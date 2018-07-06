-- 文件：秘境矿洞脚本
-- 创建：zzx
-- 日期：2017-12-04

local BG_WIDTH 		= 2202
local SPECIAL_POS 	= cc.p(365, 260)

local LegionTrialMainPannelNewUI = class("LegionTrialMainPannelNewUI", BaseUI)

function LegionTrialMainPannelNewUI:ctor(serverData,index)
	self.uiIndex 			= GAME_UI.UI_LEGION_TRIAL_MAIN_NEW_PANNEL

    if serverData.trial.achievement == nil then
        serverData.trial.achievement = {}
    end

    self.trial 				= serverData.trial
    self.index 				= index
    self.adventure_rand 	= serverData.adventure_rand

    UserData:getUserObj().trial = self.trial

    self:initData()
end

function LegionTrialMainPannelNewUI:initData()
    self.adventureTime 		= 3
    self.bgMoveTime 		= 20

    self.curChoosePage 		= 1
    self.choosePageBtns 	= {}

    self.coins 				= {}
    
    self.centerLineTypes 	= {}

    -- 下一个探索的页数和硬币id
    self.nextExplorePage 	= 1
    self.nextExploreCoinId 	= 1

    self.legiontTialCoins 				= GameData:getConfData('trialcoins')

    self.legionTrialCoinIncreaSetype 	= GameData:getConfData('trialcoinincreasetype')

    self.legionTrialBaseConfig 			= GameData:getConfData('trialbaseconfig')

    self.legionTrialAdventure 			= GameData:getConfData('trialadventure')
end

function LegionTrialMainPannelNewUI:calNextExploreData()
    local round 			= self.trial.round
    local judge 			= false

    for i = 1, 3 do
        if judge then
            break
        end
        local coins 		= round[tostring(i)].coins
        for j = 1, 9 do
            if judge then
                break
            end
            if coins[tostring(j)] == 0 then
                judge = true
                self.nextExplorePage = i
                self.nextExploreCoinId = j
            end
        end
    end
end

function LegionTrialMainPannelNewUI:init()

	self:setUIBackInfo()

    local winSize 			= cc.Director:getInstance():getWinSize()

    local trialImg 			= self.root:getChildByName('trial_bg_img')

    trialImg:setContentSize( winSize )
    trialImg:setPosition( cc.p(winSize.width / 2, winSize.height / 2) )

    self.trialImg 			= trialImg

    local lockPl 			= self.root:getChildByName('lock_pl')

    lockPl:setVisible(false)
    lockPl:setContentSize( winSize )

    self.lockPl 			= lockPl

    -- 背景
    local backGroundBgPl 	= trialImg:getChildByName('bg_pl')
   	self.backImg 			= {}
   	for i = 1, 2 do
   		local img 			= backGroundBgPl:getChildByName('zhong_' .. i .. '_img')
   		img:setPosition( cc.p((i - 1) * BG_WIDTH, 0) )
   		self.backImg[i] 	= img
   	end
   	self.boxImg 			= backGroundBgPl:getChildByName('box_img')

   	-- 奇遇按钮
   	local adventrueBtn 		= trialImg:getChildByName('adventrue_btn')
   	-- 周成就按钮
   	local achievementBtn 	= trialImg:getChildByName('achievement_btn')

   	self.adventrueBtn 		= adventrueBtn
   	self.achievementBtn 	= achievementBtn

   	local btnsArr 			= {adventrueBtn, achievementBtn}

   	for i , v in pairs (btnsArr) do
   		v:setPosition(cc.p(80 + (i - 1) * 100, winSize.height - 130))
   	end
   
   	local rightPlNode 		= trialImg:getChildByName('right_pl_node')

   	rightPlNode:setPosition( cc.p(winSize.width, winSize.height / 2) )

   	-- 积分bar
   	local barBg 			= trialImg:getChildByName('bar_bg')

   	barBg:setPosition( cc.p(100, 30) )

   	self.barBg 				= barBg

   	-- 武将模型
    local animBg 			= trialImg:getChildByName('anim_bg')
    
    local role 				= RoleData:getMainRole()
    local spineAni 			= GlobalApi:createLittleLossyAniByName(role:getUrl()..'_display', nil, role:getChangeEquipState())

    spineAni:setScale(0.7)
    spineAni:setPosition(cc.p(animBg:getContentSize().width/2,animBg:getContentSize().height/2))
    animBg:addChild(spineAni)

    self.spineAni 			= spineAni
    self.spineAni:getAnimation():play('idle', -1, 1)

    self:initBtns()
    self:initRight()
    self:refreshLeftExploreTimes()
    self:refreshTodayScoreBar()
    self:refreshRightChoosePage(1, true)

    self:registerAction()

    self:refreshAdventureMark()
    self:refreshAchievementMark()

    if self.index then
        LegionTrialMgr:showLegionTrialAdventurePannelUI(self.trial,self.index)
    end
