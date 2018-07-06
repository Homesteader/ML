local RoleEquipSelectCell = class("RoleEquipSelectCell")
local ClassItemCell = require('script/app/global/itemcell')
local BASE_HEIGHT = 110
local BASE_WIDTH = 450
local ATTR_HEIGHT = 26

function RoleEquipSelectCell:ctor(rolePos, equipObj, isEquiped, index)
	self.width = BASE_WIDTH
	self.height = 0
    self.rolePos = rolePos
    self.isEquiped = isEquiped
    self.equipObj = equipObj
    self.index = index
	self:initCell(equipObj)
    self.panel:setName("equip_select_cell_" .. index)
end

function RoleEquipSelectCell:initCell(equipObj)

    self.width,self.height = 332,110
    local roleObj = RoleData:getRoleByPos(self.rolePos)
	local bgImg = ccui.ImageView:create()
    self.bgImg = bgImg
    bgImg:loadTexture("uires/ui_new/common/common_bg_10.png")
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width,self.height))
    self.panel = bgImg
    
    self.node = cc.Node:create()
    self.node:setPosition(cc.p(60, 55))
    bgImg:addChild(self.node)

    self.tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.equipObj, self.node)
    self.tab.awardBgImg:setTouchEnabled(false)

    --装备名字
    local equipNameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    self.equipNameTx = equipNameTx
    local equipName = self.equipObj:getName()
    self.equipNameTx:setString(equipName)
    local color = self.equipObj:getNameColor()
    self.equipNameTx:setColor(color)
    self.equipNameTx:setPosition(cc.p(110, 102))
    self.equipNameTx:setAnchorPoint(cc.p(0,1))
    self.equipNameTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
    bgImg:addChild(self.equipNameTx)

    -- 主属性
    local mainAttribute = self.equipObj:getMainAttribute()
    local attrName = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    self.attrNameTx = attrName
    self.attrNameTx:setAnchorPoint(cc.p(0, 1))
    self.attrNameTx:setTextColor(COLOR_TYPE.YELLOW1)
    self.attrNameTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
    self.attrNameTx:setString(mainAttribute.name)
    self.attrNameTx:setPosition(cc.p(120, 72))
    bgImg:addChild(self.attrNameTx)

    local attrValue = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    self.attrValueTx = attrValue
    self.attrValueTx:setAnchorPoint(cc.p(0, 1))
    self.attrValueTx:setTextColor(COLOR_TYPE.WHITE1)
    self.attrValueTx:enableOutline(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    self.attrValueTx:setString(mainAttribute.value)
    self.attrValueTx:setPosition(cc.p(160, 72))
    bgImg:addChild(self.attrValueTx)

    --精炼属性
    self.refineAttrNameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    self.refineAttrNameTx:setAnchorPoint(cc.p(0, 1))
    self.refineAttrNameTx:setTextColor(COLOR_TYPE.RED1)
    self.refineAttrNameTx:enableOutline(COLOROUTLINE_TYPE.RED1, 2)
    self.refineAttrNameTx:setString("伤害加成")
    self.refineAttrNameTx:setPosition(cc.p(120, 42))
    bgImg:addChild(self.refineAttrNameTx)

    self.refineAttrValueTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    self.refineAttrValueTx:setAnchorPoint(cc.p(0, 1))
    self.refineAttrValueTx:setTextColor(COLOR_TYPE.WHITE1)
    self.refineAttrValueTx:enableOutline(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    self.refineAttrValueTx:setString("+100%")
    self.refineAttrValueTx:setPosition(cc.p(200, 42))
    bgImg:addChild(self.refineAttrValueTx)

    -- 穿戴按钮
    local putOnBtn = ccui.Button:create("uires/ui_new/common/common_btn_12.png", nil, nil)
    putOnBtn:setName("puton_btn")
    self.putOnBtn = putOnBtn
    local putOnBtnSize = putOnBtn:getContentSize()
    local putOnLabel = cc.Label:createWithTTF("", "font/gamefont1.ttf", 20)
    putOnLabel:setTextColor(cc.c4b(255,247,208, 255)) 
    putOnLabel:enableOutline(cc.c4b(125, 69, 7, 255), 2)
    putOnLabel:setPosition(cc.p(putOnBtnSize.width/2+2, putOnBtnSize.height*0.57))
    putOnLabel:setString(GlobalApi:getLocalStr_new("COMMON_EQUIP"))
    putOnBtn:setTouchEnabled(true)
    putOnBtn:setPropagateTouchEvents(false)
    putOnBtn:addChild(putOnLabel)
    putOnBtn:setPosition(cc.p(self.width - 50, 60))
    bgImg:addChild(putOnBtn)

    putOnBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            local roleObj = RoleData:getRoleByPos(self.rolePos)
            local obj = roleObj:getEquipByIndex(self.equipObj:getType())
            if obj and obj:getGodId() ~= 0 and self.equipObj:getGodId() == 0 then
                local godLevel = obj:getGodLevel()
                local godEquipConf = GameData:getConfData("godequip")
                local godEquipObj = godEquipConf[self.equipObj:getType()][godLevel]
                local cost = -self.equipObj:getInheritCost()
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('MESSAGE_3'),cost,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        self:SendPost(self.equipObj,cost)
                  end,GlobalApi:getLocalStr('TAVERN_YES'),GlobalApi:getLocalStr('TAVERN_NO'),function ()
                        self:SendPost(self.equipObj)
                  end)                 
            else
                self:SendPost(self.equipObj)
            end
        end
    end)

    -- 如果当前已经穿了装备
    putOnBtn:setVisible(not self.isEquiped)
