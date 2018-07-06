local GetWayFragmentUI = class("GetWayFragmentUI", BaseUI)

function GetWayFragmentUI:ctor(obj)
    self.uiIndex = GAME_UI.UI_GET_WAY_FRAGMENT_UI_PANNEL
    self.obj = obj
end

function GetWayFragmentUI:init()
	local bg1 = self.root:getChildByName("bg1")
	self:adaptUI(bg1)

    local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("RELOAD_NEW_CLIENT"), "font/gamefont.ttf", 25)
	msg:setAnchorPoint(cc.p(0, 1))
	msg:setPosition(cc.p(262, 216))
	msg:setMaxLineWidth(30)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	msg:setColor(COLOR_TYPE.ORANGE)
	msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    self.root:addChild(msg)
    msg:setVisible(false)

    bg1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetWayFragmentUI()
        end
    end)

	local winSize = cc.Director:getInstance():getVisibleSize()

    local img4 = self.root:getChildByName('img4')

    local useEffect = self.obj:getUseEffect()
    local heroBoxConfData = GameData:getConfData("herobox")[tonumber(useEffect)]
    local awards = heroBoxConfData.awards
    local displayobj = DisplayData:getDisplayObjs(awards)
    local width = 210.36
    local num = #displayobj
    if num == 3 then
        img4:setVisible(false)
    end
    local offset = (winSize.width - num*width)/(num + 1)

    for i = 1,num do
        local img = self.root:getChildByName('img' .. i)
        img:setPositionX(offset + (i - 1)*(width + offset))
        img:setPositionY(309.00)

        local data = displayobj[i]
        local roleobj = RoleData:getRoleInfoById(data:getId())

        local soliderImg = img:getChildByName('solider_img')
        local soliderId = roleobj:getSoldierId() or 1
        soliderImg:loadTexture('uires/ui/common/'..'soldier_'..soliderId..'.png')

        local quality = roleobj:getQuality()
        
        if quality == 6 then
            img:loadTexture('uires/ui/common/bg_red.png')
        else
            img:loadTexture('uires/ui/common/bg_orange.png')
        end

        local img2 = img:getChildByName('img')
        img2:loadTexture(roleobj:getBigCardImg())

        local name = img:getChildByName('name')
        local name2 = img:getChildByName('name2')
        msg:setString(roleobj:getName())
        local textHeight = msg:getContentSize().height
        if textHeight == 96 then
            name:setVisible(false)
            name2:setVisible(true)
            name2:setString(roleobj:getName())
        else
            name:setVisible(true)
            name2:setVisible(false)
            name:setString(roleobj:getName())
        end

        img2:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,roleobj)
            end
        end)

    end

    local desc = self.root:getChildByName('desc')
    desc:setString(self.obj:getDesc())
    desc:setPosition(cc.p(winSize.width/2,80))
end

return GetWayFragmentUI