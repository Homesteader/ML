local StoreMainUI = class("StoreMainUI", BaseUI)

local MAX_TAB = 6

local checkBtnTexture = {
    nor = "uires/ui_new/store/tab_nor.png",
    sel = "uires/ui_new/store/tab_sel.png",
}

function StoreMainUI:ctor(storeType,storeTabId,shop)

	self.uiIndex = GAME_UI.UI_STOREMAIN
    self.storeType = storeType                      --商店类型(配置表中的货架ID)
    self.storeTabId = storeTabId                    --商店页签Id
    self.goods = {}
    self:setGoodsData(storeTabId,shop.goods)
    self.oldChoosId = nil
    self.refreshInfo = {}
    self:setRefreshData(storeTabId,shop.manual_refresh_count,shop.next_refresh_time)
end

function StoreMainUI:stopSchedule()
    if self._scheduleId then
        GlobalApi:clearScheduler(self._scheduleId)
        self._scheduleId = nil
    end
end

function StoreMainUI:onHide()
    self:stopSchedule()
end

function StoreMainUI:setUIBackInfo()
    UIManager.sidebar:setBackBtnCallback('', function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideStoreMainUI()
        end
    end, 1)
end

function StoreMainUI:init()

    local bg_img = self.root:getChildByName("bg_img")
    local bg = bg_img:getChildByName("bg")
    self:adaptUI(bg_img,bg)
    
    self:setUIBackInfo()

    

    local shopFrameCfg = GameData:getConfData("shopuniversaltab")[self.storeType]
    if not shopFrameCfg then
        return
    end

    self.shopTabCfg = GameData:getConfData("shopuniversalconfig")
    self.shopGoodsCfg = GameData:getConfData("shopuniversalgoods")

    local storebg = bg:getChildByName("store_bg")

    self.arrow_img = storebg:getChildByName("arrow_img")
    
    --商品列表
    self.cloneCell = storebg:getChildByName("_cell_clone")
    self.goods_sv = storebg:getChildByName("goods_sv")
    self.goods_sv:setScrollBarEnabled(false)

    self.herobg = storebg:getChildByName("hero_bg")

    --商店名字
    local titlebg = storebg:getChildByName("title_bg")
    local titleTx = titlebg:getChildByName("text")
    titleTx:setString(shopFrameCfg.name)

    --页签
    local tabinfo = {}
    for i=1,MAX_TAB do
        local tabId = shopFrameCfg['tab'..i]
        if tabId ~= 0 then
            local openCondition = self.shopTabCfg[tabId].openCondition
            local open = self:checkStoreTabOpen(openCondition)
            if open then
                table.insert(tabinfo, tabId)
            end
        end
    end

    --检测传入页签Id是否正确
    local n = GlobalApi:tableFind(tabinfo, self.storeTabId) 
    if n == 0 then
        logger_error("wrong storeTabId:",self.storeTabId)
        return 
    end

    self.tabBtn = {}
    local tabbg = storebg:getChildByName("tab_bg")  
    for i=1,MAX_TAB do
        local tabbtn = tabbg:getChildByName("tab_"..i)
        if i <= #tabinfo then

            local id = tabinfo[i]
            local tabTx = tabbtn:getChildByName("text")
            local tabName = self.shopTabCfg[id].name
            tabTx:setString(tabName)
            self.tabBtn[i] = {id = id, tabbtn = tabbtn, tabTx = tabTx}
            tabbtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:chooseBtn(id)
                end
            end)
        else
            tabbtn:setVisible(false)
        end
    end

    local boneTab = tabbg:getChildByName("bone")
    local posY = self.tabBtn[#tabinfo].tabbtn:getPositionY()
    boneTab:setPositionY(posY-64)

    self:chooseBtn(self.storeTabId)

end

--设置商店货物数据
function StoreMainUI:setGoodsData(storeTabId,goods)

    if not goods then
        return
    end

    self.goods[storeTabId] = goods 
end

function StoreMainUI:checkStoreTabOpen(openCondition)
    local open = GlobalApi:getOpenInfo_new(openCondition)
    return open
end

function StoreMainUI:chooseBtn(tabId)

    if self.oldChoosId == tabId then
        return
    end

    for i=1,#self.tabBtn do
        if self.tabBtn[i].id == tabId then
            self.tabBtn[i].tabbtn:loadTextureNormal(checkBtnTexture.sel)
            self.tabBtn[i].tabTx:setTextColor(cc.c4b(241, 253, 254, 255))
            self.tabBtn[i].tabTx:enableOutline(cc.c4b(42, 84, 75, 255), 2)
        else
            self.tabBtn[i].tabbtn:loadTextureNormal(checkBtnTexture.nor)
            self.tabBtn[i].tabTx:setTextColor(cc.c4b(84, 131, 127, 255))
            self.tabBtn[i].tabTx:enableOutline(cc.c4b(28, 37, 39, 255), 2)
        end
    end

    self.oldChoosId = tabId

    if not self.goods[self.oldChoosId] then

        local args = {
            id = self.storeType,
            tab = tabId,
        }
        MessageMgr:sendPost('get','shop',json.encode(args),function (response)
            
            local code = response.code
            local data = response.data
            if code == 0 then
                local shop = data.shop
                self:setGoodsData(tabId,shop.goods)
                self:updateGoods()
                self:setRefreshData(tabId,shop.manual_refresh_count,shop.next_refresh_time)
                self:updateInfo(tabId)
            else
                local descStr = response.desc or ''
                local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_ERROR'),descStr)
                promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
            end
        end)
    else
        self:updateGoods()
        self:updateInfo(tabId)
    end

    if self.shopTabCfg[tabId] then
        local resTab = self.shopTabCfg[tabId].resShow
        UIManager:showSidebar({1,15},resTab,true)
    end 
end

function StoreMainUI:setRefreshData(storeTabId,manualcnt,refreshtime)

    if not self.refreshInfo[storeTabId] then
        self.refreshInfo[storeTabId] = {
            manualcnt = manualcnt,
            refreshtime = refreshtime,
        }
    else
        self.refreshInfo[storeTabId].manualcnt = manualcnt
        self.refreshInfo[storeTabId].refreshtime = refreshtime
    end
    
end

--更新刷新信息显示
function StoreMainUI:updateInfo(tabId)

    if not self.shopTabCfg[tabId] then
        return
    end

    if not self.refreshInfo[tabId] then
        return
    end

    local refreshTime = self.refreshInfo[tabId].refreshtime
    local manualcnt = self.refreshInfo[tabId].manualcnt

    local freshTipsTx = self.herobg:getChildByName("refresh_tip")
    local refreshTimeTx = self.herobg:getChildByName("refresg_time")
    local descTx = self.herobg:getChildByName("desc_tx")

    local shopType = self.shopTabCfg[tabId].type
    local desc1 = self.shopTabCfg[tabId].desc1
    if shopType == 'fixedReset' then
        freshTipsTx:setString(GlobalApi:getLocalStr_new("STORE_STR_INFOTX04"))
        descTx:setString('')
        self:timeoutCallback(refreshTimeTx,refreshTime)
    else
        freshTipsTx:setString('')
        descTx:setString(desc1)
    end

    --重置
    local desc2 = self.shopTabCfg[tabId].desc2
    local resetCost
    if self.shopTabCfg[tabId].resetCost1[1]  then
        local displayobj = DisplayData:getDisplayObj(self.shopTabCfg[tabId].resetCost1[1])
        if not displayobj then
            return
        end
        local ownCnt = displayobj:getOwnNum()
        local cnt = displayobj:getNum()
        if ownCnt >= cnt then
            resetCost = self.shopTabCfg[tabId].resetCost1
        else
           resetCost =self.shopTabCfg[tabId].resetCost2
        end
    else
        resetCost =self.shopTabCfg[tabId].resetCost2
    end


    local manualResetType = self.shopTabCfg[tabId].autonomicReset
    local manual_update = self.herobg:getChildByName("manual_update")
    local autoDescTx = self.herobg:getChildByName("auto_desc")
    manual_update:setVisible(manualResetType == 1)    
    if manualResetType == 1 then

        autoDescTx:setString('')
        local restCostIcon = manual_update:getChildByName("cost_icon")
        local restCostTx = manual_update:getChildByName("cost_tx")
        local refresh_btn = manual_update:getChildByName("refresh_btn")
        local btnTx = refresh_btn:getChildByName("text")
        btnTx:setString(GlobalApi:getLocalStr_new("STORE_BTN_TX1"))
        local remain_tx = manual_update:getChildByName("remain_tx")
        local remain_num = manual_update:getChildByName("remain_num")

        local resetLimitStr = self.shopTabCfg[tabId].resetLimit
        if resetLimitStr ~= '0' then

            local limitInfo = string.split(resetLimitStr , '.')
            if #limitInfo ~= 2 then
                return
            end

            local cfgName,fieldName = limitInfo[1],limitInfo[2]
            local cfg = GameData:getConfData(cfgName)
            local cfgkey = ''
            if cfgName == 'vip' then
                local vipLv = UserData:getUserObj():getVip()
                cfgkey = tostring(vipLv)
            end

            local totalCnt = cfg[cfgkey][fieldName]
            if not totalCnt then
                return
            end

            local remainCnt = totalCnt - manualcnt
            remain_tx:setString(GlobalApi:getLocalStr_new("STORE_STR_INFOTX05"))
            remain_num:setString(remainCnt)
            local color = remainCnt > 0 and COLOR_TYPE.GREEN1 or COLOR_TYPE.RED1
            local outlineColor = remainCnt > 0 and COLOROUTLINE_TYPE.GREEN1 or COLOROUTLINE_TYPE.RED1
            remain_num:setTextColor(color) 
            remain_num:enableOutline(outlineColor, 1)

        else
            remain_tx:setString('')
            remain_num:setString('')
        end

        local displayobj = DisplayData:getDisplayObj(resetCost[1])
        if not displayobj then
            return
        end
        restCostIcon:loadTexture(displayobj:getIcon())
        local ownCnt = displayobj:getOwnNum()
        local costNum = displayobj:getNum()
        restCostTx:setString(costNum)
        local color = ownCnt < costNum and COLOR_TYPE.RED1 or COLOR_TYPE.GREEN1
        local outlineColor = ownCnt < costNum and COLOROUTLINE_TYPE.RED1 or COLOROUTLINE_TYPE.GREEN1
        restCostTx:setTextColor(color) 
        restCostTx:enableOutline(outlineColor, 1)

        refresh_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then

                if ownCnt < costNum then
                    local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_NOTENOUGH'),displayobj:getName())
                    promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
                    return
                end

                local args = {
                    id = self.storeType,
                    tab  = tabId,
                }
                MessageMgr:sendPost('refresh','shop',json.encode(args),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local shop  = data.shop
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self:setGoodsData(tabId,shop.goods)
                        self:updateGoods()
                        self:setRefreshData(tabId,shop.manual_refresh_count,shop.next_refresh_time)
                        self:updateInfo(tabId)
                        promptmgr:showSystenHint(GlobalApi:getLocalStr_new("STORE_STR_INFOTX06"), COLOR_TYPE.GREEN)
                    else
                        local descStr = response.desc or ''
                        local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_ERROR'),descStr)
                        promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
                    end
                end)
            end
        end)
    else
        autoDescTx:setString(desc2)
    end
