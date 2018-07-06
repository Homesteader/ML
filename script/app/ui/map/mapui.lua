local MainSceneUI = class("MainSceneUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local CloudZOrder = 10020
local BuoyZOrder = 10007 -- tag 9992 - 3
local CityNameZOrder = 10004
local CityAnimationZOrder = 5 --tag 9999 - 8
local GrayFightZOrder = 1 -- tag 10001
local FightZOrder = 10006 -- 9987
local BiologyZOrder = 10021 -- tag 10003+
local CityZOrder = 10003
local FeilongZOrderLow = 10008
local FeilongZOrderHigh = 10022
local ChipZOrder = 99999 -- tag 10003+

local MIN_SCALE = 0.3
function MainSceneUI:ctor(cityId,callback,scale,isCity,thief,reward)
	self.uiIndex = GAME_UI.UI_MAINSCENE
    self.cityId = cityId
    self.isCity = isCity
    self.callback = callback
    self.currScale = scale or 1.0
    self.mapChipImgs = {}
    self.allBgId = {}
    self.isMin = false
    self.actionNum = 0
    self.count = 0
    self.thief = thief
    self.reward = reward
    self.locatePage = MapMgr.locatePage or 1
    MapMgr.mapClose = false
    -- print(socket.gettime(),'==================map2')
    if not self.cityId then
        local fightedId = MapData:getFightedCityId()
        local isFirst = MapData.data[fightedId]:getBfirst()
        if isFirst == true then
            self.cityId = fightedId
        end
    end
end

function MainSceneUI:createCloud()
    self.cloudBtns = {}
    self.cloudImgs = {}
    self.cloudImgsPos = {}
    local node = cc.CSLoader:createNode("csb/cloud.csb")
    node:setName("cloud")
    self.panel2:addChild(node)
    node:setLocalZOrder(CloudZOrder)
    for i=1,30 do
        local str = 'cloud_'..i..'_pl'
        local pl = node:getChildByName(str)
        local btn = pl:getChildByName('explore_btn')
        local cloudImg1 = pl:getChildByName('cloud_1_img')
        local cloudImg2 = pl:getChildByName('cloud_2_img')
        local cloudImg3 = pl:getChildByName('cloud_3_img')
        local cityData = MapData.data[MapData.maxProgress]
        local cloudId = cityData:getGroup() or 1
        pl:setVisible(false)
        pl:setLocalZOrder(CloudZOrder)
        btn:setVisible(i == cloudId)
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                MapData:openCloud(function ()
                    btn:setVisible(false)
                    cloudImg1:setVisible(false)
                    local cloudOpen = require("script/app/ui/map/cloudopen").new(function()
                        pl:setVisible(false)
                        local cityData = MapData.data[MapData.currProgress]
                        local btn = self.panel2:getChildByName('map_city_'..MapData.currProgress)
                        btn:setTouchEnabled(true)
                        btn:setBright(true)
                        self:updateFightBtn()
                        self:updateCityName()
                        self:updateDragonEggImg()
                        self:updateCloudBtn()
                        self:updateLocation()
                        self:updateOpen()
                        local fightedId = MapData:getFightedCityId()
                        -- 特殊处理，前面新手引导会出现位移
                        if fightedId >= 43 or fightedId == 6 then
                            self:setWinPosition(MapData.currProgress)
                        end
                    end,i + 1)
                    cloudOpen:showUI()
                end)
            end
        end)
        self.cloudBtns[i] = {btn = btn,pl = pl}
        self.cloudImgs[i] = {cloudImg1,cloudImg2,cloudImg3}
        self.cloudImgsPos[i] = {}
        for i1,v1 in ipairs(self.cloudImgs[i]) do
            if v1 then
                self.cloudImgsPos[i][i1] = cc.p(v1:getPositionX(),v1:getPositionY())
            end
        end
    end
    self:updateCloudBtn()
end

--边界检测
function MainSceneUI:detectEdges( point )
    if point.x > self.limitRW then
        point.x = self.limitRW
    end
    if point.x < self.limitLW then
        point.x = self.limitLW
    end
    if point.y > self.limitUH then
        point.y = self.limitUH
    end
    if point.y < self.limitDH then
        point.y = self.limitDH
    end
end

--重置边界值
function MainSceneUI:setLimit(scale1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local point = self.panel3:getAnchorPoint()
    local scale = scale1
    if not scale then
        scale = self.currScale
    end
    self.limitLW = winSize.width - 6144*scale*(1 - point.x)
    self.limitRW = 6144*scale*point.x
    self.limitUH = 4096*scale*point.y
    self.limitDH = winSize.height - 4096*scale*(1 - point.y)
end

-- ntype 是否直接定位
-- 定位
function MainSceneUI:setWinPosition(cityId,stype,ntype,callback,scale)
    self.panel3:stopAllActions()
    self.currScale = self.panel3:getScale()
    self:setLimit()
    self:createCityBtns(cityId)
    if scale then
        self.panel3:runAction(cc.ScaleTo:create(0.5,scale))
        self.currScale = scale
        self:setLimit()
        self:setPowerSign()
    else
        if self.currScale ~= 1 and not ntype then
            -- self.panel3:setScale(1)
            self.panel3:runAction(cc.ScaleTo:create(0.5,1))
            self.currScale = 1
            self:setLimit()
            self:setPowerSign()
            self:updateFightBtn()
            self:updateOpen()
            local bgImg = self.panel1:getChildByName('bg_img')
            if bgImg then
                bgImg:removeFromParent()
            end
        end
    end
    local winSize = cc.Director:getInstance():getVisibleSize()
    local anchor = self.panel3:getAnchorPoint()
    local cityData = MapData.data[cityId]
    local point
    local cloudId = cityData:getGroup()
    if  MapMgr.locatePage == 1 and cityId == MapData.maxProgress and cityData:getStar(1) > 0 and self.cloudBtns and self.cloudBtns[cloudId] and not callback then
        local posX,posY = self.cloudBtns[cloudId].btn:getPosition()
        local cloudPl = self.cloudBtns[cloudId].pl
        point = cc.p(
            6144*self.currScale*anchor.x - cloudPl:getPositionX()*self.currScale + winSize.width/2 - posX*self.currScale,
            4096*self.currScale*anchor.y - cloudPl:getPositionY()*self.currScale + winSize.height/2 - posY*self.currScale)
    else
        local pos = cityData:getBtnPos()
        point = cc.p(
            6144*self.currScale*anchor.x - pos.x*self.currScale + winSize.width/2,
            4096*self.currScale*anchor.y - pos.y*self.currScale + winSize.height/2)
    end
    self:detectEdges(point)
    if ntype then
        -- local btn = self.btns[cityId]
        local pos = cityData:getBtnPos()
        return cc.p(pos.x/6144,pos.y/4096),point
    else
        if stype == 1 then
            self.panel3:setPosition(point)
            self:createBgByPos()
        elseif stype == 3 then
            if callback then
                callback()
            end
        else
            local function callback1()
                if callback then
                    callback()
                end
                if not scale then
                    self:createBgByPos()
                end
            end
            local posX3,posY3 = self.panel3:getPositionX(),self.panel3:getPositionY()
            if math.abs(posX3-point.x) < 1 and math.abs(posY3-point.y) < 1 then
                callback1()
            else
                self.panel3:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,point),cc.CallFunc:create(function()
                    callback1()
                end)))
            end
        end
        self:setLimit()
    end
end

function MainSceneUI:closeMapOnshow()
    self.isNotShow = true
end

function MainSceneUI:onShow()
    if self.isNotShow then
        UIManager:showSidebar({1,2,4,5,6,14},{1,2,3},true)
        self.isNotShow = false
        return
    end
    if self.isNotOnShow then
        -- 飞龙飞，会打开刘备合成界面,不刷新
        self:updateRunBar()
        UIManager:showSidebar({1,2,4,5,6,14},{1,2,3},true)
        self.isNotOnShow = false
        return
    end
    if self.ntype1 ~= 1 then
        self:updateFightBtn()
        self:updateCloudBtn()
        self:updateCityName()
        self:updateDragonEggImg()
        self:setBtnsVisible()
        self:updateLocation()
        self:updateOpen()
        self:updateFinger()
        self:updateTributeBox()
        UIManager:showSidebar({1,2,4,5,6,14},{1,2,3},true)
    end
    self.ntype1 = 0

    local cityData = MapData.data[tonumber(MapData.currProgress)]
    local level = UserData:getUserObj():getLv()
    local needLevel = cityData:getLevel()
    if level >= needLevel then
        local btn = self.panel2:getChildByName('map_city_'..MapData.currProgress)
        btn:setTouchEnabled(true)
        btn:setBright(true)
    end
end

function MainSceneUI:updateMapHandler()
	local winSize = cc.Director:getInstance():getVisibleSize()
	local MAX_SCALE = 1
    local startDistance = 0
    local touchArr = {}
    local currLocationArr = {}
    local moveFlag = true
    local isDraging = false
    local midpointNormalize =cc.p(0,0)
    local lastTouche1 = cc.p(0,0)
    local function getWorldAnchorPoint(point)
        return cc.p(point.x/6144/self.currScale,point.y/4096/self.currScale)
    end
    local function getWorldPosition(point)
        return cc.p(6144*self.currScale*self.panel3:getAnchorPoint().x + point.x - self.panel3:getPositionX(),4096*self.currScale*self.panel3:getAnchorPoint().y + point.y - self.panel3:getPositionY())
    end
    local function onTouchesMoved(touches, event )
        local node = self.panel2:getChildByTag(9987)
        if node then
            node:setScale(1/self.currScale)
        end
        if touchArr[0] and touchArr[1] then
            self:updateCloudMove()
        	for k, v in pairs(touches) do
				if v:getId() == 0 then
					currLocationArr[0] = v:getLocation()
				elseif v:getId() == 1 then
					currLocationArr[1] = v:getLocation()
				end
			end
            if not currLocationArr[0] or not currLocationArr[1] then
                return
            end
			local dis =cc.pGetDistance(currLocationArr[0],currLocationArr[1])
            local point = cc.pMidpoint(currLocationArr[0],currLocationArr[1])
			if dis ~= startDistance and dis > startDistance * 0.8 and dis > 100 then
				local newscale = self.currScale * (dis/startDistance)
				newscale = self.currScale*(1 + (dis-startDistance)/500)
                startDistance = dis
				
				if newscale < MIN_SCALE then
	    			newscale = MIN_SCALE
	    		elseif newscale > MAX_SCALE then
	    			newscale = MAX_SCALE
	    		end
                if newscale == self.currScale then
                    return
                end
                self.panel3:stopAllActions()
                local wPoint = getWorldPosition(point)
                local wAnchor = getWorldAnchorPoint(wPoint)

                local x = 6144*newscale*wAnchor.x
                local y = 4096*newscale*wAnchor.y
                local x1 = 6144*newscale*(1-wAnchor.x)
                local y1 = 4096*newscale*(1-wAnchor.y)
                if x < point.x then
                    point.x = 0
                    wAnchor.x = 0
                end
                if x1 < winSize.width - point.x then
                    point.x = winSize.width
                    wAnchor.x = 1
                end
                if y < point.y then
                    point.y = 0
                    wAnchor.y = 0
                end
                if y1 < winSize.height - point.y then
                    point.y = winSize.height
                    wAnchor.y = 1
                end
                self.panel3:setPosition(point)
                self.panel3:setAnchorPoint(wAnchor)
                self:setLimit()

                self.panel3:setScale(newscale)
                self.currScale = newscale
                self:setLimit()
                self:setPowerSign()
			end
        else
            isDraging = true
        end
    end

    local function onTouchesBegan(touches, event )
    	for k, v in pairs(touches) do
    		touchArr[v:getId()] = v:getLocation()
    	end
        startDistance = 0
        lastTouche1 = touchArr[0]
    	if touchArr[0] and touchArr[1] then
    		moveFlag = false
    		startDistance = cc.pGetDistance(touchArr[0],touchArr[1])
            midpointNormalize =cc.pNormalize(cc.pMidpoint(touchArr[0],touchArr[1]))
        else
            isDraging = true
    	end
    end

    local function onTouchesEnded(touches, event )
        startDistance = 0
    	for k, v in pairs(touches) do
    		touchArr[v:getId()] = nil
    	end 
    	if touchArr[0] == nil or touchArr[1] == nil then
    		moveFlag = true
    	end
        isDraging = false
    end

    local listener1 = cc.EventListenerTouchAllAtOnce:create()
    listener1:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener1:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN ) 
    listener1:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED ) 
    local eventDispatcher1 = self.panel1:getEventDispatcher()
    eventDispatcher1:addEventListenerWithSceneGraphPriority(listener1, self.panel1)
    self.listener1 = listener1

    local function onMouseScroll(event)
        local node = self.panel2:getChildByTag(9987)
        if node then
            node:setScale(1/self.currScale)
        end
        self:updateCloudMove()
		self.panel3:stopAllActions()
        local x = event:getScrollX()
        local y = event:getScrollY()
        local diffScale = (event:getScrollX() - event:getScrollY())*0.05
        local newscale = self.currScale + diffScale
        local point = self.mouseMovePoint
        if not point then
            return
        end
        if newscale < MIN_SCALE then
            newscale = MIN_SCALE
        elseif newscale > MAX_SCALE then
            newscale = MAX_SCALE
        end
        if newscale == self.currScale then
            return
        end
        local wPoint = getWorldPosition(point)
        local wAnchor = getWorldAnchorPoint(wPoint)

        local x = 6144*newscale*wAnchor.x
        local y = 4096*newscale*wAnchor.y
        local x1 = 6144*newscale*(1-wAnchor.x)
        local y1 = 4096*newscale*(1-wAnchor.y)
        if x < point.x then
            point.x = 0
            wAnchor.x = 0
        end
        if x1 < winSize.width - point.x then
            point.x = winSize.width
            wAnchor.x = 1
        end
        if y < point.y then
            point.y = 0
            wAnchor.y = 0
        end
        if y1 < winSize.height - point.y then
            point.y = winSize.height
            wAnchor.y = 1
        end
        self.panel3:setPosition(point)
        self.panel3:setAnchorPoint(wAnchor)
        self:setLimit()

        self.panel3:setScale(newscale)
        self.currScale = newscale
        self:setLimit()
        self:createBgByPos()
        self:setPowerSign()
        -- if self.guideZoomFlag and self.currScale <= MIN_SCALE and self.guideCallback then
        --     self.guideCallback()
        --     self.guideZoomFlag = false
        --     self:setCityBtnsStatus(true)
        -- end
    end

    local function onMouseMove(event)
        self.mouseMovePoint = cc.p(event:getCursorX(),event:getCursorY())
    end

    if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
        local listener2 = cc.EventListenerMouse:create()
        listener2:registerScriptHandler(onMouseScroll,cc.Handler.EVENT_MOUSE_SCROLL)
        listener2:registerScriptHandler(onMouseMove,cc.Handler.EVENT_MOUSE_MOVE)
        local eventDispatcher2 = self.root:getEventDispatcher()
        eventDispatcher2:addEventListenerWithSceneGraphPriority(listener2, self.root)
        self.listener2 = listener2
    end

    self.panel3:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
        end
	end)

    local bgPanelPrePos = nil
    local bgPanelPos = nil
    local bgPanelDiffPos = nil
    local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    local beginTime = 0
    local endTime = 0
    local a = 0
    local b = 0
    local isHideBtn = false
    self.panel1:addTouchEventListener(function (sender, eventType)
        local isRunning = GuideMgr:isRunning()
        if (not moveFlag and not self.guideZoomFlag) or isRunning then
            return
        end
        if eventType == ccui.TouchEventType.moved then
            self:hideBtns(1)
            isHideBtn = true
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
                bgPanelDiffPos = cc.p(bgPanelPos.x - bgPanelPrePos.x, bgPanelPos.y - bgPanelPrePos.y)
                local targetPos = cc.pAdd(cc.p(self.panel3:getPositionX(),self.panel3:getPositionY()),bgPanelDiffPos)
                self:detectEdges(targetPos)
                self.panel3:setPosition(targetPos)
                self:setBtnsVisible()
            end
        else
            if eventType == ccui.TouchEventType.canceled then
                if isHideBtn == true then
                    self:hideBtns(2)
                    isHideBtn = false
                end
            end
            bgPanelPrePos = nil
            bgPanelPos = nil
            bgPanelDiffPos = nil
            if eventType == ccui.TouchEventType.began then
                beginTime = socket.gettime()
                self.panel3:stopAllActions()
                self.currScale = self.panel3:getScale()
                self:setLimit()
                beginPoint = sender:getTouchBeganPosition()
            end
            if eventType == ccui.TouchEventType.ended then
                if isHideBtn == true then
                    self:hideBtns(2)
                    isHideBtn = false
                end
                endPoint= sender:getTouchEndPosition()
                endTime = socket.gettime()
                local aSpeed = 0.8
                local speedX = endPoint.x - beginPoint.x
                local speedY = endPoint.y - beginPoint.y
                if (math.abs(speedX) < 50 and math.abs(speedY) < 50) or (endTime - beginTime)*1000 > 300 then
                    self:createBgByPos()
                    return
                end
                local diffPoint1 =cc.p(speedX*aSpeed,speedY*aSpeed)
                local diffPoint2 =cc.p(diffPoint1.x + speedX*math.pow(aSpeed,2),diffPoint1.y + speedY*math.pow(aSpeed,2))
                local diffPoint3 =cc.p(diffPoint2.x + speedX*math.pow(aSpeed,3),diffPoint2.y + speedY*math.pow(aSpeed,3))
                local diffPoint4 =cc.p(diffPoint3.x + speedX*math.pow(aSpeed,4),diffPoint3.y + speedY*math.pow(aSpeed,4))
                local diffPoint5 =cc.p(diffPoint4.x + speedX*math.pow(aSpeed,5),diffPoint4.y + speedY*math.pow(aSpeed,5))
                local diffPoint6 =cc.p(diffPoint5.x + speedX*math.pow(aSpeed,6),diffPoint5.y + speedY*math.pow(aSpeed,6))
                local diffPoint7 =cc.p(diffPoint6.x + speedX*math.pow(aSpeed,7),diffPoint6.y + speedY*math.pow(aSpeed,7))
                local diffPoint8 =cc.p(diffPoint7.x + speedX*math.pow(aSpeed,8),diffPoint7.y + speedY*math.pow(aSpeed,8))
                local diffPoint9 =cc.p(diffPoint8.x + speedX*math.pow(aSpeed,9),diffPoint8.y + speedY*math.pow(aSpeed,9))
                local tab = {diffPoint1,diffPoint2,diffPoint3,diffPoint4,diffPoint5,diffPoint6,diffPoint7,diffPoint8,diffPoint9}
                local x = self.panel3:getPositionX()
                local y = self.panel3:getPositionY()
                local newPoint1 = cc.pAdd(cc.p(x,y),diffPoint1)
                local newPoint2 = cc.pAdd(cc.p(x,y),diffPoint2)
                local newPoint3 = cc.pAdd(cc.p(x,y),diffPoint3)
                local newPoint4 = cc.pAdd(cc.p(x,y),diffPoint4)
                local newPoint5 = cc.pAdd(cc.p(x,y),diffPoint5)
                local newPoint6 = cc.pAdd(cc.p(x,y),diffPoint6)
                local newPoint7 = cc.pAdd(cc.p(x,y),diffPoint7)
                local newPoint8 = cc.pAdd(cc.p(x,y),diffPoint8)
                local newPoint9 = cc.pAdd(cc.p(x,y),diffPoint9)

                self:detectEdges(newPoint1)
                self:detectEdges(newPoint2)
                self:detectEdges(newPoint3)
                self:detectEdges(newPoint4)
                self:detectEdges(newPoint5)
                self:detectEdges(newPoint6)
                self:detectEdges(newPoint7)
                self:detectEdges(newPoint8)
                self:detectEdges(newPoint9)
                self.panel3:runAction(
                    cc.Sequence:create(
                    cc.MoveTo:create(0.1, newPoint1),
                    cc.MoveTo:create(0.1, newPoint2),
                    cc.MoveTo:create(0.1, newPoint3),
                    cc.MoveTo:create(0.1, newPoint4),
                    cc.MoveTo:create(0.1, newPoint5),
                    cc.MoveTo:create(0.1, newPoint6),
                    cc.MoveTo:create(0.1, newPoint7),
                    cc.MoveTo:create(0.1, newPoint8),
                    cc.CallFunc:create(function()
                        self:createBgByPos()
                    end))
                    )
            end
        end
    end)
