local FirstRechargeUI = class("FirstRechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function FirstRechargeUI:ctor(data)
    self.uiIndex = GAME_UI.UI_FIRSTRECHARGE
	self.data = data
	self.cfg = GameData:getConfData("specialreward")["first_pay"]

    UserData:getUserObj().activity.first_pay = self.data.first_pay
    UserData:getUserObj().tips.first_pay = 0
end	

function FirstRechargeUI:onShow()
	self:updatePanel()
end

function FirstRechargeUI:updatePanel()
	local gotoTx=self.gotoBtn:getChildByName("tx")	
	
	local val=UserData:getUserObj():getMark().first_pay
	print("UserData:getUserObj().getMark().first_pay "..val)
	local str=''
	local isCanGetAwards=false
	if val==0 then
		str=GlobalApi:getLocalStr('FIRSTRECHARGE_1')
	elseif val==1 then
		str=GlobalApi:getLocalStr('FIRSTRECHARGE_2')
		isCanGetAwards=true
	end
	
	gotoTx:setString(str)
	self.gotoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			if isCanGetAwards==false then
				RechargeMgr:hideFirstRecharge(function ()
				RechargeMgr:showRecharge()
				end)
			else
                --[[if self.hadFood == true then
                    local food = UserData:getUserObj():getFood()
                    local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                    if food >= maxFood then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                        return
                    end
                end
                --]]
				local args = {}
				MessageMgr:sendPost('get_first_pay_reward','user',json.encode(args),function (response)
					local code = response.code
					if code == 0 then
						local awards = response.data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
							GlobalApi:showAwardsCommon(awards,nil,nil,true)
                            UserData:getUserObj():getMark().first_pay = 2
						end
						
                        UserData:getUserObj().tips.first_pay = 0
                        self.data.first_pay = response.data.first_pay
                        UserData:getUserObj().activity.first_pay = self.data.first_pay

                        self.bg2:setVisible(false)
                        self.bg3:setVisible(true)
                        self:refreshSV()
					end
				end)

			end
	    end
	end)
end

function FirstRechargeUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
    local bg3 = bg1:getChildByName("bg3")
    self.bg2 = bg2
    self.bg3 = bg3
	self:adaptUI(bg1, bg2)
    self:adaptUI(bg1, bg3)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 20))
    bg3:setPosition(cc.p(winSize.width/2,winSize.height/2 - 20))

    local val=UserData:getUserObj():getMark().first_pay
    if val == 2 then
        bg2:setVisible(false)
        bg3:setVisible(true)
    else
        bg2:setVisible(true)
        bg3:setVisible(false)
    end

    self:initBg2()
    self:initBg3()
	self.audioId=AudioMgr.PlayAudio(13)
end

