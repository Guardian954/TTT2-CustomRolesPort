AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_phn.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(82, 226, 255, 255)

	self.abbr = "phn" -- abbreviation
	self.radarColor = Color(150, 150, 150) -- color if someone is using the radar
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.unknownTeam = true --  Hides their team members - hopefully

	self.defaultTeam = TEAM_INNOCENT -- the team name: roles with same team name are working together
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
	tbl[ROLE_PHANTOM] = tbl[ROLE_PHANTOM] or {}


	table.insert(tbl[ROLE_PHANTOM], {
		cvar = "ttt2_phantom_possess",
		checkbox = true,
		desc = "Phantom can possess someone after death (Def. 1)"
	})

	table.insert(tbl[ROLE_PHANTOM], {
		cvar = "ttt2_phantom_burn",
		checkbox = true,
		desc = "Phantoms body can be burnt to kill him properly (Def. 1)"
	})

	table.insert(tbl[ROLE_PHANTOM], {
		cvar = "ttt2_phantom_respawn_weaker",
		checkbox = true,
		desc = "Phantoms respawn with less health each time the resurrect (Def. 1)"
	})
	table.insert(tbl[ROLE_PHANTOM], {
		cvar = "ttt2_phantom_notify_detective",
		checkbox = true,
		desc = "Detectives are notified of phantoms death (Def. 1)"
	})
	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_respawn_health",
      slider = true,
      min = 0,
      max = 100,
      decimal = 0,
      desc = "Phantom respawn health (def. 50)"
  	})
	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_haunt_power_max",
      slider = true,
      min = 0,
      max = 300,
      decimal = 0,
      desc = "Max power for haunting (def. 100)"
  	})
  	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_haunt_power_rate",
      slider = true,
      min = 0,
      max = 100,
      decimal = 0,
      desc = "Rate that power builds at when haunting (def. 10)"
  	})
  	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_haunt_move_cost",
      slider = true,
      min = 0,
      max = 200,
      decimal = 0,
      desc = "Cost for movement action when haunting (def. 25)"
  	})
	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_haunt_jump_cost",
      slider = true,
      min = 0,
      max = 200,
      decimal = 0,
      desc = "Cost for jump action when haunting (def. 50)"
  	})
  	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_haunt_drop_cost",
      slider = true,
      min = 0,
      max = 200,
      decimal = 0,
      desc = "Cost for drop action when haunting (def. 75)"
  	})
  	table.insert(tbl[ROLE_PHANTOM], {
      cvar = "ttt2_phantom_haunt_attack_cost",
      slider = true,
      min = 0,
      max = 200,
      decimal = 0,
      desc = "Cost for attack action when haunting(def. 100)"
  	})
end)

-- Global floats used for HUD element
hook.Add('TTT2SyncGlobals', 'ttt2_phantom_sync_convars', function()
		SetGlobalFloat('ttt2_phantom_haunt_power_max', GetConVar('ttt2_phantom_haunt_power_max'):GetInt())
		SetGlobalFloat('ttt2_phantom_haunt_power_rate', GetConVar('ttt2_phantom_haunt_power_rate'):GetFloat())	
		SetGlobalFloat('ttt2_phantom_haunt_move_cost', GetConVar('ttt2_phantom_haunt_move_cost'):GetInt())
		SetGlobalFloat('ttt2_phantom_haunt_jump_cost', GetConVar('ttt2_phantom_haunt_jump_cost'):GetInt())
		SetGlobalFloat('ttt2_phantom_haunt_drop_cost', GetConVar('ttt2_phantom_haunt_drop_cost'):GetInt())
		SetGlobalFloat('ttt2_phantom_haunt_attack_cost', GetConVar('ttt2_phantom_haunt_attack_cost'):GetInt())
		cvars.AddChangeCallback("ttt2_phantom_haunt_power_max", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_power_max", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_phantom_haunt_power_rate", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_power_rate", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_phantom_haunt_move_cost", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_move_cost", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_phantom_haunt_jump_cost", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_jump_cost", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_phantom_haunt_jump_cost", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_jump_cost", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_phantom_haunt_drop_cost", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_drop_cost", tobool(tonumber(new)))
		end)
		cvars.AddChangeCallback("ttt2_phantom_haunt_attack_cost", function(cv, old, new)
			SetGlobalBool("ttt2_phantom_haunt_attack_cost", tobool(tonumber(new)))
		end)
end)


function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)
end

