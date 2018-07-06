local TowerUI = class("TowerUI", BaseUI)
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local ClassItemCell = require('script/app/global/itemcell')

local attconf = GameData:getConfData('attribute')
function TowerUI:ctor(data,stype)
    self.uiIndex = GAME_UI.UI_TOWER_MAIN
    self.data = data
    self.stype = stype

    self.curFloor = self.data.cur_floor
    self.maxFloor = self.data.top_floor
    self.sweepTime = self.data.sweep_start_time or 0
    self.resetNum = self.data.reset_num
    self.achievementGotRecord = self.data.get_effort

    self.realTowerConf = GameData:getConfData('tower')
    self.towerConf = {}

    for i = #self.realTowerConf, 1, -1 do
        local obj = GlobalApi:clone(self.realTowerConf[i])
        obj.id = i
        table.insert(self.towerConf, obj)
    end

    --加底
    local obj = {}
    obj.id = 0
    table.insert(self.towerConf, obj)

    -- 显示的层数
    --self.showCount = self.data.
end

function TowerUI:setUIBackInfo()
    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_TOWER_MAIN), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideTowerMain()
        end
    end,1)
end

function TowerUI:init()

    local bgimg =  self.root:getChildByName("bg_img")
    self:adaptUI(bgimg)

    local winSize = cc.Director:getInstance():getWinSize()

    self:setUIBackInfo()

    local maskTopImg = bgimg:getChildByName("mask_top_img")
    local topImgSize = maskTopImg:getContentSize()
    maskTopImg:setContentSize(cc.size(winSize.width,topImgSize.height))

    local maskbottomImg = bgimg:getChildByName("mask_bottom_img")
    local bottomImgSize = maskbottomImg:getContentSize()
    maskbottomImg:setContentSize(cc.size(winSize.width,bottomImgSize.height))

    -- 商店按钮
    local shop = bgimg:getChildByName('shop')
    local btnTx = shop:getChildByName("func_tx")
    btnTx:setString(GlobalApi:getLocalStr_new("TOWER_BTN_STR2"))
    local space = shop:getContentSize().width + 25
    shop:setPosition(cc.p(winSize.width - 10, winSize.height - 140))
    shop:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showShop(21,{min = 21,max = 22},self.data.max_star or 0)
        end
    end)

    -- 排行榜按钮
    local rank = bgimg:getChildByName('rank')
    local btnTx = rank:getChildByName("func_tx")
    btnTx:setString(GlobalApi:getLocalStr_new("TOWER_BTN_STR1"))
    rank:setPosition(cc.p(winSize.width - space - 10, winSize.height - 140))
    rank:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RankingListMgr:showRankingListMain(3)
        end
    end)

    -- 帮助按钮
    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.TOWER)
    btn:setPosition(cc.p(winSize.width - space * 2 - 10, winSize.height - 140))
    btn:loadTextureNormal('uires/ui_new/arena/battlelog1.png')
    btn:loadTexturePressed('uires/ui_new/arena/battlelog2.png')
    btn:setAnchorPoint(cc.p(1, 0))
    local funcTx = btn:getChildByName('func_tx')
    if funcTx == nil then
        local funcTx = ccui.Text:create()
        funcTx:setFontName("font/gamefont1.ttf")
        funcTx:setFontSize(20)
        local size = btn:getContentSize()
        funcTx:setPosition(cc.p(size.width/2,13))
        funcTx:setTextColor(cc.c4b(255, 255, 255, 255))
        funcTx:enableOutline(COLOR_TYPE.BLACK, 2)
        funcTx:setAnchorPoint(cc.p(0.5,0.5))
        funcTx:setName('fucn_tx')
        funcTx:setString(GlobalApi:getLocalStr_new('TOWER_BTN_STR3'))
        btn:addChild(funcTx)
    end
    bgimg:addChild(btn)

    -- 成就按钮
    local group = bgimg:getChildByName('group')
    local btnTx = group:getChildByName("func_tx")
    btnTx:setString(GlobalApi:getLocalStr_new("TOWER_BTN_STR"))
    group:setPosition(cc.p(winSize.width - space * 3 - 10, winSize.height - 140))
    group:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:showAchievementUI(self.maxFloor, self.achievementGotRecord)
        end
    end)

    self.opPanel = bgimg:getChildByName('op_pl')
    self.opPanel:setPositionX(winSize.width*0.7)

    -- 标题
    local titleBg = self.opPanel:getChildByName('title_bg')
    self.titleTx = titleBg:getChildByName('title_tx')
    self.tipsTx = self.opPanel:getChildByName('tips_tx')
    
    -- 推荐战力
    self.recommendFightForceLabel = self.opPanel:getChildByName('fight_force_label') 
    self.recommendFightForce = self.opPanel:getChildByName('fight_force_tx')
    -- 推荐等级
    self.recommendLevelLabel = self.opPanel:getChildByName('level_label')
    self.recommendLevel = self.opPanel:getChildByName('level_tx')

    -- 奖励面板
    local awardPanel = self.opPanel:getChildByName('award_bg')
    self.infoBg = awardPanel:getChildByName('info_bg')
    self.infoLabelTx = self.infoBg:getChildByName('info_label_tx')
    self.info_tx = self.infoBg:getChildByName('info_tx')
    self.cashImg = self.infoBg:getChildByName('cash_img')
    self.cashImg:setVisible(false)
    self.itemCell = {}
    for i=1,3 do
        local itemNode = awardPanel:getChildByName('item_node'..i)
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        itemNode:addChild(tab.awardBgImg)
        self.itemCell[i] = tab
        tab.awardBgImg:setScale(0.8)
    end

    self.sweepBtn = awardPanel:getChildByName('sweep_btn')
    self.sweepBtnTx = self.sweepBtn:getChildByName('func_tx')
    self.sweepBtnTx:setString(GlobalApi:getLocalStr_new('STR_SWEEP'))

    -- 挑战按钮
    self.fightBtn = self.opPanel:getChildByName('fight_btn')
    self.fightBtnTx = self.fightBtn:getChildByName('func_tx')
    self.fightBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:challenge()
        end 
    end)

    self.resetCountTx = self.opPanel:getChildByName('reset_count_tx')
    local resetCountInfoTx = self.opPanel:getChildByName('reset_count_info')
    resetCountInfoTx:setString(GlobalApi:getLocalStr_new('TOWER_INFO_STR1'))

    -- 爬塔滚动区域
    local opPanelSize = self.opPanel:getContentSize()
    self.floorSv = bgimg:getChildByName('floor_sv')
    self.floorSv:setScrollBarEnabled(false)
    self.floorCell = bgimg:getChildByName('floor_cell')
    self.floorCell:setVisible(false)
    local size = self.floorSv:getContentSize()

    self.floorSv:setContentSize(cc.size(winSize.width*0.7 - opPanelSize.width/2,size.height))
    self.viewSize = self.floorSv:getContentSize() -- 可视区域的大小
    self.cellCenterPosX = (winSize.width*0.7 - opPanelSize.width/2)*0.5
    self:update()
    self:initListView()

    local mainObj = RoleData:getMainRole()
    local url = mainObj:getUrl()
    self.mainAni = GlobalApi:createAniByName(url)
    if self.mainAni then
        self.floorSv:addChild(self.mainAni)
        self.mainAni:getAnimation():play("idle", -1, 1)
        self.mainAni:setScale(0.5)
        self.mainAni:setLocalZOrder(#self.towerConf+1)
    end

    local pos = self:getFloorPos(self.curFloor)
    self.mainAni:setPosition(pos)
    if self.curFloor % 2 == 1 then
        self.mainAni:setScaleX(-0.5)
    else
        self.mainAni:setScaleX(0.5)
    end

    if self.stype == 'shop1' then
        MainSceneMgr:showShop(22,{min = 21,max = 22},self.data.max_star or 0)
    end
end

function TowerUI:initListView()
    self.cellSpace = 0
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.towerConf
    for i = allNum, 1, -1 do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData, widgetItem)
        self:addItem(tempCellData,widgetItem)
    end

    local function updateCallback(tempCellData, widgetItem)
        self:updateItem(tempCellData,widgetItem)
    end

    local startPos = self:getFloorListStartPos()
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.floorSv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback, 1, -startPos, updateCallback)
    else
        self.scrollViewGeneral:resetScrollView(self.floorSv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback, 1, -startPos, updateCallback)
    end
