local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/fomm1802/Script/refs/heads/main/Show%20Fps.lua"))() --Show FPS

local win = lib:Window("PREVIEW", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

local tab = win:Tab("Tab")

local tab2 = win:Tab("Tools")

local tab10 = win:Tab("ST")

local teleportLoop = false  -- ตัวแปรเพื่อตรวจสอบสถานะการทำงานของลูป teleport

tab:Toggle("Teleport Loop 1", false, function(t)
    teleportLoop = t  -- เปลี่ยนสถานะการทำงานตามค่า toggle

    if teleportLoop then
        -- เริ่มลูป teleport
        spawn(function()  -- ใช้ spawn เพื่อรันโค้ดนี้ใน thread แยก
            while teleportLoop do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(621.4434204101562, 130.55836486816406, 342.1183776855469)
                end
                wait(1)  -- ตั้งค่าการหน่วงเวลาในการ teleport สามารถเปลี่ยนได้ตามต้องการ
            end
        end)
    end
end)

tab:Toggle("Teleport Loop Afk ", false, function(t)
    teleportLoop = t  -- เปลี่ยนสถานะการทำงานตามค่า toggle

    if teleportLoop then
        -- เริ่มลูป teleport
        spawn(function()  -- ใช้ spawn เพื่อรันโค้ดนี้ใน thread แยก
            while teleportLoop do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-1500.524169921875, -234.71974182128906, -2859.197265625)
                end
                wait(1)  -- ตั้งค่าการหน่วงเวลาในการ teleport สามารถเปลี่ยนได้ตามต้องการ
            end
        end)
    end
end)

-- เพิ่มปุ่ม Button สำหรับเปิด Position Finder GUI
tab2:Button("Button Position Finder", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fomm1802/Script/refs/heads/main/Position%20Finder%20GUI.Lua"))()
end)

tab2:Button("Turtle Spy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua", true))()
end)

tab2:Button("Simple Spy", function()
    loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()
end)
-- tab:Slider("Slider", 0, 100, 30, function(t)
--     print(t)
-- end)

-- tab:Dropdown("Dropdown", {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"}, function(t)
--     print(t)
-- end)

-- tab:Colorpicker("Colorpicker", Color3.fromRGB(255, 0, 0), function(t)
--     print(t)
-- end)

-- tab:Textbox("Textbox", true, function(t)
--     print(t)
-- end)

tab10:Bind("Bind", Enum.KeyCode.RightShift, function()
    print("Pressed!")
end)

tab10:Label("Label")

local changeclr = win:Tab("Change UI Color")

changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255))
end)
