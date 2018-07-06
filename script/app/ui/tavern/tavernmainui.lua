local TavernUI = class("TavernUI", BaseUI)

function TavernUI:ctor(heroId,typeId)
	self.uiIndex = GAME_UI.UI_TAVERN
	self.heroId = heroId
	self.typeId = typeId or 1
end

function TavernUI:setUIBackInfo()

    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_TAVERN), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TavernMgr:hideTavernMain()
        end
    end,1)

end

function TavernUI:onShow()
    self:setUIBackInfo()
end

function TavernUI:init()

	local award = {
		"card",
	}

	self:setUIBackInfo()

	local bgimg = self.root:getChildByName("bg_img")
	local bg = bgimg:getChildByName('bg')
	self:adaptUI(bgimg, bg)
	
	self.heroPL = bg:getChildByName("hero_pl")
	
	--图鉴
	local book_btn = bg:getChildByName("book_btn")
	local btnTx = book_btn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("TAVERN_BTN_TX3"))
	book_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ChartMgr:showChartMain(1)
        end
    end)

	--刷新
	local refreshCost = GlobalApi:toAwards(GlobalApi:getGlobalValue_new("tavernRefreshCost"))
	local refreshCostObj = DisplayData:getDisplayObj(refreshCost[1])
	local updateBtn = self.heroPL:getChildByName("update_btn")
	local btnTx = updateBtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("TAVERN_BTN_TX1"))
	updateBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	self:sendRefreshHotHero(refreshCostObj)
        end
    end)
	
	--兑换
	local limitheroCfg = GameData:getConfData("tavernlimithero")[self.typeId]
	local exchangeBtn = self.heroPL:getChildByName("exchange_btn")
	local btnTx = exchangeBtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("TAVERN_BTN_TX2"))
	exchangeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

        	local limitheroCfg = GameData:getConfData("tavernlimithero")[self.typeId]
			local costdisplayObj = DisplayData:getDisplayObj(limitheroCfg.exchangeCost[1])
			self:sendExchangeHotHero(costdisplayObj)
        end
    end)
    
    self.recruitbg = {}
	local tavernCfg = GameData:getConfData("tavern")
	for i=1,2 do

		local name =  GlobalApi:getGeneralText(tavernCfg[i].name)
		local recruitbg = bg:getChildByName("recruit_"..i)
		local nameTx = recruitbg:getChildByName("name_tx")
		nameTx:setString(name)

		recruitbg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            if i == RecruitType.normal then
	            	TavernMgr:showTavernNormalRecruitUI()
	            elseif i == RecruitType.high then
	            	TavernMgr:showTavernHighRecruitUI()
	            end
	        end
	    end)
	    self.recruitbg[i] = recruitbg
	end

	self:updateNormalRecruit()
	self:updateHighRecruit()
	self:updateHotHero()
end

