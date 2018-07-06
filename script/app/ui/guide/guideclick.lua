local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideClick = class("GuideClick", ClassGuideBase)

function GuideClick:ctor(guideNode, guideObj, saveWithClick)
    self.guideObj = guideObj
    self.guideNode = guideNode
    self.flag = true
    self.saveWithClick = saveWithClick
end

function GuideClick:startGuide()
    local guideObj = self.guideObj
    self.uiShowFlag = false
    self.swallowBeforeShow = guideObj.swallowbeforeshow
    local function doit()
        self.uiShowFlag = true
        local parentNode
        local uiObj
        if guideObj.specialui and guideObj.specialui == "sidebar" then
            uiObj = UIManager:getSidebar()
            parentNode = uiObj:getNode()
        else
            uiObj = UIManager:getUIByIndex(guideObj.uiindex)
            parentNode = uiObj.root
        end
        local widget
        local index = 1
        local maxNum = #guideObj.widgetindex
        while index <= maxNum do
            local name = guideObj.widgetindex[index]
            local isActivity = guideObj.isActivity
            if isActivity then
                local activityName = guideObj.activityname
                name =  GuideMgr:getActivityBtnName(activityName)
                if not name then
                    GuideMgr:saveAndFinish()
                    return
                end
            end
            if type(name) == "number" then
               widget = xx.Utils:Get():seekNodeByTag(parentNode, name)
            else
               widget = xx.Utils:Get():seekNodeByName(parentNode, name)
            end
            parentNode = widget
            index = index + 1
        end
        if widget == nil then
            GuideMgr:saveAndFinish()
            return
        end
        self.clickWidget = widget
        local widgetSize = widget:getContentSize()
        local touchScale = self.guideObj.touchScale or 1
        local touchOffsetW = widgetSize.width*(1 - touchScale)/2
        local touchOffsetH = widgetSize.height*(1 - touchScale)/2
        self.touchRect = cc.rect(touchOffsetW+1, touchOffsetH+1, widgetSize.width-touchOffsetW*2-2, widgetSize.height-touchOffsetH*2-2)
        local _propagateTouchEvents = widget:isPropagateTouchEvents()
        widget:setPropagateTouchEvents(false)

        local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
        self.hand = hand
        hand:getAnimation():play("idle01", -1, 1)
        hand:setRotation(guideObj.rotation)
        if guideObj.hideHand then
            hand:setVisible(false)
        end
        local widgetScreenPos = widget:getParent():convertToWorldSpace(cc.p(widget:getPosition()))
        if guideObj.addtowidget then
            hand:setPosition(cc.pAdd(cc.p(widgetSize.width/2, widgetSize.height/2), guideObj.pos))
            hand:setLocalZOrder(100000)
            widget:addChild(hand)
        else
            hand:setPosition(cc.pAdd(widgetScreenPos, guideObj.pos))
            hand:setLocalZOrder(2)
            self.guideNode:addChild(hand)
        end
        local widget2 = ccui.Widget:create()
        self.widget2 = widget2
        widget2:registerScriptHandler(function (event)
            if event == "exit" then
                widget2:unregisterScriptHandler()
                self.clickWidget = nil
                self.widget2 = nil
            end
        end)
        -- widget2:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        -- widget2:setBackGroundColorOpacity(100)
        -- widget2:setBackGroundColor(COLOR_TYPE.YELLOW)
        widget2:setAnchorPoint(cc.p(0, 0))
        widget2:setContentSize(widgetSize)
        widget2:setTouchEnabled(true)
        widget2:setSwallowTouches(false)
        widget2:setPropagateTouchEvents(false)
        widget2:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                if self.saveWithClick then
                    GuideMgr.saveWithMsg = true
                end
            elseif eventType == ccui.TouchEventType.canceled then
                if self.saveWithClick then
                    GuideMgr.saveWithMsg = false
                end
            elseif eventType == ccui.TouchEventType.ended then
                if guideObj.finish == "msg" then
                    CustomEventMgr:addEventListener(CUSTOM_EVENT.MSG_RESPONSE, self, function ()
                        self:clickOver()
                        CustomEventMgr:removeEventListener(CUSTOM_EVENT.MSG_RESPONSE, self)
                        self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
                            self:finish()
                        end)))
                    end)
                elseif guideObj.finish == "normal" then
                    self:clickOver()
                    self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
                        self:finish()
                    end)))
                else
                    self:clickOver()
                end
            end
        end)
        
        -- 是否高亮
        if guideObj.hightlight then
            local winsize = cc.Director:getInstance():getWinSize()
            local pos = widget:getParent():convertToWorldSpace(cc.p(widget:getPosition()))
            local clone = widget:clone()
            clone:setSwallowTouches(false)
            clone:setPosition(pos)
            clone:addClickEventListener(function ()
            end)
            clone:addTouchEventListener(function (sender, eventType)
            end)
            local bg = ccui.ImageView:create("uires/ui/common/bg1_gray44.png")
            bg:setScale9Enabled(true)
            bg:setContentSize(winsize)
            bg:setPosition(winsize.width / 2, winsize.height / 2)
            self.guideNode:addChild(bg)
            self.guideNode:addChild(clone)
            self.cloneWidgetBg = bg
            self.cloneWidget = clone
        end
        -- 显示提示
        if guideObj.showtips then
            local guidetextConf = GameData:getConfData("local/guidetext")[guideObj.tipstext]
            local dialogNode = cc.Node:create()
            self.dialogNode = dialogNode
            local dialog = ccui.ImageView:create("uires/ui/guide/bg_dialog3.png")
            local npc = GlobalApi:createSpineByName("guide_npc_7", "spine/guide_npc_7/guide_npc_7", 1)
            local npcScaleX = guideObj.tipsscalex or 1
            local npcScaleY = guideObj.tipsscaley or 1
            npc:setScaleX(0.6*npcScaleX)
            npc:setScaleY(0.6*npcScaleY)
            npc:setAnimation(0, "idle", true)
            local label = cc.Label:createWithTTF(guidetextConf.text, "font/gamefont1.TTF", 21)
            label:setAlignment(0)
            label:setVerticalAlignment(1)
            label:setMaxLineWidth(230)
            label:setTextColor(COLOR_TYPE.BLACK)
            label:enableOutline(cc.c4b(255, 255, 255, 255), 1)
            local labelSize = label:getContentSize()
            if labelSize.height > 40 then
                dialog:setScale9Enabled(true)
                dialog:setContentSize(dialog:getContentSize().width, labelSize.height + 30)
            end
            dialogNode:addChild(npc)
            dialogNode:addChild(dialog)
            dialogNode:addChild(label)
            self.guideNode:addChild(dialogNode)
            dialogNode:setPosition(cc.pAdd(widgetScreenPos, guideObj.tipspos))
            AudioMgr.playEffect("media/guide/" .. guidetextConf.soundRes, false)
        end
        widget:addChild(widget2)
        if guideObj.func and uiObj and uiObj[guideObj.func] then
            uiObj[guideObj.func](uiObj)
        end
    end
    if guideObj.specialui then
        doit()
    else
        if UIManager:getTopNodeIndex() == guideObj.uiindex and not UIManager:getUIByIndex(guideObj.uiindex)._showAnimation then
            doit()
        else
            CustomEventMgr:addEventListener(CUSTOM_EVENT.UI_SHOW, self, function (uiIndex)
                if UIManager:getTopNodeIndex() == guideObj.uiindex then
                    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
                    doit()
                end
            end)
        end
    end
