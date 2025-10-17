--[[ 
  NOTE: ใช้เป็นตัวอย่าง UI เท่านั้น
  ระวังการโหลดสคริปต์จากภายนอกเสมอ
]]

--// Services
local UserInputService = game:GetService("UserInputService")

--// Library (ป้องกัน error ตอนโหลด)
local ok, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()
end)
if not ok or not Library then
    warn("Failed to load UI library")
    return
end

--// Window
local Window = Library:CreateWindow({
    Title = "???",
    Theme = "Dark",
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.2,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt, -- ดีฟอลต์
})

--// Themes
local Themes = {
    Light = {
        Primary = Color3.fromRGB(232, 232, 232),
        Secondary = Color3.fromRGB(255, 255, 255),
        Component = Color3.fromRGB(245, 245, 245),
        Interactables = Color3.fromRGB(235, 235, 235),
        Tab = Color3.fromRGB(50, 50, 50),
        Title = Color3.fromRGB(0, 0, 0),
        Description = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(255, 255, 255),
        Outline = Color3.fromRGB(210, 210, 210),
        Icon = Color3.fromRGB(100, 100, 100),
    },
    Dark = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(35, 35, 35),
        Component = Color3.fromRGB(40, 40, 40),
        Interactables = Color3.fromRGB(45, 45, 45),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240, 240, 240),
        Description = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
    Void = {
        Primary = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 20, 20),
        Component = Color3.fromRGB(25, 25, 25),
        Interactables = Color3.fromRGB(30, 30, 30),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240, 240, 240),
        Description = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
}

Window:SetTheme(Themes.Dark)

--// Sections
Window:AddTabSection({ Name = "Main",     Order = 1 })
Window:AddTabSection({ Name = "Settings", Order = 2 })

--// Tab [MAIN]
local Main = Window:AddTab({
    Title = "Components",
    Section = "Main",
    Icon = "rbxassetid://11963373994",
})

Window:AddSection({ Name = "Non Interactable", Tab = Main })

Window:AddParagraph({
    Title = "Paragraph",
    Description = "Insert any important text here.",
    Tab = Main,
})

Window:AddSection({ Name = "Interactable", Tab = Main })

Window:AddButton({
    Title = "Button",
    Description = "I wonder what this does",
    Tab = Main,
    Callback = function()
        Window:Notify({
            Title = "hi",
            Description = "i'm a notification",
            Duration = 5,
        })
    end,
})

Window:AddSlider({
    Title = "Slider",
    Description = "Sliding",
    Tab = Main,
    MaxValue = 100,
    Callback = function(amount) -- ชื่อแปรสื่อความ
        warn("Slider:", amount)
    end,
})

Window:AddToggle({
    Title = "Toggle",
    Description = "Switching",
    Tab = Main,
    Callback = function(state)
        warn("Toggle:", state)
    end,
})

Window:AddInput({
    Title = "Input",
    Description = "Typing",
    Tab = Main,
    Callback = function(text)
        warn("Input:", text)
    end,
})

Window:AddDropdown({
    Title = "Dropdown",
    Description = "Selecting",
    Tab = Main,
    Options = {
        ["An Option"]   = "hi",
        ["And another"] = "hi",
        ["Another"]     = "hi",
    },
    Callback = function(value) -- เดิมใช้ Number ซึ่งกำกวม
        warn("Dropdown:", value)
    end,
})

Window:AddKeybind({
    Title = "Keybind",
    Description = "Binding",
    Tab = Main,
    Callback = function(keycode) -- ควรเป็น Enum.KeyCode
        warn("Key Set:", keycode)
    end,
})

--// Tab [SETTINGS]
local Settings = Window:AddTab({
    Title = "Settings",
    Section = "Settings",
    Icon = "rbxassetid://11293977610",
})

-- เก็บ minimizeKey เอง (อย่าปล่อยให้เป็น nil)
local minimizeKey: Enum.KeyCode = Enum.KeyCode.LeftAlt

Window:AddKeybind({
    Title = "Minimize Keybind",
    Description = "Set the keybind for Minimizing",
    Tab = Settings,
    Callback = function(keycode: Enum.KeyCode)
        minimizeKey = keycode
        -- ถ้า lib รองรับ ก็ตั้งค่าไว้ด้วย
        Window:SetSetting("Keybind", keycode)
        Window:Notify({ Title = "Keybind Updated", Description = tostring(keycode), Duration = 3 })
    end,
})

Window:AddDropdown({
    Title = "Set Theme",
    Description = "Set the theme of the library!",
    Tab = Settings,
    Options = {
        ["Light Mode"] = "Light",
        ["Dark Mode"]  = "Dark",
        ["Extra Dark"] = "Void",
    },
    Callback = function(themeKey)
        local theme = Themes[themeKey]
        if theme then
            Window:SetTheme(theme)
        else
            warn("Unknown theme:", themeKey)
        end
    end,
})

Window:AddToggle({
    Title = "UI Blur",
    Description = "If enabled, set Roblox graphics 8+",
    Default = true,
    Tab = Settings,
    Callback = function(enabled)
        Window:SetSetting("Blur", enabled)
    end,
})

Window:AddSlider({
    Title = "UI Transparency",
    Description = "Set the transparency of the UI",
    Tab = Settings,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(alpha: number)
        -- ป้องกันค่าเพี้ยน
        alpha = math.clamp(alpha, 0, 1)
        Window:SetSetting("Transparency", alpha)
    end,
})

Window:Notify({
    Title = "Hello World!",
    Description = "Press Left Alt (or your chosen key) to Minimize!",
    Duration = 10,
})

--// Keybind Handling ที่ถูกต้อง
-- เดิม: เปรียบเทียบ InputObject กับ nil/Keybind (ผิดชนิด)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == minimizeKey then
            -- ถ้าไลบรารีมีเมธอด Minimize/Toggle ใช้ตรงนี้
            -- ตัวอย่าง: Window:ToggleMinimize()
            warn("Minimize hotkey pressed:", minimizeKey)
        end
    end
end)