end

function StoreMainUI:timeoutCallback(parent,nextTime)
    local diffTime = 0
    if nextTime ~= 0 then
        diffTime = nextTime - GlobalData:getServerTime()
    end

    if diffTime < 0 then
        return
    end

    local node = cc.Node:create()
    node:setTag(9527)    
    node:setPosition(cc.p(0,0))
    parent:removeChildByTag(9527)
    parent:addChild(node)

    Utils:createCDLabel(node,diffTime,COLOR_TYPE.GREEN1,COLOROUTLINE_TYPE.GREEN1,CDTXTYPE.NONE,'',COLOR_TYPE.YELLOW1,COLOROUTLINE_TYPE.YELLOW1,20,function () 
        parent:removeAllChildren()
    end)        
end

function StoreMainUI:updateGoods()

    local goods = self.goods[self.oldChoosId]
    if not goods then
        return
    end

    self:stopSchedule()

    local totalLine = math.ceil(#goods/3)
    local curIndex = 1
    self.goods_sv:removeAllChildren()
    self.goods_sv:setTouchEnabled(false)

    self.arrow_img:setVisible(totalLine>=3)
    if totalLine >= 3 then
        self.arrow_img:stopAllActions()
        local index = 1
        local act = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function ()
            local res = 'uires/ui_new/store/down_arrows'..index..'.png'
            self.arrow_img:loadTexture(res)
            index = index + 1
            if index > 3 then
                index = 1
            end
        end)))
        self.arrow_img:runAction(act)
    else
        self.arrow_img:stopAllActions()
    end

    local function callBack()
        if curIndex <= totalLine then

            local cellBg = self.goods_sv:getChildByName("cell"..curIndex)
            if not cellBg then
                cellBg = self.cloneCell:clone()
                cellBg:setName("cell"..curIndex)
                local zOrder = totalLine-(curIndex-1)
                self.goods_sv:addChild(cellBg, zOrder)
            end

            self:updateItem(cellBg, curIndex)
            curIndex = curIndex + 1
        else
            self:stopSchedule()
            self.goods_sv:setTouchEnabled(true)

            local size = self.goods_sv:getContentSize()
            local cellHeight = 233-15
            if totalLine > 0 then
                if totalLine * cellHeight > cellHeight then
                    self.goods_sv:setInnerContainerSize(cc.size(size.width,totalLine * cellHeight))
                else
                    self.goods_sv:setInnerContainerSize(size)
                end
            
                local function getPos(i)
                    local size2 = self.goods_sv:getInnerContainerSize()
                    return cc.p(0,size2.height-cellHeight* i)
                end
                for i=1,totalLine do
                    local cell = self.goods_sv:getChildByName("cell"..i)
                    if cell then
                        cell:setPosition(getPos(i))
                    end
                end
            end
        end
    end
    self._scheduleId        = GlobalApi:interval(callBack,0.05)