end

function LegionTrialMainPannelNewUI:setUIBackInfo()
    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_LEGION_TRIAL_MAIN_NEW_PANNEL), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           	LegionTrialMgr:hideLegionTrialMainPannelUI()
        end
    end, 1)
end

function LegionTrialMainPannelNewUI:onShow()
	self:setUIBackInfo()
	self:refreshStatus()
	self:refreshTodayScoreBar()
	-- logger('LegionTrialMainPannelNewUI:onShow()')
end

function LegionTrialMainPannelNewUI:onHide()
	self:stopBgAction()
	-- logger('LegionTrialMainPannelNewUI:onHide()')	
end

function LegionTrialMainPannelNewUI:refreshAdventureMark()
    local mark = self.adventrueBtn:getChildByName('mark')
    mark:setVisible(UserData:getUserObj():getLegionTrialAdventureShowStatus())
end

function LegionTrialMainPannelNewUI:refreshAchievementMark()
    local mark = self.achievementBtn:getChildByName('mark')
    mark:setVisible(UserData:getUserObj():getLegionTrialAchievementShowStatus())
end

function LegionTrialMainPannelNewUI:initBtns()
	-- 奇遇
	self.adventrueBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:showLegionTrialAdventurePannelUI(self.trial)
        end
    end)
	-- 成就
    self.achievementBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callBack(achievement)
                self.trial.achievement = achievement
                self:refreshStatus()
            end
            LegionTrialMgr:showLegionTrialAchievementPannelUI(self.trial,callBack)
        end
    end)
end

function LegionTrialMainPannelNewUI:initRight()
	local rightPlNode 		= self.trialImg:getChildByName("right_pl_node")
 
 	-- 初始化标签页   
    for i = 1, 3 do
        local chooseBtn 	= rightPlNode:getChildByName("choose" .. i .."_btn")
        local tx 			= chooseBtn:getChildByName('tx')

        tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC' .. (i + 2)))

        chooseBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:refreshRightChoosePage(i)
            end
        end)

        table.insert(self.choosePageBtns, chooseBtn)
    end

    -- 顶部道具组
    local topBg 			= rightPlNode:getChildByName("top_bg")

    for i = 1, 9 do
        local coin 			= topBg:getChildByName("coin_" .. i)

        local lightImg 		= coin:getChildByName("light_img")
        local icon 			= coin:getChildByName("icon")
        local selectImg 	= coin:getChildByName("select_img")

        icon:ignoreContentAdaptWithSize(true)

        coin.id 			= i
        coin.lightImg 		= lightImg
        coin.icon 			= icon
        coin.selectImg 		= selectImg

        table.insert(self.coins, coin)
    end

    -- 中部
    local centerBg 			= rightPlNode:getChildByName("center_bg")

    for i = 1, 3 do
        local centerLineType = centerBg:getChildByName("center_line_type" .. i)

        table.insert(self.centerLineTypes,centerLineType)
    end

    self.checkBtn 			= centerBg:getChildByName("check_btn")

    self.checkBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:showLegionTrialAddRatePannelUI()
        end
    end)

    self.noRateAddTx 		= centerBg:getChildByName("no_rate_add_tx")
    self.noRateAddTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC6'))

    -- 底部
    local bottomImg 		= rightPlNode:getChildByName('bottom_img')

    -- 一键探索按钮
    local exploreBtn 		= bottomImg:getChildByName('explore_btn')
    local exploreBtnTx 		= exploreBtn:getChildByName('text')
    -- 领取按钮
    local getBtn 			= bottomImg:getChildByName('get_btn')
    local getBtnTx 			= getBtn:getChildByName('text')
    -- 已领取文本
    local getedTx 			= bottomImg:getChildByName('geted_tx')

    exploreBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC56'))
    getBtnTx:setString(GlobalApi:getLocalStr('STR_GET'))
    getedTx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))

    self.exploreBtn 		= exploreBtn
    self.getBtn 			= getBtn
    self.getedTx 			= getedTx

    -- 一键探索
    self.exploreBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:startOneExplore()
        end
    end)

    -- 领取
    self.getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            -- 领取通讯
            local function callBack(data)
                local awards = data.awards
			    if awards then
				    GlobalApi:parseAwardData(awards)
				    GlobalApi:showAwardsCommon(awards,nil,nil,true)
			    end
                
                local achievement = data.achievement 
                -- 有改变，就替换
                if achievement then
                    for k,v in pairs(achievement) do
                        if self.trial.achievement[k] == nil then
                            self.trial.achievement[k] = {}
                            self.trial.achievement[k].award_got_level = 0
                        end
                        self.trial.achievement[k].progress = v.progress
                    end
                end 

                if data['daily_score'] then
                	self.trial.daily_score = data['daily_score']
               	end
               	if data['week_score'] then
                	self.trial.week_score = data['week_score']
               	end
                
                self.trial.round[tostring(self.curChoosePage)].award_got = 1

                self:refreshGetState()
                self:refreshTodayScoreBar()
                self:refreshStatus()
            end

            LegionTrialMgr:showLegionTrialGetAwardPannelUI(self.trial,self.curChoosePage,callBack)
        end
    end)

    local desc1Tx 			= bottomImg:getChildByName('desc_1_tx')
    local desc2Tx 			= bottomImg:getChildByName('desc_2_tx')

    desc1Tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC8'))
    desc2Tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC9'))

    local valueTx1 			= bottomImg:getChildByName('value_1_tx')
    local valueTx2 			= bottomImg:getChildByName('value_2_tx')

    local leftTimesTx 		= bottomImg:getChildByName('lefttimes_tx')

    self.valueTx1 			= valueTx1
    self.valueTx2 			= valueTx2
    self.leftTimesTx 		= leftTimesTx
