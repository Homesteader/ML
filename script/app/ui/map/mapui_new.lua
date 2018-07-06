local LevelMapUI = class("LevelMapUI", BaseUI)

local mapblockLen = 6
local mapWidth = 5879
local mapHeight = 768
local MIN_SCALE = 0.85
local MAX_SCALE = 2
local speed = 60

local CityZOrder = 10003
local ModuleZOrder = 10005 -- 9986
local FightZOrder = 10006 -- 9987
local PlayerZOrder = 10009 -- 9990

local MAX_HEIGHT = 10000
local function getDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
end

function LevelMapUI:ctor(mapType,customsId,moveCustomsId,isCity)
	self.uiIndex = GAME_UI.UI_MAINSCENE
	self.currScale = scale or 1.0
	self.allBgId = {}
	self.curMap = mapType
	self.mainRoleAni = nil
	self.customsId = customsId
    self.moveCustomsId = moveCustomsId
    self.isCity = isCity
    MapMgr.maptype = mapType
end

function LevelMapUI:setMapBtn()

    local function callback()
        MapMgr:hideMainScene()
        MainSceneMgr:showMainCity()
    end
    UIManager.sidebar:setMapBtnCallback(GlobalApi:getLocalStr_new("MAINSCENE_BTN_STE2"),callback)
end

function LevelMapUI:init()

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
        end
    end)

	self.panel1 = self.root:getChildByName("Panel_1")
    self.panel3 = self.panel1:getChildByName("Panel_3")
    self.panel2 = self.panel3:getChildByName("Panel_2")
    self.hideImg = self.panel1:getChildByName('hide_img')
    self.ui_pannel = self.panel1:getChildByName("ui_root")

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.panel1:setContentSize(cc.size(winSize.width,winSize.height))
    self.panel1:setSwallowTouches(false)
    self.ui_pannel:setContentSize(cc.size(winSize.width,winSize.height))

    self:initLoading()
    self:setMapBtn()
end


function LevelMapUI:onShow()
    UIManager:showSidebar({1,2,4,5,6,14,16},{1,2,3},true)
    self:setMapBtn()
end

function LevelMapUI:initLoading()

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
    local loadedImgMaxCount = 0

    local customs = {"customs_0.png","customs_1_1.png","customs_1_2.png","customs_1_3.png",
                     "customs_0_dis.png","customs_1_1_dis.png","customs_1_2_dis.png","customs_1_3_dis.png",
                     "map_bg.png","customs_bg.png","open_bg.png"}

    loadedImgMaxCount = loadedImgMaxCount + #customs
    local function imageLoaded(texture)
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        if not self.isCity then
            self.loadingUI:setPercent(loadingPercent)
        end
        if loadedImgCount >= loadedImgMaxCount then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                local function callback()
                    self:enterWithOutAction()
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

    for i=1,#customs do
         cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/mainscene/'..customs[i],imageLoaded)
    end
end

function LevelMapUI:enterWithOutAction()

    local mapBgImg = self.panel2:getChildByName("map_bg_img")
    mapBgImg:setVisible(true)
    self:createBtns()

    UIManager:showSidebar({1,2,4,5,6,14,16},{1,2,3})

    self:updateCustoms()
    self:updateMapHandler()
end

function LevelMapUI:createBtns()

    local size = self.ui_pannel:getContentSize()

    local btnStr = {"CUSTOMS_MAP_BTNTX1","CUSTOMS_MAP_BTNTX2","CUSTOMS_MAP_BTNTX3"}
    local openStr = {"","elite","hard"}
    for i=1,3 do
    	local chooseBtn = self.ui_pannel:getChildByName("choose_btn"..i)
    	local text = chooseBtn:getChildByName("text")
    	text:setString(GlobalApi:getLocalStr_new(btnStr[i]))
    	if i > 1 then
    		local isOpen = GlobalApi:getOpenInfo_new(openStr[i])
    		chooseBtn:setVisible(isOpen)
        else
           chooseBtn:setVisible(true) 
    	end
    	chooseBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	self.curMap = i
	            self:updateMap()
	        end
	    end)
	    chooseBtn:setPositionX(size.width-20)
    end
end

--重置边界值
function LevelMapUI:setLimit(scale1)

	local winSize = cc.Director:getInstance():getVisibleSize()
    local point = self.panel3:getAnchorPoint()
    local scale = scale1
    if not scale then
        scale = self.currScale
    end
    self.limitLW = winSize.width - mapWidth*scale*(1 - point.x)
    self.limitRW = mapWidth*scale*point.x
    self.limitUH = 768*scale*point.y
    self.limitDH = winSize.height - 768*scale*(1 - point.y)

