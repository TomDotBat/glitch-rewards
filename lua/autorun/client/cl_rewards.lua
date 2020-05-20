-- Colors 
local COLORS = {
    background = Color(0, 0, 0, 220),
    secondary = Color(0, 0, 0, 190),
    red = Color(240, 127, 24),
    text = Color(255,255,255,255)
}

-- Fonts
surface.CreateFont( "Rewards24", { font = "Roboto", extended = false, size = 24, weight = 500, } )
surface.CreateFont( "Rewards18", { font = "Roboto", extended = false, size = 18, weight = 500, } )

local function drawRect(x,y,w,h,color)
    surface.SetDrawColor(color)
    surface.DrawRect(x,y,w,h)
end

local function calculeSize(str)
    surface.SetFont("Rewards18")
    local w,h = surface.GetTextSize(str)

    return w + 60
end

local function generateBtn(frame,x,y,w,h,str)
    h = h - 2
    y = y + 2
    
    local btn = vgui.Create("DButton", frame)
        btn:SetSize(w,h)
        btn:SetPos(x,y)
        btn:SetText('')
        function btn:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,COLORS.secondary)

            local colText = COLORS.text

            if self:IsHovered() then
                colText = COLORS.red
            end

            draw.SimpleText(str,"Rewards18", w/2, h/2, colText, 1, 1)
        end
        function btn:OnMousePressed()
            surface.PlaySound( "buttons/button15.wav" )
            self:DoClick()
        end
        
    return btn
end

-- Receive menu
function Rewards:SeeRewards(frame,int)
    local tbl = Rewards.List[int]

    frame:Clear()
    frame.Paint = function(self,w,h)
        local intOffset = 0

        for k,v in pairs(tbl.rewardsList or {}) do
            draw.SimpleText(k .. ". " .. v, "Rewards24", 10, 10 + intOffset, color_white,0)

            intOffset = intOffset + 30
        end
    end

    local btnBack = generateBtn(frame,10,frame:GetTall()-40,frame:GetWide()-20,30,"Back")
        function btnBack:DoClick()
            frame:Clear()
            frame.Paint = nil

            tbl.funcOnClick(frame)
        end    
end

function Rewards:Steam(frame)
    local tbl = Rewards.List[1]

    frame.Paint = function(self,w,h)
        draw.SimpleText("Join our Steam Group for server", "Rewards24", w/2, h/2 - 50, color_white, 1, 1)
        draw.SimpleText("related news and rewards!", "Rewards24", w/2, h/2 - 25, color_white, 1, 1)
    end

    local btnJoin = generateBtn(frame,15,frame:GetTall()-80,frame:GetWide()-30,30,"Join")
        function btnJoin:DoClick()
            gui.OpenURL("https://steamcommunity.com/groups/" .. tbl.group)
        end

    local btnCheck = generateBtn(frame,15,frame:GetTall()-45,frame:GetWide()-30,30,"Check")
        function btnCheck:DoClick()
            net.Start("Rewards:Player:Check:SteamGroup")
            net.SendToServer()
        end
end
 
function Rewards:Discord(frame)
    local tbl = Rewards.List[2]

    frame.Paint = function(self,w,h)
        draw.SimpleText("Join our Discord to chat with", "Rewards24", w/2, h/2 - 50, color_white, 1, 1)
        draw.SimpleText("other players and earn rewards!", "Rewards24", w/2, h/2 - 25, color_white, 1, 1)
    end

    --local btnRewards = generateBtn(frame,15,frame:GetTall()-115,300,30,"See Rewards")
        --function btnRewards:DoClick()
        --    Rewards:SeeRewards(frame,2)
        --end

    local btnJoin = generateBtn(frame,15,frame:GetTall()-80,frame:GetWide()-30,30,"Join")
        function btnJoin:DoClick()
            --gui.OpenURL(tbl.url)
            RunConsoleCommand("discord_join")
        end

    local btnCheck = generateBtn(frame,15,frame:GetTall()-45,frame:GetWide()-30,30,"Check")
        function btnCheck:DoClick()
            --net.Start("Rewards:Player:Check:Discord")
            --net.SendToServer()
        end
end

function Rewards:DiscordBoost(frame)
    local tbl = Rewards.List[2]

    frame.Paint = function(self,w,h)
        draw.SimpleText("Nitro boost our Discord earn a big reward!", "Rewards24", w/2, h/2 - 30, color_white, 1, 1)
    end

    local btnCheck = generateBtn(frame,15,frame:GetTall()-45,frame:GetWide()-30,30,"Check")
        function btnCheck:DoClick()
            net.Start("Rewards:Player:Check:DiscordBoost")
            net.SendToServer()
        end
