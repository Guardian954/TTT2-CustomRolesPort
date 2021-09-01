AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_swa.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(245, 48, 155, 255)

	self.abbr = "swa" -- abbreviation
	self.radarColor = Color(245, 48, 155) -- color if someone is using the radar
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill

	self.defaultTeam = TEAM_NONE -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment

	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 5, -- minimum amount of players until this role is able to get selected
		credits = 1, -- the starting credits of a specific role
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		shopFallback = SHOP_DISABLED,
	}
end

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicPhaCVars", function(tbl)
	tbl[ROLE_SWAPPER] = tbl[ROLE_SWAPPER] or {}

  	table.insert(tbl[ROLE_SWAPPER], {
      cvar = "ttt2_swapper_killer_health",
      slider = true,
      min = 0,
      max = 100,
      decimal = 0,
      desc = "Health of swappers killer on resurrection (Def. 1)"
  	})
  	table.insert(tbl[ROLE_SWAPPER], {
      cvar = "ttt2_swapper_respawn_health",
      slider = true,
      min = 0,
      max = 100,
      decimal = 0,
      desc = "Health swapper returns resurrects with (Def. 50)"
  	})
	table.insert(tbl[ROLE_SWAPPER], {
		cvar = "ttt2_swapper_entity_damage",
		checkbox = true,
		desc = "Can the swapper damage entities? (Def. 1)"
	})
	 table.insert(tbl[ROLE_SWAPPER], {
		cvar = "ttt2_swapper_enviromental_damage",
		checkbox = true,
		desc = "Can explode, burn, crush, fall, drown? (Def. 1)"
	})
end)

