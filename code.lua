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

-- ====== ตัวแปรสถานะ Auto Gacha ======
local autoGacha = false

-- ====== Toggle ควบคุม Auto Gacha ======
local Toggle = GeneralSection:CreateToggle({
    Name = "Auto Gacha",
    Default = false, -- เริ่มต้นปิด
    Callback = function(Value)
        autoGacha = Value
        print("Auto Gacha:", Value)
    end
})

-- ย้ำให้แน่ใจว่าเริ่มปิดแน่ ๆ
Toggle:Set(false)
autoGacha = false

-- ====== Loop ยิง Trigger (ไม่บล็อก UI) ======
task.spawn(function()
    while true do
        if autoGacha then
            pcall(function()
                local args = { "x10" }
                workspace:WaitForChild("Containers")
                    :WaitForChild("CoinGachaContainer")
                    :WaitForChild("SpaceGacha")
                    :WaitForChild("Trigger")
                    :FireServer(unpack(args))
            end)
        end
        task.wait(0.1)
    end
end)
