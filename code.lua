local CascadeUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SquidGurr/CascadeUI/main/CascadeUI.lua'))()

local Window = CascadeUI:CreateWindow({
    Title = "CascadeUI",
    Size = UDim2.new(0, 550, 0, 400),
    Position = UDim2.new(0.5, -275, 0.5, -200)
})

local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

local GeneralSection = MainTab:CreateSection("Test Stuff")
local SettingsSection = SettingsTab:CreateSection("Test Stuff")

-- ประกาศตัวแปรสถานะ
local autoGacha = false

-- Toggle จาก UI ของคุณ
local Toggle = GeneralSection:CreateToggle({
    Name = "Auto Gacha",
    Default = false,
    Callback = function(Value)
        autoGacha = Value
        print("Auto Gacha:", Value)
    end
})

-- รันลูปแบบแยก thread เพื่อไม่ให้ค้าง UI
task.spawn(function()
    while true do
        if autoGacha then
            local args = { "x10" }
            workspace:WaitForChild("Containers")
                :WaitForChild("CoinGachaContainer")
                :WaitForChild("SpaceGacha")
                :WaitForChild("Trigger")
                :FireServer(unpack(args))
        end
        task.wait(0.1)
    end
end)

Toggle:Set(true)

local value = Toggle:Get()

local Button = GeneralSection:CreateButton({
    Name = "Button",
    Callback = function()
        print("Button clicked!")
    end
})

Button:Fire()

local Slider = GeneralSection:CreateSlider({
    Name = "Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(Value)
        print("Slider value:", Value)
    end
})

Slider:Set(75)

local value = Slider:Get()

local Dropdown = GeneralSection:CreateDropdown({
    Name = "Dropdown",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(Option)
        print("Selected option:", Option)
    end
})

Dropdown:Set("Option 2")

local option = Dropdown:Get()

Dropdown:Refresh({"New Option 1", "New Option 2"}, false)

local ColorPicker = SettingsSection:CreateColorPicker({
    Name = "Color Picker",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print("Selected color:", Color)
    end
})

ColorPicker:Set(Color3.fromRGB(0, 255, 0))

local color = ColorPicker:Get()