end

function RoleEquipSelectCell:SendPost(equipObj,cost)
    cost = cost or 0
    if UserData:getUserObj():getGold() < cost then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'), COLOR_TYPE.RED)
        return
    end
    local args = {
        eid = self.equipObj:getSId(),
        pos = self.rolePos
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
            RoleData:putOnEquip(self.rolePos, self.equipObj)
            RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP_INFO, self.equipObj:getType())
            RoleMgr:updateRoleList()
        end
    end)
end

function RoleEquipSelectCell:update(index,rolePos, equipObj, isEquiped)
    self.rolePos = rolePos
    local roleObj = RoleData:getRoleByPos(self.rolePos)
    self.isEquiped = isEquiped
    self.equipObj = equipObj
    local subAttrs = self.equipObj:getSubAttribute()
    local subAttrNum = self.equipObj:getSubAttrNum()
    local num = subAttrNum > 2 and subAttrNum or 2
    local godId = self.equipObj:getGodId()
    if godId > 0 then
        local godNum = godId == 3 and 2 or 1
        subAttrNum = subAttrNum + godNum
    end
    self.height = BASE_HEIGHT + subAttrNum*ATTR_HEIGHT
    --self.bgImg:setContentSize(cc.size(self.width, self.height))

    ClassItemCell:updateItem(self.tab, self.equipObj, 1)

    self.node:setPosition(cc.p(60, self.height - 55))
    ClassItemCell:setGodLight(self.tab.awardBgImg, self.equipObj:getGodId())
    -- 等级
    self.equipLvLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
    self.equipLvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.equipLvLabel:setTextColor(self.equipObj:getNameColor())
    self.equipLvLabel:setString("Lv. " .. self.equipObj:getLevel() .. " " .. self.equipObj:getName())
    self.equipLvLabel:setPosition(cc.p(120, self.height - 25))
    -- 装备战斗力
    local fightforceStr = nil
    if self.isEquiped then
        fightforceStr = GlobalApi:getLocalStr("STR_EQUIP_FIGHTFORCE") .. "：" .. self:getProFightForce()
    else
        fightforceStr = GlobalApi:getLocalStr("STR_EQUIPED_FIGHTFORCE") .. "：" .. self:getProFightForce()
    end
    self.newImg:setVisible(false)
    if index == 1 then
        local ishaveeq,canequip = roleObj:isHavebetterEquip(self.equipObj:getType())
        
        if ishaveeq and canequip then
            self.newImg:setVisible(true)
        end
    end
    self.newImg:setPosition(cc.p(self.width,self.height))
    self.fightforceLabel:setString(fightforceStr)
    self.fightforceLabel:setPosition(cc.p(120, self.height - 55))
    -- 主属性
    local mainAttribute = self.equipObj:getMainAttribute()
    local mainAttributeStr = mainAttribute.name .. "：+" .. mainAttribute.value
    self.attributeLabel1:setString(mainAttributeStr)
    self.attributeLabel1:setPosition(cc.p(120, self.height - 81))

    -- 副属性
    local subAttrIndex = 0
    for k, v in pairs(subAttrs) do
        subAttrIndex = subAttrIndex + 1
        local attributeLabel = self.attributeLabelArr[subAttrIndex]
        local subAttrStr = v.name .. "    +" .. v.value
        attributeLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
        attributeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        attributeLabel:setTextColor(self.equipObj:getNameColor())
        attributeLabel:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
        attributeLabel:setString(subAttrStr)
        attributeLabel:setVisible(true)
    end
    for i = subAttrIndex+1, 4 do
        self.attributeLabelArr[i]:setVisible(false)
    end
    -- 神器
    if godId > 0 then
        subAttrIndex = subAttrIndex + 1
        local godObj = clone(self.equipObj:getGodAttr())
        self.goldLabel1:setVisible(true)
        self.goldLabel1:setTextColor(COLOR_TYPE[godObj[1].color])
        self.goldLabel1:enableOutline(COLOROUTLINE_TYPE[godObj[1].color], 1)
        self.goldLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        self.goldLabel1:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
        if godObj[1].type == 1 then
            godObj[1].value = math.floor(godObj[1].value/100)
        end
        if godObj[1].double then
            self.goldLabel1:setString(godObj[1].name .. " +" .. godObj[1].value*2 .. "%")
        else
            self.goldLabel1:setString(godObj[1].name .. " +" .. godObj[1].value .. "%")
        end
        if godObj[2] then
            subAttrIndex = subAttrIndex + 1
            self.goldLabel2:setVisible(true)
            self.goldLabel2:setTextColor(COLOR_TYPE[godObj[2].color])
            self.goldLabel2:enableOutline(COLOROUTLINE_TYPE[godObj[2].color], 1)
            self.goldLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            self.goldLabel2:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
            if godObj[2].type == 1 then
                godObj[2].value = math.floor(godObj[2].value/100)
            end
            if godObj[2].double then
                self.goldLabel2:setString(godObj[2].name .. " +" .. godObj[2].value*2 .. "%")
            else
                self.goldLabel2:setString(godObj[2].name .. " +" .. godObj[2].value .. "%")
            end
        else
            self.goldLabel2:setVisible(false)
        end
    else
        self.goldLabel1:setVisible(false)
        self.goldLabel2:setVisible(false)
    end
    
    if self.isEquiped then -- 如果当前已经穿了装备
        self.putOnBtn:setVisible(false)
    else
        --self.putOnBtn:setVisible(true)
        if UserData:getUserObj():getLv() < self.equipObj:getLevel()-10 then
            self.putOnBtn:setVisible(false)
        else
            self.putOnBtn:setVisible(true)
        end
    end
    
    