function TavernUI:sendRefreshHotHero(refreshCostObj)
	
	if not refreshCostObj then
		return
	end

	local ownWine = refreshCostObj:getOwnNum()
    local cost = refreshCostObj:getNum()
    if ownWine < cost then
		local tip = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),refreshCostObj:getName())
		promptmgr:showSystenHint(tip, COLOR_TYPE.RED)
		return
	end

	
	local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0.5, 0.5))
    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("COMMON_STR_COST"), 18, COLOR_TYPE.WHITE1)
    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt1:clearShadow()
    local rt2 = xx.RichTextImage:create(refreshCostObj:getIcon())
    local rt3 = xx.RichTextLabel:create(refreshCostObj:getNum(), 18, COLOR_TYPE.WHITE1)
    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt3:clearShadow()
    local rt4 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO18"), 18,COLOR_TYPE.WHITE1)
	rt4:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	rt4:clearShadow()
	rt:addElement(rt1)
    rt:addElement(rt2)
    rt:addElement(rt3)
    rt:addElement(rt4)
    rt:setAlignment("middle")
    rt:setPosition(cc.p(195,160))
    rt:setContentSize(cc.size(400, 30))
	rt:format(true)

	promptmgr:showMessageBox(rt,MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()
    	MessageMgr:sendPost('refresh_hero','tavern',json.encode({}),function(response)
			local code = response.code
	        local data = response.data
            if code == 0 then
                local costs = data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				promptmgr:showSystenHint(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO4"), COLOR_TYPE.GREEN)
				self.heroId = data.hid
				self.typeId = data.id or 1
				UserData:getUserObj():setTavenHotTime(data.refresh_time)
				UserData:getUserObj():setTavenHotHero(data.hid)
				self:updateHotHero()
            end
        end)
    end)
end

function TavernUI:sendExchangeHotHero(costdisplayObj)

	if not costdisplayObj then
		return
	end

	local heroBaseConf,combatConf = GlobalApi:getHeroConf(self.heroId)
	if not heroBaseConf or not combatConf then
		return
	end

	local costNum = costdisplayObj:getNum()
	local own = costdisplayObj:getOwnNum()
	if own < costNum then
		local tip = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),costdisplayObj:getName())
		promptmgr:showSystenHint(tip, COLOR_TYPE.RED)
		return
	end

	local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0.5, 0.5))
    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("COMMON_STR_COST1"), 18, COLOR_TYPE.WHITE1)
    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt1:clearShadow()
    local rt2 = xx.RichTextImage:create(costdisplayObj:getIcon())
    local rt3 = xx.RichTextLabel:create(costdisplayObj:getNum(), 18, COLOR_TYPE.WHITE1)
    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt3:clearShadow()
    local rt4 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO19"), 18,COLOR_TYPE.WHITE1)
	rt4:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	rt4:clearShadow()
	local rt5 = xx.RichTextLabel:create(heroBaseConf.heroName, 20,COLOR_QUALITY[combatConf.quality])
    rt5:setStroke(COLOROUTLINE_QUALITY[combatConf.quality], 2)
    rt5:clearShadow()
    local rt6 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("COMMON_STR_QUE"), 18,COLOR_TYPE.WHITE1)
	rt6:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	rt6:clearShadow()
	rt:addElement(rt1)
    rt:addElement(rt2)
    rt:addElement(rt3)
    rt:addElement(rt4)
    rt:addElement(rt5)
    rt:setAlignment("middle")
    rt:setPosition(cc.p(195,160))
    rt:setContentSize(cc.size(400, 30))
	rt:format(true)

	promptmgr:showMessageBox(rt,MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()
    	MessageMgr:sendPost('exchange_hero','tavern',json.encode({}),function(response)
			local code = response.code
	        local data = response.data
            if code == 0 then
                local costs = data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end

				local function callback()
					self.heroId = data.hid
					self.typeId = data.id or 1
					UserData:getUserObj():setTavenHotHero(data.hid)
					self:updateHotHero()
				end
				local awards = data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,callback,true) 
                end
            end
        end)
    end)
end

function TavernUI:update(recruitType)
	if RecruitType.normal == recruitType then
		self:updateNormalRecruit()
	elseif RecruitType.high == recruitType then
		self:updateHighRecruit()
	end
end

--刷新普通招募
function TavernUI:updateNormalRecruit()

	local cost_bg = self.recruitbg[RecruitType.normal]:getChildByName("cost_bg")
	local icon = cost_bg:getChildByName("icon")
	local costTx = cost_bg:getChildByName("text")
	local newImg = cost_bg:getChildByName("new_img")

	local totalFreeCount = GlobalApi:getGlobalValue_new("tavernNormalFreeTimes")
	local normalFreeCount = UserData:getUserObj():getTavenNormalFree()
	local tavernCfg = GameData:getConfData("tavern")[RecruitType.normal]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])  
	if not costTokenObj or not costMoneyObj then
		return
	end

	local state_tx = self.recruitbg[RecruitType.normal]:getChildByName("state_tx")
	state_tx:setString('')
	local nextFreeTime = UserData:getUserObj():getTavenNextNormalTime()
	local remainTime =  nextFreeTime - GlobalData:getServerTime()
	local remainFreeCount = totalFreeCount - normalFreeCount
	local isFree = remainFreeCount > 0 and remainTime <=0
	newImg:setVisible(isFree)
	if not isFree then
		local str = GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO6")
		if remainTime >0 then
			self:timeoutCallback(state_tx,nextFreeTime,str,CDTXTYPE.BACK,20)
		end
		local ownTokenNum = costTokenObj:getOwnNum()
		local ownMoney = costMoneyObj:getOwnNum()
		if ownTokenNum >= 1 then
			icon:loadTexture(costTokenObj:getIcon())
			costTx:setString(costTokenObj:getNum())
		else
			icon:loadTexture(costMoneyObj:getIcon())
			costTx:setString(costMoneyObj:getNum())
		end
	else
		icon:loadTexture(costTokenObj:getIcon())
		costTx:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO5"))
	end

	local goldCallCnt = UserData:getUserObj():getTavenGoldCallCnt()
	local vip = UserData:getUserObj():getVip()
	local vipConf = GameData:getConfData("vip")[tostring(vip)]
	local strTotal = "/"..vipConf.tavernNormalLimit
	local remainCnt = vipConf.tavernNormalLimit - goldCallCnt
	if remainCnt < 0 then
		remainCnt = 0
	end
	local infoTx = self.recruitbg[RecruitType.normal]:getChildByName("info")
	if not self.normalRt then
		local rt = xx.RichText:create()
	    rt:setAnchorPoint(cc.p(0, 0.5))
	    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO7"), 20, COLOR_TYPE.WHITE1)
	    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt1:clearShadow()
	    local rt2 = xx.RichTextLabel:create(remainCnt, 20,cc.c4b(255,232,43,255))
	    rt2:setStroke(cc.c4b(94,46,16,255), 2)
	    rt2:clearShadow()
	    local rt3 = xx.RichTextLabel:create(strTotal, 20,COLOR_TYPE.WHITE1)
	    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt3:clearShadow()
		rt:addElement(rt1)
	    rt:addElement(rt2)
	    rt:addElement(rt3)
	    rt:setAlignment("left")
	    rt:setPosition(cc.p(0,0))
	    rt:setContentSize(cc.size(400, 30))
		rt:format(true)
		infoTx:addChild(rt)
		self.normalRt = {rt = rt, rt1 = rt1, rt2 = rt2, rt3 = rt3}
	else
		self.normalRt.rt2:setString(remainCnt)
		self.normalRt.rt:format(true)
	end	
