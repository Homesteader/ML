-- 文件：秘境矿洞奇遇
-- 创建：zzx
-- 日期：2017-12-06

local LegionTrialAdventurePannelNewUI 	= class("LegionTrialAdventurePannelNewUI", BaseUI)
local ClassItemCell 					= require('script/app/global/itemcell')

local function ConvertTime(time)
	local h 			= math.floor(time / 3600)
	time 				= time % 3600
	local m 			= math.floor(time / 60)
	local s 			= time % 60

	return h, m, s
end

function LegionTrialAdventurePannelNewUI:ctor(trial,index)
    self.uiIndex 			= GAME_UI.UI_LEGION_TRIAL_ADVENTURE_NEW_PANNEL

    self.trial 				= trial
    self.index 				= index

    self:initData()
end

function LegionTrialAdventurePannelNewUI:initData()
	self.curData 			= {}

	local nowTime 			= GlobalData:getServerTime()

	for k, v in pairs(self.trial.adventure) do
        if v.award_got == 0 and v.type ~= 3 and nowTime < v.time then
            local tab 			= {}

            tab['index'] 		= tonumber(k)
            tab['type'] 		= v['type']
            tab['time'] 		= v['time']
            tab['param1'] 		= v['param1']
            tab['param2'] 		= v['param2']
            tab['param3'] 		= v['param3']
            tab['pass'] 		= v['pass'] or 0
            tab['award_got'] 	= v['award_got'] or 0

            table.insert(self.curData,tab)
        end
    end
end

function LegionTrialAdventurePannelNewUI:init()
	local activeBgImg       = self.root:getChildByName("active_bg_img")
    local activeImg     	= activeBgImg:getChildByName("active_img")

    self:adaptUI(activeBgImg, activeImg)

    local close_btn     	= activeImg:getChildByName("close_btn")

    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialAdventurePannelUI()
        end
    end)

    local tableListView 	= activeImg:getChildByName('table_list')
    tableListView:setScrollBarEnabled(false)

    local cloneTab 			= activeImg:getChildByName('clone_tab')

    local neiBgImg 			= activeImg:getChildByName('nei_bg_img')

    local panelOne 			= neiBgImg:getChildByName('panel_1')
    local panelTwo 			= neiBgImg:getChildByName('panel_2')

    self.tableListView 		= tableListView
    self.cloneTab 			= cloneTab

    self.panelOne 			= panelOne
    self.panelTwo 			= panelTwo

    self.tabArr 			= {}
    self.curSelectIdx 		= 1

    self:initTabList()
    self:showSelectPanel()
    self:playSelectEffect()

    self.scheduleId 		= GlobalApi:interval(function(dt) self:updateTime(dt) end,0.2)
    self.newCheckTime 		= 0
end

function LegionTrialAdventurePannelNewUI:onShow()
	
end

function LegionTrialAdventurePannelNewUI:onHide()
	self:stopSchedule()

	if self.lvUp then
        self.lvUp:removeFromParent()
        self.lvUp = nil
    end

    -- LegionTrialMgr:refreshTrialMainStatus(self.trial)
end

function LegionTrialAdventurePannelNewUI:stopSchedule()
	if self.scheduleId then
		GlobalApi:clearScheduler(self.scheduleId)
		self.scheduleId = nil
	end
end

function LegionTrialAdventurePannelNewUI:initTabList()
	for k, v in pairs (self.curData) do
		local tabBtn 		= self.cloneTab:clone()

		tabBtn:setVisible(true)

		local smallIco 		= tabBtn:getChildByName('small_ico')
		local bg 			= tabBtn:getChildByName('bg')

		local timeTx 		= bg:getChildByName('time_tx')

		if v['type'] == 1 then
			smallIco:loadTexture('uires/ui_new/trial/shangren2.png')
		else
			smallIco:loadTexture('uires/ui_new/trial/guairen2.png')
		end

		local leftTime 		= v['time'] - GlobalData:getServerTime()
		local h, m, s 		= ConvertTime(leftTime)
					
		timeTx:setString(string.format('%02d:%02d:%02d', h, m, s))

		tabBtn:addClickEventListener(function ()
			self:onSelectTab( k )
		end)

		self.tableListView:pushBackCustomItem(tabBtn)

		local obj 			= {}

		obj['time'] 		= v['time']
		obj['index'] 		= k
		obj['btn'] 			= tabBtn

		table.insert(self.tabArr, obj)
	end
end