hook.Add('TTT2SyncGlobals', 'ttt2_swapper_sync_convars', function()
		SetGlobalFloat('ttt2_swapper_killer_health', GetConVar('ttt2_swapper_killer_health'):GetInt())
		SetGlobalFloat('ttt2_swapper_respawn_health', GetConVar('ttt2_swapper_respawn_health'):GetFloat())	
		SetGlobalFloat('ttt2_swapper_entity_damage', GetConVar('ttt2_swapper_respawn_health'):GetFloat())	
		SetGlobalFloat('ttt2_swapper_enviromental_damage', GetConVar('ttt2_swapper_respawn_health'):GetFloat())	
		cvars.AddChangeCallback("ttt2_swapper_killer_health", function(cv, old, new)
			SetGlobalBool("ttt2_swapper_killer_health", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_swapper_respawn_health", function(cv, old, new)
			SetGlobalBool("ttt2_swapper_respawn_health", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_swapper_entity_damage", function(cv, old, new)
			SetGlobalBool("ttt2_swapper_entity_damage", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_swapper_enviromental_damage", function(cv, old, new)
			SetGlobalBool("ttt2_swapper_enviromental_damage", tobool(tonumber(new)))
		end)
end)

function ROLE:Initialize()
	if CLIENT then
		-- Role specific language elements
		LANG.AddToLanguage("En", self.name, "Swapper")
		LANG.AddToLanguage("En", "info_popup_" .. self.name,
			[[You are a Swapper!
				Get killed by other roles to steal their roles and leave them as the swapper!]])
		LANG.AddToLanguage("En", "body_found_" .. self.abbr, "This was a Swapper...")
		LANG.AddToLanguage("En", "search_role_" .. self.abbr, "This person was a Swapper!")
		LANG.AddToLanguage("En", "target_" .. self.name, "Swapper")
		LANG.AddToLanguage("En", "ttt2_desc_" .. self.name, [[The Swapper is a unique role that when killed takes their killers identity!]])
	end
end

if SERVER then
	CreateConVar("ttt2_swapper_killer_health", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_swapper_respawn_health", "100", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_swapper_entity_damage", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_swapper_enviromental_damage", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})


	local attackerweps = {}
	local swapperweps = {}

	hook.Add("TTTBeginRound", "SwapperStartRound", function()
		local attackerweps = {}
		local swapperweps = {}
	end)

	-- Swapper doesnt deal or take any damage in relation to players
	hook.Add("PlayerTakeDamage", "SwapperNoDamage", function(ply, inflictor, killer, amount, dmginfo)
		if SwapperTakeNoDamage(ply, killer) or SwapperDealNoDamage(ply, killer) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)
	
	-- Check if the swapper can damage entities or be damaged by environmental effects
	hook.Add("EntityTakeDamage", "SwapperEntityNoDamage", function(ply, dmginfo)
		if SwapperEntityDamage(ply, dmginfo) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)

	-- Grab the weapons tables before the player loses them
	hook.Add("DoPlayerDeath", "SwapperItemGrab", function(victim, attacker, dmginfo)
		if victim:GetSubRole() == ROLE_SWAPPER and IsValid(attacker) and attacker:IsPlayer() then
			attackerweps = attacker:GetWeapons()
			swapperweps = victim:GetWeapons()
		end
	end)

	hook.Add("PlayerDeath", "SwapperDeath", function(victim, infl, attacker)
		if victim:GetSubRole() == ROLE_SWAPPER and IsValid(attacker) and attacker:IsPlayer() then
			if victim == attacker then return end -- Suicide

			local attackerRole = attacker:GetSubRole()

			-- Handle the killers swap to his new life of swapper
			attacker:SetRole(ROLE_SWAPPER)
			local health = GetConVar("ttt2_swapper_killer_health"):GetInt()
	        if health == 0 then
	            attacker:Kill()
	        else
	            attacker:SetHealth(health)
	        end
	        SendFullStateUpdate()

			attacker:PrintMessage(HUD_PRINTCENTER, "You killed the Swapper!")

			-- Handle the swappers new life as a new role
			SwapperRevive(victim, attackerRole)

			timer.Simple(0.01, function()
				SwapWeapons(victim, attacker, swapperweps, attackerweps)
	        end)

        end
	end)


	function SwapperTakeNoDamage(ply, attacker)
		if not IsValid(ply) or ply:GetSubRole() ~= ROLE_SWAPPER then return end

		if IsValid(attacker) and attacker ~= ply then return end

		return true -- true to block damage event
	end

	function SwapperEntityDamage(ply, dmginfo)
		local attacker = dmginfo:GetAttacker()

		if not (IsValid(ply) and ply:IsPlayer()) and not (IsValid(attacker) and attacker:IsPlayer())  then return end -- If theres no players involved at all leave here
		if IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() ~= ROLE_SWAPPER then return end -- If the attacker is a player but not the swapper then dont block anything
		if SpecDM and (ply.IsGhost and ply:IsGhost() or (attacker.IsGhost and attacker:IsGhost())) then return end

		-- Allow the swapper to damage entities unless convar is false
		if GetConVar("ttt2_swapper_entity_damage"):GetBool() and IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_SWAPPER then return end

		-- Allow the swapper to take environmental damage unless convar is false
		if GetConVar("ttt2_swapper_enviromental_damage"):GetBool() and IsValid(ply) and ply:IsPlayer() and ply:GetSubRole() == ROLE_SWAPPER and (dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_FALL) or dmginfo:IsDamageType(DMG_DROWN)) then return end

		return true
	end

	function SwapperDealNoDamage(ply, attacker)
		if not IsValid(ply) or not IsValid(attacker) or not attacker:IsPlayer() or attacker:GetSubRole() ~= ROLE_SWAPPER then return end
		if SpecDM and (ply.IsGhost and ply:IsGhost() or (attacker.IsGhost and attacker:IsGhost())) then return end

		return true -- true to block damage event
	end

	-- Function to hand everyone their new weapons
	function SwapWeapons(victim, attacker, victimtable, attackertable)

		if not IsValid(ply) or not IsValid(attacker) or not ply:IsPlayer() or not attacker:IsPlayer() then return end

		for _, weapons in ipairs(attackertable) do
			print("Stripping weapon " .. tostring(WEPS.GetClass(weapons)) .. " from " .. tostring(attacker))
			attacker:StripWeapon(WEPS.GetClass(weapons))
		end

		-- Give the attacker all their victims gear
		for _, weapons in ipairs(victimtable) do
			print("Attempting to give " .. tostring(WEPS.GetClass(weapons)) .. " to " .. tostring(attacker))
            attacker:Give(WEPS.GetClass(weapons))
        end
        attacker:SelectWeapon("weapon_zm_improvised")
        victimtable = {}

		-- Next is the victim
		-- Remove all equipment from the victim
		for _, weapons in ipairs(attackertable) do
			print("Stripping weapon " .. tostring(WEPS.GetClass(weapons)) .. " from " .. tostring(victim))
			victim:StripWeapon(WEPS.GetClass(weapons))
		end
		-- Give the victim all their attackers gear
		for _, weapons in ipairs(attackertable) do
			print("Attempting to give " .. tostring(WEPS.GetClass(weapons)) .. " to " .. tostring(victim))
            victim:Give(WEPS.GetClass(weapons))
        end
        victim:SelectWeapon("weapon_zm_improvised")
        attackertable = {}

	end

	local offsets = {}

	for i = 0, 360, 15 do
	    table.insert(offsets, Vector(math.sin(i), math.cos(i), 0))
	end

	function FindRespawnLocation(pos)
	    local midsize = Vector(33, 33, 74)
	    local tstart = pos + Vector(0, 0, midsize.z / 2)

	    for i = 1, #offsets do
	        local o = offsets[i]
	        local v = tstart + o * midsize * 1.5

	        local t = {
	            start = v,
	            endpos = v,
	            mins = midsize / -2,
	            maxs = midsize / 2
	        }

	        local tr = util.TraceHull(t)

	        if not tr.Hit then return (v - Vector(0, 0, midsize.z / 2)) end
	    end

	    return false
	end

	function SwapperRevive(ply, role)
		ply:Revive(
	      0,
	      function()
	      	local body = ply.server_ragdoll or ply:GetRagdollEntity()
			local health = GetConVar("ttt2_swapper_respawn_health"):GetInt()
			ply:SetHealth(health)
			if IsValid(body) then
                ply:SetPos(FindRespawnLocation(body:GetPos()) or body:GetPos())
                ply:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
                body:Remove()
            end
            ply:SetRole(role)
			ply:SetDefaultCredits()
	        ply:ResetConfirmPlayer()
	        SendFullStateUpdate()
	      end,
	      nil,
	      false,
	      true
	    )
	end

end

if CLIENT then

	
end