local PopWindowFirstRechargeUI = class("PopWindowFirstRechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowFirstRechargeUI:ctor(data)
    self.data = data
    self.cfg = GameData:getConfData("specialreward")["first_pay"]
    self:init()
end

function PopWindowFirstRechargeUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_firstrecharge.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bgImg1 = bgImg:getChildByName("bg_img1")
    local bgImg2 = bgImg1:getChildByName("bg_img2")
    local bg2 = bgImg2:getChildByName("bg_img3")
	self.bg2 = bg2

    self:initBg2()
	self:updatePanel()
end

function PopWindowFirstRechargeUI:initBg2()
    local bg2 = self.bg2
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
	richText2:setPosition(cc.p(230,157 - 48))
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
	richText:setPosition(cc.p(18,360 - 48))
    richText:format(true)
    bg2:addChild(richText)

	self:updatePanel()
end

function PopWindowFirstRechargeUI:updatePanel()
	local gotoTx=self.gotoBtn:getChildByName("tx")	
	gotoTx:setString(GlobalApi:getLocalStr('POP_WINDOW_DES2'))
	self.gotoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			RechargeMgr:showFirstRecharge()
	    end
	end)
end

function PopWindowFirstRechargeUI:getPanel()
    return self.bgImg
end
            
return PopWindowFirstRechargeUI