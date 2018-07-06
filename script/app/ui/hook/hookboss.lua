local hookBoss = class("hookBoss")
local bossUrl = {"YY_caocao","YY_liubei","YY_sunquan"}
function hookBoss:ctor(mapbg,bossKey,bossInfo)

	self.mapbg = mapbg
	self.pathId = bossInfo.positionId
	self.bossType = bossInfo.type
	self.bossKey = bossKey
	self.isDead = false
	self.isRun = false
	self.isClick = false
	local pathCfg = GameData:getConfData("explorepath")
	if pathCfg[self.pathId] then
		local postion = pathCfg[self.pathId].pos
		self:createBoss(postion)
		self:startMove()
	else
		logger_error("wrong boss path id",self.pathId)
	end
	self.moveDis = 100
end

function hookBoss:updateBoss(bossKey,bossInfo)

	self.pathId = bossInfo.positionId
	self.bossType = bossInfo.type
	self.bossKey = bossKey
	local pathCfg = GameData:getConfData("explorepath")
	if pathCfg[self.pathId] then
		if self.bossbg then
			self.bossbg:removeFromParent()
		end
		self.isDead = false
		local postion = pathCfg[self.pathId].pos
		self:createBoss(postion)
		if not self.isRun  then
			self:startMove()
		else
			local pos = {1,-1}
			self.moveDis = pos[math.random(1,2)]*self.moveDis
	        self:bossMove()
		end	
	end

end

function hookBoss:createBoss(postion)

	local bossCfg = GameData:getConfData("exploreboss")[tonumber(self.bossType)]
	local posX,posY = postion[1],postion[2]
	self.bossbg = ccui.ImageView:create('uires/ui_new/common/bg1_alpha.png')
	self.bossbg:setPosition(cc.p(posX,posY))
	self.bossbg:setScale9Enabled(true)
	self.bossbg:setContentSize(cc.size(80,105))
	self.bossbg:setLocalZOrder(10000-posY)
	self.bossbg:setScale(bossCfg.scale)
	local name = bossUrl[self.bossType] or 'YY_caocao'
	local url = "animation_littlelossy/thief/" .. name
    local bossAni = GlobalApi:createLittleLossyAniByName(name, url)
    bossAni:setName("boss")
    bossAni:setPosition(cc.p(40,13))
    bossAni:getAnimation():play('idle', -1, 1)
    local function movementFun(armature, movementType, movementID)
        if movementType == 1 then
            if movementID == "dead" then
                bossAni:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1),cc.CallFunc:create(function()

                    self.bossbg:removeFromParent()
                    self.bossbg = nil
                    hookheromgr:updateHookBoss()
                end)))
            elseif movementID == "hit" then
            	bossAni:getAnimation():play('idle', -1, 1)
            end
        end
    end
    bossAni:getAnimation():setMovementEventCallFunc(movementFun)
    self.bossbg:addChild(bossAni)
    self.mapbg:addChild(self.bossbg)
    self.bossbg:setOpacity(0)
    self.bossbg:runAction(cc.FadeIn:create(0.2))
    self.bossbg:setTouchEnabled(true)
    self.bossbg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            self.isClick = true
        elseif eventType == ccui.TouchEventType.ended then

        	if self.isDead then
        		return
        	end

        	local args = {
        		type = self.bossType,
        		positionId = self.pathId,
        	}
        	logger("self.bossKey",self.bossKey)
            MessageMgr:sendPost('fight_boss','auto_fight',json.encode(args),function (response)
				local code = response.code
		        local data = response.data
		        if code == 0 then
		        	
		        	local oldBoss = UserData:getUserObj():getHookBoss()
		        	local clickCnt = oldBoss[self.bossKey].curClick + 1
		        	if clickCnt >= bossCfg.maxClickCount then
		        		self.isDead = true
		        		self.isRun = false
		        		UserData:getUserObj():updateHookBoss(data.boss_birth)
		        		bossAni:getAnimation():play('dead',-1, -1)
		        	else  
		        		oldBoss[self.bossKey].curClick = data.boss_birth[self.bossKey].curClick
		        		bossAni:getAnimation():play('hit',-1, -1)
		        	end
		        	local awards = response.data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                    end
                    self:goldFly()
				end
			end)
        end
    end)

end