end

--定位
function LevelMapUI:setWinPosition(cityId,stype,ntype,callback,scale)
    self.panel3:stopAllActions()
    self.currScale = self.panel3:getScale()
    self:setLimit()
    if scale then
        self.panel3:runAction(cc.ScaleTo:create(0.5,scale))
        self.currScale = scale
        self:setLimit()
    else
        if self.currScale ~= 1 and not ntype then
            self.panel3:runAction(cc.ScaleTo:create(0.5,1))
            self.currScale = 1
            self:setLimit()
            self:updateFightBtn()
            self:updateModuleOpenTip()
            local bgImg = self.panel1:getChildByName('bg_img')
            if bgImg then
                bgImg:removeFromParent()
            end
        end
    end
    local winSize = cc.Director:getInstance():getVisibleSize()
    local anchor = self.panel3:getAnchorPoint()
    local cityData = MapData.data[cityId]
    
    local pos = cityData:getBtnPos()
    local point = cc.p(
        mapWidth*self.currScale*anchor.x - pos.x*self.currScale + winSize.width/2,
        mapHeight*self.currScale*anchor.y - pos.y*self.currScale + winSize.height/2)
    
    self:detectEdges(point)
    if ntype then
        local pos = cityData:getBtnPos()
        return cc.p(pos.x/mapWidth,pos.y/mapHeight),point
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

--边界检测
function LevelMapUI:detectEdges( point )
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

function LevelMapUI:updateMapHandler()
	local winSize = cc.Director:getInstance():getVisibleSize()
    local startDistance = 0
    local touchArr = {}
    local currLocationArr = {}
    local moveFlag = true
    local isDraging = false
    local midpointNormalize =cc.p(0,0)
    local lastTouche1 = cc.p(0,0)
    local function getWorldAnchorPoint(point)
        return cc.p(point.x/mapWidth/self.currScale,point.y/mapHeight/self.currScale)
    end
    local function getWorldPosition(point)
        return cc.p(mapWidth*self.currScale*self.panel3:getAnchorPoint().x + point.x - self.panel3:getPositionX(),mapHeight*self.currScale*self.panel3:getAnchorPoint().y + point.y - self.panel3:getPositionY())
    end
    local function onTouchesMoved(touches, event )
        if touchArr[0] and touchArr[1] then
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

                local x = mapWidth*newscale*wAnchor.x
                local y = mapHeight*newscale*wAnchor.y
                local x1 = mapWidth*newscale*(1-wAnchor.x)
                local y1 = mapHeight*newscale*(1-wAnchor.y)
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
        --self:updateCloudMove()
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

        local x = mapWidth*newscale*wAnchor.x
        local y = mapHeight*newscale*wAnchor.y
        local x1 = mapWidth*newscale*(1-wAnchor.x)
        local y1 = mapHeight*newscale*(1-wAnchor.y)
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
            isHideBtn = true
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
                bgPanelDiffPos = cc.p(bgPanelPos.x - bgPanelPrePos.x, bgPanelPos.y - bgPanelPrePos.y)
                local targetPos = cc.pAdd(cc.p(self.panel3:getPositionX(),self.panel3:getPositionY()),bgPanelDiffPos)
                self:detectEdges(targetPos)
                self.panel3:setPosition(targetPos)
            end
        else
            if eventType == ccui.TouchEventType.canceled then
                if isHideBtn == true then
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
                    --self:hideBtns(2)
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

