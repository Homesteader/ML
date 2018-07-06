local ArenaUI = class("ArenaUI", BaseUI)
local winSize = cc.Director:getInstance():getWinSize()
local space = 10

local rankImg = {
    [1] =  {bg = 'uires/ui_new/arena/flag1.png',title = 'uires/ui_new/arena/flower1.png'},
    [2] =  {bg = 'uires/ui_new/arena/flag2.png',title = 'uires/ui_new/arena/flower2.png'},
    [3] =  {bg = 'uires/ui_new/arena/flag3.png',title = 'uires/ui_new/arena/flower3.png'},
    [4] =  {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [5] =  {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [6] =  {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [7] =  {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [8] =  {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [9] =  {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [10] = {bg = 'uires/ui_new/arena/flag4.png',title = 'uires/ui_new/arena/flower4.png'},
    [11] = {bg = 'uires/ui_new/arena/flag5.png',title = 'uires/ui_new/arena/flower5.png'}
}

function ArenaUI:ctor(jsonObj,arenaType)

    self.uiIndex = GAME_UI.UI_ARENA
    self.data = jsonObj.data
    self.arenaType = arenaType
    self.myRank = jsonObj.data.rank or 100000
    self.topTen = jsonObj.data.top_ten
    self.enemys = jsonObj.data.enemy
    self.maxRank = jsonObj.data.max_rank        --历史最高排位
    self.maxType = jsonObj.data.max_type        --历史最高竞技场类型
    self.award_got = jsonObj.data.award_got     --成就奖励领取情况
    self.oldMaxCnt = 0
end

function ArenaUI:setUIBackInfo()

    local name = string.format(GlobalApi:getLocalStr_new("AREAN_TITLE_TX3"),self.arenabaseCfg.name)
    name = name or UIManager:getUIName(GAME_UI.UI_ARENA)
    UIManager.sidebar:setBackBtnCallback(name, function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ArenaMgr:hideArena()
        end
    end)
end

function ArenaUI:onShow()
    self:setUIBackInfo()
end

function ArenaUI:onHide()
    self:stopSchedule()
end

function ArenaUI:init()

    local bgimg = self.root:getChildByName("bg_img")
    self:adaptUI(bgimg)

    if not self.arenaType then
        promptmgr:showSystenHint('arena type nil', COLOR_TYPE.RED)
        return
    end

    self.arenabaseCfg = GameData:getConfData("arenabase")[self.arenaType]
    self.arenaRankCfg = GameData:getConfData("arenarank")[self.arenaType]
    local rankIndx = #self.arenaRankCfg
    for i=1,#self.arenaRankCfg do
        if self.myRank >= self.arenaRankCfg[i].rank then
            rankIndx = i
        else
            break
        end
    end

    self:setUIBackInfo()

    self.arenaRefreshCd =GlobalApi:getGlobalValue_new("arenaRefreshCd")

    local bottombg = bgimg:getChildByName("bottom_bg")
    local bottomBgsize = bottombg:getContentSize()
    bottombg:setContentSize(cc.size(winSize.width,bottomBgsize.height))
    
    --徽章信息
    local badgebg = bgimg:getChildByName("badge_bg")
    local dadgeIcon = badgebg:getChildByName("badge_icon")
    dadgeIcon:loadTexture("uires/icon/badge/"..self.arenabaseCfg.icon)
    badgebg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ArenaMgr:showArenaAwardUI(self.arenaType,rankIndx)
        end
    end)
    local detailsBtn = badgebg:getChildByName("details_btn")
    detailsBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ArenaMgr:showArenaAwardUI(self.arenaType,rankIndx)
        end
    end)

    local tipTx = badgebg:getChildByName("tip")
    tipTx:setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX4"))
    local rankAward = self.arenaRankCfg[rankIndx].award
    for i=1,2 do
        local disPlayData = DisplayData:getDisplayObjs(rankAward)
        local resIcon = badgebg:getChildByName("res_icon"..i)
        local resNumTx = badgebg:getChildByName("res_num"..i)
        local awards = disPlayData[i]
        if not awards then
            resIcon:setVisible(false)
            resNumTx:setVisible(false)
        else
           resIcon:setVisible(true)
           resNumTx:setVisible(true) 
           resIcon:loadTexture(awards:getIcon())
           resNumTx:setString(awards:getNum())
        end
    end

    --功能按钮组
    self.iconBg = bgimg:getChildByName("icon_bg")
    self.iconBg:setPositionX(winSize.width)
    self:initFunctionBtn()

    --底部条文字显示
    local bottomBgsize = bottombg:getContentSize()
    self.refreshBtn = bottombg:getChildByName("refresh_btn")
    self.refreshBtnTx = self.refreshBtn:getChildByName("text")
    self.refreshBtnTx :setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX1"))
    self.refreshBtn:setPositionX(bottomBgsize.width+4)
    self.refreshBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.refreshBtn:setEnabled(false)
            self.refreshBtnTx:setVisible(false)
            self.cdnode:setVisible(true)
            self:refresh()
        end
    end)
    self.cdnode = cc.Node:create()
    self.cdnode:setPosition(160,30)
    self.refreshBtn:add(self.cdnode)

    local tipTx1 = bottombg:getChildByName("tip1")
    tipTx1:setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX2"))
    local tipTx2 = bottombg:getChildByName("tip2")
    tipTx2:setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX3"))
    local timeTx = bottombg:getChildByName("time_tx")
    local arenaBalanceTime =GlobalApi:getGlobalValue_new("arenaBalanceTime")
    timeTx:setString(arenaBalanceTime..":00")

    local contTip = bottombg:getChildByName("cont_tip")
    local contTipPosX = bottomBgsize.width/2-50
    contTip:setPositionX(contTipPosX)
    contTip:setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX1"))
    local tipSize = contTip:getContentSize()
    self.contNumTx = bottombg:getChildByName("cont_tx")
    self.contNumTx:setPositionX(contTipPosX+tipSize.width+3)

    --购买次数
    local addBtn = bottombg:getChildByName("add_btn")
    local posX = self.contNumTx:getPositionX()
    addBtn:setPositionX(posX+40)
    addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:buyChallengeCount()
        end
    end)

    self.cardSv = bgimg:getChildByName("sv")
    self.cardSv:setItemsMargin(space)

    self:updateChallengeCount()
    self.cellbg = bgimg:getChildByName("cell_bg")

    self:updateRankList()

end


function ArenaUI:stopSchedule()
    if self._scheduleId then
        GlobalApi:clearScheduler(self._scheduleId)
        self._scheduleId = nil
    end
end

function ArenaUI:initFunctionBtn()

    --布阵
    local embattleBtn = self.iconBg:getChildByName("embattle_btn")
    local btnTx = embattleBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX2"))
    embattleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BattleMgr:showEmbattleUI()
        end
    end)

    --战报
    local battlelogBtn = self.iconBg:getChildByName("battlelog_btn")
    local btnTx = battlelogBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX3"))
    battlelogBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ArenaMgr:showArenaV2Report()
        end
    end)

    --排行
    local rankBtn = self.iconBg:getChildByName("rank_btn")
    local btnTx = rankBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX4"))
    rankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RankingListMgr:showRankingListMain(2)
        end
    end)

    --商店
    local storeBtn = self.iconBg:getChildByName("store_btn")
    local btnTx = storeBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX5"))
    storeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showShop(31,{min = 31,max = 32}, self.data.max_rank)
        end
    end)

    --成就
    local achieveBtn = self.iconBg:getChildByName("achieve_btn")
    local btnTx = achieveBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX6"))
    achieveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ArenaMgr:showArenaAchieveUI(self.arenaType,self.myRank,self.maxType,self.maxRank,self.award_got)
        end
    end)