end

function LegionTrialMainPannelNewUI:refreshRightChoosePage(i, isForce)

    if i == self.curChoosePage and not isForce then
        return
    end

    self.curChoosePage 		= i

    for i = 1, 3 do
        local btn 			= self.choosePageBtns[i]
        
        if i == self.curChoosePage then
            btn:loadTexture('uires/ui_new/trial/btn_2.png')
           
            self:refreshRightCoinsShowStatus()
            self:refreshRightRemain()
        else
            btn:loadTexture('uires/ui_new/trial/btn_1.png')
        end
    end
end

function LegionTrialMainPannelNewUI:refreshRightCoinsShowStatus()
    local round 		= self.trial.round
    local coins 		= round[tostring(self.curChoosePage)].coins

    for i = 1, 9 do
        local coinId 	= coins[tostring(i)]
        local coin 		= self.coins[i]
        local lightImg 	= coin.lightImg
        local icon 		= coin.icon
        local selectImg = coin.selectImg

        selectImg:setVisible(false)
        lightImg:setVisible(false)

        if coinId == 0 then
            icon:loadTexture('uires/ui_new/trial/wenhao.png')
        else
            icon:loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coinId].icon)
        end
    end

    local function blinkArrays(index,temp)
	    local allNum = #temp

	    if index > allNum then
	        index = 1
	    end

	    local blinkAnimals = temp[index]
	    local action1 = cc.DelayTime:create(0.3)
	    local action2 = cc.CallFunc:create(function ()
	        for i = 1,#blinkAnimals do
	            local pos = blinkAnimals[i]
	            local coinFrame = self.coins[pos]
	            local lightImg = coinFrame.lightImg
	            lightImg:setVisible(true)
	        end
	    end)
	    local action3 = cc.DelayTime:create(0.3)
	    local action4 = cc.CallFunc:create(function ()
	        for i = 1,#blinkAnimals do
	            local pos = blinkAnimals[i]
	            local coinFrame = self.coins[pos]
	            local lightImg = coinFrame.lightImg
	            lightImg:setVisible(false)
	        end
	        blinkArrays(index + 1,temp)
	    end)
	    self.coins[1]:runAction(cc.Sequence:create(action1,action2,action3,action4))
	end

    local function refreshRightCoinsBlinks()
    	self.coins[1]:stopAllActions()

	    local ids = {}
	    for i = 1, 9 do
	        if coins[tostring(i)] > 0 then
	            table.insert(ids,coins[tostring(i)])
	        end
	    end

	    local temp1,temp2 = LegionTrialMgr:getLegionTrialBlink(ids)
	    if #temp2 > 0 then
	        blinkArrays(1,temp2)
	    end
    end

    refreshRightCoinsBlinks()
