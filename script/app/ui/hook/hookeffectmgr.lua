local hookeffectmgr = {
	bfNode = nil,
	effectsPools = nil
}

-- 初始化
function hookeffectmgr:init(bfNode)
	self.effectsPools = hookheromgr:createObjPool()
	self.bfNode = bfNode
	self.preloadList = {}
end

function hookeffectmgr:clear()
	self.bfNode = nil
	self.effectsPools = nil
	self.preloadList = nil
end

function hookeffectmgr:preloadAni()
	for id, num in pairs(self.preloadList) do
		for i = 1, num do
			local aniObj = ClassEffects.new(id, self.effectsPools)
			aniObj.effectsNode:setVisible(false)
			self.bfNode:addChild(aniObj.effectsNode)
			self.effectsPools:push(id, aniObj)
		end
	end
	self.preloadList = nil
end