function LevelMapUI:createBgByPos(pos)
	
	local index = 0
    for i=1,mapblockLen do
        if self.allBgId[i] then
            index = index + 1
        end
    end
    if index >= mapblockLen then
        return
    end
    local posX,posY
    if pos then
        posX,posY = pos.x,pos.y
    else
        posX,posY = self.panel3:getPosition()
    end
    local anchor = self.panel3:getAnchorPoint()
    local leftBottomPosX,leftBottomPosY = math.abs(posX - mapWidth*self.currScale*anchor.x),math.abs(posY - mapHeight*self.currScale*anchor.y)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local points = {
        cc.p(leftBottomPosX/self.currScale,leftBottomPosY/self.currScale + winSize.height/self.currScale), -- 左上
        cc.p((leftBottomPosX + winSize.width)/self.currScale,leftBottomPosY/self.currScale + winSize.height/self.currScale), --右上
        cc.p(leftBottomPosX/self.currScale,leftBottomPosY/self.currScale),	--左下
        cc.p(leftBottomPosX/self.currScale + winSize.width/self.currScale,leftBottomPosY/self.currScale), -- 右下
    }
    local function getBg(point)
        local x = (point.x - point.x%1024)/1024 + 1
        local y = (point.y - point.y%768)/768 + 1
        return (1 - y)*6 + x
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

            if j >= 1 and j <= mapblockLen then
                local bgImg = self.panel2:getChildByTag(j + 1000)
                if not bgImg then
                    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/mainscene/map_'..j..'.png',function(texture)

                        local function getBgPos(i)
                            local index = (1 - math.floor((i - 1)/6 + 1))*6+(i - 1)%6 + 1
                            local posX = (math.floor((index - 1)%6 + 1) - 1)*1024 + 512
                            local posY = (math.ceil(index/6) - 1)*768 + 384
                            return cc.p(posX,posY)
                        end
                        local img = ccui.ImageView:create('uires/ui_new/mainscene/map_'..j..'.png')
                        img:setPosition(getBgPos(j))
                        self.panel2:addChild(img,1,j+1000)
                        self.allBgId[j] = 1
                    end)
                end
            end
        end
    end
end

--根据地图块创建关卡
function LevelMapUI:createCustomByMapId(mapId)

	local minPosX = (math.floor((mapId - 1)%6 + 1) - 1)*1024
	local minPosY = (math.ceil(mapId/6) - 1)*768
	local maxPosX = minPosX + 1024
	local maxPosY = minPosY + 768

	local customCfg = GameData:getConfData("custom")
	for i=1,#customCfg do
		local posX,posY = customCfg[i].posX,customCfg[i].posY
		if posX >= minPosX and posX <= maxPosX and posY >= minPosY and posY <= maxPosY then
			self:createCustom(customCfg[i].id)
		end
	end
end

function LevelMapUI:updateCustoms()

    local customCfg = GameData:getConfData("custom")
    for i=1,#customCfg do
        self:createCustom(customCfg[i].id)
    end

    --设置地图缩放
    self.panel3:setScale(self.currScale)
    self:setLimit()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local anchor,point = self:setWinPosition(self.customsId,1,1)
    self:createBgByPos(point)
    self.panel3:setAnchorPoint(anchor)
    local point1 = cc.p(winSize.width/2,winSize.height/2)
    self:setLimit()
    self:detectEdges(point1)
    self.panel3:setPosition(point1)

    self:createPlayer()
    self:updateFightBtn()
    self:updateModuleOpenTip()
end

--创建关卡点
function LevelMapUI:createCustom(customsId)

	local custiomsObj = MapData.data[customsId]
    local btnRes = custiomsObj:getBtnResource()
	local btn = self.panel2:getChildByName('map_city_'..customsId)
	if not btn then
		
		btn = ccui.Button:create()
        btn:setName("map_city_" .. customsId)
        local size = btn:getContentSize()
        btn:setSwallowTouches(false)
        btn:setPosition(custiomsObj:getBtnPos())
        local zOder = MAX_HEIGHT - custiomsObj:getBtnPos().y - 1
        btn:setLocalZOrder(zOder)
        self.panel2:addChild(btn)
    else
    	local customsType = custiomsObj:getCustomsType()
    	if customsType ~= self.curMap then
    		custiomsObj:setCustomsType(self.curMap)
    	end
	end

    local level = UserData:getUserObj():getLv()
    local needLevel = custiomsObj:getLevel()
    local isMain = custiomsObj:isMainCustoms()
    local fightMax = MapData:getFightedCustomsByType(MapMgr.maptype)
    local shouldAttck = MapData:getCurProgress(MapMgr.maptype)
    if customsId <= fightMax then
       btn:loadTextureNormal(btnRes..".png") 
       btn:setTouchEnabled(isMain)
    else
        btn:loadTextureNormal(btnRes.."_dis.png")
        if customsId == shouldAttck then
            btn:setTouchEnabled(needLevel<=level)
        else
            btn:setTouchEnabled(false)
        end
    end

    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if needLevel > level then
                promptmgr:showSystenHint(GlobalApi:getLocalStr_new('LV_NOT_ENOUCH'),COLOR_TYPE.RED)
                return
            else
                self:fightCallback(customsId)
            end
        end
    end) 

    if isMain then
        local btnSize = btn:getContentSize()
        local customsbg = btn:getChildByName("customs_bg")
        if not customsbg then
            customsbg = ccui.ImageView:create("uires/ui_new/mainscene/customs_bg.png")
            customsbg:setName("customs_bg")
            customsbg:setPosition(cc.p(btnSize.width/2,5))
            local text = ccui.Text:create()
            text:setFontName("font/gamefont.ttf")
            text:setFontSize(18)
            text:setColor(cc.c4b(252, 248, 178, 255))
            text:setString(customsId)
            text:setName("text")
            local customsbgSize = customsbg:getContentSize() 
            text:setPosition(cc.p(customsbgSize.width/2,customsbgSize.height/2))
            customsbg:addChild(text)
            btn:addChild(customsbg)
        else
            customsbg:setPosition(cc.p(btnSize.width/2,5))
            local text = customsbg:getChildByName("text")
            if text then
                text:setString(customsId)
            end
        end

    end
