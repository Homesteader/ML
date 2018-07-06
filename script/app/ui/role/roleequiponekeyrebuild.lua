local RoleEquipOneKeyRebuildUI = class("RoleEquipOneKeyRebuildUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function RoleEquipOneKeyRebuildUI:ctor(buildType,roleObj)
    self.uiIndex = GAME_UI.UI_EQUIP_ONEKEY_REBUILD
    self.buildType = buildType
    self.roleObj = roleObj
end


function RoleEquipOneKeyRebuildUI:init()
    
    local alphaBg = self.root:getChildByName("bg_img")
    local bg = alphaBg:getChildByName("bg")
    self:adaptUI(alphaBg, bg) 

    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideEquipOnekeyRebuildUI()
        end
    end)

    local strTextIndex = self.buildType == 1 and "ROLE_EQUIPREBUILD_INFO8" or "ROLE_EQUIPREBUILD_INFO9"
    local titleTx = bg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr_new(strTextIndex))
    
    local contentBg = bg:getChildByName("di")
    local tipTx = contentBg:getChildByName("tip_tx")
    local strTextIndex = self.buildType == 1 and "ROLE_EQUIPREBUILD_INF10" or "ROLE_EQUIPREBUILD_INF11"
    tipTx:setString(GlobalApi:getLocalStr_new(strTextIndex))

    local tipTx1 = contentBg:getChildByName("tip_tx1")
    tipTx1:setString(GlobalApi:getLocalStr_new("ROLE_EQUIPREBUILD_INF12"))
    
    --强化消耗
    self.cost_bg = contentBg:getChildByName("cost_bg")
    self.cost_bg:setVisible(self.buildType == 1)

    self.cost_item_bg = contentBg:getChildByName("cost_item_bg")
    self.cost_item_bg:setVisible(self.buildType ~= 1)
    if self.buildType == 2 then
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
    end

    --显示装备
    self.minLv = 99999
    self.equipInfo = {}
    for i= 1,MAXEQUIPNUM do
        local equipObj = self.roleObj:getEquipByIndex(i)
        local tab
        if equipObj then
            tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equipObj, contentBg)
            local awardbgSize = tab.awardBgImg:getContentSize()
            local upImg = ccui.ImageView:create("uires/ui_new/common/arrow_up.png")
            upImg:setPosition(cc.p(awardbgSize.width/2-10,-10))
            upImg:setScale(0.6)
            tab.awardBgImg:addChild(upImg)
            local upTx = ccui.Text:create()
            upTx:setFontName("font/gamefont.ttf")
            upTx:setFontSize(18)
            upTx:setColor(COLOR_TYPE.GREEN1)
            upTx:enableOutline(COLOROUTLINE_TYPE.GREEN1, 2)
            upTx:setAnchorPoint(cc.p(0, 0.5))
            upTx:setPosition(cc.p(awardbgSize.width/2, -12))
            tab.awardBgImg:addChild(upTx)

            local quality = equipObj:getQuality()
            if self.buildType == 1 then
                local strengthenLv = equipObj:getStrengthenLv()
                self.minLv = strengthenLv < self.minLv and strengthenLv or self.minLv
                self.equipInfo[i] = {strengthenLv = strengthenLv,quality = quality,oldLv = strengthenLv,upTx = upTx,upImg = upImg}
            else
                local refineLv,canRefineMaxLv = equipObj:getRefineLv()
                local refineExp = equipObj:getRefineExp() 
                local quality = equipObj:getQuality()
                self.minLv = refineLv < self.minLv and refineLv or self.minLv
                self.equipInfo[i] = {}
                self.equipInfo[i].refineLv = refineLv
                self.equipInfo[i].canRefineMaxLv=canRefineMaxLv
                self.equipInfo[i].refineExp = refineExp
                self.equipInfo[i].quality = quality
                self.equipInfo[i].oldLv = refineLv
                self.equipInfo[i].upTx = upTx
                self.equipInfo[i].upImg = upImg
            end
            
        else
            tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil)
            tab.awardBgImg:loadTexture(DEFAULT)
            tab.awardImg:loadTexture(DEFAULTEQUIP[i])
            tab.cornerImg:setVisible(false)
            tab.cornerImgR:setVisible(false)
            contentBg:addChild(tab.awardBgImg)
        end

        tab.awardBgImg:setScale(0.9)
        local posX = 76 + (i-1)*96
        tab.awardBgImg:setPosition(cc.p(posX,216))
    end

    --确定
    local ok_btn = bg:getChildByName("ok_btn")
    local btnTx = ok_btn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_OK"))
    ok_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendRebuildMgs()
        end
    end)

    --取消
    local cancle_btn = bg:getChildByName("cancle_btn")
    local btnTx = cancle_btn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_CANCLE"))
    cancle_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideEquipOnekeyRebuildUI()
        end
    end)

    self:update()