end

function MainSceneUI:createBgByPos(pos)
    local index = 0
    for i=1,24 do
        if self.allBgId[i] then
            index = index + 1
        end
    end
    if index >= 24 then
        return
    end
    local posX,posY
    if pos then
        posX,posY = pos.x,pos.y
    else
        posX,posY = self.panel3:getPosition()
    end
    local anchor = self.panel3:getAnchorPoint()
    local leftBottomPosX,leftBottomPosY = math.abs(posX - 6143*self.currScale*anchor.x),math.abs(posY - 4095*self.currScale*anchor.y)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local points = {
        cc.p(leftBottomPosX/self.currScale,leftBottomPosY/self.currScale + winSize.height/self.currScale), -- 左上
        cc.p((leftBottomPosX + winSize.width)/self.currScale,leftBottomPosY/self.currScale + winSize.height/self.currScale),
        cc.p(leftBottomPosX/self.currScale,leftBottomPosY/self.currScale),
        cc.p(leftBottomPosX/self.currScale + winSize.width/self.currScale,leftBottomPosY/self.currScale),
    }
    local function getBg(point)
        local x = (point.x - point.x%1024)/1024 + 1
        local y = (point.y - point.y%1024)/1024 + 1
        return (4 - y)*6 + x
    end
    local ids = {}
    for i,v in ipairs(points) do
        local bgId = getBg(v)
        ids[i] = bgId
    end
    local newIds = {}
    local leftIds = {}
    local rightIds = {}
    for i=ids[1],ids[3],6 do
        leftIds[#leftIds + 1] = i
    end
    for i=ids[2],ids[4],6 do
        rightIds[#rightIds + 1] = i
    end
    for i,v in ipairs(leftIds) do
        for j=v,rightIds[i] do
            newIds[#newIds + 1] = j
            if j >= 1 and j <= 24 then
                local bgImg = self.panel2:getChildByTag(j + 1000)
                if not bgImg then
                    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/'..j..'.png',function(texture)
                        local function getBgPos(i)
                            local index = (4 - math.floor((i - 1)/6 + 1))*6+(i - 1)%6 + 1
                            local posX = (math.floor((index - 1)%6 + 1) - 1)*1024 + 512
                            local posY = (math.ceil(index/6) - 1)*1024 + 512
                            return cc.p(posX,posY)
                        end
                        local img = ccui.ImageView:create('uires/ui/mainscene/bg_'..j..'.jpg')
                        img:setPosition(getBgPos(j))
                        if MapMgr.mapClose == true then
                            return
                        end
                        self.panel2:addChild(img,1,j+1000)
                        self:createCityBtnsByBg(tonumber(j))
                        self.allBgId[j] = 1
                        self:createCityName()
                    end)
                end
            end
        end
    end
end

function MainSceneUI:createCityBtns(cityId)
    local cityData = MapData.data[tonumber(cityId)]
    local btn = self.panel2:getChildByName('map_city_'..cityId)
    local level = UserData:getUserObj():getLv()
    if not btn then
        btn = ccui.Button:create(cityData:getBtnResource())
        btn:setName("map_city_" .. cityId)
        btn:setScale(0.8)
        local index = tonumber(cityId)
        local size = btn:getContentSize()
        btn:setSwallowTouches(false)
        local needLevel = cityData:getLevel()
        if tonumber(cityId) <= MapData.maxProgress then
            if tonumber(cityId) > 0 then
                if MapData.data[tonumber(cityId)]:getStar(1) > 0
                    or (tonumber(cityId) - 1 == 0 and MapData.currProgress ~= 0) 
                    or (MapData.data[tonumber(cityId) - 1]:getStar(1) > 0 and level >= needLevel)then 
                    btn:setTouchEnabled(true)
                    btn:setBright(true)
                else
                    btn:setTouchEnabled(false)
                    btn:setBright(false)
                end
            end
        else
            btn:setTouchEnabled(false)
            btn:setBright(false)
        end
        
        btn:setPosition(cityData:getBtnPos())
        btn:setLocalZOrder(CityZOrder)
        self.panel2:addChild(btn)
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                self.panel2:stopAllActions()
                local type1 = cityData:getType()
                local type2 = cityData:getType1()
                local skeletonNode = self.panel2:getChildByTag(tonumber('8000'..type1..type2))
                if not skeletonNode then
                    local spineName = 'city_shake_'..type1..'_'..type2
                    skeletonNode = GlobalApi:createSpineByName(spineName, 'spine/city_shake/' .. spineName, 1)
                    self.panel2:addChild(skeletonNode, CityAnimationZOrder, tonumber('8000'..type1..type2))
                else
                    skeletonNode:clearTracks()
                end
                skeletonNode:setVisible(true)
                skeletonNode:setPosition(btn:getPosition())
                skeletonNode:registerSpineEventHandler(function (event)
                    UIManager:showSidebar({1,2,4,5},{1,2,3})
                    btn:setVisible(false)
                    self:effectEnd(index,btn)
                end, sp.EventType.ANIMATION_START)

                skeletonNode:registerSpineEventHandler(function (event)
                    btn:setVisible(true)
                    skeletonNode:setVisible(false)
                end, sp.EventType.ANIMATION_END)
                skeletonNode:setAnimation(0, 'city_shake_1', false)
            elseif eventType == ccui.TouchEventType.ended then
                self:effectEnd(index,btn)
            elseif eventType == ccui.TouchEventType.canceled then
                self.count = 0
            end
        end)
    end
end

function MainSceneUI:createCityBtnsByBg(bgId)
    local cityIds = GameData:getConfData("cityres")[bgId]
    if not cityIds or not cityIds.cityId then
        return
    end
    for i,v in ipairs(cityIds.cityId) do
        self:createCityBtns(tonumber(v))
    end
end

function MainSceneUI:createBgAfter()
    for i=1,24 do
        -- local bg = self.panel2:getChildByTag(1000 + i)
        -- if not bg then
        --     local img = ccui.ImageView:create('uires/ui/mainscene/bg_'..i..'.jpg')
        --     img:setPosition(self:getBgPos(i))
        --     self.panel2:addChild(img,1,i+100)
        --     self:createCityBtnsByBg(i)
        -- end
        self:createCityBtnsByBg(i)
    end
end

function MainSceneUI:createBgBefore()
    local cityData = MapData.data[MapData.currProgress]
    local currId = cityData:getBcakId()
    local diffs = {-7,-6,-5,-1,0,1,5,6,7}
    if currId%6 == 0 then
        diffs = {-7,-6,-1,0,5,6}
    elseif currId%6 == 1 then
        diffs = {-6,-5,0,1,6,7}
    end
    local ids = {}
    for i,v in ipairs(diffs) do
        local id = currId + v
        if id >= 1 and id <= 24 then
            ids[#ids + 1] = id
        end
    end
    local function getBgPos(i)
        local index = (4 - math.floor((i - 1)/6 + 1))*6+(i - 1)%6 + 1
        local posX = (math.floor((index - 1)%6 + 1) - 1)*1024 + 512
        local posY = (math.ceil(index/6) - 1)*1024 + 512
        return cc.p(posX,posY)
    end
    for i,v in ipairs(ids) do
        self:createCityBtnsByBg(tonumber(v))
    end
end

function MainSceneUI:createCurrCity()
    local cityData = MapData.data[MapData.currProgress]
    local currId = cityData:getBcakId()
    self:createCityBtnsByBg(currId)

    if self.cityId then
        local cityData1 = MapData.data[self.cityId]
        local currId1 = cityData1:getBcakId()
        if currId ~= currId1 then
            self:createCityBtnsByBg(currId1)
        end
    end
end

function MainSceneUI:updateCurrProgress()
    if MapData.currProgress == 0 then
        return
    end
    MapData.currProgress = MapData.maxProgress
    for i=1,MapData.maxProgress do
        local cityData = MapData.data[i]
        local star = cityData:getStar(1)
        if not star or star <= 0 then
            MapData.currProgress = i
            return
        end
    end
end

function MainSceneUI:createAllCamp()
    local bgImg = ccui.ImageView:create('uires/ui/mainscene/map.jpg')
    local swordSpine = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
    swordSpine:setPosition(cc.p(830, 580))
    bgImg:addChild(swordSpine)
    swordSpine:setAnimation(0, "animation", true)
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    bgImg:setName('bg_img')
    self.panel1:addChild(bgImg)
end

function MainSceneUI:setCityBtnsStatus(b)
    for i=0,#MapData.data do
        local btn = self.panel2:getChildByName('map_city_'..i)
        if btn then
            btn:setTouchEnabled(b)
        end
    end
end

function MainSceneUI:guideZoomMap(callback)
    self.guideCallback = callback
    self.guideZoomFlag = true
    self:setCityBtnsStatus(false)
    self:hideBtns(1)
    UIManager:setBlockTouch(true)
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        local anchor = self.panel3:getAnchorPoint()
        local winSize = cc.Director:getInstance():getVisibleSize()
        self.panel3:setAnchorPoint(cc.p(anchor.x,1))
        self.panel3:setPositionY(winSize.height)
        self:setLimit()
        self:setPowerSign()
        self.panel3:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,0.3),cc.CallFunc:create(function()
            UIManager:setBlockTouch(false)
            self.currScale = 0.3
            self:setLimit()
            self:setPowerSign()
        end)))
    end)))
end