function LegionTrialAdventurePannelNewUI:updateTime( dt_ )
	for _, v in pairs (self.tabArr) do
		local tabBtn 		= v['btn']
		local time 			= v['time']

		local bg 			= tabBtn:getChildByName('bg')
		local timeTx 		= bg:getChildByName('time_tx')

		local leftTime 		= time - GlobalData:getServerTime()

		if leftTime > 0 then
			local h, m, s 		= ConvertTime(leftTime)		
			timeTx:setString(string.format('%02d:%02d:%02d', h, m, s))
		else
			timeTx:setString('00:00:00')
		end
	end

	if GlobalData:getServerTime() - self.newCheckTime > 1 then
		self.newCheckTime 	= GlobalData:getServerTime()

		self:updateNewIco()
	end
end

function LegionTrialAdventurePannelNewUI:updateNewIco()
	local nowTime 			= GlobalData:getServerTime()

	for _, v in pairs (self.tabArr) do
		local tabBtn 		= v['btn']
		local time 			= v['time']
		local index 		= v['index']

		local data 			= self.curData[index]

		local newIco 		= tabBtn:getChildByName('new_ico')
        local judge 		= false
     
        if nowTime < time and data.type == 2 then
            if data.pass == 1 then     		-- 已经通关,未领取 
                if data.award_got == 0 then
                    judge = true
                end
            else
                judge = true
            end
        end

        newIco:setVisible(judge)
	end
end

function LegionTrialAdventurePannelNewUI:playSelectEffect()
    if self.lvUp then
        self.lvUp:removeFromParent()
        self.lvUp = nil
    end

    local tabBtn 	= nil

    for _, v in pairs (self.tabArr) do
    	if v.index == self.curSelectIdx then
    		tabBtn  = v.btn
    		break
    	end
    end

    if not tabBtn then
    	logger('no find tabBtn in playSelectEffect >>>')
    	return
    end

    local bottomNode= tabBtn:getChildByName('bottom_pl')
    
    local lvUp 		= ccui.ImageView:create("uires/ui_new/trial/guang.png")

    lvUp:setPosition(cc.p(0,35))
    bottomNode:addChild(lvUp)

    local size 		= lvUp:getContentSize()
    local particle 	= cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)

    self.lvUp 		= lvUp
end

function LegionTrialAdventurePannelNewUI:onSelectTab( index_ )
	if self.curSelectIdx == index_ then
		return
	end

	self.curSelectIdx = index_

	self:showSelectPanel()
	self:playSelectEffect()
end

function LegionTrialAdventurePannelNewUI:showSelectPanel()
	local data 				= self.curData[self.curSelectIdx]

	if not data then
		logger('no data in showSelectPanel')
		return
	end

	if data['type'] == 1 then
		self.panelOne:setVisible(true)
		self.panelTwo:setVisible(false)

		self:updateSellerPl( data )
	else
		self.panelOne:setVisible(false)
		self.panelTwo:setVisible(true)

		self:updateStrangeManPl( data )
	end
end

function LegionTrialAdventurePannelNewUI:judgeTime( time_ )
	return time_ >= GlobalData:getServerTime()
end