end

function RoleEquipOneKeyRebuildUI:update()
    if self.buildType == 1 then
        self:updateStrengthenCost()
    elseif self.buildType == 2 then
        self:getRefineCost()
    end
end

--一键强化消耗
function RoleEquipOneKeyRebuildUI:updateStrengthenCost()

    local totalCost,costdisplayObj = self:getStrengCost()
    if not totalCost or not costdisplayObj then
        return
    end

    local icon = self.cost_bg:getChildByName("icon")
    local costTx = self.cost_bg:getChildByName("text")
    local ownum = costdisplayObj:getOwnNum()
    icon:loadTexture(costdisplayObj:getIcon())
    costTx:setString(GlobalApi:toWordsNumber(totalCost)..'/'..GlobalApi:toWordsNumber(ownum))
    
     for k,v in pairs(self.equipInfo) do 
        if v.upTx and v.upImg then
            local upLv = v.strengthenLv-v.oldLv
            v.upTx:setVisible(upLv~=0)
            v.upImg:setVisible(upLv~=0)
            v.upTx:setString(upLv)
        end
    end 
end

function RoleEquipOneKeyRebuildUI:getStrengCost()
    
    local upgradeCfg = GameData:getConfData("equipupgrade")
    local maxLv,detaLv = GlobalApi:getStrengthenLvInfo()
    local upGradeMinLv = false
    local totalCost = 0
    local ownNum = 0
    local costAward = upgradeCfg[1]['cost1']
    local displayObj = DisplayData:getDisplayObj(costAward[1])
    if displayObj then
        ownNum = displayObj:getOwnNum()
    end

    local enoughMoney = false
    while(true) do
        upGradeMinLv = false
        for i=1,MAXEQUIPNUM do
            if self.equipInfo[i] and self.equipInfo[i].strengthenLv and self.equipInfo[i].strengthenLv < self.minLv then
                local strengthenUpLv = self.equipInfo[i].strengthenLv + 1
                local costAward = upgradeCfg[strengthenUpLv]['cost'..self.equipInfo[i].quality]
                local costdisplayObj = DisplayData:getDisplayObj(costAward[1])
                if costdisplayObj then
                    local costNum = costdisplayObj:getNum()
                    local allCost = totalCost + costNum
                    if allCost <= ownNum then
                        enoughMoney = true
                        if strengthenUpLv <= maxLv then
                            upGradeMinLv = true
                            totalCost = allCost
                            self.equipInfo[i].strengthenLv = strengthenUpLv 
                        end
                    else
                        enoughMoney = false
                        break
                    end
                end
            end
        end

        if not enoughMoney then
            break
        end

        if upGradeMinLv then
            self.minLv = self.minLv + 1
        end

        if self.minLv >= maxLv then
            break
        end
    end

    return totalCost,displayObj

end

--一键精炼消耗
function RoleEquipOneKeyRebuildUI:getRefineCost()

    self.costMaterialInfo = {}
    while(true) do
        local minLv = 99999
        local minLvIndex = 1
        local minLvIndex
        for i=1,MAXEQUIPNUM do
            if self.equipInfo[i] then
                local refineLv =  self.equipInfo[i].refineLv 
                if refineLv < minLv  then
                    minLv = refineLv
                    minLvIndex = i
                end
            end
        end
        if not self.equipInfo[minLvIndex] then
            break
        end
        local refineLv = self.equipInfo[minLvIndex].refineLv
        local canRefineMaxLv = self.equipInfo[minLvIndex].canRefineMaxLv
        local refineExp = self.equipInfo[minLvIndex].refineExp
        local quality = self.equipInfo[minLvIndex].quality

        local nextRefineLv = refineLv+1
        if nextRefineLv > canRefineMaxLv then
            break
        end
        local needExp = self:getNeedExpToLv(refineExp,quality,nextRefineLv)
        local canUpgrade,eatedExp = self:getMaterialNums(needExp)
        if not canUpgrade then
            break
        end  
        self.equipInfo[minLvIndex].refineExp = self.equipInfo[minLvIndex].refineExp + eatedExp
        local realLv = self:changeRefineExpToLv(self.equipInfo[minLvIndex].refineExp,quality)
        self.equipInfo[minLvIndex].refineLv = realLv
        
    end

    --显示提升等级
    for i=1,MAXEQUIPNUM do
        if self.equipInfo[i] then
            local refineLv = self.equipInfo[i].refineLv
            local upLv = refineLv - self.equipInfo[i].oldLv
            self.equipInfo[i].upTx:setVisible(upLv~=0)
            self.equipInfo[i].upImg:setVisible(upLv~=0)
            self.equipInfo[i].upTx:setString(upLv)
        end
    end

    --显示消耗材料
    local cnt = 0
    for k,v in pairs(self.costMaterialInfo) do
        if v ~= 0 then
            cnt = cnt + 1
        end
    end
    local postab = {180,138,96,50}
    local startPos = postab[cnt]
    for i=1,#self.refineItem do
        local itemId = self.refineItem[i].id
        local materialobj = BagData:getMaterialById(itemId)
        if materialobj then
            local costNum = self.costMaterialInfo[itemId]
            if costNum ~= 0 then
                local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,materialobj,self.cost_item_bg)
                tab.awardBgImg:setScale(0.8)
                local posX = startPos + (i-1)*85
                tab.awardBgImg:setPosition(cc.p(posX,49))
                tab.lvTx:setString(costNum)
            end
        end
    end

