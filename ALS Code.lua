local codes = {
    "TitansAreReal", "EnchantsSoon", "ShadowMonarch!", "Dungeons!", "AnotherSecretCode!", "NewUi!", 
    "BattlepassReset!", "SecretCode", "GreatWarWow!", "NewCaverns!", "NewGlobalBoss!", "HapplyNewYear!", 
    "ALS2025!", "HappyHolidays!", "AncientVampireIsBack!!", "MerryChrisTMas!", "ExtraChristmasBaby!", 
    "SORRYforIssues!!", "NewGodly!", "ChristmasRaid!", "EventBP!", "BLEACHWAVE!", "Sub2OtakuGaming", 
    "NewUpdateKrazy!", "Sorry4LateUPD!", "BossRush!", "SkinBanner!", "BossIGCool!", "LateUpdSorry!", 
    "NewLobby!", "LSwat!", "SryForDelay!", "FateIsHere!", "NoLagWow!", "WorldHop!", "SORRYLuvU!", 
    "BossStudio4Life!", "Evos!", "Tournaments!", "Drops!", "TY1MGroup", "NewEra!", "MasteredUltraInstinct!", 
    "DBUPDPt2!", "ThegrSirBrandonInsta", "LevelRewards!", "NewSecret!", "LagFixes!!", "ammyisbacky", 
    "ThrillerBark", "100RRLIMITEDTIMECODE", "Raffle", "Nomoredelay!", "ThrillerNext!", "BugsFixed!", 
    "BossStudio4Life", "500MVISITS!", "Spooky!", "Dracula!?", "CLANWARS", "TheFixesAreHere!", "Lagfixes!!", 
    "SorryForBugs!", "theGramALS", "Bleach2", "MakeYourClan!", "PodcastyCodeBois!", "NewGODLY!!", 
    "2xPOINTS", "SorryForBugs!!", "300KLIKES!!", "JointheGram!", "10KAGAIN??", "ZankaNoTachi", "TheOne", 
    "ShinigamiVsQuincy", "QOLpart2Next!", "TYBW..?", "NewBUNDLES?!", "BOBAKISBACK!", "Goodluck!!", 
    "Welcome!!", "FollowDalG", "10KFR!", "OverHeaven!", "JOJOUpdate!", "HeavenUpdateHYPE??", "SLIME!!", 
    "SecretCodeFR", "Event!!!", "TensuraSlime!", "UPDTIME", "BPReset!"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local redeemFunction = ReplicatedStorage:FindFirstChild("RedeemCode") -- เปลี่ยนชื่อตามฟังก์ชันจริงในเกมของคุณ

if redeemFunction and redeemFunction:IsA("RemoteFunction") then
    for _, code in ipairs(codes) do
        task.spawn(function()
            local success, result = pcall(function()
                return redeemFunction:InvokeServer(code)
            end)

            if success then
                print("Redeemed:", code, "Result:", result)
            else
                warn("Failed to redeem:", code, "Error:", result)
            end
        end)
    end
else
    warn("Could not find 'RedeemCode' RemoteFunction in ReplicatedStorage")
end