end

function TowerUI:getFloorListStartPos()
    local startFloor = self.curFloor - 1
    if startFloor < 0 then
        startFloor = 0
    end
    local startPos = startFloor * 105
    if startPos + self.floorSv:getContentSize().height > self.allHeight then
        startPos = self.allHeight - self.floorSv:getContentSize().height
    end

    return startPos
end

function TowerUI:getFloorPos(floorId)


    local floorPosY = floorId * 105+70
    if floorPosY + self.floorSv:getContentSize().height > self.allHeight then
        floorPosY = self.allHeight - self.floorSv:getContentSize().height
    end

    local posX = floorId  % 2 == 0 and 145 or 265
    return cc.p(posX,floorPosY)
end

function TowerUI:initItemData(index)
    if self.towerConf[index] then
        local w = 249
        local h = 105
        
        local curCellHeight = h

        self.allHeight = curCellHeight + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w
        table.insert(self.cellsData, tempCellData)
    end
end

function TowerUI:addItem(tempCellData, widgetItem)
    if self.towerConf[tempCellData.index] then
        local index = tempCellData.index

        local cell = self.floorCell:clone()
        cell:setVisible(true)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(cell, index)
        cell:setName('cell' .. index)
        cell:setPosition(cc.p(self.cellCenterPosX,h*0.5))

        self:updateFloorCell(cell, index)
    end
