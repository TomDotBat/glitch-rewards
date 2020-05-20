local endpoint = "http://127.0.0.1:3000/"
--Add CS lua
AddCSLuaFile("autorun/sh_rewards.lua")
AddCSLuaFile("autorun/client/cl_rewards.lua")

-- Initialize networks
util.AddNetworkString("Rewards:Player:Check:SteamGroup")
util.AddNetworkString("Rewards:Player:Check:Discord")
util.AddNetworkString("Rewards:Player:Check:DiscordBoost")
util.AddNetworkString("Rewards:Player:Check:Referral")

function Rewards:CheckSteamGroup(pPlayer,strGroup,func)
	if pPlayer:IsValid() then
        http.Fetch(string.format("http://steamcommunity.com/groups/%s/memberslistxml/?xml=1&c=%i",strGroup,CurTime()), function(body,len,headers,code)
            if code == 200 then
                local results = body

                if !results then return end
                
                if string.find(results,pPlayer:SteamID64(),0) then
                    if func then 
                        func(pPlayer,true) 
                    end
                else
                    func(pPlayer,false) 
                end
            else
                print("[Rewards] : " .. string.format("Error steam group : %i", code))
            end
        end, function(err) 
            print("[Rewards] : Error steam group : " .. err)
        end)
	end
end

function Rewards:ReferralUser(pPlayer)
    local tbl = Rewards.List[4]

    local tblList = Rewards:Query("SELECT * FROM referral WHERE steamid = {{steamid}} AND received = 0", { steamid = pPlayer:SteamID64() })

    for k,v in pairs(tblList or {}) do
        if tbl.funcOnSuccess then
            tbl.funcOnSuccess(pPlayer)
        end    

        Rewards:Query("UPDATE referral SET received = 1 WHERE id = {{id}}", { id = v.id })
    end
end

-- Player check steam group
net.Receive("Rewards:Player:Check:SteamGroup",function(_,pPlayer)
    local tbl = Rewards.List[1]

    pPlayer.Reward_LastCheck = pPlayer.Reward_LastCheck or 0

    if pPlayer.Reward_LastCheck > CurTime() then
        return DarkRP.notify(pPlayer,1,5,"Wait!")
    end 

    pPlayer.Reward_LastCheck = CurTime() + 3

    local tblRewards = Rewards:Query("SELECT * FROM rewards WHERE steamid = {{steamid}} AND type_id = 1",{steamid = pPlayer:SteamID64()})

    if table.Count(tblRewards) > 0 then 
        return DarkRP.notify(pPlayer,1,5,tbl.msgAlready)
    end

    Rewards:CheckSteamGroup(pPlayer,tbl.group,function(pPlayer,bool)
        if bool then
            if tbl.funcOnSuccess then
                tbl.funcOnSuccess(pPlayer)
            end

            Rewards:Query("INSERT INTO rewards(steamid,type_id) VALUES({{steamid}},1)",{steamid = pPlayer:SteamID64()})

            DarkRP.notify(pPlayer,0,5,tbl.msgSuccess)
        else
            DarkRP.notify(pPlayer,1,5,tbl.msgFailed)
        end
    end)
end)

-- Player check discord
net.Receive("Rewards:Player:Check:Discord",function(_,pPlayer)
    local tbl = Rewards.List[2]

    pPlayer.Reward_LastCheck = pPlayer.Reward_LastCheck or 0

    if pPlayer.Reward_LastCheck > CurTime() then
        return DarkRP.notify(pPlayer,1,5,"Wait!")
    end 

    pPlayer.Reward_LastCheck = CurTime() + 3

    local tblRewards = Rewards:Query("SELECT * FROM rewards WHERE steamid = {{steamid}} AND type_id = 2",{steamid = pPlayer:SteamID64()})

    if table.Count(tblRewards) > 0 then 
        return DarkRP.notify(pPlayer,1,5,tbl.msgAlready)
    end

    http.Fetch( endpoint .. "playerIsVerified",
        function( body, len, headers, code )
            if body == "Yes" then 
                if tbl.funcOnSuccess then
                    tbl.funcOnSuccess(pPlayer)
                    for k,v in pairs(player.GetAll()) do 
                        DarkRP.notify(v,0,5,v:Name() .. " Has just boosted the server and has recieved $50k!");
                    end
                    Rewards:Query("INSERT INTO rewards(steamid,type_id) VALUES({{steamid}},2)",{steamid = pPlayer:SteamID64()})
                end
            else
                DarkRP.notify(pPlayer,1,5,tbl.msgFailed)
            end
        end,
        function( error )
            DarkRP.notify(pPlayer,1,5,"The API Endpoint is down, contact the server owner.")
        end,
        { ["steam"] = pPlayer:SteamID(), ["token"]= access }
    )

end)

-- Player check discord boost
net.Receive("Rewards:Player:Check:DiscordBoost",function(_,pPlayer)
    local tbl = Rewards.List[3]

    pPlayer.Reward_LastCheck = pPlayer.Reward_LastCheck or 0

    if pPlayer.Reward_LastCheck > CurTime() then
        return DarkRP.notify(pPlayer,1,5,"Wait!")
    end 

    pPlayer.Reward_LastCheck = CurTime() + 3

    local tblRewards = Rewards:Query("SELECT * FROM rewards WHERE steamid = {{steamid}} AND type_id = 3",{steamid = pPlayer:SteamID64()})

    if table.Count(tblRewards) > 0 then 
        return DarkRP.notify(pPlayer,1,5,tbl.msgAlready)
    end

    http.Fetch( endpoint .. "isNitroBooster",
        function( body, len, headers, code )
            if body == "Yes" then 
                if tbl.funcOnSuccess then
                    tbl.funcOnSuccess(pPlayer)
                end

                Rewards:Query("INSERT INTO rewards(steamid,type_id) VALUES({{steamid}},3)",{steamid = pPlayer:SteamID64()})
                for k,v in pairs(player.GetAll()) do 
                    DarkRP.notify(v,0,5,v:Name() .. " Has just boosted the server and has recieved $1mil!");
                end
            else
                DarkRP.notify(pPlayer,1,5,tbl.msgFailed)
            end
        end,
        function( error )
            DarkRP.notify(pPlayer,1,5,"The API Endpoint is down, contact the server owner.")
        end,
        { ["steam"] = pPlayer:SteamID(), ["token"] = access }
    )

end)

-- Player check referral
net.Receive("Rewards:Player:Check:Referral",function(_,pPlayer)
    local strSteamid = net.ReadString()
    local tbl = Rewards.List[4]

    if string.len(strSteamid) < 5 then return end

    local tblCheck = Rewards:Query("SELECT * FROM referral WHERE steamid = {{steamid}}", { steamid = pPlayer:SteamID64() })

    if table.Count(tblCheck) < 1 then
        Rewards:Query("INSERT INTO referral(steamid,code,received) VALUES({{steamid}},{{code}},0)",
        {
            steamid = pPlayer:SteamID64(),
            code = strSteamid
        })

        for k,v in pairs(player.GetAll()) do
            if !IsValid(v) then continue end
            if v:SteamID64() != strSteamid then continue end
        
            Rewards:ReferralUser(v)
        end

        DarkRP.notify(pPlayer,0,5,tbl.msgSuccess)        
    else
        DarkRP.notify(pPlayer,1,5,tbl.msgAlready)        
    end
end)