function MainSceneUI:enterWithOutAction(thief,reward)
    self.ntype1 = 0
    local mapBgImg = self.panel2:getChildByName("map_bg_img")
    mapBgImg:setVisible(true)
    self:createBtns()
    if self.currScale == 0.35 then
        self:setBuoyBtnsVisible(1,1)
        self:createAllCamp()
        UIManager:showSidebar({0},{0})
    else
        UIManager:showSidebar({1,2,4,5,6,14},{1,2,3})
        self:createRunBar()
    end

    self.panel3:setScale(self.currScale)
    -- self.currScale = 1
    self:setLimit()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local anchor,point = self:setWinPosition(self.cityId or MapData.currProgress,1,1)
    self.panel3:setAnchorPoint(anchor)
    local point1 = cc.p(winSize.width/2,winSize.height/2)
    self:setLimit()
    self:detectEdges(point1)
    self.panel3:setPosition(point1)
    self.panel3:setScale(self.currScale)
    -- self.currScale = 1
    self:setLimit()
    self:updateCloudVisible()
    self:updateFightBtn()
    self:updateOpen()
    self:updateFinger()
    --UIManager:getSidebar():setFrameBtnsVisible(true)
    -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
    --     if self.currScale ~= 0.35 then
    --         UIManager:showSidebar({1,2,4,6},{1,2,3})
    --     else
    --         UIManager:showSidebar({0},{0})
    --     end
    --     -- self:createBgAfter()
    --     self:createCityName()
    --     self:updateGrayFightBtn()
    --     self:updateMapHandler()

    -- end)))

    if self.currScale ~= 0.35 then
        UIManager:showSidebar({1,2,4,5,6,14},{1,2,3})
        self:createRunBar()
    else
        UIManager:showSidebar({0},{0})
    end
    -- self:createBgAfter()
    self:createCityName()
    self:updateDragonEggImg()
    self:updateMapHandler()
    self:updateFeilongSpine()
    self:updateTributeBox()
    if thief then
        self:createThief(thief)
    end
    if reward then
        UIManager:getSidebar():setHide(true)
        local hideImg = self.hideImg
        -- if hideImg then
        --     hideImg:setTouchEnabled(true)
        -- end
        self:updateCityName(reward)
    elseif self.callback then
        self.callback()
    else
        self:updateCityName()
    end
end

function MainSceneUI:initLoading()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local loadingUI,loadingPanel
    if not self.isCity then
        loadingUI = require ("script/app/ui/loading/loadingui").new(2)
        loadingPanel = loadingUI:getPanel()
        loadingPanel:setPosition(cc.p(winSize.width/2, winSize.height/2))
        self.root:addChild(loadingPanel, 9999)
        self.loadingUI = loadingUI
    end
    local loadedImgCount = 0
    local loadedImgMaxCount = 57
    local function imageLoaded(texture)
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        if not self.isCity then
            self.loadingUI:setPercent(loadingPercent)
        end
        if loadedImgCount >= loadedImgMaxCount then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                local function callback()
                    self:createCurrCity()
                    self:createCloud()
                    self:createBgBefore()
                    self:updateCloudMove()
                    self:enterWithOutAction(self.thief,self.reward)
                    local btn = self.panel2:getChildByName('map_city_0')
                    if btn then
                        self:effectEnd(0,btn,true)
                    end
                end
                if not self.isCity then
                    UIManager:removeLoadingAction()
                    self.loadingUI:runToPercent(0.2, 100, function ()
                        self.loadingUI:removeFromParent()
                        self.loadingUI = nil
                        callback()
                    end)
                else
                    callback()
                end
            end)))
        end
    end
    -- for i=1,8 do
    --     cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/city'..i..'.png',imageLoaded)
    -- end
    for i=1,24 do
        cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/cloud'..i..'.png',imageLoaded)
    end
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/explore_nor_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/explore_sel_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/yun_bg.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/map_bg.png',imageLoaded)
    -- for i=1,24 do
    --     cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/bg_'..i..'.jpg',imageLoaded)
    -- end
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/locate_nor_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/locate_sel_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/prefecture_nor_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/prefecture_sel_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/jingying.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/putong.png',imageLoaded)
    for i=1,11 do
        cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/name_bg_'..i..'.png',imageLoaded)
    end
    for i=1,3 do
        for j=0,3 do
           cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/mainscene/'..i..'-'..j..'.png',imageLoaded)
        end
    end
end

function MainSceneUI:init()
    -- print(socket.gettime(),'==================map3')
    self.root:registerScriptHandler(function (event)
        if event == "exit" then
            if self.listener1 then
                ScriptHandlerMgr:getInstance():removeObjectAllHandlers(self.listener1)
                self.panel1:getEventDispatcher():removeEventListener(self.listener1)
                self.listener1 = nil
            end
            if self.listener2 then
                ScriptHandlerMgr:getInstance():removeObjectAllHandlers(self.listener2)
                self.root:getEventDispatcher():removeEventListener(self.listener2)
                self.listener2 = nil
            end
            MapMgr.mapClose = true
            -- MapMgr.uiClass['MainSceneUI'] = nil
        end
    end)
    self.panel1 = self.root:getChildByName("Panel_1")
    self.panel3 = self.panel1:getChildByName("Panel_3")
    self.panel2 = self.panel3:getChildByName("Panel_2")
    self.hideImg = self.panel1:getChildByName('hide_img')
    -- local powerEndPl = self.hideImg:getChildByName('power_end_pl')
    -- local powerEndTx = powerEndPl:getChildByName('power_end_tx')
    -- local topImg = powerEndPl:getChildByName('top_img')
    -- local bottomImg = powerEndPl:getChildByName('bottom_img')
    local winSize = cc.Director:getInstance():getVisibleSize()
    -- 386
    -- powerEndPl:setContentSize(cc.size(winSize.width,300))
    -- topImg:setContentSize(cc.size(winSize.width,10))
    -- bottomImg:setContentSize(cc.size(winSize.width,10))
    -- topImg:setPosition(cc.p(winSize.width/2,304))
    -- bottomImg:setPosition(cc.p(winSize.width/2,-4))
    -- topImg:setLocalZOrder(2)
    -- bottomImg:setLocalZOrder(2)
    -- powerEndPl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    -- powerEndTx:setPosition(cc.p(winSize.width/2,35))
    -- powerEndPl:setVisible(false)
    -- powerEndTx:setOpacity(0)
    self.panel1:setContentSize(cc.size(winSize.width,winSize.height))
    self.panel1:setSwallowTouches(false)
    self.root:setVisible(self.ntype1 ~= 1)
    self:updateCurrProgress()
    -- print(socket.gettime(),'==================map4')
    self:initLoading()
    -- print(socket.gettime(),'==================map5')
end

-- MAP_EXTENT
local BTNS = {
    'uires/ui/mainscene/combat_nor_btn.png',
    'uires/ui/mainscene/prefecture1_nor_btn.png',
    'uires/ui/mainscene/expedition_nor_btn.png',
    'uires/ui/mainscene/huicheng_nor_btn.png'
}
local SBTNS = {
    'uires/ui/mainscene/combat_sel_btn.png',
    'uires/ui/mainscene/prefecture1_sel_btn.png',
    'uires/ui/mainscene/expedition_sel_btn.png',
    'uires/ui/mainscene/huicheng_sel_btn.png'
}
local COLOR_QUALITY = {
    -- {color = cc.c3b(255,255,255),campcolor = cc.c3b(83,157,35),pos2 = cc.p(118.5,44),outline = cc.c4b(50,24,5,255),color1 = cc.c3b(255,255,0)},
    {color = cc.c3b(255,255,255),campcolor = cc.c3b(196,192,48),pos2 = cc.p(118.5,44),outline = cc.c4b(50,24,5,255),color1 = cc.c3b(255,255,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(35,35,207),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(63,40,128),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(232,29,81),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(149,108,40),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(149,108,40),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(83,157,35),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(83,157,35),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(68,179,210),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(68,179,210),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)},
    {color = cc.c3b(206,203,187),campcolor = cc.c3b(68,179,210),pos2 = cc.p(118.5,44),outline = cc.c4b(0,0,0,255),color1 = cc.c3b(0,0,0)}
}

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓征战浮标管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
-- 浮标响应方法
function MainSceneUI:fightCallback(index,stype)
    if stype == 4 then
        MapMgr:hideMainScene()
        MainSceneMgr:showMainCity()
    else
        local stypes = {'combat','lord','expedition'}
        GlobalApi:getGotoByModule(stypes[stype],nil,index)
    end
end
--设置征战浮标是否显示
function MainSceneUI:setBtnsVisible()
    if self.isActEnd == true and self.isBtnEffEnd == true then
        local index = 9991
        local bar = self.panel2:getChildByTag(index)
        if bar then
            self.isBtnEffEnd = false
            local size = bar:getContentSize()
            for i=1,3 do
                local btn = bar:getChildByTag(i)
                if btn then
                    -- print(btn:getPositionX(),btn:getPositionY(),'=============='..i)
                    btn:runAction(cc.MoveTo:create(0.3,cc.p(size.width/2,0)))
                    btn:runAction(cc.ScaleTo:create(0.3,0.1))
                end
            end
            bar:runAction(cc.Sequence:create(cc.ProgressTo:create(0.3, 0),cc.CallFunc:create(function()
                local sprite = self.panel2:getChildByTag(9987)
                if sprite then
                    sprite:setVisible(true)
                end
                bar:setVisible(false)
                self.isBtnEffEnd = true
            end)))
        end
    end
end

--城池动画播放完成
function MainSceneUI:effectEnd(id,btn,isCreate)
    -- if id == 0 then
    --     return
    -- end
    if not isCreate then
        self.count = self.count + 1
        if self.count < 2 then
            return
        end
        self.count = 0
    end
    local cityData = MapData.data[id]
    local index = 9991
    local size = btn:getContentSize()
    local bar = self.panel2:getChildByTag(index)
    if not bar then
        -- img = ccui.ImageView:create('uires/ui/mainscene/buoy_bg.png')
        bar = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/mainscene/buoy_bg.png"))
        bar:setName("bar")
        bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        bar:setMidpoint(cc.p(0, 0))
        bar:setBarChangeRate(cc.p(1, 0))
        self.panel2:addChild(bar,BuoyZOrder,index)
    end
    bar:setVisible(false)
    bar:stopAllActions()
    self.isBtnEffEnd = true
    self.isActEnd = false
    local size = bar:getContentSize()
    local buoyBtns = {}
    for i=1,3 do
        local buoyBtn = bar:getChildByTag(i)
        if not buoyBtn then
            buoyBtn = ccui.Button:create(BTNS[i],SBTNS[i])
            buoyBtn:setName("buoy_btn_" .. i)
            bar:addChild(buoyBtn,BuoyZOrder,i)
        end
        local index = i
        if i == 1 then
            if id == 0 then
                buoyBtn:loadTextures(BTNS[4],SBTNS[4])
                index = 4
            else
                buoyBtn:loadTextures(BTNS[i],SBTNS[i])
            end
        end
        buoyBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:fightCallback(id,index)
            end
        end)
        -- buoyBtn:setSwallowTouches(false)
        buoyBtn:setScale(1)
        buoyBtn:setPosition(btn:getPosition())
        buoyBtn:stopAllActions()
        buoyBtns[i] = buoyBtn
        buoyBtn:setVisible(false)
    end
    if isCreate == true then
        return
    end
    local star = cityData:getStar(1)
    if star <= 0 and id ~= 0 then
        bar:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
            self:fightCallback(id,3)
        end)))
        return
    end
    local endPoint = cc.p(btn:getPositionX(),btn:getPositionY() + size.height/2)
    local action = cc.Sequence:create(cc.MoveTo:create(0.3,endPoint),
            cc.CallFunc:create(function ()
                self.isActEnd = true
            end))
    local ntype = cityData:getType()
    local size1 = buoyBtns[1]:getContentSize()
    local pos = {
        cc.p(size.width/2,size.height - size1.height/4),
        cc.p(size1.width/4,size.height/4),
        cc.p(size.width - size1.width/4,size.height/4),
        cc.p(size.width/4,size.height/3*2),
        cc.p(size.width/4*3,size.height/3*2),
    }
    if id <= 0 then
        buoyBtns[1]:setPosition(pos[5])
        buoyBtns[1]:setVisible(true)
        buoyBtns[2]:setPosition(pos[4])
        buoyBtns[2]:setVisible(true)
        -- bar:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
        --     self:fightCallback(id,2)
        -- end)))
        -- return
    else
        local formation = cityData:getFormation(3)
        if formation and formation > 0 then
            buoyBtns[1]:setPosition(pos[1])
            buoyBtns[2]:setPosition(pos[2])
            buoyBtns[3]:setPosition(pos[3])
            buoyBtns[1]:setVisible(true)
            buoyBtns[2]:setVisible(true)
            buoyBtns[3]:setVisible(true)
        else
            buoyBtns[2]:setPosition(pos[4])
            buoyBtns[3]:setPosition(pos[5])
            buoyBtns[2]:setVisible(true)
            buoyBtns[3]:setVisible(true)
        end
    end
    for i=1,3 do
        local buoyBtn = bar:getChildByTag(i)
    end
    local sprite = self.panel2:getChildByTag(9987)
    if sprite then
        sprite:setVisible(false)
    end

    bar:setVisible(true)
    bar:setPercentage(100)
    bar:setScale(0.1)
    bar:setPosition(btn:getPosition())
    bar:runAction(action)
    bar:runAction(cc.ScaleTo:create(0.3,1))
end

