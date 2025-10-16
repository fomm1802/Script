--============================================================
--  Yut Collector + Orion UI (Executor-Friendly, Fast & Stable)
--============================================================

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

--============================================================
--  Universal fetch (รองรับหลาย executor + offline file)
--============================================================
local function universal_get(url)
    -- 1) executor requests
    local req = nil
    if syn and syn.request then req = syn.request end
    if not req and http_request then req = http_request end
    if not req and request then req = request end
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then
            return res.Body
        end
    end
    -- 2) client HttpGet
    local okGet, body = pcall(function() return game:HttpGet(url) end)
    if okGet and body and #body > 0 then
        return body
    end
    -- 3) local file (ใส่ไฟล์เองถ้าจะใช้ออฟไลน์)
    local okRead, fbody = pcall(function()
        if readfile then return readfile("Orion.source.lua") end
    end)
    if okRead and fbody and #fbody > 0 then
        return fbody
    end
    return nil
end

--============================================================
--  Orion loader (+ Fallback Shim ครบเมธอด)
--============================================================
local ORION_URL = "https://raw.githubusercontent.com/shlexware/Orion/main/source"
local orion_src = universal_get(ORION_URL)

local OrionLib
if orion_src and #orion_src > 0 then
    local ok, lib = pcall(function() return loadstring(orion_src)() end)
    if ok and lib then OrionLib = lib end
end

-- Fallback UI (Shim) เมธอดครบ: AddSlider/Toggle/Textbox/Label/Button
if not OrionLib then
    warn("⚠️ Orion โหลดไม่สำเร็จ → ใช้ Fallback UI (ยังทำงานได้ แต่ไม่มีหน้าตา)")
    local DummyLabel = { Set=function()end }
    local DummyTab = {
        AddSection=function() return {} end,
        AddButton=function(_, o) if o and o.Callback then pcall(o.Callback) end end,
        AddToggle=function(_, o) if o and o.Default and o.Callback then pcall(o.Callback, o.Default) end end,
        AddSlider=function(_, o) if o and o.Default and o.Callback then pcall(o.Callback, o.Default) end end,
        AddTextbox=function(_, o) if o and o.Default and o.Callback then pcall(o.Callback, o.Default) end end,
        AddLabel=function() return DummyLabel end,
    }
    local DummyWindow = { MakeTab=function() return DummyTab end }
    OrionLib = {
        MakeWindow=function() return DummyWindow end,
        MakeNotification=function(t) print("[Notify]", t and t.Content or "") end,
        Init=function() end,
        Destroy=function() end,
    }
end

--============================================================
--  Boot UI
--============================================================
OrionLib:MakeNotification({
    Name = "Orion Ready",
    Content = "UI Loaded. ไปเก็บ Yut กัน 🚀",
    Image = "rbxassetid://4483345998",
    Time = 3
})

local Window = OrionLib:MakeWindow({
    Name = "Yut Collector",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Orion"
})

--============================================================
--  Player Tab
--============================================================
local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false })
PlayerTab:AddSection({ Name = "Player" })

PlayerTab:AddSlider({
    Name = "Walkspeed",
    Min = 16, Max = 100, Default = 16,
    Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "speed",
    Callback = function(Value)
        local plr = Players.LocalPlayer
        if plr and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Value end
        end
    end
})

--============================================================
--  Yut Collector Tab
--============================================================
local YutTab = Window:MakeTab({ Name = "Yut Collector", Icon = "rbxassetid://4483345998", PremiumOnly = false })
YutTab:AddSection({ Name = "Collector" })

-- พารามิเตอร์
local TWEEN_TIME = 1.2
local WARP_UP = 100
local HIDE_WHEN_COLLECT = true
local AUTO_MODE = false
local YUT_PATH = "workspace.Platform.Plat"

YutTab:AddSlider({
    Name = "Tween Time (sec)",
    Min = 0.2, Max = 5, Default = TWEEN_TIME, Increment = 0.1, ValueName = "sec",
    Callback = function(v) TWEEN_TIME = v end
})
YutTab:AddSlider({
    Name = "Warp Up Distance",
    Min = 10, Max = 500, Default = WARP_UP, Increment = 5, ValueName = "studs",
    Callback = function(v) WARP_UP = v end
})
YutTab:AddToggle({
    Name = "ซ่อนตัวตอนเก็บ (Invisible)",
    Default = HIDE_WHEN_COLLECT,
    Callback = function(state) HIDE_WHEN_COLLECT = state end
})

local StatusLabel = YutTab:AddLabel("Status: Idle")
local ProgressLabel = YutTab:AddLabel("Progress: 0/0")

YutTab:AddTextbox({
    Name = "Yut Path (e.g. workspace.Platform.Plat)",
    Default = YUT_PATH,
    TextDisappear = false,
    Callback = function(txt)
        if txt and #tostring(txt) > 0 then
            YUT_PATH = tostring(txt)
            OrionLib:MakeNotification({ Name="Path Updated", Content="Path -> "..YUT_PATH, Image="rbxassetid://4483345998", Time=2 })
        end
    end
})

