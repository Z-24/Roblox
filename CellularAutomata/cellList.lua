--[[
	parent  : cellularAutomata.lua
	children: none
	ModuleScript
  ]]--
--instead of a config file, arguments like board size are passed into the start function directly, instead this file only houses cell configurations
local cell = require(script.Parent.cell);

--[[
	assigning the config/cell list table to a variable before returning it is unneeded
	all that matters for a modulescript is it's return value, so if we never do anything meaningful with the variable why not just return the table directly?
  ]]--
return {
	--[[
		filling out the cells in this list using the cell.new constructor rather than filling out the table literals directly
		the whole point of an object constructor is to *avoid* having to manually declare all the properties of an object like this, so why manually fill it out here?
		this is also more readable as the declarations are simpler and don't have large, nested tables
	  ]]--
	cell.new("Zombie", {
		color = Color3.new(0.764705, 0, 1),
		mutRate = 0.4,
		strength = 1
	}),
	
	cell.new("Human", {
		color = Color3.new(0, 0.376470, 0.592156),
		mutRate = 0.2,
		strength = 0.8
	}),
	
	cell.new("Alien", {
		color = Color3.new(0.752941, 0, 0),
		mutRate = 0.1,
		strength = 1.1
	}),
	
	cell.new("Rat", {
		color = Color3.new(0.654901, 0.654901, 0.654901),
		mutRate = 10,
		strength = 0.5
	}),
	
	cell.new("Corona", {
		color = Color3.new(1, 0.733333, 0),
		mutColor = Color3.new(0.439215, 0.321568, 0),
		mutRate = 1000,
		strength = math.huge
	})
};