--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑征战浮标管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓外框浮标管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--更新定位
function MainSceneUI:updateLocation()
    local locateBtn = self.root:getChildByName('locate_btn')
    local changeBtn = locateBtn:getChildByName('change_btn')
    local tributeBtn = self.panel1:getChildByName('tribute_btn')
    local isOpen = GlobalApi:getOpenInfo('elite')
    local isTaskOpen = GlobalApi:getOpenInfo('task')
    changeBtn:setVisible(isOpen)
    local progress = MapData:getCanFighttingIdByPage(self.locatePage)
    local cityData = MapData.data[progress]
    local keyArr = string.split(cityData:getName() , '.')
    if self.locatePage == 1 then
        local star = cityData:getStar(1)
        if star > 0 and progress ~= #MapData.data then
            self.nameRts.re1:setString(GlobalApi:getLocalStr('LOCATION_NEW_CITY'))
            self.nameRts.re2:setString('')
        else
            self.nameRts.re1:setString('['..cityData:getName()..']')
            --self.nameRts.re2:setString('['..GlobalApi:getLocalStr('NORMAL2')..']')
            --self.nameRts.re2:setColor(COLOR_TYPE.GREEN)
            self.nameRts.re2:setString('')
        end
        changeBtn:loadTextureNormal('uires/ui/mainscene/putong.png')
    else
        self.nameRts.re1:setString('['..cityData:getName()..']')
        --self.nameRts.re2:setString('['..GlobalApi:getLocalStr('ELITE2')..']')
        --self.nameRts.re2:setColor(COLOR_TYPE.RED)
        self.nameRts.re2:setString('')
        changeBtn:loadTextureNormal('uires/ui/mainscene/jingying.png')
    end
    self.nameRts.richText:format(true)

    local conf = GameData:getConfData('citytribute')
    local fightedId = MapData:getFightedCityId()
    local cityTribute = MapData.cityTribute
    local canGet = false
    for i,v in ipairs(conf) do
        if v.cityId <= fightedId and not cityTribute[tostring(i)] then
            canGet = true
            break
        end
    end
    local peopleImg = tributeBtn:getChildByName('people_img')
    local boxImg = tributeBtn:getChildByName('box_img')
    local descTx = tributeBtn:getChildByName('desc_tx')
    local isOpen = GlobalApi:getOpenInfo('tribute')
    local currScale = math.floor(self.currScale * 100)/100
    if isOpen and currScale > MIN_SCALE then
        tributeBtn:setVisible(true)
    else
        tributeBtn:setVisible(false)
    end
    if canGet then
        peopleImg:setPosition(cc.p(31,28))
        peopleImg:setVisible(true)
        boxImg:setPosition(cc.p(119,42))
        descTx:setPosition(cc.p(119,7))
        descTx:setColor(COLOR_TYPE.GREEN)
        descTx:enableOutline(COLOROUTLINE_TYPE.GREEN)
        descTx:setString(GlobalApi:getLocalStr('STR_CANGET'))
        local timeTx = tributeBtn:getChildByName('time_tx')
        if timeTx then
            timeTx:removeFromParent()
        end
    else
        -- peopleImg:setPosition(cc.p(119,28))
        peopleImg:setVisible(false)
        boxImg:setPosition(cc.p(31,42))
        descTx:setPosition(cc.p(31,7))
        descTx:setColor(COLOR_TYPE.PALE)
        descTx:enableOutline(COLOROUTLINE_TYPE.PALE)
        descTx:setString(GlobalApi:getLocalStr('TRIBUTE_DESC_3'))

        local endTime = Time.beginningOfToday() + 86400 + tonumber(GlobalApi:getGlobalValue('resetHour')) * 3600
        local nowTime = GlobalData:getServerTime()
        if nowTime - Time.beginningOfToday() < 5 * 3600 then
            endTime = Time.beginningOfToday() + tonumber(GlobalApi:getGlobalValue('resetHour')) * 3600
        end
        local diffTime = endTime - nowTime
        local timeTx = tributeBtn:getChildByName('time_tx')
        local size = tributeBtn:getContentSize()
        if timeTx then
            timeTx:removeFromParent()
        end
        timeTx = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
        timeTx:setName('time_tx')
        timeTx:setPosition(cc.p(72,26))
        timeTx:setAnchorPoint(cc.p(0,0.5))
        tributeBtn:addChild(timeTx)
        Utils:createCDLabel(timeTx,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT,nil,nil,nil,25,function ()
            self:updateLocation()
        end)
    end
end

--隐藏外框浮标
function MainSceneUI:hideBtns(ntype)
    local barBg = self.panel1:getChildByName('bar_bg')
    local tributeBtn = self.panel1:getChildByName('tribute_btn')
    if ntype == 1 then
        -- print('=================================1')
        UIManager:showSidebar({0},{1,2,3},nil,true)
        for i,v in ipairs(self.buoyBtns) do
            if v then
                v:setVisible(false)
            end
        end
        if barBg then
            barBg:setVisible(false)
        end
        tributeBtn:setVisible(false)
    elseif ntype == 2 then
        local currScale = math.floor(self.currScale * 100)/100
        if currScale <= MIN_SCALE then
            UIManager:showSidebar({0},{0},true)
            self:setBuoyBtnsVisible(1,1)
        else
            UIManager:showSidebar({1,2,4,5,6,14},{1,2,3},true,true)
            self:setBuoyBtnsVisible()
        end
    end
end

function MainSceneUI:setLordBtnVisible(b)
    local lordBtn = self.root:getChildByName('lord_btn')
    lordBtn:setVisible(b)
end

-- isNotFadeIn 是否渐隐
-- vType 显示相应按钮
--设置外框图标是否显示
function MainSceneUI:setBuoyBtnsVisible(isNotFadeIn,vType)
    local barBg = self.panel1:getChildByName('bar_bg')
    local winSize = cc.Director:getInstance():getVisibleSize()
    local conf = GameData:getConfData('moduleopen')['lord']
    local cityId = conf.cityId
    local isFirst = MapData.data[cityId]:getBfirst()
    local extraMask = {
        true,
        GlobalApi:getOpenInfo('lord') and (isFirst == false),
        true,
    }
    local changePos = {
        true,
        true,
        false,
    }
    local size = self.buoyBtns[1]:getContentSize()
    local x,y = winSize.width, winSize.height - 90
    local vertical = 60
    for i=1,#self.buoyBtns do
        local visible = extraMask[i]
        if isNotFadeIn == 1 then
            if vType then
                self.buoyBtns[i]:setVisible(visible and i == vType)
            else
                self.buoyBtns[i]:setVisible(visible)
            end
        else
            self.buoyBtns[i]:setOpacity(0)
            self.buoyBtns[i]:setVisible(visible)
            self.buoyBtns[i]:runAction(cc.FadeIn:create(0.5))
        end
        if changePos[i] then
            self.buoyBtns[i]:setPosition(cc.p(x,y))
            if visible then
                y = y - vertical
            end
        end
    end
    if barBg then
        if isNotFadeIn == 1 then
            barBg:setVisible(true)
        else
            barBg:setVisible(true)
            barBg:setOpacity(0)
            barBg:runAction(cc.FadeIn:create(0.5))
        end
    end

    local tributeBtn = self.panel1:getChildByName('tribute_btn')
    local isTributeOpen = GlobalApi:getOpenInfo('tribute')
    local currScale = math.floor(self.currScale * 100)/100
    if isTributeOpen and currScale > MIN_SCALE then
        if isNotFadeIn == 1 then
            tributeBtn:setVisible(true)
        else
            tributeBtn:setVisible(true)
            tributeBtn:setOpacity(0)
            tributeBtn:runAction(cc.FadeIn:create(0.5))
        end
    else
        tributeBtn:setVisible(false)
    end

end

function MainSceneUI:showRunBar(callback)
    local barBg = self.panel1:getChildByName('bar_bg')
    if barBg then
        barBg:setVisible(true)
    end
    if callback then
        callback()
    end
end

function MainSceneUI:refreshRunBar()
    local isFirst = MapData.data[24]:getBfirst()
    local barBg = self.panel1:getChildByName('bar_bg')
    local fightedId = MapData:getFightedCityId()
    -- 次数是否已经用完了
    local use = 0
    local maxNum = 0 
    if MapData:getDropDragons() ~= nil  then
        use = MapData:getDropDragons().use
        maxNum = MapData:getDropDragons().num
    end
    if (fightedId == 24 and not isFirst) or (use >= maxNum and fightedId >= 24) then
        if barBg then
            self.panel1:removeChildByName('bar_bg')
            self:createRunBar()
        end
    end
end

function MainSceneUI:updateRunBar(callback)
    local fightedId = MapData:getFightedCityId()
    local barBg = self.panel1:getChildByName('bar_bg')
    if not barBg then
        return
    end
    local num = 0
    for i=1,24 do
        local conf = GameData:getConfData('feilongfly')[i]
        if fightedId >=i and conf and conf.play ~= 0 then
            num = num + 1
        end
    end
    if num == 0 then
        num = 1
    end
    local imgs = {'emoticon_1.png','emoticon_2.png','emoticon_2.png','emoticon_6.png'}
    if barBg then
        local bar = barBg:getChildByName('bar')
        local perTx = barBg:getChildByName('bar_tx')
        local img = barBg:getChildByName('img')
        local obj = BagData:getFragmentById(4208)
        local obj1 = RoleData:getRoleInfoById(4208)
        if bar and perTx and img then
            if obj then
                local num = obj:getNum()
                local num1 = obj:getMergeNum()
                perTx:setString(num..'/'..num1)
                if num > num1 then
                    bar:setPercent(100)
                else
                    bar:setPercent(num/num1*100)
                end
            else
                perTx:setString('0/80')
                bar:setPercent(0)
           end
        end
    end
    if callback then
        callback()
    end
end

function MainSceneUI:createDiDi()
    local winSize = cc.Director:getInstance():getVisibleSize()
    if self.panel1:getChildByName('bar_bg') then
        self.panel1:removeChildByName('bar_bg')
    end
    local dididalongImg = ccui.ImageView:create('uires/ui/activity/dididalong.png')
    dididalongImg:setName('bar_bg')
    dididalongImg:setScale(0.8)
    dididalongImg:setTouchEnabled(true)
    dididalongImg:setPosition(cc.p(winSize.width/2,winSize.height - 100))
    self.panel1:addChild(dididalongImg)
    dididalongImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:showLiubeiInfoPanel()
        end
    end)
end

function MainSceneUI:createRunBar()
    local fightedId = MapData:getFightedCityId()
    --[[
    local openTime = Time.beginningOfOneDay(UserData:getUserObj():getServerOpenTime())
    local nowTime = GlobalData:getServerTime()
    local obj = BagData:getFragmentById(4208)
    local num = 0
    local num1 = 80
    if obj then
        num = obj:getNum()
        num1 = obj:getMergeNum()
    end
    local level = UserData:getUserObj():getLv()
    local data = MapData.data[4]
    local star = data:getStar(1)
    if level < 3 or star <= 0 or (fightedId >= 24 and (nowTime - openTime) >= 86400*3) or (fightedId >= 24 and num < num1) then
        return
    end
    --]]
    local level = UserData:getUserObj():getLv()
    -- 次数是否已经用完了
    local use = 0
    local maxNum = 0 
    if MapData:getDropDragons() ~= nil  then
        use = MapData:getDropDragons().use
        maxNum = MapData:getDropDragons().num
    end
    if fightedId < 4 or (use >= maxNum and fightedId >= 24) then
        return
    end
    
    if self.panel1:getChildByName('bar_bg') then
        self.panel1:removeChildByName('bar_bg')
    end

    local winSize = cc.Director:getInstance():getVisibleSize()
    local node = cc.CSLoader:createNode('csb/mapbar.csb')
    local barBg = node:getChildByName('bar_bg')
    local bar = barBg:getChildByName('bar')
    local img = barBg:getChildByName('img')
    img:ignoreContentAdaptWithSize(true)
    img:loadTexture('uires/ui/activity/dididalong.png')
    img:setScale(0.8)
    local descTx = barBg:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('CLICK_VIEW'))
    descTx:setOpacity(0)
    descTx:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1),cc.FadeIn:create(0.5),cc.DelayTime:create(1),cc.FadeOut:create(0.5)),3))
    barBg:removeFromParent(false)
    barBg:setPosition(cc.p(winSize.width/2,winSize.height - 100))
    bar:setScale9Enabled(true)
    bar:setCapInsets(cc.rect(10,15,5,5))
    bar:setPercent(0)
    barBg:setName('bar_bg')
    self.panel1:addChild(barBg)
    self:updateRunBar()

    if MapData.data[fightedId]:getBfirst() == true and fightedId == 4 then
        barBg:setVisible(false)
    end

    barBg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.isNotOnShow = true
            MapMgr:showLiubeiInfoPanel()
        end
    end)
    img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.isNotOnShow = true
            MapMgr:showLiubeiInfoPanel()
        end
    end)
    local isFirst = MapData.data[24]:getBfirst()
    if fightedId > 24 or (fightedId == 24 and not isFirst)then
        self:createDiDi()
    end
end

--创建外框按钮
function MainSceneUI:createBtns()
    local locateBtn = ccui.Button:create('uires/ui/mainscene/locate_nor_btn.png')
    local prefectureBtn = ccui.Button:create('uires/ui/mainscene/prefecture_nor_btn.png','uires/ui/mainscene/prefecture_sel_btn.png')
    local backBtn = ccui.Button:create('uires/ui_new/buoy/fight_nor_btn.png','uires/ui_new/buoy/fight_sel_btn.png')
    local changeBtn = ccui.Button:create('uires/ui/mainscene/jingying.png')
    backBtn:setName("back_btn")
    locateBtn:setName("locate_btn")
    changeBtn:setName("change_btn")
    prefectureBtn:setName("lord_btn")
    locateBtn:setAnchorPoint(cc.p(0.8,1))
    prefectureBtn:setAnchorPoint(cc.p(1,1))
    self.root:addChild(locateBtn,9999)
    self.root:addChild(prefectureBtn,9999)
    self.root:addChild(backBtn,9999)

    local size = backBtn:getContentSize()
    local backBtnTx = ccui.Text:create()
    backBtnTx:setFontName("font/gamefont1.TTF")
    backBtnTx:setFontSize(22)
    backBtnTx:setColor(cc.c4b(254,254,254, 255))
    backBtnTx:enableOutline(cc.c4b(34,28,44, 255),2)
    backBtnTx:setString(GlobalApi:getLocalStr_new("MAINSCENE_BTN_STE2"))
    backBtnTx:setPosition(cc.p(size.width/2,20))
    backBtn:addChild(backBtnTx,9998)

    local size1 = locateBtn:getContentSize()
    if not self.nameRts then
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(220, 30))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
        local re1 = xx.RichTextLabel:create('', 24, COLOR_TYPE.WHITE)
        local re2 = xx.RichTextLabel:create('', 24, COLOR_TYPE.WHITE)
        re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        re1:setFont('font/gamefont1.TTF')
        re2:setFont('font/gamefont1.TTF')
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:setPosition(cc.p(180,size1.height/2))
        locateBtn:addChild(richText)
        self.nameRts = {richText = richText,re2 = re2,re1 = re1}
    end
    changeBtn:setPosition(cc.p(40,size1.height/2))
    locateBtn:addChild(changeBtn)

    local size = backBtn:getContentSize()
    backBtn:setAnchorPoint(cc.p(0,0.5))
    backBtn:setPosition(cc.p(25,size.height/2))
    backBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideMainScene()
            MainSceneMgr:showMainCity()
        end
    end)

    local isOpen = GlobalApi:getOpenInfo('elite')
    changeBtn:setVisible(isOpen)
    locateBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local id = MapData:getCanFighttingIdByPage(self.locatePage)
            MapMgr:setWinPosition(id,2)
        end
    end)

    changeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local page = self.locatePage%2 + 1
            self.locatePage = page
            MapMgr.locatePage = page
            self:updateFightBtn()
            self:updateLocation(self.buoyBtns)
            self:updateOpen()
            local id = MapData:getCanFighttingIdByPage(self.locatePage)
            MapMgr:setWinPosition(id,2)
        end
    end)

    prefectureBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local mapData = MapData.data
            local owners = {}
            local uid = UserData:getUserObj():getUid()
            local cityId
            local args = {}
            MessageMgr:sendPost('get_lord_list','battle',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    local owners = data.lord
                    -- for i,v in ipairs(mapData) do
                    --     local owner = owners[tostring(i)]
                    --     print('======================0',i,owner)
                    --     if owner then
                    --         print('======================1',i,owner.uid,uid)
                    --     end
                    --     if owner and owner.uid == uid then
                    --         cityId = i
                    --     end
                    -- end
                    -- print('=======================',cityId)
                    MapData:setLordDrop(data.self_lord_drop)
                    if data.self then
                        MapData.lordId = tonumber(data.self)
                        MapMgr:showPrefecturePanel(tonumber(data.self),owners[tostring(data.self)])
                    else
                        MapMgr:showViewPrefecturePanel(owners)
                    end
                end
            end)
        end
    end)

    local node = cc.CSLoader:createNode("csb/tributebtn.csb")
    local tributeBtn = node:getChildByName('tribute_btn')
    local winSize = cc.Director:getInstance():getVisibleSize()
    tributeBtn:setPosition(cc.p(20,winSize.height -140))
    tributeBtn:removeFromParent(false)
    self.panel1:addChild(tributeBtn)
    tributeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('tribute')
        end
    end)
    
    self.buoyBtns = {locateBtn,prefectureBtn,backBtn}
    self:setBuoyBtnsVisible(1)
    self:updateLocation()

