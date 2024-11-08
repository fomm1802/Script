-- Load Libraries
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

-- Create Main Window
local win = lib:Window("PREVIEW", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

-- Create Tabs
local tab = win:Tab("Tab")
local tab2 = win:Tab("Tools")
local tab10 = win:Tab("ST")

-- Load Libraries
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0, Enum.EasingStyle.Linear) -- ตั้งเวลาในการเคลื่อนที่เป็น 0 วินาที

-- Main Teleport Function with Tween
local function teleportToPosition(position)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = position})
        tween:Play()
    end
end

-- Toggle Functions for Different Positions
local teleportLoop1 = false
local teleportLoopAfk = false
local teleportLoopAfk2 = false

-- Teleport Loop 1 (Position 1)
tab:Toggle("Teleport Loop 1", false, function(t)
    teleportLoop1 = t
    if teleportLoop1 then
        spawn(function()
            while teleportLoop1 do
                teleportToPosition(CFrame.new(621.4434204101562, 130.55836486816406, 342.1183776855469))
                wait(1)
            end
        end)
    end
end)

-- Teleport Loop Afk (Position 2)
tab:Toggle("Teleport Loop Afk", false, function(t)
    teleportLoopAfk = t
    if teleportLoopAfk then
        spawn(function()
            while teleportLoopAfk do
                teleportToPosition(CFrame.new(-1500.524169921875, -234.71974182128906, -2859.197265625))
                wait(1)
            end
        end)
    end
end)

-- Teleport Loop Afk 2 Player (Position 3)
tab:Toggle("Teleport Loop Afk 2 Player", false, function(t)
    teleportLoopAfk2 = t
    if teleportLoopAfk2 then
        spawn(function()
            while teleportLoopAfk2 do
                teleportToPosition(CFrame.new(-1669.128173828125, -214.18020629882812, -2840.79736328125))
                wait(1)
            end
        end)
    end
end)


tab2:Button("Custom Keyboard Gui", function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/RedZenXYZ/4d80bfd70ee27000660e4bfa7509c667/raw/da903c570249ab3c0c1a74f3467260972c3d87e6/KeyBoard%2520From%2520Ohio%2520Fr%2520Fr", true))()
end)

-- Position Finder GUI Button
tab2:Button("Position Finder", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fomm1802/Script/refs/heads/main/Position%20Finder%20GUI.Lua", true))()
end)

tab2:Button("Position V2 ?", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fomm1802/Script/refs/heads/main/Position%20%3F.lua", true))()
end)

-- Turtle Spy Button
tab2:Button("Turtle Spy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua", true))()
end)

-- Simple Spy Button
tab2:Button("Simple Spy", function()
    loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua", true))()
end)

-- Keybind Button (RightShift)
--tab10:Bind("Bind", Enum.KeyCode.Home, function()
--print("Pressed!")
--end)

