--==[ CONFIG | ปรับตรงนี้พอ ]==--
local SETTINGS = {
	-- เก็บ Yut
	FolderPath = workspace.Platform.Plat, -- โฟลเดอร์ที่มีชิ้น "Yut"
	YutClass = "BasePart",
	CollectOrder = "nearest",    -- "nearest" | "original"
	CollectSpeed = 2,
	CollectEaseStyle = Enum.EasingStyle.Quad,
	CollectEaseDir = Enum.EasingDirection.Out,
	YutYOffset = -2,

	-- วาปขึ้นฟ้า
	TeleportHeight = 500,
	UpSpeed = 2,
	UpEaseStyle = Enum.EasingStyle.Sine,
	UpEaseDir = Enum.EasingDirection.Out,

	-- การมองเห็น
	HideCharacter = true,
	RestoreVisibility = true,

	-- พื้นบนฟ้า
	MakePlatform = true,         -- true = สร้างพื้น / false = ลอยค้าง
	PlatformSize = Vector3.new(22, 2, 22),
	PlatformColor = Color3.fromRGB(255, 200, 100),
	PlatformMaterial = Enum.Material.Neon,
	PlatformName = "SkyPlatform",
	PlatformYOffset = 0.0,       -- + ขึ้น / - ลง จากตำแหน่งปลายทาง
	PlatformFadeIn = 0.25,       -- 0 = ไม่เฟด
	PlatformLifetime = 0,        -- 0 = ถาวร (ใช้ Debris ถ้า > 0)
	ExtraStandPadding = 0.5,     -- กันทะลุหลังวางบนพื้น
}

--==[ HOP CONFIG ]==--
-- โหมด hop หลังทำเสร็จ:
--   Mode = "off"        -> ไม่ hop
--   Mode = "public"     -> ไป public server ของ placeId ที่ตั้ง
--   Mode = "reserved"   -> สร้างห้อง Reserved (ทำที่ Server) แล้วเข้า
--   HopAllPlayers=true  -> (เฉพาะบนเซิร์ฟเวอร์) พาทั้งห้องไปด้วย
local HOP = {
	Enabled = true,
	Mode = "public",                -- "off" | "public" | "reserved"
	TargetPlaceId = game.PlaceId,   -- เป้าหมาย
	HopAllPlayers = false,          -- true = พาทั้งห้อง (ทำบนเซิร์ฟเวอร์เท่านั้น)
	MaxRetries = 3,
	RetryDelay = 2,
	TeleportData = { from = "YutCollector", ts = os.time() },
}
--================================

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
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

local function getYuts()
	if not SETTINGS.FolderPath or not SETTINGS.FolderPath.Parent then
		warn("[Collector] FolderPath ไม่ถูกต้อง")
		return {}
	end
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

--== เก็บ Yut ==
local function moveToAndCollect(yut: BasePart, idx: number, total: number)
	if not yut or not yut.Parent then return end
	local targetPos = yut.Position + Vector3.new(0, SETTINGS.YutYOffset, 0)
	local info = TweenInfo.new(SETTINGS.CollectSpeed, SETTINGS.CollectEaseStyle, SETTINGS.CollectEaseDir)
	tween(hrp, info, { CFrame = CFrame.new(targetPos) })

	if yut and yut.Parent then
		yut:Destroy()
	end
	print(string.format("เก็บแล้ว: %d/%d", idx, total))
end

--== สร้างพื้น ==
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

--== วาปขึ้น + ยืนจริง ==
local function teleportUpAndStand()
	local upPos = hrp.Position + Vector3.new(0, SETTINGS.TeleportHeight, 0)
	local info = TweenInfo.new(SETTINGS.UpSpeed, SETTINGS.UpEaseStyle, SETTINGS.UpEaseDir)
	tween(hrp, info, { CFrame = CFrame.new(upPos) })

	zeroVelocity()

	if SETTINGS.MakePlatform then
		local platform = createPlatform(upPos)
		local standHeight = (SETTINGS.PlatformSize.Y/2) + humanoid.HipHeight + SETTINGS.ExtraStandPadding
		hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, standHeight, 0))
		if humanoid:GetState() == Enum.HumanoidStateType.Physics then
			humanoid:ChangeState(Enum.HumanoidStateType.Landed)
		end
		hrp.Anchored = false
	else
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		hrp.Anchored = true
	end
end

--== HOP ==
local function hopPublicSelf()
	local opts = Instance.new("TeleportOptions")
	opts:SetTeleportData(HOP.TeleportData)
	-- ใน LocalScript แนะนำ teleport เฉพาะตัวเอง
	TeleportService:TeleportAsync(HOP.TargetPlaceId, {player}, opts)
end

local HopRemote -- RemoteEvent สำหรับสั่งเซิร์ฟเวอร์
local function getHopRemote()
	if HopRemote then return HopRemote end
	HopRemote = ReplicatedStorage:FindFirstChild("HopRemote")
	if not HopRemote then
		-- รอสคริปต์เซิร์ฟเวอร์สร้าง
		HopRemote = ReplicatedStorage:WaitForChild("HopRemote", 5)
	end
	return HopRemote
end

local function hopReservedViaServer()
	local remote = getHopRemote()
	if not remote then
		warn("[HOP] ไม่มี HopRemote ใน ReplicatedStorage")
		return
	end
	remote:FireServer({
		mode = "reserved",
		targetPlaceId = HOP.TargetPlaceId,
		hopAll = HOP.HopAllPlayers,
		data = HOP.TeleportData,
	})
end

local function hopPublicAllViaServer()
	local remote = getHopRemote()
	if not remote then
		warn("[HOP] ไม่มี HopRemote ใน ReplicatedStorage")
		return
	end
	remote:FireServer({
		mode = "publicAll",
		targetPlaceId = HOP.TargetPlaceId,
		hopAll = true,
		data = HOP.TeleportData,
	})
end

local function hopToNextServer()
	if not HOP.Enabled or HOP.Mode == "off" then return end
	if RunService:IsStudio() then
		warn("[HOP] ข้ามการ Teleport ใน Studio")
		return
	end

	for attempt = 1, HOP.MaxRetries do
		local ok, err = pcall(function()
			if HOP.Mode == "reserved" then
				hopReservedViaServer() -- ให้เซิร์ฟเวอร์จัดการ
			elseif HOP.Mode == "public" and HOP.HopAllPlayers then
				hopPublicAllViaServer() -- public ทั้งห้อง -> ทำบนเซิร์ฟเวอร์
			else
				hopPublicSelf() -- public เฉพาะตัวเอง -> ทำบน client ได้
			end
		end)
		if ok then
			print(string.format("[HOP] เริ่มวาร์ป (mode=%s)...", HOP.Mode))
			return
		else
			warn(string.format("[HOP] ล้มเหลวครั้งที่ %d: %s", attempt, tostring(err)))
			task.wait(HOP.RetryDelay)
		end
	end
	warn("[HOP] หมดสิทธิ์ลองใหม่ ยังวาร์ปไม่ได้")
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
	if yut and yut:IsA(SETTINGS.YutClass) then
		moveToAndCollect(yut, i, total)
	end
end

if SETTINGS.RestoreVisibility and not originalVisibilityOn then
	setCharacterVisible(true)
end

if total > 0 then
	print("✅ เก็บครบ! เตรียมขึ้นฟ้า…")
	teleportUpAndStand()
	print("🧱 เรียบร้อย! ยืนได้มั่นคงบนฟ้า — เตรียม hop")
	hopToNextServer()
else
	warn("⚠️ ไม่พบ Yut ในโฟลเดอร์ที่ตั้งค่าไว้")
end