end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑外框浮标管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓城池名称底板管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--更新当前城市名字的背景
function MainSceneUI:updateCityName(award)
    local cityDatas = MapData.data
    local isRun = false
    for i=0,MapData.currProgress do
        local cityBtn = self.panel2:getChildByName('map_city_'..i)
        if cityBtn then
            local size = cityBtn:getContentSize()
            local nameNode= self.panel2:getChildByName('node_name_'..i)
            local star = MapData.data[i]:getStar(1)
            local star1 = MapData.data[i]:getStar(2)
            local isFirst = MapData.data[i]:getBfirst()
            if not nameNode then
                if i == 0 then
                    nameNode = self:createNameBg(cityBtn,i)
                else
                    nameNode = self:createNameBg(cityBtn,i,1)
                end
                self.panel2:addChild(nameNode,CityNameZOrder)
                nameNode:setName('node_name_'..i)
            end
            local nameBgImg = nameNode:getChildByName('name_bg_img')
            local nameTx = nameBgImg:getChildByName('name_tx')
            if i == 0 then
                nameBgImg:loadTexture('uires/ui/mainscene/0-0.png')
            elseif star > 0 then
                if isFirst == true then
                    isRun = true
                    -- if hideImg then
                    --     hideImg:setTouchEnabled(true)
                    -- end
                    local str = 'ui_citycraft_light_t'
                    local animation = GlobalApi:createLittleLossyAniByName(str)
                    -- animation:getAnimation():playWithIndex(0, -1, 1)
                    cityBtn:addChild(animation)
                    animation:setName(str)
                    animation:setPosition(cc.p(size.width/2,0))
                    local function movementFun(armature, movementType, movementID)
                        if movementType == 2 then
                            animation:removeFromParent()
                        end
                    end
                    -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                        UIManager:getSidebar():mapBtnsFly('star')
                    -- end)))
                    animation:getAnimation():setMovementEventCallFunc(movementFun)
                    nameBgImg:runAction(cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function()
                        animation:getAnimation():playWithIndex(0, -1, 1)
                        nameBgImg:loadTexture('uires/ui/mainscene/'..star..'-'..star1..'.png')
                        -- if star == 3 and star1 == 3 then
                        --     -- nameBgImg:loadTexture('uires/ui/mainscene/qi.png')
                        --     nameNode:setPosition(cc.p(cityBtn:getPositionX(),cityBtn:getPositionY()))
                        -- else
                        --     -- nameBgImg:loadTexture('uires/ui/mainscene/'..star..'-'..star1..'.png')
                        --     nameNode:setPosition(cc.p(cityBtn:getPositionX(),cityBtn:getPositionY() - size.height/3))
                        -- end
                        nameTx:setColor(COLOR_QUALITY[1].color)
                        nameTx:setPosition(COLOR_QUALITY[1].pos2)
                        nameTx:enableOutline(COLOR_QUALITY[1].outline,1)
                        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    end),cc.FadeIn:create(0.5),cc.CallFunc:create(function()
                            if MapData.data[i].conf.moduleOpenId and MapData.data[i].conf.moduleOpenId ~= '0' then
                                -- if hideImg then
                                --     hideImg:setTouchEnabled(false)
                                -- end
                                UIManager:getSidebar():setHide(false)
                                MapMgr:sendTribute(i,function()
                                    MapData.data[i]:setBfirst(false)
                                    MapMgr:showModuleopenPanel(i)
                                end)
                            elseif MapData.data[i].conf.tributeVisible == 0 then
                                -- if hideImg then
                                --     hideImg:setTouchEnabled(false)
                                -- end
                                UIManager:getSidebar():setHide(false)
                                MapMgr:sendTribute(i,function()
                                    MapData.data[i]:setBfirst(false)
                                    if MapData.data[i].conf.guideIndex > 0 then
                                        GuideMgr:startCityOpenGuide(MapData.data[i].conf.guideIndex, 1)
                                    end
                                end)
                            else
                                local type1,type2 = MapData.data[i]:getTypes()
                                local id = i
                                local function callback(ntype)
                                    if self.hideImg then
                                        self.hideImg:setTouchEnabled(false)
                                    end
                                    UIManager:getSidebar():setHide(false)
                                    if award and ntype then
                                        MapMgr:showAwardPanel()
                                        if self.showDragonDiDi == true then
                                            self.showDragonDiDi = nil
                                            MapMgr:showLiubeiInfoPanel(true)
                                        end
                                    else
                                        MapMgr:sendTribute(i,function()
                                            MapData.data[i]:setBfirst(false)
                                            self:updateFinger()
                                            if MapData.data[i].conf.guideIndex > 0 then
                                                GuideMgr:startCityOpenGuide(MapData.data[i].conf.guideIndex, 1)
                                            end
                                            if self.showDragonDiDi == true then
                                                self.showDragonDiDi = nil
                                                MapMgr:showLiubeiInfoPanel(true)           
                                            end
                                        end)
                                    end
                                end
                                if type1 == 1 and type2 == 2 then
                                    self:feilongFly(i,function()
                                        local id = MapData.data[i]:getCamp()
                                        UIManager:getSidebar():setHide(false)
                                        MapMgr:showTalkPanel(i,function()
                                            local name = GlobalApi:getLocalStr('CAMP_'..id)
                                            MapMgr:showPowerEndPanel(name,callback,i)
                                        end,true)
                                    end)
                                else
                                    self:feilongFly(i,function(ntype)
                                        callback(ntype)
                                    end)
                                end
                            end
                        end)))
                else
                    nameBgImg:loadTexture('uires/ui/mainscene/'..star..'-'..star1..'.png')
                    -- if star == 3 and star1 == 3 then
                    --     -- nameBgImg:loadTexture('uires/ui/mainscene/qi.png')
                    --     nameNode:setPosition(cc.p(cityBtn:getPositionX(),cityBtn:getPositionY()))
                    -- else
                        -- nameBgImg:loadTexture('uires/ui/mainscene/'..star..'-'..star1..'.png')
                        -- nameNode:setPosition(cc.p(cityBtn:getPositionX(),cityBtn:getPositionY() - size.height/3))
                    -- end
                end
            end
            nameBgImg:ignoreContentAdaptWithSize(true)
        end
    end
    local cityData = MapData.data[MapData.currProgress]
    local btn1 = self.panel2:getChildByName('map_city_'..MapData.currProgress)
    -- btn1:setVisible(true)
    -- btn1:setTouchEnabled(true)
    -- btn1:setBright(true)
    if isRun == false and award then
        MapMgr:showAwardPanel()
    end
end

function MainSceneUI:feilongFlyCallback()
    if self.feilongflyCallback then
        local fightedId = MapData:getFightedCityId()
        local tempData = GameData:getConfData('feilongfly')
        if tempData[fightedId].showDragonDiDi == 1 then
            self.showDragonDiDi = true
        end
        self.feilongflyCallback(false)
        -- UIManager:showSidebar({1,2,4,5,6},{1,2,3},true)
        -- local backBtn = self.root:getChildByName('back_btn')
        -- local locateBtn = self.root:getChildByName('locate_btn')
        -- backBtn:setVisible(true)
        -- locateBtn:setVisible(true)
        self.feilongflyCallback = nil
    end
end

function MainSceneUI:feilongFly(cityId,callback)
    local conf = GameData:getConfData('feilongfly')[cityId]
    if not conf then
        callback(true)
        return
    elseif conf.play == 0 then
        if conf.guideIndex and conf.guideIndex ~= 0 then
            GuideMgr:startCityOpenGuide(conf.guideIndex, 1)
            self.feilongflyCallback = callback
        else
            if callback then
                callback(false)
            end
        end
        return
    end
    -- UIManager:showSidebar({0},{0})
    -- local backBtn = self.root:getChildByName('back_btn')
    -- local locateBtn = self.root:getChildByName('locate_btn')
    -- backBtn:setVisible(false)
    -- locateBtn:setVisible(false)

    local acionname = conf.action
    local nextCityId
    for i= cityId + 1,#MapData.data do
        local conf1 = GameData:getConfData('feilongfly')[i]
        if conf1 and conf1.play ~= 0 then
            nextCityId = i
            break
        end
    end
    local spine = self.panel2:getChildByName('feilong_spine')
    if not nextCityId then
        spine:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(callback)))
        return
    end
    local helpImg = spine:getChildByName('help_img')
    local nextCityData = MapData.data[nextCityId]
    local cityData = MapData.data[cityId]
    local pos = nextCityData:getBtnPos()
    local flyConf = GameData:getConfData('feilongfly')[nextCityId]
    local endPos = cc.p(pos.x + flyConf.posX,pos.y + flyConf.posY)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local anchor = self.panel3:getAnchorPoint()
    local scale = 0.5
    local point = cc.p(
        6144*scale*anchor.x - pos.x*scale + winSize.width/2,
        4096*scale*anchor.y - pos.y*scale + winSize.height/2)
    local nextAcionname = flyConf.action
    spine:registerSpineEventHandler(function (event)
        if event.animation == tostring(nextAcionname..'_anim1') then
            self.panel3:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                if nextAcionname == 'liubei' then
                    helpImg:stopAllActions()
                    helpImg:setVisible(true)
                    helpImg:setOpacity(0)
                    helpImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.FadeIn:create(0.5),cc.DelayTime:create(1),cc.FadeOut:create(0.5))))
                end
                spine:runAction(cc.MoveTo:create(2,endPos))
                spine:setAnimation(0, tostring(nextAcionname..'_anim2'), true)
            end),cc.MoveTo:create(2,point),
            cc.CallFunc:create(function()
                helpImg:setVisible(false)
                spine:setAnimation(0, tostring(nextAcionname..'_anim3'), false)
                spine:setLocalZOrder(FeilongZOrderLow)
            end)))
        elseif event.animation == tostring(nextAcionname..'_anim3') then
            self.panel3:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                if nextAcionname == 'liubei' then
                    spine:setAnimation(0, tostring(nextAcionname..'_anim5'), true)
                else
                    spine:setAnimation(0, tostring(nextAcionname..'_anim4'), true)
                end
                self:setWinPosition(cityId,nil,nil,function()
                    UIManager:getSidebar():setHide(false)
                    if conf.guideIndex and conf.guideIndex ~= 0 then
                        GuideMgr:startCityOpenGuide(conf.guideIndex, 1)
                        self.feilongflyCallback = callback
                    else
                        if callback then
                            callback()
                        end
                    end
                end,1)
            end)))
        end
    end, sp.EventType.ANIMATION_END)

    local pl = self.panel2:getChildByName('box_pl')
    local box = pl:getChildByName('box_spine')
    helpImg:setVisible(false)
    helpImg:setPosition(cc.p(25,225))
    helpImg:loadTexture('uires/ui/mainscene/help_2.png')
    self:setWinPosition(cityId,nil,nil,function()
        if conf.action1 and conf.action1 ~= '' then
            if conf.action1 == 'suipian' then
                local x = box:getScaleX()
                if x < 0 then
                    box:setScaleX(-1)
                    box:setScaleY(1)
                else
                    box:setScale(1)
                end
            end
            pl:setVisible(true)
            self.action1 = conf.action1
            box:setAnimation(0, tostring(conf.action1..'_idle'), true)
        end
        spine:setAnimation(0, tostring(nextAcionname..'_anim1'), false)
        spine:setLocalZOrder(FeilongZOrderHigh)
        self:detectEdges(point)
        self:createBgByPos(point)
    end,0.5)
end

function MainSceneUI:boxFly(equip,callback)
    local pl = self.panel2:getChildByName('box_pl')
    local winSize = cc.Director:getInstance():getVisibleSize()
    local tab = pl:convertToWorldSpace(cc.p(0,0))
    local box = self.panel1:getChildByName('box_a')
    local equipFly
    if not box then
        box = GlobalApi:createSpineByName('ui_map_box', "spine/ui_map_box/ui_map_box", 1)
        box:setAnimation(0,'suipian_idle', true)
        box:setName('box_a')
        box:setPosition(cc.p(tab.x + 50,tab.y))
        box:setScale(1)
        self.panel1:addChild(box)

        if equip then
            local stype = equip:getCategory()
            local img = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equip, self.panel1)
            img.lvTx:setString('Lv.'..equip:getLevel())
            img.awardBgImg:setPosition(cc.p(tab.x + 50,tab.y))
            img.awardBgImg:setScale(0)
            ClassItemCell:setGodLight(img.awardBgImg,equip:getGodId())
            equipFly = img.awardBgImg
        end
    end
    box:setVisible(true)
    if not callback then
        box:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(winSize.width/2,winSize.height - 100)),cc.CallFunc:create(function()
            box:setVisible(false)
            self:updateRunBar()
            if equip and equipFly then
                equipFly:runAction(cc.Sequence:create(cc.JumpTo:create(2,cc.p(winSize.width/2,winSize.height/2),15,4),
                    cc.DelayTime:create(0.2),
                    cc.MoveTo:create(0.5,cc.p(winSize.width - 55,55)),
                    cc.CallFunc:create(function()
                        equipFly:removeFromParent()
                        self.isNotShow = true
                        MapMgr:showGodPanel(equip,GlobalApi:getLocalStr('C_GET_GOD_EQUIP'))
                    end)
                ))
                equipFly:runAction(cc.Sequence:create(cc.ScaleTo:create(2,1),cc.DelayTime:create(0.2),cc.ScaleTo:create(0.5,0)))
            end
        end)))
        box:runAction(cc.ScaleTo:create(1,0.01))
    else
        box:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(winSize.width/2,winSize.height - 100)),cc.CallFunc:create(function()
            box:setVisible(false)
            self:updateRunBar()
        end)))
        equipFly:setScale(0.5)
        equipFly:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(1,cc.p(winSize.width/2,winSize.height - 100)),cc.CallFunc:create(function()
            equipFly:removeFromParent()
            callback()
        end)))
        box:runAction(cc.ScaleTo:create(1,0.01))
        equipFly:runAction(cc.ScaleTo:create(1,0.01))
    end
end

function MainSceneUI:showDiDiGet(callback)
     MapMgr:showGodPanel(nil,GlobalApi:getLocalStr('MAP_DIDI_DESC'),callback)
end

function MainSceneUI:getFeilongBoxAwards(callback)
    local args = {id = self.feilongCityId}
    MessageMgr:sendPost('open_pass_box','battle',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommonByText(awards)
            end
            local awardTab = DisplayData:getDisplayObjs(awards)
            local equip
            for i,v in ipairs(awardTab) do
                if v:getObjType() == 'equip' then
                    equip = v
                end
            end
            local pl = self.panel2:getChildByName('box_pl')
            local box = pl:getChildByName('box_spine')
            box:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
                -- if self.action1 == 'liubei' or self.action1 == 'suipian' then
                    self:boxFly(equip,callback)
                -- end
            end)))
        end
    end)
end

