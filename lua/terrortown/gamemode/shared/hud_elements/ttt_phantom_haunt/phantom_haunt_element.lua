local base = 'pure_skin_element'

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

-- The following code was taken from LeBroomers Demonic possession for TTT2 and manipulated to suit, why remake the hud element when hes alrady made it better than I couldve
-- Check out his addon: https://steamcommunity.com/sharedfiles/filedetails/?id=1615324913

if CLIENT then -- CLIENT
    local const_defaults = {
        basepos = {x = 0, y = 0},
        size = {w = 400, h = 225},
        minsize = {w = 400, h = 225}
    }

    local barColor = Color(205, 155, 0, 255)
    local timerColor = Color(234, 41, 41)
    local pad = 15
    
    function HUDELEMENT:PreInitialize()
        BaseClass.PreInitialize(self)
        
        local hud = huds.GetStored("pure_skin")
        if hud then
            hud:ForceElement(self.id)
        end

        -- set as fallback default, other skins have to be set to true!
        self.disabledUnlessForced = false
	end

    function HUDELEMENT:Initialize()
		self.scale = 1.0
        self.basecolor = self:GetHUDBasecolor()
        self.pad = pad * self.scale

		BaseClass.Initialize(self)
    end

    function HUDELEMENT:PerformLayout()
        self.basecolor = self:GetHUDBasecolor()
        self.scale = self:GetHUDScale()
        self.pad = pad * self.scale

		BaseClass.PerformLayout(self)
	end
    
    function HUDELEMENT:GetDefaults()
		const_defaults['basepos'] = {x = math.Round(self.pad), y = math.Round(ScrH() * 0.5 - self.size.h * 0.5)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
    end

    function HUDELEMENT:ShouldDraw()
        local client = LocalPlayer()
        return IsValid(client) and client:GetNWBool("Haunting") or HUDEditor.IsEditing
	end
    -- parameter overwrites end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h
        local fontColor = self:GetDefaultFontColor(self.basecolor)

		-- draw bg
        self:DrawBg(x, y, w, h, self.basecolor)
        
        -- draw border and shadow
        self:DrawLines(x, y, w, h, self.basecolor.a)

        local rx, ry = x + self.pad, y + self.pad
        local bw, bh = w - 2 * self.pad, 26 * self.scale
        local th = 40 * self.scale
        local powerY = y - self.pad - bh
        local dp = client:GetNWInt("HauntingPower", 0)

        self:DrawBar(rx, powerY, bw, bh, barColor, dp / GetGlobalFloat("ttt2_phantom_haunt_power_max"), self.scale)
        draw.AdvancedText(tostring(math.floor(dp)) .. " / " .. tostring(GetGlobalFloat("ttt2_phantom_haunt_power_max")), "PureSkinBar", rx + bw * 0.5, powerY + bh * 0.5, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, true, self.scale)

        draw.AdvancedText("Available Commands", "PureSkinBar", rx + bw * 0.5, ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, true, self.scale)

        ry = ry + bh * 1.2

        draw.RoundedBoxEx(0, rx, ry, bw, 1, fontColor)

        ry = ry + self.pad

        draw.AdvancedText("Move Keys", "PureSkinItemInfo", rx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText("Move the player", "PureSkinItemInfo", x + w * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText(tostring(GetGlobalFloat("ttt2_phantom_haunt_move_cost")) .. " Power", "PureSkinItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt2_phantom_haunt_move_cost") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, true, self.scale)

        ry = ry + bh + self.pad

        draw.AdvancedText("Space", "PureSkinItemInfo", rx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText("Jump for the player", "PureSkinItemInfo", x + w * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText(tostring(GetGlobalFloat("ttt2_phantom_haunt_jump_cost")) .. " Power", "PureSkinItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt2_phantom_haunt_jump_cost") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, true, self.scale)

        ry = ry + bh + self.pad

        draw.AdvancedText("Right Click", "PureSkinItemInfo", rx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText("Drop the players weapon", "PureSkinItemInfo", x + w * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText(tostring(GetGlobalFloat("ttt2_phantom_haunt_drop_cost")) .. " Power", "PureSkinItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt2_phantom_haunt_drop_cost") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, true, self.scale)

        ry = ry + bh + self.pad

        draw.AdvancedText("Left Click", "PureSkinItemInfo", rx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText("Attack for the player", "PureSkinItemInfo", x + w * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, true, self.scale)
        draw.AdvancedText(tostring(GetGlobalFloat("ttt2_phantom_haunt_attack_cost")) .. " Power", "PureSkinItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt2_phantom_haunt_attack_cost") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, true, self.scale)

    end
end