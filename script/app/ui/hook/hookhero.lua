local hookbulletmgr = require("script/app/ui/hook/hookbulletmgr")
local hookenemy = require("script/app/ui/hook/hookenemy")
local hookhero = class("hookhero")
local herohomePos = {
	{x = 2285,y = 948},
	{x = 2029,y = 883},
	{x = 2206,y = 777},
	{x = 1943,y = 839},
	{x = 2123,y = 731},
	{x = 1860,y = 790},
	{x = 2037,y = 686},
}

local function getDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
end
local modeScale = 0.6
local attackDis = 85
local talkRes = "uires/ui/battle/bg_talk_7.png"
local words = {"尼玛!","天气还不错!","蓝瘦,香菇!","看,有灰机！","MD渣渣","谁丑谁尴尬","宝宝心里苦","一亿小目标"}
local speed = 70
function hookhero:ctor(heroId,index,mapbg,name)

	self.heroId = heroId
	self.heroname = name
	self.enermyCount = 0
	self.enemyTotal = 0
	self.modeObj = nil

	self.homepos = herohomePos[index]
	self.heropos = nil
	self.heroIndex = index
	self.mapbg = mapbg
	self.state = "rest"						   --状态
	self.isfinishIdle = false 				   --巡逻休息等待1s的标志

	self.path = {}

	self.attackTimer = false 					--攻击计时器
	self.restTimer = false 						--休息计时器
	self.patrolTimer = false

	self.totalBlood = 0
	self.baseInfo = GameData:getConfData("combatherotemplate")[self.heroId]

	self.pathCfg = GameData:getConfData("explorepath")
	self.explorebaseCfg = GameData:getConfData("explorebase")

	self.totalTime = 0						    
	self.attacktime = 0
	self.restTime = self.explorebaseCfg["RestTime"].value						--休息时间
	self.patrolTime = self.explorebaseCfg["PatrolTime"].value					--巡逻时间
end

function hookhero:updateRole(heroId,index,name)

	if self.heroId == heroId then
		return
	end

	self.heroId = heroId
	self.heroname = name
	self.baseInfo = GameData:getConfData("combatherotemplate")[self.heroId]
	self.heroIndex = index
	self:born(true)
end

function hookhero:born(update)

	self.heropos = herohomePos[self.heroIndex]
	local heroPos,enemyPos,enemyCount,state,restTime,attacktime = self:getUserDefaultData(self.heroIndex)
	if heroPos == nil then
  
		--随机敌人数量
		local maxCount = self.explorebaseCfg["OnceKillMin"].value
		local minCount = self.explorebaseCfg["OnceKillMin"].value
		self.enermyCount = math.random(minCount,maxCount)
		self.enemyTotal = self.enermyCount
		state = "searchTarget"
	else
		self.enermyCount = tonumber(enemyCount[1])
		self.enemyTotal = tonumber(enemyCount[2])
		self.restTime = tonumber(restTime)
		self.attacktime = tonumber(attacktime)
		if state ~= "rest" then
			self.heropos = heroPos
		end
		--logger(self.enermyCount,self.enemyTotal,self.restTime,self.attacktime)
	end

	self.totalBlood = self.enemyTotal + 1
	self:createMode(update)
	self:initModePos()
	self:createEnemy(enemyPos,update)
	if state == "patrol" or state == "patroling" then
		state = "patrol"
	end	
	self:setState(state)
end

function hookhero:initModePos()

	self.modeObj:setPosition(self.heropos.x, self.heropos.y)
	self.modeObj:getAnimation():play('idle', -1, 1)
	self:setDirection(-1)
	self.modeObj:setLocalZOrder(10000-self.heropos.y)
	local barbg = self.modeObj:getChildByName("barbg")
	local bar = barbg:getChildByName("bar")
	local percentage = (self.enermyCount+1)/self.totalBlood
	bar:setPercentage(100*percentage)
	bar:setOpacity(0)
    barbg:setOpacity(0)
	self.modeObj:runAction(cc.FadeIn:create(0.5))
end

function hookhero:setEnemy()

	self.totalTime = self.enemy.exitTime
	if self.attacktime <= 0 then
		self.attacktime = self.enemy.lifeTime
	end

end

