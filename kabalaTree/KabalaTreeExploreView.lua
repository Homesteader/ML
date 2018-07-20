local KabalaTreeExploreView = class("KabalaTreeExploreView", BaseLayer)
local KabalaTreeNpc = import(".KabalaTreeNpc")
local KabalaTreeGridMap = import(".KabalaTreeGridMap")
local KabalaAStarPath = import(".KabalaAStarPath")
local KabalaTreeItem = import(".KabalaTreeItem")

function KabalaTreeExploreView:ctor(mapId)
	self.super.ctor(self)

	self:initData(mapId)
	self:init("lua.uiconfig.kabalaTree.kabalaTreeExploreView")
end

function KabalaTreeExploreView:initData(mapId)
	
    self.mapId = mapId
    self.minTouchMoveDis = 50                   --用于判断地图是否是拖动
    self.playerModeScale = 1
    self.playerPos = ccp(9,9)
    self.mapScale = 0.5

    self.mapContainerPrePos = nil
    self.mapContainerPos = nil
    self.mapContainerDiffPos = nil
    self.mapTouchBeginPos = nil
    self.index =  0
    self.KabalaTreeGridMap = KabalaTreeGridMap.new()
    self.KabalaAStarPath = KabalaAStarPath.new()
    self.KabalaTreeItem = KabalaTreeItem.new()

end


function KabalaTreeExploreView:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui
	self:showTopBar()

    --设置标题
    self.TextArea_title = TFDirector:getChildByPath(self.topLayer, 'TextArea_title')
    self.TextArea_title:setText("点击了ID："..self.mapId)

	self.Panel_root = TFDirector:getChildByPath(ui, "Panel_root")
    self.Panel_prefab = TFDirector:getChildByPath(ui,"Panel_prefab")
    self.Panel_treeExploreMap = TFDirector:getChildByPath(self.Panel_root, 'Panel_treeExploreMap')

    --ship
    self.Panel_player = TFDirector:getChildByPath(self.Panel_prefab, 'Panel_player'):clone()
    self.Image_random = TFDirector:getChildByPath(self.Panel_prefab, 'Image_random')

    --UI
    self.Panel_UI = TFDirector:getChildByPath(self.Panel_root, 'Panel_UI')
    self.Button_maphelp = TFDirector:getChildByPath(self.Panel_UI, 'Button_maphelp')
    self.Button_maphelp = TFDirector:getChildByPath(self.Panel_UI, 'Button_maphelp')
    self.Button_itembag = TFDirector:getChildByPath(self.Panel_UI, 'Button_itembag')
    self.Button_statelist = TFDirector:getChildByPath(self.Panel_UI, 'Button_statelist')
    self.Image_task_bg = TFDirector:getChildByPath(self.Panel_UI, 'Image_task_bg')
    self.taskLabel = {}
    for i=1,2 do
        self.taskLabel[i] = TFDirector:getChildByPath(self.Image_task_bg, 'Label_task_'..i)
    end

    --team
    self.Image_team_bg = TFDirector:getChildByPath(self.Panel_UI, 'Image_team_bg')
    self.teamInfo = {}
    for i=1,3 do
       local teamImage =  TFDirector:getChildByPath(self.Image_team_bg, 'Image_team'..i)
       local memberflag = TFDirector:getChildByPath(teamImage, 'Image_member_flag')
       local Image_team_head = TFDirector:getChildByPath(teamImage, 'Image_team_head')
       local Label_state_tx = TFDirector:getChildByPath(teamImage, 'Label_state_tx')
       local effectBar = TFDirector:getChildByPath(teamImage, 'LoadingBar_bar')
       local Image_add = TFDirector:getChildByPath(teamImage, 'Image_add')
       local Image_teambar_bg = TFDirector:getChildByPath(teamImage, 'Image_teambar_bg')
       self.teamInfo[i] = {teamImage = teamImage,memberflag = memberflag,headImg = Image_team_head,stateTx = Label_state_tx,
                           effectbar = effectBar,Image_add = Image_add,barbg = Image_teambar_bg}
    end

    --radar
    self.Image_radar = TFDirector:getChildByPath(self.Panel_UI, 'Image_radar')
    self.radarCircle = TFDirector:getChildByPath(self.Panel_prefab, 'Image_radar_circle')
    self.radarCircle:setScale(0)
    self.radarFlash = TFDirector:getChildByPath(self.Image_radar, 'Image_radar_flash')
    self.radarDot = {}
    for i=1,10 do
        self.radarDot[i] = TFDirector:getChildByPath(self.Image_radar, 'Image_radar_dot'..i)
    end
    
    self.timer = 0
    self._scheduleId   = TFDirector:addTimer(10, -1, nil, handler(self.onCountDownPer, self))

    self:generateTiledMap()
    self:createNpc()
    self:locationPlayer()
    self:initMapItem()

    self:uiLogic()
