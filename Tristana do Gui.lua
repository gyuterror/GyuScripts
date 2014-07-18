--[[Tristana do Gui - by gyuterror
		Some facts:
		- Supports AP Tristana (With DFG in combo)
		- I've been working for a long time on this script, it is my first one! 
		- With last hit function
		
		Required Libs:
		- SOW
		- VPrediction
]]

-- Name Check -- 
if myHero.charName ~= "Tristana" then return end

if VIP_USER then 
	require "Prodiction" 
end

-- Loading Function --
function OnLoad()
	Variables()
	TristanaMenu()
	PrintChat("<font color='#0000FF'> >> Tristana Do Gui Loaded!! <<</font>")
end

-- Tick Function --
function OnTick()
	Checks()
	UpdateRange()
	--UseConsumables()
	DamageCalculation()

	-- Menu Vars --
	ComboKey =   TristanaMenu.combo.comboKey
	HarassKey =  TristanaMenu.harass.harassKey
	JungleKey =  TristanaMenu.jungle.jungleKey
	
	if ComboKey then FullCombo() end
	if HarassKey then HarassCombo() end
	if JungleKey then JungleClear() end
	if TristanaMenu.ks.killSteal then KillSteal() end
	if TristanaMenu.ks.autoIgnite then AutoIgnite() end
	if TristanaMenu.harass.minionKill then MinionHarass() end
end

