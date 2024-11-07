-- Get necessary services
local RS = game:GetService("RunService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui and configure properties
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui

-- Create TextLabel for FPS display
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 80, 0, 30)
fpsLabel.Position = UDim2.new(0, 10, 1, -40) -- Bottom left corner
fpsLabel.AnchorPoint = Vector2.new(0, 1)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Semi-transparent black background
fpsLabel.BorderSizePixel = 0
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 20
fpsLabel.TextStrokeTransparency = 0.8 -- Adds a subtle text outline for readability
fpsLabel.Parent = screenGui

-- FPS counting variables
local frames = 0

-- Count frames per second
RS.RenderStepped:Connect(function()
    frames = frames + 1
end)

-- Update FPS display every second
while wait(0.5) do
    fpsLabel.Text = string.format("FPS: %d", frames)
    frames = 0
end
