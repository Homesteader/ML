local hookbulletmgr = require("script/app/ui/hook/hookbulletmgr")
local hookenemy = class("hookenemy")
local enemyTab = {115,209,300}
function hookenemy:ctor(mapbg,enemyPos,target)
	self.mapbg = mapbg
	self.mode = nil
	self.mapid = nil
	self.state = "rest"
	self.target = target
	self.enemyPos = enemyPos

	local explorebaseCfg = GameData:getConfData("explorebase")
	self.exitTime = explorebaseCfg['ExistTime'].value
	self.lifeTime = explorebaseCfg['KillTime'].value
end

function hookenemy:update(enemyPos,target)

	self.mode = nil
	self.mapid = nil
	self.state = "rest"
	self.target = target
	self.enemyPos = enemyPos
end

function hookenemy:born()
	if not self.mode then
		self:create()
	end
end

function hookenemy:attack(target)
	
	self.state = "attack"
	local x,y = self:getPosition()
	local x1,y1 = target:getPosition()
	if x < x1 then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end	
	self.firePos = cc.p(x,y)

end

function hookenemy:hited()
	
end

function hookenemy:fire()

	local function callback()
		self.target:hited()
	end
	local dir = self:getDirection()
	hookbulletmgr:fireBullet(self.bulletId,self.firePos,self.target,dir,self.target.heroId,callback)
end

function hookenemy:die(callback)

	self.state = "dead"
	self.diecallback = callback
end

function hookenemy:getState()
	return self.state
end

function hookenemy:getPosition()
	return self.mode:getPosition()
end

function hookenemy:getDirection()
	return self.mode:getScaleX()
end

function hookenemy:setDirection(scaleX)
	self.mode:setScaleX(self.mode:getScaleX()*scaleX)
end

function hookenemy:spawn(callback)
	local spawnAct = cc.Spawn:create(cc.FadeIn:create(1),cc.JumpBy:create(0.5,cc.p(0,0),140,1))
	local act = cc.Sequence:create(spawnAct,cc.CallFunc:create(callback))
	self.mode:runAction(act)
end

function hookenemy:create()

	local enemyType = math.random(1,#enemyTab)
	local enemyid = enemyTab[enemyType]
	local emptyMap = {}
	for k,v in pairs(hookheromgr.hookMap) do
		if v.empty then
			emptyMap[#emptyMap+1] = v
		end
	end
	local enemypos = math.random(1,#emptyMap)
	self.mapid = emptyMap[enemypos].id
	hookheromgr.hookMap[self.mapid].empty = false
	local pos = emptyMap[enemypos].pos
	if self.enemyPos and self.enemyPos.x ~= -1 and self.enemyPos.y ~= -1 then
		pos = self.enemyPos
	end
	local soldierConf,modelConf = GlobalApi:getSoldierConf(enemyid)
	local url = modelConf.modelUrl.."_g"
	self:createMode(url,pos)

	--加载子弹
	local skillInfo = GameData:getConfData("skill")[soldierConf.skillGroupId]
	local bulletConf = GameData:getConfData("bullet")
	self.bulletId = skillInfo.bulletId
	if self.bulletId~= 0 then
		hookbulletmgr:addBullet(bulletConf[skillInfo.bulletId], skillInfo,self.target.heroId)
	end
end

function hookenemy:createMode(modelurl,pos)
	
	local spineAni = hookheromgr:createAniByName(modelurl, "animation_littlelossy/xiaobing/xiaobing", nil)
	spineAni:setScale(1.5)
	spineAni:getAnimation():play('idle', -1, 1)
	spineAni:setPosition(pos.x, pos.y)
	spineAni:setLocalZOrder(10000-pos.y-2)

	local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
		if frameEventName == "-1" and self.state == "attack" then
			self:fire()
		end
	end
	spineAni:getAnimation():setFrameEventCallFunc(frameFun)
	spineAni:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)

		if movementType == 2 and movementID == "idle" then
			if self.state == "attack" then 
				spineAni:getAnimation():play('attack', -1, 0)
			elseif self.state == "dead" then
				spineAni:getAnimation():play('dead', -1, 0)
			end
		elseif movementType == 1 and movementID == "attack" then
			spineAni:getAnimation():play('idle', -1, 1)	
		elseif movementType == 1 and movementID == "dead" then
			hookheromgr.hookMap[self.mapid].empty = true
			self.mode:removeFromParent()
			self.mode = nil
			if self.diecallback then
				self.diecallback()
			end
		end
	end)
	spineAni:setOpacity(0)
	self.mode = spineAni
	self.mapbg:addChild(spineAni)
end

return hookenemy