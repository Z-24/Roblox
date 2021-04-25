-- init.lua
-- Afrxzo
-- Thu, 08/04/2021

-- This module is the main interface for the placing and interchanging of building pieces, all of the interfaces main
-- logic runs here independently, of course without taking Config.lua into consideration. A major code refactor is
-- more than likely to happen.

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local Settings = require(script.Config)

local Camera = workspace.CurrentCamera
local EditModeView = workspace.EditView 

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementEnded = ReplicatedStorage:WaitForChild("PlacementEnded")

local PlacedBuilds = {}

local InEditMode = false
local SelectedBuild
local Selection
local CanPlace = false

-- Key-Bind Mapping

local function RKeyPressed(InputObject, gameProcessed, callBack)
    if gameProcessed then return end
    if InputObject.KeyCode == Enum.KeyCode.R then
        callBack()
    end
end

local function EKeyPressed(InputObject, gameProcessed, callBack)
    if gameProcessed then return end
    if InputObject.KeyCode == Enum.KeyCode.E then
        callBack()
    end
end

local function QKeyPressed(InputObject, gameProcessed, callBack)
    if gameProcessed then return end
    if InputObject.KeyCode == Enum.KeyCode.Q then
        callBack()
    end
end

-- Private Methods

local function Serialize(Part)
    local Properties = {"Size", "CFrame", "Name", "Color", "CanCollide", "Anchored", "Material", "Orientation"}
    local Serialized = {}
    for _, Property in pairs(Properties) do
        if Property == "CFrame" or Property == "Size" or Property == "Orientation" then
            Serialized[Property] = {Part[Property].X, Part[Property].Y, Part[Property].Z}
        elseif Property == "Color" then
            Serialized[Property] = {Part[Property].R, Part[Property].G, Part[Property].B}
        else
            Serialized[Property] = Part[Property]
        end
    end
    return game:GetService("HttpService"):JSONEncode(Serialized)
end

local function EnterEditMode()
    Camera.CameraType = Enum.CameraType.Scriptable
    game:GetService("TweenService"):Create(Camera, TweenInfo.new(
        1,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    ), {CFrame = EditModeView.CFrame}):Play()
    InEditMode = true
end

local function ExitEditMode()
    game:GetService("TweenService"):Create(Camera, TweenInfo.new(
        1,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    ), {CFrame = Player.Character.Head.CFrame}):Play()
    if Selection then
        Selection:Destroy()
        Selection = nil
        SelectedBuild = nil
    end
    delay(1.5, function()
        InEditMode = false
        Camera.CameraType = Enum.CameraType.Custom
    end)
end

local function SnapToGrid(Position, Canvas)
    return Vector3.new(
        math.floor((Position.X / Settings.GridSnapBase) * Settings.GridSnapBase),
        (Canvas.Position.Y) + 0.55,
        math.floor((Position.Z / Settings.GridSnapBase) * Settings.GridSnapBase)
    )
end

local function clampToBounds(vector,base)
    local MinimumX, MaximumX = (base.Position.X - (base.Size.X / 2)), (base.Position.X + (base.Size.X / 2))
    local MinimumZ, MaximumZ = (base.Position.Z - (base.Size.Z / 2)), (base.Position.Z + (base.Size.Z / 2))
    return Vector3.new(math.clamp(vector.X, MinimumX, MaximumX), 0, math.clamp(vector.Z, MinimumZ, MaximumZ))
end

local function RotateSelection()
    if SelectedBuild ~= nil and Selection ~= nil then
        Selection.CFrame =  CFrame.Angles(0, math.rad(Selection.Orientation.Y + Settings.RotationalIncrement), 0)
    end
end

local function InverseRotateSelection()
    if SelectedBuild ~= nil and Selection ~= nil then
        Selection.CFrame =  CFrame.Angles(0, math.rad(Selection.Orientation.Y - Settings.RotationalIncrement), 0)
    end
end

local function SelectBuild()
    if SelectedBuild and InEditMode then return end
end


local function GetTouchingParts(Part)
    local Connection = Part.Touched:Connect(function() end)
    local results = Part:GetTouchingParts()
    Connection:Disconnect()
    return results
end

local function PlaceBuild()
    if SelectedBuild ~= nil and Selection ~= nil and CanPlace then
        SelectedBuild.CFrame = Selection.CFrame
        SelectedBuild.CanCollide = true
        table.insert(PlacedBuilds, SelectedBuild)
        --PlacementEnded:FireServer(Serialize(SelectedBuild))
        Selection:Destroy()
        Selection = nil
        SelectedBuild = nil
    end
end

-- Public Methods

local PlacementModule = {}

function PlacementModule:Bind(Build, Canvas)
    EnterEditMode()
    self.Canvas = Canvas
    SelectedBuild = Build

    local selection = SelectedBuild:Clone()
    selection.Parent = workspace
    selection.Color = Color3.fromRGB(0, 255, 0)
    selection.Transparency = 0.8
    selection.Position = clampToBounds(SnapToGrid(Mouse.Hit.Position, PlacementModule.Canvas), PlacementModule.Canvas)
    Selection = selection
end

function PlacementModule:Exit()
    ExitEditMode()
end

coroutine.wrap(function()
    while RunService.Heartbeat:Wait() do
        if SelectedBuild ~= nil then
            local results = GetTouchingParts(Selection)
            for _, Part in pairs(results) do
                if table.find(PlacedBuilds, Part) then 
                    CanPlace = false
                    Selection.CanCollide = true
                    Selection.Color = Color3.fromRGB(255, 0, 0)
                    Selection.Position = Selection.Position
                else
                    CanPlace = true
                    Selection.Color = Color3.fromRGB(0, 255, 0)
                    Selection.Position = clampToBounds(SnapToGrid(Mouse.Hit.Position, PlacementModule.Canvas), PlacementModule.Canvas)
                end
            end
            --Selection.Position = clampToBounds(SnapToGrid(Mouse.Hit.Position, PlacementModule.Canvas), PlacementModule.Canvas)
        end
    end
end)()

Mouse.Button1Down:Connect(PlaceBuild)
Mouse.Button1Down:Connect(SelectBuild)
UserInputService.InputBegan:Connect(function(InputObject, GameProcessed)
    RKeyPressed(InputObject, GameProcessed, RotateSelection)
    EKeyPressed(InputObject, GameProcessed, InverseRotateSelection)
    QKeyPressed(InputObject, GameProcessed, ExitEditMode)
end)

return PlacementModule