end

function LegionTrialMainPannelNewUI:refreshRightRemain()
    -- 中间
    local round 		= self.trial.round
    local coins 		= round[tostring(self.curChoosePage)].coins
    local temp 			= {}
    local hasGetNum 	= 0

    for i = 1,9 do
        temp[i] = coins[tostring(i)]
        if temp[i] > 0 then
            hasGetNum 	= hasGetNum + 1
        end
    end

    local rates 		= LegionTrialMgr:getLegionTrialAddAwardRate(temp)

    if rates['5'] == 1 then
        self.noRateAddTx:setVisible(true)
        for _, v in pairs (self.centerLineTypes) do
        	v:setVisible(false)
        end
    else
        self.noRateAddTx:setVisible(false)
       
        local showIds 		= {}

        for i = 1, 4 do
            if rates[tostring(i)] > 0 then
                local temp 	= {}
                temp.type 	= i
                temp.value 	= rates[tostring(i)]
                table.insert(showIds,temp)
            end
        end

        for i = 1, 3 do
            if #showIds > 0 then
                local data 			= showIds[1]
                local awardIncrease = self.legionTrialCoinIncreaSetype[data.type].awardIncrease
                local rateTx 		= self.centerLineTypes[i]:getChildByName('rate_tx')
                local img 			= self.centerLineTypes[i]:getChildByName('img')
                local value 		= string.format("%.1f", awardIncrease * data.value)

                rateTx:setString(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC7'), data.value))
                self.centerLineTypes[i]:setVisible(true)
                img:loadTexture( 'uires/icon/legiontrial/' .. self.legionTrialCoinIncreaSetype[data.type].icon)
                table.remove(showIds,1)
            else
                self.centerLineTypes[i]:setVisible(false)
            end
        end
    end

    -- 奖励倍率
    local baseRateValue 	= LegionTrialMgr:getLegionTrialBaseRate()
    local addRateValue 		= 0

    local addValueTx1 		= self.valueTx1:getChildByName('add_tx')

    if rates[tostring(4)] == 1 then
        addRateValue 		= 2
    else
        for i = 1,3 do
            if rates[tostring(i)] > 0 then
                local awardIncrease = self.legionTrialCoinIncreaSetype[i].awardIncrease
                addRateValue = addRateValue + rates[tostring(i)] * awardIncrease
            end
        end
    end

   	self.valueTx1:setString( baseRateValue )
   	addValueTx1:setString( string.format("+%.1f", addRateValue) )
   	addValueTx1:setPositionPercent(cc.p(1, 0.5))

   	-- 奖励积分
   	local addValueTx2 				= self.valueTx2:getChildByName('add_tx')
    local legionTrialBaseConfigData = self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]

    local coinBaseValue 			= tonumber(legionTrialBaseConfigData.coinBaseAward)
    local coinAddValue 				= legionTrialBaseConfigData.coinBaseAward * addRateValue

    self.valueTx2:setString( coinBaseValue )
   	addValueTx2:setString( string.format("+%.1f", coinAddValue) )
   	addValueTx2:setPositionPercent(cc.p(1, 0.5))

    self:refreshGetState()
end

function LegionTrialMainPannelNewUI:refreshGetState()
    local round 					= self.trial.round
    local coins 					= round[tostring(self.curChoosePage)].coins
    local temp 						= {}
    local hasGetNum 				= 0

    for i = 1, 9 do
        temp[i] = coins[tostring(i)]
        if temp[i] > 0 then
            hasGetNum = hasGetNum + 1
        end
    end

    local isGet 					= tonumber(round[tostring(self.curChoosePage)].award_got) ~= 0

    if not isGet then -- 未领取
    	-- 可领取
        if 9 == hasGetNum then
        	self.exploreBtn:setVisible(false)
            self.getBtn:setVisible(true)
            self.getedTx:setVisible(false)
        -- 未达成
        else
            self.exploreBtn:setVisible(true)
            self.getBtn:setVisible(false)
            self.getedTx:setVisible(false)
        end
    else    -- 已领取
       	self.exploreBtn:setVisible(false)
        self.getBtn:setVisible(false)
        self.getedTx:setVisible(true)
    end

    -- 硬币监听
    for i = 1, 9 do
        local coin 		= self.coins[i]
        local id 		= coin.id
        local selectImg = coin.selectImg

        coin:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then

                if self.trial.round[tostring(self.curChoosePage)].coins[tostring(i)] == 0 or isGet then
                    return
                end

                local function callBack2()
                    selectImg:setVisible(false)
                end

                local function callBack(data,reset_count)
                    if data.costs then
                        GlobalApi:parseAwardData(data.costs)
                    end

                    self.trial.round[tostring(self.curChoosePage)].coins[tostring(i)] = data.new_coin
                    self.trial.round[tostring(self.curChoosePage)].reset_count = reset_count

                    -- 有改变，就替换
                    self:refreshAchievement(data.achievement)

                    -- 硬币随机动画
                    self:playCoinAct(coin.icon,data.new_coin)
                end

                selectImg:setVisible(true)
                LegionTrialMgr:showLegionTrialResetCoinPannelUI(self.trial,self.curChoosePage,i,callBack,callBack2)
            end
        end)
    end
