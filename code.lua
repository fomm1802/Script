--==[ CONFIG ]==--
local SETTINGS = {
	CollectSpeed = 1.2,
	UpSpeed = 2,
	HideCharacter = true,
	YutYOffset = -2,
	TeleportHeight = 500,
	PlatformSize = Vector3.new(20, 1, 20),
	PlatformColor = Color3.fromRGB(255, 200, 100),
	FolderPath = workspace.Platform.Plat
}
--==============--

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

-- ✅ สร้างพื้นตรงตำแหน่งที่กำหนด (แน่นอนว่าชนได้)
local function createPlatform(atPosition)
	local p = Instance.new("Part")
	p.Name = "SkyPlatform"
	p.Size = SETTINGS.PlatformSize
	p.Color = SETTINGS.PlatformColor
	p.Material = Enum.Material.Neon
	p.Anchored = true
	p.CanCollide = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	-- วางให้ “หลังคา” อยู่พอดีกับ atPosition (เลยลดครึ่งความหนา)
	p.CFrame = CFrame.new(atPosition - Vector3.new(0, SETTINGS.PlatformSize.Y/2, 0))
	p.Parent = workspace
	return p
end

local function teleportUp()
	print("✅ เก็บครบ! วาปขึ้นฟ้า~ 🚀")

	-- ใช้ upPos เดิมเป็น “ตำแหน่งจริง” ทั้งสำหรับพื้นและตัวละคร
	local upPos = hrp.Position + Vector3.new(0, SETTINGS.TeleportHeight, 0)

	local tweenInfo = TweenInfo.new(SETTINGS.UpSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(upPos)})
	tween:Play()
	tween.Completed:Wait()

	-- สร้างพื้นที่ upPos (ไม่อิง hrp.Position ที่อาจยังไม่อัพเดต)
	local platform = createPlatform(upPos)

	-- รีเซ็ตความเร็วป้องกันเด้ง/ไถล
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	-- วางตัวละครให้สูงจากพื้นแบบพอดี (เผื่อ HipHeight)
	local standY = SETTINGS.PlatformSize.Y/2 + humanoid.HipHeight + 0.5
	hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, standY, 0))

	-- ให้ยืนได้ตามปกติ (อย่าใช้ Physics)
	if humanoid:GetState() == Enum.HumanoidStateType.Physics then
		humanoid:ChangeState(Enum.HumanoidStateType.Landed)
	end
	hrp.Anchored = false

	print("🧱 สร้างพื้นเสร็จและยืนได้เรียบร้อย!")
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
