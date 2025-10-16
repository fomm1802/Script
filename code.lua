--!strict
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ให้แน่ใจว่าเรามี character/HRP เสมอ (รองรับรีสปอว์น)
local function getCharacterAndHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart") :: BasePart
	return char, hrp
end

local char, hrp = getCharacterAndHRP()

-- ==== Config ====
local YUTS_CONTAINER: Instance = workspace:WaitForChild("Platform"):WaitForChild("Plat")
local TWEEN_TO_YUT_TIME = 1.2
local TELEPORT_UP_TIME = 1.5
local TELEPORT_UP_HEIGHT = 100
local HIDE_TRANSPARENCY = 1
local COLLECTED_FADE = 1 -- 1 = มองไม่เห็น, 0.75 = จาง, 0 = ปกติ
-- ================

-- เก็บค่าโปร่งใสไว้ เพื่อคืนค่าได้ทีหลัง (ใช้ LocalTransparencyModifier เพื่อไม่ยุ่งฝั่งเซิร์ฟเวอร์)
local originalLTM: {BasePart, number}[] = {}
local function hideCharacter()
	originalLTM = {}
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(originalLTM, {d, d.LocalTransparencyModifier})
			d.LocalTransparencyModifier = HIDE_TRANSPARENCY
			d.CanCollide = false
		end
	end
end

local function restoreCharacter()
	for _, item in ipairs(originalLTM) do
		local part, ltm = item[1], item[2]
		if part and part.Parent then
			part.LocalTransparencyModifier = ltm
		end
	end
	originalLTM = {}
end

-- ดึงรายการ Yut ที่เป็น BasePart เท่านั้น และยังไม่โดนเก็บ (Attribute "Collected" ~= true)
local function getYuts(): {BasePart}
	local list = {}
	for _, inst in ipairs(YUTS_CONTAINER:GetChildren()) do
		if inst:IsA("BasePart") and not inst:GetAttribute("Collected") then
			table.insert(list, inst)
		end
	end
	return list
end

-- Tween ไปยังตำแหน่งของ yut (เลื่อน HRP ด้วย CFrame)
local function moveToYut(yut: BasePart)
	local targetPos = yut.Position + Vector3.new(0, -2, 0)
	local tweenInfo = TweenInfo.new(TWEEN_TO_YUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
	tween:Play()
	tween.Completed:Wait()
end

-- “เก็บ” โดยไม่ทำลาย: ทำเครื่องหมาย, ปิดชน/สัมผัส, ซ่อน และย้ายไปไว้ในโฟลเดอร์แยก (ถ้ามี)
local collectedFolder = (workspace:FindFirstChild("Collected") :: Instance) or Instance.new("Folder", workspace)
collectedFolder.Name = "Collected"

local function markCollected(yut: BasePart)
	if yut:GetAttribute("Collected") then return end -- กันซ้ำ

	yut:SetAttribute("Collected", true)
	-- ปิดการชน/สัมผัส และซ่อนไว้ (ไม่ Destroy)
	yut.CanCollide = false
	if yut:IsA("BasePart") then
		yut.CanTouch = false
	end
	yut.Transparency = COLLECTED_FADE

	-- ย้ายไปโฟลเดอร์ Collected เพื่อแยกออกจากพื้นที่เล่น (ปลอดภัยและเรียบร้อย)
	yut.Parent = collectedFolder
end

-- วาปขึ้นฟ้าเมื่อเก็บครบ
local function teleportUp()
	print("✅ เก็บครบ! วาปขึ้นฟ้า~ 🚀")
	local upPos = hrp.Position + Vector3.new(0, TELEPORT_UP_HEIGHT, 0)
	local tweenInfo = TweenInfo.new(TELEPORT_UP_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(upPos)})
	tween:Play()
end

-- รองรับรีสปอว์นระหว่างทำงาน
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- ===== Main =====
hideCharacter()

local yuts = getYuts()
local totalYut = #yuts
local collected = 0

for _, yut in ipairs(yuts) do
	if not yut or not yut.Parent then
		-- เผื่อมีการเปลี่ยนฉาก/ย้ายชิ้นไปก่อนถึงคิวนี้
		continue
	end

	-- อัปเดต HRP เผื่อผู้เล่นรีสปอว์นช่วงนี้
	if not hrp or not hrp.Parent then
		char, hrp = getCharacterAndHRP()
	end

	moveToYut(yut)
	markCollected(yut)

	collected += 1
	print(("เก็บแล้ว: %d/%d"):format(collected, totalYut))
	task.wait(0.05) -- เว้นจังหวะนิด กัน tween ชนกัน
end

restoreCharacter()

if collected == totalYut and totalYut > 0 then
	teleportUp()
else
	print(("เก็บได้ %d จาก %d"):format(collected, totalYut))
end
