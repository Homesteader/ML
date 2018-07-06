local BattleCounterV2UI = class("BattleCounterV2UI", BaseUI)

local COUNTER_COLOR_BROWN = cc.c4b(87, 38, 4, 255)

function BattleCounterV2UI:ctor()
    self.uiIndex = GAME_UI.UI_BATTLE_COUNTER_V2
end

function BattleCounterV2UI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bgImg = self.root:getChildByName("bg_img")
    bgImg:setContentSize(winSize)
    bgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))

    local closeBtn = bgImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winSize.width, winSize.height))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    self.leftBtn = bgImg:getChildByName("left_btn")
    self.rightBtn = bgImg:getChildByName("right_btn")
    self.leftBtn:setPosition(cc.p(50, winSize.height/2))
    self.rightBtn:setPosition(cc.p(winSize.width-50, winSize.height/2))
    self.leftBtn:setTouchEnabled(false)
    self.leftBtn:setBright(false)
    self.leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.pv:scrollToItem(self.pv:getCurrentPageIndex() - 1)
        end
    end)
    self.rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.pv:scrollToItem(self.pv:getCurrentPageIndex() + 1)
        end
    end)

    self.pv = bgImg:getChildByName("pv")
    self.pv:setContentSize(winSize)
    self.pv:setPosition(cc.p(winSize.width/2, winSize.height/2))

    self:initPage()
end

