local TavernNormalRecruitUI = class("TavernNormalRecruitUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TavernNormalRecruitUI:ctor(heroId,typeId)
	self.uiIndex = GAME_UI.UI_TAVEN_NORMAL_PANNEL
	self.heroId = heroId
	self.typeId = typeId or 1
	self.talkText = {}
end

function TavernNormalRecruitUI:setUIBackInfo()

    UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_TAVEN_NORMAL_PANNEL), function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr:PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TavernMgr:hideNormalRecruitUI()
        end
    end,1)

end

function TavernNormalRecruitUI:onShow()
    self:setUIBackInfo()
end

function TavernNormalRecruitUI:init()

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

	--金币召唤次数
	self.infoTx = bg:getChildByName("info_tex")
	self:updateRecruitCnt()

	self.recruitbg = {}
	local tavernCfg = GameData:getConfData("tavern")
	for i=1,2 do

		local textStr = i== 1 and "TAVERN_MAIN_INFO11" or "TAVERN_MAIN_INFO12"
		local recruitbg = bg:getChildByName("recruit_"..i)
		local nameTx = recruitbg:getChildByName("name_tx")
		nameTx:setString(GlobalApi:getLocalStr_new(textStr))

		recruitbg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then

	        	if i == 1 then
	        		self:sendRecruitOneMsg()
	        	else
	        		self:sendRecruitTenMsg()
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
end

function TavernNormalRecruitUI:updateDropInfo()

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.normal]
	local name =  GlobalApi:getGeneralText(tavernCfg.name)
	local dropNameTx = self.dropbg:getChildByName("drop_tip")
	local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(name, 20,cc.c4b(243,140,247,255))
    rt1:setStroke(cc.c4b(69,54,33,255), 2)
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

function TavernNormalRecruitUI:updateRecruitCnt()

	local goldCallCnt = UserData:getUserObj():getTavenGoldCallCnt()
	local vip = UserData:getUserObj():getVip()
	local vipConf = GameData:getConfData("vip")[tostring(vip)]
	local strTotal = "/"..vipConf.tavernNormalLimit
	local remainCnt = vipConf.tavernNormalLimit - goldCallCnt
	if remainCnt < 0 then
		remainCnt = 0
	end

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
		self.infoTx:addChild(rt)
		self.normalRt = {rt = rt, rt1 = rt1, rt2 = rt2, rt3 = rt3}
	else
		self.normalRt.rt2:setString(remainCnt)
		self.normalRt.rt:format(true)
	end	
end

--刷新普通招募(一次)
function TavernNormalRecruitUI:updateRecruitOne()

	local cost_bg = self.recruitbg[1]:getChildByName("cost_bg")
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

	local state_tx = self.recruitbg[1]:getChildByName("state_tx")
	state_tx:setString('')
	local nextFreeTime = UserData:getUserObj():getTavenNextNormalTime()
	local remainTime =  nextFreeTime - GlobalData:getServerTime()
	local remainFreeCount = totalFreeCount - normalFreeCount
	self.isFree = remainFreeCount > 0 and remainTime <= 0
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
function TavernNormalRecruitUI:updateRecruitTen()

	local cost_bg = self.recruitbg[2]:getChildByName("cost_bg")
	local icon = cost_bg:getChildByName("icon")
	local costTx = cost_bg:getChildByName("text")
	local newImg = cost_bg:getChildByName("new_img")

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.normal]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])  
	if not costTokenObj or not costMoneyObj then
		return
	end

	local state_tx = self.recruitbg[2]:getChildByName("state_tx")
	state_tx:setString('')
	
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

function TavernNormalRecruitUI:timeoutCallback(parent,time,str,cdType,fintSize)

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

function TavernNormalRecruitUI:sendRecruitOneMsg()
	
	local goldCallCnt = UserData:getUserObj():getTavenGoldCallCnt()
	local vip = UserData:getUserObj():getVip()
	local vipConf = GameData:getConfData("vip")[tostring(vip)]
	local strTotal = "/"..vipConf.tavernNormalLimit
	local remainCnt = vipConf.tavernNormalLimit - goldCallCnt
	if remainCnt < 1 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO13"), COLOR_TYPE.RED)
		return
	end

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.normal]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])
	local ownTokenNum = costTokenObj:getOwnNum()
	local ownMoney = costMoneyObj:getOwnNum()
	local needMoney = costMoneyObj:getNum()
	local args = {
		type = RecruitType.normal,
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
            UserData:getUserObj():setTavenNormalFree(data.nfree)
            UserData:getUserObj():setTavenNextNormalTime(data.ntime)

            TavernMgr:showTavernAnimate(awards, function ()
				self:updateRecruitOne()
	            if data.gold_count then
	            	UserData:getUserObj():setTavenGoldCallCnt(data.gold_count)
	            	self:updateRecruitCnt()
	        	end
	            TavernMgr:updateTavernMain(RecruitType.normal)
			end, 1,RecruitType.normal)
        end
    end)
end

function TavernNormalRecruitUI:sendRecruitTenMsg()
	
	local goldCallCnt = UserData:getUserObj():getTavenGoldCallCnt()
	local vip = UserData:getUserObj():getVip()
	local vipConf = GameData:getConfData("vip")[tostring(vip)]
	local strTotal = "/"..vipConf.tavernNormalLimit
	local remainCnt = vipConf.tavernNormalLimit - goldCallCnt
	if remainCnt < 10 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO13"), COLOR_TYPE.RED)
		return
	end

	local tavernCfg = GameData:getConfData("tavern")[RecruitType.normal]
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

	MessageMgr:sendPost('ten_tavern','tavern',json.encode({type = RecruitType.normal}),function(response)
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
	            if data.gold_count then
	            	UserData:getUserObj():setTavenGoldCallCnt(data.gold_count)
	            	self:updateRecruitCnt()
	        	end
	            TavernMgr:updateTavernMain(RecruitType.normal)
			end, 2,RecruitType.normal)
        end
    end)

end

return TavernNormalRecruitUI