--找到路径Id组
function hookhero:findPath(startPathId,targetPathId)

	local startPosX,startPosY = self.pathCfg[startPathId].pos[1],self.pathCfg[startPathId].pos[2]
	local targetPosX,targetPosY = self.pathCfg[targetPathId].pos[1],self.pathCfg[targetPathId].pos[2]

    local curNode,valueG,valueH,valueF
    valueG = 0																--出发点到当前方块的移动量
    valueH = getDistance(startPosX,startPosY,targetPosX,targetPosY)			--当前到目标的移动量
    valueF = valueH + valueG												--两者之和

    local closeTable = {}
    local openTable = {}
    local closeIndex = 0

    openTable[startPathId] = {pathId = startPathId, valueG = valueG,valueH = valueH, valueF = valueF,parent = nil}
    local openCount = 1
    while openCount ~= 0 do

        local minF = 1000000
        for k,v in pairs(openTable) do
            if v.valueF < minF then
                minF = v.valueF
                curNode = v
            end
        end

        closeIndex = closeIndex + 1
        closeTable[closeIndex] = curNode
        openTable[curNode.pathId] = nil
        openCount = openCount -1
        if curNode.pathId == targetPathId then
            break
        end

        local around = self.pathCfg[curNode.pathId].around
        local findSuceess = false
        for i=1,#around do

            local roundId = around[i]
            if roundId == targetPathId then
                closeIndex = closeIndex + 1
                closeTable[closeIndex] = {pathId = roundId,valueG = 0,valueH = 0,valueF = valueG,parent = curNode.pathId }
                findSuceess = true 
                break
            end

            local inCloseTab = false
            for k,v in pairs(closeTable) do
                if v.pathId ==  roundId then
                    inCloseTab = true
                    break
                end
            end 

            if not inCloseTab then
                --不在开启列表中
                local aroundPosX,aroundPosY = self.pathCfg[roundId].pos[1],self.pathCfg[roundId].pos[2]
                if openTable[roundId] == nil then
                    local valueG = getDistance(aroundPosX,aroundPosY,startPosX,startPosY)
                    local valueH = getDistance(aroundPosX,aroundPosY,targetPosX,targetPosY)
                    local valueF = valueG + valueH
                    openTable[roundId] = {}
                    openTable[roundId] = {pathId = roundId,valueG = valueG,valueH = valueH,valueF = valueF,parent = curNode.pathId }
                    openCount = openCount + 1
                else
                	local curPosX,curPosY = self.pathCfg[curNode.pathId].pos[1],self.pathCfg[curNode.pathId].pos[2]
                    local valueG = getDistance(aroundPosX,aroundPosY,curPosX,curPosY) + curNode.valueG
                    if valueG < openTable[roundId].valueG then
                        openTable[roundId].valueG = valueG
                        openTable[roundId].valueF = valueG + openTable[roundId].valueH
                        openTable[roundId].parent = curNode.pathId
                    end  
                end
            end

        end

        if findSuceess then
            break
        end

        if openCount == 0 and curNode.pathId ~= targetPathId then

            local str = GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT41")
            promptmgr:showSystenHint(self.heroname..str, COLOR_TYPE.RED)  
            logger_error(self.heroname,startPathId,targetPathId)
            return false
        end
    end

    
    local pathtab = {}       
   	pathtab[1] = closeTable[#closeTable].pathId
    local index = 1
    local p = closeTable[#closeTable].parent
    for i=#closeTable-1,1,-1 do
        if p == closeTable[i].pathId then
            index = index + 1
            p = closeTable[i].parent
            pathtab[index] = closeTable[i].pathId
        end
    end

    self.path = {}
    for i=#pathtab,1,-1 do
    	self.path[#self.path+1] = pathtab[i]
    end
end

--找到距传入坐标最近的路径点Id
function hookhero:getPathId(x,y)

	local minDis = 3000
	local pathId
	for i=1,#self.pathCfg do
		local posX,posY = self.pathCfg[i].pos[1],self.pathCfg[i].pos[2]
		local dis = getDistance(x,y,posX,posY)
		if dis < minDis then
			minDis = dis
			pathId = i
		end
	end

	return pathId
end

function hookhero:findTarget()

	local x1,y1 = self:getPosition()
	local x2,y2 = self.enemy:getPosition()

	local startPathId = self:getPathId(x1,y1)
	local targetPathId = self:getPathId(x2,y2)
	self:findPath(startPathId,targetPathId)
	self:moveOnPath(1)
end

function hookhero:moveOnPath(targetPathIndex)

	if not self.path[targetPathIndex] then

		local x1,y1 = self:getPosition()
		local x2,y2 = self.enemy:getPosition()
		local d = getDistance(x1, y1, x2, y2)
		local attackRange = 85
		if self.baseInfo.attackType == 2 then
			attackRange = attackRange + attackDis
		end

		local ty = y2
		local tx
		if x1 <= x2 then
			tx = x2 - attackRange
		else
			tx = x2 + attackRange
		end
		if x1 <= tx then
			self:setDirection(1)
		else
			self:setDirection(-1)
		end

		local function callback()

			local s = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
				self:setState("patrol")
			end))
			self.modeObj:runAction(s)
			self.modeObj:getAnimation():play('idle', -1, 1)
		end

		local time = getDistance(x1, y1, tx, ty)/speed
		self:moveToTarget(cc.p(tx, ty), time,callback)
		return
	end

	local x1,y1 = self:getPosition()
	local pathId = self.path[targetPathIndex]
	local pathPosX,pathPosY = self.pathCfg[pathId].pos[1],self.pathCfg[pathId].pos[2]
	if x1 <= pathPosX then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end

	local nextPathIdx = targetPathIndex+1
	local time = getDistance(x1,y1,pathPosX,pathPosY)/speed
	local function callback()
		self:moveOnPath(nextPathIdx)
	end
	self:moveToTarget(cc.p(pathPosX,pathPosY),time,callback)
	self.modeObj:getAnimation():play('run', -1, 1)
end

function hookhero:moveToTarget(pos, time,func)
	local moveAct = cc.Sequence:create(cc.MoveTo:create(time,pos),cc.CallFunc:create(function ()
		func()
	end))
	self.modeObj:runAction(moveAct)
end

function hookhero:gohome()
	--logger_error(self.heroname.." go home")
	self:setState("rest")
	local sequence = cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function ()
		self:initModePos()		
	end))
	self.modeObj:runAction(sequence)

