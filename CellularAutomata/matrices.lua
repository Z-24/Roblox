--[[
    matrices.lua
    Author: Afrxzo
    Sun, 04/25/2021 (MM/DD/YY)

    matrices.lua is the file responsible for constructing
    2-Dimensional arrays and allowing CellularAutomata to map
    3D space into grid space.
--]]

local Matrices = {}
Matrices.__index = Matrices

function Matrices.new(SizeX: number, SizeY: number, DefaultValue: any)
    local Matrix = setmetatable({}, Matrices)
    for Row = 1, SizeX do
        Matrix[Row] = {}
        for Column = 1, SizeY do
            Matrix[Row][Column] = DefaultValue or 0 
        end
    end
    return Matrix
end

--[[**
    Constructs a new Matrix
    @param [number] The amount of 'Rows'
    @param [number] The amount of 'Columns'
    {@param [any] The default value of the matrix expression}
    @returns [Matrix]
-]]

function Matrices:Iterate()
    local Row = 1
    local Column = 0
    local function Iterator()
        if Column == #self[Row] then
            Row = Row + 1
            Column = 0
        end
        if Row > #self then return end
        Column = Column + 1
        return Row, Column, self[Row][Column]
    end
    return Iterator
end

--[[**
    Returns an iterator function
    @returns [Row: number], [Column: number], [Value: number]
]]

return Matrices