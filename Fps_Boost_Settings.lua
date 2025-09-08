--[[ 
    FPS Boost GUI (Lite Version)
    ✅ Features
    - Levels: Low / Mid / High
    - Auto Optimize (เลือก High ให้เอง)
    - Real-time FPS & Memory Monitor
    - Notify System
    - Save Settings (writefile/readfile)
    ❌ No Maximum Mode
    ❌ No 3D Rendering Toggle (mouse safe)
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

-- Save file path
local SETTINGS_FILE = "Fps_Boost_Settings.json"

-- Save function
local function saveSettings(data)
    local encoded = HttpService:JSONEncode(data)
    if writefile then
        writefile(SETTINGS_FILE, encoded)
    end
end

-- Load function
local function loadSettings()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        local raw = readfile(SETTINGS_FILE)
        return HttpService:JSONDecode(raw)
    end
    return {}
end

-- Load user settings
local settingsData = loadSettings()
local selectedLevel = settingsData.level or "Low"

-- GUI Setup
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FPSBoostGuiLite"
screenGui.ResetOnSpawn = false

-- Toggle Button
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0, 140, 0, 32)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Text = "Show FPS Boost UI"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.AutoButtonColor = true
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 8)

-- Notify Function
local function notify(message, success)
    local notif = Instance.new("TextLabel", screenGui)
    notif.Text = message
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0.1, 0)
    notif.BackgroundColor3 = success and Color3.fromRGB(30, 150, 50) or Color3.fromRGB(180, 50, 50)
    notif.BackgroundTransparency = 0.2
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BorderSizePixel = 0
    local notifCorner = Instance.new("UICorner", notif)
    notifCorner.CornerRadius = UDim.new(0, 6)

    TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 0, BackgroundTransparency = 0.2}):Play()
    task.delay(2, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- FPS & Memory Display
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0, 160, 0, 25)
fpsLabel.Position = UDim2.new(0, 180, 0, 20)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0 | Mem: 0MB"
fpsLabel.BorderSizePixel = 0
local fpsCorner = Instance.new("UICorner", fpsLabel)
fpsCorner.CornerRadius = UDim.new(0, 6)

-- Status Label
local statusLabel = Instance.new("TextLabel", screenGui)
statusLabel.Size = UDim2.new(0, 300, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.Text = "Status: Waiting..."

-- Main GUI Frame
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.05
local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Toggle Frame Visibility
local uiVisible = false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
    toggleButton.Text = uiVisible and "Hide FPS Boost UI" or "Show FPS Boost UI"
end)

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "FPS Boost Lite"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- Optimization Levels
local levels = {"Low", "Mid", "High"}
local buttons = {}

local function clean(obj)
    if obj and obj:IsA("BasePart") then 
        obj.Material = Enum.Material.SmoothPlastic 
        obj.Reflectance = 0 
        obj.CastShadow = false 
    end
end

local function removeIf(obj, condition)
    if condition and obj and obj.Destroy then 
        pcall(function() obj:Destroy() end) 
    end
end

function updateOptimization()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if selectedLevel == "Low" then
            removeIf(obj, obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire"))
        elseif selectedLevel == "Mid" then
            removeIf(obj, obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Beam") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") or obj:IsA("PointLight") or obj:IsA("Decal"))
        elseif selectedLevel == "High" then
            removeIf(obj, obj:IsA("Texture") or obj:IsA("Sound") or obj:IsA("ForceField") or obj:IsA("Explosion") or obj:IsA("Sparkles") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire"))
            clean(obj)
        end
    end
    if selectedLevel == "High" then
        Lighting.FogEnd = 250
        Workspace.StreamingEnabled = true
        Workspace.StreamingTargetRadius = 128
    elseif selectedLevel == "Mid" then
        Lighting.FogEnd = 500
    elseif selectedLevel == "Low" then
        Lighting.FogEnd = 1000
    end
end

-- Create Button Function
local function createButton(parent, text, size, pos, color, bold)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    btn.TextSize = 16
    btn.AutoButtonColor = true
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    return btn
end

-- Level Buttons
for i, level in ipairs(levels) do
    local btn = createButton(
        frame,
        level,
        UDim2.new(1, -30, 0, 30),
        UDim2.new(0, 15, 0, 40 + (i - 1) * 35),
        Color3.fromRGB(60, 60, 70),
        false
    )

    btn.MouseButton1Click:Connect(function()
        selectedLevel = level
        statusLabel.Text = "Status: Optimizing ("..level..")"
        pcall(updateOptimization)
        statusLabel.Text = "Status: Done ("..level..")"
        notify("Optimization: "..level.." Success!", true)
        saveSettings({level = selectedLevel})
    end)
    buttons[level] = btn
end

-- Auto Optimize Button
local autoBtn = createButton(
    frame,
    "Auto Optimize",
    UDim2.new(1, -30, 0, 30),
    UDim2.new(0, 15, 0, 160),
    Color3.fromRGB(150, 60, 60),
    true
)
autoBtn.MouseButton1Click:Connect(function()
    selectedLevel = "High"
    statusLabel.Text = "Status: Auto Optimizing..."
    pcall(updateOptimization)
    statusLabel.Text = "Status: Done (Auto)"
    notify("Auto Optimize Complete!", true)
    saveSettings({level = selectedLevel})
end)

-- FPS Monitor
local fps, frames = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frames += 1
    fps += dt
    if fps >= 1 then
        local mb = math.floor(Stats:GetTotalMemoryUsageMb())
        fpsLabel.Text = "FPS: " .. tostring(math.floor(frames / fps)) .. " | Mem: " .. mb .. "MB"
        fps, frames = 0, 0
    end
end)

-- Apply saved settings on start
task.wait(1)
statusLabel.Text = "Status: Loading Settings..."
pcall(updateOptimization)
statusLabel.Text = "Status: Ready ("..selectedLevel..")"
notify("Settings Loaded: "..selectedLevel, true)