end

function hookhero:createEnemy(enemyPos)

	if self.enemy then
		return
	end

	self.enemy = hookenemy.new(self.mapbg,enemyPos,self)
	
	self.enemy:born()
	self:setEnemy()
end

function hookhero:hited()
	self.modeObj:getAnimation():play('hit', -1, 0)
	local hurtTx = self.modeObj:getChildByName("hurt_tx")
	local hurtnum = math.random(1,10)
	hurtTx:setString(-hurtnum)
	hurtTx:setOpacity(255)

	local barbg = self.modeObj:getChildByName("barbg")
	local bar = barbg:getChildByName("bar")
	barbg:setOpacity(255)
	bar:setOpacity(255)
	local act = cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
		hurtTx:setOpacity(0)
	end))
	hurtTx:runAction(act)
	local act1 = cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
		barbg:setOpacity(0)
	end))
	barbg:runAction(act1)
	local act2 = cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
		bar:setOpacity(0)
	end))
	bar:runAction(act2)
end

function hookhero:patrol()
	
	self.patrolTimer = true
	self.patrolTime = math.random(8,15)
	self.patrolDis = 150
	local x1,y1 = self:getPosition()
	local x2,y2 = self.enemy:getPosition()
	if x1 < x2 then
		self.patrolDis = -self.patrolDis
	end
	self.isfinishIdle = true
end

