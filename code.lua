--==[ CONFIG ส่วนนี้ปรับได้เลย ไม่ต้องไปรื้อข้างล่าง ]==--
local SETTINGS = {
	CollectSpeed = 0.1,          -- ความเร็วตอน Tween เก็บ Yut
	UpSpeed = 2,                 -- ความเร็วตอนวาปขึ้นฟ้า
	HideCharacter = true,        -- จะให้ซ่อนตัวไหม (true/false)
	YutYOffset = -2,             -- ระยะต่ำกว่าตัว Yut ตอน Tween ไปหา
	TeleportHeight = 500,        -- ความสูงที่จะวาปขึ้นฟ้า
	PlatformSize = Vector3.new(20, 1, 20), -- ขนาดพื้น
	PlatformColor = Color3.fromRGB(255, 200, 100), -- สีพื้น
	FolderPath = workspace.Platform.Plat  -- โฟลเดอร์ที่มี Yut ทั้งหมด
}
--============================================================--

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- ดึง Yut ทั้งหมด
local yuts = SETTINGS.FolderPath:GetChildren()
local totalYut = #yuts
local collected = 0

-- ฟังก์ชันซ่อนตัว
local function hideCharacter()
	if not SETTINGS.HideCharacter then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

-- ฟังก์ชัน Tween ไปเก็บ Yut
local function moveToYut(yut)
	local targetPos = yut.Position + Vector3.new(0, SETTINGS.YutYOffset, 0)
	local tweenInfo = TweenInfo.new(SETTINGS.CollectSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})

	tween:Play()
	tween.Completed:Wait()

	yut:Destroy()
	collected += 1
	print("เก็บแล้ว: " .. collected .. "/" .. totalYut)
end

-- ฟังก์ชันสร้างพื้นไว้ยืน
local function createPlatform(position)
	local platform = Instance.new("Part")
	platform.Size = SETTINGS.PlatformSize
	platform.Color = SETTINGS.PlatformColor
	platform.Anchored = true
	platform.Material = Enum.Material.Neon
	platform.Name = "SkyPlatform"
	platform.CFrame = CFrame.new(position - Vector3.new(0, SETTINGS.PlatformSize.Y / 2, 0))
	platform.Parent = workspace
	return platform
end

-- ฟังก์ชันวาปขึ้นฟ้า + สร้างพื้น
local function teleportUp()
	print("✅ เก็บครบ! วาปขึ้นฟ้า~ 🚀")

	local upPos = hrp.Position + Vector3.new(0, SETTINGS.TeleportHeight, 0)
	local tweenInfo = TweenInfo.new(SETTINGS.UpSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(upPos)})

	tween:Play()
	tween.Completed:Wait()

	-- สร้างพื้นไว้ยืน
	local platform = createPlatform(hrp.Position)

	-- ล็อกตำแหน่งตัวละครให้อยู่บนพื้น
	hrp.CFrame = platform.CFrame + Vector3.new(0, SETTINGS.PlatformSize.Y / 2 + 2, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	hrp.Anchored = false

	print("🧱 มีพื้นให้ยืนบนฟ้าเรียบร้อยแล้ว~")
end

-- เริ่มทำงาน
hideCharacter()
for _, yut in ipairs(yuts) do
	if yut:IsA("BasePart") then
		moveToYut(yut)
	end
end

if collected == totalYut then
	teleportUp()
end
