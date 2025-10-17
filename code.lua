local CascadeUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SquidGurr/CascadeUI/main/CascadeUI.lua'))()

-- หน้าต่างหลัก
local Window = CascadeUI:CreateWindow({
    Title = "CascadeUI",
    Size = UDim2.new(0, 550, 0, 400),
    Position = UDim2.new(0.5, -275, 0.5, -200)
})

-- แท็บหลัก
local MainTab = Window:CreateTab("Main")
local GeneralSection = MainTab:CreateSection("Test Stuff")

-- ====== Toggle ควบคุม Auto Gacha ======
local Toggle = GeneralSection:CreateToggle({
    Name = "Auto Gacha",
    Default = false,
    Callback = function(Value)
        if Value then
            -- เปิด Auto Gacha
            local args = {"x10"}
            workspace:WaitForChild("Containers")
                :WaitForChild("CoinGachaContainer")
                :WaitForChild("SpaceGacha")
                :WaitForChild("Trigger")
                :FireServer(unpack(args))
        else
            -- ปิด Auto Gacha (ยังไม่ทำอะไรในที่นี้)
            print("Auto Gacha ปิดแล้ว")
        end
    end
})
