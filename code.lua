--==[ CONFIG | ปรับตรงนี้พอ ]==--
local SETTINGS = {
	-- เก็บ Yut
	FolderPath = workspace.Platform.Plat,
	YutClass = "BasePart",       -- กรองชนิด (BasePart เท่านั้น)
	CollectOrder = "nearest",    -- "nearest" | "original"

	CollectSpeed = 2,         -- เวลาทำ Tween ไปเก็บต่อชิ้น
	CollectEaseStyle = Enum.EasingStyle.Quad,
	CollectEaseDir = Enum.EasingDirection.Out,
	YutYOffset = -2,             -- ต่ำกว่าจุด Yut นิดหน่อย กันชนค้าง

	-- วาปขึ้นฟ้า
	TeleportHeight = 500,
	UpSpeed = 2,
	UpEaseStyle = Enum.EasingStyle.Sine,
	UpEaseDir = Enum.EasingDirection.Out,

	-- การมองเห็น
	HideCharacter = true,        -- ซ่อนตัวระหว่างเก็บ
	RestoreVisibility = true,    -- เสร็จแล้วคืนค่าความโปร่งใส

	-- พื้นบนฟ้า
	MakePlatform = true,         -- true = สร้างพื้น, false = ลอยค้าง
	PlatformSize = Vector3.new(22, 2, 22),
	PlatformColor = Color3.fromRGB(255, 200, 100),
	PlatformMaterial = Enum.Material.Neon,
	PlatformName = "SkyPlatform",
	PlatformYOffset = 0.0,       -- เลื่อนพื้นขึ้น/ลงจาก upPos
	PlatformFadeIn = 0.25,       -- วินาทีในการเฟดเข้าของพื้น (0 = ไม่เฟด)
	PlatformLifetime = 0,        -- วินาที; 0 = อยู่ถาวร (Debris จะลบให้ถ้า > 0)

	-- ความปลอดภัยฟิสิกส์
	ExtraStandPadding = 0.5,     -- กันทะลุหลังวางบนพื้น
}
--================================

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--== Utils ==
local function tween(instance: Instance, info: TweenInfo, props: table)
	local tw = TweenService:Create(instance, info, props)
	tw:Play()
	tw.Completed:Wait()
	return tw
end

local function getYuts()
	local list = {}
	for _, obj in ipairs(SETTINGS.FolderPath:GetChildren()) do
		if obj:IsA(SETTINGS.YutClass) then
			table.insert(list, obj)
		end
	end
	if SETTINGS.CollectOrder == "nearest" then
		table.sort(list, function(a, b)
			return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
		end)
	end
	return list
end

local function setCharacterVisible(isVisible: boolean)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = isVisible and 0 or 1
		end
	end
end

local function zeroVelocity()
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
end

--== เก็บ Yut ==
local function moveToAndCollect(yut: BasePart, idx: number, total: number)
	if not yut or not yut.Parent then return end
	local targetPos = yut.Position + Vector3.new(0, SETTINGS.YutYOffset, 0)
	local info = TweenInfo.new(SETTINGS.CollectSpeed, SETTINGS.CollectEaseStyle, SETTINGS.CollectEaseDir)
	tween(hrp, info, { CFrame = CFrame.new(targetPos) })

	-- กันเคสโดนลบระหว่างทาง
	if yut and yut.Parent then
		yut:Destroy()
	end
	print(string.format("เก็บแล้ว: %d/%d", idx, total))
end

--== สร้างพื้น (มั่นใจว่าชนได้ + เฟดเข้า) ==
local function createPlatform(atPos: Vector3)
	local p = Instance.new("Part")
	p.Name = SETTINGS.PlatformName
	p.Size = SETTINGS.PlatformSize
	p.Color = SETTINGS.PlatformColor
	p.Material = SETTINGS.PlatformMaterial
	p.Anchored = true
	p.CanCollide = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth

	local yOffset = SETTINGS.PlatformSize.Y/2 + SETTINGS.PlatformYOffset
	p.CFrame = CFrame.new(atPos - Vector3.new(0, yOffset, 0))
	p.Parent = workspace

	if SETTINGS.PlatformFadeIn > 0 then
		p.Transparency = 1
		tween(p, TweenInfo.new(SETTINGS.PlatformFadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0})
	end
	if SETTINGS.PlatformLifetime > 0 then
		Debris:AddItem(p, SETTINGS.PlatformLifetime)
	end
	return p
end

--== วาปขึ้น + วางให้ยืนจริง ==
local function teleportUpAndStand()
	local upPos = hrp.Position + Vector3.new(0, SETTINGS.TeleportHeight, 0)
	local info = TweenInfo.new(SETTINGS.UpSpeed, SETTINGS.UpEaseStyle, SETTINGS.UpEaseDir)
	tween(hrp, info, { CFrame = CFrame.new(upPos) })

	zeroVelocity()

	if SETTINGS.MakePlatform then
		local platform = createPlatform(upPos)
		local standHeight = (SETTINGS.PlatformSize.Y/2) + humanoid.HipHeight + SETTINGS.ExtraStandPadding
		hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, standHeight, 0))
		-- ให้ยืนปกติ
		if humanoid:GetState() == Enum.HumanoidStateType.Physics then
			humanoid:ChangeState(Enum.HumanoidStateType.Landed)
		end
		hrp.Anchored = false
	else
		-- ลอยค้าง (ถ้าไม่สร้างพื้น)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		hrp.Anchored = true
	end
end

--== Main ==
local originalVisibilityOn = true
if SETTINGS.HideCharacter then
	originalVisibilityOn = false
	setCharacterVisible(false)
end

local yuts = getYuts()
local total = #yuts
for i, yut in ipairs(yuts) do
	if yut:IsA(SETTINGS.YutClass) then
		moveToAndCollect(yut, i, total)
	end
end

if SETTINGS.RestoreVisibility and not originalVisibilityOn then
	setCharacterVisible(true)
end

if total > 0 then
	print("✅ เก็บครบ! เตรียมขึ้นฟ้า…")
	teleportUpAndStand()
	print("🧱 เรียบร้อย! ยืนได้มั่นคงบนฟ้า")
else
	warn("⚠️ ไม่พบ Yut ในโฟลเดอร์ที่ตั้งค่าไว้")
end