end

function ArenaUI:initData()

    self.rankData = {}
    for k,v in pairs(self.topTen) do
        local obj = v
        obj.uid = tonumber(k)
        obj.type = 'check'
        table.insert(self.rankData, obj)
    end

    for k,v in pairs(self.enemys) do
        local obj = v
        obj.uid = tonumber(k)
        obj.type = 'fight'
        table.insert(self.rankData, obj)
    end
    table.sort(self.rankData, function (a, b)
        return a.rank < b.rank
    end)
end

function ArenaUI:updateChallengeCount()

    local arenaMaxCount = GlobalApi:getGlobalValue_new('arenaMaxCount')
    local challengeCount = arenaMaxCount + self.data.buy_count - self.data.count 
    self.contNumTx:setString(challengeCount)

end

function ArenaUI:updateRankList()

    self:stopSchedule()
    self.cardSv:removeAllChildren()
    self:initData()

    local curIndex = 1
    local myRankIndex = 1
    local function callBack()
        if self.rankData[curIndex] then

            local item = self.cellbg:clone()
            self:updateRankData(item, curIndex, self.rankData[curIndex])
            self.cardSv:pushBackCustomItem(item)

            if self.myRank == self.rankData[curIndex].rank then
                myRankIndex = curIndex
            end
            
            curIndex = curIndex + 1
        else
            self:stopSchedule()
            self.cardSv:setTouchEnabled(true)

            if myRankIndex > 5 then
                self.cardSv:jumpToRight()
            else
                self.cardSv:jumpToLeft()
            end
        end
    end
    self._scheduleId        = GlobalApi:interval(callBack,0.05)