end

function KabalaTreeExploreView:generateTiledMap()
 
    self.tileMap = self.KabalaTreeGridMap:generateMap(self.mapId,self.playerPos,self.mapScale)
    if self.tileMap then
        self.tileMap:setName("map")
        self.Panel_root:addChild(self.tileMap)
    end
end

--初始地图道具(进入地图显示)
function KabalaTreeExploreView:initMapItem()

    local itemTab = {}
    self.KabalaTreeItem:initItem(self.Image_random,itemTab)
end

--创建npc
function KabalaTreeExploreView:createNpc()

    if not self.tileMap then
        return
    end

    self.KabalaTreeNpc = KabalaTreeNpc:new()
    self.tileMap:addChild(self.Panel_player)
    self.KabalaTreeNpc:initPlayerInfo(self.Panel_player,self.playerPos,self.playerModeScale)

    local offsetY = 10
    local seqact = Sequence:create({
        MoveBy:create(0.5, ccp(0, offsetY)),
        MoveBy:create(0.5, ccp(0, -offsetY)),
    })
    self.Panel_player:runAction(RepeatForever:create(seqact))
    return true

end

function KabalaTreeExploreView:touchBegin(touch,touchPos)

    if not self.tileMap then
        return
    end

    self.mapTouchBeginPos = touchPos
    local point = me.p(self.tileMap:convertToNodeSpace(touchPos))    
    local posM,posN = KabalaTreeDataMgr:convertToMN(point.x,point.y)
    local num = self.tileMap:getLayerNum()

end

function KabalaTreeExploreView:touchMoved(touch,touchPos)

    if not self.tileMap then
        return
    end

    self.mapContainerPrePos = self.mapContainerPos
    self.mapContainerPos = touchPos
    if self.mapContainerPos and self.mapContainerPrePos then
        self.mapContainerDiffPos = ccp(self.mapContainerPos.x - self.mapContainerPrePos.x, self.mapContainerPos.y - self.mapContainerPrePos.y)
        local targetPos = me.pAdd(ccp(self.tileMap:getPositionX(),self.tileMap:getPositionY()),self.mapContainerDiffPos)        
        KabalaTreeDataMgr:detectEdges(targetPos)        
        self.tileMap:setPosition(targetPos)
    end 
end

function KabalaTreeExploreView:touchEnd(touch,touchPos)

    self.mapContainerPrePos = nil
    self.mapContainerPos = nil
    self.mapContainerDiffPos = nil

    if not self.tileMap then
        return
    end

    local touchEndPos = touchPos
    local dis = me.pGetDistance(self.mapTouchBeginPos,touchEndPos)
    if dis < self.minTouchMoveDis then

        self:clickTiled(touchPos)
    end
end

function KabalaTreeExploreView:clickTiled(touchPos)
   
    local point = me.p(self.tileMap:convertToNodeSpace(touchPos))
    local posM,posN = KabalaTreeDataMgr:convertToMN(point.x,point.y)
    local curPosMN = self.KabalaTreeNpc:getPositiontMN()

    local isExist = KabalaTreeDataMgr:existInMap(ccp(posM,posN))
    if not isExist then
        return
    end

    if curPosMN.x == posM and curPosMN.y == posN then
        return
    end

    print("clickMN",posM,posN)
    --有一些判断(是否存在怪物,建筑,道具,是否是障碍物)   
    local palyerState = self.KabalaTreeNpc:getPlayerState()
    if palyerState ~= "moving" then
        local distance = KabalaTreeDataMgr:getTiledDistance(curPosMN,ccp(posM,posN))
        self:findPath(curPosMN,ccp(posM,posN))
    end