function LegionTrialAdventurePannelNewUI:updateSellerPl( data_ )
	local dialogBg 			= self.panelOne:getChildByName('dialog_bg')

	for i = 1, 3 do
		local tx 			= dialogBg:getChildByName('tx_' .. i)
		tx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_' .. (8 + i)) )
	end

	local infoBg 			= self.panelOne:getChildByName('info_bg')

	local nameTx 			= infoBg:getChildByName('item_name_tx')
	local frameImg 			= infoBg:getChildByName('frame')

	frameImg:setVisible(false)

	local originSellDescTx 	= infoBg:getChildByName('origin_sell_desc_tx')
	local originResIco 		= infoBg:getChildByName('origin_res_ico')
	local originSellNumTx 	= infoBg:getChildByName('origin_sell_num_tx')

	local newSellDescTx 	= infoBg:getChildByName('new_sell_desc_tx')
	local newResIco 		= infoBg:getChildByName('new_res_ico')
	local newSellNumTx 		= infoBg:getChildByName('new_sell_num_tx')

	local buyBtn 			= infoBg:getChildByName('buy_btn')
	local buyBtnTx 			= buyBtn:getChildByName('ok_tx')

	local buyedTx 			= infoBg:getChildByName('buyed_tx')

	local goodsConf 		= GameData:getConfData('trialgoods')
	local confData 			= goodsConf[data_.param1][data_.param2]

	local lastPrice 		= confData.shamCost
    local nowPrice 			= confData.cost
    local award 			= confData.award

    -- 原价
    local disPlayData1 		= DisplayData:getDisplayObjs(lastPrice)[1]
   	-- 现价
    local disPlayData2 		= DisplayData:getDisplayObjs(nowPrice)[1]
    -- 道具
    local disPlayData3 		= DisplayData:getDisplayObjs(award)[1]

    nameTx:setString( disPlayData3:getName() )

    local cell 				= ClassItemCell:create(ITEM_CELL_TYPE.ITEM, disPlayData3, infoBg)
    cell.lvTx:setString('x'..disPlayData3:getNum())
    local godId 			= disPlayData3:getGodId()
    disPlayData3:setLightEffect(cell.awardBgImg)

    cell.awardBgImg:setPosition(cc.p(180, 234))

    originSellDescTx:setString( GlobalApi:getLocalStr('FWACT_ORIPRICE') .. ':' )
    originResIco:loadTexture( disPlayData1:getIcon() )
    originSellNumTx:setString( disPlayData1:getNum() )

    newSellDescTx:setString( GlobalApi:getLocalStr('FWACT_CURPRICE') .. ':' )
    newResIco:loadTexture( disPlayData2:getIcon() )
    newSellNumTx:setString( disPlayData2:getNum() )

    buyBtnTx:setString( GlobalApi:getLocalStr('BUY') )

    buyedTx:setString( GlobalApi:getLocalStr('HAD_BOUGHT') )

    if data_['award_got'] == 0 then
    	buyedTx:setVisible(false)
    	buyBtn:setVisible(true)
    else
    	buyedTx:setVisible(true)
    	buyBtn:setVisible(false)
    end

    local endTime 			= data_['time']
    local adventureIndex 	= data_['index']

    buyBtn:addTouchEventListener(function (sender, eventType)
    	if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 判断时间到了没
            if not self:judgeTime(endTime) then
            	 promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end

            local function callBack2()
                local function callBack(data)

                    local awards = data.awards
				    if awards then
					    GlobalApi:parseAwardData(awards)
					    GlobalApi:showAwardsCommon(awards,nil,nil,true)
				    end
				    local costs = data.costs
				    if costs then
					    GlobalApi:parseAwardData(costs)
				    end

				    buyedTx:setVisible(true)
    				buyBtn:setVisible(false)

                    -- 刷新数据
                    self.curData[self.curSelectIdx]['award_got'] = 1
    				self.trial.adventure[tostring(adventureIndex)]['award_got'] = 1
                end
                LegionTrialMgr:legionTrialBuyShopItemFromServer(adventureIndex,callBack)
            end

            if disPlayData2:getId() == "cash" then
                UserData:getUserObj():cost('cash',disPlayData2:getNum(),function()
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH'),disPlayData2:getNum()), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        callBack2()
                    end)
                end)
            else    -- 金币
                local userCoin = UserData:getUserObj():getCash()
                if userCoin >= disPlayData2:getNum() then
                    callBack2()
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC40'), COLOR_TYPE.RED)
                end
            end
        end
    end)
end

