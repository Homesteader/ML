local KabalaTreeNpc = class("KabalaTreeNpc")

function KabalaTreeNpc:ctor()

	self.isMoving = false
end

--初始化player
function KabalaTreeNpc:initPlayerInfo(Panel_player,mn_position,scale)

	self.Panel_player = Panel_player

	local position = KabalaTreeDataMgr:convertToPos(mn_position.x,mn_position.y)
    position =  KabalaTreeDataMgr:convertToPosAR(position.x,position.y)
    self:setPosition(position)
    self:setScale(scale)
    self:setDirection(1)
    self:setPositiontMN(mn_position)
end

function KabalaTreeNpc:setPosition(position)

	self.position = position
	self.Panel_player:setPosition(position)
end

function KabalaTreeNpc:getPostion()
	return self.position
end

function KabalaTreeNpc:setPositiontMN(mn_position)

	self.mn_position = mn_position
end

function KabalaTreeNpc:getPositiontMN()
	return self.mn_position
end

function KabalaTreeNpc:setScale(scale)

	self.scale = scale
	self.Panel_player:setScale(scale)
end

function KabalaTreeNpc:setDirection(dir)

	self.direction = dir
	self.Panel_player:setScaleX(self.direction*self.scale)
end

function KabalaTreeNpc:setPalyerState(playerState)

	self.playerState = playerState
end

function KabalaTreeNpc:getPlayerState()
	
	return self.playerState
end

function KabalaTreeNpc:play(action)

	local skeletAnimation = self.Panel_player:getChildByName("model")
	if not skeletAnimation then
		return
	end
	skeletAnimation:play(action, 1)	
end

function KabalaTreeNpc:startMove(path,callback)

	if not path then
		return
	end

	--self:play("move")
	self:setPalyerState("moving")

	self.finishMoveCallBack = callback

	self.path = path
	self.pathId = 2					--从第2个格子开始，第一个格子是当前位置
	self:MoveTo(self.pathId)

end

function KabalaTreeNpc:MoveTo(desPathId)

	if not self.path[desPathId] then
		self:finishMove()
		return
	end

	local desTiledPos = self.path[desPathId]
	local position = KabalaTreeDataMgr:convertToPos(desTiledPos.x,desTiledPos.y)
   	position =  KabalaTreeDataMgr:convertToPosAR(position.x,position.y)

    --设置方向
    local curPositon = self:getPostion()
    local direction = position.x < curPositon.x and -1 or 1
    self:setDirection(direction)

    --移动
    self:moveing(position)
end

function KabalaTreeNpc:moveing(position)


	local action = Sequence:create({
        MoveTo:create(0.5,position),
        CallFunc:create(function()
        	self:setPositiontMN(self.path[self.pathId])
        	self.position = position
            self.pathId = self.pathId+1
            self:MoveTo(self.pathId)
        end)
    })
	self.Panel_player:runAction(action)
end

function KabalaTreeNpc:finishMove()

	--self:play("stand")
	self:setPalyerState("stand")

	if self.finishMoveCallBack then
		self.finishMoveCallBack()
	end
end
return KabalaTreeNpc