end

function LegionTrialMainPannelNewUI:refreshLeftExploreTimes()
	local maxCount 	= LegionTrialMgr:getLegionTrialAllEcploreCount()
	local useCount  = self.trial.explore_count
	local leftCount = math.max(math.floor((maxCount - useCount) / 9), 0)

    local str 		= string.format(GlobalApi:getLocalStr_new('STR_TRAIL_DESC_1'), tostring(leftCount))

    self.leftTimesTx:setString(str)
end

function LegionTrialMainPannelNewUI:refreshTodayScoreBar()
	local legionTrialBaseConfigData = self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]

	local isGeted 			= self.trial.daily_award_got ~= 0

	local needScore 		= legionTrialBaseConfigData.dayAwardNeedIntegral
	local haveScore 		= self.trial.daily_score

	local bar 				= self.barBg:getChildByName('bar')
	local tx 				= self.barBg:getChildByName('tx')
	local boxImg 			= self.barBg:getChildByName('box_img')

	local per 				= haveScore / needScore * 100

	bar:setPercent( math.min(per, 100) )
	tx:setString( GlobalApi:getLocalStr_new('STR_TODAY_SCORE') .. '：' .. haveScore .. '/' .. needScore )

	local dropId 			= tonumber(legionTrialBaseConfigData['dayAwardLootId'])

	local obj  				= {}

	obj['type'] 			= 'drop'
	obj['name'] 			= GlobalApi:getLocalStr_new('STR_DAILY_BOX')
	obj['id'] 				= dropId

	if isGeted then
		boxImg:setTouchEnabled(false)
		ShaderMgr:setGrayForWidget(boxImg)
	else

		boxImg:setTouchEnabled(true)
		ShaderMgr:restoreWidgetDefaultShader(boxImg)
	end

	local function requestCallBack( data )
		if data.awards then
            GlobalApi:parseAwardData(data.awards)
            GlobalApi:showAwardsCommon(data.awards,nil,nil,true)
		end

		self.trial.daily_award_got = 1

		self:refreshTodayScoreBar()
	end

	boxImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if haveScore >= needScore then
        		LegionTrialMgr:legionTrialGetDailyBoxFromServer(requestCallBack)
        	else
        		GetWayMgr:showGetwayDropUI(obj)
        	end            
        end
	end)
end

function LegionTrialMainPannelNewUI:refreshStatus()
    UserData:getUserObj().trial = self.trial
    self:refreshAchievementMark()
    self:refreshAdventureMark()
end

function LegionTrialMainPannelNewUI:startOneExplore()

    if self.trial.explore_count >= LegionTrialMgr:getLegionTrialAllEcploreCount() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC13'), COLOR_TYPE.RED)
        return
    end

    self.stopIndex = 0

    self:calNextExploreData()
    -- 刷新到要得到硬币的标签页
    self:refreshRightChoosePage(self.nextExplorePage)

    self:startOneRunAction()
end

