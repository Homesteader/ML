local BagItemCellUI = class("BagItemCellUI")
local ClassItemCell = require('script/app/global/itemcell')
function BagItemCellUI:ctor(obj,bagType,cellId)
	self.obj = obj
	self.bagType = bagType
    self.cellId = cellId

	self:initPanel()
end

function BagItemCellUI:initPanel()
	local panel = cc.CSLoader:createNode("csb/bagitemcell.csb")
	local cellBg = panel:getChildByName("cell_bg")
	cellBg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(cellBg)

	local itemNode = cellBg:getChildByName("node")
    if not self.itemCell then
	    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	    self.itemCell = tab
		itemNode:addChild(tab.awardBgImg)
		tab.awardBgImg:setScale(0.9)
        tab.awardBgImg:setSwallowTouches(false)
	end

    self.lightBg = cellBg:getChildByName("light_bg")
    self.lightBg:setScale(0.9)
    self.lightBg:setVisible(false)

    self.itemCell.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.lightBg:setVisible(true)
            BagMgr:updateRightPanel(self.obj,self.bagType,self.cellId,self.lightBg)
        end
    end)

    ClassItemCell:updateItem(self.itemCell,self.obj,1)
    if self.cellId == 1 then
        self.lightBg:setVisible(true)
        BagMgr:updateRightPanel(self.obj,self.bagType,self.cellId,self.lightBg)
    end
end


function BagItemCellUI:getPanel()
	return self.panel
end

function BagItemCellUI:update(obj,bagType,cellId)
	if not obj then
		return
	end

    self.obj = obj
    self.bagType = bagType
    self.cellId = cellId
    ClassItemCell:updateItem(self.itemCell,self.obj,1)

    if self.cellId == 1 then
        self.lightBg:setVisible(true)
        BagMgr:updateRightPanel(self.obj,self.bagType,self.cellId,self.lightBg)
    end
end

return BagItemCellUI