end

function TowerUI:updateItem(tempCellData, widgetItem)
    if self.towerConf[tempCellData.index] then
        local index = tempCellData.index
        local cell = widgetItem:getChildByName('cell' .. index)
        self:updateFloorCell(cell, index)
    end
end

function TowerUI:createAni(parentnode,url,index,uiOffsetY)
    parentnode:removeAllChildren()
    local spineAni = GlobalApi:createLittleLossyAniByName(url.."_display")
    if spineAni then
        self.spineAniarr[index] = spineAni
        spineAni:setPosition(cc.p(parentnode:getContentSize().width/2,uiOffsetY))
        parentnode:addChild(spineAni)
    end
end

function TowerUI:updateFloorCell(cell, index)
    local bgImg = cell:getChildByName('bg_img')
    local icon = cell:getChildByName('icon_img')
    local floorNumBg = icon:getChildByName('floor_num_bg')
    local floorTx = floorNumBg:getChildByName('floor_tx')
    local lockImg = floorNumBg:getChildByName('lock_img')
    local aniNode = icon:getChildByName('ani')
    local obj = self.towerConf[index]

    local posX = obj.id  % 2 == 0 and 75 or 195
    icon:setPositionX(posX)

    if obj.id == 0 then
        bgImg:loadTexture('uires/ui_new/tower/floor_bottom.png')
        aniNode:setVisible(false)
        floorNumBg:setVisible(false)
        return
    else
        bgImg:loadTexture('uires/ui_new/tower/floor_mid.png')
        if obj.id  % 2 == 0 then
            bgImg:setScaleX(-1)
        end
    end

    
    floorTx:setString(string.format(GlobalApi:getLocalStr_new('TOWER_FLOOR_HEAD'), obj.id))
    local conf = self.realTowerConf[obj.id]
    if obj.id <= self.maxFloor then
        lockImg:setVisible(false)
        floorTx:setTextColor(cc.c4b(253,232,43, 255))
        floorTx:enableOutline(cc.c4b(94,46,16, 255), 2)
    else
        -- 等级不满足
        lockImg:setVisible(true)
        floorTx:setTextColor(cc.c4b(173,173,173, 255))
        floorTx:enableOutline(cc.c4b(32,32,32, 255), 2)
    end

    if (obj.id <= self.curFloor) then
        -- 打过的
        
        if #conf.boxAward > 0 then
            aniNode:setVisible(true)
            aniNode:loadTexture('uires/ui_new/tower/box_open.png')
        else
            -- 没宝箱的，显示空的
            aniNode:setVisible(false)
        end
        
    else
        aniNode:setVisible(true)

        -- 没打过的
        if #conf.boxAward > 0 then
            -- 有宝箱
            aniNode:loadTexture('uires/ui_new/tower/box.png')
        else
            -- 没宝箱的显示怪物
            aniNode:removeAllChildren()
            local formationConf = GameData:getConfData('formation')[conf.formation]
            local bossIndex = formationConf.boss
            local bossId = formationConf['pos' .. bossIndex]
            local _,_,monsterModelConf = GlobalApi:getMonsterConf(bossId)
            if monsterModelConf then
                local spineAni = GlobalApi:createAniByName(monsterModelConf.modelUrl)
                if spineAni then
                    aniNode:addChild(spineAni)
                    spineAni:getAnimation():play("idle", -1, 1)
                    spineAni:setPosition(cc.p(25, 0))

                    if obj.id  % 2 ~= 0 then
                        spineAni:setScaleX(-1)
                    end
                    aniNode:setScale(0.5)
                end
            end
        end
    end
