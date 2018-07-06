local hookbulletmgr = {
}
local BULLET_RENDER_ZORDER = 20000
local BULLET_PLIST_RES = "animation/battle_bullet/battle_bullet"
local function rotateBullet(bullet, startPos, endPos)    
    local pos = cc.pSub(endPos, startPos)
    local rotateRadians = cc.pToAngleSelf(pos)
    local rotateDegrees = math.deg( -1 * rotateRadians)
    bullet:setRotation(rotateDegrees)
end

function hookbulletmgr:init(mapbg)
	cc.SpriteFrameCache:getInstance():addSpriteFrames(BULLET_PLIST_RES .. ".plist")
	self.bulletPools = hookheromgr:createObjPool()
	self.mapbg = mapbg
	self.preloadList = {}
end

function hookbulletmgr:clear()
	self.bulletPools = nil
	self.mapbg = nil
	self.preloadList = nil
end


function hookbulletmgr:addBullet(bulletInfo, skillInfo,poolId)
	if skillInfo.bulletNum > 0 then
		local bulletId = bulletInfo.id
		local bulletObj = self:createBullet(bulletId)
		bulletObj.bulletNode:setVisible(false)
		self.bulletPools:push(poolId, bulletObj)
	end
end

function hookbulletmgr:createBullet(bulletId)

	local bulletObj = {}
	local bulletInfo = GameData:getConfData("bullet")[bulletId]
	if not bulletInfo then
		return
	end

	local bulletNode = nil
	if bulletInfo.bulletType == 3 then
		logger("连线型")
	else
		if bulletInfo.resType == 1 then
		-- 图片
			bulletNode = GlobalApi:createWithSpriteFrameName(bulletInfo.res .. ".png")
		else
		-- 动画
			bulletNode = hookheromgr:createAniByName(bulletInfo.res, "animation/battle_bullet/battle_bullet", nil)
		end

		--105特殊子弹
		if bulletInfo.id == 105 then
			bulletNode:setScale(5)
		else
			bulletNode:setScale(bulletInfo.scale/100)
		end
	end
	self.mapbg:addChild(bulletNode)

	bulletObj.sid = bulletId
	bulletObj.bulletInfo = bulletInfo
	bulletObj.bulletNode = bulletNode
	bulletObj.scaleX = bulletInfo.scale/100 
	return bulletObj
end