function MainSceneUI:updateFeilongSpine()
    -- animation1 抓起刘备
    -- animation2 抓起刘备飞
    -- animation3 抓起刘备落
    -- animation4 把刘备踩在脚下睡觉
    -- animation5 把虚弱的刘备踩在脚下休息
    local cityId,cityId1
    local fightedId = MapData:getFightedCityId()
    local num = fightedId
    if not MapData.data[fightedId]:getBfirst() then
        num = fightedId + 1
    end
    for i= num,#MapData.data do
        local conf = GameData:getConfData('feilongfly')[i]
        if conf and conf.play ~= 0 then
            if not cityId then
                cityId = i
            else
                cityId1 = i
                break
            end
        end
    end
    if not cityId then
        return
    end
    local flyConf = GameData:getConfData('feilongfly')[cityId]
    local acionname = flyConf.action
    local cityData = MapData.data[cityId]
    local beginPos = cityData:getBtnPos()
    local box = GlobalApi:createSpineByName('ui_map_box', "spine/ui_map_box/ui_map_box", 1)
    -- box:setPosition(cc.p(beginPos.x + flyConf.posX,beginPos.y + flyConf.posY))
    box:setAnimation(0, 'liubei_idle', true)
    box:setName('box_spine')
    box:setPosition(cc.p(50,0))
    box:setScale(0.5)
    self.feilongCityId = cityId
    box:registerSpineEventHandler(function (event)
        if event.animation == self.action1..'_open' then
            local args = {id = cityId}
            MessageMgr:sendPost('open_pass_box','battle',json.encode(args),function (response)
                local code = response.code
                local data = response.data
                if code == 0 then
                    local awards = data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommonByText(awards)
                    end
                    local awardTab = DisplayData:getDisplayObjs(awards)
                    local equip
                    for i,v in ipairs(awardTab) do
                        if v:getObjType() == 'equip' then
                            equip = v
                        end
                    end
                    box:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
                        if self.action1 == 'liubei' or self.action1 == 'suipian' then
                            self:boxFly(equip)
                        end
                    end)))
                end
            end)
        end
    end, sp.EventType.ANIMATION_END)
    local node = cc.CSLoader:createNode("csb/thief.csb")
    local pl = node:getChildByName('pl')
    local thiefImg = pl:getChildByName('thief_img')
    thiefImg:setLocalZOrder(1)
    thiefImg:setVisible(false)

    pl:removeFromParent(false)
    pl:setContentSize(cc.size(100,100))
    pl:setPosition(cc.p(beginPos.x + flyConf.posX,beginPos.y + flyConf.posY))
    pl:setName('box_pl')
    pl:setLocalZOrder(FeilongZOrderLow - 1)
    pl:setVisible(false)
    pl:addChild(box)
    pl:setTouchEnabled(true)
    pl:setColor(cc.c3b(255,0,0))
    pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.action1 then
                box:setAnimation(0, tostring(self.action1..'_open'), false)
            end
        end
    end)

    local spine = GlobalApi:createSpineByName('ui_map_feilong', "spine/ui_map_feilong/ui_map_feilong", 1)
    spine:setPosition(cc.p(beginPos.x + flyConf.posX,beginPos.y + flyConf.posY))
    spine:setAnimation(0, tostring(acionname..'_anim4'), true)
    spine:setName('feilong_spine')
    spine:setLocalZOrder(FeilongZOrderLow)
    spine:setScale(0.5)

    local helpImg = ccui.ImageView:create('uires/ui/mainscene/help_2.png')
    helpImg:setAnchorPoint(cc.p(0.5,1))
    helpImg:setPosition(cc.p(0,150))
    helpImg:setName('help_img')
    helpImg:setVisible(false)
    helpImg:setScale(2)

    if cityId1 then
        local endPos = MapData.data[cityId1]:getBtnPos()
        spine:setScaleX(endPos.x < beginPos.x and -0.5 or 0.5)
        box:setScaleX(endPos.x < beginPos.x and -0.5 or 0.5)
        helpImg:setScaleX(endPos.x < beginPos.x and -2 or 2)
    else
        spine:setScaleX(-0.5)
        box:setScaleX(-0.5)
        helpImg:setScaleX(-2)
    end
    if acionname == 'liubei' then
        helpImg:setPosition(cc.p(0,400))
        helpImg:setVisible(true)
        helpImg:stopAllActions()
        helpImg:setOpacity(0)
        helpImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),cc.FadeIn:create(0.5),cc.DelayTime:create(1),cc.FadeOut:create(0.5))))
    end
    spine:addChild(helpImg)
    self.panel2:addChild(pl)
    self.panel2:addChild(spine)
end

--创建城池名称底板
function MainSceneUI:createNameBg(btn,cityId)
    if cityId > MapData.currProgress then
        return
    end
    local city = MapData.data[cityId]
    local size = btn:getContentSize()
    local camp
    local name
    local star
    local star1
    local isFirst
    if cityId == 0 then
        star = 0
        star1 = 0
        isFirst = false
    else
        star = city:getStar(1)
        star1 = city:getStar(2)
        isFirst = city:getBfirst()
        if star > 0 and isFirst == false then
            camp = 1
        else
            camp = tonumber(city:getCamp()) or 1
        end
    end
    name = city:getName()
    local nameNode = cc.CSLoader:createNode("csb/name.csb")
    local nameBgImg = nameNode:getChildByName('name_bg_img')
    local nameTx = nameBgImg:getChildByName('name_tx')
    if (star ~= nil) and (star1 ~= nil) and (isFirst ~= nil) and isFirst == false then
        nameBgImg:loadTexture('uires/ui/mainscene/'..star..'-'..star1..'.png')
        nameTx:setColor(COLOR_QUALITY[1].color)
        nameTx:setPosition(COLOR_QUALITY[1].pos2)
        nameTx:enableOutline(COLOR_QUALITY[1].outline,1)
        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    else
        nameBgImg:loadTexture('uires/ui/mainscene/name_bg_'..camp..'.png')
        nameTx:setColor(COLOR_QUALITY[1].color)
        nameTx:setPosition(COLOR_QUALITY[1].pos2)
        nameTx:enableOutline(COLOR_QUALITY[1].outline,1)
        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    end
    nameTx:setString(name)
    nameBgImg:ignoreContentAdaptWithSize(true)
    nameNode:setPosition(cc.p(btn:getPositionX(),btn:getPositionY() - size.height/3))
    return nameNode
end

--创建所有城池名称底板
function MainSceneUI:createCityName()
    -- local fightedId = MapData:getFightedCityId()
    -- if cityId > fightedId then
    --     return
    -- end
    for i=0,MapData.currProgress do
        local btn = self.panel2:getChildByName('map_city_'..i)
        local nameNode = self.panel2:getChildByName('node_name_'..i)
        if btn and not nameNode then
            nameNode = self:createNameBg(btn,i)
            self.panel2:addChild(nameNode,CityNameZOrder)
            nameNode:setName('node_name_'..i)
        end
    end
end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑城池名称底板管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓大地图碎片管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--获得地图碎片颜色
function MainSceneUI:getColor(i)
    if i < 124 and i > 0 then
        local cityData = MapData.data[i]
        local camp = tonumber(cityData:getCamp())
        if i <= MapData.maxProgress and cityData:getStar(1) > 0 then
            if self.guideZoomFlag and i == 8 then
                return cc.c3b(255,0,0)
            else
                return COLOR_QUALITY[1].campcolor
            end
        else
            return COLOR_QUALITY[camp or 1].campcolor
        end
    else
        return COLOR_QUALITY[1].campcolor
    end
end
--设置势力名字颜色
function MainSceneUI:setPowerSign1(panel)
    local star = MapData.data[MapData.currProgress]:getStar(1)
    local conf
    if star > 0 or MapData.currProgress == 0 then
        conf = GameData:getConfData("camppos")[MapData.currProgress]
    else
        conf = GameData:getConfData("camppos")[MapData.currProgress - 1]
    end
    for i=1,11 do
        local nameTx = panel:getChildByName('name_'..i..'_tx')
        local camp = conf['camp'..i]
        if MapData.currProgress == 0 and i == 1 then
            nameTx:setVisible(false)
        else
            nameTx:setVisible(true)
        end
        if camp and camp[1] then
            nameTx:setString(GlobalApi:getLocalStr('CAMP_'..i))
            local cityData = MapData.data[tonumber(camp[1])]
            local pos = cityData:getBtnPos()
            local posX,posY = pos.x*MIN_SCALE,pos.y*MIN_SCALE
            nameTx:setPosition(cc.p(posX + tonumber(camp[2] or 0),posY + tonumber(camp[3] or 0)))
        else
            nameTx:setString('')
        end
    end
end

--设置地图碎片颜色
function MainSceneUI:setBtnsTouchEnabled(pl2,b)
    for i=0,#MapData.data do
        local btn = self.panel2:getChildByName('map_city_'..i)
        if btn then
            btn:setTouchEnabled(b)
        end
    end
end

function MainSceneUI:changeColor(img,sprite)
    local color1 = cc.c3b(255,0,0) --self:getColor(8)
    local color = self:getColor(0)
    local endR,endG,endB = color1.r,color1.g,color1.b
    local beginR,beginG,beginB = color.r,color.g,color.b
    local colorR,colorG,colorB = color.r,color.g,color.b
    local changeColor2
    local index1 = 1
    local function changeColor1()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.03),cc.CallFunc:create(function()
            if math.abs(colorG - beginG) > 3 then
                img:setColor(cc.c3b(colorR,colorG,colorB))
                colorR = colorR + math.ceil((beginR - endR)/3)
                colorG = colorG + math.ceil((beginG - endG)/3)
                colorB = colorB + math.ceil((beginB - endB)/3)
                changeColor1()
            else
                img:setColor(cc.c3b(beginR,beginG,beginB))
                colorR,colorG,colorB = beginR,beginG,beginB
                self.root:stopAllActions()
                changeColor2()
            end
        end)))
    end
    changeColor2 = function()
        if index1 > 2 then
            self.guideZoomFlag = false
            self:setCityBtnsStatus(true)
            local btn2 = self.panel2:getChildByName('map_city_9')
            local size2 = btn2:getContentSize()
            local pos = cc.p(btn2:getPositionX()*self.currScale,btn2:getPositionY()*self.currScale)
            sprite:runAction(cc.MoveTo:create(1,pos))
            return
        end
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.07),cc.CallFunc:create(function()
            if endG ~= colorG then
                img:setColor(cc.c3b(colorR,colorG,colorB))
                colorR = colorR + (endR - beginR)/4
                colorG = colorG + (endG - beginG)/4
                colorB = colorB + (endB - beginB)/4
                changeColor2()
            else
                index1 = 1 + index1
                img:setColor(cc.c3b(endR,endG,endB))
                colorR,colorG,colorB = endR,endG,endB
                self.root:stopAllActions()
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                    changeColor1()
                end)))
            end
        end)))
    end
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(changeColor1)))
end
--设置地图碎片颜色
function MainSceneUI:setPowerSign()
    self.root:stopAllActions()
    if self.guideZoomFlag and self.currScale <= MIN_SCALE and self.guideCallback then
        self.guideCallback()
        self.guideCallback = nil
    end
    self:updateFinger()
    if self.currScale <= MIN_SCALE and self.isMin ~= true then
        self:setBuoyBtnsVisible(1,1)
        UIManager:showSidebar({0},{0})
        local barBg = self.panel1:getChildByName('bar_bg')
        if barBg then
            barBg:setVisible(false)
        end
        self.isMin = true
        local chipPanel = self.panel2:getChildByTag(99999)
        if not chipPanel then
            chipPanel = cc.CSLoader:createNode("csb/map_chip.csb")
            chipPanel:setOpacity(0)
            chipPanel:setPosition(cc.p(0,0))
            self.panel2:addChild(chipPanel,ChipZOrder,99999)
        end
        chipPanel:runAction(cc.FadeIn:create(0.5))
        chipPanel:setScale(1/self.currScale)
        local panel = chipPanel:getChildByName('map_pl')
        local mapBg = panel:getChildByName('map_bg_img')
        local sprite = chipPanel:getChildByTag(9999)
        local btn = self.panel2:getChildByName('map_city_'..MapData.currProgress)
        if not sprite then
            sprite = GlobalApi:createSpineByName('map_fight', "spine/map_fight/map_fight", 1)
            sprite:setPosition(cc.p(btn:getPositionX()*self.currScale,btn:getPositionY()*self.currScale))
            sprite:setAnimation(0, 'animation', true)
            chipPanel:addChild(sprite,FightZOrder,9999)
        else
            sprite:setPosition(btn:getPositionX()*self.currScale,btn:getPositionY()*self.currScale)
        end
        if self.guideZoomFlag then
            local btn1 = self.panel2:getChildByName('map_city_8')
            sprite:setPosition(btn1:getPositionX()*self.currScale,btn1:getPositionY()*self.currScale)
        end
        for i=0,#MapData.data do
            local cityData = MapData.data[i]
            local id = cityData:getChipId()
            local img = panel:getChildByName('chip_'..id..'_img')
            if img then
                local color = self:getColor(i)
                img:setColor(color)
                if self.guideZoomFlag and i == 8 then
                    self:changeColor(img,sprite)
                end
            end
        end
        local img1 = panel:getChildByName('chip_0_img')
        img1:setColor(COLOR_QUALITY[1].campcolor)

        -- for i,v in ipairs(MapData.data) do
        -- for i=0,#MapData.data do
        --     local btn = btns[i]
        --     if btn then
        --         btn:setTouchEnabled(false)
        --     end
        -- end
        self:setBtnsTouchEnabled(false)
        self:setPowerSign1(panel)
        local imgs = {}
        local index
        if MapData.data[MapData.currProgress]:getStar(1) > 0 then
            index = MapData.currProgress + 1
            if MapData.currProgress >= MapData.maxProgress then
                return
            end
        else
            index = MapData.currProgress
        end

        for i=index,MapData.maxProgress do
            local cityData = MapData.data[i]
            local id = cityData:getChipId()
            local img = panel:getChildByName('chip_'..id..'_img')
            img:setColor(cc.c3b(255,0,0))
        end

    elseif self.isMin == true then
        self.isMin = false
        local chipPanel = self.panel2:getChildByTag(99999)
        if chipPanel then
            chipPanel:runAction(cc.FadeOut:create(0.5))
        end
        for i=0,MapData.currProgress do
            local btn = self.panel2:getChildByName('map_city_'..i)
            if btn then
                btn:setTouchEnabled(true)
                btn:setSwallowTouches(false)
            end
        end
        UIManager:showSidebar({1,2,4,5,6,14},{1,2,3},true,true)
        self:setBuoyBtnsVisible(1)
    end
