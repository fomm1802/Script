--==[ CONFIG ]==--
local SETTINGS = {
	FolderPath = workspace.Platform.Plat,  -- โฟลเดอร์ที่มี Yut
	YutClass = "BasePart",
	CollectOrder = "nearest",              -- "nearest" | "original"

	CollectSpeed = 50,                    -- ความเร็ววิ่งไปเก็บ (studs/วินาที)
	EaseStyle = Enum.EasingStyle.Quad,
	EaseDir = Enum.EasingDirection.Out,
	YutYOffset = -2,

	-- ขึ้นฟ้า (เวลาใช้เป็น "วินาที" ตรงๆ ตาม Tween)
	TeleportHeight = 500,
	UpTime = 2,
	UpEaseStyle = Enum.EasingStyle.Sine,
	UpEaseDir = Enum.EasingDirection.Out,

	-- ทำพื้น (ถ้าอยากลอยค้าง set เป็น false)
	MakePlatform = true,
	PlatformSize = Vector3.new(22, 2, 22),
	PlatformColor = Color3.fromRGB(255,200,100),
	PlatformMaterial = Enum.Material.Neon,
	StandPadding = 0.5,                    -- กันทะลุ (เพิ่มจาก HipHeight)

	HideCharacter = true,
	RestoreVisibility = true,
}

--==[ HOP หลังเก็บครบ ]==--
-- Mode: "off" | "public" | "reserved"
-- public: เทเลพอร์ตตัวเองไป public เซิร์ฟของ place เป้าหมาย
-- reserved: ให้เซิร์ฟเวอร์สร้างห้องแล้วพาไป (ต้องมี ServerScript ด้านล่าง)
local HOP = {
	Mode = "public",
	TargetPlaceId = game.PlaceId,
	MaxRetries = 3,
	RetryDelay = 2,
	HopAllPlayers = false,  -- เฉพาะโหมดที่เซิร์ฟทำ (publicAll/reserved)
	Data = { from = "YutCollector", ts = os.time() },
}
--=========================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--== Utils ==
local function tween(i, info, props)
	local t = TweenService:Create(i, info, props); t:Play(); t.Completed:Wait(); return t
end
local function setVisible(on)
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = on and 0 or 1 end
	end
end
local function zeroVel()
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
end

local function getYuts()
	local arr = {}
	for _, o in ipairs(SETTINGS.FolderPath:GetChildren()) do
		if o:IsA(SETTINGS.YutClass) then table.insert(arr, o) end
	end
	if SETTINGS.CollectOrder == "nearest" then
		table.sort(arr, function(a,b)
			return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
		end)
	end
	return arr
end

--== เคลื่อนที่ด้วย "ความเร็วจริง" ==--
local function moveToYut(yut, idx, total)
	if not yut or not yut.Parent then return end
	local target = yut.Position + Vector3.new(0, SETTINGS.YutYOffset, 0)
	local distance = (target - hrp.Position).Magnitude
	local time = math.max(distance / math.max(SETTINGS.CollectSpeed, 1), 0.02)

	local info = TweenInfo.new(time, SETTINGS.EaseStyle, SETTINGS.EaseDir)
	tween(hrp, info, {CFrame = CFrame.new(target)})

	if yut and yut.Parent then yut:Destroy() end
	print(string.format("เก็บแล้ว %d/%d | ระยะ %.1f studs | %.2fs", idx, total, distance, time))
end

--== ทำพื้นยืน ==
local function createPlatform(at)
	local p = Instance.new("Part")
	p.Size = SETTINGS.PlatformSize
	p.Color = SETTINGS.PlatformColor
	p.Material = SETTINGS.PlatformMaterial
	p.Anchored = true
	p.CanCollide = true
	p.Name = "SkyPlatform"
	p.CFrame = CFrame.new(at - Vector3.new(0, SETTINGS.PlatformSize.Y/2, 0))
	p.Parent = workspace
	return p
end

local function upAndStand()
	local upPos = hrp.Position + Vector3.new(0, SETTINGS.TeleportHeight, 0)
	local info = TweenInfo.new(SETTINGS.UpTime, SETTINGS.UpEaseStyle, SETTINGS.UpEaseDir)
	tween(hrp, info, {CFrame = CFrame.new(upPos)})

	zeroVel()

	if SETTINGS.MakePlatform then
		local pf = createPlatform(upPos)
		local standY = SETTINGS.PlatformSize.Y/2 + humanoid.HipHeight + SETTINGS.StandPadding
		hrp.CFrame = CFrame.new(pf.Position + Vector3.new(0, standY, 0))
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
local function hop_public_self()
	local opts = Instance.new("TeleportOptions"); opts:SetTeleportData(HOP.Data)
	TeleportService:TeleportAsync(HOP.TargetPlaceId, {player}, opts)
end
local function getRemote()
	local r = ReplicatedStorage:FindFirstChild("HopRemote")
	if not r then r = ReplicatedStorage:WaitForChild("HopRemote", 5) end
	return r
end
local function hop_via_server(mode)
	local r = getRemote(); if not r then warn("ไม่มี HopRemote"); return end
	r:FireServer({
		mode = mode, -- "reserved" | "publicAll"
		targetPlaceId = HOP.TargetPlaceId,
		hopAll = HOP.HopAllPlayers,
		data = HOP.Data,
	})
end
local function doHop()
	if HOP.Mode == "off" then return end
	if RunService:IsStudio() then warn("Studio ไม่เทเลพอร์ต"); return end

	for i=1, HOP.MaxRetries do
		local ok, err = pcall(function()
			if HOP.Mode == "public" and not HOP.HopAllPlayers then
				hop_public_self()
			elseif HOP.Mode == "public" and HOP.HopAllPlayers then
				hop_via_server("publicAll")
			elseif HOP.Mode == "reserved" then
				hop_via_server("reserved")
			end
		end)
		if ok then print("[HOP] start"); return else warn("[HOP] fail", i, err); task.wait(HOP.RetryDelay) end
	end
end

--== Main ==
local wasVisible = true
if SETTINGS.HideCharacter then wasVisible = false; setVisible(false) end

local yuts = getYuts()
for i, y in ipairs(yuts) do moveToYut(y, i, #yuts) end

if SETTINGS.RestoreVisibility and not wasVisible then setVisible(true) end

if #yuts > 0 then
	print("✅ เก็บครบ! ขึ้นฟ้า…"); upAndStand(); print("🧱 เสร็จ — hop!")
	doHop()
else
	warn("ไม่พบ Yut ในโฟลเดอร์")
end
