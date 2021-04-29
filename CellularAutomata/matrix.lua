--[[
	parent  : cellularAutomata.lua
	children: none
	ModuleScript
  ]]--
local matrix = {};

function matrix.new(cols, rows)
	--emulation of a class is simply unneeded here
	local newMatrix = {
		cols = cols,
		rows = rows,
		size = cols * rows
	};
	--only initializing the tables for each column, why set each row in the columns to 0 if they're going to be changed into an entirely different type later and we never use the initial 0 value?
	for i = 1, cols do
		newMatrix[i] = {};
	end;
	
	return newMatrix;
end;

--iterator function unneeded, this version of the project never iterates through the entire matrix

return matrix;