function Variables()
	gameState = GetGame()
	if gameState.map.shortName == "twistedTreeline" then
		TTMAP = true
	else
		TTMAP = false
	end
	wRange, eRange, rRange, iRange = 900, 600, 645, 600
	qName, wName, eName, rName = "Rapid Fire", "Rocket Jump", "Explosive Shot", "Buster Shot"
	qReady, wReady, eReady, rReady = false, false, false, false
	wSpeed, wDelay, wWidth = math.huge, .250, 450
	if VIP_USER then
		wPos, ePos = nil, nil
		Prodict = ProdictManager.GetInstance()
		ProdictW = Prodict:AddProdictionObject(_W, wRange, wSpeed, wDelay, wWidth, myHero)
	end
	hpReady, mpReady, fskReady, Recalling = false, false, false, false
	TextList = {"Harass him!!", "E+W KILL!", "Full Combo Kill!", "Need Mana!!", "Skills on CD!"}
	KillText = {}
	colorText = ARGB(255,0,255,0)
	usingHPot, usingMPot, usingUlt, rManual = false, false, false, false
	lastAnimation = nil
	lastAttack = 0
	lastAttackCD = 0
	lastWindUpTime = 0
	enemyMinions = minionManager(MINION_ENEMY, eRange, player, MINION_SORT_HEALTH_ASC)
	enemyHeroes = GetEnemyHeroes()
	allyHeroes = GetAllyHeroes()
	JungleMobs = {}
	JungleFocusMobs = {}
	ToInterrupt = {}
	priorityTable = {
	    AP = {
	        "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
	        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
	        "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra",
	            },
	    Support = {
	        "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
	                },
	    Tank = {
	        "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
	        "Warwick", "Yorick", "Zac",
	            },
	    AD_Carry = {
	        "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
	        "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed", 
	                },
	    Bruiser = {
	        "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
	        "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao",
	            },
        }
	InterruptList = {
    	{ charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    	{ charName = "FiddleSticks", spellName = "Crowstorm"},
    	{ charName = "FiddleSticks", spellName = "DrainChannel"},
    	{ charName = "Galio", spellName = "GalioIdolOfDurand"},
    	{ charName = "Karthus", spellName = "FallenOne"},
    	{ charName = "Katarina", spellName = "KatarinaR"},
    	{ charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    	{ charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    	{ charName = "Nunu", spellName = "AbsoluteZero"},
    	{ charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    	{ charName = "Shen", spellName = "ShenStandUnited"},
    	{ charName = "Urgot", spellName = "UrgotSwap2"},
    	{ charName = "Varus", spellName = "VarusQ"},
    	{ charName = "Warwick", spellName = "InfiniteDuress"}
	}

	
	JungleMobNames = { 
        ["wolf8.1.1"] = true,
        ["wolf8.1.2"] = true,
        ["YoungLizard7.1.2"] = true,
        ["YoungLizard7.1.3"] = true,
        ["LesserWraith9.1.1"] = true,
        ["LesserWraith9.1.2"] = true,
        ["LesserWraith9.1.4"] = true,
        ["YoungLizard10.1.2"] = true,
        ["YoungLizard10.1.3"] = true,
        ["SmallGolem11.1.1"] = true,
        ["wolf2.1.1"] = true,
        ["wolf2.1.2"] = true,
        ["YoungLizard1.1.2"] = true,
        ["YoungLizard1.1.3"] = true,
        ["LesserWraith3.1.1"] = true,
        ["LesserWraith3.1.2"] = true,
        ["LesserWraith3.1.4"] = true,
        ["YoungLizard4.1.2"] = true,
        ["YoungLizard4.1.3"] = true,
        ["SmallGolem5.1.1"] = true,
}

	FocusJungleNames = {
        ["Dragon6.1.1"] = true,
        ["Worm12.1.1"] = true,
        ["GiantWolf8.1.1"] = true,
        ["AncientGolem7.1.1"] = true,
        ["Wraith9.1.1"] = true,
        ["LizardElder10.1.1"] = true,
        ["Golem11.1.2"] = true,
        ["GiantWolf2.1.1"] = true,
        ["AncientGolem1.1.1"] = true,
        ["Wraith3.1.1"] = true,
        ["LizardElder4.1.1"] = true,
        ["Golem5.1.2"] = true,
		["GreatWraith13.1.1"] = true,
		["GreatWraith14.1.1"] = true,
}

	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil then
			if FocusJungleNames[object.name] then
				table.insert(JungleFocusMobs, object)
			elseif JungleMobNames[object.name] then
				table.insert(JungleMobs, object)
			end
		end
	end

	for _, enemy in pairs(enemyHeroes) do
        for _, champ in pairs(InterruptList) do
            if enemy.charName == champ.charName then
                table.insert(ToInterrupt, champ.spellName)
            end
        end
     end

     	TargetSelector = TargetSelector(TARGET_LOW_HP, wRange ,DAMAGE_PHYSICAL)
	TargetSelector.name = "Tristana"

	if heroManager.iCount < 10 then 
        PrintChat(" >> Too few champions to arrange priority")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPrioritys()
    else
        ArrangePrioritys()
    end

end

-- Menu --
function TristanaMenu()
	TristanaMenu = scriptConfig("Tristana do Gui", "Tristana")
	
	menu:addParam("drawAA", "Draw Autoattack Range", SCRIPT_PARAM_ONOFF, false) 					--menu.drawAA 				//false
		menu:addParam("colorAA", "Circle Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255}) 				--menu.colorAA 				//255,255,255,255
		menu:addParam("line", "-----------------------------------------", SCRIPT_PARAM_INFO, "") 		-------------------- 		------------------
		menu:addParam("drawlasthit", "Draw Mark on Minion", SCRIPT_PARAM_ONOFF, false) 					--menu.drawlasthit 			//true
		menu:addParam("width", "Circle Width", SCRIPT_PARAM_SLICE, 3, 1, 5) 							--menu.width 				//3,1,5
		menu:addParam("color", "Circle Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 0}) 					  --menu.color 				//255,75,0,100
		menu:addParam("line", "-----------------------------------------", SCRIPT_PARAM_INFO, "") 		-------------------- 		------------------
		menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
		menu:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
	
	TristanaMenu:addSubMenu("["..myHero.charName.." - Combo Settings]", "combo")
		TristanaMenu.combo:addParam("comboKey", "Full Combo Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
		TristanaMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.combo:addParam("wKillOnly", "Use W Only to Kill", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.combo:addParam("comboOrbwalk", "OrbWalk on Combo", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.combo:permaShow("comboKey") 
	
	TristanaMenu:addSubMenu("["..myHero.charName.." - Harass Settings]", "harass")
		TristanaMenu.harass:addParam("harassKey", "Harass Hotkey (C)", SCRIPT_PARAM_ONKEYDOWN, false, 67)
		TristanaMenu.harass:addParam("minionKill", "Smart Minion Kill Harass", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.harass:addParam("harassW", "Use "..qName.." (Q)", SCRIPT_PARAM_ONOFF, false)
		TristanaMenu.harass:addParam("harassOrbwalk", "OrbWalk on Harass", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.harass:permaShow("harassKey") 
		
	TristanaMenu:addSubMenu("["..myHero.charName.." - "..rName.." (R) Settings]", "ult")
		TristanaMenu.ult:addParam("rInterrupt", "Interrupt Spells with "..rName, SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.ult:addParam("pushFromMe", "Push Enemies Away From me", SCRIPT_PARAM_ONOFF, true)
		for _, ally in pairs(allyHeroes) do
			TristanaMenu.ult:addParam("pushFromAlly" .. ally.charName, "Push Enemies from " .. ally.charName, SCRIPT_PARAM_ONOFF, false)
		end

	TristanaMenu:addSubMenu("["..myHero.charName.." - Clear Settings]", "jungle")
		TristanaMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, 86)
		TristanaMenu.jungle:addParam("jungleQ", "Clear with "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.jungle:addParam("jungleE", "Clear with "..eName.." (E)", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.jungle:addParam("jungleOrbwalk", "Orbwalk the Jungle", SCRIPT_PARAM_ONOFF, true)
		
		
	TristanaMenu:addSubMenu("["..myHero.charName.." - KillSteal Settings]", "ks")
		TristanaMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.ks:addParam("predIgnite", "Predicted Ignite/Ult", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.ks:addParam("dontJump", "Don't Jump if # Enemies Around", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
		TristanaMenu.ks:permaShow("killSteal") 
			
	TristanaMenu:addSubMenu("["..myHero.charName.." - Drawing Settings]", "drawing")	
		TristanaMenu.drawing:addParam("mDraw", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
		TristanaMenu.drawing:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.drawing:addParam("wDraw", "Draw "..wName.." (W) Range", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.drawing:addParam("eDraw", "Draw "..eName.." (E) Range", SCRIPT_PARAM_ONOFF, true)
	
	TristanaMenu:addSubMenu("["..myHero.charName.." - Misc Settings]", "misc")
		TristanaMenu.misc:addParam("aMP", "Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.misc:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
		TristanaMenu.misc:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	TristanaMenu:addTS(TargetSelector)
end

-- Last Hit Function --
function Init()	
	EnemyMinionManager = minionManager(MINION_ENEMY, 750, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinionManager = minionManager(MINION_JUNGLE, 750, myHero, MINION_SORT_MAXHEALTH_DEC)
end
function DrawCircleNextLvllasthit(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(0/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCirclelasthit(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvllasthit(x, y, z, radius, menu.width, color, 75)	
	end
end

-- Full Combo --
function FullCombo()
	 if Target == nil then return end

    if TristyMenu.combo.useQ then
        if Qlista and (GetDistance(Target) < TristyMenu.combo.rangeToQ) then
            CastSpell(_Q)
        end
    end

    if TristyMenu.combo.useW then
        if Wlista and (GetDistance(Target) < rangoW) then
            CastSpecialW()
        end
    end

    if TristyMenu.combo.useE == 2 then
        if Elista and (GetDistance(Target) < rangoE) then
            CastSpell(_E, Target)
        end
    end

    if TristyMenu.combo.useR then
        if Rlista and (GetDistance(Target) < rangoR) then
            CastSpell(_R, Target)
        end
    end
end

function Harass()

    if Target ~= nil then
        if (GetDistance(Target) < rangoE) then
            CastSpell(_E, Target)
        end
    end
end


function HarassCombo()
	if TristanaMenu.harass.harassOrbwalk then
		if Target then
			OrbWalking(Target)
		else
			moveToCursor()
		end
	end
	if Target then
		CastE(Target)
	end
end

function MinionHarass( )
	for _, minion in pairs(enemyMinions.objects) do
		local AaMinionDmg = getDmg("AD", minion, myHero) or 0
		local LicMinionDmg = licReady and (getDmg("LICHBANE", minion, myHero)) or 0
		local ShnMinionDmg = shnReady and (getDmg("SHEEN", minion, myHero)) or 0
		local HitMinionDmg = AaMinionDmg + LicMinionDmg + ShnMinionDmg
		if ValidTarget(minion) and Target then
			if minion.health <= HitMinionDmg and GetDistance(minion, Target) < 75 then
				myHero:Attack(minion)
			end
		end
	end
end

-- Jungle Farming --
function JungleClear()
	JungleMob = GetJungleMob()
	if TristanaMenu.jungle.jungleOrbwalk then
		if JungleMob then
			OrbWalking(JungleMob)
		else
			moveToCursor()
		end
	end
	if JungleMob then
		if TristanaMenu.jungle.jungleQ and GetDistance(JungleMob) <= eRange then CastSpell(_Q) end
		if TristanaMenu.jungle.jungleE and GetDistance(JungleMob) <= eRange then CastSpell(_E, JungleMob) end
	end
end

-- Get Jungle Mob --
function GetJungleMob()
        for _, Mob in pairs(JungleFocusMobs) do
                if ValidTarget(Mob, qRange) then return Mob end
        end
        for _, Mob in pairs(JungleMobs) do
                if ValidTarget(Mob, qRange) then return Mob end
        end
end

-- Casting W into Enemies --
function CastW(enemy)
	if not enemy then 
		enemy = Target 
	end
	if (countEnemiesAround(enemy) + 1) < TristanaMenu.ks.dontJump then
		if ValidTarget(enemy) and GetDistance(Target) <= wRange then
			if VIP_USER then
				if wPos then
					CastSpell(_W, wPos.x, wPos.z)
					return true
				end
			else
				local wPred = TargetPrediction(wRange, wSpeed, wDelay, wWidth)
				local wPrediction = wPred:GetPrediction(enemy)
				if wPrediction then
					CastSpell(_W, wPrediction.x, wPrediction.z)
					return true
				end
			end
		end
	end
	return false
end

function CastE(enemy)
	if not enemy then
		enemy = Target
	end
	if not eReady or (GetDistance(enemy) > eRange) then
		return false
	end
	if ValidTarget(enemy) then 
		if VIP_USER then
			Packet("S_CAST", {spellId = _E, targetNetworkId = enemy.networkID}):send()
			return true
		else
			CastSpell(_E, enemy)
			return true
		end
	end
	return false
end

function CastR(enemy)
	if not enemy then
		enemy = Target
	end
	if not rReady or (GetDistance(enemy) > rRange) then
		return false
	end
	if ValidTarget(enemy) then 
		if VIP_USER then
			Packet("S_CAST", {spellId = _R, targetNetworkId = enemy.networkID}):send()
			return true
		else
			CastSpell(_R, enemy)
			return true
		end
	end
	return false
end

function UseItems(enemy)
	if not enemy then
		enemy = Target
	end
	if ValidTarget(enemy) then
		if dfgReady and GetDistance(enemy) <= 600 then CastSpell(dfgSlot, enemy) end
		if hxgReady and GetDistance(enemy) <= 600 then CastSpell(hxgSlot, enemy) end
		if bwcReady and GetDistance(enemy) <= 450 then CastSpell(bwcSlot, enemy) end
		if brkReady and GetDistance(enemy) <= 450 then CastSpell(brkSlot, enemy) end
		if tmtReady and GetDistance(enemy) <= 185 then CastSpell(tmtSlot) end
		if hdrReady and GetDistance(enemy) <= 185 then CastSpell(hdrSlot) end
	end
end

function OnGainBuff(unit, buff)
	if Target then
		if buff and buff.name == "explosiveshotdebuff" then
			if unit == Target then
				if TristanaMenu.ks.predIgnite then
					local predictedHealth = ((unit.health - eDmg) + (unit.hpRegen))
					if wReady and GetDistance(unit) < wRange and predictedHealth < wDmg then
						CastW(Target)
					elseif rReady and GetDistance(unit) < rRange and predictedHealth < rDmg then
						CastR(unit)
					elseif iReady and rReady and GetDistance(unit) < iRange and predictedHealth < (iDmg + rDmg) then
						CastSpell(ignite, unit)
						CastR(unit)
					end
				end
			end
		end
	end
end

-- KillSteal function --
function KillSteal()
	if Target then
		if GetDistance(Target) <= eRange and eReady and Target.health <= (eDmg) then
			if myMana > eMana then
				CastE(Target)
			end
		elseif GetDistance(Target) <= wRange and wReady and Target.health <= (wDmg) then 
			if myMana > wMana then
				CastW(Target)
			end
		elseif GetDistance(Target) <= wRange and eReady and wReady and Target.health <= (wDmg + eDmg) then
			if myMana > (wMana + eMana) then
				CastE(Target)
			end
		elseif GetDistance(Target) <= wRange and wReady and rReady and Target.health <= (wDmg + rDmg) then
			if myMana > (wMana + rMana) then
				CastW(Target)
			end
		elseif GetDistance(Target) <= eRange and eReady and rReady and Target.health <= (eDmg + rDmg) then
			if myMana > (eMana + rMana) then
				CastE(Target)
				CastR(Target)
			end
		elseif GetDistance(Target) <= wRange and eReady and wReady and Target.health <= (wDmg + eDmg + rDmg) then
			if myMana > (wMana + eMana + rMana) then
				CastW(Target)
				CastE(Target)
				CastSpell(ignite, Target)
				CastR(Target)
			end
		elseif GetDistance(Target) <= rRange and rReady and Target.health <= rDmg then
			if myMana > rMana then
				CastR(Target)
			end
		end
	end
end

-- Auto Ignite --
function AutoIgnite()
	if Target then
		if Target.health <= iDmg and GetDistance(Target) <= 600 then
			if iReady then CastSpell(ignite, Target) end
		end
	end
end

-- Push Enemies --
function PushEnemies()	
	if TristanaMenu.ult.pushFromMe and not myHero.dead and isInDanger(myHero) then
		local enemy = getClosestEnemy(myHero)
		CastR(enemy)
	end
	for _, ally in pairs(allyHeroes) do
		if TristanaMenu.ult["pushFromAlly" .. ally.charName] and not ally.dead and myHero:GetDistance(ally) <= rRange + 200 and isInDanger(ally) then
			local enemy = getClosestEnemy(ally)
			if myHero:GetDistance(enemy) <= rRange then CastR(enemy) end
		end
	end	
end

-- Using our consumables --
function UseConsumables()
	if not InFountain() and not Recalling and Target ~= nil then
		if TristanaMenu.misc.aHP and myHero.health < (myHero.maxHealth * (TristanaMenu.misc.HPHealth / 100))
			and not (usingHPot or usingFlask) and (hpReady or fskReady)	then
				CastSpell((hpSlot or fskSlot)) 
		end
		if TristanaMenu.misc.aMP and myHero.mana < (myHero.maxMana * (TristanaMenu.farming.qFarmMana / 100))
			and not (usingMPot or usingFlask) and (mpReady or fskReady) then
				CastSpell((mpSlot or fskSlot))
		end
	end
end		

-- Damage Calculations --
function DamageCalculation()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			myMana = (myHero.mana)
			wMana = myHero:GetSpellData(_W).mana
			eMana = myHero:GetSpellData(_E).mana
			rMana = myHero:GetSpellData(_R).mana
			aDmg = getDmg("AD", enemy, myHero) or 0
			wDmg = (getDmg("W", enemy, myHero)) or 0
			eDmg = (getDmg("E", enemy, myHero)) or 0
			rDmg = rReady and (getDmg("R", enemy, myHero)) or 0
			dfgDmg = dfgReady and (getDmg("DFG", enemy, myHero)) or 0
            hxgDmg = hxgReady and (getDmg("HXG", enemy, myHero)) or 0
            bwcDmg = bwcReady and (getDmg("BWC", enemy, myHero)) or 0
            shnDmg = shnReady and (getDmg("SHEEN", enemy , myHero)) or 0
			licDmg = licReady and (getDmg("LICHBANE", enemy,myHero)) or 0
            iDmg = iReady and (getDmg("IGNITE",enemy,myHero)) or 0
            hitDmg = aDmg + shnDmg + licDmg
            itemsDmg = dfgDmg + hxgDmg + bwcDmg + iDmg + hitDmg
            maxDmg = itemsDmg + eDmg + wDmg + rDmg 
			if enemy.health <= (eDmg + wDmg + itemsDmg) then
				if eReady and wReady then
					if myMana > (eMana + wMana) then
						KillText[i] = 2
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 4
						colorText = ARGB(255,0,0,255)
					end
				else
					KillText[i] = 5
					colorText = ARGB(255,0,0,255)
				end
			elseif enemy.health <= (eDmg + wDmg + rDmg + itemsDmg) then
				if eReady and wReady and rReady then
					if myMana > (eMana + wMana + rMana) then
						KillText[i] = 3
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 4
						colorText = ARGB(255,0,0,255)
					end
				else
					KillText[i] = 5
					colorText = ARGB(255,0,0,255)
				end
			elseif enemy.health > (eDmg + wDmg + rDmg + itemsDmg) then
				KillText[i] = 1
				colorText = ARGB(255,0,255,0)
			end
		end
	end
end

function ArrangePrioritys()
    for i, enemy in pairs(enemyHeroes) do
        SetPriority(priorityTable.AD_Carry, enemy, 1)
        SetPriority(priorityTable.AP, enemy, 2)
        SetPriority(priorityTable.Support, enemy, 3)
        SetPriority(priorityTable.Bruiser, enemy, 4)
        SetPriority(priorityTable.Tank, enemy, 5)
    end
end

function ArrangeTTPrioritys()
	for i, enemy in pairs(enemyHeroes) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
        SetPriority(priorityTable.AP, enemy, 1)
        SetPriority(priorityTable.Support, enemy, 2)
        SetPriority(priorityTable.Bruiser, enemy, 2)
        SetPriority(priorityTable.Tank, enemy, 3)
	end
end

function SetPriority(table, hero, priority)
    for i=1, #table, 1 do
        if hero.charName:find(table[i]) ~= nil then
            TS_SetHeroPriority(priority, hero.charName)
        end
    end
end

-- Adjust Our Skills Range --
function UpdateRange()
	eRange = (((myHero.level * 9) - 9) + 600)
end 

-- Object Handling Functions --
function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("Global_Item_HealthPotion.troy") then
			if GetDistance(obj, myHero) <= 70 then
				usingHPot = true
				usingFlask = true
			end
		end
		if obj.name:find("Global_Item_ManaPotion.troy") then
			if GetDistance(obj, myHero) <= 70 then
				usingFlask = true
				usingMPot = true
			end
		end
		if obj.name:find("TeleportHome.troy") then
			if GetDistance(obj) <= 70 then
				Recalling = true
			end
		end
		if FocusJungleNames[obj.name] then
			table.insert(JungleFocusMobs, obj)
		elseif JungleMobNames[obj.name] then
            table.insert(JungleMobs, obj)
		end
	end
end

function OnDeleteObj(obj)
	if obj ~= nil then
			if obj.name:find("Global_Item_HealthPotion.troy") then
			if GetDistance(obj) <= 70 then
				usingHPot = false
				usingFlask = false
			end
		end
		if obj.name:find("Global_Item_ManaPotion.troy") then
			if GetDistance(obj) <= 70 then
				usingMPot = false
				usingFlask = false
			end
		end
		if obj.name:find("TeleportHome.troy") then
			if GetDistance(obj) <= 70 then
				Recalling = false
			end
		end
		for _, Mob in pairs(JungleMobs) do
			if obj.name == Mob.name then
				table.remove(JungleMobs, i)
			end
		end
		for _, Mob in pairs(JungleFocusMobs) do
			if obj.name == Mob.name then
				table.remove(JungleFocusMobs, i)
			end
		end
	end
end

-- Recalling Functions --
function OnRecall(hero, channelTimeInMs)
	if hero.networkID == player.networkID then
		Recalling = true
	end
end

function OnAbortRecall(hero)
	if hero.networkID == player.networkID then
		Recalling = false
	end
end

function OnFinishRecall(hero)
	if hero.networkID == player.networkID then
		Recalling = false
	end
end

-- Function OnDraw --
function OnDraw()
	--> Ranges
	if not TristanaMenu.drawing.mDraw and not myHero.dead then
		if wReady and TristanaMenu.drawing.wDraw then
			myPosV = Vector(myHero.x, myHero.z)
			mousePosV = Vector(mousePos.x, mousePos.z)
			if GetDistance(myPosV, mousePosV) < wRange - 50 then
				DrawCircle(mousePos.x, mousePos.y, mousePos.z, 250, 0x111111) 
			else
				finalV = myPosV+(mousePosV-myPosV):normalized()* (wRange - 60)
				DrawCircle(finalV.x, myHero.y, finalV.y, 250, 0x111111) 
			end		
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x0000FF)
		end
		if eReady and TristanaMenu.drawing.eDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x0000FF)
		end
	end
	if TristanaMenu.drawing.cDraw then
		for i = 1, heroManager.iCount do
        	local Unit = heroManager:GetHero(i)
        	if ValidTarget(Unit) then
        		local barPos = WorldToScreen(D3DXVECTOR3(Unit.x, Unit.y, Unit.z)) --(Credit to Zikkah)
				local PosX = barPos.x - 35
				local PosY = barPos.y - 10        
        	 	DrawText(TextList[KillText[i]], 13, PosX, PosY, colorText)
			end
		end
    end
end
  if menu.drawAA then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, myAArange, 1, ARGB(menu.colorAA[1],menu.colorAA[2],menu.colorAA[3],menu.colorAA[4]))	
	end
	if menu.drawlasthit then
		EnemyMinionManager:update()
		for i, minion in pairs(EnemyMinionManager.objects) do
			if minion ~= nil and minion.health < getDmg("AD",minion,myHero) then
				DrawCirclelasthit(minion.x, minion.y, minion.z, 50, ARGB(menu.color[1],menu.color[2],menu.color[3],menu.color[4]))
			end
		end
		JungleMinionManager:update()
		for i, minion in pairs(JungleMinionManager.objects) do
			if minion ~= nil and minion.health < getDmg("AD",minion,myHero) then
				DrawCirclelasthit(minion.x, minion.y, minion.z, 50, ARGB(menu.color[1],menu.color[2],menu.color[3],menu.color[4]))
			end
		end
	end
end

-- Manciuzz Orbwalker http://pastebin.com/jufCeE0e
------ Configuration -------
local OrbWalkerKey = 32
local OrbWalkerKeyAA = GetKey("Y")
 
---------------------
local SOWConfig, ts, MyTrueRange
local HitBoxSize = 65
local lastAttack = GetTickCount()
local walkDistance = 300
local lastWindUpTime = 0
local lastAttackCD = 0
 
--Channeling related
local lastAnimation = ""
local lastChanneling = 0
--
function OnLoad()
        MyTrueRange = myHero.range + HitBoxSize
        SOWConfig = scriptConfig("Simple Orb Walker 1.0", "simpleOrbWalker")
    SOWConfig:addParam("OrbWalker", "Orb Walker", SCRIPT_PARAM_ONKEYDOWN, false, OrbWalkerKey)
    if VIP_USER then SOWConfig:addParam("OrbWalkerAA", "Orb Walker - Auto Attack", SCRIPT_PARAM_ONKEYDOWN, false, OrbWalkerKeyAA) end
    SOWConfig:addParam("attackFocused", "Kite focused targets", SCRIPT_PARAM_ONOFF, false)
    SOWConfig:addParam("drawCircles", "Display circles", SCRIPT_PARAM_ONOFF, true)
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, MyTrueRange, DAMAGE_PHYSICAL, false)
        ts.name = "OrbWalker"
    SOWConfig:addTS(ts)
    PrintChat(" >> Simple Orb Walker 1.0 loaded!")
end
 
function OnProcessSpell(object, spell)
    if myHero.dead then return end
        local spellIsAA = (spell.name:lower():find("attack") or isSpellAttack(spell.name)) and not isNotAttack(spell.name)
    if object.isMe then
                if spellIsAA then
            lastAttack = GetTickCount() - GetLatency()/2
                        lastWindUpTime = spell.windUpTime*1000
                        lastAttackCD = spell.animationTime*1000
        elseif refreshAttack(spell.name) then
            lastAttack = GetTickCount() - GetLatency()/2 - lastAttackCD
        end
    end
end
 
function OnTick()
        MyTrueRange = myHero.range + HitBoxSize
        ts.range = MyTrueRange
        ts.targetSelected = SOWConfig.attackFocused
        ts:update()
        if myHero.dead or myHeroisChanneling() then return end
    if SOWConfig.OrbWalker or SOWConfig.OrbWalkerAA then
        if (SOWConfig.OrbWalker or SOWConfig.OrbWalkerAA) and ts.target ~= nil and GetDistance(ts.target) - HitBoxSize < MyTrueRange then
            if GetDistance(ts.target) <= 500 then
                                if GetInventoryItemIsCastable(3153) then
                                        CastItem(3153, ts.target)
                                elseif GetInventoryItemIsCastable(3144) then
                                        CastItem(3144, ts.target)
                                elseif GetInventoryItemIsCastable(3146) then
                                        CastItem(3146, ts.target)
                                end
                        end
                        if timeToShoot() then
                                myHero:Attack(ts.target)
                        elseif heroCanMove() then
                                moveToCursor()
                        end
                elseif SOWConfig.OrbWalkerAA then
                        if timeToShoot() then
                                local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*walkDistance
                                Packet("S_MOVE", {type = 7, x = moveToPos.x, y = moveToPos.z}):send()
                        elseif heroCanMove() then
                                moveToCursor()
                        end
        elseif heroCanMove() then
                        moveToCursor()
        end
    end
end
function heroCanMove()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end
function timeToShoot()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end
function moveToCursor()
        if GetDistance(mousePos) > 50 or lastAnimation == "Idle1" then
                local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*walkDistance
                myHero:MoveTo(moveToPos.x, moveToPos.z)
        end
end
function OnDraw()
    if not myHero.dead and SOWConfig.drawCircles then
                DrawCircle(myHero.x, myHero.y, myHero.z, MyTrueRange, 0x19A712)
        if ts.target ~= nil then
            for j=0, 5 do DrawCircle(ts.target.x, ts.target.y, ts.target.z, 50 + j*1.5, 0x00FF00) end
        end
    end
end
--Channeling related
function OnSendPacket(p)
        local packet = Packet(p)
        if packet:get('name') == 'S_CAST' and packet:get('sourceNetworkId') == myHero.networkID then
                local spellId = packet:get('spellId')
                if (myHero.charName == "Katarina" and spellId == _R) or (myHero.charName == "Nunu" and spellId == _R) then
                        lastChanneling = GetTickCount()
                end
        end
end
function OnAnimation(unit,animationName)
        if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end
function myHeroisChanneling()
        return (
                (GetTickCount() <= lastChanneling + GetLatency() + 50)
                or (myHero.charName == "Katarina" and lastAnimation == "Spell4")
                or (myHero.charName == "Nunu" and (lastAnimation == "Spell4" or lastAnimation == "Spell4_Loop"))
    )
end
--
function refreshAttack(spellName)
    return (
                --Blitzcrank
                spellName == "PowerFist"
                --Darius
                or spellName == "DariusNoxianTacticsONH"
                --Nidalee
                or spellName == "Takedown"
                --Sivir
                or spellName == "Ricochet"
                --Teemo
                or spellName == "BlindingDart"
                --Vayne
                or spellName == "VayneTumble"
                --Jax
                or spellName == "JaxEmpowerTwo"
                --Mordekaiser
                or spellName == "MordekaiserMaceOfSpades"
                --Nasus
                or spellName == "SiphoningStrikeNew"
                --Rengar
                or spellName == "RengarQ"
                --Wukong
                or spellName == "MonkeyKingDoubleAttack"
                --Yorick
                or spellName == "YorickSpectral"
                --Vi
                or spellName == "ViE"
                --Garen
                or spellName == "GarenSlash3"
                --Hecarim
                or spellName == "HecarimRamp"
                --XinZhao
                or spellName == "XenZhaoComboTarget"
                --Leona
                or spellName == "LeonaShieldOfDaybreak"
                --Shyvana
                or spellName == "ShyvanaDoubleAttack"
                or spellName == "shyvanadoubleattackdragon"
                --Talon
                or spellName == "TalonNoxianDiplomacy"
                --Trundle
                or spellName == "TrundleTrollSmash"
                --Volibear
                or spellName == "VolibearQ"
                --Poppy
                or spellName == "PoppyDevastatingBlow"
    )
end
function isSpellAttack(spellName)
        return (
                --Ashe
                spellName == "frostarrow"
                --Caitlyn
                or spellName == "CaitlynHeadshotMissile"
                --Quinn
                or spellName == "QuinnWEnhanced"
                --Trundle
                or spellName == "TrundleQ"
                --XinZhao
                or spellName == "XenZhaoThrust"
                or spellName == "XenZhaoThrust2"
                or spellName == "XenZhaoThrust3"
                --Garen
                or spellName == "GarenSlash2"
                --Renekton
                or spellName == "RenektonExecute"
                or spellName == "RenektonSuperExecute"
    )
end
function isNotAttack(spellName)
        return (
                --Shyvana
                spellName == "shyvanadoubleattackdragon"
                or spellName == "ShyvanaDoubleAttack"
                --MonkeyKing
                or spellName == "MonkeyKingDoubleAttack"
                --JarvanIV
                --or spellName == "JarvanIVCataclysmAttack"
                --or spellName == "jarvanivcataclysmattack"
    )
end

-- Spells/Items Checks --
function Checks()
	-- Updates Targets --
	TargetSelector:update()
	tsTarget = TargetSelector.target
	if ValidTarget(tsTarget) and tsTarget.type == "obj_AI_Hero" then
		Target = tsTarget
	else
		Target = nil
	end
	
	-- Finds Ignite --
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	end
	
	-- Slots for Items / Pots / Wards --
	rstSlot, ssSlot, swSlot, vwSlot =    GetInventorySlotItem(2045),
									     GetInventorySlotItem(2049),
									     GetInventorySlotItem(2044),
									     GetInventorySlotItem(2043)
	dfgSlot, hxgSlot, bwcSlot, brkSlot = GetInventorySlotItem(3128),
										 GetInventorySlotItem(3146),
										 GetInventorySlotItem(3144),
										 GetInventorySlotItem(3153)
	hpSlot, mpSlot, fskSlot =            GetInventorySlotItem(2003),
							             GetInventorySlotItem(2004),
							             GetInventorySlotItem(2041)
	znaSlot, wgtSlot =                   GetInventorySlotItem(3157),
	                                     GetInventorySlotItem(3090)
	tmtSlot, hdrSlot = 					 GetInventorySlotItem(3077),
										 GetInventorySlotItem(3074)
	licSlot, shnSlot =                   GetInventorySlotItem(3100),
	                                     GetInventorySlotItem(3057)

	
	-- Spells --									 
	qReady = (myHero:CanUseSpell(_Q) == READY)
	wReady = (myHero:CanUseSpell(_W) == READY)
	eReady = (myHero:CanUseSpell(_E) == READY)
	rReady = (myHero:CanUseSpell(_R) == READY)
	iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	
	-- Items --
	dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	hxgReady = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
	bwcReady = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
	brkReady = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
	znaReady = (znaSlot ~= nil and myHero:CanUseSpell(znaSlot) == READY)
	wgtReady = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
	licReady = (licSlot ~= nil and myHero:CanUseSpell(licSlot) == READY)
	shnReady = (shnSlot ~= nil and myHero:CanUseSpell(shnSlot) == READY)
		
	-- Pots --
	hpReady = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
	mpReady =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
	fskReady = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
	
	if VIP_USER then
		if Target and not Target.dead then
			wPos = ProdictW:GetPrediction(Target)
		end
	end

	-- Updates Minions --
	enemyMinions:update()
end