end

function KabalaTreeExploreView:findPath(srcPos,desPos)

    self.KabalaAStarPath:initData(srcPos,desPos)
    local result = self.KabalaAStarPath:findAStarPath()
    if result then
        local path = self.KabalaAStarPath:getPath()
        self.KabalaTreeNpc:startMove(path,function()
            self:playerFinishMove()
        end)
    else
        Utils:showTips("无法到达目的地");
    end  
end

--移动到目的地
function KabalaTreeExploreView:playerFinishMove()

    --到达目的地产生格子
    local posMN = self.KabalaTreeNpc:getPositiontMN()
    self:startSpawnTile(posMN.x,posMN.y)

    self:triggerTiledEvent(posMN)
end

--触发格子事件(领取随机道具) 
function KabalaTreeExploreView:triggerTiledEvent(tilePosMN)

    if not self.tileMap then
        return
    end

    --依据tiled配置判定类型(临时使用gid代替1-普通格子 2-其他 3-随机道具)
    local layer = self.tileMap:getLayer("ground")
    local gid = layer:getTileGIDAt(tilePosMN)
    if gid == 1 then
        print("normal")
    elseif gid == 2 then
        print("other")
    elseif gid == 3 then        
        local rewardList = {}
        table.insert(rewardList,{id=500018,num=10})
        table.insert(rewardList,{id=500017,num=8})
        Utils:showReward(rewardList)
        self.KabalaTreeItem:cleanItem(tilePosMN)
    end
end

--产生格子
function KabalaTreeExploreView:startSpawnTile(posM,posN)

    if not self.tileMap or self.spawningTile then
        return
    end

    local layer = self.tileMap:getLayer("ground")
    self.aroundTile = KabalaTreeDataMgr:getSpawnTiledAround(ccp(posM,posN))    
    self.aroundIndex = 1
    self:spawnAroundTile()
end

--产生周围的格子
function KabalaTreeExploreView:spawnAroundTile()
    if not self.tileMap then
        return
    end
    self.spawningTile = true
    local curTile = self.aroundTile[self.aroundIndex]
    if not curTile then
        self.spawningTile = false
        return
    end
        
    local layer = self.tileMap:getLayer("ground")
    local tileImg = layer:getTileAt(ccp(curTile.x,curTile.y))
    local zOder = tileImg:getZOrder()
    local position = tileImg:getPosition()
    local spawnAction = Spawn:create({
        FadeIn:create(0.5),
        MoveTo:create(0.5,ccp(position.x,position.y+80))
    })
    local seq = Sequence:create({
        spawnAction,
        CallFunc:create(function ()                
            self.aroundIndex = self.aroundIndex + 1
            self:spawnAroundTile()

            self.KabalaTreeItem:spawnNewItem(curTile)
        end)
    })
    tileImg:runAction(seq)
    
end

--定位
function KabalaTreeExploreView:locationPlayer()

    local posMN = self.KabalaTreeNpc:getPositiontMN()
    local targetPosition = KabalaTreeDataMgr:convertToPos(posMN.x,posMN.y)
    local mapPosX, mapPosY = self:getMapContaierPos(targetPosition)
    local position = KabalaTreeDataMgr:detectEdges(ccp(mapPosX,mapPosY)) 
    local sequence = Sequence:create({
        MoveTo:create(0.5,position),
        CallFunc:create(function ()
            print("1111111111111111")
        end)
    })
    self.tileMap:runAction(sequence)        
end

function KabalaTreeExploreView:getMapContaierPos(playerPos)

    local tileXCount,tileYCount = KabalaTreeDataMgr:getTileXYCount()
    local tileWidth,tileHeight  = KabalaTreeDataMgr:getTileSize()

    local mappos = self.tileMap:getPosition()
    local winSize = me.Director:getVisibleSize()  
    local mapPosX = (tileXCount*tileWidth/2 - playerPos.x)*self.mapScale
    local mapPosY = (tileYCount*tileHeight/2 - playerPos.y)*self.mapScale
    return mapPosX, mapPosY
end

--**********************************UI***************************************