end

--刷新豪华招募
function TavernUI:updateHighRecruit()

	local cost_bg = self.recruitbg[RecruitType.high]:getChildByName("cost_bg")
	local icon = cost_bg:getChildByName("icon")
	local costTx = cost_bg:getChildByName("text")
	local newImg = cost_bg:getChildByName("new_img")

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])  
	if not costTokenObj or not costMoneyObj then
		return
	end

	local state_tx = self.recruitbg[RecruitType.high]:getChildByName("state_tx")
	state_tx:setString('')
	local nextFreeTime = UserData:getUserObj():getTavenNextHighTime()
	local remainTime =  nextFreeTime - GlobalData:getServerTime()

	local isFree = false
	if remainTime <= 0 then
		isFree = true
	end

	newImg:setVisible(isFree)
	if not isFree then
		local str = GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO6")
		self:timeoutCallback(state_tx,nextFreeTime,str,CDTXTYPE.BACK,20)
		local ownTokenNum = costTokenObj:getOwnNum()
		local ownMoney = costMoneyObj:getOwnNum()
		if ownTokenNum >= 1 then
			icon:loadTexture(costTokenObj:getIcon())
			costTx:setString(costTokenObj:getNum())
		else
			icon:loadTexture(costMoneyObj:getIcon())
			costTx:setString(costMoneyObj:getNum())
		end
	else
		icon:loadTexture(costTokenObj:getIcon())
		costTx:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO5"))
	end

	local specialNeedCnt = tavernCfg.specialNeed
	local allCnt = UserData:getUserObj():getTavenHighCallCnt()
	if specialNeedCnt ~= 0 then
		local cnt = specialNeedCnt - allCnt%specialNeedCnt
		local infoTx = self.recruitbg[RecruitType.high]:getChildByName("info")
		if not self.highRt then
			local rt = xx.RichText:create()
		    rt:setAnchorPoint(cc.p(0, 0.5))
		    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO8"), 20, COLOR_TYPE.WHITE1)
		    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
		    rt1:clearShadow()
		    local rt2 = xx.RichTextLabel:create(cnt, 20,cc.c4b(255,232,43,255))
		    rt2:setStroke(cc.c4b(94,46,16,255), 2)
		    rt2:clearShadow()
		    local rt3 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO9"), 20,COLOR_TYPE.WHITE1)
		    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
		    rt3:clearShadow()
		    local rt4 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO10"), 20,cc.c4b(255,104,30,255))
		    rt4:setStroke(cc.c4b(85,39,12,255), 2)
		    rt4:clearShadow()
			rt:addElement(rt1)
		    rt:addElement(rt2)
		    rt:addElement(rt3)
		    rt:addElement(rt4)
		    rt:setAlignment("left")
		    rt:setPosition(cc.p(0,0))
		    rt:setContentSize(cc.size(400, 30))
			rt:format(true)
			infoTx:addChild(rt)
			self.highRt = {rt = rt, rt1 = rt1, rt2 = rt2, rt3 = rt3, rt4 = rt4}
		else
			self.highRt.rt2:setString(cnt)
			self.highRt.rt:format(true)
		end
	end
end