--开启巡逻
function hookhero:patroling()

	local x1,y1 = self:getPosition()
	local x2,y2 = x1+self.patrolDis,y1
	local distance = getDistance(x1, y1, x2, y2)
	local costTime = distance/speed
	if x1 < x2 then
		self:setDirection(1)
	else
		self:setDirection(-1)

	end

	local talkbg = self.modeObj:getChildByName("talkbg")
	talkbg:setVisible(false)

	self.modeObj:getAnimation():play('run', -1, 1)
	self.modeObj:setLocalZOrder(10000-y1)
	local action = cc.Sequence:create(cc.MoveTo:create(costTime,cc.p(x2,y2)),cc.CallFunc:create(function ()
		self:setState("patrol",true)
		self.modeObj:getAnimation():play('idle', -1, 1)
		self.isfinishIdle = true
		self.patrolDis = -self.patrolDis
		local talktext = words[math.random(1,#words)]
		local text = talkbg:getChildByName("text")
		text:setString(talktext)
		local num = math.random(1,3)
		talkbg:setVisible(num==1)
		if not self.patrolTimer then
			self:setState("check")
		end
	end))
	self.modeObj:runAction(action)
end

function hookhero:checkTarget()

	local x1,y1 = self:getPosition()
	local x2,y2 = self.enemy:getPosition()
	local d = getDistance(x1, y1, x2, y2)
	local attackRange = 85
	if self.baseInfo.attackType == 2 then
		attackRange = attackRange + attackDis
	end

	local talkbg = self.modeObj:getChildByName("talkbg")
	talkbg:setVisible(false)

	if x1 < x2 then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end

	if d > attackRange then
		local ty = y2
		local tx
		if x1 <= x2 then
			tx = x2 - attackRange
		else
			tx = x2 + attackRange
		end
		local distance = getDistance(x1, y1, tx, ty)
		local costTime = distance/speed
		local function callback()
			self:setState("attack")
		end
		self.modeObj:getAnimation():play('run', -1, 1)
		local moveAct = cc.Sequence:create(cc.MoveTo:create(costTime,cc.p(tx, ty)),cc.CallFunc:create(callback))
	    self.modeObj:runAction(moveAct)
	else
		self:setState("attack")
	end

end

function hookhero:attack()

	local x1,y1 = self:getPosition()
	local x2,y2 = self.enemy:getPosition()

	if x1 < x2 then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end

	local function callback()
		self.attackTimer = true
		self.enemy:attack(self)	
		local x,y = self:getPosition()
		local x1,y1 = self.enemy:getPosition()
		self.firePos = cc.p(x,y)
	end
	self.enemy:spawn(callback)
end

function hookhero:fireBullet()
	local function callback()
		self.enemy:hited()
	end
	local dir = self:getDirection()

	hookbulletmgr:fireBullet(self.bulletId,self.firePos,self.enemy,dir,self.bulletId,callback)
end

function hookhero:spawnGold(x,y)

	if not self.gold then
		self.gold = GlobalApi:createLittleLossyAniByName("goldmine_exploiting2")
	    self.gold:getAnimation():playWithIndex(0, -1, 1)
		self.mapbg:addChild(self.gold)
	end
	self.gold:setPosition(x, y+60)
	self.gold:setLocalZOrder(10000-y-1)
	self.gold:setVisible(true)

	local JumpBy  = cc.JumpBy:create(0.5,cc.p(0,0),100,1)	
	local act = cc.Sequence:create(JumpBy,cc.CallFunc:create(function ()
		self.gold:setVisible(false)
	end))
	self.gold:runAction(act)
end

function hookhero:victory()

	self.enermyCount = self.enermyCount - 1
	self.modeObj:getAnimation():play('shengli', -1, 0)
	local barBg = self.modeObj:getChildByName("barbg")
	local bar = barBg:getChildByName("bar")
	local percentage = (self.enermyCount+1)/self.totalBlood
	bar:setPercentage(percentage*100)

end

function hookhero:getDirection()
	return self.modeObj:getScaleX()
end

function hookhero:setDirection(scaleX)

	self.modeObj:setScaleX(scaleX*modeScale)
	local barbg = self.modeObj:getChildByName("barbg")
	barbg:setScaleX(0.25*scaleX)
	local hurtTx = self.modeObj:getChildByName("hurt_tx")
	hurtTx:setScaleX(scaleX*2)
	local talkbg = self.modeObj:getChildByName("talkbg")
	talkbg:setScaleX(scaleX*2)
end

function hookhero:getPosition()
	return self.modeObj:getPosition()
end

function hookhero:setState(state,notexecuteFunc)

	self.state = state
	if not notexecuteFunc then
		self:changeState(state)
	end
	self:setUserDefaultData()
end

function hookhero:changeState(state)
	
	if state == "searchTarget" then
		self:findTarget()
	elseif state == "patrol" then
		self:patrol()
	elseif state == "patroling" then
		self:patroling()
	elseif state == "check" then
		self:checkTarget()
	elseif state == "attack" then
		self:attack()
	elseif state == "rest" then
		self.restTimer = true
		self.heropos = herohomePos[self.heroIndex]

		if self.enermyCount <= 0 then
			local maxCount = self.explorebaseCfg["OnceKillMin"].value
			local minCount = self.explorebaseCfg["OnceKillMin"].value
			self.enermyCount = math.random(minCount,maxCount)
			self.enemyTotal = self.enermyCount
			self.totalBlood = self.enemyTotal + 1
		end

		if self.restTime <=0 then
			self.restTime = self.explorebaseCfg["RestTime"].value
		end
		
	end
end

function hookhero:setUserDefaultData()

	local x,y = self:getPosition()
	local x1,y1 = -1,-1
	if "rest" ~= self.state then
		x1,y1 = self.enemy:getPosition()
	end
	local value = x..","..y.."|"..x1..","..y1.."|" ..self.enermyCount..","..self.enemyTotal.."|"..self.state.."|"..self.restTime.."|"..self.attacktime
	local key = UserData:getUserObj():getUid().."index"..self.heroIndex
	cc.UserDefault:getInstance():setStringForKey(key,value)
end

function hookhero:getUserDefaultData(key)

	key = UserData:getUserObj():getUid().."index"..key
	local userInfoStr = cc.UserDefault:getInstance():getStringForKey(key)
	local userInfo = string.split(userInfoStr, '|')
	if not next(userInfo) then
		return
	else
		if #userInfo ~= 6 then
			return
		end
		local param1 = string.split(userInfo[1], ',')
		local param2 = string.split(userInfo[2], ',')
		local enemyCount = string.split(userInfo[3], ',')
		local state = userInfo[4]
		local resttime = userInfo[5]
		local attacktime = userInfo[6]
		
		local heroPos = {x = tonumber(param1[1]),y = tonumber(param1[2])}
		local enemyPos = {x = tonumber(param2[1]),y = tonumber(param2[2])}
		return heroPos,enemyPos,enemyCount,state,resttime,attacktime
	end

end

function hookhero:update()

	if self.attackTimer then
		self.attacktime = self.attacktime -1
		if self.attacktime <= 0 then
			self.attackTimer = false
			local x,y = self.enemy:getPosition()
			local function enemyDiefinish()
				self:spawnGold(x,y)
				self:victory()
				self.enemy = nil
			end
			self.enemy:die(enemyDiefinish)
		end
	end

	if self.restTimer then
		self.restTime = self.restTime - 1
		if self.restTime <= 0 then
			self.restTimer = false
			self:createEnemy()
			self:setState("searchTarget")
		end
	end

	if self.patrolTimer then
		self.patrolTime = self.patrolTime - 1
		if self.patrolTime <= 0 then
			self.patrolTimer = false
		end
	end

	if self.restTimer or self.attackTimer then 
		self:setUserDefaultData()
	end
end

function hookhero:createMode(update)

	if update then
		local roleObj = self.mapbg:getChildByName("role"..self.heroIndex)
		if roleObj then
			self.mapbg:removeChildByName("role"..self.heroIndex)
		end
	end
	local _,heroCombatInfo,heroModelConf = GlobalApi:getHeroConf(self.heroId)
	local spineAni
	if string.sub(heroModelConf.modelUrl, 1, 4) == "nan_" then
		spineAni = hookheromgr:createAniByName(heroModelConf.modelUrl, "animation/nan/nan", self.changeEquipObj)
	else
		spineAni = hookheromgr:createAniByName(heroModelConf.modelUrl, nil, self.changeEquipObj)
	end
    local shadow = spineAni:getBone(heroModelConf.modelUrl)
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
	local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
		if frameEventName == "-1" and self.enemy and self.enemy:getState() ~= "dead" and self.state == "attack" then
			self:fireBullet()
		end
	end
	spineAni:getAnimation():setFrameEventCallFunc(frameFun)
	spineAni:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)

		if movementType == 2 and movementID == "idle" then
			if self.state == "searchTarget" then 
				spineAni:getAnimation():play('run', -1, 1)
			elseif self.state == "attack" then 
				spineAni:getAnimation():play('attack', -1, 0)
			elseif self.state == "patrol" then
				if not self.isfinishIdle then
					return
				end
				
				self.isfinishIdle = false
				local s = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
					self.isfinishIdle = true
					self:setState("patroling")
				end))
				spineAni:runAction(s)
			end
		elseif movementType == 1 and movementID == "attack" then
			spineAni:getAnimation():play('idle', -1, 1)
		elseif movementType == 2 and movementID == "run" then
			if self.state == "attack" then
				spineAni:getAnimation():play('idle', -1, 1)
			elseif self.state == "searchTarget" then
				local posY = spineAni:getPositionY()
				spineAni:setLocalZOrder(10000-posY)
				self:setUserDefaultData()
			elseif self.state == "patrol" then
				spineAni:getAnimation():play('idle', -1, 1)
				local posY = spineAni:getPositionY()
				spineAni:setLocalZOrder(10000-posY)
				self.isfinishIdle = true
			end
		elseif movementType == 1 and movementID == "hit" then
			spineAni:getAnimation():play('attack', -1, 0)
		elseif movementType == 1 and movementID == "shengli" then
			if self.enermyCount <= 0 then
				spineAni:getAnimation():play('idle', -1, 1)
				self:gohome()
			else
				self:createEnemy()
				self:setState("searchTarget")
			end
		end
	end)

	self.modeObj = spineAni
	self.modeObj:setScale(modeScale)
	self:creattalk(heroModelConf.hpBarHeight)
	self:hurtnumber(heroModelConf.hpBarHeight)
	self:creatbloodBar(heroModelConf.hpBarHeight)
	self.modeObj:setName("role"..self.heroIndex)
	self.mapbg:addChild(self.modeObj)
	
    --加载子弹
    local skillGroupConf= GameData:getConfData("skillgroup")[heroCombatInfo.skillGroupId[1]]
	local skillInfo = GameData:getConfData("skill")[skillGroupConf.baseSkill]
	local bulletConf = GameData:getConfData("bullet")
	self.bulletId = skillInfo.bulletId
	if self.bulletId ~= 0 then
		hookbulletmgr:addBullet(bulletConf[skillInfo.bulletId], skillInfo,self.bulletId)
	end
