--==[ CONFIG ]==--
local SETTINGS = {
	CollectSpeed = 50,           -- ความเร็วเคลื่อนที่ (studs/วินาที)
	UpSpeed = 2,                  -- ความเร็วตอนวาปขึ้นฟ้า (วินาที)
	HideCharacter = true,
	YutYOffset = -2,
	TeleportHeight = 500,
	PlatformSize = Vector3.new(20, 1, 20),
	PlatformColor = Color3.fromRGB(255, 200, 100),
	FolderPath = workspace.Platform.Plat,
}
--================--

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local yuts = SETTINGS.FolderPath:GetChildren()
local totalYut = #yuts
local collected = 0

local function hideCharacter()
	if not SETTINGS.HideCharacter then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

-- ✅ ใช้ “ความเร็ว” แทน “เวลา”
local function moveToYut(yut)
	local targetPos = yut.Position + Vector3.new(0, SETTINGS.YutYOffset, 0)
	local distance = (targetPos - hrp.Position).Magnitude
	local time = distance / SETTINGS.CollectSpeed  -- ⬅️ ระยะ ÷ ความเร็ว

	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})

	tween:Play()
	tween.Completed:Wait()

	yut:Destroy()
	collected += 1
	print(string.format("เก็บแล้ว: %d/%d (ระยะ %.1f studs ใช้เวลา %.2fs)", collected, totalYut, distance, time))
end

local function createPlatform(pos)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Size = SETTINGS.PlatformSize
	p.Color = SETTINGS.PlatformColor
	p.Material = Enum.Material.Neon
	p.CFrame = CFrame.new(pos - Vector3.new(0, SETTINGS.PlatformSize.Y/2, 0))
	p.Parent = workspace
	return p
end

local function teleportUp()
	print("✅ เก็บครบ! วาปขึ้นฟ้า~ 🚀")

	local upPos = hrp.Position + Vector3.new(0, SETTINGS.TeleportHeight, 0)
	local tweenInfo = TweenInfo.new(SETTINGS.UpSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(upPos)})

	tween:Play()
	tween.Completed:Wait()

	local platform = createPlatform(upPos)
	local standY = SETTINGS.PlatformSize.Y / 2 + humanoid.HipHeight + 0.5
	hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, standY, 0))

	humanoid:ChangeState(Enum.HumanoidStateType.Landed)
	print("🧱 สร้างพื้นและยืนได้เรียบร้อย!")
end

hideCharacter()
for _, yut in ipairs(yuts) do
	if yut:IsA("BasePart") then
		moveToYut(yut)
	end
end

if collected == totalYut then
	teleportUp()
end
