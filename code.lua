--==[ CONFIG ]==--
local SETTINGS = {
	FolderPath = workspace.Platform.Plat,   -- โฟลเดอร์ที่มี Yut
	YutClass = "BasePart",
	CollectOrder = "nearest",               -- "nearest" | "original"

	CollectSpeed = 100,                      -- ความเร็วเคลื่อนที่ (studs/วินาที)
	EaseStyle = Enum.EasingStyle.Quad,
	EaseDir = Enum.EasingDirection.Out,
	YutYOffset = -5,

	-- ขึ้นฟ้า
	TeleportHeight = 500,
	UpTime = 2,
	UpEaseStyle = Enum.EasingStyle.Sine,
	UpEaseDir = Enum.EasingDirection.Out,

	-- สร้างพื้น
	MakePlatform = true,
	PlatformSize = Vector3.new(22, 2, 22),
	PlatformColor = Color3.fromRGB(255,200,100),
	PlatformMaterial = Enum.Material.Neon,
	StandPadding = 0.5,

	HideCharacter = true,
	RestoreVisibility = true,
}

--==[ HOP หลังเก็บครบ ]==--
local HOP = {
	TargetPlaceId = 121116694547285,  -- 👈 ปลายทาง
	Data = { from = "YutCollector", ts = os.time() },
}
--=========================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--== Utils ==--
local function tween(i, info, props)
	local t = TweenService:Create(i, info, props)
	t:Play()
	t.Completed:Wait()
end

local function setVisible(on)
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") then
			d.LocalTransparencyModifier = on and 0 or 1
		end
	end
end

local function zeroVel()
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
end

local function getYuts()
	if not SETTINGS.FolderPath or not SETTINGS.FolderPath.Parent then
		warn("❌ FolderPath ไม่ถูกต้อง"); return {}
	end
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

local function moveToYut(yut, idx, total)
	if not yut or not yut.Parent then return end
	local target = yut.Position + Vector3.new(0, SETTINGS.YutYOffset, 0)
	local distance = (target - hrp.Position).Magnitude
	local time = math.max(distance / SETTINGS.CollectSpeed, 0.02)
	zeroVel()
	local info = TweenInfo.new(time, SETTINGS.EaseStyle, SETTINGS.EaseDir)
	tween(hrp, info, {CFrame = CFrame.new(target)})
	if yut and yut.Parent then yut:Destroy() end
	print(string.format("✅ เก็บแล้ว %d/%d | ระยะ %.1f studs | %.2fs", idx, total, distance, time))
end

local function createPlatform(at)
	local p = Instance.new("Part")
	p.Name = "SkyPlatform"
	p.Size = SETTINGS.PlatformSize
	p.Color = SETTINGS.PlatformColor
	p.Material = SETTINGS.PlatformMaterial
	p.Anchored = true
	p.CanCollide = true
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
	else
		hrp.Anchored = true
	end
end

--== HOP ==
local function doHop()
	if RunService:IsStudio() then
		warn("⚠️ Studio ไม่เทเลพอร์ต")
		return
	end

	print("🌍 เตรียม Hop ไป Place:", HOP.TargetPlaceId)

	local ok, err = pcall(function()
		if HOP.TargetPlaceId == game.PlaceId then
			-- ไป place เดิม (client call ได้)
			TeleportService:TeleportAsync(game.PlaceId, {player})
		else
			-- ไปคนละ place → ใช้ trick: TeleportToPlaceInstance
			local servers = TeleportService:GetPlayerPlaceInstanceAsync(HOP.TargetPlaceId)
			local targetServer = nil

			for _, info in pairs(servers) do
				if info and info.AccessCode then
					targetServer = info.AccessCode
					break
				end
			end

			if targetServer then
				TeleportService:TeleportToPlaceInstance(HOP.TargetPlaceId, targetServer, player)
			else
				TeleportService:Teleport(HOP.TargetPlaceId, player)
			end
		end
	end)

	if not ok then
		warn("❌ Hop ล้มเหลว:", err)
	else
		print("✅ Hop เรียบร้อย")
	end
end

--== Main ==--
local wasVisible = true
if SETTINGS.HideCharacter then
	wasVisible = false
	setVisible(false)
end

local yuts = getYuts()
for i, y in ipairs(yuts) do
	moveToYut(y, i, #yuts)
end

if SETTINGS.RestoreVisibility and not wasVisible then
	setVisible(true)
end

if #yuts > 0 then
	print("🚀 เก็บครบ! วาปขึ้นฟ้า...")
	upAndStand()
	print("🧱 ยืนบนฟ้าเสร็จ — เตรียม Hop!")
	doHop()
else
	warn("❌ ไม่พบ Yut ในโฟลเดอร์")
end
