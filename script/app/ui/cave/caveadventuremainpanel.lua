-- 文件：山洞探险主界面
-- 创建：zzx
-- 日期：2017-12-09

local CaveAdventureMainPanelUI  = class("CaveAdventureMainPanelUI", BaseUI)
local ClassItemCell             = require('script/app/global/itemcell')

local function ConvertTime(time)
    local h             = math.floor(time / 3600)
    time                = time % 3600
    local m             = math.floor(time / 60)
    local s             = time % 60

    return h, m, s
end

local GRID_MAX_POS = 28

function CaveAdventureMainPanelUI:ctor( caveData_ )
    self.uiIndex                = GAME_UI.UI_CAVE_ADVENTURE_MAIN_PANEL
    self._caveData              = caveData_
end

function CaveAdventureMainPanelUI:setUIBackInfo()
    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_CAVE_ADVENTURE_MAIN_PANEL), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CaveAdventureMgr:hideMainUI()
        end
    end, 1)
end

function CaveAdventureMainPanelUI:init()
    self:setUIBackInfo()

    local bottomBg              = self.root:getChildByName('bottom_bg')
    local bottomImg             = bottomBg:getChildByName('bottom_img')

    local lockPl                = self.root:getChildByName('lock_img')

    local bottomBgSize          = bottomBg:getContentSize()

     -- 适配
    bottomBg:setPosition( cc.p(self:getWSize().width / 2, self:getWSize().height / 2) )
    bottomImg:setPosition( cc.p(bottomBgSize.width / 2, bottomBgSize.height / 2 - 30) )

    lockPl:setPosition( cc.p(self:getWSize().width / 2, self:getWSize().height / 2) )
    lockPl:setContentSize( self:getWSize() )

    self._bottomImg             = bottomImg
    self._lockPl                = lockPl

    -- 棋子
    local chess                 = bottomImg:getChildByName('chess')

    self._chess                 = chess

    self:initData()
    -- 初始化格子
    self:initGrids()
    -- 初始化棋子
    self:initChess()
    -- 初始化骰子
    self:initDice()

    self:startSchedule()

    self:updateAll()
end

function CaveAdventureMainPanelUI:onShow()
    self:setUIBackInfo()
end

function CaveAdventureMainPanelUI:onHide()
    self:stopSchedule()
end

function CaveAdventureMainPanelUI:startSchedule()
    self:stopSchedule()

    self.scheduleId         = GlobalApi:interval(function(dt) self:updateTime(dt) end,0.5)
end

function CaveAdventureMainPanelUI:stopSchedule()
    if self.scheduleId then
        GlobalApi:clearScheduler(self.scheduleId)
        self.scheduleId = nil
    end
end

function CaveAdventureMainPanelUI:initData()
    self._grids                 = {}
end

function CaveAdventureMainPanelUI:updateAll()
    self:updateChessInfo()
    self:updateTime()
    self:updateChess()
    self:updateFinalBox()
end

function CaveAdventureMainPanelUI:initGrids()
    -- 初始坐标
    local startPos      = cc.p(55, 480)
    -- x间距
    local interval_x    = 91
    -- y间距
    local interval_y    = 85

    local girdIndex     = 1

    -- 1~ 10
    for i = 1, 10 do
        local grid      = self:createGrid(girdIndex)

        grid:setPosition( cc.p(startPos.x + (i-1) * interval_x, startPos.y) )
        grid:setLocalZOrder(1)
        self._bottomImg:addChild(grid)

        table.insert(self._grids, grid)

        girdIndex       = girdIndex + 1
    end

    -- 11 ~ 14
    for i = 1, 4 do
        local grid      = self:createGrid(girdIndex)
        
        grid:setPosition( cc.p(startPos.x + 9 * interval_x, startPos.y - i * interval_y) )
        grid:setLocalZOrder(i + 1)
        self._bottomImg:addChild(grid)

        table.insert(self._grids, grid)

        girdIndex       = girdIndex + 1
    end

    -- 15 ~ 24
    for i = 1, 10 do
        local grid      = self:createGrid(girdIndex)
        
        grid:setPosition( cc.p(startPos.x + (10 - i) * interval_x, startPos.y - 5 * interval_y) )
        grid:setLocalZOrder(6)
        self._bottomImg:addChild(grid)

        table.insert(self._grids, grid)

        girdIndex       = girdIndex + 1
    end

    -- 25 ~ 28
    for i = 1, 4 do
        local grid      = self:createGrid(girdIndex)
        
        grid:setPosition( cc.p(startPos.x, startPos.y - (5 - i) * interval_y) )
        grid:setLocalZOrder(6 - i)
        self._bottomImg:addChild(grid)

        table.insert(self._grids, grid)

        girdIndex       = girdIndex + 1
    end

    self:updateGrids()