end

function GuideClick:clickOver()
    if self.clickWidget then
        self.clickWidget:setPropagateTouchEvents(_propagateTouchEvents)
        self.clickWidget = nil
    end
    if self.widget2 then
        self.widget2:removeFromParent()
    end
    self.hand:removeFromParent()
    if self.guideObj.hightlight then
        self.cloneWidgetBg:removeFromParent()
        self.cloneWidget:removeFromParent()
    end
    if self.guideObj.showtips then
        self.dialogNode:removeFromParent()
    end
end

function GuideClick:clear()
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.MSG_RESPONSE, self)
end

function GuideClick:canSwallow(sender)
    self.flag = true
    if self.swallowBeforeShow and not self.uiShowFlag then -- 打开界面前可以随便点
        self.flag = false
    else
        if self.clickWidget and self.clickWidget:isVisible() and self.clickWidget:isTouchEnabled() and not UIManager:isBlockTouch() then
            local pos = sender:getTouchBeganPosition()
            local posx, posy = self.clickWidget:getPosition()
            local wpos = self.clickWidget:convertToNodeSpace(pos)
            if cc.rectContainsPoint(self.touchRect, wpos) then
                self.flag = false
            end
        end
    end
    return self.flag
end

function GuideClick:onClickScreen()
    if self.flag then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("GUIDE_INFO_1"), COLOR_TYPE.GREEN)
    end
end

return GuideClick