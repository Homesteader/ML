local TavernHighRecruitUI = class("TavernHighRecruitUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TavernHighRecruitUI:ctor()
	self.uiIndex = GAME_UI.UI_TAVEN_HIGH_PANNEL
end

function TavernHighRecruitUI:setUIBackInfo()

    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_TAVEN_HIGH_PANNEL), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TavernMgr:hideHighRecruitUI()
        end
    end,1)

end

function TavernHighRecruitUI:onShow()
    self:setUIBackInfo()
end

function TavernHighRecruitUI:init()

	self:setUIBackInfo()

	local bgimg = self.root:getChildByName("bg_img")
	local bg = bgimg:getChildByName('bg')
	self:adaptUI(bgimg, bg)
	
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

	--特殊招募次数
	self.infoTx = bg:getChildByName("info_tex")
	self:updateRecruitCnt()

	self.recruitbg = {}
	for i=1,3 do


		local textStr = "TAVERN_MAIN_INFO11"
		if i == 2 then
			textStr = "TAVERN_MAIN_INFO12"
		elseif i== 3 then
			textStr = "TAVERN_MAIN_INFO16"
		end
		
		local recruitbg = bg:getChildByName("recruit_"..i)
		local nameTx = recruitbg:getChildByName("name_tx")
		nameTx:setString(GlobalApi:getLocalStr_new(textStr))

		recruitbg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then

	        	if i == 1 then
	        		self:sendRecruitOneMsg()
	        	elseif i == 2 then
	        		self:sendRecruitTenMsg()
	        	elseif i == 3 then
	        		self:sendRecruitFriendshipMsg()
	        	end
	        end
	    end)
	    self.recruitbg[i] = recruitbg
	end

	--显示掉落信息
	self.dropbg = bg:getChildByName("drop_pl")
	self:updateDropInfo()

	--招募信息
	self:updateRecruitOne()
	self:updateRecruitTen()
	self:updateRecruitFriendship()
end

function TavernHighRecruitUI:updateDropInfo()

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local name =  GlobalApi:getGeneralText(tavernCfg.name)
	local dropNameTx = self.dropbg:getChildByName("drop_tip")
	local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(name, 20,cc.c4b(255,140,50,255))
    rt1:setStroke(cc.c4b(102,55,18,255), 2)
    rt1:clearShadow()
    local rt2 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO14"), 20, COLOR_TYPE.WHITE1)
    rt2:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt2:clearShadow()
    rt:addElement(rt1)
	rt:addElement(rt2)
	rt:setAlignment("left")
    rt:setPosition(cc.p(0,0))
    rt:setContentSize(cc.size(300, 30))
	rt:format(true)
	dropNameTx:addChild(rt)

	local dropItemTab = {}
	local fixCount = #tavernCfg.fixedAward
	--固定掉落
	for i=1,#tavernCfg.fixedAward do
		table.insert(dropItemTab, tavernCfg.fixedAward[i])
	end

	for i=1,#tavernCfg.cycleBasicAward1 do
		table.insert(dropItemTab, tavernCfg.cycleBasicAward1[i])
	end

	for i=1,3 do
		local cycleAward = tavernCfg["cycleAward"..i]
		for j=1,#cycleAward do
			table.insert(dropItemTab, cycleAward[j])
		end
	end

	for i=1,#dropItemTab do
		local displayObj = DisplayData:getDisplayObj(dropItemTab[i])
		if displayObj then
			local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayObj, self.dropbg)
			cell.awardBgImg:setPosition(cc.p(285+(i-1)*95, 74))
			cell.awardBgImg:setScale(0.9)
			if i <= fixCount then
				cell.cornerFallImg:setVisible(true)
				cell.cornerFallTx:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO15"))
			end
		end
	end
end

function TavernHighRecruitUI:updateRecruitCnt()

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local specialNeedCnt = tavernCfg.specialNeed
	local allCnt = UserData:getUserObj():getTavenHighCallCnt()
	if specialNeedCnt ~= 0 then
		local cnt = specialNeedCnt - allCnt%specialNeedCnt
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
			self.infoTx:addChild(rt)
			self.highRt = {rt = rt, rt1 = rt1, rt2 = rt2, rt3 = rt3, rt4 = rt4}
		else
			self.highRt.rt2:setString(cnt)
			self.highRt.rt:format(true)
		end
	end
end

