local player = game.Players.LocalPlayer

-- CONFIG
local BANNER = "SummerBanner"      -- Banner ที่จะสุ่ม
local PRICE_PER_SUMMON = 500       -- ราคาต่อการสุ่ม 1 ครั้ง
local CHECK_INTERVAL = 1           -- วินาทีระหว่างเช็ค

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local summonEvent = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Summon")

-- ฟังก์ชันดึงค่า BeachBall
local function getBeachBall()
    local items = player:WaitForChild("ItemsInventory")
    local beachBall = items:WaitForChild("BeachBall")
    return beachBall:WaitForChild("Amount").Value
end

-- ฟังก์ชันดึง Inventory
local function getInventoryInfo()
    local data = player:WaitForChild("Data")
    local inventoryMax = data:WaitForChild("Inventory_MaxUnit").Value

    local mainGui = player.PlayerGui:WaitForChild("Main")
    local unitInventoryFrame = mainGui:WaitForChild("UnitInventoryFrame")
    local units = unitInventoryFrame:WaitForChild("Units")

    local totalUnits = 0
    for _, child in ipairs(units:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            totalUnits = totalUnits + child.Value
        end
    end

    return inventoryMax, totalUnits
end

-- ฟังก์ชัน Summon
local function doSummon(times)
    local args = {
        [1] = BANNER,
        [2] = tostring(times)
    }
    summonEvent:InvokeServer(unpack(args))
    print("Summon: " .. times .. " ครั้ง (Banner: " .. BANNER .. ")")
end

-- Loop เช็คตลอดเวลา
while task.wait(CHECK_INTERVAL) do
    local beachBall = getBeachBall()
    local inventoryMax, totalUnits = getInventoryInfo()
    local spaceLeft = inventoryMax - totalUnits

    local maxFromBeachBall = math.floor(beachBall / PRICE_PER_SUMMON)
    local summonable = math.min(maxFromBeachBall, spaceLeft)

    if summonable > 0 then
        doSummon(summonable)
    else
        if beachBall < PRICE_PER_SUMMON then
            print("ยังสุ่มไม่ได้: BeachBall ไม่พอ (มีแค่ " .. beachBall .. ")")
        elseif spaceLeft <= 0 then
            print("ยังสุ่มไม่ได้: Inventory เต็ม (เต็ม " .. inventoryMax .. ")")
        else
            print("ยังสุ่มไม่ได้: เงื่อนไขอื่น")
        end
    end
end