function TavernUI:updateHotHero()

	local talkimg = self.heroPL:getChildByName("talk_img")
	local nameTx = talkimg:getChildByName("name_tx")
	local updateTx = talkimg:getChildByName("update_tx")
	self:showTalkTx(nameTx)

	local refreshTotalTime = GlobalApi:getGlobalValue_new("tavernExchangeRefreshInterval")
	local lastRefreshTime = UserData:getUserObj():getTavenHotTime()
	local nextRefreshTime = lastRefreshTime + refreshTotalTime * 3600
	local str = GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO2")
	self:timeoutCallback(updateTx,nextRefreshTime,str,CDTXTYPE.FRONT,16)

	--刷新消耗
	local refreshCost = GlobalApi:toAwards(GlobalApi:getGlobalValue_new("tavernRefreshCost"))
	local refreshCostObj = DisplayData:getDisplayObj(refreshCost[1])
	local updateCostBg = self.heroPL:getChildByName("res_bg1") 
	local icon = updateCostBg:getChildByName("icon")
	local updateTx = updateCostBg:getChildByName("text")
	if refreshCostObj then
		icon:loadTexture(refreshCostObj:getIcon())
		updateTx:setString(refreshCostObj:getNum())
	end

	--兑换消耗
	local limitheroCfg = GameData:getConfData("tavernlimithero")[self.typeId]
	local costdisplayObj = DisplayData:getDisplayObj(limitheroCfg.exchangeCost[1])
	local exchangeTipbg = self.heroPL:getChildByName("text_bg")
	local exchangeTipTx = exchangeTipbg:getChildByName("text")
    local exchangeCostBg = self.heroPL:getChildByName("res_bg2") 
	local icon = exchangeCostBg:getChildByName("icon")
	local exchangeTx = exchangeCostBg:getChildByName("text")
	if costdisplayObj then
		local costNum = costdisplayObj:getNum()
		local own = costdisplayObj:getOwnNum()
		icon:loadTexture(costdisplayObj:getIcon())
		exchangeTx:setString(costNum)
		exchangeTipTx:setString(string.format(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO3"),costdisplayObj:getName()))
	end

	--热点英雄
	local _,_,modelConf = GlobalApi:getHeroConf(self.heroId)
	if modelConf then
		local x,y = exchangeTipbg:getPosition()
		local spineAni = self.heroPL:getChildByName("mode")
		if spineAni then
			spineAni:removeFromParent()
		end
		spineAni = GlobalApi:createLittleLossyAniByName(modelConf.modelUrl.."_display")
        spineAni:setAnchorPoint(cc.p(0.5, 0))
        spineAni:setPosition(cc.p(x,y+20))
        spineAni:getAnimation():play('idle', -1, 1)
        spineAni:setName('mode')
        self.heroPL:addChild(spineAni)
	end
end

function TavernUI:showTalkTx(nameTx)

	local heroBaseConf,combatConf = GlobalApi:getHeroConf(self.heroId)
	if not heroBaseConf or not combatConf then
		return
	end

	if not self.talkText then
		local nameRt = xx.RichText:create()
	    nameRt:setAnchorPoint(cc.p(0, 0.5))
	    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO1"), 20, COLOR_TYPE.WHITE1)
	    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt1:clearShadow()
	    
	    local rt2 = xx.RichTextLabel:create(" "..heroBaseConf.heroName, 20,COLOR_QUALITY[combatConf.quality])
	    rt2:setStroke(COLOROUTLINE_QUALITY[combatConf.quality], 2)
	    rt2:clearShadow()
		nameRt:addElement(rt1)
	    nameRt:addElement(rt2)
	    nameRt:setAlignment("left")
	    nameRt:setPosition(cc.p(0,0))
	    nameRt:setContentSize(cc.size(400, 30))
		nameRt:format(true)
		nameTx:addChild(nameRt)
		self.talkText = {nameRt = nameRt, rt1 = rt1, rt2 = rt2}
	else
		self.talkText.rt1:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO1")) 
		self.talkText.rt2:setString(" "..heroBaseConf.heroName)
		self.talkText.rt2:setColor(COLOR_QUALITY[combatConf.quality])
		self.talkText.rt2:setStroke(COLOROUTLINE_QUALITY[combatConf.quality], 2)
		self.talkText.nameRt:format(true)
	end
	
end

function TavernUI:timeoutCallback(parent,time,str,cdType,fintSize)

	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	if diffTime < 0 then
		return
	end
	local node = cc.Node:create()
	node:setTag(9527)
	node:setAnchorPoint(cc.p(0,0.5)) 
	node:setPosition(cc.p(64,0))
	parent:removeChildByTag(9527)
	parent:addChild(node)

	Utils:createCDLabel(node,diffTime,COLOR_TYPE.GREEN1,COLOROUTLINE_TYPE.GREEN1,cdType,str,COLOR_TYPE.WHITE1,COLOROUTLINE_TYPE.OFFWHITE1,fintSize,function ()	
		parent:removeAllChildren()
	end)
end

return TavernUI