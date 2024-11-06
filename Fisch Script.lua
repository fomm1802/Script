local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()

local Main = library:CreateWindow("Main","Crimson")

local tab = Main:CreateTab("Cheats")
local tab2 = Main:CreateTab("Misc")

tab:CreateToggle("Auto Sell",function(a)

end)

tab:CreateCheckbox("Auto Sell",function(a)
    _G.AUTOSELL = a
    while _G.AUTOSELL do
        wait(2)
        workspace.world.npcs:FindFirstChild("Mel Merchant").merchant.sellall:InvokeServer()
    end
end)

tab2:CreateButton("Hello",function()
    print("clicked")
end)

tab:Show()