--刷新普通招募(一次)
function TavernHighRecruitUI:updateRecruitOne()

	local cost_bg = self.recruitbg[1]:getChildByName("cost_bg")
	local icon = cost_bg:getChildByName("icon")
	local costTx = cost_bg:getChildByName("text")
	local newImg = cost_bg:getChildByName("new_img")

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])  
	if not costTokenObj or not costMoneyObj then
		return
	end

	local state_tx = self.recruitbg[1]:getChildByName("state_tx")
	state_tx:setString('')
	local nextFreeTime = UserData:getUserObj():getTavenNextHighTime()
	local remainTime =  nextFreeTime - GlobalData:getServerTime()

	self.isFree = false
	if remainTime <= 0 then
		self.isFree = true
	end

	newImg:setVisible(self.isFree)
	if not self.isFree then
		local str = GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO6")
		if remainTime > 0 then
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
end

--刷新普通招募(十次)
function TavernHighRecruitUI:updateRecruitTen()

	local cost_bg = self.recruitbg[2]:getChildByName("cost_bg")
	local icon = cost_bg:getChildByName("icon")
	local costTx = cost_bg:getChildByName("text")
	local newImg = cost_bg:getChildByName("new_img")

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])  
	if not costTokenObj or not costMoneyObj then
		return
	end

	local state_tx = self.recruitbg[2]:getChildByName("state_tx")
	state_tx:setString('')
	
	if not self.tenRt then
		local rt = xx.RichText:create()
	    rt:setAnchorPoint(cc.p(0, 0.5))
	    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO15"), 20,cc.c4b(253,232,43,255))
	    rt1:setStroke(cc.c4b(94,46,16,255), 2)
	    rt1:clearShadow()
	    local rt2 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO10"), 20, cc.c4b(255,104,30,255))
	    rt2:setStroke(cc.c4b(85,39,12,255), 2)
	    rt2:clearShadow()
	    rt:addElement(rt1)
		rt:addElement(rt2)
		rt:setAlignment("left")
	    rt:setPosition(cc.p(0,0))
	    rt:setContentSize(cc.size(300, 30))
		state_tx:addChild(rt)
		self.tenRt = {rt = rt, rt1 = rt1, rt2 = rt2}
	else
		self.tenRt.rt1:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO15"))
		self.tenRt.rt2:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO10"))
	end
	self.tenRt.rt:format(true)

	local ownTokenNum = costTokenObj:getOwnNum()
	local costTokenNum = costTokenObj:getNum()
	local ownMoney = costMoneyObj:getOwnNum()
	local costMoney = costMoneyObj:getNum()*tavernCfg.tenDiscount
	if ownTokenNum >= costTokenNum*10 then
		icon:loadTexture(costTokenObj:getIcon())
		costTx:setString(costTokenNum*10)
		newImg:setVisible(true)
	else
		icon:loadTexture(costMoneyObj:getIcon())
		costTx:setString(costMoney)
		newImg:setVisible(ownMoney>=costMoney)
	end
end

