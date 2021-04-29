--[[
	parent  : cellularAutomata.lua
	children: none
	ModuleScript
  ]]--
local cell = {};

--positions are vector3's, Z is interpreted as the "Y" axis for the 2D space cells inhabit
local function node(pos, color)
	--node constructor more or less the same as the original, except the name is less wordy
	local newNode = Instance.new("Part");
	newNode.Name = pos.X..pos.Z;
	newNode.Size = Vector3.new(1, 1, 1);
	newNode.Position = pos;
	newNode.Color = color;
	newNode.TopSurface = Enum.SurfaceType.Smooth;
	newNode.Anchored = true;
	newNode.Parent = workspace:WaitForChild("Nodes");
	return newNode;
end;

function cell.new(name, dna, pos)
	--[[
		again class emulation is entirely unnecessary here, we never even inherit from it so why bother emulating class functionality?
		this constructor also doesn't need board size, as "ratio" is unused in this version
		we also take a DNA argument directly, more on that in the place the :Spawn function would be
		
		also, spawning a node is optional and only occurs if we provide a position. this allows me to use the constructor to make templates that i can re-use
		
		i also make the property names less wordy, "cell.CellName" is redundant, i know it's a cell name, im accessing a property of a cell, i don't need the property name to remind me it's parent object is a cell
	  ]]--
	return {
		name = name								  ,
		dna  = dna								  ,
		node = pos and node(pos, dna.color) or nil, --ternary operation, be careful with over-using these, they're not the fastest thing in the world. if you don't know how this works i'd recommend looking up "lua ternary operator"
		pos  = pos
	};
end;

function cell.clone(host, pos)
	--[[
		this function is used to clone cells from a template
		and due to how the .new constructor works, i can provide a position and give the cell a physical node
		this allows me to use the constructor in places like the cellList file to make templates
		and avoid unecessary large table definitions
	  ]]--
	return cell.new(host.name, host.dna, pos);
end;

function cell.setNode(host, pos)
	--unused, yet kept for utility
	host.node = node(pos, host.dna.color);
	host.pos = pos;
end;

local MUTATION_BONUS = 1.2;
local DARKEN_AMOUNT = 0.0150305;

--[[
	you may notice i don't use : functions here
	it's because again, class emulation is unneeded
	it's not that hard to just make a function in the module that takes our object as an argument and manipulates it
	it'll also run faster, as it won't have to deal with metatables
  ]]--
function cell.mutate(host)
	--[[
		using constants and compound assignments for the mutations, to avoid repetition
		if you don't know what a compound assignment is, i'd highly recommend looking them up, they're quite useful
		in a nutshell i can do something like "x *= 5" which is equivalent to "x = x * 5"
	  ]]--
	host.dna.mutRate *= MUTATION_BONUS;
	host.dna.strength *= MUTATION_BONUS;
	local color = host.node.Color;
	--instead of only darkening the color once, the color is darkened several times as the cell mutates so you can tell at a glance how strong a cell might be
	host.node.Color = Color3.new(math.clamp(color.R - DARKEN_AMOUNT, 0, 1), math.clamp(color.G - DARKEN_AMOUNT, 0, 1), math.clamp(color.B - DARKEN_AMOUNT, 0, 1));
end;

--[[
	Spawn has been omitted, it's pointless
	what's the point of having a constructor if i have to call some sort of strange second constructor to actually make the object usable?
	you can easily assign all of these properties in the constructor directly
	and with making the spawning of a node optional, there's no need to do any weird recoloring of "none" nodes, i can just spawn the cell's node directly when needed
  ]]--

function cell.infect(host, victim)
	--more or less the same as the original function, but is not a function of the object, it's just a function which takes our object
	victim.name = host.name;
	victim.dna = host.dna;
	victim.node.Color = host.node.Color;
end;

return cell;

