local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- จุดทั้งหมดของ Yut
local yuts = workspace.Platform.Plat:GetChildren()
local totalYut = #yuts
local collected = 0

-- ฟังก์ชันซ่อนตัว
local function hideCharacter()
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

-- ฟังก์ชัน Tween ไปเก็บ Yut
local function moveToYut(yut)
	local targetPos = yut.Position + Vector3.new(0, -2, 0)
	local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})

	tween:Play()
	tween.Completed:Wait()

	-- “ชน” แล้วเก็บ
	yut:Destroy()
	collected += 1
	print("เก็บแล้ว: " .. collected .. "/" .. totalYut)
end

-- ฟังก์ชันวาปขึ้นฟ้า
local function teleportUp()
	print("✅ เก็บครบ! วาปขึ้นฟ้า~ 🚀")

	-- จุดที่อยากให้วาปไป (ขึ้นฟ้า 100 หน่วย)
	local upPos = hrp.Position + Vector3.new(0, 100, 0)

	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(upPos)})

	tween:Play()
end

-- เริ่มเก็บของทั้งหมด
hideCharacter()
for _, yut in ipairs(yuts) do
	if yut:IsA("BasePart") then
		moveToYut(yut)
	end
end

-- ถ้าเก็บครบ → วาปขึ้นฟ้า
if collected == totalYut then
	teleportUp()
end