if SERVER then
	CreateConVar("ttt2_phantom_possess", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_burn", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_respawn_weaker", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_notify_detective", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_respawn_health", "50", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_haunt_power_max", "100", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_haunt_power_rate", "10", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_haunt_move_cost", "25", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_haunt_jump_cost", "50", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_haunt_drop_cost", "75", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_phantom_haunt_attack_cost", "100", {FCVAR_NOTIFY, FCVAR_ARCHIVE})


	local deadPhantoms = {}


	local function ResetPhantom()
		local players = player.GetAll()
		for i = 1, #players do
			local ply = players[i]
			ply:SetNWBool("Haunted", false)
			ply:SetNWBool("Haunting", false)
			ply:SetNWString("HauntingTarget", nil)
			ply:SetNWInt("HauntingPower", 0)
			timer.Remove(ply:Nick() .. "HauntingPower")
		end
		deadPhantoms = {}
		print("Phantom Reset Complete")
	end
	
	-- Lets make sure no weird haunting stuff is happening outside of the round and reset everyone to normal
	hook.Add("TTTPrepareRound", "PhantomPrepareRound", ResetPhantom)
	hook.Add("TTTBeginRound", "PhantomStartRound", ResetPhantom)
	hook.Add("TTTEndRound", "PhantomEndRound", ResetPhantom)

	
	hook.Add("KeyPress", "PhantomPossession", function(ply, key)
		if ply:GetNWBool("Haunting", false) then
			local killer = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil
			if not IsValid(killer) or not killer:IsPlayer() then return end

			local action = nil
            -- Translate the key to the action, the undo action, how long it lasts, and how much it costs
            if key == IN_ATTACK then
                action = {"+attack", "-attack", 0.5, GetConVar("ttt2_phantom_haunt_attack_cost"):GetInt()}
                ply:SpectateEntity(ply:GetNWString("HauntingTarget"))	-- make sure we arent switching targets on mouse clicks

            elseif key == IN_ATTACK2 then
                action = {"+menu", "-menu", 0.2, GetConVar("ttt2_phantom_haunt_drop_cost"):GetInt()}
                ply:SpectateEntity(ply:GetNWString("HauntingTarget"))	-- make sure we arent switching targets on mouse clicks

            elseif key == IN_MOVELEFT or key == IN_MOVERIGHT or key == IN_FORWARD or key == IN_BACK then
                local moveCost = GetConVar("ttt2_phantom_haunt_move_cost"):GetInt()
                if key == IN_FORWARD then
                    action = {"+forward", "-forward", 0.5, moveCost}
                elseif key == IN_BACK then
                    action = {"+back", "-back", 0.5, moveCost}
                elseif key == IN_MOVELEFT then
                    action = {"+moveleft", "-moveleft", 0.5, moveCost}
                elseif key == IN_MOVERIGHT then
                    action = {"+moveright", "-moveright", 0.5, moveCost}
                end
            elseif key == IN_JUMP then
                action = {"+jump", "-jump", 0.2, GetConVar("ttt2_phantom_haunt_jump_cost"):GetInt()}
            end

			if action == nil then return end

			-- If this cost isn't valid, this action isn't valid
			local cost = action[4]
			if cost <= 0 then return end

			-- Check power level
			local currentpower = ply:GetNWInt("HauntingPower", 0)
			if currentpower < cost then return end


			-- Deduct the cost, run the command, and then run the un-command after the delay
			ply:SetNWInt("HauntingPower", currentpower - cost)
			if action[1] == "+menu" then
				killer:DropWeapon()
			end
			killer:ConCommand(action[1])
			timer.Simple(action[3], function()
				killer:ConCommand(action[2])
			end)
			return
		end
	end)

	hook.Add("PlayerDeath", "PhantomDeath", function(victim, infl, attacker)
		if victim:GetSubRole() == ROLE_PHANTOM and IsValid(attacker) and attacker:IsPlayer() then

			if victim == attacker then return end -- Suicide dont continue

			attacker:SetNWBool("Haunted", true)
			
			if GetConVar("ttt2_phantom_notify_detective"):GetBool() then 
				-- Use this method to grab all as I saw something about how intense pairs and ipairs are in comparison
				local players = player.GetAll()
				for i = 1, #players do
					local ply = players[i]
					if ply:GetSubRole() == ROLE_DETECTIVE then
						ply:PrintMessage(HUD_PRINTCENTER, "The Phantom is Dead!")
					end
				end
			end

			local sid = victim:SteamID64()

	        if not deadPhantoms[sid] then
	            deadPhantoms[sid] = {times = 1, player = victim, attacker = attacker:SteamID64()}
	        else
	            deadPhantoms[sid] = {times = deadPhantoms[sid].times + 1, player = victim, attacker = attacker:SteamID64()}
	        end
			
			if GetConVar("ttt2_phantom_possess"):GetBool() then
	            victim:SetNWBool("Haunting", true)
	            victim:SetNWString("HauntingTarget", attacker)
	            victim:SetNWInt("HauntingPower", 0)
				
				timer.Create(victim:Nick() .. "HauntingPower", 1, 0, function()
					-- Make sure the victim is still in the correct spectate mode
					local spec_mode = victim:GetObserverMode()
					if spec_mode ~= OBS_MODE_CHASE and spec_mode ~= OBS_MODE_IN_EYE then
						victim:Spectate(OBS_MODE_CHASE)
					end
					victim:SpectateEntity(victim:GetNWString("HauntingTarget"))
					local power = victim:GetNWInt("HauntingPower", 0)
					local power_rate = GetConVar("ttt2_phantom_haunt_power_rate"):GetInt()
					local new_power = math.Clamp(power + power_rate, 0, GetConVar("ttt2_phantom_haunt_power_max"):GetInt())
					victim:SetNWInt("HauntingPower", new_power)
					end)
			end
        end
	end)

	hook.Add("PostPlayerDeath", "PhantomPostDeath", function(ply)
		PhantomChecks(ply)
	end)



	function PhantomChecks(ply)
		if ply:GetNWBool("Haunted", false) then

			local respawn = false
			local phantomUsers = table.GetKeys(deadPhantoms)
			for i = 1, #phantomUsers do
				local phantom = deadPhantoms[phantomUsers[i]]

				if phantom.attacker == ply:SteamID64() and IsValid(phantom.player) then
					local deadPhantom = phantom.player
					deadPhantom:SetNWBool("Haunting", false)
					deadPhantom:SetNWInt("HauntingPower", 0)
					timer.Remove(deadPhantom:Nick() .. "HauntingPower")
					if not deadPhantom:Alive() then
						-- Find the Phantom's corpse
						local phantomBody = deadPhantom.server_ragdoll or deadPhantom:GetRagdollEntity()
						if IsValid(phantomBody) or not GetConVar("ttt2_phantom_burn"):GetBool() then
							PhantomRevive(deadPhantom, phantomBody)						
							respawn = true
						else
							deadPhantom:PrintMessage(HUD_PRINTCENTER, "Your attacker died but your body has been destroyed.")
						end
					end
				end

			ply:SetNWBool("Haunted", false)
			SendFullStateUpdate()

			end	
		end	
	end

	function PhantomRevive(ply, plybody)
		ply:Revive(
	      0,
	      function()
			local health = GetConVar("ttt2_phantom_respawn_health"):GetInt()
			if GetConVar("ttt2_phantom_respawn_weaker"):GetBool() then
				-- Check how many times phantom has died and devide res health by that if convar allows
				local plymulti = deadPhantoms[ply:SteamID64()].times

				for _ = 1, plymulti - 1 do
					health = health / 2
				end
				health = math.max(1, math.Round(health))
			end
			ply:SetHealth(health)
			plybody:Remove()
			ply:SetNWString("HauntingTarget", nil)
			ply:PrintMessage(HUD_PRINTCENTER, "Your attacker died and you have been respawned.")
	        ply:ResetConfirmPlayer()
	      end,
	      nil,
	      false,
	      true
	    )
	end