-- 怪人
function LegionTrialAdventurePannelNewUI:updateStrangeManPl( data_ )
	local dialogBg 			= self.panelTwo:getChildByName('dialog_bg')

	for i = 1, 3 do
		local tx 			= dialogBg:getChildByName('tx_' .. i)
		tx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_' .. (11 + i)) )
	end

	local monsterImg 		= self.panelTwo:getChildByName('monster_img')
	
	local powerBg 			= self.panelTwo:getChildByName('power_bg')

	local powerIco 			= powerBg:getChildByName('ico')
	local powerTx 			= powerBg:getChildByName('tx')

	local infoBg 			= self.panelTwo:getChildByName('info_bg')

	local titleBg 			= infoBg:getChildByName('title_bg')
	local titleTx 			= titleBg:getChildByName('title_tx')

	local notice1Tx 		= infoBg:getChildByName('notice_1_tx')

	local resetDescTx 		= infoBg:getChildByName('reset_desc_tx')
	local resetNumTx 		= infoBg:getChildByName('reset_num_tx')

	local starBg 			= infoBg:getChildByName('star_bg')

	local starDescTx 		= starBg:getChildByName('star_desc_tx')

	local resetBtn 			= starBg:getChildByName('reset_btn')
	local resetBtnTx 		= resetBtn:getChildByName('ok_tx')

	local rewardBg 			= infoBg:getChildByName('reward_bg')

	local rewardDescTx 		= rewardBg:getChildByName('reward_desc_tx')
	local scoreDescTx 		= rewardBg:getChildByName('score_desc_tx')

	local scoreBg 			= rewardBg:getChildByName('score_bg')
	local scoreNumTx 		= scoreBg:getChildByName('score_num_tx')

	local oneKeyBtn 		= infoBg:getChildByName('onekey_challenge_btn')
	local oneKeyBtnTx 		= oneKeyBtn:getChildByName('tx')

	local challengeBtn 		= infoBg:getChildByName('challenge_btn')
	local challengeBtnTx 	= challengeBtn:getChildByName('tx')

	local getBtn 			= infoBg:getChildByName('get_btn')
	local getBtnTx 			= getBtn:getChildByName('tx')

	local getedTx 			= infoBg:getChildByName('geted_tx')

	titleTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_15') )
	notice1Tx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_16') )
	-- resetDescTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_17') )
	starDescTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_18') )
	rewardDescTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_19') )
	scoreDescTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_20') )
	resetBtnTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_21') )
	oneKeyBtnTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_22') )
	challengeBtnTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_23') )
	getedTx:setString( GlobalApi:getLocalStr('LEGION_TRIAL_DESC50') )
	getBtnTx:setString( GlobalApi:getLocalStr('STR_GET') )

	powerTx:setString( data_['param1'] )

	-- 重置消耗
	local resetCount 		= data_['param3']
	local resetCost 		= GlobalApi:GetCostByType('trialCrackpotReset', resetCount + 1)

	if resetCost > 0 then
		resetDescTx:setPositionX( 370 )
		resetDescTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_17') )
		resetNumTx:setVisible(true)
		resetNumTx:setString( resetCost )
	else
		resetDescTx:setPositionX( 378 )
		resetDescTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_24') )
		resetNumTx:setVisible(false)
	end

	-- 星级
	local curStar 			= math.max(data_['param2'], 1)

	for i = 1, 5 do
		local starIco 		= starBg:getChildByName('star_' .. i)
		starIco:setVisible( i <= curStar )
	end

	local baseConf 			= GameData:getConfData('trialbaseconfig')
	local curBaseConf 		= baseConf[LegionTrialMgr:calcTrialLv(self.trial.join_level)]

	local rewardScore 		= curBaseConf['crackpotAwardIntegral'][curStar]
	local rewards 			= curBaseConf['crackpotAward' .. curStar]

	-- 奇遇奖励(跟星级挂钩)
	for i = 1, 2 do
		local oldItem 		= rewardBg:getChildByName('reward_item_' .. i)
		if oldItem then
			oldItem:removeFromParent()
		end
	end

	local displayAwards 	= DisplayData:getDisplayObjs(rewards)

	for i, v in pairs(displayAwards) do
		local awardCell 	= ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, rewardBg)

		awardCell.awardBgImg:setName('reward_item_' .. i)
        awardCell.awardBgImg:setPosition(cc.p(45 + (i - 1) * 70, 50))
        awardCell.awardBgImg:setScale(0.7)
	end

	-- 奇遇积分
	scoreNumTx:setString( rewardScore .. GlobalApi:getLocalStr_new('STR_TRAIL_DESC_25') )

	local pass 				= data_['pass']
	local awardGot 			= data_['award_got']

	if pass == 1 then    			-- 已经通关
        if awardGot == 1 then 		-- 已经领取
        	oneKeyBtn:setVisible(false)
        	challengeBtn:setVisible(false)
        	getBtn:setVisible(false)
        	getedTx:setVisible(true)
        else
            oneKeyBtn:setVisible(false)
        	challengeBtn:setVisible(false)
        	getedTx:setVisible(false)
        	getBtn:setVisible(true)
        end
        ShaderMgr:setGrayForWidget(resetBtn)
        resetBtn:setTouchEnabled(false)

        GlobalApi:setCommonBtnTxt( resetBtnTx, 'orange', false )
    else
       	oneKeyBtn:setVisible(true)
    	challengeBtn:setVisible(true)
    	getedTx:setVisible(false)
    	getBtn:setVisible(false)
    	ShaderMgr:restoreWidgetDefaultShader(resetBtn)
        resetBtn:setTouchEnabled(true)

        GlobalApi:setCommonBtnTxt( resetBtnTx, 'orange', true )
    end

	local endTime 			= data_['time']
    local adventureIndex 	= data_['index']

    -- 重置
	resetBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

        	-- 判断时间到了没
            if not self:judgeTime(endTime) then
            	 promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end

            self:doReset( adventureIndex )
        end
	end)

	-- 挑战
	challengeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            -- 判断时间到了没
            if not self:judgeTime(endTime) then
            	 promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end

            self:doChallenge( adventureIndex )
        end
    end)

	-- 一键挑战
	oneKeyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            -- 判断时间到了没
            if not self:judgeTime(endTime) then
            	 promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end

            self:doOneKeyChallenge( adventureIndex )
        end
    end)

    -- 领奖
	getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:doGetReward( adventureIndex )
        end
    end)
