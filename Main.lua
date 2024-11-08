-- Load Libraries
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

-- Create Main Window
local win = lib:Window("PREVIEW", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

-- Create Tabs
local tab = win:Tab("Tab")
local tab2 = win:Tab("Tools")
local tab10 = win:Tab("ST")

-- Variables
local teleportLoop = false  -- To manage the teleport loop state

-- Teleport Loop 1 (Teleport to specific position)
tab:Toggle("Teleport Loop 1", false, function(t)
    teleportLoop = t  -- Update teleport loop state
    if teleportLoop then
        -- Start teleport loop
        spawn(function()
            while teleportLoop do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(621.4434204101562, 130.55836486816406, 342.1183776855469)
                end
                wait(1)  -- Delay between teleports
            end
        end)
    end
end)

-- Teleport Loop Afk (Teleport to another position)
tab:Toggle("Teleport Loop Afk", false, function(t)
    teleportLoop = t  -- Update teleport loop state
    if teleportLoop then
        -- Start teleport loop
        spawn(function()
            while teleportLoop do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-1500.524169921875, -234.71974182128906, -2859.197265625)
                end
                wait(1)  -- Delay between teleports
            end
        end)
    end
end)

tab:Toggle("Teleport Loop Afk 2 Player", false, function(t)
    teleportLoop = t  -- Update teleport loop state
    if teleportLoop then
        -- Start teleport loop
        spawn(function()
            while teleportLoop do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-1669.128173828125, -214.18020629882812, -2840.79736328125)
                end
                wait(1)  -- Delay between teleports
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

