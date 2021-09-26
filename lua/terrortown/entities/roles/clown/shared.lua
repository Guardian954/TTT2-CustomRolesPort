if SERVER then
	AddCSLuaFile()
	
	util.AddNetworkString("NewClownConfetti")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_clo.vmt")
	resource.AddFile("sound/clown/clown_sound.wav")
	util.PrecacheSound("clown/clown_sound.wav")

	

end


roles.InitCustomTeam(ROLE.name, {
		icon = "vgui/ttt/dynamic/roles/icon_clo",
		color = Color(245, 48, 155, 255)
})

function ROLE:PreInitialize()
	self.color = Color(245, 48, 155, 255)

	self.abbr = "clo" -- abbreviation
	self.radarColor = Color(245, 48, 155) -- color if someone is using the radar
	self.surviveBonus = 2 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 0 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = 0 -- multiplier for teamkill
	self.preventWin = false -- set true if role can't win (maybe because of own / special win conditions)
	self.defaultTeam = TEAM_CLOWN -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment

	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 5, -- minimum amount of players until this role is able to get selected
		random = 30,
		credits = 1, -- the starting credits of a specific role
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		shopFallback = SHOP_DISABLED,
	}
end

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicCloCVars", function(tbl)
	tbl[ROLE_CLOWN] = tbl[ROLE_CLOWN] or {}

  	table.insert(tbl[ROLE_CLOWN], {
      cvar = "ttt2_clown_damage_bonus",
      slider = true,
      min = 0,
      max = 5,
      decimal = 1,
      desc = "How much extra damage the killer clown gets (Def. 0)"
  	})
  	table.insert(tbl[ROLE_CLOWN], {
      cvar = "ttt2_clown_activation_credits",
      slider = true,
      min = 0,
      max = 5,
      decimal = 0,
      desc = "How many credits the killer clown starts with (Def. 0)"
  	})
  	 table.insert(tbl[ROLE_CLOWN], {
      cvar = "ttt2_clown_health_on_transform",
      slider = true,
      min = 0,
      max = 100,
      decimal = 0,
      desc = "Clowns health when transforming into KillerClown (Def. 0)"
  	})
	table.insert(tbl[ROLE_CLOWN], {
		cvar = "ttt2_clown_entity_damage",
		checkbox = true,
		desc = "Can the clown damage entities? (Def. 1)"
	})
	 table.insert(tbl[ROLE_CLOWN], {
		cvar = "ttt2_clown_environmental_damage",
		checkbox = true,
		desc = "Can explode, burn, crush, fall, drown? (Def. 1)"
	})
end)

if SERVER then
	CreateConVar("ttt2_clown_damage_bonus", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_clown_entity_damage", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_clown_environmental_damage", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_clown_health_on_transform", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

	local function ResetClown()
		-- Nothing to reset yet
	end
	

	local function KillerClownChecks(victim, attacker)
		print("In killer clown checks")

		local players = player.GetAll()	
		local teams = {}

		for i = 1, #players do
			local ply = players[i]
			
			if ply:IsValid() and ply:Alive() and ply ~= victim then
				local team = ply:GetTeam()
				local preventWin 
				if ply:GetSubRoleData().preventWin == nil then
					preventWin = false
					print("Player with team " .. tostring(team) .. " has no preventWin so it was set to: " .. tostring(preventWin))
				else
					preventWin = ply:GetSubRoleData().preventWin
					print("Player with team " .. tostring(team) .. " has preventWin: " .. tostring(preventWin))
				end
				if ply:GetSubRole() ~= (ROLE_CLOWN) and not preventWin then -- Dont log the clowns team now that theyre independant or any role that cannot win by default

					if not teams[team] then
						teams[team] = {count = 1}
					else
						teams[team] = {count = teams[team].count + 1}
					end
			
				end
			end
		end

		print("Heres the current teams table: ")
		PrintTable(teams)
		local NoOfTeams = table.GetKeys(teams)

		print("No of teams: " .. #NoOfTeams)
		if #NoOfTeams == 1 then
			for i = 1, #players do
				local ply = players[i]
				local team = ply:GetTeam()
				if ply:GetSubRole() == ROLE_CLOWN then

					ply:SetRole(ROLE_KILLERCLOWN, team) -- Team parameter added to account for roles like the doppelganger, should let them play along but with their own team still.
					SendFullStateUpdate()
		        	ply:UpdateTeam(team) 

					local health = GetConVar("ttt2_clown_health_on_transform"):GetInt()
					if health ~= 0 then
						ply:SetHealth(health)
					end
					ply:PrintMessage(HUD_PRINTCENTER, "Kill them all!")

					net.Start("NewClownConfetti")
					net.WriteEntity(ply)
					net.Broadcast()
					SendFullStateUpdate()
					print("Killer clown is on the loose!")
				end
			end
		else
			print("Still multiple teams alive and fighting no killer clown yet")
		end
	
	end

	hook.Add("TTTPrepareRound", "ClownPrepareRound", ResetClown)
	hook.Add("TTTBeginRound", "ClownStartRound", ResetClown)
	hook.Add("TTTEndRound", "ClownEndRound", ResetClown)

	-- Hide the clown as a normal jester to the traitors
	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleClown", function(ply, tbl)
		if ply and not ply:HasTeam(TEAM_TRAITOR) or ply:GetSubRoleData().unknownTeam or GetRoundState() == ROUND_POST then return end

		for clown in pairs(tbl) do
			if not clown:IsTerror() or clown == ply then
				continue
			end
			if ply:GetSubRole() ~= ROLE_CLOWN and clown:GetSubRole() == ROLE_CLOWN then
				if not clown:Alive() then
					continue
				end
				if ply:GetTeam() ~= TEAM_JESTER then
					tbl[clown] = {ROLE_JESTER, TEAM_JESTER}
				else
					tbl[clown] = {ROLE_CLOWN, TEAM_JESTER}
				end
			end
		end
	end)

	hook.Add("TTT2ModifyRadarRole", "TTT2ModifyRadarRoleClown", function(ply, target)
		if ply:HasTeam(TEAM_TRAITOR) and target:GetSubRole() == ROLE_CLOWN then
			return ROLE_JESTER, TEAM_JESTER
		end
	end)

	-- We'll check for players alive here to prevent winning if possible
	hook.Add("DoPlayerDeath", "KillerClownChecks", function(victim, attacker, dmginfo)
		if victim:IsValid() and victim:IsPlayer() then
			local players = player.GetAll()	
			for i = 1, #players do
				local ply = players[i]
				if ply:IsValid() and ply:Alive() and ply:GetSubRole() == ROLE_CLOWN then -- Only continue if a living clown is found
					KillerClownChecks(victim, attacker)
				end
			end
		end
	end)

	-- Player doesnt deal or take any damage in relation to players
	hook.Add("PlayerTakeDamage", "ClownNoDamage", function(ply, inflictor, killer, amount, dmginfo)
		if TakeNoDamage(ply, killer, ROLE_CLOWN) or DealNoDamage(ply, killer, ROLE_CLOWN) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)
	
	-- Check if the player can damage entities or be damaged by environmental effects
	hook.Add("EntityTakeDamage", "ClownEntityNoDamage", function(ply, dmginfo)
		if EntityDamage(ply, dmginfo, ROLE_CLOWN) or TakeEnvironmentalDamage(ply, dmginfo, ROLE_CLOWN) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)
end