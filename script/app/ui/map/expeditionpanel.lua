local ExpeditionUI = class("ExpeditionUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ExpeditionUI:ctor(customsId)
	self.uiIndex = GAME_UI.UI_EXPEDITION
	self.customsId = tonumber(customsId)
end

function ExpeditionUI:init()

	local bg_img = self.root:getChildByName("bg_img")
	local bg = bg_img:getChildByName("bg")
    self:adaptUI(bg_img, bg)

	local closeBtn = bg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideExpeditionPanel()
        end
    end)

	local mapObj = MapData.data[self.customsId]
	if not mapObj then
		return
	end

	local titleTx = bg:getChildByName("title_tx")
	titleTx:setString(mapObj:getName())

	local type_icon = bg:getChildByName("type_icon")
	local typeTx = type_icon:getChildByName("text")
	typeTx:setString(mapObj:getTypeName())

	--模型，战斗力
	local monsterGroup = mapObj:getFormation()
	local monsterConf = GameData:getConfData("formation")[monsterGroup]
	local monsterId = monsterConf['pos'..monsterConf.boss]
	local _,_,monsterModelConf = GlobalApi:getMonsterConf(monsterId)

	local role_bg = bg:getChildByName("role_bg")
	local spine = GlobalApi:createLittleLossyAniByName(monsterModelConf.modelUrl..'_display')
	if spine then
		local roleBgSize = role_bg:getContentSize()
		spine:getAnimation():play('idle', -1, 1)
		spine:setPosition(cc.p(roleBgSize.width/2,20))
		role_bg:addChild(spine)
	end

	local forceTx = bg:getChildByName("number_tx") 
	forceTx:setString(monsterConf.fightforce)
	
	--战斗次数
	local limits = mapObj:getDayLimits()
	local curTimes = mapObj:getTimes()
	local remainTimes = limits-curTimes
	if remainTimes < 0 then
		remainTimes = 0
	end
	local first = mapObj:getBfirst()
	local canWipeout = limits > 0 and first
	local battle_time_bg = bg:getChildByName("battle_time_bg")
	battle_time_bg:setVisible(limits ~= 0)
	local timeTx = battle_time_bg:getChildByName("time_tx")
	if limits ~= 0 then
		local addbtn = battle_time_bg:getChildByName("add_btn")
		addbtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            self:addTimes()
	        end
	    end)
		
		if not self.timeRt then
		    local richText = xx.RichText:create()
			local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX1'), 21,COLOR_TYPE.WHITE1)
			rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
			rt1:clearShadow()

			local color = remainTimes == 0 and COLOR_TYPE.RED1 or COLOR_TYPE.WHITE1
			local outlineColor = remainTimes == 0 and COLOROUTLINE_TYPE.RED1 or COLOROUTLINE_TYPE.OFFWHITE1
			local rt2 = xx.RichTextLabel:create(remainTimes, 21, color)
			rt2:setStroke(outlineColor, 2)
			rt2:clearShadow()
			local rt3 = xx.RichTextLabel:create("/"..limits, 21, COLOR_TYPE.WHITE1)
			rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
			rt3:clearShadow()
			richText:addElement(rt1)
			richText:addElement(rt2)
			richText:addElement(rt3)
		    
		    richText:setAnchorPoint(cc.p(0.5, 0.5))
		    richText:setAlignment('middle')
		    richText:setPosition(cc.p(0, 3))
		    richText:setContentSize(cc.size(400, 22))
		    richText:format(true)
		    timeTx:addChild(richText)
		    self.timeRt = {rt = richText, rt1 = rt1, rt2 = rt2, rt3 = rt3}
		end
	end

	local tipTx = bg:getChildByName("tip_tx")
	tipTx:setString(GlobalApi:getLocalStr_new("CUSTOMS_MAP_INFOTX4"))
	tipTx:setVisible(limits==0)

	--掉落
	local dropImg = bg:getChildByName("drop_img")
	local infoTx = dropImg:getChildByName("info_tx")
	local strIndex = limits == 0 and "CUSTOMS_MAP_INFOTX2" or "CUSTOMS_MAP_INFOTX3"
	infoTx:setString(GlobalApi:getLocalStr_new(strIndex))
	local itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	itemCell.awardBgImg:setScale(0.8)
	local cellbg = itemCell.awardBgImg
	local list = dropImg:getChildByName("list")
	list:setItemsMargin(-5)
	list:setScrollBarEnabled(false)
	local first = mapObj:getBfirst()
	local award = first == false and mapObj:getFirstAward() or mapObj:getDrop()
	for i=1,#award do
		local displayobj = DisplayData:getDisplayObj(award[i])
		if displayobj then
			local item = list:getItem(i-1)
			if not item then
				item = cellbg:clone()
	            list:pushBackCustomItem(item)
			end
			ClassItemCell:updateItem(item,displayobj,2)
			item:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(displayobj)
                end
            end)
		end
	end

	--粮草
	local cost_tx = bg:getChildByName("cost_tx")
	local posX = limits==0 and 493 or 562
	cost_tx:setPositionX(posX)
	local food = mapObj:getFood()
	local displayobj = DisplayData:getDisplayObj(food[1])
	if displayobj then

		local rt = xx.RichText:create()
	    rt:setAnchorPoint(cc.p(0.5, 0.5))
	    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("CUSTOMS_MAP_INFOTX5"), 18, COLOR_TYPE.WHITE1)
	    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt1:clearShadow()
	    local rt2 = xx.RichTextImage:create(displayobj:getIcon())
	    rt2:setScale(0.5)
	    local rt3 = xx.RichTextLabel:create(displayobj:getNum(), 18, COLOR_TYPE.WHITE1)
	    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt3:clearShadow()
	    rt:addElement(rt1)
	    rt:addElement(rt2)
	    rt:addElement(rt3)
	    rt:setAlignment("middle")
	    local size = cost_tx:getContentSize()
	    rt:setPosition(cc.p(0,20))
	    rt:setContentSize(cc.size(400, 10))
		rt:format(true)
		cost_tx:addChild(rt)
	end

	--扫荡
	self.wipe_btn = bg:getChildByName("wipe_btn")
	local btnTx = self.wipe_btn:getChildByName("text")
	btnTx:setString(string.format(GlobalApi:getLocalStr_new("CUSTOMS_MAP_BTNTX5"),remainTimes))
	self.wipe_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:wipeout()
        end
    end)
    if first then
    	self.wipe_btn:setVisible(remainTimes~=0)
    else
    	self.wipe_btn:setVisible(false)
    end
    
	
	--挑战
	local battle_btn = bg:getChildByName("battle_btn")
	local posX = limits==0 and 493 or 562
	battle_btn:setPositionX(posX)
	local btnTx = battle_btn:getChildByName("text")
	local str = canWipeout and 'CUSTOMS_MAP_BTNTX6' or 'CUSTOMS_MAP_BTNTX4'
	btnTx:setString(GlobalApi:getLocalStr_new(str))
	battle_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if canWipeout then
        		self:wipeout(1)
        	else
            	self:onFight()
            end
        end
    end)
	