--============================================================
--  Helpers
--============================================================
local function getChar()
    local plr = Players.LocalPlayer
    return plr.Character or plr.CharacterAdded:Wait()
end

local function getHRP(character)
    return character:WaitForChild("HumanoidRootPart")
end

local function setVisible(character, visible)
    local vis = visible and 0 or 1
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = vis
            for _, d in ipairs(part:GetChildren()) do
                if d:IsA("Decal") then d.Transparency = vis end
            end
        elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
            part.Handle.Transparency = vis
        end
    end
end

local function safeGet(pathStr)
    local ref = workspace
    local steps = string.split(pathStr, ".")
    if steps[1] == "workspace" then table.remove(steps, 1) end
    for i = 1, #steps do
        if not ref then return nil end
        ref = ref:FindFirstChild(steps[i])
    end
    return ref
end

local function listYuts()
    local container = safeGet(YUT_PATH)
    if not container then return {} end
    local arr, kids = {}, container:GetChildren()
    for i = 1, #kids do
        local obj = kids[i]
        if obj:IsA("BasePart") then
            arr[#arr+1] = obj
        elseif obj:IsA("Model") and obj.PrimaryPart then
            arr[#arr+1] = obj.PrimaryPart
        end
    end
    return arr
end

local function moveToPart(hrp, part)
    local targetPos = part.Position + Vector3.new(0, -2, 0)
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(targetPos)}
    )
    tween:Play()
    tween.Completed:Wait()
end

local function teleportUp(hrp)
    local upPos = hrp.Position + Vector3.new(0, WARP_UP, 0)
    local dur = WARP_UP / 100
    if dur < 0.5 then dur = 0.5 end
    if dur > 2 then dur = 2 end
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(upPos)}
    )
    tween:Play()
end

--============================================================
--  Core collect
--============================================================
local busy = false

local function collectOnce()
    if busy then return end
    busy = true
    StatusLabel:Set("Status: Collecting...")

    local char = getChar()
    local hrp = getHRP(char)

    if HIDE_WHEN_COLLECT then setVisible(char, false) end

    local yuts = listYuts()
    local total, collected = #yuts, 0
    ProgressLabel:Set(("Progress: %d/%d"):format(collected, total))

    if total == 0 then
        StatusLabel:Set("Status: ไม่พบ Yut ที่พาธที่ตั้งไว้")
        OrionLib:MakeNotification({ Name="Yut Collector", Content="ไม่เจอของให้เก็บ เช็คพาธ/แมพอีกที", Image="rbxassetid://4483345998", Time=3 })
        if HIDE_WHEN_COLLECT then setVisible(char, true) end
        busy = false
        return
    end

    for i = 1, total do
        local y = yuts[i]
        if y and y.Parent then
            if Players.LocalPlayer.Character ~= char then
                StatusLabel:Set("Status: ตัวละครรีเซ็ต ยกเลิกครั้งนี้")
                break
            end
            moveToPart(hrp, y)
            pcall(function() if y and y.Parent then y:Destroy() end end)
            collected = collected + 1
            ProgressLabel:Set(("Progress: %d/%d"):format(collected, total))
            task.wait(0.05)
        end
    end

    if HIDE_WHEN_COLLECT then setVisible(char, true) end

    if collected >= total and total > 0 then
        StatusLabel:Set("Status: Completed! วาปขึ้นฟ้า")
        OrionLib:MakeNotification({ Name="✅ Done", Content="เก็บครบ! วาปขึ้นฟ้า~ 🚀", Image="rbxassetid://4483345998", Time=3 })
        teleportUp(hrp)
    else
        StatusLabel:Set("Status: Stopped/Interrupted")
    end

    busy = false
end

YutTab:AddButton({
    Name = "Collect Yut (ครั้งเดียว)",
    Callback = function() task.spawn(collectOnce) end
})

YutTab:AddToggle({
    Name = "Auto Collect (ลูปต่อเนื่อง)",
    Default = false,
    Callback = function(state)
        AUTO_MODE = state
        if state then
            OrionLib:MakeNotification({ Name="Auto ON", Content="เริ่มเก็บวนเรื่อย ๆ", Image="rbxassetid://4483345998", Time=2 })
            task.spawn(function()
                while AUTO_MODE do
                    if not busy then collectOnce() end
                    local c=0
                    while c<30 do
                        if not AUTO_MODE then break end
                        task.wait(0.1); c=c+1
                    end
                end
                StatusLabel:Set("Status: Idle")
            end)
        else
            OrionLib:MakeNotification({ Name="Auto OFF", Content="หยุดเก็บอัตโนมัติ", Image="rbxassetid://4483345998", Time=2 })
        end
    end
})

--============================================================
--  Settings Tab
--============================================================
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false })
SettingsTab:AddSection({ Name = "Settings" })
SettingsTab:AddButton({
    Name = "Destroy UI",
    Callback = function() AUTO_MODE=false; OrionLib:Destroy() end
})

-- กันรีสปอนแล้วหาย
Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.defer(function()
        setVisible(newChar, true)
        if StatusLabel then StatusLabel:Set("Status: Respawned -> Idle") end
    end)
end)

-- ยิง UI
OrionLib:Init()
--=============================== END ===============================