end

function CaveAdventureMainPanelUI:createGrid( girdIndex_ )

    if not girdIndex_ then
        return
    end

    local gridImg       = ccui.ImageView:create('uires/ui_new/cave/grid_1.png')
    local gridIco       = ccui.ImageView:create('uires/ui_new/cave/dice.png')

    local size          = gridImg:getContentSize()

    gridIco:setName('ico')
    gridIco:setScale(0.85)
    gridIco:setPosition( cc.p(size.width / 2, size.height / 2) )
    gridIco:setVisible(false)

    gridImg:setContentSize(cc.size(90, 91))
    gridImg:addChild(gridIco)

    if girdIndex_ == GRID_MAX_POS then
        local cornerIco = ccui.ImageView:create('uires/ui_new/common/conerR_red.png')
        cornerIco:setPosition(cc.p(65, 20))

        local txt       = ccui.Text:create(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_12'), 'font/gamefont.ttf', 16)

        txt:setTextColor(cc.c4b(255, 222, 10, 255))
        txt:enableOutline(cc.c4b(85, 10, 11, 255), 1)
        txt:setPosition(cc.p(24, 12.5))

        cornerIco:addChild(txt)
        gridImg:addChild(cornerIco)
    end

    return gridImg
end

function CaveAdventureMainPanelUI:updateGrids()    
    for idx, _ in ipairs (self._grids) do
        self:updateOneGrid(idx)
    end
end

function CaveAdventureMainPanelUI:updateOneGrid( idx_ )
    local caveEventConf     = GameData:getConfData('customcaveevent')
    local caveArr           = self._caveData['cave']['cave_arr']

    local gridImg           = self._grids[idx_]
    local gridIco           = gridImg:getChildByName('ico')

    if caveArr[idx_] then
        -- 起点
        if idx_ == 1 then
            gridImg:setTouchEnabled(false)
            gridImg:loadTexture( 'uires/ui_new/cave/grid_4.png' )
            gridIco:setVisible(false)
        else
            if caveEventConf[caveArr[idx_]] then
                gridImg:loadTexture( caveEventConf[caveArr[idx_]]['gridBgUrl'] )
                gridIco:setVisible(true)
                gridIco:loadTexture( caveEventConf[caveArr[idx_]]['gridAwardUrl'] )

                local conf          = GameData:getConfData('customcaveaward')
                local joinLv        = self._caveData['cave']['level']

                local confData      = conf[tonumber(joinLv)]

                if confData[caveArr[idx_]] then
                    -- PrintT(confData[caveArr[idx_]], true)

                    local disObj    = DisplayData:getDisplayObj( confData[caveArr[idx_]][1] )

                    gridImg:setTouchEnabled(true)
                    gridImg:addTouchEventListener(function (sender, eventType)
                        if eventType == ccui.TouchEventType.began then
                            AudioMgr.PlayAudio(11)
                        elseif eventType == ccui.TouchEventType.ended then
                            GetWayMgr:showGetwayUI(disObj,false)
                        end
                    end)
                else
                    gridImg:setTouchEnabled(false)
                end                
            else
                gridImg:setTouchEnabled(false)
                gridImg:loadTexture( 'uires/ui_new/cave/grid_1.png' )
                gridIco:setVisible(false)
            end
        end
    end
end

function CaveAdventureMainPanelUI:getGirdPosition( girdIndex_ )
    if not self._grids[girdIndex_] then
        return
    end

    local x, y = self._grids[girdIndex_]:getPosition()

    return cc.p(x, y)
end

function CaveAdventureMainPanelUI:initChess()
    self._chess:setVisible(true)
    self._chess:setLocalZOrder(9999)
end

function CaveAdventureMainPanelUI:updateChess()
    local chessPos          = self._caveData['cave']['cur_stay'] + 1

    self._chess:setPosition( self:getGirdPosition(chessPos) )
end

function CaveAdventureMainPanelUI:updateTime( dt_ )
    local centerBg          = self._bottomImg:getChildByName('center_bg')
    local infoBg            = centerBg:getChildByName('bg')

    -- 更新骰子倒计时
    local cdDescTx          = infoBg:getChildByName('revert_desc_cd_time_tx')
    local cdTx              = infoBg:getChildByName('revert_cd_time_tx')

    local maxDiceNum        = tonumber(GlobalApi:getGlobalValue_new('customCaveDiceNumLimit'))
    local curDiceNum        = self._caveData['cave']['left_num']

    -- print('maxDiceNum = ' , maxDiceNum)
    -- print('curDiceNum = ' , curDiceNum)

    if curDiceNum >= maxDiceNum then
        cdDescTx:setVisible(false)
        cdTx:setVisible(false)
    else
        local revertTime    = self._caveData['cave']['start_reply_time']
        local coldMinutes   = tonumber(GlobalApi:getGlobalValue_new('customCaveDiceInterval')) * 60

        local coldEndTime   = revertTime + coldMinutes
        local nowTime       = GlobalData:getServerTime()

        if coldEndTime >= nowTime then
            cdDescTx:setVisible(true)
            cdTx:setVisible(true)

            local leftTime      = coldEndTime - nowTime
            local h, m, s       = ConvertTime(leftTime)
                        
            cdTx:setString(string.format('%02d:%02d:%02d', h, m, s))
        else
            cdDescTx:setVisible(false)
            cdTx:setVisible(true)
            cdTx:setString('00:00:00')

            self:stopSchedule()

            CaveAdventureMgr:sendReplyDicePost( function (data)

                if not CaveAdventureMgr:isExistUI('caveMainUI') then
                    return
                end

                if data['left_num'] and data['start_reply_time'] then
                    self._caveData['cave']['left_num'] = data['left_num']
                    self._caveData['cave']['start_reply_time'] = data['start_reply_time']
                end
                
                self:startSchedule()
                self:updateTime()
                self:updateChessInfo()
            end)
        end
    end

    -- 更新宝箱倒计时
    local finalBoxBg        = infoBg:getChildByName('final_box_bg')
    local boxTimeTx         = finalBoxBg:getChildByName('box_time_tx')

    local shardObj          = self._caveData['cave']['shard']
    local isFinsh           = true

    for k, v in pairs (shardObj) do
        if v == 0 then
            isFinsh = false
        end
    end

    if isFinsh and boxTimeTx:isVisible() then
        local finshTime     = self._caveData['cave']['put_shard_time']
        local disapperTime  = finshTime + tonumber(GlobalApi:getGlobalValue_new('customCaveSuperBoxLife')) * 3600
        local nowTime       = GlobalData:getServerTime()

        -- 未超时
        if disapperTime >= nowTime then
            local leftTime  = disapperTime - nowTime
            local h, m, s   = ConvertTime(leftTime)
                        
            boxTimeTx:setString(string.format('%02d:%02d:%02d', h, m, s))
        else
            boxTimeTx:setString('00:00:00')

            self:stopSchedule()

            CaveAdventureMgr:sendMainPost( function (data)

                if not CaveAdventureMgr:isExistUI('caveMainUI') then
                    return
                end
                
                self:startSchedule()
                self:updateAll()
            end)
        end
    end
end

function CaveAdventureMainPanelUI:updateChessInfo()
    local centerBg          = self._bottomImg:getChildByName('center_bg')
    local infoBg            = centerBg:getChildByName('bg')

    local diceNumTx         = infoBg:getChildByName('dice_num_tx')

    local maxDiceNum        = tonumber(GlobalApi:getGlobalValue_new('customCaveDiceNumLimit'))
    local curDiceNum        = self._caveData['cave']['left_num']

    diceNumTx:setString( curDiceNum .. '/' .. maxDiceNum )
end

function CaveAdventureMainPanelUI:initDice()
    local centerBg          = self._bottomImg:getChildByName('center_bg')
    local infoBg            = centerBg:getChildByName('bg')

    local scaleMarkImg      = infoBg:getChildByName('scalemark_img')
    local dicePointer       = infoBg:getChildByName('dice_bg')
    local diceIco           = infoBg:getChildByName('dice_ico')

    local diceNumTx         = infoBg:getChildByName('dice_num_tx')

    local descTx            = infoBg:getChildByName('desc_tx')

    local cdDescTx          = infoBg:getChildByName('revert_desc_cd_time_tx')
    local cdTx              = infoBg:getChildByName('revert_cd_time_tx')

    descTx:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_1') )
    cdDescTx:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_2') )

    local isActive          = false

    dicePointer:setTouchEnabled(true)
    dicePointer:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isActive = false

            dicePointer:stopAllActions()
            dicePointer:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function ()
                        isActive = true
                        self:startRandomPointer()  
                    end)
                ))
        elseif eventType == ccui.TouchEventType.ended then
            dicePointer:stopAllActions()
            if isActive then
                isActive = false
                self:endRandomPointer()
            end
        end
    end)