end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑大地图碎片管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓大地图云管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--云动画
function MainSceneUI:OneCloudMoveBy(currScale,cloudImg,j)
    local function cloudMoveBy(cloudImg)
        local act = {}
        local time = math.random(5,6)
        act[1] = cc.MoveBy:create(time, cc.p(0,10*self.currScale))
        act[2] = cc.MoveBy:create(time, cc.p(10*self.currScale,0))
        act[3] = cc.MoveBy:create(time, cc.p(0,-10*self.currScale))
        act[4] = cc.MoveBy:create(time, cc.p(-10*self.currScale,0))
        act[5] = cc.MoveBy:create(time, cc.p(0,-10*self.currScale))
        act[6] = cc.MoveBy:create(time, cc.p(-10*self.currScale,0))
        act[7] = cc.MoveBy:create(time, cc.p(0,10*self.currScale))
        act[8] = cc.MoveBy:create(time, cc.p(10*self.currScale,0))
        local i = math.random(1,4)
        local move = act[i]
        local move1 = act[i + 4]
        -- for i,v in ipairs(cloudImgs[index]) do
            if j == 1 then
                cloudImg:runAction(cc.Sequence:create(move,move1,cc.CallFunc:create(function()
                    cloudMoveBy(cloudImg)
                end)))
            else
                cloudImg:runAction(cc.Sequence:create(move,move1))
            end
        -- end
    end
    -- for i,v in ipairs(cloudImgs) do
        cloudMoveBy(cloudImg)
    -- end
end
--创建云动画
function MainSceneUI:updateCloudMove()
    for i,v in ipairs(self.cloudImgs) do
        for j,k in ipairs(v) do
            if k then
                k:stopAllActions()
                k:runAction(cc.Sequence:create(cc.MoveTo:create(2,self.cloudImgsPos[i][j]),cc.CallFunc:create(function()
                    self:OneCloudMoveBy(self.currScale,k,j)
                end)))
            end
        end
    end
end
--更新云探索按钮
function MainSceneUI:updateCloudBtn()
    local cityData = MapData.data[MapData.maxProgress]
    local cityData1 = MapData.data[MapData.maxProgress + 1]
    local cloudId = cityData:getGroup()
    local openStar = 10000
    if cityData1 then
       openStar = tonumber(cityData1:getNeedStar())
    end
    -- local level = UserData:getUserObj():getLv()
    local star = MapData:getMaxStar()
    if MapData.maxProgress == MapData.currProgress and cityData:getStar(1) > 0 and star >= openStar then
        if self.cloudBtns[cloudId] and self.cloudBtns[cloudId].btn then
            local nameTx = self.cloudBtns[cloudId].btn:getChildByTag(9999)
            if nameTx then
                nameTx:setString('')
            end
            self.cloudBtns[cloudId].btn:setVisible(true)
            self.cloudBtns[cloudId].btn:setTouchEnabled(true)
            ShaderMgr:restoreWidgetDefaultShader(self.cloudBtns[cloudId].btn)
        end
    else
        if self.cloudBtns[cloudId] and self.cloudBtns[cloudId].btn then
            local nameTx = self.cloudBtns[cloudId].btn:getChildByTag(9999)
            if not nameTx then
                local size = self.cloudBtns[cloudId].btn:getContentSize()
                nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
                nameTx:setColor(cc.c3b(255,0,0))
                nameTx:enableOutline(cc.c4b(0, 0, 0, 255), 2)
                nameTx:setPosition(size.width/2,size.height/2)
                nameTx:setAnchorPoint(cc.p(0.5,2.32))
                self.cloudBtns[cloudId].btn:addChild(nameTx,9999,9999)
            end
            if star < openStar then
                nameTx:setString(string.format(GlobalApi:getLocalStr('STR_STAR_LV'),openStar))
            else
                local keyArr = string.split(cityData:getName() , '.')
                nameTx:setString(string.format(GlobalApi:getLocalStr('STR_NEED_OCCUPIED'),keyArr[#keyArr]))
            end
            self.cloudBtns[cloudId].btn:setVisible(true)
        end
    end
end
--设置云是否可见
function MainSceneUI:updateCloudVisible()
    local cityData = MapData.data[MapData.maxProgress]
    local cloudId = cityData:getGroup() or 1
    for i,v in ipairs(self.cloudBtns) do
        if i < cloudId then
            v.pl:setVisible(false)
        else
            v.pl:setVisible(true)
            v.pl:setOpacity(1)
            v.pl:runAction(cc.Sequence:create(cc.FadeIn:create(0.4)))
        end
    end
end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑大地图云管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
function MainSceneUI:updateTributeBox()
    local fightedId = MapData:getFightedCityId()
    local index = 0
    local conf = GameData:getConfData('citytribute')
    for i=1,#conf do
        local cityData = MapData.data[conf[i].cityId]                
        local boxImg = self.panel2:getChildByName('tribute_box_img_'..i)
        if conf[i].cityId <= fightedId then
            index = index + 1
            if not boxImg then
                if not MapData.cityTribute[tostring(index)] then
                    local pos = cityData:getBtnPos()
                    boxImg = ccui.ImageView:create('uires/ui/common/box4.png')
                    boxImg:setName('tribute_box_img_'..i)
                    boxImg:setScale(0.8)
                    boxImg:setAnchorPoint(cc.p(0.5,0.2))
                    boxImg:setPosition(cc.p(pos.x,pos.y + 40))
                    self.panel2:addChild(boxImg,FightZOrder)
                    boxImg:setTouchEnabled(true)
                    boxImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                        cc.RotateBy:create(0.025, 15),
                        cc.RotateBy:create(0.025, -15),
                        cc.RotateBy:create(0.025, 0),
                        cc.RotateBy:create(0.025, -15),
                        cc.RotateBy:create(0.025, 15),
                        cc.DelayTime:create(1))))
                    boxImg:addTouchEventListener(function (sender, eventType)
                        if eventType == ccui.TouchEventType.began then
                            AudioMgr.PlayAudio(11)
                        elseif eventType == ccui.TouchEventType.ended then
                            MapMgr:showTributePanel()
                        end
                    end)
                end
            else
                if MapData.cityTribute[tostring(index)] then
                    boxImg:setVisible(false)
                else
                    boxImg:setVisible(true)
                end
            end
        end
    end
end

--更新最新龙蛋关卡图片
function MainSceneUI:updateDragonEggImg()
    if self.dragonEggImg then
        self.dragonEggImg:setVisible(false)
    end
    local fightedId = MapData:getFightedCityId()
    for i=MapData.currProgress,MapData.maxProgress do
        local cityData = MapData.data[i]                
        local type1 = cityData:getType()
        local type2 = cityData:getType1()
        if i > fightedId and type1 == 1 and type2 == 2 then
            if not self.dragonEggImg then
                self.dragonEggImg = ccui.ImageView:create('uires/ui/mainscene/light.png')
                local eggImg = ccui.ImageView:create('uires/ui/treasure/egg_'..(cityData:getDragon() - 1)..'.png')
                local size = self.dragonEggImg:getContentSize()
                eggImg:setScale(0.25)
                eggImg:setName('egg_img')
                eggImg:setPosition(cc.p(size.width/2,size.height/2))
                self.dragonEggImg:setName('dragon_egg_img')
                self.panel2:addChild(self.dragonEggImg,FightZOrder + 1)

                local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
                particle:setScale(0.5)
                particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                particle:setPosition(cc.p(size.width/2, size.height/2))
                self.dragonEggImg:addChild(particle)
                self.dragonEggImg:addChild(eggImg)
            end
            local pos = cityData:getBtnPos()
            self.dragonEggImg:setPosition(cc.p(pos.x,pos.y + 50))
            self.dragonEggImg:setVisible(true)
        end
    end
end
--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓剑动画管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--更新剑动画
function MainSceneUI:updateFightBtn()
    local cityId = 0
    local isVisible = false
    local level = UserData:getUserObj():getLv()
    if MapMgr.locatePage == 1 then
        local cityData = MapData.data[MapData.currProgress]
        local needLevel = cityData:getLevel()
        if cityData and cityData:getStar(1) <= 0 and level >= needLevel then
            cityId = MapData.currProgress
            isVisible = true
        end
    else
        local id = MapData:getFightedEliteCityId()
        if id < #MapData.data then
            cityId = id + 1
            isVisible = true
        end
    end
    if isVisible then
        self:createCityBtns(cityId)
        local btn = self.panel2:getChildByName('map_city_'..cityId)
        local size = btn:getContentSize()
        local sprite = self.panel2:getChildByTag(9987)
        if not sprite then
            sprite = GlobalApi:createSpineByName('map_fight', "spine/map_fight/map_fight", 1)
            sprite:setPosition(cc.p(btn:getPositionX(),btn:getPositionY()+size.height/2))
            sprite:setAnimation(0, 'animation', true)
            sprite:setName('fight_action')
            self.panel2:addChild(sprite,FightZOrder,9987)
        else
            sprite:setVisible(true)
            sprite:setPosition(btn:getPositionX(),btn:getPositionY()+size.height/2)
        end
        sprite:setScale(1/self.currScale)
        -- local openImg = self.panel2:getChildByName('open_img')
        -- local openImg1 = self.panel2:getChildByName('open_img1')
        -- if openImg then
        --     openImg:setVisible(false)
        -- end
        -- if openImg1 then
        --     openImg1:setVisible(false)
        -- end
    else
        local sprite = self.panel2:getChildByTag(9987)
        if sprite then
            sprite:setVisible(false)
        end  
    end
end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑剑动画管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓生物动画管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--环境生物移动
-- function MainSceneUI:monsterMove(biology,aniType)
--     local winSize = cc.Director:getInstance():getVisibleSize()
--     local l = self.limitLW - winSize.width
--     local r = self.limitRW
--     local u = self.limitUH
--     local d = self.limitDH - winSize.height
--     local posX = biology:getPositionX()
--     local posY = biology:getPositionY()
--     local cityId = math.random(1,#MapData.data)
--     local cityBtn = self.btns[cityId]
--     local posX1 = cityBtn:getPositionX() + math.random(-500,500)
--     local posY1 = cityBtn:getPositionY() + math.random(-500,500)
--     local dis =cc.pGetDistance(cc.p(posX1,posY1),cc.p(posX,posY))
--     local time = dis/10

--     local scale = 0
--     if posX < posX1 then
--         biology:setScaleX(-1)
--     else
--         biology:setScaleX(1)
--     end
--     biology:runAction(cc.Sequence:create(
--         cc.MoveTo:create(time,cc.p(posX1,posY1)),
--         cc.CallFunc:create(function()
--             if aniType ~= 2 then
--                 biology:setAnimation(0,'idle', true)
--             end
--         end),
--         cc.DelayTime:create(math.random(1,3)),
--         cc.CallFunc:create(function()
--             if aniType ~= 2 then
--                 biology:setAnimation(0,'walk', true)
--             end
--             self:monsterMove(biology,aniType)
--         end)
--     ))
-- end
--创建环境生物
-- function MainSceneUI:createEnvironmentMonster()
--     local conf = GameData:getConfData("biology")
--     self.biology = {}
--     for i,v in ipairs(conf) do
--         -- self['biology'..i] = 
--         local cityId = math.random(1,#MapData.data)
--         local cityData = self.btns[cityId]
--         biology:setPosition(cityData:getPosition())
--         self.biology[#self.biology + 1] = biology
--         self.panel2:addChild(biology,BiologyZOrder,10003 + i)

--         local ntype = v.ntype
--         if ntype == 2 then
--             biology:setAnimation(0,'fly', true)
--         else
--             biology:setAnimation(0,'walk', true)
--         end
--         self:monsterMove(biology,ntype)
--     end
-- end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑生物动画管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓生物动画管理↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--环境生物移动
function MainSceneUI:monsterMove(cityId,node,thief)
    -- thief:setAnimation(0,'run', true)
    thief:getAnimation():play('run', -1, 1)
    local allPos = MapData.data[cityId]:getThiefPos()
    local pos = MapData.data[tonumber(allPos[1])]:getBtnPos()
    -- print(allPos[1],allPos[2],allPos[3],allPos[4],allPos[5],pos.x,pos.y)
    local beginPosx = pos.x + allPos[2]
    local endxs = {beginPosx,beginPosx + allPos[4],beginPosx + allPos[5]}
    local posX = node:getPositionX()
    local posY = node:getPositionY()
    -- local posX1 = endxs[math.random(1,3)]
    local function getRandom()
        repeat
            local random =math.random(1,3)
            if random == self.random then
                self.random = random %3 + 1
                return
            else
                self.random = random
                return
            end
        until false
    end
    getRandom()
    local posX1 = endxs[self.random]
    -- print(self.random,posX1,pos.y,posX,posY)
    local dis =cc.pGetDistance(cc.p(posX1,pos.y),cc.p(posX,posY))
    local time = dis/10
    if posX < posX1 then
        thief:setScaleX(math.abs(thief:getScaleX()))
    else
        thief:setScaleX(-math.abs(thief:getScaleX()))
    end
    -- print(posX1,posY)
    local ac = {'idle','idle01'}
    node:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,cc.p(posX1,posY)),
        cc.CallFunc:create(function()
            -- thief:setAnimation(0,'idle', true)
            -- thief:setAnimation(0, actionName, true)
            thief:getAnimation():play(ac[math.random(1,2)], -1, -1)
        end),
        cc.DelayTime:create(math.random(3,5)),
        cc.CallFunc:create(function()
            self:monsterMove(cityId,node,thief)
        end)
    ))
end

function MainSceneUI:goldsFly(index)
    for i,v in ipairs(self.allGoldImgs[index]) do
        v:setTouchEnabled(false)
        v:stopAllActions()
    end
end

function MainSceneUI:goldFly(cityId,pl,node,thief,i,thiefConf)
    local award = DisplayData:getDisplayObj(thiefConf.award[1])
    local stype = award:getId()
    local function getResUrl()
        return 'uires/ui/res/'..stype..'.png'
    end
    local posX1,posY1 = node:getPositionX(),node:getPositionY()
    local posX2,posY2 = pl:getPositionX(),pl:getPositionY()
    local goldImg = ccui.ImageView:create()
    goldImg:loadTexture(getResUrl())

    local size = goldImg:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/thing_fall.plist")
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2,size.height*3/4))
    goldImg:addChild(particle)
    
    local size = pl:getContentSize()
    -- print(posX1,posX2,size.width/2,posX1 + posX2 + size.width/2)
    -- print(posY1,posY2,size.height/2,posY1 + posY2 + size.height/2)
    local posX,posY = posX1 + posX2,posY1 + posY2 + size.height/2
    -- goldImg:setScale(1)
    goldImg:setPosition(cc.p(posX,posY))
    goldImg:setScale(thiefConf.scale)
    goldImg:setTouchEnabled(true)
    self.allGoldImgs[i][#self.allGoldImgs[i] + 1] = goldImg
    self.panel2:addChild(goldImg,9999)
    local diffX = math.random(posX - 45,posX + 45)
    local diffY = math.random(posY + 25 + size.height/3,posY + 50 + size.height/3)
    local diffY1 = math.random(posY - 10 - size.height/2,posY + 2 - size.height/2)
    local diffX1
    if diffX > posX then
        diffX1 = math.random(diffX,posX + size.width)
    else
        diffX1 = math.random(posX - size.width,diffX)
    end
    -- print(posX,posY,diffX,diffY,diffX1,diffY1)
    local bezier = {
        cc.p(posX,posY),
        cc.p(diffX,diffY),
        cc.p(diffX1,diffY1)
    }
    local time = 0.4 + math.random(50,200)*0.001
    local bezierTo = cc.BezierTo:create(time, bezier)
    goldImg:setScale(thiefConf.scale/5*3)
    goldImg:setOpacity(0)
    self.actionNum = self.actionNum + 1
    goldImg:runAction(cc.FadeIn:create(0.2))
    goldImg:runAction(cc.Sequence:create(
        bezierTo,
        cc.CallFunc:create(function ()
            self.goldActionEnd = true
            self.actionNum = self.actionNum - 1
            -- goldImg:setVisible(false)
            -- goldImg:removeFromParent()
            if self.actionNum <= 0 and self.isDead[i] == false then
                self:monsterMove(cityId,node,thief)
            end
            goldImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                local winSize = cc.Director:getInstance():getVisibleSize()
                local tab = goldImg:convertToWorldSpace(cc.p(0,0))
                goldImg:removeFromParent()
                local img = ccui.ImageView:create()
                img:loadTexture(getResUrl())
                img:setPosition(cc.p(tab.x,tab.y))
                img:setScale(thiefConf.scale*0.7*3)
                img:setLocalZOrder(9999)
                self.panel1:addChild(img)
                local time = 0.01 * math.random(50,100)
                local pos = {
                    cash = cc.p(winSize.width - 640 ,winSize.height - 30),
                    xp = cc.p(80,winSize.height - 80),
                    food = cc.p(winSize.width - 200 ,winSize.height - 30)}
                local award = DisplayData:getDisplayObj(thiefConf.award[1])
                local id = award:getId()
                img:runAction(cc.Sequence:create(cc.MoveTo:create(time,pos[id]),cc.CallFunc:create(function()
                    img:removeFromParent()
                end)))
                img:runAction(cc.ScaleTo:create(time,0.1))
            end)))
        end))
    )
    goldImg:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.6,thiefConf.scale*0.7*3))
    )
