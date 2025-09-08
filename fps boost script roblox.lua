--[[
    FPS Boost GUI Pro Edition (Refactored + Settings Save + Toggle Rendering)
    ✅ Clean Code + Helper Functions
    ✅ Save/Load Last Optimization Level + Render State
    ✅ Auto Optimize, Notifications, FPS + Memory Monitor
    ✅ Toggle 3D Rendering (On/Off)
--]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// Config
local CONFIG = {
    Colors = {
        Main = Color3.fromRGB(60, 60, 90),
        Button = Color3.fromRGB(60, 60, 70),
        Accent = Color3.fromRGB(150, 60, 60),
        Render = Color3.fromRGB(80, 80, 150),
        Success = Color3.fromRGB(30, 150, 50),
        Error = Color3.fromRGB(180, 50, 50),
    },
    FogLevels = {
        Low = 1000,
        Mid = 500,
        High = 250,
        Maximum = 250,
    },
    SaveTag = "FPSBoostPro_SaveData"
}

--// Save/Load System
local function saveSettings(data)
    local folder = LocalPlayer:FindFirstChild(CONFIG.SaveTag) or Instance.new("Folder", LocalPlayer)
    folder.Name = CONFIG.SaveTag

    local store = folder:FindFirstChild("Settings") or Instance.new("StringValue", folder)
    store.Name = "Settings"
    store.Value = HttpService:JSONEncode(data)
end

local function loadSettings()
    local folder = LocalPlayer:FindFirstChild(CONFIG.SaveTag)
    if folder and folder:FindFirstChild("Settings") then
        local raw = folder.Settings.Value
        return HttpService:JSONDecode(raw)
    end
    return {}
end

--// UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "FPSBoostProGui"
screenGui.ResetOnSpawn = false

--// Helpers
local function makeCorner(instance, radius)
    local c = Instance.new("UICorner", instance)
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

local function notify(message, success)
    local notif = Instance.new("TextLabel")
    notif.Parent = screenGui
    notif.Text = message
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0.1, 0)
    notif.BackgroundColor3 = success and CONFIG.Colors.Success or CONFIG.Colors.Error
    notif.BackgroundTransparency = 0.2
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BorderSizePixel = 0
    makeCorner(notif, 6)

    TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    task.delay(2, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

local function createButton(parent, text, size, pos, color, bold)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = size
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color or CONFIG.Colors.Button
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    btn.TextSize = 16
    btn.AutoButtonColor = true
    makeCorner(btn, 6)
    return btn
end

--// Toggle Button
local toggleButton = createButton(screenGui, "Show FPS Boost UI", UDim2.new(0, 160, 0, 32), UDim2.new(0, 20, 0, 20), CONFIG.Colors.Main, true)

--// FPS & Memory Monitor
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Parent = screenGui
fpsLabel.Size = UDim2.new(0, 160, 0, 25)
fpsLabel.Position = UDim2.new(0, 200, 0, 20)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0 | Mem: 0MB"
fpsLabel.BorderSizePixel = 0
makeCorner(fpsLabel, 6)

--// Main Frame
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 260, 0, 360)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
makeCorner(frame, 10)

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Text = "FPS Boost Pro"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200,200,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = frame
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 1, -30)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.Text = "Status: Waiting..."

-- Toggle Frame Visibility
local uiVisible = false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
    toggleButton.Text = uiVisible and "Hide FPS Boost UI" or "Show FPS Boost UI"
end)

--// Optimization Logic
local selectedLevel = "Low"
local renderEnabled = true

local function clean(obj)
    if obj and obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end
end

local removalRules = {
    Low = {"ParticleEmitter","Trail","Smoke","Fire"},
    Mid = {"ParticleEmitter","Trail","Smoke","Fire","Beam","SpotLight","SurfaceLight","PointLight","Decal"},
    High = {"Texture","Sound","ForceField","Explosion","Sparkles","BillboardGui","SurfaceGui","ParticleEmitter","Trail","Smoke","Fire"},
}

local function updateOptimization()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if selectedLevel ~= "Maximum" then
            for _, class in ipairs(removalRules[selectedLevel] or {}) do
                if obj:IsA(class) then pcall(function() obj:Destroy() end) end
            end
            if selectedLevel == "High" then clean(obj) end
        else
            if not obj:IsA("Camera") and not obj:IsA("Humanoid") and not obj:IsA("Player") then
                pcall(function() obj:Destroy() end)
            end
            clean(obj)
        end
    end

    Lighting.FogEnd = CONFIG.FogLevels[selectedLevel] or 1000
    Workspace.StreamingEnabled = (selectedLevel == "High" or selectedLevel == "Maximum")
    Workspace.StreamingTargetRadius = (selectedLevel == "High" or selectedLevel == "Maximum") and 128 or 512
end

--// Buttons for Levels
local levels = {"Low", "Mid", "High", "Maximum"}
for i, level in ipairs(levels) do
    local btn = createButton(frame, level, UDim2.new(1, -30, 0, 30), UDim2.new(0, 15, 0, 40 + (i-1)*35))
    btn.MouseButton1Click:Connect(function()
        selectedLevel = level
        saveSettings({level = selectedLevel, render = renderEnabled})
        statusLabel.Text = "Status: Optimizing ("..level..")"
        pcall(updateOptimization)
        statusLabel.Text = "Status: Done ("..level..")"
        notify("Optimization: "..level.." applied!", true)
    end)
end

-- Auto Optimize
local autoBtn = createButton(frame, "Auto Optimize", UDim2.new(1, -30, 0, 30), UDim2.new(0, 15, 0, 200), CONFIG.Colors.Accent, true)
autoBtn.MouseButton1Click:Connect(function()
    selectedLevel = "High"
    saveSettings({level = selectedLevel, render = renderEnabled})
    statusLabel.Text = "Status: Auto Optimizing..."
    pcall(updateOptimization)
    statusLabel.Text = "Status: Done (Auto)"
    notify("Auto Optimize Complete!", true)
end)

-- Toggle Rendering
local renderBtn = createButton(frame, "Toggle Rendering (On)", UDim2.new(1, -30, 0, 30), UDim2.new(0, 15, 0, 240), CONFIG.Colors.Render, true)
renderBtn.MouseButton1Click:Connect(function()
    renderEnabled = not renderEnabled
    RunService:Set3dRenderingEnabled(renderEnabled)
    renderBtn.Text = renderEnabled and "Toggle Rendering (On)" or "Toggle Rendering (Off)"
    saveSettings({level = selectedLevel, render = renderEnabled})
    notify("3D Rendering " .. (renderEnabled and "Enabled" or "Disabled"), true)
end)

--// FPS Monitor
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

--// Load Last Settings
task.defer(function()
    local saved = loadSettings()
    if saved.level then
        selectedLevel = saved.level
        statusLabel.Text = "Status: Loading Saved ("..selectedLevel..")"
        pcall(updateOptimization)
        notify("Loaded last setting: "..selectedLevel, true)
    end
    if saved.render ~= nil then
        renderEnabled = saved.render
        RunService:Set3dRenderingEnabled(renderEnabled)
        renderBtn.Text = renderEnabled and "Toggle Rendering (On)" or "Toggle Rendering (Off)"
        notify("Rendering state restored: " .. (renderEnabled and "On" or "Off"), true)
    end
end)
