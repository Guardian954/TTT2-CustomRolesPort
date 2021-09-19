if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_beg.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(245, 48, 155, 255)

	self.abbr = "beg" -- abbreviation
	self.radarColor = Color(245, 48, 155) -- color if someone is using the radar
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.preventWin = true -- set true if role can't win (maybe because of own / special win conditions)
	self.defaultTeam = TEAM_BEGGAR -- the team name: roles with same team name are working together
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

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicBegCVars", function(tbl)
	tbl[ROLE_BEGGAR] = tbl[ROLE_BEGGAR] or {}

	table.insert(tbl[ROLE_BEGGAR], {
		cvar = "ttt2_beggar_entity_damage",
		checkbox = true,
		desc = "Can the beggar damage entities? (Def. 1)"
	})
	 table.insert(tbl[ROLE_BEGGAR], {
		cvar = "ttt2_beggar_environmental_damage",
		checkbox = true,
		desc = "Can explode, burn, crush, fall, drown? (Def. 1)"
	})
	table.insert(tbl[ROLE_BEGGAR], {
		cvar = "ttt2_beggar_respawn",
		checkbox = true,
		desc = "Beggar respawn on death (Def. 1)"
	})
	table.insert(tbl[ROLE_BEGGAR], {
      cvar = "ttt2_beggar_respawn_delay",
      slider = true,
      min = 0,
      max = 60,
      decimal = 0,
      desc = "Beggar respawn delay (Def. 3)"
  	})
  	table.insert(tbl[ROLE_BEGGAR], {
		cvar = "ttt2_beggar_reveal_mode",
		combobox = true,
		desc = "ttt2_beggar_reveal_mode (Def: 0)",
		choices = {
			"0 - Never reveal the beggar has changed team",
			"1 - Only alert the detective or traiters the beggar has now joined",
			"2 - Alert all of the beggars new team members",
			"3 - Alert everyone of the beggars new team"
		},
		numStart = 0
	})
end)

if SERVER then
	CreateConVar("ttt2_beggar_entity_damage", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_beggar_environmental_damage", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_beggar_respawn", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_beggar_respawn_delay", "3", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_beggar_reveal_mode", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	

	hook.Add("TTTBeginRound", "BeggarStartRound", function()

	end)

	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleBeggar", function(ply, tbl)
		if ply and not ply:HasTeam(TEAM_TRAITOR) or ply:GetSubRoleData().unknownTeam or GetRoundState() == ROUND_POST then return end

		for beggar in pairs(tbl) do
			if not beggar:IsTerror() or beggar == ply then
				continue
			end
			if ply:GetSubRole() ~= ROLE_BEGGAR and beggar:GetSubRole() == ROLE_BEGGAR then
				if not beggar:Alive() then
					continue
				end
				if ply:GetTeam() ~= TEAM_JESTER then
					tbl[beggar] = {ROLE_JESTER, TEAM_JESTER}
				else
					tbl[beggar] = {ROLE_BEGGAR, TEAM_JESTER}
				end
			end
		end
	end)

	hook.Add("TTT2ModifyRadarRole", "TTT2ModifyRadarRoleBeggar", function(ply, target)
		if ply:HasTeam(TEAM_TRAITOR) and target:GetSubRole() == ROLE_BEGGAR then
			return ROLE_JESTER, TEAM_JESTER
		end
	end)

	hook.Add("WeaponEquip", "BeggarItemEquip", function(weapon, ply)
		if weapon.CanBuy and not weapon.AutoSpawnable then
		    if not weapon.BoughtBy then
		        weapon.BoughtBy = ply
		    elseif ply:GetSubRole() == ROLE_BEGGAR then --and (weapon.BoughtBy:GetTeam() == (ROLE_TRAITOR or ROLE_INNOCENT)) then
		    	print("Beggar has picked up a " .. tostring(weapon) .. " dropped by " .. tostring(weapon.BoughtBy) .. " who has this team " .. tostring(weapon.BoughtBy:GetTeam()))
		        local role
		        if weapon.BoughtBy:GetTeam() == TEAM_TRAITOR then
		            role = ROLE_TRAITOR
		            team = "traitors team"

		        elseif weapon.BoughtBy:GetTeam() == TEAM_INNOCENT then
		            role = ROLE_INNOCENT
		            team = "innocents team"

		        else
		        	print("Non innocent or traiter supplied weapon given to beggar: " .. tostring(weapon) .. " by " .. tostring(weapon.BoughtBy)) -- Another role has dropped something for the beggar, print so we can see if its shop bought and who the player is.
		        	role = weapon.BoughtBy:GetSubRole()	
		        	team = weapon.BoughtBy:GetTeam()	

		        end

		        ply:SetRole(role)
		        ply:PrintMessage(HUD_PRINTTALK, "You have joined the " .. team)
		        ply:PrintMessage(HUD_PRINTCENTER, "You have joined the " .. team)
		        timer.Simple(0.5, function() SendFullStateUpdate() end) -- Slight delay to avoid flickering from beggar to the new role and back to beggar
		        
		        local mode = GetConVar("ttt2_beggar_reveal_mode"):GetInt()

		        local players = player.GetAll()
		        if mode ~= 0 then
					for i = 1, #players do
						local v = players[i]
			            if (mode == 1 and (role == ROLE_INNOCENT and v:GetSubRole() == ROLE_DETECTIVE) or (role == ROLE_TRAITOR and v:GetTeam() == TEAM_TRAITOR)) or (mode == 2 and ply:GetTeam() == v:GetTeam()) or (mode == 3) then
			                v:PrintMessage(HUD_PRINTTALK, "The beggar has joined the " .. team)
			                v:PrintMessage(HUD_PRINTCENTER, "The beggar has joined the " .. team)
			            end
			        end
		        end
		    end
		end
	end)

	-- Beggar doesnt deal or take any damage in relation to players
	hook.Add("PlayerTakeDamage", "BeggarNoDamage", function(ply, inflictor, killer, amount, dmginfo)
		if TakeNoDamage(ply, killer, ROLE_BEGGAR) or DealNoDamage(ply, killer, ROLE_BEGGAR) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)
	
	-- Check if the beggar can damage entities or be damaged by environmental effects
	hook.Add("EntityTakeDamage", "BeggarEntityNoDamage", function(ply, dmginfo)
		if EntityDamage(ply, dmginfo, ROLE_BEGGAR) or TakeEnvironmentalDamage(ply, dmginfo, ROLE_BEGGAR) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)

	hook.Add("PlayerDeath", "BeggarDeath", function(victim, infl, attacker)
		if victim:GetSubRole() == ROLE_BEGGAR and IsValid(attacker) and attacker:IsPlayer() then
			if victim == attacker then return end -- Suicide so do nothing

			if GetConVar("ttt2_beggar_respawn"):GetBool() then
				local delay = GetConVar("ttt2_beggar_respawn_delay"):GetInt()
				if delay > 0 then
	                victim:PrintMessage(HUD_PRINTCENTER, "You were killed but will respawn in " .. delay .. " seconds.")
	            else
	                victim:PrintMessage(HUD_PRINTCENTER, "You were killed but are about to respawn.")
	                -- Introduce a slight delay to prevent player getting stuck as a spectator
	                delay = 0.1
	            end
	            timer.Simple(delay, function()
					BeggarRevive(victim)
	        	end)
			end
        end
	end)

	function BeggarRevive(ply)
		ply:Revive(
	      0,
	      function()	-- @param[opt] function OnRevive The @{function} that should be run if the @{Player} revives
	        ply:ResetConfirmPlayer()
	        SendFullStateUpdate()
	      end
	    )
	end
end