end

function TowerUI:onShowUIAniOver()
    if self.data.cur_floor == 1 and self.data.cur_room == 2 then -- 玩家第一次打完第一关时触发引导
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.TOWER)
    end
end

function TowerUI:onShow()
    self:doupdate()
end

function TowerUI:doupdate()
    MessageMgr:sendPost('get','tower',"{}",function (response)
        
        release_print('get tower resp')
        local code = response.code
        if code == 0 then
            self.data = response.data
            self.curFloor = self.data.cur_floor
            self.maxFloor = self.data.top_floor
            self.sweepTime = self.data.sweep_start_time
            self.resetNum = self.data.reset_num
            self.achievementGotRecord = self.data.get_effort

            UserData:getUserObj():initTower(response.data)
            TowerMgr:setTowerData(self.data)
            self:update()
        end
    end)
end

function TowerUI:getMaxLvcount()
    local formationconf = GameData:getConfData('formation')
    local num = 0
    for k,v in pairs (formationconf) do
        if tonumber(k)> 10000 and tonumber(k) < 20000 then
            num = num + 1
        end
    end
    return math.floor(num/3)
    
end

function TowerUI:update()

    if TowerMgr:getTowerAction() then
        TowerMgr:setTowerAction(false)
        local action = cc.CSLoader:createTimeline("csb/towermainpanel.csb")
        self.root:runAction(action)
        action:play("animation0", false)
        xx.Utils:Get():setActionTimelineAnimationEndCallFunc(action, "animation0", function ()
            xx.Utils:Get():removeActionTimelineAnimationEndCallFunc(action, "animation0")
            self:updatemain(self.curFloor + 1)

            if self.scrollViewGeneral then
                self.scrollViewGeneral:updateItems()
            end
        end)
    else
        self:updatemain(self.curFloor + 1)
        
        if self.scrollViewGeneral then
            self.scrollViewGeneral:updateItems()
        end
    end
end

