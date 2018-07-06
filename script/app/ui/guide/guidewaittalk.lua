local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideWaitTalk = class("GuideWaitTalk", ClassGuideBase)

function GuideWaitTalk:ctor(guideNode, guideObj)
    self.guideObj = guideObj
    self.guideNode = guideNode
    self.flag = true
    self.clickFlag = true
end

function GuideWaitTalk:startGuide()
    local guideObj = self.guideObj
    self.uiShowFlag = false
    self.swallowBeforeShow = guideObj.swallowbeforeshow
    local function doit()
        self.clickFlag = false
        self.uiShowFlag = true
        local uiObj = UIManager:getUIByIndex(guideObj.uiindex)
        local parentNode = uiObj.root
        local widget
        local index = 1
        local maxNum = #guideObj.widgetindex
        while index <= maxNum do
            local name = guideObj.widgetindex[index]
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
        local widgetScreenPos = widget:getParent():convertToWorldSpace(cc.p(widget:getPosition()))
        if guideObj.gridPosArrX then
            local pos = widgetScreenPos
            local size = widget:getContentSize()
            local anchor = widget:getAnchorPoint()
            local diffWidth = size.width*(0.5 - anchor.x)*(((widget:isFlippedX() == true) and -1) or 1)
            local diffHeight = size.height*(0.5 - anchor.y)*(((widget:isFlippedY() == true) and -1) or 1)
            local leftTop = cc.Sprite:create("uires/ui/guide/grid.png")
            local leftBottom = cc.Sprite:create("uires/ui/guide/grid.png")
            local rightTop = cc.Sprite:create("uires/ui/guide/grid.png")
            local rightBottom = cc.Sprite:create("uires/ui/guide/grid.png")
            leftTop:setAnchorPoint(cc.p(0,1))
            leftBottom:setAnchorPoint(cc.p(0,1))
            rightTop:setAnchorPoint(cc.p(0,1))
            rightBottom:setAnchorPoint(cc.p(0,1))
            leftTop:setScale(guideObj.gridScale or 1)
            leftBottom:setScale(guideObj.gridScale or 1)
            rightTop:setScale(guideObj.gridScale or 1)
            rightBottom:setScale(guideObj.gridScale or 1)

            leftBottom:setScaleY(-1*(guideObj.gridScale or 1))
            rightTop:setScaleX(-1*(guideObj.gridScale or 1))
            rightBottom:setScale(-1*(guideObj.gridScale or 1))
            local diff = 20
            leftTop:setPosition(cc.p(pos.x - size.width/2 + diffWidth + guideObj.gridPosArrX[1] - diff,pos.y + size.height/2 + diffHeight + guideObj.gridPosArrY[1] + diff))
            leftBottom:setPosition(cc.p(pos.x - size.width/2 + diffWidth + guideObj.gridPosArrX[2] - diff,pos.y - size.height/2 + diffHeight + guideObj.gridPosArrY[2] - diff))
            rightTop:setPosition(cc.p(pos.x + size.width/2 + diffWidth + guideObj.gridPosArrX[3] + diff,pos.y + size.height/2 + diffHeight + guideObj.gridPosArrY[3] + diff))
            rightBottom:setPosition(cc.p(pos.x + size.width/2 + diffWidth + guideObj.gridPosArrX[4] + diff,pos.y - size.height/2 + diffHeight + guideObj.gridPosArrY[4] - diff))
            self.guideNode:addChild(leftTop)
            self.guideNode:addChild(leftBottom)
            self.guideNode:addChild(rightTop)
            self.guideNode:addChild(rightBottom)
            local diff1 = diff/2
            leftTop:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(diff1,-diff1)),cc.MoveBy:create(0.5,cc.p(-diff1,diff1)))))
            leftBottom:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(diff1,diff1)),cc.MoveBy:create(0.5,cc.p(-diff1,-diff1)))))
            rightTop:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(-diff1,-diff1)),cc.MoveBy:create(0.5,cc.p(diff1,diff1)))))
            rightBottom:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(-diff1,diff1)),cc.MoveBy:create(0.5,cc.p(diff1,-diff1)))))
            self.allGrid = {leftTop,leftBottom,rightTop,rightBottom}
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
            local label = cc.Label:createWithTTF(guidetextConf.text, "font/gamefont1.TTF", 20)
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
            local pos = cc.pAdd(widgetScreenPos, guideObj.tipspos)
            dialogNode:setPosition(cc.p(pos.x,pos.y))
            if guideObj.tipsdialogpos then
                dialog:setPosition(cc.p(guideObj.tipsdialogpos.x,guideObj.tipsdialogpos.y))
                label:setPosition(cc.p(guideObj.tipsdialogpos.x,guideObj.tipsdialogpos.y))
            end
            AudioMgr.playEffect("media/guide/" .. guidetextConf.soundRes, false)
        end
        if guideObj.func and uiObj and uiObj[guideObj.func] then
            uiObj[guideObj.func](uiObj)
        end
    end
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

function GuideWaitTalk:onClickScreen()
    if not self.clickFlag then
        self.clickFlag = true
        self:clickOver()
        self:finish()
    end
end

function GuideWaitTalk:clickOver()
    if self.clickWidget then
        self.clickWidget = nil
    end
    if self.guideObj.hightlight then
        self.cloneWidgetBg:removeFromParent()
        self.cloneWidget:removeFromParent()
    end
    if self.guideObj.showtips then
        self.dialogNode:removeFromParent()
    end

    if self.allGrid then
        for i,v in ipairs(self.allGrid) do
            v:removeFromParent()
        end
        self.allGrid = nil
    end
end

function GuideWaitTalk:clear()
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.MSG_RESPONSE, self)
end

function GuideWaitTalk:canSwallow(sender)
    self.flag = true
    if self.swallowBeforeShow and not self.uiShowFlag then -- 打开界面前可以随便点
        self.flag = false
    end
    return self.flag
end

return GuideWaitTalk