function KabalaTreeExploreView:stopSchedule()
    if self._scheduleId then
        TFDirector:removeTimer(self._scheduleId)
        self._scheduleId = nil
    end
end

function KabalaTreeExploreView:removeEvents()
    self:stopSchedule()
end


function KabalaTreeExploreView:onCountDownPer()

    self.timer = self.timer + 1
    if self.timer >= 50 then
        self:updateRadar()
        self.timer = 0
    end
end

function KabalaTreeExploreView:updateRadar()

    local randarTime = 0.5
    local radarCircle = self.radarCircle:clone()
    self.Image_radar:addChild(radarCircle)


    local sequence = Sequence:create({
        Spawn:create({
            ScaleTo:create(2,1.1),
            FadeIn:create(2),
        }),
        CallFunc:create(function ()
            radarCircle:removeFromParent()
        end)
    })
    radarCircle:runAction(sequence)

    local repeatAct = RepeatForever:create(
        RotateBy:create(2,360)
    )
    self.radarFlash:runAction(repeatAct)
end


function KabalaTreeExploreView:registerEvents()

    --[[self:setBackBtnCallback(function ()
        AlertManager:close()
        local view = AlertManager:getLayer(-1)
        if view and view.__cname == "kabalaTreesMainView" then
            print("is kabalaTreeMainView")
        else
            Utils:openView("kabalaTree.kabalaTreeMainView")
        end
    end)]]
    self.Panel_treeExploreMap:addMEListener(TFWIDGET_TOUCHBEGAN, handler(self.touchBegin,self));
    self.Panel_treeExploreMap:addMEListener(TFWIDGET_TOUCHMOVED, handler(self.touchMoved,self));
    self.Panel_treeExploreMap:addMEListener(TFWIDGET_TOUCHENDED, handler(self.touchEnd,self));

    self.Button_maphelp:onClick(function ()
        Utils:showTips("地图说明")
        self:locationPlayer()
    end)

    self.Button_itembag:onClick(function ()
        Utils:showTips("道具背包")
    end)

    self.Button_statelist:onClick(function ()
        Utils:showTips("状态列表")
    end)

    for i=1,3 do
        self.teamInfo[i].teamImage:onClick(function ()
            self:onTouchTeamHead(i)
        end)
    end
    --[[
    多点触碰控制缩放
    local listener1 = cc.EventListenerTouchAllAtOnce:create()
    listener1:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener1:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN ) 
    listener1:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )
    ]]
end

function KabalaTreeExploreView:uiLogic()


    self:updateTeamPL()
    self:updateTask()

    --雷达
    for i=1,10 do
        local updateTiem = 3
        if i > 3 and i < 7 then
            updateTiem = 5
        elseif i > 7 then
            updateTiem = 6
        end
        local repeatAct = RepeatForever:create(Blink:create(updateTiem,i))
        self.radarDot[i]:runAction(repeatAct)
    end
    self:updateRadar()

end

--阵容界面
function KabalaTreeExploreView:updateTeamPL()
    
    for i = 1, 3 do
        local isOn = HeroDataMgr:getIsFormationOn(i)
        if isOn then
            local id = HeroDataMgr:getHeroIdByFormationPos(i)
            local headIconRes = HeroDataMgr:getIconPathById(id)
            self.teamInfo[i].headImg:setTexture(headIconRes) 
            self.teamInfo[i].headImg:setScale(0.55)
            local isCapitan = true
            self.teamInfo[i].memberflag:setVisible(isCapitan)
            self.teamInfo[i].Image_add:setVisible(false)
            self.teamInfo[i].stateTx:setVisible(true)
            self.teamInfo[i].barbg:setVisible(true)
        else
            self.teamInfo[i].memberflag:setVisible(false)
            self.teamInfo[i].Image_add:setVisible(true)
            self.teamInfo[i].stateTx:setVisible(false)
            self.teamInfo[i].barbg:setVisible(false)
        end
    end
end

function KabalaTreeExploreView:onTouchTeamHead(index)
    Utils:showTips("换阵容")
end

--任务列表
function KabalaTreeExploreView:updateTask()
    self.taskLabel[1]:setText("收集任务道具(0/5)")
    self.taskLabel[2]:setText("击杀撒旦,净化质点(未完成)")
end

return KabalaTreeExploreView