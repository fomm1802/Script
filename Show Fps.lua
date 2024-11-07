-- Get necessary services
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Remove existing FPS UI if it exists
local existingGui = PlayerGui:FindFirstChild("StatsDisplay")
if existingGui then
    existingGui:Destroy()
end

-- Create ScreenGui and configure properties
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsDisplay"
screenGui.Parent = PlayerGui

-- Create TextLabel for FPS display
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 100, 0, 50)
fpsLabel.Position = UDim2.new(0, 10, 1, -60) -- Bottom left corner
fpsLabel.AnchorPoint = Vector2.new(0, 1)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Semi-transparent black background
fpsLabel.BorderSizePixel = 0
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 18
fpsLabel.TextStrokeTransparency = 0.8 -- Adds a subtle text outline for readability
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.TextYAlignment = Enum.TextYAlignment.Top
fpsLabel.Parent = screenGui

-- Variables for FPS
local frames = 0
local lastUpdate = tick() -- Track the last time we updated the FPS

-- Count frames per second
RS.RenderStepped:Connect(function()
    frames = frames + 1
end)

-- Update FPS display every second with a debounce mechanism for stability
while wait(1) do
    local currentTime = tick()

    -- Update FPS only once per second
    if currentTime - lastUpdate >= 1 then
        fpsLabel.Text = string.format("FPS: %d", frames) -- Display FPS only
        frames = 0
        lastUpdate = currentTime
    end
end
