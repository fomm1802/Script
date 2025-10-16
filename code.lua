--============================================================
--  Yut Warp Collector (No Destroy) - วาร์ปเร็ว ชนแล้วเก็บ
--============================================================

-- === ตั้งค่าเร็ว ๆ ===
local YUT_PATH   = "workspace.Platform.Plat" -- พาธกอง Yut (แก้ให้ตรงแมพ)
local HIDE_WHILE = true                      -- ซ่อนตัวระหว่างเก็บไหม
local WARP_UP    = 100                       -- วาร์ปขึ้นฟ้าเมื่อเก็บครบ (studs)
local STEP_WAIT  = 0.05                      -- หน่วงระหว่างวาร์ปแต่ละอัน

--============================================================
local Players = game:GetService("Players")
local player  = Players.LocalPlayer
local char    = player.Character or player.CharacterAdded:Wait()
local hrp     = char:WaitForChild("HumanoidRootPart")

-- ซ่อน/โชว์ตัวละคร
local function setVisible(character, visible)
	local vis = visible and 0 or 1
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = vis
			for _, d in ipairs(part:GetChildren()) do
				if d:IsA("Decal") then d.Transparency = vis end
			end
		elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
			part.Handle.Transparency = vis
		end
	end
end

-- หา object จาก path
local function safeGet(pathStr)
	local ref = workspace
	local steps = string.split(pathStr, ".")
	if steps[1] == "workspace" then table.remove(steps, 1) end
	for _, name in ipairs(steps) do
		if not ref then return nil end
		ref = ref:FindFirstChild(name)
	end
	return ref
end

-- หา part สำหรับแต่ละก้อน
local function getPartFor(obj)
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		if obj.PrimaryPart then return obj.PrimaryPart end
		for _, d in ipairs(obj:GetDescendants()) do
			if d:IsA("BasePart") then return d end
		end
	end
	return nil
end

-- ดึงรายการทั้งหมด
local function listYuts()
	local container = safeGet(YUT_PATH)
	if not container then return {} end
	local arr = {}
	for _, o in ipairs(container:GetChildren()) do
		local p = getPartFor(o)
		if p then table.insert(arr, p) end
	end
	return arr
end

-- วาร์ปไปหาแต่ละก้อน
local function warpTo(part)
	char = player.Character or player.CharacterAdded:Wait()
	hrp  = char:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, -2, 0))
	task.wait(STEP_WAIT)
end

-- วาร์ปขึ้นฟ้าเมื่อเสร็จ
local function warpUp()
	hrp.CFrame = hrp.CFrame + Vector3.new(0, WARP_UP, 0)
end

--============================================================
-- MAIN
--============================================================
print("[YutWarp] เริ่มวาร์ปไปเก็บแบบไม่ทำลาย...")
if HIDE_WHILE then setVisible(char, false) end

local targets = listYuts()
local total = #targets
if total == 0 then
	if HIDE_WHILE then setVisible(char, true) end
	warn("[YutWarp] ไม่พบ Yut ที่พาธ: " .. YUT_PATH)
	return
end

local collected = 0
for _, part in ipairs(targets) do
	if not part or not part.Parent then continue end
	if player.Character ~= char then
		warn("[YutWarp] ตัวละครรีเซ็ต ยกเลิกรอบนี้")
		break
	end
	warpTo(part)
	collected = collected + 1
	print(("[YutWarp] วาร์ปหาแล้ว: %d/%d"):format(collected, total))
end

if HIDE_WHILE then setVisible(char, true) end
if collected >= total and total > 0 then
	print("[YutWarp] เก็บครบ! วาร์ปขึ้นฟ้า 🚀")
	warpUp()
else
	print("[YutWarp] จบแบบยังไม่ครบ (อาจมีของถูกลบไปก่อน)")
end

-- กันรีสปอนแล้วหาย
Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
	task.defer(function() setVisible(newChar, true) end)
end)