end

function ArenaUI:updateRankData(cellBg, curIndex,rankInfo)

    cellBg:stopAllActions()
    cellBg:setVisible(true)
    cellBg:setOpacity(0)

    cellBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

    local titleTx = cellBg:getChildByName("title_tx")
    titleTx:setVisible(self.arenaType~=1)
    local titleBg = cellBg:getChildByName("title_bg")
    titleBg:setVisible(self.arenaType==1)

    --头显示
    local rankPos = rankInfo.rank
    if rankPos >=11 then
        cellBg:loadTexture(rankImg[11].bg) 
        titleBg:loadTexture(rankImg[11].title) 
    else
        cellBg:loadTexture(rankImg[rankPos].bg) 
        titleBg:loadTexture(rankImg[rankPos].title) 
    end
    
    --名字
    local nameTx = cellBg:getChildByName("name_tx")
    nameTx:setString(rankInfo.name)

    --排名
    local rankTx = cellBg:getChildByName("rank_tx")
    rankTx:setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX5")..rankPos)
    local rankImg = cellBg:getChildByName("rank_img")
    rankImg:setVisible(rankPos<=3)
    rankImg:loadTexture("uires/ui_new/rank/rank_"..rankPos..".png")
    rankTx:setVisible(rankPos>3)
    
    --战斗力
    local fightTx = cellBg:getChildByName("fight_tx")
    fightTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_FIGHT").."："..rankInfo.fight_force)
    
    --模型
    local hid = tonumber(rankInfo.model)
    local promote = nil
    local weapon_illusion = nil
    local wing_illusion = nil
    local _,heroCombatConf = GlobalApi:getHeroConf(hid)
    if heroCombatConf.camp == 5 then
        if rankInfo.weapon_illusion and rankInfo.weapon_illusion > 0 then
            weapon_illusion = rankInfo.weapon_illusion
        end
        if rankInfo.wing_illusion and rankInfo.wing_illusion > 0 then
            wing_illusion = rankInfo.wing_illusion
        end
    end
    local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
    local heroNode = cellBg:getChildByName("hero_node")
    local spineAni = heroNode:getChildByName("role_ani")
    if spineAni then
        spineAni:removeFromParent()
    end
    spineAni = GlobalApi:createLittleLossyAniByRoleId(hid,changeEquipObj)
    spineAni:setScale(0.5)
    spineAni:setPosition(cc.p(0,-10))
    spineAni:getAnimation():play("idle", -1, 1)
    spineAni:setName("role_ani")
    heroNode:addChild(spineAni)

    --挑战
    local battleBtn = cellBg:getChildByName("battle_btn")
    local btnTx = battleBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX7"))
    battleBtn:setVisible(rankInfo.type=='fight' and self.myRank~=rankPos)
    battleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:fight(curIndex)
        end
    end)

    --查看
    local checkBtn = cellBg:getChildByName("check_btn")
    local btnTx = checkBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX8"))
    checkBtn:setVisible(rankInfo.type=='check' and self.myRank~=rankPos)
    checkBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BattleMgr:showCheckInfo(rankInfo.uid,'world','arena')
        end
    end)

    --我自己标识
    local myselfImg = cellBg:getChildByName("myself_img")
    local imgTx = myselfImg:getChildByName("text")
    imgTx:setString(GlobalApi:getLocalStr_new("AREAN_BTN_TX9"))
    myselfImg:setVisible(self.myRank==rankPos) 