end

function RoleEquipSelectCell:getPanel()
	return self.panel
end

function RoleEquipSelectCell:getSize()
	return self.width, self.height
end

function RoleEquipSelectCell:setPosition(pos)
	self.panel:setPosition(pos)
end
function RoleEquipSelectCell:getProFightForce()
    local fightforce = 0
    local attconf =GameData:getConfData('attribute')
    local roleObj = RoleData:getRoleByPos(self.rolePos)
    local obj = roleObj:getEquipByIndex(self.equipObj:getType())
    local equiatt = {}
    if obj and not self.isEquiped then
        local att = {}  
        for i=1,#attconf do
            att[i] = 0
            equiatt[i] = 0
        end
        equiatt = clone(self.equipObj:getAllAttr())
        for i=1,self.equipObj:getMaxGemNum() do
            local gemObj = obj:getGems()[i]
            if gemObj then
                local attrId = gemObj:getAttrId()
                att[attrId] = att[attrId] + gemObj:getValue()
            end
            local gemObj1 = self.equipObj:getGems()[i]
            if gemObj1 then
                local attrId = gemObj1:getAttrId()
                att[attrId] = att[attrId] - gemObj1:getValue()
            end
        end
        local godId = self.equipObj:getGodId()
        local godId1 = obj:getGodId()
        if godId == 0 and godId1 ~= 0 then
            local godAttr = clone(obj:getGodAttr())
            for k,v in pairs(godAttr) do
                if v.double then
                    att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)*2
                else
                    att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)
                end
            end
        end
        local attemp = {}
        for i=1,#attconf do
            attemp[i] = 0
            attemp[i] = equiatt[i]+att[i]
        end
        fightforce =self.equipObj:getFightForcePre(attemp)
    else
       fightforce = self.equipObj:getFightForce()
    end
    return fightforce
end
return RoleEquipSelectCell