function BattleCounterV2UI:initPage()
    local winSize = cc.Director:getInstance():getWinSize()
    local indexs = {3, 1, 2}
    for _, i in ipairs(indexs) do
        local node = cc.CSLoader:createNode("csb/battlecounter_page.csb")
        local bg_alpha_1 = node:getChildByName("bg_alpha_1")
        bg_alpha_1:setContentSize(winSize)

        local bg_alpha_2 = bg_alpha_1:getChildByName("bg_alpha_2")
        bg_alpha_2:setPosition(cc.p(winSize.width/2, winSize.height/2))

        local tiao_img = bg_alpha_2:getChildByName("tiao_img")
        local soldier_type_img = tiao_img:getChildByName("soldier_type_img")
        soldier_type_img:loadTexture("uires/ui/common/soldier_" .. i .. ".png")

        local soldier_type_tx = tiao_img:getChildByName("soldier_type_tx")
        soldier_type_tx:setString(GlobalApi:getLocalStr("SOLDIER_LEGION_" .. i))

        local help_btn = tiao_img:getChildByName("help_btn")
        help_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                BattleMgr:showBattleCounter()
            end
        end)

        local desc_tx_1 = tiao_img:getChildByName("desc_tx_1")
        desc_tx_1:setString(GlobalApi:getLocalStr("STR_COUNTER_DESC_1"))

        local desc_tx_2 = tiao_img:getChildByName("desc_tx_2")
        local soldier_counter = i - 1
        if soldier_counter <= 0 then
            soldier_counter = 3
        end
        desc_tx_2:setString(GlobalApi:getLocalStr("SOLDIER_TYPE_" .. soldier_counter))

        local desc_tx_3 = tiao_img:getChildByName("desc_tx_3")
        desc_tx_3:setString("+20%")

        local desc_tx_4 = tiao_img:getChildByName("desc_tx_4")
        desc_tx_4:setString(GlobalApi:getLocalStr("STR_MOVE_SPEED"))

        local desc_tx_5 = tiao_img:getChildByName("desc_tx_5")
        soldier_counter = i + 1
        if soldier_counter > 3 then
            soldier_counter = 1
        end
        desc_tx_5:setString(GlobalApi:getLocalStr("SOLDIER_SPEED_TYPE_" .. soldier_counter))

        local floor_img = bg_alpha_2:getChildByName("floor_img")

        if i == 1 then
            local textPosX = 110
            local textPosY = 50
            local text1 = ccui.Text:create()
            text1:setFontName("font/gamefont.ttf")
            text1:setFontSize(23)
            text1:setColor(COUNTER_COLOR_BROWN)
            text1:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_15"))
            text1:setAnchorPoint(cc.p(0, 0.5))
            text1:setPosition(cc.p(textPosX, textPosY))
            tiao_img:addChild(text1)
            local textSize1 = text1:getContentSize()

            local text2 = ccui.Text:create()
            text2:setFontName("font/gamefont.ttf")
            text2:setFontSize(23)
            text2:setColor(COLOR_TYPE.RED)
            text2:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_16"))
            text2:setAnchorPoint(cc.p(0, 0.5))
            text2:setPosition(cc.p(textPosX + textSize1.width, textPosY))
            tiao_img:addChild(text2)
            local textSize2 = text2:getContentSize()

            local text3 = ccui.Text:create()
            text3:setFontName("font/gamefont.ttf")
            text3:setFontSize(23)
            text3:setColor(COUNTER_COLOR_BROWN)
            text3:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_17"))
            text3:setAnchorPoint(cc.p(0, 0.5))
            text3:setPosition(cc.p(textPosX + textSize1.width + textSize2.width, textPosY))
            tiao_img:addChild(text3)
            local textSize3 = text3:getContentSize()

            local text4 = ccui.Text:create()
            text4:setFontName("font/gamefont.ttf")
            text4:setFontSize(23)
            text4:setColor(COLOR_TYPE.RED)
            text4:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_18"))
            text4:setAnchorPoint(cc.p(0, 0.5))
            text4:setPosition(cc.p(textPosX + textSize1.width + textSize2.width + textSize3.width, textPosY))
            tiao_img:addChild(text4)

            local redImg = ccui.ImageView:create("uires/ui/battlecounter/red_tiao_1.png")
            redImg:setPosition(cc.p(425, 155))
            floor_img:addChild(redImg)

            local arrow1 = ccui.ImageView:create("uires/ui/battlecounter/arrow.png")
            arrow1:setOpacity(0)
            arrow1:setPosition(cc.p(280, 155))
            floor_img:addChild(arrow1)

            local arrow2 = ccui.ImageView:create("uires/ui/battlecounter/arrow.png")
            arrow2:setOpacity(0)
            arrow2:setPosition(cc.p(430, 155))
            floor_img:addChild(arrow2)

            redImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                arrow1:stopAllActions()
                arrow1:setOpacity(0)
                arrow1:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
                arrow2:stopAllActions()
                arrow2:setOpacity(0)
                arrow2:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end), cc.DelayTime:create(1))))

            local soldier1 = ccui.ImageView:create("uires/ui/battlecounter/soldier4.png")
            soldier1:setPosition(cc.p(190, 200))
            floor_img:addChild(soldier1)

            local soldier2 = ccui.ImageView:create("uires/ui/battlecounter/soldier8.png")
            soldier2:setPosition(cc.p(380, 100))
            floor_img:addChild(soldier2)

            local soldier3 = ccui.ImageView:create("uires/ui/battlecounter/soldier7.png")
            soldier3:setPosition(cc.p(550, 200))
            floor_img:addChild(soldier3)

            local soldier4 = ccui.ImageView:create("uires/ui/battlecounter/soldier7.png")
            soldier4:setPosition(cc.p(680, 200))
            floor_img:addChild(soldier4)
        elseif i == 2 then
            local textPosX = 180
            local textPosY = 50
            local text1 = ccui.Text:create()
            text1:setFontName("font/gamefont.ttf")
            text1:setFontSize(23)
            text1:setColor(COUNTER_COLOR_BROWN)
            text1:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_15"))
            text1:setAnchorPoint(cc.p(0, 0.5))
            text1:setPosition(cc.p(textPosX, textPosY))
            tiao_img:addChild(text1)
            local textSize1 = text1:getContentSize()

            local text2 = ccui.Text:create()
            text2:setFontName("font/gamefont.ttf")
            text2:setFontSize(23)
            text2:setColor(COLOR_TYPE.RED)
            text2:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_19"))
            text2:setAnchorPoint(cc.p(0, 0.5))
            text2:setPosition(cc.p(textPosX + textSize1.width, textPosY))
            tiao_img:addChild(text2)
            local textSize2 = text2:getContentSize()

            local text3 = ccui.Text:create()
            text3:setFontName("font/gamefont.ttf")
            text3:setFontSize(23)
            text3:setColor(COUNTER_COLOR_BROWN)
            text3:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_20"))
            text3:setAnchorPoint(cc.p(0, 0.5))
            text3:setPosition(cc.p(textPosX + textSize1.width + textSize2.width, textPosY))
            tiao_img:addChild(text3)

            local arrow = ccui.ImageView:create("uires/ui/battlecounter/arrow2.png")
            arrow:setPosition(cc.p(290, 115))
            floor_img:addChild(arrow)

            local soldier1 = ccui.ImageView:create("uires/ui/battlecounter/soldier5.png")
            soldier1:setPosition(cc.p(190, 200))
            floor_img:addChild(soldier1)

            local soldier2 = ccui.ImageView:create("uires/ui/battlecounter/soldier7.png")
            soldier2:setPosition(cc.p(420, 100))
            floor_img:addChild(soldier2)

            local soldier3 = ccui.ImageView:create("uires/ui/battlecounter/soldier7.png")
            soldier3:setPosition(cc.p(550, 200))
            floor_img:addChild(soldier3)

            local soldier4 = ccui.ImageView:create("uires/ui/battlecounter/soldier8.png")
            soldier4:setPosition(cc.p(680, 200))
            floor_img:addChild(soldier4)
        elseif i == 3 then
            local textPosX = 70
            local textPosY = 50
            local text1 = ccui.Text:create()
            text1:setFontName("font/gamefont.ttf")
            text1:setFontSize(23)
            text1:setColor(COUNTER_COLOR_BROWN)
            text1:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_21"))
            text1:setAnchorPoint(cc.p(0, 0.5))
            text1:setPosition(cc.p(textPosX, textPosY))
            tiao_img:addChild(text1)
            local textSize1 = text1:getContentSize()

            local text2 = ccui.Text:create()
            text2:setFontName("font/gamefont.ttf")
            text2:setFontSize(23)
            text2:setColor(COLOR_TYPE.RED)
            text2:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_22"))
            text2:setAnchorPoint(cc.p(0, 0.5))
            text2:setPosition(cc.p(textPosX + textSize1.width, textPosY))
            tiao_img:addChild(text2)
            local textSize2 = text2:getContentSize()

            local text3 = ccui.Text:create()
            text3:setFontName("font/gamefont.ttf")
            text3:setFontSize(23)
            text3:setColor(COUNTER_COLOR_BROWN)
            text3:setString(GlobalApi:getLocalStr("STR_SEARCH_AI_23"))
            text3:setAnchorPoint(cc.p(0, 0.5))
            text3:setPosition(cc.p(textPosX + textSize1.width + textSize2.width, textPosY))
            tiao_img:addChild(text3)

            local redImg = ccui.ImageView:create("uires/ui/battlecounter/red_tiao_2.png")
            redImg:setPosition(cc.p(415, 120))
            floor_img:addChild(redImg)

            local arrow1 = ccui.ImageView:create("uires/ui/battlecounter/arrow.png")
            arrow1:setOpacity(0)
            arrow1:setPosition(cc.p(300, 152))
            floor_img:addChild(arrow1)

            local arrow2 = ccui.ImageView:create("uires/ui/battlecounter/arrow.png")
            arrow2:setOpacity(0)
            arrow2:setPosition(cc.p(480, 152))
            floor_img:addChild(arrow2)

            local arrow3 = ccui.ImageView:create("uires/ui/battlecounter/arrow3.png")
            arrow3:setOpacity(0)
            arrow3:setPosition(cc.p(625, 120))
            arrow3:setRotation(50)
            floor_img:addChild(arrow3)

            redImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                arrow1:stopAllActions()
                arrow1:setOpacity(0)
                arrow1:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
                arrow2:stopAllActions()
                arrow2:setOpacity(0)
                arrow2:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
                arrow3:stopAllActions()
                arrow3:setOpacity(0)
                arrow3:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end), cc.DelayTime:create(0.8))))

            local soldier1 = ccui.ImageView:create("uires/ui/battlecounter/soldier6.png")
            soldier1:setPosition(cc.p(190, 200))
            floor_img:addChild(soldier1)

            local soldier2 = ccui.ImageView:create("uires/ui/battlecounter/soldier7.png")
            soldier2:setPosition(cc.p(550, 100))
            floor_img:addChild(soldier2)

            local soldier3 = ccui.ImageView:create("uires/ui/battlecounter/soldier8.png")
            soldier3:setPosition(cc.p(680, 100))
            floor_img:addChild(soldier3)
        end

        bg_alpha_1:removeFromParent(false)

        self.pv:addPage(bg_alpha_1)
    end

    self.pv:setCurrentPageIndex(0)
    self.currIndex = 0

    self.root:scheduleUpdateWithPriorityLua(function (dt)
        if self.currIndex ~= self.pv:getCurrentPageIndex() then
            if self.guideHand then
                self.guideHand:removeFromParent()
                self.guideHand = nil
            end
            self.currIndex = self.pv:getCurrentPageIndex()
            if self.currIndex == 0 then
                self.leftBtn:setTouchEnabled(false)
                self.leftBtn:setBright(false)
            elseif self.currIndex == 1 then
                self.leftBtn:setTouchEnabled(true)
                self.rightBtn:setTouchEnabled(true)
                self.leftBtn:setBright(true)
                self.rightBtn:setBright(true)
            elseif self.currIndex == 2 then
                self.rightBtn:setTouchEnabled(false)
                self.rightBtn:setBright(false)
            end
        end
    end, 0)