function LegionTrialMainPannelNewUI:startOneRunAction()
    local speed 	= 8
    local keepTime  = 5

    local animBg 	= self.spineAni:getParent()
    local x1, y1 	= animBg:getPosition()
    local wPos 		= animBg:getParent():convertToWorldSpace(cc.p(x1, y1))

    local function startBtnAni()
	    local exploreBtnTx 		= self.exploreBtn:getChildByName('text')

	    local str 				= GlobalApi:getLocalStr('LEGION_TRIAL_DESC55')
	   	
	   	exploreBtnTx:stopAllActions()
	    exploreBtnTx:setString( str )
   
    	local arr 				= {}

    	arr[#arr+1] 			= cc.DelayTime:create(0.2)
    	arr[#arr+1] 			= cc.CallFunc:create(function() exploreBtnTx:setString( str .. '.' ) end)
    	arr[#arr+1] 			= cc.DelayTime:create(0.2)
    	arr[#arr+1] 			= cc.CallFunc:create(function() exploreBtnTx:setString( str .. '..' ) end)
    	arr[#arr+1] 			= cc.DelayTime:create(0.2)
    	arr[#arr+1] 			= cc.CallFunc:create(function() exploreBtnTx:setString( str .. '...' ) end)
    	arr[#arr+1] 			= cc.DelayTime:create(0.2)
    	arr[#arr+1] 			= cc.CallFunc:create(function() exploreBtnTx:setString( str ) end)

    	exploreBtnTx:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
    end

    local function stopBtnAni()
    	local exploreBtnTx 		= self.exploreBtn:getChildByName('text')
	   	
	   	exploreBtnTx:stopAllActions()
	    exploreBtnTx:setString( GlobalApi:getLocalStr('LEGION_TRIAL_DESC56') )
    end

    local function requestCallBack( data )
    	self:oneExploreRefreshData(data)

        local serverCoins = data.coins

        local function callBackCoins()
            local coin = serverCoins[1]
            if coin then
                local coins = self.trial.round[tostring(self.nextExplorePage)].coins
                coins[tostring(self.nextExploreCoinId)] = coin
                self:refreshStatus()

                self:flyCoin(self.callBackCoins,true)
                table.remove(serverCoins,1)
                self.nextExploreCoinId = self.nextExploreCoinId + 1
            else
                self:exploreEnd()
                self:lockTouch(false)
            end
        end
        self.callBackCoins = callBackCoins

        self:lockTouch(true)

        -- 烟雾特效
        self:getBombAnimation(callBackCoins)
    end

    local function stop()
    	self:stopBgAction()

    	self.spineAni:getAnimation():play('shengli', -1, 1)

    	local arr 	= {}

    	arr[#arr+1] = cc.DelayTime:create(0.4)
    	arr[#arr+1] = cc.CallFunc:create(function ()
    		self.boxImg:setVisible(false)
    		self:lockTouch(false)
    		stopBtnAni()

    		LegionTrialMgr:legionTrialOneExploreFromServer(requestCallBack)
    	end)

    	self.boxImg:runAction(cc.Sequence:create(arr))
    end

    local function move()
    	for i , v in pairs(self.backImg) do
    		local oldx = v:getPositionX()
    		local newx = oldx - speed

    		if newx < -BG_WIDTH then
    			if i == 1 then
    				self.backImg[1]:setPositionX(BG_WIDTH)
    				self.backImg[2]:setPositionX(0)
    			else
    				self.backImg[2]:setPositionX(BG_WIDTH)
    				self.backImg[1]:setPositionX(0)
    			end
    			break
    		else
    			v:setPositionX(oldx - speed)
    		end
    	end

    	local boxX = self.boxImg:getPositionX() - speed

    	if boxX - wPos.x < 80 then
    		stop()
    	else
    		self.boxImg:setPositionX( boxX )
    	end
   	end

   	self.boxImg:stopAllActions()
   	self.boxImg:setVisible(true)
   	self.boxImg:setPosition(cc.p(1200, 290))

   	self.spineAni:getAnimation():play('run', -1, 1)

   	self:stopBgAction()
   	startBtnAni()
   	self:lockTouch(true)

    self.scheduleId = GlobalApi:interval(move, 0.01)
end

-- 一键探索结束数据刷新
function LegionTrialMainPannelNewUI:oneExploreRefreshData(data)

	-- PrintT(data, true)

    -- 刷新本地数据
    local serverCoins 		= data.coins
    local adventure 		= data.adventure
    local achievement 		= data.achievement
 	
 	if achievement then
	    -- 有改变，就替换
	    for k,v in pairs(achievement) do
	        if self.trial.achievement[k] == nil then
	            self.trial.achievement[k] = {}
	            self.trial.achievement[k].award_got_level = 0
	        end
	        self.trial.achievement[k].progress = v.progress
	    end
	end

    self.trial.explore_count = self.trial.explore_count + #serverCoins

    local awardsArr = {}
    local showIdx 	= 1

    if adventure then
	    for k,v in pairs(adventure) do
	        self.trial.adventure[tostring(k)] = v
	        if v.type == LEGION_TRIAL_ADVENTURE_TYPE.CASH then
	            local awards = v.param1
			    if awards then
				    GlobalApi:parseAwardData(awards)
	                table.insert(awardsArr, awards)
			    end
	        end
	    end
	end 

    local showWidgets 		= {}

    for i = self.nextExploreCoinId, 9 do
        local index 		= (self.nextExplorePage - 1) * 9 + i
        local aventureType 	= self.adventure_rand[tostring(index)]

        local desc 			= nil

        if aventureType <= 0 then
            desc = GlobalApi:getLocalStr('LEGION_TRIAL_DESC54')
        elseif aventureType == 3 then
            desc = self.legionTrialAdventure[aventureType].desc
        else
            desc = self.legionTrialAdventure[aventureType].desc
        end
        if desc then
            local w 		= cc.Label:createWithTTF(GlobalApi:getGeneralText(desc), 'font/gamefont.ttf', 24)

		    w:setTextColor(COLOR_TYPE.WHITE)

            if aventureType >= 1 then
                w:setTextColor(COLOR_TYPE.ORANGE)
            end

		    w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		    w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

		    table.insert(showWidgets, w)

		    if aventureType == 3 and awardsArr[showIdx] then

		    	local showAwards = awardsArr[showIdx]

		    	for i,v in ipairs(showAwards) do
					local awardTab = DisplayData:getDisplayObj(v)

					local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..awardTab:getName()..'x'..awardTab:getNum(), 'font/gamefont.ttf', 24)
					w:setTextColor(awardTab:getNameColor())
					w:enableOutline(awardTab:getNameOutlineColor(),1)
					w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

					table.insert(showWidgets, w)
				end

		    	showIdx = showIdx + 1
		   	end
        end
    end
    promptmgr:showAttributeUpdate(showWidgets)

    self:refreshStatus()
end

--  一次探索结束
function LegionTrialMainPannelNewUI:exploreEnd()
    self:refreshRightChoosePage(self.nextExplorePage, true)
    self:refreshLeftExploreTimes()
    self:refreshTodayScoreBar()
end

function LegionTrialMainPannelNewUI:stopBgAction()
	if self.scheduleId then
		GlobalApi:clearScheduler(self.scheduleId)
		self.scheduleId = nil
	end
end

function LegionTrialMainPannelNewUI:playCoinAct(icon,new_coin)
    local randTemp = {}
    for i = 1,9 do
        if i ~= new_coin then
            table.insert(randTemp,i)
        end
    end
    local icon1 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(1, 2)]].icon
    local icon2 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(3, 4)]].icon
    local icon3 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(5, 6)]].icon
    local icon4 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(7, 8)]].icon

    local act1 = cc.DelayTime:create(0.1)
    local act2 = cc.CallFunc:create(function() icon:loadTexture(icon1) end)
    local act3 = cc.DelayTime:create(0.1)
    local act4 = cc.CallFunc:create(function() icon:loadTexture(icon2) end)
    local act5 = cc.DelayTime:create(0.1)
    local act6 = cc.CallFunc:create(function() icon:loadTexture(icon3) end)
    local act7 = cc.DelayTime:create(0.1)
    local act8 = cc.CallFunc:create(function() icon:loadTexture(icon4) end)
    local act9 = cc.DelayTime:create(0.1)
    local act10 = cc.CallFunc:create(function() 
    	self:refreshRightChoosePage(self.curChoosePage,true) 
    	self:lockTouch(false)
    end)

    self:lockTouch(true)

    icon:runAction(cc.Sequence:create(act1,act2,act3,act4,act5,act6,act7,act8,act9,act10))