function FirstRechargeUI:initBg2()
    local bg2 = self.bg2
    self.hadFood = false
    local hadFoodNum = 0

    local firstPayShowAwards = GameData:getConfData("avfirstpayshowawards")[1]
    local showAwards = DisplayData:getDisplayObjs(firstPayShowAwards.awards)

	for i=1,3 do
		local bg = bg2:getChildByName('bg'..i)
		if showAwards[i] then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, showAwards[i], bg)
			local bgSize=bg:getContentSize()
			tab.awardBgImg:setPosition(cc.p(bgSize.width/2, bgSize.height/2))
			
			if i==1 then
				local effect = tab.awardBgImg:getChildByName('chip_light')
				local size = tab.awardBgImg:getContentSize()
				if not effect then
					effect = GlobalApi:createLittleLossyAniByName("chip_light")
					effect:getAnimation():playWithIndex(0, -1, 1)
					effect:setName('chip_light')
					effect:setVisible(true)
					effect:setPosition(cc.p(size.width/2,size.height/2))
					tab.awardBgImg:addChild(effect)
				else
					effect:setVisible(true)
				end
			end
            if showAwards[i]:getId() == 'food' then
			    hadFoodNum = hadFoodNum + 1
		    end

            tab.nameTx:setScale(0.9)
            tab.nameTx:setPositionY(-18)
            tab.nameTx:setString(showAwards[i]:getName())
            tab.nameTx:setColor(showAwards[i]:getNameColor())
            tab.nameTx:enableOutline(showAwards[i]:getNameOutlineColor(),1)

            local guangImg = bg2:getChildByName('guang_' .. i)
            if showAwards[i]:getQuality() == 6 then
                guangImg:setVisible(true)
                guangImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
            else
                guangImg:setVisible(false)
            end

		end
	end

    if hadFoodNum > 0 then
        self.hadFood = true
    end
	
    ----
    local awards = DisplayData:getDisplayObjs(self.cfg.reward)
    local bg = bg2:getChildByName('bg4')
    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[1], bg)
	local bgSize=bg:getContentSize()
	tab.awardBgImg:setPosition(cc.p(bgSize.width/2, bgSize.height/2))
	local effect = tab.awardBgImg:getChildByName('chip_light')
	local size = tab.awardBgImg:getContentSize()
	if not effect then
		effect = GlobalApi:createLittleLossyAniByName("chip_light")
		effect:getAnimation():playWithIndex(0, -1, 1)
		effect:setName('chip_light')
		effect:setVisible(true)
		effect:setPosition(cc.p(size.width/2,size.height/2))
		tab.awardBgImg:addChild(effect)
	else
		effect:setVisible(true)
	end

    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(220, 40))
	local re1 = xx.RichTextLabel:create(firstPayShowAwards.desc1, 22, COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(firstPayShowAwards.desc2, 22,COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
	richText2:addElement(re1)
	richText2:addElement(re2)
    richText2:setAlignment('left')
    --richText2:setVerticalAlignment('left')
	richText2:setAnchorPoint(cc.p(0,0.5))
	richText2:setPosition(cc.p(230,157))
    richText2:format(true)
    bg2:addChild(richText2)

	--role
	self.ani = GlobalApi:createSpineByName("ui_npc_zhaoyun", "spine/ui_npc_zhaoyun/ui_npc_zhaoyun", 1)
	local roleNode = ccui.Helper:seekWidgetByName(bg2,"roleNode")
	self.ani:setAnimation(0, 'idle', true)
	self.ani:setLocalZOrder(999)
    roleNode:addChild(self.ani)
	self.ani:setPosition(cc.p(0,0))
	
	--goto btn
	self.gotoBtn = bg2:getChildByName("goto_btn")

	--close btn
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RechargeMgr:hideFirstRecharge()
	    end
	end)
	
    -- 
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_3'), 24, cc.c4b(246, 255, 0, 255))
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(25, 25, 25, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_4'), 24,COLOR_TYPE.RED)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(18,360))
    richText:format(true)
    bg2:addChild(richText)


	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
	self:updatePanel()
end

function FirstRechargeUI:initBg3()
    local bg3 = self.bg3

    local closeBtn = bg3:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RechargeMgr:hideFirstRecharge()
	    end
	end)
	

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_5'), 26, COLOR_TYPE.RED)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_6'), 26,COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(238,365))
    richText:format(true)
    bg3:addChild(richText)


    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_7'), 26, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	--local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_6'), 26,COLOR_TYPE.WHITE)
	--re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    --re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    --re2:setFont('font/gamefont.ttf')
	richText2:addElement(re1)
	--richText2:addElement(re2)
    richText2:setAlignment('left')
    richText2:setVerticalAlignment('middle')
	richText2:setAnchorPoint(cc.p(1,0.5))
	richText2:setPosition(cc.p(260 + 758,365 - 40))
    richText2:format(true)
    bg3:addChild(richText2)

    self.tempData = GameData:getConfData('avfirstpay')
    local bg = bg3:getChildByName('bg')
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = bg3:getChildByName('cell')
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell
    self:refreshSV()

    bg3:setOpacity(0)
    bg3:runAction(cc.FadeIn:create(0.3))
end

function FirstRechargeUI:refreshSV()
    local val = UserData:getUserObj():getMark().first_pay
    if val ~= 2 then
        return
    end
    self.datas = {}
    for i = 1,#self.tempData do
        local v = clone(self.tempData[i])
        
        local target1 = v.target1
        local target2 = v.target2
        local progress = self.data.first_pay.progress[tostring(i)]
        local rewards = self.data.first_pay.rewards

        local progress1 = progress[tostring(1)] or 0
        local progress2 = progress[tostring(2)] or 0
        if (progress1 >= target1) or (target2 > 0 and progress2 >= target2) then
            if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                v.showStatus = 1
            else
                v.showStatus = 3
            end
        else
            v.showStatus = 2
        end
        table.insert(self.datas,v)
    end

    table.sort(self.datas,function(a, b)
        if a.showStatus == b.showStatus then
            return tonumber(a.id) < tonumber(b.id)
        else
            return a.showStatus > b.showStatus
        end
	end)

    self.sv:removeAllChildren()
    self:updateSV()