end

--更新地图
function LevelMapUI:updateMap()

	MapMgr.maptype = self.curMap
    local fightedMaxId = MapData:getFightedCustomsByType(MapMgr.maptype)
    self.customsId = fightedMaxId or self.customsId

	self:updateCustoms()
end

function LevelMapUI:fightCallback(customsId)
     MapMgr:showExpeditionPanel(customsId)
end

--创建功能开启图标
function LevelMapUI:updateModuleOpenTip()
     
    local customsId = MapData:getCurProgress(MapMgr.maptype)
    local fightMax = MapData:getFightedCustomsByType(MapMgr.maptype)
    local custiomsObj = MapData.data[customsId]
    local moduleOpenId = custiomsObj:getOpenModuleId()

    local isVisible = fightMax < customsId and moduleOpenId ~= '0'
    if isVisible then
        local conf = GameData:getConfData('moduleopen_new')[moduleOpenId] 
        local btn = self.panel2:getChildByName('map_city_'..customsId)
        local zOrder = MAX_HEIGHT - btn:getPositionY()
        local size = btn:getContentSize()
        local sprite = self.panel2:getChildByTag(9986)
        if not sprite then
            sprite = ccui.ImageView:create("uires/ui_new/mainscene/open_bg.png")
            sprite:setPosition(cc.p(btn:getPositionX()-15,btn:getPositionY()+size.height+20))
            local spriteSize = sprite:getContentSize()
            local openTx = ccui.Text:create()
            openTx:setFontName("font/gamefont.ttf")
            openTx:setFontSize(16)
            openTx:setColor(cc.c4b(127, 58, 0, 255))
            openTx:setString(GlobalApi:getLocalStr_new("CUSTOMS_MAP_INFOTX11"))
            openTx:setName("open_tx")
            openTx:setAnchorPoint(cc.p(0,0.5))
            openTx:setPosition(cc.p(5,47))
            sprite:addChild(openTx)

            local moduleNameTx = ccui.Text:create()
            moduleNameTx:setFontName("font/gamefont1.ttf")
            moduleNameTx:setFontSize(18)
            moduleNameTx:setColor(cc.c4b(253, 232, 43, 255))
            moduleNameTx:enableOutline(cc.c4b(94, 46, 16, 255), 2)
            moduleNameTx:setString(conf.name)
            moduleNameTx:setName("modulename_tx")
            moduleNameTx:setPosition(cc.p(spriteSize.width/2,spriteSize.height/2))
            sprite:addChild(moduleNameTx)
            sprite:setTag(9986)
            sprite:setLocalZOrder(zOrder)
            self.panel2:addChild(sprite)
            
        else
            local moduleNameTx = sprite:getChildByName("modulename_tx")
            if moduleNameTx then
                moduleNameTx:setString(conf.name)
            end
            
            sprite:setLocalZOrder(zOrder)
            sprite:setVisible(true)
            sprite:setPosition(btn:getPositionX(),btn:getPositionY()+size.height/2+20)
        end
    else
        local sprite = self.panel2:getChildByTag(9986)
        if sprite then
            sprite:setVisible(false)
        end  
    end
end