end

function hookhero:hurtnumber(barheight)

	local hurtTx = cc.LabelBMFont:create()
	hurtTx:setFntFile("uires/ui/number/font1_negative.fnt")
	hurtTx:setOpacity(0)
	barheight = barheight*3
    hurtTx:setPosition(0,barheight+20)
    hurtTx:setName("hurt_tx")
    hurtTx:setScale(2)
    self.modeObj:addChild(hurtTx)

end

function hookhero:creatbloodBar(barheight)
	barheight = barheight*2.5
	local barbg = ccui.ImageView:create("uires/ui/common/bar_bg_1.png")
    barbg:setAnchorPoint(cc.p(0.5, 0))
    barbg:setPosition(cc.p(0,barheight))
    barbg:setScaleX(0.25)
    barbg:setScale9Enabled(true)
    local bar = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/bar_1.png"))
    bar:setAnchorPoint(cc.p(0, 0))
    bar:setPosition(cc.p(0,0))
    bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    bar:setMidpoint(cc.p(0, 0))
    bar:setBarChangeRate(cc.p(1, 0))
    local percentage = (self.enermyCount+1)/self.totalBlood
    bar:setPercentage(percentage*100)
    bar:setName("bar")
    barbg:addChild(bar)
    barbg:setName("barbg")
    self.modeObj:addChild(barbg)
end

function hookhero:creattalk(barheight)

	barheight = barheight*2
	local talkbg = ccui.ImageView:create(talkRes)
	talkbg:setAnchorPoint(cc.p(0.5, 0))
	talkbg:setPositionY(barheight)
	local text = ccui.Text:create()
	text:setFontName("font/gamefont.ttf")
	text:setFontSize(24)
	text:setName("text")
	text:setColor(COLOR_TYPE.BLACK)
	local talkbgSize = talkbg:getContentSize()
	text:setPosition(talkbgSize.width*0.5,40)
	talkbg:addChild(text)
	talkbg:setName("talkbg")
	talkbg:setScale(2)
	talkbg:setVisible(false)
	self.modeObj:addChild(talkbg)
end

return hookhero