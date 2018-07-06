local ArenaEntranceUI = class("ArenaEntranceUI", BaseUI)

function ArenaEntranceUI:ctor(curAreanType)

    self.uiIndex = GAME_UI.UI_ARENA_ENTRANCE
    self.curAreanType = curAreanType or 1 --当前所处竞技场类型
end

function ArenaEntranceUI:setUIBackInfo()
    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_ARENA_ENTRANCE), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ArenaMgr:hideArenaEntrance()
        end
    end,1)
end

function ArenaEntranceUI:onShow()
    self:setUIBackInfo()
end

function ArenaEntranceUI:init()

    local bgimg = self.root:getChildByName("bg_img")
    local alphaimg = bgimg:getChildByName("alpha_img")
    self:adaptUI(bgimg,alphaimg)

    self:setUIBackInfo()

    local arenaTypeCfg = GameData:getConfData("arenabase")
    for i=1,6 do
        local open = i==1
        local cfg = arenaTypeCfg[i]
        local arenaCell = alphaimg:getChildByName("arena_cell"..i) 
        local nameTx = arenaCell:getChildByName("name_text")
        nameTx:setString(string.format(GlobalApi:getLocalStr_new("AREAN_TITLE_TX2"),cfg.name))
        local curIcon = arenaCell:getChildByName("cur_icon")
        curIcon:setVisible(self.curAreanType==i)
        local badageIcon = arenaCell:getChildByName("badage")
        badageIcon:loadTexture("uires/icon/badge/"..cfg.icon)
        badageIcon:ignoreContentAdaptWithSize(true)
        local lockimg = arenaCell:getChildByName("lock")
        local lockTextBg = arenaCell:getChildByName("lock_text_bg")
        local lockTx = lockTextBg:getChildByName("lock_text")
        lockTx:setString("80关解锁")
        lockimg:setVisible(not open)
        lockTextBg:setVisible(not open)
        arenaCell:setTouchEnabled(open)
        arenaCell:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                ArenaMgr:showArena(i)
            end
        end)
    end

end

return ArenaEntranceUI