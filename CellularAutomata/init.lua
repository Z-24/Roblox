--[[
    CellularAutomata.lua
    Author: Afrxo
    Sun, 04/25/2021 (MM/DD/YY)

    CellularAutomata is a Roblox Module, designed to simulate the 
    division and multiplication of cells.
--]]

local CellularAutomata = {}

-- Required Components
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

-- Dependencies
local Matrices = require(script.matrices)
local Cell = require(script.cell)
local Config = require(script.config)

-- Constants
local MAP_SIZE_X = Config.MapSize[1]
local MAP_SIZE_Y = Config.MapSize[2]

-- Control Variables
local Pandemic = false

-- Private Methods

local function GetLivingCellCount(Board: board)
    local CellCount = {}
    for CellName, _ in pairs(Config.Cells) do
        CellCount[CellName] = 0
    end
    for _, _, CellValue in Board:Iterate() do
        local CellName = CellValue.CellName
        CellCount[CellName] = CellCount[CellName] + 1
    end
    table.sort(CellCount, function(Operand1, Operand2)
        return Operand2 < Operand1
    end)
    return CellCount
end

local function GetMovableCells(Board: board, Host: cell, PositionY: number, PositionX: number)
    local Moves = {}
    local HostName = Host.CellName
    local MovableCells = {}
    --[[
        Seems confusing at first, what we are doing here is
        translating pointers in Grid Space  around the host cell.
    ]]
    Moves[1] = {PositionY + 1, PositionX}
    Moves[2] = {PositionY - 1, PositionX}
    Moves[3] = {PositionY, PositionX - 1}
    Moves[4] = {PositionY, PositionX + 1}
    Moves[5] = {PositionY + 1, PositionX - 1}
    Moves[6] = {PositionY + 1, PositionX + 1}
    Moves[7] = {PositionY - 1, PositionX - 1}
    Moves[8] = {PositionY - 1, PositionX + 1}
    for _, Move in pairs(Moves) do
        if Board[Move[1]] ~= nil then
            if Board[Move[1]][Move[2]] ~= nil then
                local PosCell = Board[Move[1]][Move[2]]
                if PosCell.Name ~= HostName then
                    --[[ 
                        Negating finding cells that are of the same type,
                        to prevent memory allocation and having cells
                        try to orientate themselves around their own 
                        cell type.
                    ]]
                    table.insert(MovableCells, PosCell)
                end
            end
        end
    end
    return MovableCells
end

local function InfectClosestCells(Board: board, Host: cell)
    --[[
        Capturing the movable cell spaces around our host cell,
        then infecting them if possible, we are also checking the
        cells stats to see if we actually can infect that cell.
    ]]
    local MovableCells = GetMovableCells(Board, Host, Host.Position[1], Host.Position[2])
    for _, NeighborCell in pairs(MovableCells) do
        if NeighborCell.CellName == "None" then
            NeighborCell:Infect(Host)
        else
            if NeighborCell.DNA.Strength > Host.DNA.Strength then
                Host:Infect(NeighborCell)
            else
                NeighborCell:Infect(Host)
            end 
        end
    end
end

-- Public Methods

function CellularAutomata:Setup()
    --[[
        Setting up a 2-Dimensional Array to compile 
        (X, Y, Z) plane to (Y, X) grid space and creating
        a physical plane.
    ]]
    self.Board = Matrices.new(MAP_SIZE_Y, MAP_SIZE_X)
    for Row, Column, _ in self.Board:Iterate() do
        --[[
            Here we are constructing a new cell object, that
            controls and mimics the behaviour of a cell
        ]]
        self.Board[Row][Column] = Cell.new(MAP_SIZE_X, MAP_SIZE_Y, Row, Column)
    end
end

--[[**
    Sets up the Simulator and creates a plane mapped to the matrix.
    @returns [void]
]]

function CellularAutomata:StartSimulation()
    local RandomGenerator = Random.new()
    for CellName, Stats in pairs(Config.Cells) do
        if Stats.Enabled then
            self.Board[RandomGenerator:NextInteger(1, MapSizeX)][RandomGenerator:NextInteger(1, MapSizeY)]:Spawn(CellName)
        end
    end 
    --[[
        In this case, iterating over every element in the matrix wouldn't be
        visually appealing, since cells would only multiply lineraly. To get 
        a better visual, we can simply select any random cell in the matrix, 
        and then multiply it.
    --]]
    coroutine.wrap(function()
        while not Pandemic do
            coroutine.wrap(function()
                for i = 0, 10 do
                    local NextCell = self.Board[RandomGenerator:NextInteger(1, MapSizeX)][RandomGenerator:NextInteger(1, MapSizeY)]
                    if NextCell.CellName ~= "None" then
                        --[[
                            In this case we would have to filter out empty cells,
                            because they are simply hollow entities that serve the
                            mechanics no function.
                        ]]
                        local MutationRate = NextCell.DNA.MutationRate
                        local Percentage = math.random() / MutationRate
                        if Percentage  <= 0.01 then
                            NextCell:Mutate()
                        end
                        --[[
                            Over here, we are using a RNG based weighting system,
                            to realistically determine wether cells mutate.
                        ]]
                        InfectClosestCells(self.Board, NextCell)
                    end
                end
            end)()
            --[[
                We want to be able to kill the task of infecting cells when
                there aren't any infectable cells left. To do so we can simply
                use a control variable, that determines wether we should be 
                looking for cells to infect. 
            ]]
            for _, Count in pairs(GetLivingCellCount(self.Board)) do
                if Count == (MAP_SIZE_Y * MAP_SIZE_X) then
                    Pandemic = true
                end
            end
            Heartbeat:Wait()
        end
    end)()
end

--[[**
    This method runs the simulator, until a global pandemic is reached.
    @returns [void]
]]

return CellularAutomata
