local EquipSelectCell = class("EquipSelectCell")
local ClassItemCell = require('script/app/global/itemcell')

function EquipSelectCell:ctor(roleobj,index,width, equipObj, isSelected,isequip,closeFun)
    self.width = width
    self.height = 0
    self.isSelected = isSelected
    self.roleobj = roleobj
    self.index = index
    self.isequip = isequip
    self.closeFun = closeFun
    self:initCell(equipObj)
end

function EquipSelectCell:initCell(equipObj)

    self.height = 110
    self.node = cc.Node:create()
    self.node:setPosition(cc.p(60, self.height - 55))
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("uires/ui_new/email/cell_bg.png")
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width-10, self.height))

    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equipObj, self.node)
    tab.awardBgImg:setTouchEnabled(false)
    tab.awardBgImg:setScale(0.9)
    bgImg:addChild(self.node)

    -- name
    local nameBg = ccui.ImageView:create()
    nameBg:loadTexture("uires/ui_new/common/common_text_bg1.png")
    nameBg:setAnchorPoint(cc.p(0, 0.5))
    nameBg:setPosition(cc.p(102, self.height - 37))
    bgImg:addChild(nameBg)

    local equipNameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    equipNameTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    equipNameTx:setAnchorPoint(cc.p(0, 0.5))
    equipNameTx:setTextColor(equipObj:getNameColor())
    equipNameTx:enableOutline(equipObj:getNameOutlineColor(), 2)
    equipNameTx:setString(equipObj:getName())
    equipNameTx:setPosition(cc.p(110, self.height - 37))
    bgImg:addChild(equipNameTx)

    -- 主属性
    local mainAttribute = equipObj:getMainAttribute()
    local mainAttrNameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
    mainAttrNameTx:setAnchorPoint(cc.p(0, 0.5))
    mainAttrNameTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
    mainAttrNameTx:setTextColor(COLOR_TYPE.YELLOW1)
    mainAttrNameTx:setString(mainAttribute.name.."：")
    mainAttrNameTx:setPosition(cc.p(115, self.height - 65))
    bgImg:addChild(mainAttrNameTx)

    --(精炼加成+强化加成+基础)
    local baseValue = equipObj:getAllBaseAttr()
    local contentsize = mainAttrNameTx:getContentSize()
    local mainAttrNumTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
    mainAttrNumTx:setAnchorPoint(cc.p(0, 0.5))
    mainAttrNumTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
    mainAttrNumTx:setTextColor(COLOR_TYPE.WHITE1)
    mainAttrNumTx:setString(baseValue)
    mainAttrNumTx:setPosition(cc.p(115+contentsize.width+2, self.height - 65))
    bgImg:addChild(mainAttrNumTx)

    -- 精炼属性
    local attributeCfg = GameData:getConfData("attribute")
    local refineSpecialAttr = equipObj:getRefineSpecialAttr()
    local specialAttrId = refineSpecialAttr.id
    local attrDesc = attributeCfg[specialAttrId].desc == '0' and '' or attributeCfg[specialAttrId].desc
    local attrNameColor = attributeCfg[specialAttrId].desc == '0' and COLOR_TYPE.YELLOW1 or COLOR_TYPE.RED1
    local refineSpecialNameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
    refineSpecialNameTx:setAnchorPoint(cc.p(0, 0.5))
    refineSpecialNameTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
    refineSpecialNameTx:setTextColor(attrNameColor)
    refineSpecialNameTx:setString(refineSpecialAttr.name.."：+")
    refineSpecialNameTx:setPosition(cc.p(115, self.height - 86))
    bgImg:addChild(refineSpecialNameTx)

    local contentsize = refineSpecialNameTx:getContentSize()
    local specialValue = equipObj:getRefineSpecialGrowth()
    local refineSpecialValueTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
    refineSpecialValueTx:setAnchorPoint(cc.p(0, 0.5))
    refineSpecialValueTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
    refineSpecialValueTx:setTextColor(attrNameColor)
    refineSpecialValueTx:setString(specialValue..attrDesc)
    refineSpecialValueTx:setPosition(cc.p(115+contentsize.width+2, self.height - 86))
    bgImg:addChild(refineSpecialValueTx)

    --装备or脱下btn
    local equipBtn = ccui.Button:create("uires/ui_new/common/common_btn_8.png","uires/ui_new/common/common_btn_9.png")
    equipBtn:setScale(0.8)
    local btnSize = equipBtn:getContentSize()
    local btnTx = cc.Label:createWithTTF("", "font/gamefont1.ttf", 31)
    btnTx:setAnchorPoint(cc.p(0.5, 0.5))
    btnTx:enableOutline(COLOROUTLINE_TYPE.YELLOW_BTN, 2)
    btnTx:setTextColor(COLOR_TYPE.YELLOW_BTN)
    btnTx:enableShadow(COLOR_BTN_SHADOW.YELLOW_BTN, cc.size(0, -1), 0)
    local btnStr = self.isequip and "COMMON_EQUIP" or "COMMON_EQUIPOFF"
    btnTx:setString(GlobalApi:getLocalStr_new(btnStr))
    btnTx:setPosition(cc.p(btnSize.width*0.5, btnSize.height*0.56))
    equipBtn:addChild(btnTx)
    equipBtn:setPosition(cc.p(self.width - 70, self.height - 80))
    equipBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.isequip then
                self:putOnEquip(equipObj)
            else
                local equipType = equipObj:getType()
                self:takeoffEquip(equipType)
            end
            RoleMgr:updateRoleList()
            self.closeFun()
        end
    end)

    bgImg:addChild(equipBtn)

    self.panel = bgImg
end

function EquipSelectCell:putOnEquip(equipObj)

    local rolePos = self.roleobj:getPosId()
    local args = {
        eid = equipObj:getSId(),
        pos = rolePos,
    }
    MessageMgr:sendPost("wear", "hero", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        local code = jsonObj.code
        if code == 0 then
            GlobalApi:parseAwardData(jsonObj.data.awards)
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            RoleData:putOnEquip(rolePos, equipObj)
            RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP_INFO, equipObj:getType())
        end
    end)
end

function EquipSelectCell:takeoffEquip(equipType)
    local isFull = BagData:isItemFull(ITEM_TYPE.EQUIP)
    if isFull then
        print("bag is fucking full")
        promptmgr:showSystenHint(GlobalApi:getLocalStr("BAG_REACHED_MAX_AND_FUSION"), COLOR_TYPE.RED)
        return
    end

    local rolePos = self.roleobj:getPosId()
    local args = {
        type = equipType,
        pos = rolePos
    }
    MessageMgr:sendPost("take_off", "hero", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        local code = jsonObj.code
        if code == 0 then
            local awards = jsonObj.data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
            end
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            RoleData:takeOffEquip(rolePos, equipType)
            RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP, equipType)
        end
    end)
end

function EquipSelectCell:getPanel()
    return self.panel
end

function EquipSelectCell:getSize()
    return self.width, self.height
end

function EquipSelectCell:setPosition(pos)
    self.panel:setPosition(pos)
end

function EquipSelectCell:setSelectCallBack(callback)
    self.callback = callback
end


return EquipSelectCell