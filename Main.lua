-- Load Libraries
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

-- Create Main Window
local win = lib:Window("PREVIEW", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

-- Create Tabs
local tab = win:Tab("Tab")
local tab2 = win:Tab("Tools")
local tab10 = win:Tab("ST")
local changeclr = win:Tab("Change UI Color")

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

-- Position Finder GUI Button
tab2:Button("Button Position Finder", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fomm1802/Script/refs/heads/main/Position%20Finder%20GUI.Lua"))()
end)

-- Turtle Spy Button
tab2:Button("Turtle Spy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua", true))()
end)

-- Simple Spy Button
tab2:Button("Simple Spy", function()
    loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()
end)

-- Keybind Button (RightShift)
tab10:Bind("Bind", Enum.KeyCode.RightShift, function()
    print("Pressed!")
end)

-- Label in the "ST" Tab
tab10:Label("Label")

-- Change UI Color Tab
changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255))
end)
