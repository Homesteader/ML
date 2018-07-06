local RoleEquipRebuildUI = class("RoleEquipRebuildUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function RoleEquipRebuildUI:ctor(type,roleObj,selectPos)
    self.uiIndex = GAME_UI.UI_EQUIP_REBUILD
    self.type = type
    self.roleObj = roleObj
    self.selectPos = selectPos or 1
end

local checkBtnTexture = {
    nor = "uires/ui_new/common/select_tab_nor.png",
    sel = "uires/ui_new/common/select_tab_push.png",
}

function RoleEquipRebuildUI:init()
    
    local alphaBg = self.root:getChildByName("bg_img")
    local bg = alphaBg:getChildByName("bg")
    self:adaptUI(alphaBg, bg)

    self.refineItem = UserData:getUserObj():getDefaultRefineItem()
    table.sort(self.refineItem, function (a, b)
            local q1 = a.quality
            local q2 = b.quality
            if q1 == q2 then
                local f1 = a.id
                local f2 = b.id
                return f1 < f2
            else
                return q1 < q2
            end
    end) 

    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideEquipRebuildUI()
        end
    end)

    --页签
    self.checkBtn = {}
    for i =1,2 do
        local checkBtn = bg:getChildByName("check_btn"..i)
        local btnTx = checkBtn:getChildByName("text")
        local btnStr = i==1 and GlobalApi:getLocalStr_new("STRENGTHEN_BTN_TX") or GlobalApi:getLocalStr_new("REFINE_BTN_TX")
        btnTx:setString(btnStr)
        self.checkBtn[i] = {}
        self.checkBtn[i].btn = checkBtn
        self.checkBtn[i].btnTx = btnTx
        checkBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:selectCheckBtn(i)
            end
        end)
    end

    --左右按钮(选择英雄)
    self.chooseRoleBtn = {}
    local rightBtn = bg:getChildByName("right_btn")
    rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:selectRole(1)
        end
    end)
    local leftBtn = bg:getChildByName("left_btn")
    leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:selectRole(-1)
        end
    end)
    self.chooseRoleBtn.right = rightBtn
    self.chooseRoleBtn.left = leftBtn
    GlobalApi:arrowBtnMove(leftBtn,rightBtn)

    self.roleCont = 0
    self.RoleMap = RoleData:getRoleMap()
    for k, v in pairs(self.RoleMap) do
        if v:getId() > 0 then
            self.roleCont = self.roleCont + 1
        end
    end
    local rolePosId = self.roleObj:getPosId()
    self.chooseRoleBtn.left:setTouchEnabled(rolePosId ~= 1)
    self.chooseRoleBtn.left:setBright(rolePosId ~= 1)
    self.chooseRoleBtn.right:setTouchEnabled(rolePosId ~= self.roleCont)
    self.chooseRoleBtn.right:setBright(rolePosId ~= self.roleCont)

    local titleTx = bg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_TITLE"))

    
    local leftBg = bg:getChildByName("left_bg")
    local center_bg = leftBg:getChildByName("center_bg")
    local one_key_btn = center_bg:getChildByName("one_key_btn")
    self.oneKeyBtnTx = one_key_btn:getChildByName("text")
    one_key_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:showEquipOnekeyRebuildUI(self.type,self.roleObj)
        end
    end)

    --武将名字 
    local heroName = self.roleObj:getName()
    self.roleNameTx = leftBg:getChildByName("hero_name")
    self.roleNameTx:setString(heroName)

    local chooseImg = leftBg:getChildByName("choos_img")

    --武将装备
    self.equipTab = {}
    for i=1,MAXEQUIPNUM do
        local equipPart = leftBg:getChildByName("part_"..i)
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil,true)
        tab.awardBgImg:ignoreContentAdaptWithSize(true)    
        tab.awardBgImg.index = i    

        local nodeSize = equipPart:getContentSize()
        tab.awardBgImg:setPosition(cc.p(nodeSize.width/2, nodeSize.height/2))
        tab.awardBgImg:setScale(0.82)
        tab.addImg:setVisible(false)
        tab.addImg:ignoreContentAdaptWithSize(true)
        local equiparr = {}
        equiparr.node = equipPart
        equiparr.tab = tab
        self.equipTab[i] = equiparr
        equipPart:addChild(tab.awardBgImg)
        self:updateEquip(i)
        self.equipTab[i].tab.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            end
            if eventType == ccui.TouchEventType.ended then

                self.selectPos = i
                local posX,posY = self.equipTab[i].node:getPosition()
                chooseImg:setPosition(posX,posY)
                self:updateRightPL()
            end
        end)
    end

    local posX,posY = self.equipTab[self.selectPos].node:getPosition()
    chooseImg:setPosition(posX,posY)

    --大师面板
    self.masterTab = {}
    local masterBg = leftBg:getChildByName("attr_bg")
    local masterTx = masterBg:getChildByName("master_tx")
    local proTx = masterBg:getChildByName("pro_tx")
    local arrow = masterBg:getChildByName("arrow")
    local fullImg = masterBg:getChildByName("full_img")
    self.masterTab.masterTx = masterTx
    self.masterTab.proTx = proTx
    self.masterTab.arrow = arrow
    self.masterTab.fullImg = fullImg
    self.masterTab.attr = {}
    for i=1,2 do
        local attrNameTx = masterBg:getChildByName("attr_tx_"..i)
        local attrValue = masterBg:getChildByName("attr_num_"..i)
        local nextAttrTx = masterBg:getChildByName("next_attr_tx_"..i)
        local nextAttrValueTx = masterBg:getChildByName("next_attr_num_"..i)
        self.masterTab.attr[i] = {}
        self.masterTab.attr[i].curAttrName = attrNameTx 
        self.masterTab.attr[i].curAttrValue = attrValue
        self.masterTab.attr[i].nextAttrName = nextAttrTx 
        self.masterTab.attr[i].nextAttrValue = nextAttrValueTx
    end

    --右侧详细界面
    local rightBg = bg:getChildByName("right_bg")
    self.basepl = rightBg:getChildByName("base_pl")
    self.noneimg = rightBg:getChildByName("null_bg")
    local noneTx = self.noneimg:getChildByName("text")
    noneTx:setString(GlobalApi:getLocalStr_new("NOT_EQUIP_TX"))

    self.equipNameTx = self.basepl:getChildByName("equip_name")
    self.showEuqipImg = self.basepl:getChildByName("show_quip")

    --强化面板
    local cangetMaxLv,deltaLv = GlobalApi:getStrengthenLvInfo()
    self.strengthen = {}
    self.strengthenBg = self.basepl:getChildByName("strengthen_bg")
    local quipInfo = self.strengthenBg:getChildByName("equip_info")
    quipInfo:setString(string.format(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_INFO3"),cangetMaxLv))
    local quipInfo1 = self.strengthenBg:getChildByName("equip_info_1")
    quipInfo1:setString(string.format(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_INFO4"),deltaLv))
    local fullimg = self.strengthenBg:getChildByName("full_img")
    self.strengthen.fullimg = fullimg
    self.strengthen.info = {}
    for i=1,2 do
        local funcNameTx = self.strengthenBg:getChildByName("fun_name"..i)
        local funcLvTx = self.strengthenBg:getChildByName("func_lv"..i)
        local attrNameTx = self.strengthenBg:getChildByName("attr_tx"..i)
        local attrValueTx = self.strengthenBg:getChildByName("attr_num"..i)
        self.strengthen.info[i] = {}
        self.strengthen.info[i].nameTx = funcNameTx
        self.strengthen.info[i].lvTx = funcLvTx
        self.strengthen.info[i].attrNameTx = attrNameTx
        self.strengthen.info[i].attrValueTx = attrValueTx
    end

    local costbg = self.strengthenBg:getChildByName("cost_bg")
    local costIcon = costbg:getChildByName("res_icon")
    local costNum = costbg:getChildByName("cost_num")
    self.strengthen.costInfo = {}
    self.strengthen.costInfo.icon = costIcon
    self.strengthen.costInfo.num = costNum

    --精炼面板
    self.refineBg = self.basepl:getChildByName("refine_bg")
    local tipTx = self.refineBg:getChildByName("equip_info")
    local jieIcon = self.refineBg:getChildByName("jie_img")
    local jieTx = jieIcon:getChildByName("text")
    local barbg = self.refineBg:getChildByName("bar_bg")
    local barTx = barbg:getChildByName("bar_tx")
    local bar = barbg:getChildByName("bar")
    bar:setScale9Enabled(true)
    bar:setCapInsets(cc.rect(26,6,26,26))
    local fullimg = self.refineBg:getChildByName("full_img")
    self.refine = {}
    self.refine.tipTx = tipTx
    self.refine.jieTx = jieTx
    self.refine.barTx = barTx
    self.refine.bar = bar
    self.refine.fullimg = fullimg
    self.refine.info = {}
    for i=1,2 do
        local funcNameTx = self.refineBg:getChildByName("fun_name"..i)
        local funcLvTx = self.refineBg:getChildByName("fun_lv"..i)
        local attrNameTx = self.refineBg:getChildByName("attr_tx"..i)
        local attrValueTx = self.refineBg:getChildByName("attr_num"..i)
        self.refine.info[i] = {}
        self.refine.info[i].baseAttr = funcNameTx
        self.refine.info[i].baseAttrValue = funcLvTx
        self.refine.info[i].attrNameTx = attrNameTx
        self.refine.info[i].attrValueTx = attrValueTx
    end
    self.refine.costItem = {}
    for i=1,4 do
        local itemBg = self.refineBg:getChildByName("item_bg_"..i)
        local item = itemBg:getChildByName("item")
        local addnumTx = itemBg:getChildByName("add_num")
        local ownNumTx = itemBg:getChildByName("num_tx")
        local itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        itemCell.awardBgImg:setPosition(cc.p(item:getPosition()))
        itemCell.awardBgImg:setScale(0.72)
        item:addChild(itemCell.awardBgImg)
        self.refine.costItem[i] = {}
        self.refine.costItem[i].itemCell = itemCell
        self.refine.costItem[i].addnumTx = addnumTx
        self.refine.costItem[i].ownNumTx = ownNumTx
    end

    --功能按钮
    local fun5Btn = self.basepl:getChildByName("func_5_btn")
    self.btn5tx = fun5Btn:getChildByName("text")
    fun5Btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.type == 1 then
                self:sendStrengthenMsg(5)
            elseif self.type == 2 then
                self:sendRefineMsg(5)
            end
        end
    end)

    local fun1Btn = self.basepl:getChildByName("func_btn")
    self.btn1tx = fun1Btn:getChildByName("text")
    fun1Btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.type == 1 then
                self:sendStrengthenMsg(1)
            elseif self.type == 2 then
                self:sendRefineMsg(1)
            end
        end
    end)

    self:selectCheckBtn(self.type)
end

--切换英雄
function RoleEquipRebuildUI:selectRole(step)

    local rolePosId = self.roleObj:getPosId()
    local newRolePosId = rolePosId + step

    local roleObj = self.RoleMap[newRolePosId]
    if not roleObj or roleObj:getId() <= 0 then
        return 
    end

    self.chooseRoleBtn.left:setTouchEnabled(newRolePosId ~= 1)
    self.chooseRoleBtn.left:setBright(newRolePosId ~= 1)
    self.chooseRoleBtn.right:setTouchEnabled(newRolePosId ~= self.roleCont)
    self.chooseRoleBtn.right:setBright(newRolePosId ~= self.roleCont)

    self.roleObj = roleObj
    local heroName = self.roleObj:getName()
    self.roleNameTx:setString(heroName)
    for i=1,MAXEQUIPNUM do
        self:updateEquip(i)
    end
    self:selectCheckBtn(self.type)
end

--页签切换
function RoleEquipRebuildUI:selectCheckBtn(type)

    for i=1,2 do
        if i == type then
            self.checkBtn[i].btn:loadTextureNormal(checkBtnTexture.nor)
            self.checkBtn[i].btnTx:setTextColor(COLOR_TYPE.TAB_WHITE)
            self.checkBtn[i].btnTx:enableOutline(COLOROUTLINE_TYPE.OFFTAB_WHITE,1)
            self.checkBtn[i].btnTx:enableShadow(COLOR_BTN_SHADOW.TAB_WHITE, cc.size(0, -1), 0)
            self.checkBtn[i].btn:setScale(1)
        else
            self.checkBtn[i].btn:loadTextureNormal(checkBtnTexture.sel)
            self.checkBtn[i].btnTx:setTextColor(COLOR_TYPE.TAB_WHITE1)
            self.checkBtn[i].btnTx:enableOutline(COLOROUTLINE_TYPE.OFFTAB_WHITE1,1)
            self.checkBtn[i].btnTx:enableShadow(COLOR_BTN_SHADOW.TAB_WHITE1, cc.size(0, -1), 0)
            self.checkBtn[i].btn:setScale(0.9)
        end
    end
    
    self.type = type
    local strTextIndex = self.type == 1 and "ROLE_EQUIPREBUILD_INFO8" or "ROLE_EQUIPREBUILD_INFO9"
    self.oneKeyBtnTx:setString(GlobalApi:getLocalStr_new(strTextIndex))

    self:updateMaser()
    self:updateRightPL()
end

function RoleEquipRebuildUI:update()

    if self.type == 1 then
        self:updateStrengthenPL()
        self:updateStengMaster()
    else
        self:updateRefinePL()
        self:updateRefineMaster()
    end

    for i=1,MAXEQUIPNUM do
        self:updateEquip(i)
    end
   
end

function RoleEquipRebuildUI:updateRightPL()

    local btn5txStr = self.type == 1 and "ROLE_EQUIPREBUILD_BTNTX1" or "ROLE_EQUIPREBUILD_BTNTX2"
    self.btn5tx:setString(GlobalApi:getLocalStr_new(btn5txStr))

    local btn1txStr = self.type == 1 and "STRENGTHEN_BTN_TX" or "REFINE_BTN_TX"
    self.btn1tx:setString(GlobalApi:getLocalStr_new(btn1txStr))

    self.basepl:setVisible(true)
    self.noneimg:setVisible(false)
    local equipObj = self.roleObj:getEquipByIndex(self.selectPos)
    if not equipObj then
        self.noneimg:setVisible(true)
        self.basepl:setVisible(false)
        return
    end
    self.equipObj = equipObj

    local equipName = equipObj:getName()
    self.equipNameTx:setString(equipName)
    local colorValue = equipObj:getNameColor()
    self.equipNameTx:setColor(colorValue)
    local equipIcon = equipObj:getIcon()
    self.showEuqipImg:loadTexture(equipIcon)

    self.strengthenBg:setVisible(self.type == 1)
    self.refineBg:setVisible(self.type == 2)
    if self.type == 1 then
        self:updateStrengthenPL()
    else
        self:updateRefinePL()
    end
end

--刷新强化界面
function RoleEquipRebuildUI:updateStrengthenPL()

    if not self.equipObj then
        return
    end

    local cangetMaxLv,deltaLv = GlobalApi:getStrengthenLvInfo()
    local funcNameStr = GlobalApi:getLocalStr_new("STRENGTHEN_LV_TX")
    local curStrengthenLv = self.equipObj:getStrengthenLv()
    local isMax = curStrengthenLv == cangetMaxLv

    self.strengthen.fullimg:setVisible(isMax)
    local nextStrengthenLv = curStrengthenLv + 1
    if nextStrengthenLv >=  cangetMaxLv then
        nextStrengthenLv = cangetMaxLv
    end

    self.strengthen.info[2].nameTx:setVisible(not isMax)
    self.strengthen.info[2].lvTx:setVisible(not isMax)
    self.strengthen.info[2].attrNameTx:setVisible(not isMax)
    self.strengthen.info[2].attrValueTx:setVisible(not isMax)

    --装备基础属性
    local mainAttribute = self.equipObj:getMainAttribute()
    local curValueAdd = self.equipObj:getStrengthGrowth()
    local nextValueAdd = self.equipObj:getStrengthGrowth(nextStrengthenLv)
    for i=1,2 do
        self.strengthen.info[i].nameTx:setString(funcNameStr)
        local lv = i==1 and curStrengthenLv or nextStrengthenLv
        self.strengthen.info[i].lvTx:setString(lv)
        self.strengthen.info[i].attrNameTx:setString(mainAttribute.name)
        local value = i==1 and curValueAdd or nextValueAdd
        self.strengthen.info[i].attrValueTx:setString("+"..value)
    end

    --消耗
    local quality = self.equipObj:getQuality()
    local equipUpgradeCfg = GameData:getConfData("equipupgrade")[nextStrengthenLv]
    local cost = equipUpgradeCfg['cost'..quality]
    local award = DisplayData:getDisplayObj(cost[1])
    if award then
        local ownum = award:getOwnNum()
        local costnum = award:getNum()
        self.strengthen.costInfo.num:setString(GlobalApi:toWordsNumber(costnum)..'/'..GlobalApi:toWordsNumber(ownum))
        if ownum < costnum then
            self.strengthen.costInfo.num:setColor(COLOR_TYPE.RED1)
        else
            self.strengthen.costInfo.num:setColor(COLOR_TYPE.WHITE1)
        end
        self.strengthen.costInfo.icon:loadTexture(award:getIcon())
    end
end

--刷新精炼界面
function RoleEquipRebuildUI:updateRefinePL()

    if not self.equipObj then
        return
    end
    local attributeCfg = GameData:getConfData("attribute")
    local equipQuality = self.equipObj:getQuality()
    local curRefineLv,canRefineMaxLv = self.equipObj:getRefineLv()
    local qualityStr = GlobalApi:getLocalStr_new("EQUIP_QUALITY_TX"..equipQuality)
    self.refine.tipTx:setString(string.format(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_INFO5"),qualityStr,canRefineMaxLv))
    self.refine.jieTx:setString(curRefineLv..GlobalApi:getLocalStr_new("COMMON_JIE"))

    local displayExp,displayNeedExp = self.equipObj:getRefineDisPlayExp()
    self.refine.barTx:setString(displayExp.."/"..displayNeedExp)
    local percent =string.format("%.2f", (displayExp/displayNeedExp)*100)  
    self.refine.bar:setPercent(percent)

    local isMax = curRefineLv == canRefineMaxLv
    self.refine.fullimg:setVisible(isMax)
    local nextRefineLv = curRefineLv + 1
    if nextRefineLv >=  canRefineMaxLv then
        nextRefineLv = canRefineMaxLv
    end

    self.refine.info[2].baseAttr:setVisible(not isMax)
    self.refine.info[2].baseAttrValue:setVisible(not isMax)
    self.refine.info[2].attrNameTx:setVisible(not isMax)
    self.refine.info[2].attrValueTx:setVisible(not isMax)

    --装备基础属性
    local mainAttribute = self.equipObj:getMainAttribute()
    local curBaseValueAdd = self.equipObj:getRefineGrowth()
    local nextBaseValueAdd = self.equipObj:getRefineGrowth(nextRefineLv)

    local refineSpecialAttr = self.equipObj:getRefineSpecialAttr()
    local curSpecialValueAdd = self.equipObj:getRefineSpecialGrowth()
    local nextSpecialValueAdd = self.equipObj:getRefineSpecialGrowth(nextRefineLv)
    for i=1,2 do
        
        self.refine.info[i].baseAttr:setString(mainAttribute.name)
        local attrDesc = attributeCfg[mainAttribute.attrType].desc == '0' and '' or attributeCfg[mainAttribute.attrType].desc
        local attrNameColor = attributeCfg[mainAttribute.attrType].desc == '0' and COLOR_TYPE.YELLOW1 or COLOR_TYPE.RED1
        self.refine.info[i].baseAttr:setTextColor(attrNameColor)
        local value = i==1 and curBaseValueAdd or nextBaseValueAdd
        self.refine.info[i].baseAttrValue:setString("+"..value..attrDesc)
        local baseSize = self.refine.info[i].baseAttr:getContentSize()
        local posX = self.refine.info[i].baseAttr:getPositionX()
        self.refine.info[i].baseAttrValue:setPositionX(baseSize.width+posX+5)

        local specialAttrId = refineSpecialAttr.id
        local attrDesc = attributeCfg[specialAttrId].desc == '0' and '' or attributeCfg[specialAttrId].desc
        local attrNameColor = attributeCfg[specialAttrId].desc == '0' and COLOR_TYPE.YELLOW1 or COLOR_TYPE.RED1
        self.refine.info[i].attrNameTx:setTextColor(attrNameColor)
        self.refine.info[i].attrNameTx:setString(refineSpecialAttr.name)
        local value = i==1 and curSpecialValueAdd or nextSpecialValueAdd
        self.refine.info[i].attrValueTx:setString("+"..value..attrDesc)
        local specialSize = self.refine.info[i].attrNameTx:getContentSize()
        local posX = self.refine.info[i].attrNameTx:getPositionX()
        self.refine.info[i].attrValueTx:setPositionX(specialSize.width+posX+5)
    end

    --消耗道具
    for i=1,4 do
        local materialobj = BagData:getMaterialById(self.refineItem[i].id)
        if materialobj then
            ClassItemCell:updateItem(self.refine.costItem[i].itemCell,materialobj,1)
            local addNum = materialobj:getUseEffect()
            local ownum = materialobj:getNum()
            self.refine.costItem[i].addnumTx:setString("+"..addNum)
            self.refine.costItem[i].ownNumTx:setString(ownum)
            self.refine.costItem[i].itemCell.limitTx:setVisible(false)
            self.refine.costItem[i].itemCell.lvTx:setVisible(false)
        end
    end
end

--刷新大师面板
function RoleEquipRebuildUI:updateMaser()
    if self.type == 1 then
        self:updateStengMaster()
    elseif self.type == 2 then
       self:updateRefineMaster()
    end
end

--刷新强化大师
function RoleEquipRebuildUI:updateStengMaster()

    local attributeCfg = GameData:getConfData("attribute")
    local strengthenCfg = GameData:getConfData("equipmasterupgrade")
    local curMasterLv = self.roleObj:getStrengthenMasterLv()
    local nextMasterLv = curMasterLv+1
    local isMax = curMasterLv == #strengthenCfg
    if nextMasterLv >= #strengthenCfg then
        nextMasterLv = #strengthenCfg
    end

    local str = string.format(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_INFO1"),strengthenCfg[nextMasterLv].needUpgradeLevel)
    self.masterTab.masterTx:setString(str)

    local nextNeedCont = strengthenCfg[nextMasterLv].needUpgradeNum
    local nextNeedLv = strengthenCfg[nextMasterLv].needUpgradeLevel
    local fitCont = 0
    for i=1,MAXEQUIPNUM do
        local equipObj = self.roleObj:getEquipByIndex(i)
        if equipObj then
            local strengthenLv = equipObj:getStrengthenLv()
            if strengthenLv >= nextNeedLv then
                fitCont = fitCont + 1
            end
        end
    end
    self.masterTab.proTx:setString("("..fitCont.."/"..nextNeedCont..")")

    self.masterTab.arrow:setVisible(not isMax)
    self.masterTab.fullImg:setVisible(isMax)

    --属性显示
    for i=1,2 do
        local curAttrId,curAttrValue 
        local nextAttrId,nextAttrValue = GlobalApi:getAttrTypeAndValue(strengthenCfg[nextMasterLv].attribute[i])
        if curMasterLv ~= 0 then
            curAttrId,curAttrValue = GlobalApi:getAttrTypeAndValue(strengthenCfg[curMasterLv].attribute[i])
        else
            curAttrId,curAttrValue = nextAttrId,0
        end

        --nil是只有一种属性的情况
        if curAttrId == nil then
            self.masterTab.attr[i].curAttrName:setVisible(false)
            self.masterTab.attr[i].curAttrValue:setVisible(false)
        else
            self.masterTab.attr[i].curAttrName:setVisible(true)
            self.masterTab.attr[i].curAttrValue:setVisible(true)
            self.masterTab.attr[i].curAttrName:setString(attributeCfg[curAttrId].name)
            local attrDesc = attributeCfg[curAttrId].desc == '0' and '' or attributeCfg[curAttrId].desc
            local curValueStr = "+"..curAttrValue..attrDesc
            self.masterTab.attr[i].curAttrValue:setString(curValueStr)

            local curNameSize = self.masterTab.attr[i].curAttrName:getContentSize()
            local posX = self.masterTab.attr[i].curAttrName:getPositionX()
            self.masterTab.attr[i].curAttrValue:setPositionX(posX+curNameSize.width+5)
        end

        if nextAttrId == nil then
            self.masterTab.attr[i].nextAttrName:setVisible(false)
            self.masterTab.attr[i].nextAttrValue:setVisible(false)
        else
            self.masterTab.attr[i].nextAttrName:setVisible(true)
            self.masterTab.attr[i].nextAttrValue:setVisible(true)
            local attrDesc = attributeCfg[nextAttrId].desc == '0' and '' or attributeCfg[nextAttrId].desc
            local nextValueStr = "+"..nextAttrValue..attrDesc
            self.masterTab.attr[i].nextAttrName:setString(attributeCfg[nextAttrId].name)
            self.masterTab.attr[i].nextAttrValue:setString(nextValueStr)
            self.masterTab.attr[i].nextAttrName:setVisible(not isMax)
            self.masterTab.attr[i].nextAttrValue:setVisible(not isMax)

            local nextNameSize = self.masterTab.attr[i].nextAttrName:getContentSize()
            local posX = self.masterTab.attr[i].nextAttrName:getPositionX()
            self.masterTab.attr[i].nextAttrValue:setPositionX(posX+nextNameSize.width+5)
        end
    end
end

--属性精炼大师
function RoleEquipRebuildUI:updateRefineMaster()

    local attributeCfg = GameData:getConfData("attribute")
    local refineMasterCfg = GameData:getConfData("equipmasterrefine")
    local curMasterLv = self.roleObj:getRefineMasterLv()
    local nextMasterLv = curMasterLv+1
    local isMax = curMasterLv == #refineMasterCfg
    if nextMasterLv >= #refineMasterCfg then
        nextMasterLv = #refineMasterCfg
    end

    local str = string.format(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_INFO2"),refineMasterCfg[nextMasterLv].needRefineLevel)
    self.masterTab.masterTx:setString(str)

    local nextNeedCont = refineMasterCfg[nextMasterLv].needRefineNum
    local neddRefineLv = refineMasterCfg[nextMasterLv].needRefineLevel
    local fitCont = 0
    for i=1,MAXEQUIPNUM do
        local equipObj = self.roleObj:getEquipByIndex(i)
        if equipObj then
            local refineLv = equipObj:getRefineLv()
            if refineLv >= neddRefineLv then
                fitCont = fitCont + 1
            end
        end
    end
    self.masterTab.proTx:setString("("..fitCont.."/"..nextNeedCont..")")

    self.masterTab.arrow:setVisible(not isMax)
    self.masterTab.fullImg:setVisible(isMax)

    --属性显示
    for i=1,2 do
        local curAttrId,curAttrValue 
        local nextAttrId,nextAttrValue = GlobalApi:getAttrTypeAndValue(refineMasterCfg[nextMasterLv].attribute[i])
        if curMasterLv ~= 0 then
            curAttrId,curAttrValue = GlobalApi:getAttrTypeAndValue(refineMasterCfg[curMasterLv].attribute[i])
        else
            curAttrId,curAttrValue = nextAttrId,0
        end

        --nil是只有一种属性的情况
        if curAttrId == nil then
            self.masterTab.attr[i].curAttrName:setVisible(false)
            self.masterTab.attr[i].curAttrValue:setVisible(false)
        else
            self.masterTab.attr[i].curAttrName:setVisible(true)
            self.masterTab.attr[i].curAttrValue:setVisible(true)
            self.masterTab.attr[i].curAttrName:setString(attributeCfg[curAttrId].name)
            local attrDesc = attributeCfg[curAttrId].desc == '0' and '' or attributeCfg[curAttrId].desc
            local attrNameColor = attributeCfg[curAttrId].desc == '0' and COLOR_TYPE.YELLOW1 or COLOR_TYPE.RED1
            self.masterTab.attr[i].curAttrName:setTextColor(attrNameColor)
            local curValueStr = "+"..curAttrValue..attrDesc
            self.masterTab.attr[i].curAttrValue:setString(curValueStr)
            local curNameSize = self.masterTab.attr[i].curAttrName:getContentSize()
            local posX = self.masterTab.attr[i].curAttrName:getPositionX()
            self.masterTab.attr[i].curAttrValue:setPositionX(posX+curNameSize.width+5)
        end

        if nextAttrId == nil then
            self.masterTab.attr[i].nextAttrName:setVisible(false)
            self.masterTab.attr[i].nextAttrValue:setVisible(false)
        else
            self.masterTab.attr[i].nextAttrName:setVisible(true)
            self.masterTab.attr[i].nextAttrValue:setVisible(true)
            local attrDesc = attributeCfg[nextAttrId].desc == '0' and '' or attributeCfg[nextAttrId].desc
            local attrNameColor = attributeCfg[nextAttrId].desc == '0' and COLOR_TYPE.YELLOW1 or COLOR_TYPE.RED1
            self.masterTab.attr[i].nextAttrName:setTextColor(attrNameColor)
            local nextValueStr = "+"..nextAttrValue..attrDesc
            self.masterTab.attr[i].nextAttrName:setString(attributeCfg[nextAttrId].name)
            self.masterTab.attr[i].nextAttrValue:setString(nextValueStr)
            self.masterTab.attr[i].nextAttrName:setVisible(not isMax)
            self.masterTab.attr[i].nextAttrValue:setVisible(not isMax)

            local nextNameSize = self.masterTab.attr[i].nextAttrName:getContentSize()
            local posX = self.masterTab.attr[i].nextAttrName:getPositionX()
            self.masterTab.attr[i].nextAttrValue:setPositionX(posX+nextNameSize.width+5)
        end
    end
end

--刷新装备
function RoleEquipRebuildUI:updateEquip(equipPos)

    local equip = self.roleObj:getEquipByIndex(equipPos)
    self.equipTab[equipPos].tab.upImg:setVisible(false)
    self.equipTab[equipPos].tab.addImg:setVisible(false)

    if equip then

        ClassItemCell:updateItem(self.equipTab[equipPos].tab, equip, 1)
        self.equipTab[equipPos].tab.addImg:setVisible(false)
        local refineLv = equip:getRefineLv()
        if refineLv > 0 then
            self.equipTab[equipPos].tab.cornerImgR:setVisible(true)
        else
            self.equipTab[equipPos].tab.cornerImgR:setVisible(false)
        end
    else
        self.equipTab[equipPos].tab.awardBgImg:loadTexture(DEFAULT)
        self.equipTab[equipPos].tab.awardImg:loadTexture(DEFAULTEQUIP[equipPos])
        self.equipTab[equipPos].tab.cornerImg:setVisible(false)
        self.equipTab[equipPos].tab.cornerImgR:setVisible(false)
    end
end

function RoleEquipRebuildUI:judgCouldUpgradeToLv(toLevel)

    local maxLv,detaLv = GlobalApi:getStrengthenLvInfo()
    if toLevel >= maxLv then
        toLevel = maxLv
    end

    local upgradeCfg = GameData:getConfData("equipupgrade")
    local strengthenLv = self.equipObj:getStrengthenLv()
    local quality = self.equipObj:getQuality()

    local totalCost = 0
    local upgradeLv = 0
    for i= strengthenLv+1,toLevel do
        local equipUpgradeCfg = upgradeCfg[i]
        local cost = equipUpgradeCfg['cost'..quality]
        local award = DisplayData:getDisplayObj(cost[1])
        if award then
            local ownum = award:getOwnNum()
            local costnum = award:getNum()
            totalCost = totalCost + costnum
            if ownum >= totalCost then
                upgradeLv = i
            end
        end
    end
    
    return upgradeLv 
end

function RoleEquipRebuildUI:sendStrengthenMsg(upLevel)
    
    if not self.equipObj then
        return
    end
    upLevel = upLevel or 1
    local strengthenLv = self.equipObj:getStrengthenLv()
    local upgradeLv = self:judgCouldUpgradeToLv(strengthenLv+upLevel)
    if upgradeLv == 0 then
        local maxLv,detaLv = GlobalApi:getStrengthenLvInfo()
        if strengthenLv >= maxLv then
            promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_EQUIPREBUILD_INFO6'), COLOR_TYPE.RED)
        else
            promptmgr:showSystenHint(GlobalApi:getLocalStr_new('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
        end
        return
    end

    local sid = self.equipObj:getSId()
    local equipPos = self.equipObj:getType()
    local args = {
        eid = sid,
        to_level = upgradeLv
    }
    MessageMgr:sendPost("intensify", "equip", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
           self.equipObj:setStrengthenLv(upgradeLv)
           RoleMgr:updateRoleMainUI()
           self:updateEquip(equipPos)
           self:updateStengMaster()
           self:updateStrengthenPL()

           local costs = jsonObj.data.costs
           if costs then
                GlobalApi:parseAwardData(costs)
           end

           promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_EQUIPREBUILD_INF13'), COLOR_TYPE.GREEN)
        end
    end)
end

function RoleEquipRebuildUI:getMaterialNums(toLevel)

    local canUpgrade = false
    local materialNums = {}
    local needExp = self.equipObj:getNeedExpToLv(toLevel)
    local eatExp = 0
    for i=1,#self.refineItem do
        local itemId = self.refineItem[i].id
        local materialobj = BagData:getMaterialById(itemId)
        if materialobj then
            local exp = tonumber(materialobj:getUseEffect())
            local ownNum = materialobj:getNum()
            local costCont = 0
            for j=1,ownNum do 
                eatExp = eatExp + exp
                costCont = costCont + 1
                if eatExp >= needExp then
                    canUpgrade = true
                    break
                end
            end
            materialNums[tostring(itemId)] = costCont
            if canUpgrade then
                break
            end  
        end
    end

    --如果增长的经验能够满足升一阶则可以升级
    if not canUpgrade then
        local curRefineLv,canRefineMaxLv = self.equipObj:getRefineLv()
        local oneNeedExp = self.equipObj:getNeedExpToLv(curRefineLv+1)
        if eatExp >= oneNeedExp then
            canUpgrade = true
        end
    end
    return canUpgrade,materialNums
end

function RoleEquipRebuildUI:sendRefineMsg(upLevel)
    
    if not self.equipObj then
        return
    end
    upLevel = upLevel or 1
    local curRefineLv,canRefineMaxLv = self.equipObj:getRefineLv()
    if curRefineLv >= canRefineMaxLv then
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_EQUIPREBUILD_INFO7'), COLOR_TYPE.RED)
        return 
    end
    local canUpgrade,materialNums = self:getMaterialNums(curRefineLv+upLevel)
    if not canUpgrade or not materialNums then
        local materialobj = BagData:getMaterialById(self.refineItem[1].id)
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
        GetWayMgr:showGetwayUI(materialobj,true)
        return
    end

    local equipPos = self.equipObj:getType()
    local sid = self.equipObj:getSId()
    local args = {
        eid = sid,
        item = materialNums,
    }
    MessageMgr:sendPost("refine", "equip", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        local data = jsonObj.data
        if code == 0 then
            local curRefineLv,canRefineMaxLv = self.equipObj:getRefineLv()
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.equipObj:setRefineLv(data.new_level)
            self.equipObj:setRefineExp(data.new_exp)
            RoleMgr:updateRoleMainUI()
                     
            self:updateRefinePL()
            if data.new_level > curRefineLv then
               self:updateEquip(equipPos)
               self:updateRefineMaster()
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('SUIT_DESC_14'), COLOR_TYPE.GREEN)
            end
        end
    end)

end
return RoleEquipRebuildUI