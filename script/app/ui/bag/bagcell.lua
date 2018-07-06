local BagCellUI = class("BagCellUI")
local ClassItemCell = require('script/app/global/itemcell')
function BagCellUI:ctor(obj,type)
	self.obj = obj
	self.type = type
	self:initPanel()
end

function BagCellUI:initPanel()
	local panel = cc.CSLoader:createNode("csb/bagcell.csb")
	local cellBg = panel:getChildByName("cell_bg")
	cellBg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(cellBg)

	self.chipNode = cellBg:getChildByName("chip_node")
    self.equipNode = cellBg:getChildByName("equip_node")
    self.chipNode:setVisible(self.type == 'fragment')
    self.equipNode:setVisible(self.type == 'equip')

	local itemNode = cellBg:getChildByName("item_node")
    if not self.itemCell then
	    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	    self.itemCell = tab
		itemNode:addChild(tab.awardBgImg)
		tab.awardBgImg:setTouchEnabled(false)
		tab.awardBgImg:setScale(0.9)
	end
    ClassItemCell:updateItem(self.itemCell,self.obj,1)

    --名字
    self.nameTx = cellBg:getChildByName("item_name")
    self.nameTx:setString(self.obj:getName())
    self.nameTx:setTextColor(self.obj:getNameColor())
    self.nameTx:enableOutline(self.obj:getNameOutlineColor(), 2)

    self.belongTx = self.equipNode:getChildByName("belong_name")
    self.belongIcon = self.equipNode:getChildByName("belong_icon")

    self.attrNameTx1 = self.equipNode:getChildByName("attr_name1")
    self.attrNumTx1 = self.equipNode:getChildByName("attr_num1")
    self.attrNameTx2 = self.equipNode:getChildByName("attr_name2")
    self.attrNumTx2 = self.equipNode:getChildByName("attr_num2")

    local probgimg = self.chipNode:getChildByName("probg_img")
    self.bar = probgimg:getChildByName("pro_bar")
    self.barTx = self.bar:getChildByName("bar_tx")
    
	--获取按钮
	local getbtn = self.chipNode:getChildByName("get_btn")
	local btnTx = getbtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("BAG_BTN_STR5"))
	getbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	promptmgr:showSystenHint('功能暂未开发', COLOR_TYPE.RED)
        end
    end)

    --提升按钮
	local upbtn = self.equipNode:getChildByName("up_btn")
	local btnTx = upbtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("BAG_BTN_STR6"))
	upbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	promptmgr:showSystenHint('功能暂未开发', COLOR_TYPE.RED)
        end
    end)

    if self.type == 'equip' then
    	self:updateEquip()
    elseif self.type == 'fragment' then
    	self:updateFragment()
	end

end

function BagCellUI:updateEquip()

	local name = ''
    local roleobj = self.obj:getbelongObj()
    if roleobj then
    	name = roleobj:getName()
    end
    self.belongTx:setString(name)
    self.belongIcon:setVisible(name~='')

    
    local mainAttribute = self.obj:getMainAttribute()
    local strengthenAdd = self.obj:getStrengthGrowth()
    self.attrNameTx1:setString(mainAttribute.name)
    local width = self.attrNameTx1:getContentSize().width
    local nameTxPos = self.attrNameTx1:getPositionX()
    self.attrNumTx1:setString(mainAttribute.value+strengthenAdd)
    self.attrNumTx1:setPositionX(nameTxPos+width+5)

    
    local refineSpecialAttr = self.obj:getRefineSpecialAttr()
    local refineSpecialAdd = self.obj:getRefineSpecialGrowth()
    local attrdesc = refineSpecialAttr.desc == '0' and '' or refineSpecialAttr.desc
    local attrNameColor = refineSpecialAttr.desc == '0' and COLOR_TYPE.YELLOW1 or COLOR_TYPE.RED1
	self.attrNameTx2:setString(refineSpecialAttr.name)
	self.attrNameTx2:setTextColor(attrNameColor)
	local width = self.attrNameTx2:getContentSize().width
    local nameTxPos = self.attrNameTx2:getPositionX()
	self.attrNumTx2:setString(refineSpecialAdd..attrdesc)
	self.attrNumTx2:setPositionX(nameTxPos+width+5)

end

function BagCellUI:updateFragment()

	local num = self.obj:getNum();
    local mergenum = self.obj:getMergeNum()
    self.bar:setPercent((num/mergenum)*100)
	self.barTx:setString(num ..'/' .. mergenum)

end

function BagCellUI:getPanel()
	return self.panel
end

function BagCellUI:update(obj,type)
	if not obj then
		return
	end
	self.obj = obj
	self.type = type

	self.chipNode:setVisible(self.type ~= 'equip')
    self.equipNode:setVisible(self.type == 'equip')

    self.nameTx:setString(self.obj:getName())
    self.nameTx:setTextColor(self.obj:getNameColor())
    self.nameTx:enableOutline(self.obj:getNameOutlineColor(), 2)
    ClassItemCell:updateItem(self.itemCell,self.obj,1)

    if self.type == 'equip' then
    	self:updateEquip()
    elseif self.type == 'fragment' then
    	self:updateFragment()
	end
end

return BagCellUI