end

function RoleEquipOneKeyRebuildUI:getMaterialNums(needExp)

    local canUpgrade = false 
    local eatExp = 0
    for i=1,#self.refineItem do
        local itemId = self.refineItem[i].id
        local materialobj = BagData:getMaterialById(itemId)
        if materialobj then
            local exp = tonumber(materialobj:getUseEffect())
            local costed = self.costMaterialInfo[itemId] or 0
            local ownNum = materialobj:getNum() - costed
            local costCont = 0
            for j=1,ownNum do 
                eatExp = eatExp + exp
                costCont = costCont + 1
                if eatExp >= needExp then
                    canUpgrade = true
                    break
                end
            end
            
            if not self.costMaterialInfo[itemId] then
                self.costMaterialInfo[itemId] = costCont
            else
               self.costMaterialInfo[itemId] = self.costMaterialInfo[itemId] + costCont 
            end
            
            if canUpgrade then
                break
            end  
        end
    end
    return canUpgrade,eatExp
end

function RoleEquipOneKeyRebuildUI:getNeedExpToLv(curRefineExp,quality,toLevel)

    local equipRefineCfg = GameData:getConfData("equiprefine")[tonumber(quality)]
    if toLevel >= #equipRefineCfg then
        toLevel = #equipRefineCfg
    end

    local needExp = 0
    for i=1,toLevel do
        needExp = needExp + equipRefineCfg[i].refineExp
    end

    needExp = needExp - curRefineExp
    if needExp < 0 then
        needExp = 0
    end
    return needExp
end

function RoleEquipOneKeyRebuildUI:changeRefineExpToLv(exp,quality)

    local refineLv = 0
    local equipRefineCfg = GameData:getConfData("equiprefine")[tonumber(quality)]
    local needExp = 0
    for i=1,#equipRefineCfg do
        needExp = needExp + equipRefineCfg[i].refineExp
        if exp >= needExp then
            refineLv = tonumber(equipRefineCfg[i].level)
        else
            break
        end
    end

    return refineLv
end

--发送消息
function RoleEquipOneKeyRebuildUI:sendRebuildMgs()
    
    local act = self.buildType == 1 and "intensify_all" or "refine_all"
    local rolePos = self.roleObj:getPosId()
    MessageMgr:sendPost(act, "equip", json.encode({pos = rolePos}), function (jsonObj)
        local code = jsonObj.code
        local data = jsonObj.data
        if code == 0 then

            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end

            for k,v in pairs(data.equip) do
                local equipObj = BagData:getEquipMapById(k)
                if equipObj then
                    if self.buildType == 1 then
                        equipObj:setStrengthenLv(v)
                    elseif self.buildType == 2 then 
                        equipObj:setRefineExp(v)
                    end
                end
            end
            RoleMgr:updateEquipRebuildUI( )
            RoleMgr:updateRoleMainUI()
            RoleMgr:hideEquipOnekeyRebuildUI()
            if self.buildType == 1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_EQUIPREBUILD_INF13'), COLOR_TYPE.GREEN)
            elseif self.buildType == 2 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_EQUIPREBUILD_INF14'), COLOR_TYPE.GREEN)
            end
        else
            local descStr = jsonObj.desc or ''
            local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_ERROR'),descStr)
            promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
        end
    end)
end
return RoleEquipOneKeyRebuildUI