end

function ExpeditionUI:updatePanel()

	local mapObj = MapData.data[self.customsId]
	if not mapObj then
		return
	end

	local limits = mapObj:getDayLimits()
	local curTimes = mapObj:getTimes()
	local remainTimes = limits-curTimes
	if remainTimes < 0 then
		remainTimes = 0
	end

	local btnTx = self.wipe_btn:getChildByName("text")
	btnTx:setString(string.format(GlobalApi:getLocalStr_new("CUSTOMS_MAP_BTNTX5"),remainTimes))
	local first = mapObj:getBfirst()
	if first then
    	self.wipe_btn:setVisible(remainTimes~=0)
    else
    	self.wipe_btn:setVisible(false)
    end
	if self.timeRt then

		self.timeRt.rt1:setString(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX1'))
		local color = remainTimes == 0 and COLOR_TYPE.RED1 or COLOR_TYPE.WHITE1
		local outlineColor = remainTimes == 0 and COLOROUTLINE_TYPE.RED1 or COLOROUTLINE_TYPE.OFFWHITE1
		self.timeRt.rt2:setString(remainTimes)
		self.timeRt.rt2:setColor(color)
		self.timeRt.rt2:setStroke(outlineColor, 2)
		self.timeRt.rt3:setString("/"..limits)
		self.timeRt.rt:format(true)
	end

end

--扫荡
function ExpeditionUI:wipeout(times)

	local mapObj = MapData.data[self.customsId]
	if not mapObj then
		return
	end

	local battledTimes = mapObj:getTimes()
	local dayLimits = mapObj:getDayLimits()
	local remainTimes = dayLimits - battledTimes
	times = times or  remainTimes
	
	if times + battledTimes > dayLimits then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX6'), COLOR_TYPE.RED)
		return
	end

	local needFood = mapObj:getFood()
	local displayobj = DisplayData:getDisplayObj(needFood[1])
	if not displayobj then
		return
	end

	local needFoodNum = displayobj:getNum()
	local ownFoodNum = displayobj:getOwnNum()
	if needFoodNum*times > ownFoodNum then
		local str = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),displayobj:getName())
        promptmgr:showMessageBox(str, MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("food")
        end)
		return
	end
	local customsType = mapObj:getCustomsType()
	local args = 
	{
		type = customsType,
		id = self.customsId,
		time = times,
	}
	MessageMgr:sendPost('auto_fight','battle',json.encode(args),function (response)
		
		local code = response.code
		local data = response.data
		if code == 0 then
            local lastLv = UserData:getUserObj():getLv()
			
			local awards = data.awards
			for k,v in pairs(awards) do
				GlobalApi:parseAwardData(v)
			end
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end

            mapObj:addTimes(customsType,times)
            self:updatePanel()
            local id,page = self.customsId,customsType
			MapMgr:showRainsPanel(awards,id)
            local nowLv = UserData:getUserObj():getLv()
            GlobalApi:showKingLvUp(lastLv,nowLv)
		else
			local descStr = response.desc or ''
			local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_ERROR'),descStr)
			promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
		end
	end)