--友情招募
function TavernHighRecruitUI:updateRecruitFriendship()

	local frindshipCost = GlobalApi:toAwards(GlobalApi:getGlobalValue_new("tavernAdvancedCost"))
	local frindshipCostObj = DisplayData:getDisplayObj(frindshipCost[1])

	local cost_bg = self.recruitbg[3]:getChildByName("cost_bg")
	local icon = cost_bg:getChildByName("icon")
	local costTx = cost_bg:getChildByName("text")
	local newImg = cost_bg:getChildByName("new_img")
	newImg:setVisible(false)
	if not frindshipCostObj  then
		return
	end

	local ownFrindshipValue = frindshipCostObj:getOwnNum()
	local costFrindshipValue = frindshipCostObj:getNum()

	icon:loadTexture(frindshipCostObj:getIcon())
	local state_tx = self.recruitbg[3]:getChildByName("state_tx")
	costTx:setColor(COLOR_TYPE.WHITE)
	local str = ''
	if ownFrindshipValue >= costFrindshipValue*10 then
		costTx:setString(costFrindshipValue*10)
		str = string.format(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO17"),10)
	else
		costTx:setString(costFrindshipValue)
		str = string.format(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO17"),1)
		if ownFrindshipValue < costFrindshipValue then
			costTx:setColor(COLOR_TYPE.RED1)
		end
	end
	state_tx:setString(str)
end

function TavernHighRecruitUI:timeoutCallback(parent,time,str,cdType,fintSize)

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

function TavernHighRecruitUI:sendRecruitOneMsg()
	
	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])
	local ownTokenNum = costTokenObj:getOwnNum()
	local ownMoney = costMoneyObj:getOwnNum()
	local needMoney = costMoneyObj:getNum()
	local args = {
		type = RecruitType.high,
	}
	if self.isFree then
		args.free = self.isFree
	else
		args.token = ownTokenNum > 0
	end

	if not self.isFree then
		if ownTokenNum < 1 then
			if ownMoney < needMoney then
				local str = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),costMoneyObj:getName())
				promptmgr:showSystenHint(str, COLOR_TYPE.RED)
				return
			end
		end
	end

	MessageMgr:sendPost('single_tavern','tavern',json.encode(args),function(response)
		local code = response.code
        local data = response.data
        if code == 0 then
            local costs = data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
			local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
            end
            UserData:getUserObj():setTavenNextHighTime(data.htime)

            TavernMgr:showTavernAnimate(awards, function ()
				self:updateRecruitOne()
	            local cnt = UserData:getUserObj():getTavenHighCallCnt()
	            UserData:getUserObj():setTavenHighCallCnt(cnt+1)
	            self:updateRecruitCnt()
	            TavernMgr:updateTavernMain(RecruitType.high)
			end,1,RecruitType.high)
        end
    end)
end

function TavernHighRecruitUI:sendRecruitTenMsg()
	
	local tavernCfg = GameData:getConfData("tavern")[RecruitType.high]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])
	local ownTokenNum = costTokenObj:getOwnNum()
	local costTokenNum = costTokenObj:getNum()
	local ownMoney = costMoneyObj:getOwnNum()
	local costMoney = costMoneyObj:getNum()*tavernCfg.tenDiscount

	if ownTokenNum < costTokenNum*10 then
		if ownMoney < costMoney then
			local str = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),costMoneyObj:getName())
			promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			return
		end
	end

	MessageMgr:sendPost('ten_tavern','tavern',json.encode({type = RecruitType.high}),function(response)
		local code = response.code
        local data = response.data
        if code == 0 then
            local costs = data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
			local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
            end

            TavernMgr:showTavernAnimate(awards, function (	)
				self:updateRecruitOne()
	            self:updateRecruitTen()
	            local cnt = UserData:getUserObj():getTavenHighCallCnt()
	            UserData:getUserObj():setTavenHighCallCnt(cnt+10)
	            self:updateRecruitCnt()
	            TavernMgr:updateTavernMain(RecruitType.high)
			end,10,RecruitType.high)
        end
    end)
end

function TavernHighRecruitUI:sendRecruitFriendshipMsg()
	
	local frindshipCost = GlobalApi:toAwards(GlobalApi:getGlobalValue_new("tavernAdvancedCost"))
	local frindshipCostObj = DisplayData:getDisplayObj(frindshipCost[1])
	local ownFrindshipValue = frindshipCostObj:getOwnNum()
	local costFrindshipValue = frindshipCostObj:getNum()
	if ownFrindshipValue < costFrindshipValue then
		local str = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),frindshipCostObj:getName())
		promptmgr:showSystenHint(str, COLOR_TYPE.RED)
		return
	end

	local addCnt = 1
	local msgAct = ''
	local actType = 1
	if ownFrindshipValue >= costFrindshipValue*10 then
		msgAct = 'ten_tavern'
		addCnt = 10
		actType = 10
	else
		msgAct = 'single_tavern'
		actType = 1
	end
	local args = {
		type = RecruitType.high,
		love = true,
	}
	MessageMgr:sendPost(msgAct,'tavern',json.encode(args),function(response)
		local code = response.code
        local data = response.data
        if code == 0 then
            local costs = data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
			local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
            end

            TavernMgr:showTavernAnimate(awards, function ()
				self:updateRecruitOne()
	            self:updateRecruitTen()
	            self:updateRecruitFriendship()
	            local cnt = UserData:getUserObj():getTavenHighCallCnt()
	            UserData:getUserObj():setTavenHighCallCnt(cnt+addCnt)
	            self:updateRecruitCnt()
	            TavernMgr:updateTavernMain(RecruitType.high)
			end, actType,RecruitType.high,true) 
        end
    end)
end

return TavernHighRecruitUI