end

function BattleCounterV2UI:guideScrollContent()
    local winSize = cc.Director:getInstance():getWinSize()
    local guidetextConf = GameData:getConfData("local/guidetext")["GUIDE_TIPS_19"]
    local bgImg = self.root:getChildByName("bg_img")
    local dialogNode = cc.Node:create()
    local dialog = cc.Sprite:create("uires/ui/guide/bg_dialog3.png")
    local npc = GlobalApi:createSpineByName("guide_npc_7", "spine/guide_npc_7/guide_npc_7", 1)
    npc:setScaleX(0.6)
    npc:setScaleY(0.6)
    npc:setAnimation(0, "idle", true)
    npc:setPosition(cc.p(50, 0))
    local label = cc.Label:createWithTTF(guidetextConf.text, "font/gamefont1.TTF", 21)
    label:setTextColor(COLOR_TYPE.BLACK)
    label:enableOutline(cc.c4b(255, 255, 255, 255), 1)
    dialogNode:addChild(npc)
    dialogNode:addChild(dialog)
    dialogNode:addChild(label)
    bgImg:addChild(dialogNode)
    dialogNode:setPosition(cc.p(100, 60))
    dialogNode:setScale(0.8)

    local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    hand:getAnimation():play("idle02", -1, -1)
    hand:getAnimation():gotoAndPause(0)
    hand:setRotation(180)
    bgImg:addChild(hand)
    local startPos = cc.p(winSize.width/2 + 200, winSize.height/2)
    local endPos = cc.p(winSize.width/2 - 200, winSize.height/2)
    hand:setPosition(startPos)
    hand:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, endPos), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        hand:setPosition(startPos)
    end))))

    self.guideHand = hand
    GuideMgr:finishCurrGuide()
end

return BattleCounterV2UI