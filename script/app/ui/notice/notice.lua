local NoticeUI = class("NoticeUI", BaseUI)

function NoticeUI:ctor()
    self.uiIndex = GAME_UI.UI_NOTICE
end

function NoticeUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local bgNode = bgImg:getChildByName("bg_node")
    self:adaptUI(bgImg, bgNode)

    bgImg:addClickEventListener(function ()
        self:hideUI()
    end)
    
    local imgNotice = bgNode:getChildByName("img_notice")
    local text = imgNotice:getChildByName("text")
    text:setString(GlobalApi:getLocalStr("GAME_NOTICE"))

    local infoLabel = bgNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local img2 = bgNode:getChildByName("img2")
    local sv = img2:getChildByName("sv")
    sv:setScrollBarEnabled(false)

    local svSize = sv:getContentSize()


    local contentWidget = ccui.Widget:create()
    sv:addChild(contentWidget)
    contentWidget:setPosition(cc.p(0, svSize.height))


    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(svSize.width, 40))
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(0,23))
	contentWidget:addChild(richText)

    local str = GlobalData:getContent()
    --local str  = "<font color = '#ffff00ff'>【%s】</font>\n危乱\n之\n中您\n的好\n友\n挺\n身\n而\n出\n，帮\n您镇\n压了\n暴乱\n，获\n得\n<font color='#ffff00ff'>金币x3440</font>"
    --print(str)
	local re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.PALE)
	--re1:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	re1:setFont('font/gamefont1.TTF')
	re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	richText:addElement(re1)
	xx.Utils:Get():analyzeHTMLTag(richText,str)

    richText:format(true)
    local labelheight = richText:getBrushY()
    if labelheight > svSize.height then
    	sv:setInnerContainerSize(cc.size(svSize.width,labelheight))
    end
    contentWidget:setPosition(cc.p(0, sv:getInnerContainerSize().height - 10))
    richText:setPosition(cc.p(0,0))


end

return NoticeUI