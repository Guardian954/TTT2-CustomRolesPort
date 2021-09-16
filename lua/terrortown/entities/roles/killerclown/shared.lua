if SERVER then
	AddCSLuaFile()
	
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_kcl.vmt")

	local startCredits = CreateConVar("ttt2_clown_activation_credits", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
end

function ROLE:PreInitialize()
	self.color = Color(245, 48, 155, 255)

	self.abbr = "kcl" -- abbreviation
	self.radarColor = Color(245, 48, 155) -- color if someone is using the radar
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.preventWin = false -- set true if role can't win (maybe because of own / special win conditions)
	self.defaultTeam = TEAM_JESTER -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment

	if not startCredits then
		startCredits = 0
		print("Failed to retrieve credit convar for clown, set to 0 credits on transform to prevent errors")
	end 
	
	self.conVarData = {
		pct = 0.00, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 99, -- minimum amount of players until this role is able to get selected
		credits = startCredits, -- the starting credits of a specific role
		togglable = false, -- option to toggle a role for a client if possible (F1 menu)
		shopFallback = SHOP_TRAITOR,
	}
end

if SERVER then

	hook.Add("ScalePlayerDamage", "KillerClownDamageScale", function(ply, hitgroup, dmginfo)
		local attacker = dmginfo:GetAttacker()
		if attacker:GetSubRole() == ROLE_KILLERCLOWN then
            local bonus = GetConVar("ttt2_clown_damage_bonus"):GetFloat()
            dmginfo:ScaleDamage(1 + bonus)
        end
	end)


end