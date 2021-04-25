--[[
    cell.lua
    Author: Afrxzo
    Sun, 04/25/2021 (MM/DD/YY)

    cell.lua is the main component of the CellAutomata 
    simulation. cell.lua constructs a new Cell object, that is
    responsible for how the cell interacts with other cells
    and the behaviour and characteristics of the cell.
--]]

local Cell = {}
Cell.__index = Cell

-- Dependencies
local CellInfo = require(script.Parent.config).Cells

local function CreateNode(Ratio, PositionX, PositionY)
    local Node = Instance.new("Part")
    Node.Name = PositionX..PositionY
    Node.Size = Vector3.new(Ratio, 1, Ratio)
    Node.Color = Color3.new(1, 1, 1)
    Node.Position = Vector3.new(PositionY, 1, PositionX)
    Node.Anchored = true
    Node.TopSurface = Enum.SurfaceType.Smooth
    Node.Parent = workspace:WaitForChild("Nodes")
end

function Cell.new(BoardSizeX: number, BoardSizeY: number, PositionX: number, PositionY: number)
    local NewCell = setmetatable({}, Cell)
    local Ratio = (BoardSizeX / BoardSizeY)
    -- More external information for our cell
    NewCell.CellName = "None"
    NewCell.DNA = {}
    NewCell.Node = CreateNode(Ratio, PositionX, PositionY)
    NewCell.Position = {PositionY, PositionX}
    return NewCell
end

--[[**
    Instantiates a new Cell Object
    @param [number] The X Length of the Matrix Board
    @param [number] The Y Height of the Matrix Board
    @param [number] The X Position of the Cell in the Matrix Board
    @param [number] The Y Position of the Cell in the Matrix Board
    @returns [Cell]
]]

function Cell:Mutate()
    local MutationRate = self.DNA.MutationRate
    local Strength = self.DNA.Strength
    self.DNA.MutationRate = (MutationRate * 1.2)
    self.DNA.Strength = (Strength * 1.2)
    self.Node.Color = CellInfo[self.CellName].MutatedColor
end

--[[**
    Mutates the Cell Object
    @returns [void]
]]

function Cell:Spawn(CellName)
    self.CellName = CellName
    self.DNA = CellInfo[CellName].DNA
    self.Node.Color = CellInfo[CellName].Color
end

--[[**
    Sets the Cell Object to a foreign Cell
    @param [string] The identifier of the Cell to set to
    @returns [void]
]]

function Cell:Infect(Host)
    self.CellName = Host.CellName
    self.DNA = Host.DNA
    self.Node.Color = CellInfo[Host.CellName].Color
end

--[[**
    Infects the Cell Object with the Host (another Cell Object)
    @param [Cell]
    @returns [void]
]]

return Cell