end

function CaveAdventureMainPanelUI:updateFinalBox()
    local centerBg          = self._bottomImg:getChildByName('center_bg')
    local infoBg            = centerBg:getChildByName('bg')
    local finalBoxBg        = infoBg:getChildByName('final_box_bg')

    local lightImg          = finalBoxBg:getChildByName('light_img')
    local boxImg            = finalBoxBg:getChildByName('box_img')

    local descTx1           = finalBoxBg:getChildByName('desc_tx_1')
    local chipIco           = finalBoxBg:getChildByName('chip_ico')
    local chipNumTx         = finalBoxBg:getChildByName('chip_num_tx')

    local boxTimeDescTx     = finalBoxBg:getChildByName('box_time_desc_tx')
    local boxTimeTx         = finalBoxBg:getChildByName('box_time_tx')

    descTx1:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_7') )
    boxTimeDescTx:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_8') )

    boxImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CaveAdventureMgr:showOpenBoxUI(self._caveData)
        end
    end)

    local shardObj          = self._caveData['cave']['shard']
    local isDamage          = self._caveData['cave']['super_box_mar'] == 1
    local isFinsh           = true
    local chipNum           = 0

    for k, v in pairs (shardObj) do
        if v == 0 then
            isFinsh = false
        else
            chipNum = chipNum + 1
        end
    end

    -- 拼成
    if isFinsh then
        local finshTime     = self._caveData['cave']['put_shard_time']
        local disapperTime  = finshTime + tonumber(GlobalApi:getGlobalValue_new('customCaveSuperBoxLife')) * 3600
        local nowTime       = GlobalData:getServerTime()

        -- 未超时
        if disapperTime >= nowTime then
            descTx1:setVisible(false)
            chipIco:setVisible(false)
            chipNumTx:setVisible(false)

            -- 损坏
            if isDamage then
                lightImg:setVisible(false)
                boxImg:setVisible(false)
                lightImg:stopAllActions()

                boxTimeDescTx:setVisible(true)
                boxTimeTx:setVisible(true)

                for i = 1, 4 do
                    local chipImg = finalBoxBg:getChildByName('chip_' .. i) 

                    chipImg:setVisible(true)
                    ShaderMgr:setGrayForWidget(chipImg)
                end

                local leftTime   = disapperTime - nowTime
                local h, m, s    = ConvertTime(leftTime)
                            
                boxTimeTx:setString(string.format('%02d:%02d:%02d', h, m, s))
                boxTimeDescTx:setString(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_14'))
            else
                lightImg:setVisible(true)
                boxImg:setVisible(true)
                boxImg:setTouchEnabled(true)
                lightImg:stopAllActions()
                lightImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(1, 60))))

                boxTimeDescTx:setVisible(true)
                boxTimeTx:setVisible(true)

                for i = 1, 4 do
                    local chipImg = finalBoxBg:getChildByName('chip_' .. i) 
                    chipImg:setVisible(false)
                end

                local leftTime   = disapperTime - nowTime
                local h, m, s    = ConvertTime(leftTime)
                            
                boxTimeTx:setString(string.format('%02d:%02d:%02d', h, m, s))
                boxTimeDescTx:setString(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_8'))
            end
        else
            descTx1:setVisible(true)
            chipIco:setVisible(true)
            chipNumTx:setVisible(true)
            chipNumTx:setString( chipNum .. '/4' )

            lightImg:setVisible(false)
            boxImg:setVisible(false)
            lightImg:stopAllActions()

            for i = 1, 4 do
                local chipImg = finalBoxBg:getChildByName('chip_' .. i)

                chipImg:setVisible(false)
                ShaderMgr:setGrayForWidget(chipImg)
            end

            boxTimeDescTx:setVisible(false)
            boxTimeTx:setVisible(false)
        end
    else
        descTx1:setVisible(true)
        chipIco:setVisible(true)
        chipNumTx:setVisible(true)
        chipNumTx:setString( chipNum .. '/4' )

        lightImg:setVisible(false)
        boxImg:setVisible(false)
        lightImg:stopAllActions()

        for i = 1, 4 do
            local chipImg = finalBoxBg:getChildByName('chip_' .. i)

            chipImg:setVisible(true)
            if shardObj[tostring(i)] == 0 then
                ShaderMgr:setGrayForWidget(chipImg)
            else
                ShaderMgr:restoreWidgetDefaultShader(chipImg)
            end
        end

        boxTimeDescTx:setVisible(false)
        boxTimeTx:setVisible(false)
    end
end

function CaveAdventureMainPanelUI:startRandomPointer()
    local centerBg          = self._bottomImg:getChildByName('center_bg')
    local infoBg            = centerBg:getChildByName('bg')

    local dicePointer       = infoBg:getChildByName('dice_bg')

    local time              = math.random(2, 5) / 10
    local angle             = math.random(1, 128) - 64

    dicePointer:stopAllActions()

    dicePointer:runAction(cc.Sequence:create(
            cc.RotateTo:create(time, angle),
            cc.CallFunc:create(function ()
                self:startRandomPointer()
            end)
        ))
end

function CaveAdventureMainPanelUI:endRandomPointer()
    local centerBg          = self._bottomImg:getChildByName('center_bg')
    local infoBg            = centerBg:getChildByName('bg')

    local dicePointer       = infoBg:getChildByName('dice_bg')

    local angel             = dicePointer:getRotation()
    local diceNumStr        = ''

    -- logger('angel = ' .. angel)

    if angel >= -64 and angel <= -24 then
        diceNumStr = '1,2'
    elseif angel >= -23 and angel <= 23 then
        diceNumStr = '3,4'
    elseif angel >= 24 and angel <= 64 then
        diceNumStr = '5,6'
    else
        logger('angel out of range .. ')
        return
    end

    local curDiceNum        = self._caveData['cave']['left_num']
    local chessPos          = self._caveData['cave']['cur_stay'] + 1

    if curDiceNum <= 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_6'), COLOR_TYPE.RED)
        return
    end

    CaveAdventureMgr:sendShakeDicePost( diceNumStr, function (data)

        if not CaveAdventureMgr:isExistUI('caveMainUI') then
            return
        end

        if data['diceNum'] then
            local str = string.format(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_15'), tostring(data['diceNum']))
            
            promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)

            self:moveChess(chessPos, math.min(chessPos + data['diceNum'], GRID_MAX_POS) , function ()
                self:moveChessEnd(data)
            end)
        end
    end)
end

function CaveAdventureMainPanelUI:moveChess( startIndex_, endIndex_ , callBack_ )
        
    local curIndex          = startIndex_
    local nextIndex         = curIndex + 1

    local function moveOneStep()
        local curPosition   = cc.p(self._chess:getPositionX(), self._chess:getPositionY())
        local nextPosition  = self:getGirdPosition( nextIndex )

        local bezierTab1    = {
            cc.p(curPosition.x + 50 / 4 , curPosition.y + 50 / 4),
            cc.p(nextPosition.x - 50 / 4 , curPosition.y + 150 / 4),
            cc.p(nextPosition.x , nextPosition.y)
        }

        local bezier1       = cc.BezierTo:create(0.2, bezierTab1)

        local arr           = {}

        arr[#arr+1]         = cc.EaseInOut:create(bezier1, 0.5)
        arr[#arr+1]         = cc.DelayTime:create(0.5)
        arr[#arr+1]         = cc.CallFunc:create(function ()
            nextIndex = nextIndex + 1

            if nextIndex > endIndex_ then
                self:lockUI(false)
                if callBack_ then
                    callBack_()
                end
            else
                moveOneStep()
            end
        end)

        self._chess:runAction(cc.Sequence:create(arr))
    end

    self:lockUI(true)
    moveOneStep()
end

function CaveAdventureMainPanelUI:moveChessEnd( data_ )

    if data_['awards'] then
        GlobalApi:parseAwardData(data_['awards'])
        GlobalApi:showAwardsCommon(data_['awards'],nil,nil,true)
    end

    if data_['cave'] then
        self._caveData['cave'] = data_['cave']
    end

    local chessPos          = self._caveData['cave']['cur_stay'] + 1
    local curChessType      = self._caveData['cave']['cave_arr'][chessPos]

    -- 飞碎片
    if curChessType == 'chip' then

        local x, y          = self._chess:getPosition()
        local sWPos         = self._chess:getParent():convertToWorldSpace(cc.p(x, y))
        local sLpos         = self._bottomImg:convertToNodeSpace(sWPos)

        local centerBg      = self._bottomImg:getChildByName('center_bg')
        local infoBg        = centerBg:getChildByName('bg')
        local finalBoxBg    = infoBg:getChildByName('final_box_bg')

        local x, y          = finalBoxBg:getPosition()
        local eWPos         = finalBoxBg:getParent():convertToWorldSpace(cc.p(x, y))
        local eLpos         = self._bottomImg:convertToNodeSpace(eWPos)

        local chipImg       = ccui.ImageView:create('uires/ui_new/cave/chip.png')

        chipImg:setScale(0.2)
        chipImg:setPosition(sLpos)

        self._bottomImg:addChild(chipImg, 999)

        local arr           = {}

        arr[#arr+1]         = cc.Spawn:create(cc.MoveTo:create(0.7, eLpos), cc.ScaleTo:create(0.7, 1))
        arr[#arr+1]         = cc.FadeOut:create(0.2)
        arr[#arr+1]         = cc.CallFunc:create(function ()
            chipImg:removeFromParent()
        end)

        chipImg:runAction(cc.Sequence:create(arr))
    end

    -- 已达最后
    if chessPos == GRID_MAX_POS then
        self:resetPlay()
    else
        self:updateAll()
    end
end

function CaveAdventureMainPanelUI:flipAllGrids()
    self:lockUI(true)
    self._chess:setVisible(false)

    for i, gridImg in ipairs(self._grids) do
        local arr       = {}

        arr[#arr+1]     = cc.OrbitCamera:create(0.5, 1, 0, 0, 90, -45, 0)
        arr[#arr+1]     = cc.CallFunc:create(function ()
            self:updateOneGrid(i)
        end)
        arr[#arr+1]     = cc.OrbitCamera:create(0.5, 1, 0, 270, 90, 45, 0)

        if i == #self._grids then
            arr[#arr+1] = cc.CallFunc:create(function ()
                self:lockUI(false)
                self._chess:setVisible(true)
                self:updateAll()
            end)
        end

        gridImg:runAction(cc.Sequence:create(arr))
    end 
end

function CaveAdventureMainPanelUI:resetPlay()
    CaveAdventureMgr:sendMainPost( function(data)
        self._caveData  = data

        self:flipAllGrids()
    end)
end

function CaveAdventureMainPanelUI:lockUI( enable_ )
    self._lockPl:setVisible( enable_ )
end

return CaveAdventureMainPanelUI