-- 刷新指定层信息
function TowerUI:updatemain(floor)
    local floorInfo = self.realTowerConf[floor]

    self.titleTx:setString(string.format(GlobalApi:getLocalStr_new('TOWER_FLOOR_HEAD'), floor))

    local formationConf = GameData:getConfData('formation')[floorInfo.formation]
    local fightForce = formationConf.fightforce
    self.recommendFightForceLabel:setString(GlobalApi:getLocalStr_new('RECOMMEND_FIGHT_FORCE_LABEL'))
    self.recommendFightForce:setString(GlobalApi:formatFightNum(fightForce))

    if floorInfo.level == 0 then
        self.recommendLevelLabel:setVisible(false)
        self.recommendLevel:setVisible(false)
    else
        self.recommendLevelLabel:setVisible(true)
        self.recommendLevel:setVisible(true)
        self.recommendLevelLabel:setString(GlobalApi:getLocalStr_new('NEED_PLAYER_LEVEL'))
        self.recommendLevel:setString(floorInfo.level)
    end

    local towerAward = {}
    for i=1,2 do
        table.insert(towerAward,floorInfo.award[i])
    end
    table.insert(towerAward,floorInfo.boxAward[1])
    local displayData = DisplayData:getDisplayObjs(towerAward)
    for i=1,3 do
        local awards = displayData[i]
        if awards then
            self.itemCell[i].awardBgImg:setVisible(true)
            ClassItemCell:updateItem(self.itemCell[i], awards,1)
        else
            self.itemCell[i].awardBgImg:setVisible(false)
        end
    end


    local vipLevel = UserData:getUserObj():getVip()
    local maxCount = GameData:getConfData('vip')[tostring(vipLevel)].towerAgainTimes
    local remainCount = maxCount - self.resetNum
    self.resetCountTx:setString(remainCount..'/'..maxCount)

    self.infoBg:removeChildByTag(9527)

    -- 重置和扫荡按钮
    if self.curFloor >= self.maxFloor then
        if self.curFloor == 0 then
            -- 显示扫荡按钮并置灰
            self.sweepBtnTx:setString(GlobalApi:getLocalStr_new('STR_SWEEP'))
            self.sweepBtnTx:setTextColor(cc.c4b(235,235,235, 255))
            self.sweepBtnTx:enableOutline(cc.c4b(62,62,62, 255), 2)
            self.sweepBtn:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(self.sweepBtn)

            self.infoLabelTx:setString(GlobalApi:getLocalStr_new('STR_CAN_SWEEP'))
            self.info_tx:setVisible(false)
            self.cashImg:setVisible(false)
        else
            -- 显示重置按钮
            self.sweepBtn:setTouchEnabled(true)
            ShaderMgr:restoreWidgetDefaultShader(self.sweepBtn)

            self.sweepBtnTx:setString(GlobalApi:getLocalStr_new('STR_RESET'))
            self.sweepBtnTx:setTextColor(cc.c4b(246,228,182, 255))
            self.sweepBtnTx:enableOutline(cc.c4b(116,66,7, 255), 2)

            self.sweepBtn:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self:Reset()
                end
            end)

            self.infoLabelTx:setString(GlobalApi:getLocalStr_new('TOWER_RESET_LABEL'))
            self.info_tx:setVisible(true)

            local resetCost = GameData:getConfData('toweragaincost')[self.resetNum+1]
            if resetCost.cost[1][3] == 0 then
                self.cashImg:setVisible(false)
                self.info_tx:setString(GlobalApi:getLocalStr_new('STR_FREE_RESET'))
                self.info_tx:setPositionX(98)
            else
                self.cashImg:setVisible(true)
                self.info_tx:setString(math.abs(resetCost.cost[1][3]))
                self.info_tx:setPositionX(137)
            end
        end
    else
        self.cashImg:setVisible(false)
        self.sweepBtn:setTouchEnabled(true)
        ShaderMgr:restoreWidgetDefaultShader(self.sweepBtn)
        self.sweepBtnTx:setTextColor(cc.c4b(246,228,182, 255))
        self.sweepBtnTx:enableOutline(cc.c4b(116,66,7, 255), 2)

        -- 显示扫荡按钮
        if self.sweepTime > 0 then
            -- 正在扫荡
            self.sweepBtnTx:setString(GlobalApi:getLocalStr_new('STR_STOP'))
            self.sweepBtn:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self:stopSweep()
                end
            end)

            -- 倒计时显示
            self:refreshSweepTime()
        else
            self.sweepBtnTx:setString(GlobalApi:getLocalStr_new('STR_SWEEP'))
            self.infoLabelTx:setVisible(true)
            self.infoLabelTx:setString(GlobalApi:getLocalStr_new('STR_CAN_SWEEP'))
            self.info_tx:setVisible(false)

            self.sweepBtn:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self:sweep()
                end
            end)
        end
    end

    -- 当前层是否可以挑战
    local userLevel = UserData:getUserObj():getLv()
    if userLevel >= floorInfo.level then
        self.fightBtn:setVisible(true)
    else
        -- 等级不满足
        self.fightBtn:setVisible(false)
    end