end

--创建环境生物
function MainSceneUI:createThief(thiefData)
    local conf = GameData:getConfData("thief")
    self.thief = {}
    self.isDead = {}
    self.allGoldImgs = {}
    local nowId = MapData.currProgress - 1
    if nowId < 1 then
        return
    end
    local function createThief(name)
        local url = "animation_littlelossy/thief/" .. name
        return GlobalApi:createLittleLossyAniByName(name, url)
    end
    local hadCityIds = {}
    local ids = {}
    local thiefNum = 0
    for i=1,nowId do
        local allPos = MapData.data[i]:getThiefPos()
        if not hadCityIds[allPos[1]] then
            hadCityIds[allPos[1]] = 1
            local hadId = false
            for _,v in pairs(MapData.allThiefPos) do
                thiefNum = thiefNum + 1
                if v == i then
                    hadId = true
                end
            end
            if hadId == false then 
                ids[#ids+1] = i
            end
        end
    end
    for i,v in pairs(thiefData) do
        if #ids > 0 or thiefNum > 0 then
            self.isDead[i] = false
            local cityId = 0
            local thiefConf = conf[tonumber(v.id)]
            local node = cc.CSLoader:createNode("csb/thief.csb")
            node:setName('node_thief_'..i)
            local pl = node:getChildByName('pl')
            local thiefImg = pl:getChildByName('thief_img')
            thiefImg:setLocalZOrder(1)
            local textImg = pl:getChildByName('text_img')
            local textTx = textImg:getChildByName('text_tx')
            local thief = createThief(thiefConf.url)
            local size = pl:getContentSize()
            thief:setPosition(cc.p(size.width/2,0))
            thief:setScale(thiefConf.scale)
            local arr = string.split(thiefConf.url,'_')
            textImg:loadTexture('uires/ui/mainscene/'..arr[2]..'.png')
            textImg:setOpacity(0)
            textTx:setString('')
            textImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    -- textImg:setScale(1/self.currScale)
                    textTx:setString(GlobalApi:getLocalStr('THIEF_DESC_'..math.random(1,5)))
                end),
                cc.DelayTime:create(2),
                cc.FadeIn:create(2),
                cc.DelayTime:create(2),
                cc.FadeOut:create(2))))

            local function movementFun(armature, movementType, movementID)
                if movementType == 1 then
                    -- 动作完成
                    if movementID == "dead" then
                        thief:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1),cc.CallFunc:create(function()
                            node:removeFromParent()
                        end)))
                    elseif movementID == "hit" then
                    end
                end
            end
            thief:getAnimation():setMovementEventCallFunc(movementFun)
            local function timeOut(ntype)
                self.isDead[i] = true
                thief:stopAllActions()
                thief:getAnimation():play('dead', -1, -1)
                local args = {
                    id = i,
                    count = (MapData.thiefClick[i] or 1),
                    die = ntype
                }
                MapData.allThiefPos[i] = nil
                MapData.thiefClick[i] = nil
                MapMgr.thief[i] = nil
                MessageMgr:sendPost('get_thief_award','battle',json.encode(args),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local lastLv = UserData:getUserObj():getLv()

                        local awards = data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end

                        local nowLv = UserData:getUserObj():getLv()
                        GlobalApi:showKingLvUp(lastLv,nowLv)

                    elseif code == 101 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('THIEF_HAD_RAN'), COLOR_TYPE.RED)
                        thief:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1),cc.CallFunc:create(function()
                            node:removeFromParent()
                        end)))
                    end
                end)
            end
            pl:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local award = DisplayData:getDisplayObj(thiefConf['award'][1])
                    if award:getId() == 'food' then
                        local food = UserData:getUserObj():getFood()
                        local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                        if food >= maxFood then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                            return
                        end
                    end
                    MapData.thiefClick[i] = (MapData.thiefClick[i] or 0) + 1
                    -- MapData.thiefClick[i] = 1
                    if MapData.thiefClick[i] > tonumber(thiefConf.maxClickCount) then
                    elseif MapData.thiefClick[i] == tonumber(thiefConf.maxClickCount) then
                        node:stopAllActions()
                        pl:setTouchEnabled(false)
                        timeOut(1)
                    else
                        self.isDead[i] = false
                        if MapData.thiefClick[i] == 1 then
                            local args = {id = i}
                            MessageMgr:sendPost('click_thief','battle',json.encode(args),function (response)
                                
                                local code = response.code
                                local data = response.data
                                if code == 0 then
                                    local beginTime = tonumber(data.click)
                                    local diffTime = beginTime + tonumber(thiefConf.clickLiveTime) - GlobalData:getServerTime()
                                    local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
                                    local size = pl:getContentSize()
                                    label:setPosition(cc.p(size.width/2,size.height/2 - 40))
                                    label:setAnchorPoint(cc.p(0,0.5))
                                    pl:addChild(label)
                                    label:setVisible(false)
                                    Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,nil,nil,nil,25,function()
                                        timeOut(0)
                                    end)
                                elseif code == 101 then
                                    MapData.allThiefPos[i] = nil
                                    MapData.thiefClick[i] = 0
                                    MapMgr.thief[i] = nil
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr('THIEF_HAD_RAN'), COLOR_TYPE.RED)
                                    thief:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1),cc.CallFunc:create(function()
                                        node:removeFromParent()
                                    end)))
                                end
                            end)    
                        end
                        node:stopAllActions()
                        thief:getAnimation():play('hit', -1, -1)
                        for j=1,tonumber(thiefConf.num) do
                            self:goldFly(cityId,pl,node,thief,i,thiefConf,pl3,panel1)
                        end
                    end
                end
            end)

            local beginTime = tonumber(v.time)
            local diffTime = beginTime + tonumber(thiefConf.liveTime)*60 - GlobalData:getServerTime()
            local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
            local size = pl:getContentSize()
            label:setPosition(cc.p(size.width/2,size.height/2))
            label:setAnchorPoint(cc.p(0,0.5))
            label:setVisible(false)
            Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,nil,nil,nil,25,function()
                timeOut(0)
            end)

            local beginTime1 = tonumber(v.click)
            if beginTime1 and beginTime1 > 0 then
                MapData.thiefClick[i] = MapData.thiefClick[i] or 1
                local diffTime1 = beginTime1 + tonumber(thiefConf.clickLiveTime) - GlobalData:getServerTime()
                local label1 = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
                label1:setPosition(cc.p(size.width/2,size.height/2 - 40))
                label1:setAnchorPoint(cc.p(0,0.5))
                label1:setVisible(false)
                Utils:createCDLabel(label1,diffTime1,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,nil,nil,nil,25,function()
                    timeOut(0)
                end)
                pl:addChild(label1)
            end

            pl:addChild(label)
            pl:addChild(thief)
            self.panel2:addChild(node,BiologyZOrder)
            self.thief[i] = {pl = pl}
            local thiefId
            if not MapData.allThiefPos[i] then
                local index = math.random(1,#ids)
                thiefId = ids[index]
                table.remove(ids,index)
            else
                thiefId = MapData.allThiefPos[i]
            end
            if thiefId then
                self.allGoldImgs[i] = {}
                local allPos = MapData.data[thiefId]:getThiefPos()
                cityId = thiefId
                MapData.allThiefPos[i] = cityId
                local pos = MapData.data[tonumber(allPos[1])]:getBtnPos()
                node:setPosition(cc.p(pos.x+allPos[2],pos.y+allPos[3]))
                self:monsterMove(thiefId,node,thief)
            end
        end
    end
end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑生物动画管理↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

function MainSceneUI:updateOpen()
    local isFirst = true
    local isFirst1 = true
    local level = UserData:getUserObj():getLv()
    local openImg1 = self.panel2:getChildByName('open_img1')
    if openImg1 then
        openImg1:setVisible(false)
    end
    local lvCityId = 0
    local openCityId = 0
    for i = MapData.currProgress,MapData.maxProgress do
        local cityData = MapData.data[i]
        local star = cityData:getStar(1)
        local funcOpen = cityData:getFuncOpen()
        local needLevel = cityData:getLevel()
        if star <= 0 then
            if level < needLevel and isFirst then
                if not openImg1 then
                    openImg1 = ccui.ImageView:create('uires/ui/mainscene/open_img_3.png')
                    openImg1:setName('open_img1')
                    local descTx = cc.Label:createWithTTF("", "font/gamefont1.TTF", 19)
                    descTx:setColor(COLOR_TYPE.RED)
                    descTx:enableOutline(COLOR_TYPE.BLACK, 1)
                    descTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    descTx:setAnchorPoint(cc.p(0,0.5))
                    descTx:setName('desc_tx')
                    descTx:setPosition(cc.p(38,38))
                    openImg1:addChild(descTx)
                    openImg1:setCascadeOpacityEnabled(true)
                    self.panel2:addChild(openImg1,FightZOrder)
                end
                local descTx1 = openImg1:getChildByName('desc_tx')
                descTx1:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES1'),needLevel))
                local pos = cityData:getBtnPos()
                local btn = self.panel2:getChildByName('map_city_'..i)
                local size = btn:getContentSize()
                openImg1:setPosition(cc.p(pos.x,pos.y + size.height/2))
                isFirst = false
                lvCityId = i
            end
            if funcOpen and funcOpen ~= '' and isFirst1 then
                local openImg = self.panel2:getChildByName('open_img')
                if not openImg then
                    openImg = ccui.ImageView:create()
                    openImg:setName('open_img')
                    local descTx = cc.Label:createWithTTF("", "font/gamefont1.TTF", 19)
                    descTx:setColor(COLOR_TYPE.BLUE)
                    descTx:enableOutline(COLOR_TYPE.BLACK, 1)
                    descTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    descTx:setAnchorPoint(cc.p(0,0.5))
                    descTx:setName('desc_tx')
                    openImg:addChild(descTx)
                    openImg:setCascadeOpacityEnabled(true)
                    self.panel2:addChild(openImg,FightZOrder)
                end
                local descTx = openImg:getChildByName('desc_tx')
                descTx:setString(funcOpen)
                if i == MapData.currProgress then
                    local sprite = self.panel2:getChildByName('fight_action')
                    if sprite and self.locatePage == 1 then
                        sprite:setVisible(false)
                    end
                    descTx:setPosition(cc.p(56,30))
                    openImg:loadTexture('uires/ui/mainscene/open_img_2.png')
                else
                    descTx:setPosition(cc.p(38,30))
                    openImg:loadTexture('uires/ui/mainscene/open_img_1.png')
                end

                openImg:ignoreContentAdaptWithSize(true)
                local pos = cityData:getBtnPos()
                local btn = self.panel2:getChildByName('map_city_'..i)
                local size = btn:getContentSize()
                openImg:setPosition(cc.p(pos.x,pos.y + size.height/2))
                openCityId = i
                isFirst1 = false
            end
        end
    end
    local openImg = self.panel2:getChildByName('open_img')
    local openImg1 = self.panel2:getChildByName('open_img1')
    if not isFirst and not isFirst1 and lvCityId == openCityId then
        openImg1:setVisible(true)
        openImg1:stopAllActions()
        openImg1:setOpacity(0)
        openImg1:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeIn:create(1),
            cc.DelayTime:create(0.5),
            cc.FadeOut:create(0.5),
            cc.DelayTime:create(1.5))))
        openImg:setVisible(true)
        openImg:stopAllActions()
        openImg:setOpacity(255)
        openImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.FadeOut:create(0.5),
            cc.DelayTime:create(2),
            cc.FadeIn:create(1),
            cc.DelayTime:create(0.5))))
    elseif not isFirst then
        openImg1:setVisible(true)
        openImg1:stopAllActions()
        openImg1:setOpacity(255)
    elseif not isFirst1 then
        openImg:setVisible(true)
        openImg:stopAllActions()
        openImg:setOpacity(255)
    else
        if openImg1 then
            openImg1:setVisible(false)
        end
        if openImg then
            openImg:setVisible(false)
        end
    end
end

function MainSceneUI:updateFinger()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local isFirst = MapData.data[5]:getBfirst()
    local isFirst1 = MapData.data[4]:getBfirst()
    local guideFinger = self.panel2:getChildByName('guide_finger')
    if MapData.currProgress == 5 and isFirst and not isFirst1 then
        if not guideFinger then
            guideFinger = GlobalApi:createLittleLossyAniByName("guide_finger")
            guideFinger:getAnimation():playWithIndex(0, -1, 1)
            guideFinger:setName('guide_finger')
            guideFinger:setPosition(MapData.data[5]:getBtnPos())
            self.panel2:addChild(guideFinger,FightZOrder)
        end
        guideFinger:setVisible(true)
    else
        if guideFinger then
            guideFinger:setVisible(false)
        end
    end

    local isFirst = MapData.data[9]:getBfirst()
    local isFirst1 = MapData.data[8]:getBfirst()
    local locateBtn = self.root:getChildByName('locate_btn')
    local guideFinger = locateBtn:getChildByName("guide_finger")
    if MapData.currProgress == 9 and isFirst and not isFirst1 and self.currScale == MIN_SCALE then
        if not guideFinger then
            guideFinger = GlobalApi:createLittleLossyAniByName("guide_finger")
            guideFinger:getAnimation():playWithIndex(0, -1, 1)
            guideFinger:setName('guide_finger')
            guideFinger:setPosition(cc.p(185,25))
            locateBtn:addChild(guideFinger,FightZOrder)
        end
        guideFinger:setVisible(true)
    else
        if guideFinger then
            guideFinger:setVisible(false)
        end
    end
end

return MainSceneUI