function hookbulletmgr:fireBullet(bulletId,firePos,target,dir,poolId,callback)

	if not bulletId then
		return
	end

	if bulletId == 0 then
		if callback then
			callback()
		end
		return
	end

	local scale = 1

	local bulletObj = self:getBullet(poolId,bulletId)
	local bulletInfo = bulletObj.bulletInfo

	local firePosX,firePosY = firePos.x,firePos.y
	local targetPosX,targetPosY = target:getPosition()
	local offSet = {
		x = 0,
		y = 10,
	}

	local bodyOffsetY = 0
	local hitPosX, hitPosY
	if dir == 1 then
		firePosX = firePosX + bulletInfo.fireOffsetX
		hitPosX = targetPosX + bulletInfo.hitOffsetX
	else
		firePosX = firePosX - bulletInfo.fireOffsetX
		hitPosX = targetPosX - bulletInfo.hitOffsetX
	end

	firePosY = firePosY + bulletInfo.fireOffsetY+offSet.y
	hitPosY = targetPosY + bulletInfo.hitOffsetY + bodyOffsetY
	if bulletInfo.bulletType ~= 4 then -- 非光环型子弹
		hitPosX = hitPosX + offSet.x
		hitPosY = hitPosY + offSet.y
	end
	if bulletInfo.targetOffset > 0 then
		local radian = cc.pGetAngle(cc.p(0, 0), cc.p(hitPosX - firePosX, hitPosY - firePosY))
		local rotatePosX = bulletInfo.targetOffset*math.cos(radian)
		local rotatePosY = bulletInfo.targetOffset*math.sin(radian)
		hitPosX = hitPosX + rotatePosX
		hitPosY = hitPosY + rotatePosY
	end
	local targetPos = {
		x = hitPosX,
		y = hitPosY,
	}
	local px = hitPosX - firePosX
	local py = hitPosY - firePosY
	bulletObj.bulletNode:setPosition(firePosX, firePosY)
	local bulletInfo = bulletObj.bulletInfo
	if bulletInfo.bulletType == 2 then -- 抛物线型子弹
		local bezier1,midX
		if firePosX > targetPosX then
			midX = (firePosX - targetPosX)/2 + 	targetPosX
		else
			midX = (targetPosX - firePosX)/2 + firePosX
		end
		bezier1 = {
			cc.p(midX, firePosY),
			firePos,
   	    	targetPos        
   	    }

		local l = cc.pGetDistance(firePos, bezier1[1])
		l = l + cc.pGetDistance(targetPos, bezier1[1])
		local t = l/bulletInfo.speed
		local bezierAction1 = cc.ArrowPathBezier:create(t, bezier1, true)
		local act
		if bulletInfo.delayTime > 0 then
			act = cc.Sequence:create(bezierAction1, cc.CallFunc:create(function ()
				if callback then
					callback()
				end
			end), cc.DelayTime:create(bulletInfo.delayTime/1000), cc.CallFunc:create(function ()
				self:putBack(bulletObj)
			end))
		else
			act = cc.Sequence:create(bezierAction1, cc.CallFunc:create(function ()
				if callback then
					callback()
				end
				self:putBack(bulletObj)
			end))
		end
		bulletObj.bulletNode:runAction(act)
		rotateBullet(bulletObj.bulletNode, firePos, bezier1[1])
		bulletObj.bulletNode:setLocalZOrder(10000)
	elseif bulletInfo.bulletType == 1 then -- 直线型子弹

		if bulletInfo.autoRotation > 0 then
			bulletObj.bulletNode:setScaleX(dir*bulletObj.scaleX)
			bulletObj.bulletNode:setRotation(-dir*math.deg(math.atan2(py, px*dir)))
		end
		local t = math.sqrt(math.pow(px, 2)+math.pow(py, 2))/tonumber(bulletInfo.speed)
		local act
		if bulletInfo.delayTime > 0 then
			act = cc.Sequence:create(cc.MoveTo:create(t, targetPos), cc.CallFunc:create(function ()
				if callback then
					callback()
				end
			end), cc.DelayTime:create(bulletInfo.delayTime/1000), cc.CallFunc:create(function ()
				self:putBack(bulletObj)
			end))
		else
			act = cc.Sequence:create(cc.MoveTo:create(t, targetPos), cc.CallFunc:create(function ()
				if callback then
					callback()
				end
				self:putBack(bulletObj)
			end))
		end
		bulletObj.bulletNode:runAction(act)
		rotateBullet(bulletObj.bulletNode, firePos, targetPos)
		bulletObj.bulletNode:setLocalZOrder(10000)
	end
end

function hookbulletmgr:putBack(bulletObj)
	if bulletObj.bulletInfo.resType ~= 1 then
		xx.Utils:Get():pauseArmatureAnimation(bulletObj.bulletNode)
	end
	bulletObj.bulletNode:setVisible(false)
	self.bulletPools:push(bulletObj.sid, bulletObj)
end


function hookbulletmgr:getBullet(poolId,bulletId)
	local bulletObj = self.bulletPools:pop(poolId)
	if bulletObj == nil then
		bulletObj = self:createBullet(bulletId)
	else
		bulletObj.bulletNode:setVisible(true)
	end
	if bulletObj.bulletInfo.resType ~= 1 then
		bulletObj.bulletNode:getAnimation():playWithIndex(0, -1, -1)
	end
	return bulletObj
end

return hookbulletmgr
