local StoreEntranceUI = class("StoreEntranceUI", BaseUI)
local MAX_TAB = 6
function StoreEntranceUI:ctor()
	self.uiIndex = GAME_UI.UI_SHOPMAIN
    self.data = data
end

function StoreEntranceUI:stopSchedule()
    if self._scheduleId then
        GlobalApi:clearScheduler(self._scheduleId)
        self._scheduleId = nil
    end
end

function StoreEntranceUI:onHide()
    self:stopSchedule()
end

function StoreEntranceUI:setUIBackInfo()
    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_SHOPMAIN), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideStoreEntranceUI()
        end
    end,1)
end

function StoreEntranceUI:init()

    local bgImg = self.root:getChildByName("bg_img")
    self:adaptUI(bgImg)

    self:setUIBackInfo()

    local winSize = cc.Director:getInstance():getVisibleSize()
    local listView = bgImg:getChildByName("list_view")
    listView:setContentSize(cc.size(960,521))
    listView:setAnchorPoint(cc.p(0.5,0))
    listView:setPositionX(winSize.width/2)
    local cloneCell = bgImg:getChildByName("clone_bg")

    self:stopSchedule()

    self.shopCfg = GameData:getConfData("shopuniversaltab") 
    local totalLine = math.ceil(#self.shopCfg/2)
    local curIndex = 1
    listView:removeAllChildren()
    listView:setTouchEnabled(false)
    listView:setScrollBarEnabled(false)
    local function callBack()
        if curIndex <= totalLine then

            local cellBg = listView:getItem(curIndex-1)
            if not cellBg then
                cellBg = cloneCell:clone()
                listView:pushBackCustomItem(cellBg)
            end

            self:updateItem(cellBg, curIndex)
            curIndex = curIndex + 1
        else
            self:stopSchedule()
            listView:setTouchEnabled(true)
        end
    end
    self._scheduleId        = GlobalApi:interval(callBack,0.05)
end

function StoreEntranceUI:updateItem(cellBg,lineId)

    cellBg:stopAllActions()
    cellBg:setVisible(true)
    cellBg:setOpacity(0)
    cellBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

    for i=1,2 do
        local storeBg = cellBg:getChildByName("store_"..i)
        local realIndex = (lineId-1)*2+i
        local cfg = self.shopCfg[realIndex]
        if cfg then
            storeBg:setVisible(true)
            local nameTx = storeBg:getChildByName("name_tx")
            local contentImg = storeBg:getChildByName("nei_bg")
            nameTx:setString(cfg.name)
            contentImg:loadTexture("uires/ui_new/store/"..cfg.icon)
            storeBg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local tabId = self:getFirstTabId(realIndex)
                    if tabId then
                        MainSceneMgr:showStoreMainUI(cfg.id,tabId)
                        MainSceneMgr:hideStoreEntranceUI()
                    else
                        logger("未开放")
                    end
                end
            end)
        else
            storeBg:setVisible(false)
        end
    end
end

function StoreEntranceUI:getFirstTabId(realIndex)

    --页签
    local shopTabCfg = GameData:getConfData("shopuniversalconfig")
    local cfg = self.shopCfg[realIndex]
    local firstTabId
    for i=1,MAX_TAB do
        local tabId = cfg['tab'..i]
        if tabId ~= 0 then
            local openCondition = shopTabCfg[tabId].openCondition
            local open = GlobalApi:getOpenInfo_new(openCondition)
            if open then
                firstTabId = tabId
                break
            end
        end
    end
    return firstTabId
end

return StoreEntranceUI