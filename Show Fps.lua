-- Get necessary services
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Remove existing FPS and Ping UI if it exists
local existingGui = PlayerGui:FindFirstChild("StatsDisplay")
if existingGui then
    existingGui:Destroy()
end

-- Create ScreenGui and configure properties
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsDisplay"
screenGui.Parent = PlayerGui

-- Create TextLabel for FPS and Ping display
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0, 200, 0, 50)
statsLabel.Position = UDim2.new(0, 10, 1, -60) -- Bottom left corner
statsLabel.AnchorPoint = Vector2.new(0, 1)
statsLabel.BackgroundTransparency = 0.5
statsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Semi-transparent black background
statsLabel.BorderSizePixel = 0
statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
statsLabel.Font = Enum.Font.SourceSansBold
statsLabel.TextSize = 18
statsLabel.TextStrokeTransparency = 0.8 -- Adds a subtle text outline for readability
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.Parent = screenGui

-- Variables for FPS and Ping
local frames = 0
local ping = 0

-- Count frames per second
RS.RenderStepped:Connect(function()
    frames = frames + 1
end)

-- Function to calculate Ping
local function updatePing()
    local start = tick() -- Record time before the request
    local success, result = pcall(function()
        -- Use a safe method to check ping by testing the player position request
        Player:RequestStreamAroundAsync(Player.Character and Player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0))
    end)
    if success then
        ping = math.floor((tick() - start) * 1000) -- Convert time to milliseconds
    else
        ping = "N/A" -- If request fails, display "N/A"
    end
end

-- Update FPS and Ping display every second
while wait(0.25) do
    updatePing() -- Get the latest Ping
    statsLabel.Text = string.format("FPS: %d\nPing: %s ms", frames, ping) -- Display FPS and Ping
    frames = 0
end
