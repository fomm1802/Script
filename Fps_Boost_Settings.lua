-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Save file
local SETTINGS_FILE = "FpsBoost_Settings.json"

-- Save / Load functions
local function saveSettings(level)
    if writefile then
        writefile(SETTINGS_FILE, HttpService:JSONEncode({level = level}))
    end
end

local function loadSettings()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        local data = readfile(SETTINGS_FILE)
        return HttpService:JSONDecode(data).level
    end
    return nil
end

-- Optimization Levels
local LEVEL_SETTINGS = {
    ["Ultra Low"] = {QualityLevel = Enum.QualityLevel.Level01, GlobalShadows = false, FogEnd = 0, StreamingTargetRadius = 32},
    ["Low"] = {QualityLevel = Enum.QualityLevel.Level01, GlobalShadows = false, FogEnd = 1000, StreamingTargetRadius = 64},
    ["Mid"] = {QualityLevel = Enum.QualityLevel.Level03, GlobalShadows = false, FogEnd = 500, StreamingTargetRadius = 96},
    ["High"] = {QualityLevel = Enum.QualityLevel.Level05, GlobalShadows = true, FogEnd = 250, StreamingTargetRadius = 128},
}

local selectedLevel = loadSettings() or "Ultra Low"

-- Notify
local function notify(message, success)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0.1, 0)
    notif.AnchorPoint = Vector2.new(0.5,0)
    notif.Text = message
    notif.BackgroundColor3 = success and Color3.fromRGB(30,150,50) or Color3.fromRGB(180,50,50)
    notif.BackgroundTransparency = 1
    notif.TextColor3 = Color3.new(1,1,1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.BorderSizePixel = 0
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,6)
    notif.Parent = LocalPlayer:WaitForChild("PlayerGui")

    TweenService:Create(notif,TweenInfo.new(0.3),{BackgroundTransparency=0.2}):Play()
    task.delay(2,function()
        TweenService:Create(notif,TweenInfo.new(0.3),{BackgroundTransparency=1,TextTransparency=1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- Update Optimization
local function updateOptimization()
    local settings = LEVEL_SETTINGS[selectedLevel]
    if settings then
        pcall(function()
            -- แก้ตรงนี้
            game:SetQualityLevel(settings.QualityLevel.Value) -- ใช้ Value ของ Enum
            Lighting.GlobalShadows = settings.GlobalShadows
            Lighting.FogEnd = settings.FogEnd
            Workspace.StreamingTargetRadius = settings.StreamingTargetRadius
        end)
    end
end


-- GUI Setup
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FPSBoostLite"
screenGui.ResetOnSpawn = false

-- FPS / Memory
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0,160,0,25)
fpsLabel.Position = UDim2.new(1,-180,0,20)
fpsLabel.AnchorPoint = Vector2.new(1,0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0 | Mem: 0MB"
Instance.new("UICorner",fpsLabel).CornerRadius=UDim.new(0,6)

-- Frame
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,260,0,280)
frame.Position = UDim2.new(0,20,0,20)
frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.05
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "FPS Boost Lite"
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200,200,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- Status
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1,-30,0,25)
statusLabel.Position = UDim2.new(0,15,0,240)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.Text = "Status: Waiting..."

-- Button Container
local buttonContainer = Instance.new("Frame", frame)
buttonContainer.Size = UDim2.new(1,-30,0,180)
buttonContainer.Position = UDim2.new(0,15,0,40)
buttonContainer.BackgroundTransparency = 1
local listLayout = Instance.new("UIListLayout", buttonContainer)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Padding = UDim.new(0,5)

local function createButton(parent,text,color,bold)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,30)
    btn.Text=text
    btn.BackgroundColor3=color
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    btn.TextSize=16
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.Parent=parent
    return btn
end

-- Level Buttons
for level,_ in pairs(LEVEL_SETTINGS) do
    local btn = createButton(buttonContainer,level,Color3.fromRGB(60,60,70),false)
    btn.MouseButton1Click:Connect(function()
        selectedLevel=level
        statusLabel.Text="Status: Optimizing ("..level..")"
        updateOptimization()
        notify("Optimization: "..level.." Success!",true)
        saveSettings(selectedLevel)
        statusLabel.Text="Status: Ready ("..selectedLevel..")"
    end)
end

-- Auto Optimize (High)
local autoBtn = createButton(frame,"Auto Optimize",Color3.fromRGB(150,60,60),true)
autoBtn.Position = UDim2.new(0,15,0,230)
autoBtn.MouseButton1Click:Connect(function()
    selectedLevel="High"
    statusLabel.Text="Status: Auto Optimizing..."
    updateOptimization()
    notify("Auto Optimize Complete!",true)
    saveSettings(selectedLevel)
    statusLabel.Text="Status: Ready ("..selectedLevel..")"
end)

-- Toggle Button
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size=UDim2.new(0,140,0,32)
toggleButton.Position=UDim2.new(0,20,0,20)
toggleButton.Text="Show FPS Boost UI"
toggleButton.BackgroundColor3=Color3.fromRGB(60,60,90)
toggleButton.TextColor3=Color3.new(1,1,1)
toggleButton.Font=Enum.Font.GothamBold
toggleButton.TextSize=14
Instance.new("UICorner",toggleButton).CornerRadius=UDim.new(0,8)
local uiVisible=false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible=uiVisible
    toggleButton.Text = uiVisible and "Hide FPS Boost UI" or "Show FPS Boost UI"
end)

-- Hotkey F5 toggle
UserInputService.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.F5 then
        uiVisible = not uiVisible
        frame.Visible=uiVisible
        toggleButton.Text = uiVisible and "Hide FPS Boost UI" or "Show FPS Boost UI"
    end
end)

-- FPS Monitor
local fps,frames=0,0
RunService.RenderStepped:Connect(function(dt)
    frames+=1
    fps+=dt
    if fps>=1 then
        local memUsage=Stats:GetTotalMemoryUsageMb()
        fpsLabel.Text=string.format("FPS: %d | Mem: %.2fMB",math.floor(frames/fps),memUsage)
        fps,frames=0,0
    end
end)

-- Apply initial settings
task.wait(1)
statusLabel.Text="Status: Applying Initial Settings..."
updateOptimization()
notify("Initial settings applied: "..selectedLevel,true)
statusLabel.Text="Status: Ready ("..selectedLevel..")"
