local CascadeUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SquidGurr/CascadeUI/main/CascadeUI.lua'))()

-- ====== Cache references (เร็วและนิ่งกว่าไล่ WaitForChild ซ้ำ ๆ) ======
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Containers = workspace:WaitForChild("Containers")

-- Gacha remote (ใน workspace)
local GachaTrigger = Containers
    :WaitForChild("CoinGachaContainer")
    :WaitForChild("SpaceGacha")
    :WaitForChild("Trigger")

-- Inventory remote (ใน ReplicatedStorage)
local UseItemRemote = ReplicatedStorage
    :WaitForChild("Shared")
    :WaitForChild("Remotes")
    :WaitForChild("InventoryRemotes")
    :WaitForChild("UseItem")

-- ====== UI Window ======
local Window = CascadeUI:CreateWindow({
    Title = "CascadeUI",
    Size = UDim2.new(0, 550, 0, 400),
    Position = UDim2.new(0.5, -275, 0.5, -200)
})

local MainTab = Window:CreateTab("Main")
local GeneralSection = MainTab:CreateSection("Test Stuff")

-- ====== สถานะและตัวกัน loop ซ้อน ======
local state = { autoGacha = false, useYut = false }
local running = { autoGacha = false, useYut = false }

-- ====== Toggle: Auto Gacha ======
local Toggle = GeneralSection:CreateToggle({
    Name = "Auto Gacha",
    Default = false,
    Callback = function(Value)
        state.autoGacha = Value
        if Value then
            if running.autoGacha then return end -- กันสแปมกดเปิดซ้ำ
            running.autoGacha = true
            task.spawn(function()
                while state.autoGacha do
                    -- ยิง x10 ครั้งละรอบ
                    local ok, err = pcall(function()
                        -- ถ้ารีโมตต้องรับ args เป็นตัวเดียว ใช้แบบนี้จะชัวร์
                        GachaTrigger:FireServer("x10")
                    end)
                    if not ok then
                        warn("[Auto Gacha] FireServer error:", err)
                    end
                    task.wait(0.1) -- ปรับคูลดาวน์ตามใจ (วิ)
                end
                running.autoGacha = false
            end)
        else
            -- แค่ปล่อย loop ดับเอง
            print("Auto Gacha ปิดแล้ว")
        end
    end
})

-- ====== Toggle: Use Yut ======
local Toggle1 = GeneralSection:CreateToggle({
    Name = "Use Yut",
    Default = false,
    Callback = function(Value)
        state.useYut = Value
        if Value then
            if running.useYut then return end
            running.useYut = true
            task.spawn(function()
                while state.useYut do
                    local ok, err = pcall(function()
                        -- ใช้ไอเทม "Yut" 1 ครั้งต่อรอบ
                        UseItemRemote:FireServer("Yut")
                    end)
                    if not ok then
                        warn("[Use Yut] FireServer error:", err)
                    end
                    task.wait(0.1) -- คูลดาวน์การใช้ไอเทม
                end
                running.useYut = false
            end)
        else
            print("Use Yut ปิดแล้ว")
        end
    end
})