end

-- 刷新扫荡时间
function TowerUI:refreshSweepTime()
    if self.sweepTime > 0 then
        local currTime = GlobalData:getServerTime()
        local passTime = currTime - self.sweepTime

        self.infoLabelTx:setVisible(false)
        self.info_tx:setVisible(false)

        local node = cc.Node:create()
        node:setTag(9527)    
        node:setPosition(cc.p(110,17))
        self.infoBg:removeChildByTag(9527)
        self.infoBg:addChild(node)
        local totalTime, times = self:calcSweepTime(self.curFloor + 1, self.maxFloor, passTime)
        local remainTime = totalTime - passTime
        Utils:createCDLabel(node, remainTime, COLOR_TYPE.GREEN, cc.c4b(0,0,0,255), CDTXTYPE.FRONT, GlobalApi:getLocalStr_new('STR_SWEEP_TIME'), nil, nil, 20, function ()
            self:sweepFinishCallback()
        end)

        local scheduler = self.root:getScheduler()
        for i = 1,#times do
            local interval = times[i][2]
            local floor = times[i][1]

            local subnode = cc.Node:create()
            local _me = self
            local subLabel = Utils:createCDLabel(subnode, interval, COLOR_TYPE.GREEN, cc.c4b(0,0,0,255), CDTXTYPE.FRONT, '', nil, nil, 20, function ()
                _me.curFloor = floor
                _me:refreshFloorInfo(_me.curFloor)
                self:roleMove(floor-1,floor)
            end)
            node:addChild(subnode)
            subLabel:setVisible(false)
        end
    end
end

function TowerUI:refreshFloorInfo(floor)
    local floorInfo = self.realTowerConf[floor + 1]

    self.titleTx:setString(string.format(GlobalApi:getLocalStr_new('TOWER_FLOOR_HEAD'), floor + 1))

    local formationConf = GameData:getConfData('formation')[floorInfo.formation]
    local fightForce = formationConf.fightforce
    self.recommendFightForceLabel:setString(GlobalApi:getLocalStr_new('RECOMMEND_FIGHT_FORCE_LABEL'))
    self.recommendFightForce:setString(GlobalApi:formatFightNum(fightForce))

    if floorInfo.level == 0 then
        self.recommendLevelLabel:setVisible(false)
        self.recommendLevel:setVisible(false)
    else
        self.recommendLevelLabel:setVisible(true)
        self.recommendLevel:setVisible(true)
        self.recommendLevelLabel:setString(GlobalApi:getLocalStr_new('NEED_PLAYER_LEVEL'))
        self.recommendLevel:setString(floorInfo.level)
    end

    local towerAward = {}
    for i=1,2 do
        table.insert(towerAward,floorInfo.award[i])
    end
    table.insert(towerAward,floorInfo.boxAward[1])
    local displayData = DisplayData:getDisplayObjs(towerAward)
    for i=1,3 do
        local awards = displayData[i]
        if awards then
            self.itemCell[i].awardBgImg:setVisible(true)
            ClassItemCell:updateItem(self.itemCell[i], awards,1)
        else
            self.itemCell[i].awardBgImg:setVisible(false)
        end
    end

    local vipLevel = UserData:getUserObj():getVip()
    local maxCount = GameData:getConfData('vip')[tostring(vipLevel)].towerAgainTimes
    local remainCount = maxCount - self.resetNum
    self.resetCountTx:setString(remainCount..'/'..maxCount)

    -- 当前层是否可以挑战
    local userLevel = UserData:getUserObj():getLv()
    if userLevel >= floorInfo.level then
        self.fightBtn:setVisible(true)
    else
        -- 等级不满足
        self.fightBtn:setVisible(false)
    end

    self:refreshFloorList('cur_floor')
    if self.scrollViewGeneral then
        self.scrollViewGeneral:updateItems()
    end