--剑动画
function LevelMapUI:updateFightBtn()
    
    local customsId = MapData:getCurProgress(MapMgr.maptype)
    local fightMax = MapData:getFightedCustomsByType(MapMgr.maptype)
    local custiomsObj = MapData.data[customsId]
    local moduleOpenId = custiomsObj:getOpenModuleId()

    local isVisible = fightMax < customsId
    if isVisible then
        local btn = self.panel2:getChildByName('map_city_'..customsId)
        local size = btn:getContentSize()
        local sprite = self.panel2:getChildByTag(9987)
        local zOrder = MAX_HEIGHT - btn:getPositionY()
        if not sprite then
            sprite = GlobalApi:createSpineByName('map_fight', "spine/map_fight/map_fight", 1)
            if moduleOpenId ~= '0' then
                 sprite:setPosition(cc.p(btn:getPositionX()+20,btn:getPositionY()+size.height+25))
            else
                 sprite:setPosition(cc.p(btn:getPositionX(),btn:getPositionY()+size.height))
            end
            sprite:setAnimation(0, 'animation', true)
            sprite:setName('fight_action')
            sprite:setScale(0.6)
            sprite:setTag(9987)
            sprite:setLocalZOrder(zOrder+1)
            self.panel2:addChild(sprite)
        else
            sprite:setVisible(true)
            if moduleOpenId ~= '0' then
                sprite:setPosition(cc.p(btn:getPositionX()+20,btn:getPositionY()+size.height+25))
            else
                sprite:setPosition(btn:getPositionX(),btn:getPositionY()+size.height/2)
            end
            sprite:setLocalZOrder(zOrder+1)
        end
    else
        local sprite = self.panel2:getChildByTag(9987)
        if sprite then
            sprite:setVisible(false)
        end  
    end
end

--创建人物模型
function LevelMapUI:createPlayer()

	local roleObj = RoleData:getMainRole()
	if roleObj then
		local url = roleObj:getUrl()
		local change = roleObj:getChangeEquipState()
		local mainRoleAni = self.panel2:getChildByTag(9990)
		if not mainRoleAni then
	    	mainRoleAni = GlobalApi:createLittleLossyAniByName(url.."_display", nil,change)
	    	mainRoleAni:getAnimation():play("idle", -1, 1)
	    	mainRoleAni:setScale(0.3)
	    	self.panel2:addChild(mainRoleAni,PlayerZOrder,9990)
	    	self.mainRoleAni = mainRoleAni
	    end
	end

    self:setRolePosition()
    
end

--设置角色的初始位置
function LevelMapUI:setRolePosition()

    local pos,targetPos
    local fightedMaxCustoms = MapData:getFightedCustomsByType(MapMgr.maptype)
    local customsId = fightedMaxCustoms
    if self.moveCustomsId then
        customsId = self.moveCustomsId - 1
        local tagetbtn = self.panel2:getChildByName('map_city_'..self.moveCustomsId)
        if tagetbtn then
            local posX,posY = tagetbtn:getPosition()
            targetPos = cc.p(posX,posY)
        end
    else
        local tagetbtn = self.panel2:getChildByName('map_city_'..(customsId+1))
        if tagetbtn then
            local posX,posY = tagetbtn:getPosition()
            targetPos = cc.p(posX,posY)
        end
    end

    local btn = self.panel2:getChildByName('map_city_'..customsId)
    if btn then
        local posX,posY = btn:getPosition()
        pos = cc.p(posX,posY)
    else
        --只可能一关都没打的情况出现
        pos = cc.p(532.5,250.5)
    end

    if pos then
        local zOrder = MAX_HEIGHT - pos.y
        self.mainRoleAni:setPosition(pos)
        self.mainRoleAni:setLocalZOrder(zOrder)
        if targetPos then
            local dir = pos.x > targetPos.x and -1 or 1
            self.mainRoleAni:setScaleX(0.3*dir)
        end
    else
        self.mainRoleAni:setOpacity(0) 
        self.mainRoleAni:setScaleX(-0.3)
    end

    self:moveToCustomsId()
end

--移动关卡点
function LevelMapUI:moveToCustomsId()

    if not self.moveCustomsId then
        return
    end

	local btn = self.panel2:getChildByName('map_city_'..self.moveCustomsId)
	if btn and self.mainRoleAni then
		local posX,posY = btn:getPosition()
        if self.moveCustomsId ~= 1 then
    		local curPosX,curPosY = self.mainRoleAni:getPosition()
    		local dis = getDistance(curPosX,curPosY,posX,posY)
    		self.mainRoleAni:getAnimation():play("run", -1, 1)
    		local seqact = cc.Sequence:create(cc.MoveTo:create(dis/speed,cc.p(posX,posY)),cc.CallFunc:create(function ()
    			self.mainRoleAni:getAnimation():play("idle", -1, 1)
    		end))
    		self.mainRoleAni:runAction(seqact)
        else
            self.mainRoleAni:setPosition(cc.p(posX,posY))
            self.mainRoleAni:runAction(cc.FadeIn:create(1))
        end
	end
end

return LevelMapUI