end

function FirstRechargeUI:updateSV()
    local num = #self.datas
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = math.ceil(num/2) * self.rewardCell:getContentSize().height +  (math.ceil(num/2) - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local cellTotalHeight = 0
    local tempHeight = self.rewardCell:getContentSize().height
    for i = 1,num do
        local tempCell = self.rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local posx = 3
        if i%2 == 0 then
            posx = 384 + 10
        end

        local curCellHeight = 0
        if i%2 == 1 then
            curCellHeight = tempCell:getContentSize().height
        end

        local curSpace = 0
        if i == 1 or i == 2 then
            curSpace = 0
        else
            if i%2 == 1 then
                curSpace = cellSpace
            end
        end
        cellTotalHeight = cellTotalHeight + curCellHeight + curSpace
        tempCell:setPosition(cc.p(posx,allHeight - cellTotalHeight))
        self.sv:addChild(tempCell)

        local confData = self.datas[i]
        tempCell:loadTexture('uires/ui/common/common_bg_26.png')

        local awards = DisplayData:getDisplayObjs(confData.awards)
        for j = 1,2 do
            local icon = tempCell:getChildByName('icon' .. j)
            if awards[j] then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards[j],icon)
                cell.awardBgImg:setPosition(cc.p(94/2,94/2))
                cell.awardBgImg:loadTexture(awards[j]:getBgImg())
                cell.chipImg:setVisible(true)
                cell.chipImg:loadTexture(awards[j]:getChip())
                cell.lvTx:setString('x'..awards[j]:getNum())
                cell.awardImg:loadTexture(awards[j]:getIcon())
                local godId = awards[j]:getGodId()
                awards[j]:setLightEffect(cell.awardBgImg)
            else
                icon:setVisible(false)
            end
        end

        local got = tempCell:getChildByName('got')
        local getBtn = tempCell:getChildByName('get_btn')
        getBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))

        local gotoBtn = tempCell:getChildByName('goto_btn')
        gotoBtn:setVisible(false)
        gotoBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_VIPLIMIT4'))

        local target1 = confData.target1
        local target2 = confData.target2
        local progress = self.data.first_pay.progress[tostring(confData.id)]
        local rewards = self.data.first_pay.rewards

        local progress1 = progress[tostring(1)] or 0
        local progress2 = progress[tostring(2)] or 0
        if (progress1 >= target1) or (target2 > 0 and progress2 >= target2) then
            if rewards[tostring(confData.id)] and rewards[tostring(confData.id)] == 1 then 
                getBtn:setVisible(false)
                got:setVisible(true)
                got:loadTexture(HASGETAWARD)
            else 
                getBtn:setVisible(true)
                got:setVisible(false)
            end
        else
            getBtn:setVisible(false)
            got:setVisible(true)
            got:loadTexture(NOTREATCH)
        end

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                MessageMgr:sendPost('get_first_pay_reward','activity',json.encode({id = confData.id}),
		        function(response)
			        if(response.code ~= 0) then
				        return
			        end
			        local awards = response.data.awards
			        if awards then
				        GlobalApi:parseAwardData(awards)
				        GlobalApi:showAwardsCommon(awards,nil,nil,true)
			        end
                    
                    self.data.first_pay.rewards[tostring(confData.id)] = 1
                    UserData:getUserObj().activity.first_pay = self.data.first_pay
                    self:refreshSV()
		        end)
            end 
        end)

        -- БъЬт
        local richText = xx.RichText:create()
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
	    richText:setContentSize(cc.size(5000, 40))
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(20,119))
	    tempCell:addChild(richText)

        local re1 = xx.RichTextLabel:create('\n',26, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont1.TTF')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,confData.desc)
        richText:format(true)
        
    end
    innerContainer:setPositionY(size.height - allHeight)

end

function FirstRechargeUI:ActionClose(call)
	AudioMgr.stopEffect(self.audioId)
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	bg2:runAction(cc.FadeOut:create(0.15))
	bg2:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.CallFunc:create(function ()
		self:hideUI()
		if(call ~= nil) then
			return call()
		end
	end)))
end

return FirstRechargeUI