end

function LegionTrialAdventurePannelNewUI:doReset( index_ )
	LegionTrialMgr:legionTrialResetMonsterStarFromServer(index_, function (jsonData)
		if jsonData.costs then
            GlobalApi:parseAwardData(jsonData.costs)
        end

		if jsonData.new_star then
			self.curData[self.curSelectIdx]['param2'] = jsonData.new_star
			self.trial.adventure[tostring(index_)]['param2'] = jsonData.new_star
		end

		self:showSelectPanel()
	end)
end

function LegionTrialAdventurePannelNewUI:doChallenge( index_ )
    LegionTrialMgr:legionTrialStartChallengeMonsterFromServer(index_,function (jsonData)

    	local customObj 		= {}
        customObj.trial_robot 	= jsonData.trial_robot
        customObj.index 		= index_

        BattleMgr:playBattle(BATTLE_TYPE.TRIAL, customObj, function ()
            MainSceneMgr:showMainCity(function()                                   
                LegionMgr:showMainUI(function ()
                    LegionTrialMgr:showLegionTrialMainPannelUI(index_)
                end)
            end, nil, GAME_UI.UI_LEGION_TRIAL_MAIN_NEW_PANNEL)
        end)
    end)
end

function LegionTrialAdventurePannelNewUI:doOneKeyChallenge( index_ )
	LegionTrialMgr:legionTrialStartChallengeMonsterFromServer(index_,function (jsonData)

        local customObj 		= {}
        customObj.trial_robot 	= jsonData.trial_robot
        customObj.index 		= index_
        -- customObj.skipFight 	= true
        customObj.mercenaries	= {}
        customObj.node 			= self.root
        customObj.rand1 		= math.random(10000)
        customObj.rand2 		= math.random(10000)

        BattleMgr:showBattleCountDown(BATTLE_TYPE.TRIAL, customObj, function (reportField, sig)
            local report 		= reportField.totalReport
            local isWin 		= report.isWin
            local starNum 		= 0

            if isWin then
                local costTime = math.floor(reportField.time)
                if costTime >= 0 and costTime <= 60 then
                    starNum = 3
                elseif costTime > 60 and costTime <= 90 then
                    starNum = 2
                elseif costTime >= 91 then
                    starNum = 1
                end
            end

            local damageInfo 	= reportField:getDamageInfo()

            local args = {
                star 		= starNum,
                sig 		= sig,
                index 		= customObj.index,
                autofight 	= 1
            }

            LegionTrialMgr:legionTrialFightFromServer(args, function (jsonObj)
            	local code 	= jsonObj.code
                if code == 0 then

                	local lastLv 	= UserData:getUserObj():getLv()
				
					local awards 	= jsonObj.data.awards
					local costs 	= jsonObj.data.costs

					if awards then
						GlobalApi:parseAwardData(awards)
					end
					if costs then
						GlobalApi:parseAwardData(costs)
					end

					local displayAwards = DisplayData:getDisplayObjs(awards)
	                local kingLvUpData 	= {}
	                kingLvUpData.lastLv = lastLv
	                kingLvUpData.nowLv 	= UserData:getUserObj():getLv()
					BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)

					-- 刷新数据
					self.curData[self.curSelectIdx]['pass'] = 1
					self.trial.adventure[tostring(index_)]['pass'] = 1

                    self:showSelectPanel()                 
                end
            end)
        end)
    end)
end

function LegionTrialAdventurePannelNewUI:doGetReward( index_ )
	LegionTrialMgr:legionTrialGetMonsterAwardFromServer(index_, function (jsonData)

		local awards = jsonData.awards
	    if awards then
		    GlobalApi:parseAwardData(awards)
		    GlobalApi:showAwardsCommon(awards,nil,nil,true)
	    end
	    local costs = jsonData.costs
	    if costs then
		    GlobalApi:parseAwardData(costs)
	    end
	    if jsonData.daily_score then
	    	self.trial.daily_score = jsonData.daily_score
	    end
	    if jsonData.week_score then
	    	self.trial.week_score = jsonData.week_score
	    end

        -- 刷新数据
        self.curData[self.curSelectIdx]['award_got'] = 1
		self.trial.adventure[tostring(index_)]['award_got'] = 1

		self:showSelectPanel()
    end)
end

return LegionTrialAdventurePannelNewUI