end

if CLIENT then
	hook.Add("Think", "PhantomSmokeCheck", function()
			local players = player.GetAll()
			for i = 1, #players do
				local ply = players[i]
				if ply:Alive() and ply:GetNWBool("Haunted") then
					if not ply.SmokeEmitter then ply.SmokeEmitter = ParticleEmitter(ply:GetPos()) end
					if not ply.SmokeInterval then ply.SmokeInterval = CurTime() end
					local pos = ply:GetPos() + Vector(0, 0, 30)
					local client = LocalPlayer()
					if ply.SmokeInterval < CurTime() then
						if client:GetPos():Distance(pos) > 1000 then return end
						ply.SmokeEmitter:SetPos(pos)
						ply.SmokeInterval = CurTime() + math.Rand(0.003, 001)
						local vec = Vector(math.Rand(-8, 8),math.Rand(-8, 8),math.Rand(10, 55))
						local pos = ply:LocalToWorld(vec)
						for i = 1, 20 do
							local particle = ply.SmokeEmitter:Add("particle/snow.vmt", pos)
							particle:SetVelocity(Vector(0,0,4) + VectorRand() * 3)
							particle:SetDieTime(math.Rand(0.5, 2))
							particle:SetStartAlpha(math.random(150, 220))
							particle:SetEndAlpha(0)
							local size = math.random(4, 7)
							particle:SetStartSize(size)
							particle:SetEndSize(size + 1)
							particle:SetRoll(0)
							particle:SetRollDelta(0)
							particle:SetColor(0, 0, 0)
						end
					end
				else
					if ply.SmokeEmitter then
						ply.SmokeEmitter:Finish()
						ply.SmokeEmitter = nil
					end
				end
			end
	end)
	
end