end

-- 重置次数
function TowerUI:Reset(isneedcash)
    local resetCostConf = GameData:getConfData('toweragaincost')
    local cost = resetCostConf[self.resetNum + 1].cost
    if cost[1][3] > 0 then
        -- 判断元宝是否足够
        local hasCash = UserData:getUserObj():getCash()
        if (cost[1][3] > hasCash) then
            promptmgr:showSystenHint(GlobalApi:getLocalStr_new('STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
            return
        end
    end
    
    local vipLevel = UserData:getUserObj():getVip()
    local maxCount = GameData:getConfData('vip')[tostring(vipLevel)].towerAgainTimes
    local remainCount = maxCount - self.resetNum
    if remainCount <= 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('TOWER_INFO_STR2'), COLOR_TYPE.RED)
        return
    end

    local args = {}
    MessageMgr:sendPost('reset_num', 'tower', json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local costs = response.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end

            self.curFloor = 0
            self.resetNum = data.reset_num
            self:update()
            self:refreshFloorList('bottom')

            local pos = self:getFloorPos(self.curFloor)
            self.mainAni:setPosition(pos)
        end
    end)

end

function TowerUI:refreshFloorList(where)
    local function callback(tempCellData, widgetItem)
        self:addItem(tempCellData,widgetItem)
    end

    local function updateCallback(tempCellData, widgetItem)
        self:updateItem(tempCellData,widgetItem)
    end

    if self.scrollViewGeneral then
        if where == 'cur_floor' then
            local startPos = self:getFloorListStartPos()
            self.scrollViewGeneral:resetScrollView(self.floorSv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback, 1, -startPos, updateCallback)
        elseif where == 'bottom' then
            self.scrollViewGeneral:resetScrollView(self.floorSv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback, 1, 0, updateCallback)
        end
    end
end

-- 扫荡
function TowerUI:sweep()
    local args = {}
    MessageMgr:sendPost('sweep', 'tower', json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            -- 刷新时间
            self.sweepTime = data.sweep_start_time
            self:update()
        end
    end)
end

-- 停止扫荡
function TowerUI:stopSweep()
    local args = {}
    MessageMgr:sendPost('stop_sweep', 'tower', json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards and #awards > 0 then
                GlobalApi:parseAwardData(awards)
                TowerMgr:showSweepAwardsUI(data)
            end

            if data.cur_floor then
                self.curFloor = data.cur_floor
            end
            self.sweepTime = 0
            self:update()
            self:refreshFloorList('cur_floor')
        end
    end)
end

-- 挑战关卡
function TowerUI:challenge()
    
    local fightFloor = self.curFloor + 1
    local formationId = GameData:getConfData('tower')[fightFloor].formation
    local customObj = {
        id = formationId,
        cur_floor = fightFloor,
    }

    BattleMgr:playBattle(BATTLE_TYPE.TOWER, customObj, function ()
        MainSceneMgr:showMainCity(function()
            TowerMgr:showTowerMain()
        end, nil, GAME_UI.UI_TOWER_MAIN)
    end)
end

function TowerUI:roleMove(floorId,endFloorId)
    
    if floorId >= endFloorId then
        self.mainAni:getAnimation():play("idle", -1, 1)
        return
    end

    local nextFloorId = floorId+1
    if nextFloorId % 2 == 0 then
        self.mainAni:setScaleX(-0.5)
    else
        self.mainAni:setScaleX(0.5)
    end

    self.mainAni:getAnimation():play("run", -1, 1)
    local pos = self:getFloorPos(nextFloorId)
    local act =  cc.Sequence:create(cc.MoveTo:create(0.2, pos),cc.CallFunc:create(function ()
        self:roleMove(nextFloorId,endFloorId)
        self:crashBody(nextFloorId)
    end)) 
    self.mainAni:runAction(act)
end

--撞飞
function TowerUI:crashBody(floorId)
    local widget = self.floorSv:getChildByName('cell' .. (#self.towerConf-floorId))
    if widget then
        local cell = widget:getChildByName('cell' .. (#self.towerConf-floorId))
        local icon = cell:getChildByName('icon_img')
        local aniNode = icon:getChildByName('ani')
        
        local conf = self.realTowerConf[floorId]
        if conf then
            if #conf.boxAward >0 then
                aniNode:loadTexture('uires/ui_new/tower/box_open.png')
            else
                aniNode:setVisible(false)
                local formationConf = GameData:getConfData('formation')[conf.formation]
                local bossIndex = formationConf.boss
                local bossId = formationConf['pos' .. bossIndex]
                local _,_,monsterModelConf = GlobalApi:getMonsterConf(bossId)
                if monsterModelConf.bodyIcon then

                    local cloneAniNode = aniNode:clone()
                    cloneAniNode:loadTexture("uires/icon/big_hero/"..monsterModelConf.bodyIcon)
                    cloneAniNode:setScale(1)
                    cloneAniNode:setVisible(true)
                    local pos = aniNode:convertToWorldSpace(cc.p(aniNode:getPosition()))
                    cloneAniNode:setPosition(pos)
                    UIManager:addAction(cloneAniNode)

                    local dir = floorId%2 == 1 and 1 or -1

                    local bezier = {
                        cc.p(pos.x,pos.y),
                        cc.p(pos.x+150*dir,pos.y+300),
                        cc.p(pos.x+350*dir,-100)
                    }

                    local action = cc.Spawn:create(cc.RotateTo:create(0.6, 360*6),cc.BezierTo:create(0.6, bezier))
                    local act = cc.Sequence:create(action,cc.CallFunc:create(function ()
                        cloneAniNode:removeFromParent()
                    end))
                    cloneAniNode:runAction(act)
                end
            end
        end       
    end
end 

-- 计算扫荡至目标层需要多久
function TowerUI:calcSweepTime(startLevel, endLevel, passTime)
    local retTime = 0
    local retTimes = {}
    for i = startLevel,endLevel do
        retTime = retTime + self.realTowerConf[i].costTime

        if retTime > passTime then
            local obj = {i, retTime - passTime}
            table.insert(retTimes, obj)
        end
    end

    return retTime, retTimes
end

-- 扫荡完成回调
function TowerUI:sweepFinishCallback( )

    self.infoBg:removeChildByTag(9527)

    self.infoLabelTx:setVisible(true)
    self.infoLabelTx:setString(GlobalApi:getLocalStr_new('STR_CAN_SWEEP'))
    self:stopSweep()
end

function TowerUI:updateAchievementGetRecord(id)
    table.insert(self.achievementGotRecord, id)
end

return TowerUI