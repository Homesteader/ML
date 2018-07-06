local ArenaHighestRankUI = class("ArenaHighestRankUI", BaseUI)

function ArenaHighestRankUI:ctor(highestRank, diffRank, displayAwards)
    self.uiIndex = GAME_UI.UI_ARENA_HIGHESTRANK
    self.highestRank = highestRank
    self.diffRank = diffRank
    self.displayAwards = displayAwards
end

function ArenaHighestRankUI:init()
    local highestBgImg = self.root:getChildByName("highest_bg_img")
    local highestAlphaImg = highestBgImg:getChildByName("highest_alpha_img")
    self:adaptUI(highestBgImg, highestAlphaImg)

    local middleNode = highestAlphaImg:getChildByName("middle_node")
    local closeBtn = middleNode:getChildByName("ok_btn")
    local btnLabel = closeBtn:getChildByName("text")
    btnLabel:setString(GlobalApi:getLocalStr_new("COMMON_STR_OK"))
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        ArenaMgr:hideArenaHighestRank()
    end)

    local guangImg = middleNode:getChildByName("guang")
    guangImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))

    local badgeIcon = middleNode:getChildByName("badge_icon")
    badgeIcon:loadTexture("uires/icon/badge/huangtong.png")
    
    local curStr = string.format(GlobalApi:getLocalStr_new("AREAN_TIP_TX12"),"黄金",self.highestRank + self.diffRank)
    local rankImg = middleNode:getChildByName("rank_img")
    local rankTx = rankImg:getChildByName("text")
    rankTx:setString(curStr)

    local upStr = string.format(GlobalApi:getLocalStr_new("AREAN_TIP_TX13"),self.diffRank)
    local upImg = middleNode:getChildByName("up_img")
    local upTx = upImg:getChildByName("text")
    upTx:setString(upStr)

end

return ArenaHighestRankUI