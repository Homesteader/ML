local GemUpgradeUI = class("GemUpgradeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')


function GemUpgradeUI:ctor(gemObj, partObj, slotIndex, roleObj, callback)
    self.uiIndex = GAME_UI.UI_GEMUPGRADE
    self.roleObj = roleObj or nil
    self.callback = callback or nil
    self.slotIndex = slotIndex or 0
    self.partObj = partObj
    self.gemObj = gemObj

    self.isBag = false
    if self.roleObj == nil then
        self.isBag = true
    end
end

function GemUpgradeUI:init()

    local gemSelectBgImg = self.root:getChildByName("bg_img")
    local gemSelectImg = gemSelectBgImg:getChildByName("bg_alpha")
    self:adaptUI(gemSelectBgImg, gemSelectImg)
    local gemSelect = gemSelectImg:getChildByName("bg_img1")

    self.closeBtn = gemSelect:getChildByName("close_btn")
    self.closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local titletx = gemSelect:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr_new('ROLE_GEM_CONFIRM_TITLE1'))

    
    local gemNode1 =  gemSelect:getChildByName("gem_node1")
    local gemItem1 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    gemNode1:addChild(gemItem1.awardBgImg)
    gemItem1.awardBgImg:setScale(0.8)
    ClassItemCell:updateItem(gemItem1,self.gemObj,1)
    gemItem1.lvTx:setVisible(false)

    local gemNode2 =  gemSelect:getChildByName("gem_node2")
    local gemItem2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    gemNode2:addChild(gemItem2.awardBgImg)
    gemItem2.awardBgImg:setScale(0.8)
    ClassItemCell:updateItem(gemItem2,self.gemObj,1)

    local curAttrTx = gemSelect:getChildByName('cur_attr_tx')
    curAttrTx:setString(self.gemObj:getAttrName() .. "+" .. self.gemObj:getValue())

    -- 下一级属性
    local attributeConf = GameData:getConfData("attribute")
    local nextAttrTx = gemSelect:getChildByName('next_attr_tx')
    local nextLevel = self.gemObj:getLevel() + 1
    local curGemId = self.gemObj:getId()
    local nextGenConf = GameData:getConfData("gem")[curGemId + 1]
    if nextGenConf then
       gemNode2:setVisible(true)
       nextAttrTx:setVisible(true)
       nextAttrTx:setString(self.gemObj:getAttrName() .. "+" .. nextGenConf['value'])
       gemItem2.awardBgImg:loadTexture(COLOR_FRAME[nextGenConf.quality])
       gemItem2.awardImg:loadTexture("uires/icon/gem/" .. nextGenConf['icon'])
       gemItem2.lvTx:setVisible(false)
       gemItem2.gemLvTx:setString("LV"..nextLevel)
    else
       gemNode2:setVisible(false) 
       nextAttrTx:setVisible(false)
    end

    -- 消耗列表
    local consumeContainer = gemSelect:getChildByName('consume_list')
    self.itemListSv = consumeContainer:getChildByName("item_list_sv")
    self.itemListSv:setScrollBarEnabled(false)
    local tipTx = consumeContainer:getChildByName("label_tx")
    tipTx:setString(GlobalApi:getLocalStr_new("ROLE_GEM_CONFIRM_INFO5"))

    -- 升级按钮
    local lvbtn = gemSelect:getChildByName('lvup_btn')
    local lvupbtntx = lvbtn:getChildByName('func_tx')
    lvupbtntx:setString(GlobalApi:getLocalStr_new('ROLE_GEM_CONFIRM_INFO3'))
    lvbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
        end       
        if eventType ==  ccui.TouchEventType.ended then
            if self.isBag then
                local gemType = self.gemObj:getType()
                local gemLevel = self.gemObj:getLevel()
                self:lvUpBagPost(gemType, gemLevel)
            else
                self:lvUpPost()
            end
        end
    end)

    self:update()
end

function GemUpgradeUI:update()

    local count = 0
    local gemItem = {}
    local canUpgrade, consumeList = self.gemObj:getUpgradeConsumeList(self.isBag)
    for k,v in pairs(consumeList) do
        count = count + 1
        local itemBg = self.itemListSv:getChildByTag(100+count)
        if not itemBg then
            gemItem[count] = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            itemBg = gemItem[count].awardBgImg
            gemItem[count].awardBgImg:setAnchorPoint(cc.p(0,0))
            gemItem[count].awardBgImg:setScale(0.7)
            self.itemListSv:addChild(itemBg, 1, 100+count)
        end
        ClassItemCell:updateItem(gemItem[count],v.gemObj,1)
        gemItem[count].lvTx:setString("x"..v.num)
    end

    local space = 5
    local size1 = cc.size(65.8,65.8)
    local size = self.itemListSv:getContentSize()
    if count > 0 then
        if count * size1.width > size.width then
            self.itemListSv:setInnerContainerSize(cc.size(count * size1.width+(count-1)*space+10,size.height))
        else
            self.itemListSv:setInnerContainerSize(size)
        end
    
        local function getPos(i)
            local size2 = self.itemListSv:getInnerContainerSize()  
            return cc.p((size1.width+space)*(i-1)+5,5)          
        end
        for i=1,count do
            local cell = self.itemListSv:getChildByTag(i + 100)
            if cell then
                cell:setPosition(getPos(i))
            end
        end
    end
end


function GemUpgradeUI:lvUpPost()

    local partId = self.partObj:getPartId()
    local args = {
        pos = self.roleObj:getPosId() or 0,
        part_pos = partId,
        gem_pos = self.slotIndex
    }

    MessageMgr:sendPost("upgrade_gem", "parttrain", json.encode(args), function (jsonObj)

        local code = jsonObj.code
        if code == 0 then
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            local gemId = self.gemObj:getId()
            -- 设置宝石等级
            if self.roleObj and self.partObj then
                self.partObj:putOnGem(self.slotIndex, gemId + 1)
                self.roleObj:setFightForceDirty(true)
            end

            if self.callback then
                self.callback()
            end

            self:hideUI()
        else
            self:hideUI()
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'),COLOR_TYPE.RED)
        end
    end)
end

function GemUpgradeUI:lvUpBagPost(gemType, gemLevel)

    local args = {
        gem_type = gemType,     -- 宝石类型
        gem_level = gemLevel,   -- 宝石等级
        gem_num = 1           -- 合成数量
    }

    MessageMgr:sendPost("gemCompose", "bag", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            local costs = jsonObj.data.costs
            GlobalApi:parseAwardData(costs)

            local awards = jsonObj.data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards, nil, nil, true)
            end

            if self.callback then
                self.callback()
            end

            self:hideUI()
        else
            -- 合成失败提示
            self:hideUI()
        end
    end)
end

return GemUpgradeUI