end

function Rewards:Referral(frame)
    local tbl = Rewards.List[4]

    frame.Paint = function(self,w,h)
        draw.SimpleText("Enter a referral code", "Rewards24", w/2, h/2-140/2, color_white,1,1)
    end

    local pEntry = vgui.Create("DTextEntry",frame)
        pEntry:SetSize(frame:GetWide()-30,25)
        pEntry:SetPos(15,frame:GetTall()-125)
        pEntry:SetPlaceholderText('Enter steamid64...')

    local btnCopy = generateBtn(frame,15,frame:GetTall()-85,frame:GetWide()-30,30,"Copy my referral code")
        function btnCopy:DoClick()
            SetClipboardText(LocalPlayer():SteamID64())
        end

    local btnCheck = generateBtn(frame,15,frame:GetTall()-45,frame:GetWide()-30,30,"Validate")
        function btnCheck:DoClick()
            net.Start("Rewards:Player:Check:Referral")
            net.WriteString(pEntry:GetValue() or "")
            net.SendToServer()
        end
end

local function openMenu()
    local intSizeBtn = 130
    local intFullSizePanel = 0
    local tblSize = {}
    local intCurrentPanel = 1

    for i = 1, #Rewards.List do
        local tbl = Rewards.List[i]
        if !tbl then continue end

        local int = calculeSize(tbl.name)

        tblSize[i] = int

        intFullSizePanel = intFullSizePanel + int
    end

    local frame = vgui.Create("DFrame")
        frame:SetSize(intFullSizePanel,300)
        frame:Center()
        frame:SetTitle('')
        frame:MakePopup()
        frame:SetAlpha(0)
        frame:AlphaTo(255,0.2)
        frame:ShowCloseButton(false)
        function frame:FadeOut()
            frame:SetAlpha(255)
            frame:AlphaTo(0,0.2,0,function()
                if !IsValid(frame) then return end
                frame:Remove()
            end)
        end
        function frame:Paint(w,h)
            drawRect(0,0,w,h,COLORS.background)
            draw.SimpleText("Glitch Fire Rewards", "Rewards24", 10, 10, color_white)
        end 

    local btnClose = vgui.Create("DButton",frame)
        btnClose:SetSize(32,32)
        btnClose:SetPos(frame:GetWide()-btnClose:GetWide()-5,5)
        btnClose:SetTextColor(color_white)
        btnClose:SetFont('Rewards24')
        btnClose:SetText('X')
        btnClose.Paint = nil
        function btnClose:DoClick()
            surface.PlaySound( "buttons/button15.wav" )
            frame:FadeOut()
        end

    local pnlContent = vgui.Create("DPanel",frame)
        pnlContent:SetSize(frame:GetWide(),frame:GetTall()-75)
        pnlContent:SetPos(0,75)
        pnlContent.Paint = nil

    local intLast = 0

    for i = 1,#Rewards.List do
        local tbl = Rewards.List[i]
        if !tbl then continue end
        if !tblSize[i] then continue end
        
        local intSize = tblSize[i]

        local btn = vgui.Create("DButton", frame)
            btn:SetSize(intSize,35)
            btn:SetPos(intLast,40)
            btn:SetText('')
            function btn:Paint(w,h)
                drawRect(0,0,w,h,COLORS.secondary)

                local colText = COLORS.text

                if self:IsHovered() || intCurrentPanel == i then
                    colText = COLORS.red
                end
                
                draw.SimpleText(tbl.name, "Rewards18", w/2, h/2, colText, 1, 1)
            end
            function btn:DoClick()
                surface.PlaySound( "buttons/button15.wav" )

                intCurrentPanel = i

                pnlContent:Clear()
                pnlContent.Paint = nil

                if tbl.funcOnClick then
                    tbl.funcOnClick(pnlContent)
                end
            end

        intLast = intLast + tblSize[i]
    end

    Rewards.List[1].funcOnClick(pnlContent)
end

hook.Add("GFStartupDone", "Rewards:GFStartupDone", openMenu)

hook.Add("OnPlayerChat","Rewards:OnPlayerChat",function(ply, text, team, isDead)
    if !ply == LocalPlayer() then return end
    if text == Rewards.Command then
        openMenu()

        return true
    end
end)

concommand.Add("rewards_menu", openMenu)