end

function StoreMainUI:updateItem(cellBg,lineId)

    if not cellBg then
        return
    end

    cellBg:stopAllActions()
    cellBg:setVisible(true)
    cellBg:setOpacity(0)
    cellBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

    local goods = self.goods[self.oldChoosId]
    if not goods then
        return
    end

    for i=1,3 do
        local realIndex = (lineId-1)*3+i
        local itemBg = cellBg:getChildByName("item_bg"..i)
        local itemGoods = goods[realIndex]
        if itemGoods then
            itemBg:setVisible(true)

            local groupId = itemGoods.groupId
            local goodsId = itemGoods.goodsId
            local buycnt  = itemGoods.buy

            local goodsCfg = self.shopGoodsCfg[groupId][goodsId]
            local displayobj = DisplayData:getDisplayObj(goodsCfg.get[1])
            if not displayobj then
                return
            end

            local ligh_bg = itemBg:getChildByName("ligh_bg")
            ligh_bg:loadTexture(displayobj:qualityLight())

            local itemIcon = itemBg:getChildByName("item")
            itemIcon:loadTexture(displayobj:getIcon())

            local nameTx = itemBg:getChildByName("name_tx")
            nameTx:setString(displayobj:getName())
            nameTx:setTextColor(displayobj:getNameColor())
            nameTx:enableOutline(displayobj:getNameOutlineColor(), 2)

            local numTx = itemBg:getChildByName("num_tx")
            numTx:setString("x"..displayobj:getNum())

            local labelStr   = goodsCfg.label
            local discountBg = itemBg:getChildByName("discount_bg")
            local discountTx = discountBg:getChildByName("text")
            discountTx:setString(labelStr)
            discountBg:setVisible(labelStr ~='0')

            local fitBuyCondition = false
            local buyLimitType = goodsCfg.buyLimitType
            local buyLimitValue = goodsCfg.buyLimitValue[1]
            local conditionStr = ''
            if buyLimitType ~= '' then
                if buyLimitType == 'level' then
                    local level = UserData:getUserObj():getLv()
                    fitBuyCondition = level >= buyLimitValue
                    if not fitBuyCondition then
                        conditionStr = string.format(GlobalApi:getLocalStr_new('STORE_STR_INFOTX07'),buyLimitValue)
                    end
                end
            else
                fitBuyCondition = true
            end

            local timesLimit = goodsCfg.timesLimit
            local limit_tx = itemBg:getChildByName("limit_tx")
            local lockImg = itemBg:getChildByName("lock")
            limit_tx:setString(conditionStr)
            lockImg:setVisible(not fitBuyCondition) 
            local haveTimesLimit = timesLimit > 0
            local remainCnt = timesLimit - buycnt
            if remainCnt <= 0 then
                remainCnt = 0
            end

            if fitBuyCondition and haveTimesLimit and remainCnt <= 0 then
                limit_tx:setString(GlobalApi:getLocalStr_new("STORE_STR_INFOTX08"))
            end

            limit_tx:setColor( COLOR_TYPE.RED1)
            limit_tx:enableOutline(COLOROUTLINE_TYPE.RED1, 1)

            if fitBuyCondition and haveTimesLimit and remainCnt > 0 then

                local rt = limit_tx:getChildByName("rtx")
                if not rt then
                    rt = xx.RichText:create()
                    rt:setAnchorPoint(cc.p(0.5, 0.5))
                    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("STORE_STR_INFOTX01"), 20, cc.c4b(253, 249, 227, 255))
                    rt1:setStroke(cc.c4b(66, 51, 32, 255), 1)
                    rt1:clearShadow()
                    local rt2 = xx.RichTextLabel:create(remainCnt, 20, COLOR_TYPE.GREEN1)
                    rt2:setStroke(COLOROUTLINE_TYPE.GREEN1, 1)
                    rt2:clearShadow()
                    local rt3 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("STORE_STR_INFOTX02"), 20, cc.c4b(253, 249, 227, 255))
                    rt3:setStroke(cc.c4b(66, 51, 32, 255), 1)
                    rt3:clearShadow()

                    rt:addElement(rt1)
                    rt:addElement(rt2)
                    rt:addElement(rt3)
                    rt:setAlignment("middle")
                    rt:setPosition(cc.p(0,0))
                    rt:setContentSize(cc.size(400, 30))
                    rt:format(true)
                    limit_tx:addChild(rt)
                end
            end

            --显示消耗
            local buyBtn = itemBg:getChildByName("buy_btn")
            local icon = buyBtn:getChildByName("icon")
            local btnTx = buyBtn:getChildByName("text")
            local buyBtnSize = buyBtn:getContentSize()
            if #goodsCfg.cost > 1 then
                btnTx:setString(GlobalApi:getLocalStr_new('STORE_STR_INFOTX03'))
                icon:setVisible(false)
                btnTx:setPositionX(buyBtnSize.width/2)
            else
                local displaycostobj = DisplayData:getDisplayObj(goodsCfg.cost[1])
                if not displaycostobj then
                    return
                end
                icon:setVisible(true)
                icon:loadTexture(displaycostobj:getIcon())
                icon:setScale(0.8)
                btnTx:setString(displaycostobj:getNum())
                btnTx:setPositionX(56)
            end
            
            buyBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then

                    if not fitBuyCondition then
                        local act = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.5),cc.ScaleTo:create(0.3, 1))
                        limit_tx:runAction(act)
                        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('STORE_STR_INFOTX09'), COLOR_TYPE.RED)
                        return
                    end

                    if haveTimesLimit and remainCnt <= 0 then 
                        local act = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.5),cc.ScaleTo:create(0.3, 1))
                        limit_tx:runAction(act)
                        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('STORE_STR_INFOTX10'), COLOR_TYPE.RED)
                        return
                    end

                    local args = {
                        id = self.storeType,
                        tab  = self.oldChoosId,
                        goods_index  = realIndex,
                    }

                    MessageMgr:sendPost('buy','shop',json.encode(args),function (response)
                        
                        local code = response.code
                        local data = response.data
                        if code == 0 then
                            local cost = data.costs
                            if cost then
                                GlobalApi:parseAwardData(cost)
                            end
                            local awards = data.awards
                            if awards then
                                GlobalApi:parseAwardData(awards)
                                GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                            end
                            goods[realIndex].buy = goods[realIndex].buy+1
                        else
                            local descStr = response.desc or ''
                            local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_ERROR'),descStr)
                            promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
                        end
                    end)
                end
            end)
        else
            itemBg:setVisible(false)
        end
    end
end

return StoreMainUI