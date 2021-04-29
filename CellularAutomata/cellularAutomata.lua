--[[
	parent  : irrelevant
	children: cell.lua, cellList.lua, matrix.lua
	ModuleScript
  ]]--
--i use comments like the one above to easily tell what the parent > child tree is without having to read through the code
local automata = {};

--constant declarations up here unecessary, if you're going to have constants, atleast put them at the earliest point they're used
--control variables also unused, we can just break from the main loop when needed

--[[
	GetLivingCellCount has been omitted entirely
	it is entirely unecessary for us to iterate through the **entire** matrix to figure out how many cells are alive
	as we can keep track manually within the loop
	this function will bottleneck in large boards, it'd perform not only a large iteration, but also a generic table.sort (not that optimized) *every frame*
  ]]--

local function gridSpace(position, origin)
	--[[
		used to translate world space to a grid position
		since the cells are all offset from the center in this version, you can do (current pos of axis - center axis) to get the board coordinate for that axis from a world space position
		
		this function avoids the need of several tables that just hold the grid position, as we can simply translate it when needed
	  ]]--
	return Vector2.new(position.X - origin.X, position.Z - origin.Z);
end;

local function adjacent(host, board, origin)
	local adjacents = {};
	--[[
		the old name of this function was extremely wordy, "GetMovableCells" is alot to describe a function that just gets the adjacent cells of another
		instead of having an ugly wall of manual move position declarations, i instead use the gridSpace function
		to get the grid position, and then simply iterate from one to the left of the cell, to one to the right of the cell
		and one to the bottom, one to the top
		this ensures every possible adjacent cell is checked and avoids wasting cycles manually declaring moves in a table
		addtionally, the "Board[pos] ~= nil" statements are unecessary, if statements execute if the expression given can be casted to a boolean true
		"nil" and "false" are the only types in lua that can be casted to false, everything else casts to true
		so all you need to do to ensure the square exists is just "if board[x]", if "board[x]" is nil, it'll be casted to false, so the if statement wont run it's block
		i also used the "and" logical operator to avoid unecessary nested if statements
		this is also significantly more readable
	  ]]--
	local gridPos = gridSpace(host.pos, origin)
	for x = gridPos.X - 1, gridPos.X + 1 do
		for y = gridPos.Y - 1, gridPos.Y + 1 do
			if board[x] and board[x][y] and board[x][y].name ~= host.name then
				adjacents[#adjacents + 1] = board[x][y];
			end;
		end;
	end;
	return adjacents;
end;

local cell = require(script.cell); --i put the declaration for the require at it's earliest use point, this function, so that others reading the code don't have to scroll up 50 lines to find it's declaration at the top of the file when they see it's name, instead it's just right here
local function infectCells(host, board, origin)
	--[[
		several problems with this function have been fixed
		1) the name is less wordy
		2) MovableCells is an unecessary variable, it's only used once, you may as well just put the function call directly into the pairs statement
		3) the check of "if NeighborCell.CellName == "None" then NeighborCell:Infect(Host) end" is pointless, none cells have a strength of 0, so "host.dna.strength > victim.dna.strength" will always succeed against them
		
		i still check for the cell name being none, but not to capture it, instead to determine that a new cell has been created which is used to keep track of the current cell count (more on the start function)
	  ]]--
	local newCells = {};
	for _, victim in ipairs(adjacent(host, board, origin)) do
		if host.dna.strength > victim.dna.strength then
			if victim.name == "None" then
				newCells[#newCells + 1] = victim;
			end;
			cell.infect(host, victim);
		else
			cell.infect(victim, host);
		end;
	end;
	return newCells;
end;

--[[
	Setup has also been omitted
	there is no reason to make the board a property of the module itself, why would the user ever want to access it?
	there is also no need for constants that control the board size, why not let the user define the board size in the start function and make the board appropriately?
	it's also more intuitive to use, since all the user needs to do is call module.start, rather than module:Setup() (which takes no args) and *then* module.start
  ]]--

local matrix = require(script.matrix);
function automata.start(boardX, boardY, origin, cellsPerFrame, tickSpeed, cellList)
	--[[
		this function has gone through several improvements, both for usability but also better code
		let's start with the immediate code improvements
		1) less wordy name, "StartSimulation" is a bit much. I know im using a simulation module. there aren't any other functions related to "starting" anything, it'd be pretty clear what this does if we just named it "start"
		2) no uses of classes or :, there's nothing that's worth making a property of the module besides the functions for controlling the simulation
		3) removed use of Random, it's just "math.random" wrapped in a slower, OOP shell
		arguments like cellList give the user more control over the behavior of the function, allowing them to provide custom cell lists without modifying the cellList module
	  ]]--
	local board = matrix.new(boardX, boardY);
	--default argument setting
	if typeof(origin	   ) ~= "Vector3" then origin        = Vector3.new(0, 1, 0    ) end;
	if type	 (cellsPerFrame) ~= "number"  then cellsPerFrame = 10 					    end;
	if type	 (tickSpeed	   ) ~= "number"  then tickSpeed     = 0 						end;
	if type	 (cellList	   ) ~= "table"   then cellList 	 = require(script.cellList) end;
	
	local livingCells = 0; --instead of having a dedicated function to keep track of living cells, we increment a number throughout the main loop
	local activeCells = {};
	do
		local alreadyUsed = {};
		for i, template in pairs(cellList) do
			if i > board.size then
				warn("cell list is larger than total board size, only "..(i - 1).." cell"..(i - 1 > 1 and "s" or "").." spawned");
				break;
			end;
			local x, y;
			repeat
				wait()
				x, y = math.random(1, board.cols), math.random(1, board.rows);
			until not alreadyUsed[x..y];
			alreadyUsed[x..y] = true;
			local host = cell.clone(template, Vector3.new(origin.X + x, origin.Y, origin.Z + y)) --cloning the template, but providing a position for the node from the origin
			board[x][y] = host;
			activeCells[#activeCells + 1] = host
			livingCells += 1;
		end;
		
		--instead of filling the board with "none" cells and then recoloring them, i spawn each normal cell randomly first, then fill in all empty spaces with none cells
		local empty = cell.new("None", {
			color = Color3.new(1,1,1),
			strength = 0
		});
		for x = 1, board.cols do
			for y = 1, board.rows do
				if not board[x][y] then
					board[x][y] = cell.clone(empty, Vector3.new(origin.X + x, origin.Y, origin.Z + y));
				end;
			end;
		end;
	end;
	
	local heartbeat = game:GetService("RunService").Heartbeat;
	local lastTick = tick();
	--removed coroutines, can be added back in if asynchronous behavior is desired, but felt it was unecessary for this function
	--one thing though, the nested coroutine is entirely unecessary and wastes resources since you're remaking it each frame in the original loop
	while livingCells < board.size do --instead of having a control variable, we can just put the check directly into the expression for the while loop
		if tick() - lastTick >= tickSpeed then
			--controls the speed of the simulation using the tickspeed arg, allowing the user to choose how fast the simulation progresses
			lastTick = tick();
			for i = 1, cellsPerFrame do --allow the user to control how many cells are processed per tick
				--[[
					this is an optimization and a QoL improvement
					activeCells is used to control the cells that we iterate through
					this array includes every cell that isn't a "none" cell, so we dont waste iterations skipping past "none" cells
					this allows for faster visible simulation on larger boards
				  ]]--
				local host = activeCells[math.random(1, #activeCells)];
				--removed unecessary variable declarations, they're only used once, just move their values directly into the expression in the if statement
				if math.random() / host.dna.mutRate <= 0.01 then
					cell.mutate(host);
				end;
					
				local newCells = infectCells(host, board, origin);
				livingCells += #newCells; --since infectCells returns an array of all new cells, we can simply increment livingCells by the length of the array
				table.move(newCells, 1, #newCells, #activeCells + 1, activeCells);
			end;
		end;
		heartbeat:Wait();
	end;
	
	print("pandemic reached");
end;

return automata;