function hookBoss:goldFly()

	local test = {
		"user",
		"cash",
		80,
	}
	local goldScale = 1
    local award = DisplayData:getDisplayObj(test)
    local stype = award:getId()
    local function getResUrl()
        return 'uires/ui/res/'..stype..'.png'
    end

    local posX,posY = self.bossbg:getPositionX(),self.bossbg:getPositionY()
    local goldImg = ccui.ImageView:create()
    goldImg:loadTexture(getResUrl())

    local size = goldImg:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/thing_fall.plist")
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2,size.height*3/4))
    goldImg:addChild(particle)
    
    local size = self.bossbg:getContentSize()
    goldImg:setPosition(cc.p(posX,posY))
    goldImg:setTouchEnabled(true)
    goldImg:setScale(goldScale)

   	self.mapbg:addChild(goldImg,9999)
    local diffX = math.random(posX - 45,posX + 45)
    local diffY = math.random(posY + 25 + size.height/3,posY + 50 + size.height/3)
    local diffY1 = math.random(posY - 10 - size.height/2,posY + 2 - size.height/2)
    local diffX1
    if diffX > posX then
        diffX1 = math.random(diffX,posX + size.width)
    else
        diffX1 = math.random(posX - size.width,diffX)
    end

    local bezier = {
        cc.p(posX,posY),
        cc.p(diffX,diffY),
        cc.p(diffX1,diffY1)
    }
    local time = 0.4 + math.random(50,200)*0.001
    local bezierTo = cc.BezierTo:create(time, bezier)
    goldImg:setScale(goldScale/5*3)
    goldImg:setOpacity(0)
    goldImg:runAction(cc.FadeIn:create(0.2))
    goldImg:runAction(cc.Sequence:create(
        bezierTo,
        cc.CallFunc:create(function ()
            goldImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                local winSize = cc.Director:getInstance():getVisibleSize()
                local tab = goldImg:convertToWorldSpace(cc.p(0,0))
                goldImg:removeFromParent()
                local img = ccui.ImageView:create()
                img:loadTexture(getResUrl())
                img:setPosition(cc.p(tab.x,tab.y))
                img:setLocalZOrder(9999)
                img:setScale(goldScale*0.7*3)
                UIManager:addAction(img)
                local time = 0.01 * math.random(50,100)
                local pos = {
                    cash = cc.p(winSize.width - 640 ,winSize.height - 30),
                    xp = cc.p(80,winSize.height - 80),
                    food = cc.p(winSize.width - 200 ,winSize.height - 30)}
                local award = DisplayData:getDisplayObj(test)
                local id = award:getId()
                
                img:runAction(cc.Sequence:create(cc.MoveTo:create(time,pos[id]),cc.CallFunc:create(function()
                	self.isClick = false
                    img:removeFromParent()
                end)))
                img:runAction(cc.ScaleTo:create(time,0.1))
            end)))
        end))
    )
    goldImg:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.6,goldScale*0.7*3))
    )
end

function hookBoss:startMove()

	local waitTime = math.random(2,6)
	local action = cc.Sequence:create(cc.DelayTime:create(waitTime),cc.CallFunc:create(function ()
		local pos = {1,-1}
		self.moveDis = pos[math.random(1,2)]*self.moveDis
        self:bossMove()
	end))
	self.bossbg:runAction(action)
end

function hookBoss:bossMove()

	local boss = self.bossbg:getChildByName("boss")
	if not boss then
		return
	end

	if not self.isClick then
	    boss:getAnimation():play('run', -1, 1)
	    self.isRun = true
	    local posX = self.bossbg:getPositionX()
	    local posY = self.bossbg:getPositionY()
	    local endPosX = posX + self.moveDis
	    local dis =cc.pGetDistance(cc.p(endPosX,posY),cc.p(posX,posY))
	    local time = dis/10
	    if posX < endPosX then
	        self.bossbg:setScaleX(math.abs(self.bossbg:getScaleX()))
	    else
	        self.bossbg:setScaleX(-math.abs(self.bossbg:getScaleX()))
	    end

	    local ac = {'idle','idle01'}
	    self.bossbg:runAction(cc.Sequence:create(
	        cc.MoveTo:create(time,cc.p(endPosX,posY)),
	        cc.CallFunc:create(function()
	            boss:getAnimation():play(ac[math.random(1,2)], -1, -1)
	        end),
	        cc.DelayTime:create(math.random(3,5)),
	        cc.CallFunc:create(function()
	        	self.moveDis = -self.moveDis
	            self:bossMove()
	        end)
	    ))
	else
		self.bossbg:stopAllActions()
	end
end

return hookBoss