end

function LegionTrialMainPannelNewUI:refreshAchievement(achievement)
	if achievement then
	    for k,v in pairs(achievement) do
	        if self.trial.achievement[k] == nil then
	            self.trial.achievement[k] = {}
	            self.trial.achievement[k].award_got_level = 0
	        end
	        self.trial.achievement[k].progress = v.progress
	    end
	end
    self:refreshStatus()
end

function LegionTrialMainPannelNewUI:refreshTrialMainStatus( trialObj )
	self.trial = trialObj

	self:onShow()
end

function LegionTrialMainPannelNewUI:refreshAdventure(serverData)
    local index 	= serverData.index
    local data 		= serverData.data

    self.trial.adventure[tostring(index)] = data

    self:refreshStatus()
end

function LegionTrialMainPannelNewUI:onShowUIAniOver()
    -- GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.LEGION_TRIAL)
end

function LegionTrialMainPannelNewUI:lockTouch( enable_ )
	self.lockPl:setVisible( enable_ )
end

-------------------------------------------------- 动画逻辑部分 --------------------------------------------------
function LegionTrialMainPannelNewUI:registerAction()

    local function movementFun(armature, movementType, movementID)
        --0 开始
        --1 完成
        if movementType == 0 then
            if movementID == 'shengli' then
            	-- for _, v in ipairs(self.backImg) do
            	-- 	v:stopAllActions()
            	-- end
            end
        elseif movementType == 2 then
            if movementID == 'shengli' then
             --    for _, v in ipairs(self.backImg) do
            	-- 	v:stopAllActions()
            	-- end
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
                    self:spineAniEnd()
                end)))
            end
        end
    end

    -- 关键帧事件
    local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
        if frameEventName == "-1" then  -- skill结束事件
            self:spineAniEnd()
        end
    end

    self.spineAni:getAnimation():setMovementEventCallFunc(movementFun)
    self.spineAni:getAnimation():setFrameEventCallFunc(frameFun)