end

--挑战
function ExpeditionUI:onFight()

    local customsObj = MapData.data[self.customsId]
    if not customsObj then
		return
	end

	local battledTimes = customsObj:getTimes()
	local dayLimits = customsObj:getDayLimits()
	local first = customsObj:getBfirst()
	local couldBattle = false

	if not first then
		couldBattle = true
	else
		couldBattle = battledTimes < dayLimits
	end

	if not couldBattle then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX6'), COLOR_TYPE.RED)
		return
	end

	local foodAward = customsObj:getFood()
	local displayobj = DisplayData:getDisplayObj(foodAward[1])
	if not displayobj then
		return
	end

	local needFoodNum = displayobj:getNum()
	local ownFoodNum = displayobj:getOwnNum()
	if needFoodNum > ownFoodNum then
		local str = string.format(GlobalApi:getLocalStr_new("COMMON_STR_NOTENOUGH"),displayobj:getName())
        promptmgr:showMessageBox(str, MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("food")
        end)
		return
	end

	local moveCustomsId = self.customsId
	local customsType = customsObj:getCustomsType()
	MapMgr:hideExpeditionPanel()
    MapMgr:playBattle(BATTLE_TYPE.NORMAL, self.customsId, customsType,function(isWin)
    	if isWin then
    		MapMgr:showMainScene(customsType,self.customsId,moveCustomsId)
    	else
    		MapMgr:showMainScene(customsType,self.customsId,nil)
    	end 
    end)
    
end

--增加次数
function ExpeditionUI:addTimes()

	local customsObj = MapData.data[self.customsId]
    if not customsObj then
		return
	end
	local totalRest = customsObj:getTotalResetNums()
	local restNums = customsObj:getResetedNums()
	if restNums >= totalRest then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX10'), COLOR_TYPE.RED)
		return
	end

	local hasCash = UserData:getUserObj():getCash()
	local resetCostYb = customsObj:getResetCost()
	if hasCash < resetCostYb then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('COMMON_NO_CASH'), COLOR_TYPE.RED)
		return
	end

	local customsType = customsObj:getCustomsType()
	local args = 
	{
		id = self.customsId,
		type = customsType,
	}

	MessageMgr:sendPost('reset_battle','battle',json.encode(args),function (response)
		
		local code = response.code
		local data = response.data
		if code == 0 then

			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            customsObj:setTimes(customsType,data.cityInfo.time)
            customsObj:setResetedNums(data.cityInfo.reset_num)
            self:updatePanel()
		else
			local descStr = response.desc or ''
			local tipStr = string.format(GlobalApi:getLocalStr_new('COMMON_STR_ERROR'),descStr)
			promptmgr:showSystenHint(tipStr, COLOR_TYPE.RED)
		end
	end)

end
return ExpeditionUI