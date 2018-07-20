
--与怪物，建筑分开创建，避免后面有特殊的表现效果
local KabalaTreeItem = class("KabalaTreeItem")

function KabalaTreeItem:ctor()

	
end

--进入地图初始化元素
function KabalaTreeItem:initItem(Image_random,itemTab)

	self.tileMap = KabalaTreeDataMgr:getTileMap()
	self.Image_random = Image_random
	self.mapItem = {}

	--表示曾经走过触发过
	for k,v in pairs(itemTab) do
		self:createItem(v)
	end
end

--开地图新产生item
function KabalaTreeItem:spawnNewItem(tilePosMN)

	if not tilePosMN then
		return
	end
	self:createItem(tilePosMN)
end

function KabalaTreeItem:cleanItem(tilePosMN)

	local item,index 
	for k,v in pairs(self.mapItem) do
		if v.pos.x == tilePosMN.x and tilePosMN.y == v.pos.y then
			item = v.item
			index = k
		end
	end
	if not item or not self.tileMap then
		return
	end
	item:stopAllActions()
	local function acFun()
        item:removeFromParent()
        table.remove(self.mapItem,index)
    end

	local seqact = Sequence:create({
        FadeOut:create(0.5),
        CallFunc:create(acFun)
    })
    item:runAction(seqact)

    local layer = self.tileMap:getLayer("ground")
    local sprite = layer:getTileAt(tilePosMN)
    if not sprite then
    	return
    end

    local action = Sequence:create({
        FadeOut:create(0.5),
        CallFunc:create(function()
        	layer:setTileGID(1,tilePosMN)
        	sprite:runAction(FadeIn:create(0.5))
        end)
    })
    sprite:runAction(action)
end

function KabalaTreeItem:createItem(tilePosMN)

	if not self.tileMap then
		return
	end 
	local layer = self.tileMap:getLayer("ground")
	local gid = layer:getTileGIDAt(tilePosMN)
	if gid ~= 3 then
		return
	end

    local position = KabalaTreeDataMgr:convertToPos(tilePosMN.x,tilePosMN.y)
    position =  KabalaTreeDataMgr:convertToPosAR(position.x,position.y)
    local randomItem = self.Image_random:clone()
    randomItem:setPosition(position)
    randomItem:setScale(1.5)
    randomItem:setOpacity(0)
    local seqact = Sequence:create({
        FadeIn:create(0.5),
        CallFunc:create(function ()
            local offsetY = 10
            local seqact = Sequence:create({
                MoveBy:create(0.5, ccp(0, offsetY)),
                MoveBy:create(0.5, ccp(0, -offsetY)),
            })
            randomItem:runAction(RepeatForever:create(seqact))
        end)
    })
    randomItem:runAction(seqact)
    self.tileMap:addChild(randomItem)

    for k,v in pairs(self.mapItem) do
		if v.pos.x == tilePosMN.x and tilePosMN.y == v.pos.y then
			return
		end
	end
	table.insert(self.mapItem,{pos = tilePosMN,item = randomItem})
end

return KabalaTreeItem