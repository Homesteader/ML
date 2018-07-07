local KabalaTreeNpc = class("KabalaTreeNpc")

function KabalaTreeNpc:ctor()

	self.path = {}
end

function KabalaTreeNpc:createNpc()

	local isOn = HeroDataMgr:getIsFormationOn(1)
	if not isOn then
		return
	end

	local id = HeroDataMgr:getHeroIdByFormationPos(1)
	local heroData = HeroDataMgr:getHero(id)
	local skinId = HeroDataMgr:getCurSkin(heroData.cid)
	local data = TabDataMgr:getData("HeroSkin", skinId)
	local resPath = string.format("effect/%s/%s", data.model, data.model)
	self.skeletonNode = SkeletonAnimation:create(resPath)
	self.skeletonNode:play("stand", 1)
	self.skeletonNode:setScale(data.modelSize * 0.25)
	return self.skeletonNode

end

function KabalaTreeNpc:setPosition(position)
	self.skeletonNode:setPosition(position)
end

function KabalaTreeNpc:startSearch(endPoint)
	
	self.endPoint = endPoint
	self.path = KabalaTreeDataMgr:getPath()
	if not self.path or not next(self.path) then
		return
	end

	if #self.path == 1 then
		return
	end

	self.nextPathIndex = 2
	local nextTarget = self.path[self.nextPathIndex]
	self:moveToTarget(nextTarget)
end

function KabalaTreeNpc:moveToTarget(desGridId)

	--设置转向
	local desGrid = KabalaTreeDataMgr:getGridDataById(desGridId)
	if not desGrid then
		return
	end

	local action = Sequence:create({
        MoveTo:create(0.5,desGrid.centerPoint),
        CallFunc:create(function()
            if desGridId ~= self.endPoint then
            	self.nextPathIndex = self.nextPathIndex+1
            	local nextTarget = self.path[self.nextPathIndex]
				self:moveToTarget(nextTarget)
        	end
        end)
    })
	self.skeletonNode:runAction(action)
end
return KabalaTreeNpc