end

-- 主角spine结束
function LegionTrialMainPannelNewUI:spineAniEnd()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
        self.spineAni:getAnimation():play('idle', -1, 1)
    end)))
end

function LegionTrialMainPannelNewUI:getBombAnimation(callBack)
    local ani = GlobalApi:createLittleLossyAniByName("ui_paolong")
    ani:setName('ui_paolong')
    ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        if movementType == 1 then
            ani:removeFromParent()
            if callBack then
                callBack()
            end
        end
    end)
    ani:setLocalZOrder(9999)
    ani:setPosition(SPECIAL_POS)
    self.trialImg:addChild(ani)
    ani:getAnimation():playWithIndex(0, -1, 0)
    return ani
end

function LegionTrialMainPannelNewUI:flyCoin(callBack,isOneExplore)
     -- 硬币动画
    local coinFrame 		= self.coins[self.nextExploreCoinId]

    local coins 			= self.trial.round[tostring(self.nextExplorePage)].coins
    local coin 				= coins[tostring(self.nextExploreCoinId)]

    local coinFrameSprite 	= coinFrame:clone()
    local icon 				= coinFrameSprite:getChildByName("icon")
    local lightImg 			= coinFrameSprite:getChildByName("light_img")
    local selectImg 		= coinFrameSprite:getChildByName("select_img")

    lightImg:setVisible(true)
    icon:ignoreContentAdaptWithSize(true)
    selectImg:setVisible(false)
    icon:loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coin].icon)

    local size 				= coinFrameSprite:getContentSize()
    local desPos 			= coinFrame:convertToWorldSpace(cc.p(size.width/2, size.height/2))

    coinFrameSprite:setPosition( SPECIAL_POS )
    self.trialImg:addChild(coinFrameSprite,9999)

    if isOneExplore then
        local act1 = cc.DelayTime:create(0.2)
        local act2 = cc.CallFunc:create(
		    function ()
                if callBack then
                    callBack()
                end
		    end
	    )
        coinFrameSprite:runAction(cc.Sequence:create(act1,act2))

        local act2 = cc.MoveTo:create(0.3, desPos)
        local act3 = cc.ScaleTo:create(0.1, 1.1)
        local act4 = cc.ScaleTo:create(0.1, 0.8)
        local act4 = cc.FadeOut:create(0.1)
	    local act5 = cc.CallFunc:create(
		    function ()
                coinFrameSprite:removeFromParent()
                coinFrame:getChildByName('icon'):loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coin].icon)
		    end
	    )
	    coinFrameSprite:runAction(cc.Sequence:create(act2, act3,act4,act5))
    else
        local act1 = cc.DelayTime:create(0.5)
        local act2 = cc.MoveTo:create(0.3, desPos)
        local act3 = cc.ScaleTo:create(0.2, 1.1)
        local act4 = cc.ScaleTo:create(0.2, 0.8)
        local act4 = cc.FadeOut:create(0.2)
	    local act5 = cc.CallFunc:create(
		    function ()
                coinFrameSprite:removeFromParent()
                if callBack then
                    callBack()
                end
		    end
	    )
	    coinFrameSprite:runAction(cc.Sequence:create(act1, act2, act3,act4,act5))
    end
end

return LegionTrialMainPannelNewUI