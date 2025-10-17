--// Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()

local Window = Library:CreateWindow({
    Title = "Universal Script UI",
    Theme = "Dark",
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.2,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

--// Themes
local Themes = {
    Dark = {
        Frames = {
            Primary = Color3.fromRGB(30, 30, 30),
            Secondary = Color3.fromRGB(35, 35, 35),
            Component = Color3.fromRGB(40, 40, 40),
            Interactables = Color3.fromRGB(45, 45, 45),
        },
        Text = {
            Tab = Color3.fromRGB(200, 200, 200),
            Title = Color3.fromRGB(240, 240, 240),
            Description = Color3.fromRGB(200, 200, 200),
        },
        Outlines = {
            Shadow = Color3.fromRGB(0, 0, 0),
            Outline = Color3.fromRGB(40, 40, 40),
        },
        Image = {
            Icon = Color3.fromRGB(220, 220, 220),
        },
    },
}

Window:SetTheme(Themes.Dark)

--// Tabs
Window:AddTabSection({ Name = "Main", Order = 1 })
Window:AddTabSection({ Name = "Settings", Order = 2 })

local Main = Window:AddTab({ Title = "Gacha", Section = "Main", Icon = "rbxassetid://11963373994" })
local Settings = Window:AddTab({ Title = "Settings", Section = "Settings", Icon = "rbxassetid://11293977610" })

--// Variables
local autoGacha = false
local loopConnection

--// Gacha Function
local function doGacha()
    local args = { "x10" }
    workspace:WaitForChild("Containers"):WaitForChild("CoinGachaContainer"):WaitForChild("SpaceGacha"):WaitForChild("Trigger"):FireServer(unpack(args))
end

--// UI Components
Window:AddButton({
    Title = "Start Auto Gacha",
    Description = "เริ่มเปิดกาชาอัตโนมัติ",
    Tab = Main,
    Callback = function()
        if autoGacha then
            Window:Notify({ Title = "Already Running", Description = "Auto Gacha is already active!", Duration = 3 })
            return
        end
        autoGacha = true
        Window:Notify({ Title = "Auto Gacha", Description = "Started opening gachas!", Duration = 3 })
        loopConnection = RunService.Heartbeat:Connect(function()
            if autoGacha then
                doGacha()
                task.wait(0.1)
            end
        end)
    end
})

Window:AddButton({
    Title = "Stop Auto Gacha",
    Description = "หยุดเปิดกาชาอัตโนมัติ",
    Tab = Main,
    Callback = function()
        autoGacha = false
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        Window:Notify({ Title = "Auto Gacha", Description = "Stopped.", Duration = 3 })
    end
})

Window:AddParagraph({
    Title = "Tip",
    Description = "กดปุ่ม Start เพื่อเริ่ม และ Stop เพื่อหยุดกาชาอัตโนมัติ",
    Tab = Main
})

-- Setting Controls
Window:AddSlider({
    Title = "UI Transparency",
    Description = "ปรับความโปร่งใสของ UI",
    Tab = Settings,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(Amount)
        Window:SetSetting("Transparency", Amount)
    end
})

Window:Notify({
    Title = "Universal Script UI Loaded",
    Description = "กด Left Alt เพื่อย่อ/ขยายหน้าต่าง",
    Duration = 8
})