end

--挑战
function ArenaUI:fight(index)

    local arenaMaxCount = GlobalApi:getGlobalValue_new('arenaMaxCount')
    local challengeCount = arenaMaxCount + self.data.buy_count - self.data.count 
    if challengeCount <= 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('AREAN_TIP_TX6'), COLOR_TYPE.RED)
        return
    end

    local obj = {
        enemy = self.rankData[index].uid
    }
    
    MessageMgr:sendPost('challenge', 'arena', json.encode(obj), function (jsonObj)
        if jsonObj.code == 0 then
            local customObj = {
                headpic = self.rankData[index].headpic,
                challengeUid = self.rankData[index].uid,
                info = jsonObj.data.info,
                enemy = jsonObj.data.enemy,
                rand1 = jsonObj.data.rand1,
                rand2 = jsonObj.data.rand2,
                rand_pos = jsonObj.data.rand_pos,
                rand_attrs = jsonObj.data.rand_attrs,
                maxRank = self.data.max_rank
            }
            if customObj.challengeUid <= 1000000 then
                customObj.quality = 4
            else
                customObj.quality = self.rankData[index].quality
            end
            BattleMgr:playBattle(BATTLE_TYPE.ARENA, customObj, function (battleReportJson)
                MainSceneMgr:showMainCity(function()
                    ArenaMgr:showArena(battleReportJson.data.type)
                end, nil, GAME_UI.UI_ARENA)
            end)
        end
    end)

end

--购买次数
function ArenaUI:buyChallengeCount()

    local vip = UserData:getUserObj():getVip()
    local vipConf = GameData:getConfData("vip")
    local extraTimes = vipConf[tostring(vip)].arenaExtraChallenge
    if self.data.buy_num >= extraTimes then 
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('COMMON_BUY_TIMES_OVER'), COLOR_TYPE.RED)
        return
    end

    local buyConf = GameData:getConfData("buy")
    local cost = buyConf[self.data.buy_num + 1].arenaExtraChallenge
    local cash = UserData:getUserObj():getCash()
    if cash < cost then -- 元宝不足
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('COMMON_NO_CASH'), COLOR_TYPE.RED)
    else
        promptmgr:showMessageBox(
            string.format(GlobalApi:getLocalStr_new("ARENA_BUY_CHALLENGE"), cost)..'\n'..string.format(GlobalApi:getLocalStr_new("ARENA_BUY_CHALLENGE_TIMES"),extraTimes - self.data.buy_num),
            MESSAGE_BOX_TYPE.MB_OK_CANCEL,
            function ()
                MessageMgr:sendPost("buy_count", "arena", "{}", function (jsonObj)
                if jsonObj.code == 0 then
                    self.data.buy_count = jsonObj.data.buy_count
                    self.data.buy_num = jsonObj.data.buy_num
                    GlobalApi:parseAwardData(jsonObj.data.awards)
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    self:updateChallengeCount()
                end
            end)
        end)
    end
end

--刷新
function ArenaUI:refresh()

    local function callback()
        self.cdnode:setVisible(false)
        self.refreshBtnTx:setVisible(true)
        self.refreshBtn:setEnabled(true)
    end
    Utils:createCDLabel(self.cdnode,self.arenaRefreshCd-1,COLOR_TYPE.GRAY1,COLOROUTLINE_TYPE.GRAY1,nil,"",COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,26,callback,1)
    MessageMgr:sendPost("refresh", "arena", "{}", function (jsonObj)
        if jsonObj.code == 0 then
            self.enemys = jsonObj.data.enemy or {}  
            self:updateRankList()
        end
    end)
end
return ArenaUI