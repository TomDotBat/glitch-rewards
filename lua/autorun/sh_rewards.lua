Rewards = Rewards or {}

-- Command to open menu
Rewards.Command = "!rewards"

Rewards.DiscordID = "656636037912723456"
Rewards.DiscordClientID = "657301721873121280"

-- Don't touch order 
Rewards.List = {
    {
        name = "Steam Group", 
        group = "glitchfire",
        funcOnSuccess = function(pPlayer)
            if CLIENT then return end
            pPlayer:addMoney(25000)
        end,
        funcOnClick = function(pnlContent)
            if SERVER then return end
            Rewards:Steam(pnlContent)
        end,
        msgSuccess = "Thank you for joining our Steam group! You have been rewarded $25,000.",
        msgAlready = "You've already been rewarded for this!",
        msgFailed = "You're not in our Steam group!",       
    },
    {
        name = "Discord",
        url = "https://discord.gg/pyrGrjC",
        funcOnSuccess = function(pPlayer)
            if CLIENT then return end
            --pPlayer:addMoney(25000)
        end,
        funcOnClick = function(pnlContent)
            if SERVER then return end
            Rewards:Discord(pnlContent)
        end,  
        msgSuccess = "Thank you for joining our Discord! You have been rewarded $25,000.",
        msgAlready = "You've already been rewarded for this!",
        msgFailed = "You're not in our Discord!"
    },
    {
        name = "Nitro Boost",
        funcOnSuccess = function(pPlayer)
            if CLIENT then return end
            pPlayer:addMoney(100000)
        end,
        funcOnClick = function(pnlContent)
            if SERVER then return end
            Rewards:DiscordBoost(pnlContent)
        end,
        msgSuccess = "Thank you for boosting our Discord! You have been rewarded $100,000.",     
        msgAlready = "You've already been rewarded for this!",
        msgFailed = "You haven't boosted our Discord!",         
    },
    {
        name = "Referral",
        funcOnSuccess = function(pPlayer)
            if CLIENT then return end
        end,
        funcOnClick = function(pnlContent)
            if SERVER then return end
            Rewards:Referral(pnlContent)
        end,    
        msgSuccess = "Success!",     
        msgAlready = "You've already been rewarded for this!"
    },
}