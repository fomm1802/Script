--[[ 
    FPS Boost GUI (Improved Version with Save System)
    
    This script is a refactored and improved version of the FPS Boost GUI,
    now including a save/load system using writefile/readfile.
    - The code is more modular and easier to read.
    - All optimization settings are stored in a configuration table.
    - UI creation is simplified using helper functions and UIListLayout.
    - It saves and loads the last selected FPS level to a file.
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Check if the script is running in a local environment
if not LocalPlayer then
    warn("FPSBoostGUI: This script should be a LocalScript!")
    return
end

-- Save file path
local SETTINGS_FILE = "Fps_Boost_Settings.json"

-- Optimization Levels Configuration
-- This table stores all the settings for each optimization level.
-- You can easily add or modify levels here without changing the core logic.
local LEVEL_SETTINGS = {
    ["Low"] = {
        QualityLevel = Enum.QualityLevel.Level01,
        GlobalShadows = false,
        FogEnd = 1000,
        StreamingTargetRadius = 64
    },
    ["Mid"] = {
        QualityLevel = Enum.QualityLevel.Level03,
        GlobalShadows = false,
        FogEnd = 500,
        StreamingTargetRadius = 96
    },
    ["High"] = {
        QualityLevel = Enum.QualityLevel.Level05,
        GlobalShadows = true,
        FogEnd = 250,
        StreamingTargetRadius = 128
    }
}

-- === Save/Load Functions ===

-- Function to save settings to a file
local function saveSettings(data)
    local encoded = HttpService:JSONEncode(data)
    if writefile then
        pcall(writefile, SETTINGS_FILE, encoded)
        return true
    end
    return false
end

-- Function to load settings from a file
local function loadSettings()
    if isfile and readfile and isfile(SETTINGS_FILE) then
        local success, rawData = pcall(readfile, SETTINGS_FILE)
        if success then
            local decoded = HttpService:JSONDecode(rawData)
            return decoded
        end
    end
    return {}
end

-- Load user settings on startup
local settingsData = loadSettings()
local selectedLevel = settingsData.level or "Low"

-- GUI Setup
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSBoostGuiLite"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- === Helper Functions ===

-- Notify Function: Displays a temporary notification message on the screen.
local function notify(message, isSuccess)
    local notif = Instance.new("TextLabel")
    notif.Name = "Notification"
    notif.Text = message
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0.1, 0)
    notif.BackgroundColor3 = isSuccess and Color3.fromRGB(30, 150, 50) or Color3.fromRGB(180, 50, 50)
    notif.BackgroundTransparency = 1
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BorderSizePixel = 0
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    notif.Parent = screenGui

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Fade in
    TweenService:Create(notif, tweenInfo, {BackgroundTransparency = 0.2}):Play()

    -- Wait and fade out
    task.delay(2, function()
        TweenService:Create(notif, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- Update Optimization Function: Applies settings based on the selected level.
local function updateOptimization()
    local settings = LEVEL_SETTINGS[selectedLevel]
    if not settings then
        warn("FPSBoostGUI: Invalid optimization level selected:", selectedLevel)
        return
    end

    pcall(function()
        settings().Rendering.QualityLevel = settings.QualityLevel
        Lighting.GlobalShadows = settings.GlobalShadows
        Lighting.FogEnd = settings.FogEnd
        Workspace.StreamingTargetRadius = settings.StreamingTargetRadius
    end)
end

-- Function to create a generic UI button
local function createButton(parent, text, color, bold)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    btn.TextSize = 16
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.Parent = parent
    return btn
end

-- === Main GUI Elements ===

-- FPS & Memory Display
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 160, 0, 25)
fpsLabel.Position = UDim2.new(1, -180, 0, 20)
fpsLabel.AnchorPoint = Vector2.new(1, 0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0 | Mem: 0MB"
fpsLabel.BorderSizePixel = 0
Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 6)
fpsLabel.Parent = screenGui

-- Main UI Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.05
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
frame.Parent = screenGui

-- Toggle Button
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0, 140, 0, 32)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Text = "Show FPS Boost UI"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 8)

local uiVisible = false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
    toggleButton.Text = uiVisible and "Hide FPS Boost UI" or "Show FPS Boost UI"
end)

-- Title
local title = Instance.new("TextLabel")
title.Text = "FPS Boost Lite"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -30, 0, 25)
statusLabel.Position = UDim2.new(0, 15, 0, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.Text = "Status: Waiting..."
statusLabel.Parent = frame

-- Button Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -30, 0, 100)
buttonContainer.Position = UDim2.new(0, 15, 0, 40)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = frame

-- UI Layout to organize buttons
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = buttonContainer

-- === Event Listeners ===

-- Optimization Level Buttons
for level, _ in pairs(LEVEL_SETTINGS) do
    local btn = createButton(buttonContainer, level, Color3.fromRGB(60, 60, 70), false)
    btn.Name = level .. "Button"

    btn.MouseButton1Click:Connect(function()
        selectedLevel = level
        statusLabel.Text = "Status: Optimizing ("..level..")"
        updateOptimization()
        saveSettings({level = selectedLevel})
        notify("Optimization: "..level.." Success!", true)
        statusLabel.Text = "Status: Ready ("..selectedLevel..")"
    end)
end

-- Auto Optimize Button
local autoBtn = createButton(
    buttonContainer,
    "Auto Optimize",
    Color3.fromRGB(150, 60, 60),
    true
)
autoBtn.Name = "AutoButton"
autoBtn.MouseButton1Click:Connect(function()
    selectedLevel = "High"
    statusLabel.Text = "Status: Auto Optimizing..."
    updateOptimization()
    saveSettings({level = selectedLevel})
    notify("Auto Optimize Complete!", true)
    statusLabel.Text = "Status: Ready (Auto)"
end)

-- FPS Monitor
local fps, frames = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1
    fps = fps + dt
    if fps >= 1 then
        local memUsage = Stats:GetTotalMemoryUsageMb()
        fpsLabel.Text = string.format("FPS: %d | Mem: %.2fMB", math.floor(frames / fps), memUsage)
        fps, frames = 0, 0
    end
end)

-- Apply saved settings on start
task.wait(1)
statusLabel.Text = "Status: Loading Settings..."
updateOptimization()
notify("Settings Loaded: "..selectedLevel.."!", true)
statusLabel.Text = "Status: Ready ("..selectedLevel..")"
