local TavernAnimateUI = class('TavernAnimateUI', BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')
-- fucking old log 
local heroFrame = {
	[2] = 'uires/ui/common/card_green.png',
	[3] = 'uires/ui/common/card_blue.png',
	[4] = 'uires/ui/common/card_purple.png',
	[5] = 'uires/ui/common/card_yellow.png',
	[6] = 'uires/ui/common/card_red.png',
}

local heroCircle = {
	[1] = 'uires/ui/tavern/circle_gray.png',
	[2] = 'uires/ui/tavern/circle_green.png',
	[3] = 'uires/ui/tavern/circle_blue.png',
	[4] = 'uires/ui/tavern/circle_puple.png',
	[5] = 'uires/ui/tavern/circle_yellow.png',
	[6] = 'uires/ui/tavern/circle_red.png',
}

-- 示例图大小
local defaultSize = cc.size(960, 640)
local positions = {
	[1] = cc.p(185, 303),
	[2] = cc.p(298, 459),
	[3] = cc.p(473, 505),
	[4] = cc.p(657, 506),
	[5] = cc.p(833, 457),
	[6] = cc.p(954, 303),
	[7] = cc.p(772, 206),
	[8] = cc.p(568, 230),
	[9] = cc.p(359, 212),
	[10] = cc.p(570, 384)
}

-- 招募音效ID
local recruitAudioId = nil

function TavernAnimateUI:ctor(awards,func,recuiteCount,recuitetype,isLove)

	self.uiIndex = GAME_UI.UI_TAVERN_ANIMATE
	self.func = func
	self.curCards = 0
	self.cardsPositions = {}
	self.cards = {}
	self.recuitetype = recuitetype or 1
	self.awardsIndex = 0
	self.awards = {}
	self:makeAwards(awards)
	self.showType = #self.awards > 6 and 2 or 1
	self.recuiteCount = recuiteCount					--招募次数
	self.isLove = isLove							--是否是爱心招募
end

function TavernAnimateUI:init()

	local bg = self.root:getChildByName('tavern_bg')
	local mask_bg = bg:getChildByName('mask_bg')
	local winSize = cc.Director:getInstance():getWinSize()
	self.mask_bg = mask_bg
	self:adaptUI(bg, mask_bg, true)

	self.modebg = self.mask_bg:getChildByName("mode_bg")
	self.modebg:setVisible(false)
	local clickTx = self.modebg:getChildByName("click_tx")
	clickTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_CONTINUE"))
	clickTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))

	local titleTx =  self.mask_bg:getChildByName("title_tx")
	titleTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_CONGRATS"))

	self.itembg = self.mask_bg:getChildByName("item_bg")

	self.costbg = self.mask_bg:getChildByName("cost_bg")
	self:againCost()

	local againBtn = mask_bg:getChildByName('again_btn')
	againBtn:addClickEventListener(function (  )
			self:func()
			TavernMgr:hideTavernAnimate()
			if self.role ~= nil then
				self.role:stopSound('sound')
			end
			TavernMgr:recuiteAgin(self.recuitetype,self.recuiteCount,self.isLove)
		end)

	local againTx = againBtn:getChildByName('text')
	local godieBtn = mask_bg:getChildByName('godie_btn')
	local backTx = godieBtn:getChildByName('text')
	backTx:setString(GlobalApi:getLocalStr('STR_RETURN_1'))
	godieBtn:addClickEventListener(function ()
			self:func()
			TavernMgr:hideTavernAnimate()
			if self.role ~= nil then
				self.role:stopSound('sound')
			end
		end)
	self.againBtn = againBtn
	self.godieBtn = godieBtn

	local sz = bg:getContentSize()
	
	againTx:setString(GlobalApi:getLocalStr('ONCE_MORE'))
	
    local black_bg = ccui.ImageView:create()
    black_bg:loadTexture('uires/ui/common/bg_black.png')
    black_bg:setScale9Enabled(true)
    black_bg:setContentSize(sz)
    black_bg:setTouchEnabled(true)
    black_bg:setPosition(cc.p(sz.width / 2, sz.height / 2))
    bg:addChild(black_bg)

    local url = 'spine/qianglingpai/qianglingpai'
    local name = 'qianglingpai'
    local spine = GlobalApi:createSpineByName(name, url, 1)
    if spine ~= nil then
    	spine:registerSpineEventHandler( function ( event )
    			spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    			recruitAudioId = nil
    			self:onFinish(black_bg, spine)
    		end, sp.EventType.ANIMATION_COMPLETE)

    	black_bg:addChild(spine)
    	spine:setLocalZOrder(999)
    	if self.recuitetype == RecruitType.high then
	    	spine:setAnimation(0, 'zhaomu2', false)
		else
			spine:setAnimation(0, 'zhaomu1', false)
		end

		recruitAudioId = AudioMgr.playEffect("media/effect/tavern_recruit.mp3", false)
	    spine:setPosition(cc.p(sz.width / 2, sz.height / 2))
    end

    black_bg:addClickEventListener(function (  )
    	self:onFinish(black_bg, spine)
    end)

	mask_bg:setCascadeOpacityEnabled(false)
	mask_bg:setOpacity(0)
end

function TavernAnimateUI:againCost()

	local icon = self.costbg:getChildByName("icon")
	local costTx = self.costbg:getChildByName("num_tx")

	local tavernCfg = GameData:getConfData("tavern")[self.recuitetype]
	local costTokenObj = DisplayData:getDisplayObj(tavernCfg.cost1[1])
	local costMoneyObj = DisplayData:getDisplayObj(tavernCfg.cost2[1])  
	if not costTokenObj or not costMoneyObj then
		return
	end

	local discount = tavernCfg.tenDiscount
	local ownTokenNum = costTokenObj:getOwnNum()
	local ownMoney = costMoneyObj:getOwnNum()
	local needTokenNum = costTokenObj:getNum()*self.recuiteCount
	local needMoney =  costMoneyObj:getNum()*self.recuiteCount
	if self.recuiteCount == 10 then
		needMoney =  costMoneyObj:getNum()*discount
	end

	local isFree = false
	if self.recuitetype == RecruitType.normal then
		local totalFreeCount = GlobalApi:getGlobalValue_new("tavernNormalFreeTimes")
		local normalFreeCount = UserData:getUserObj():getTavenNormalFree()
		local nextFreeTime = UserData:getUserObj():getTavenNextNormalTime()
		local remainTime =  nextFreeTime - GlobalData:getServerTime()
		local remainFreeCount = totalFreeCount - normalFreeCount
		isFree = remainFreeCount > 0 and remainTime <= 0
	elseif self.recuitetype == RecruitType.high then
		local nextFreeTime = UserData:getUserObj():getTavenNextHighTime()
		local remainTime =  nextFreeTime - GlobalData:getServerTime()
		isFree = remainTime <= 0
	end

	if not isFree then
		if ownTokenNum >= needTokenNum then
			icon:loadTexture(costTokenObj:getIcon())
			costTx:setString(needTokenNum)
			costTx:setColor(cc.c4b(254, 251, 224, 255))
			costTx:enableOutline(cc.c4b(113, 65, 31, 255), 2)
		else
			if self.isLove then
				local frindshipCost = GlobalApi:toAwards(GlobalApi:getGlobalValue_new("tavernAdvancedCost"))
				local frindshipCostObj = DisplayData:getDisplayObj(frindshipCost[1])
				icon:loadTexture(frindshipCostObj:getIcon())
				local ownFrindshipValue = frindshipCostObj:getOwnNum()
				local costFrindshipValue = frindshipCostObj:getNum()
				if ownFrindshipValue >= costFrindshipValue*10 then
					costTx:setString(costFrindshipValue*10)
					costTx:setColor(cc.c4b(254, 251, 224, 255))
					costTx:enableOutline(cc.c4b(113, 65, 31, 255), 2)
				else
					if ownFrindshipValue < costFrindshipValue then
						costTx:setString(costFrindshipValue)
						costTx:setColor(COLOR_TYPE.RED1)
						costTx:enableOutline(COLOROUTLINE_TYPE.RED1, 2)
					else
						costTx:setColor(cc.c4b(254, 251, 224, 255))
						costTx:enableOutline(cc.c4b(113, 65, 31, 255), 2)
					end
				end
			else
				icon:loadTexture(costMoneyObj:getIcon())
				costTx:setString(needMoney)
				if ownMoney >= needMoney then
					costTx:setColor(cc.c4b(254, 251, 224, 255))
					costTx:enableOutline(cc.c4b(113, 65, 31, 255), 2)
				else
					costTx:setColor(COLOR_TYPE.RED1)
					costTx:enableOutline(COLOROUTLINE_TYPE.RED1, 2)
				end
			end
		end
	else
		icon:loadTexture(costTokenObj:getIcon())
		costTx:setString(GlobalApi:getLocalStr_new("TAVERN_MAIN_INFO5"))
	end
end

function TavernAnimateUI:genCard(role)
	local node = cc.CSLoader:createNode('csb/taverncard.csb')

	local quality = role:getQuality()
	local frame = node:getChildByName('frame')
	frame:setLocalZOrder(98)
	-- frame:setRotation3D(cc.vec3(-45, 0, 0))
	frame:loadTexture(heroFrame[quality])
	local effectnode = frame:getChildByName('effect_node')
	local cardeffect = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
	cardeffect:setScale(2.2)
	cardeffect:setPosition(cc.p(3, 17))
	cardeffect:getAnimation():playWithIndex(0, -1, 1)
	cardeffect:getAnimation():setSpeedScale(0.8)
	effectnode:addChild(cardeffect, 1)


	local soldier_img = frame:getChildByName('soldier')
	soldier_img:loadTexture('uires/ui/common/soldier_'..role:getSoldierId()..'.png')
	soldier_img:ignoreContentAdaptWithSize(true)

	local layout = node:getChildByName('mask_white')
	layout:setLocalZOrder(99)

	local name = frame:getChildByName('name')
	name:setString(role:getName())
	name:setTextColor(cc.c4b(255, 247, 228, 255))
	name:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))

	local hero = frame:getChildByName('hero')
	hero:setLocalZOrder(999)
	local hid = role:getId()
	local spine = GlobalApi:createLittleLossyAniByName(role:getUrl() .. "_display", nil, role:getChangeEquipState())
	local spineScale = 1.0
	if self.recuitetype ~= 3 then
		frame:setScale(1.5)
		if spine ~= nil then
			spine:setScale(0.7)
		end
	else
		if spine ~= nil then
			spine:setScale(0.7)
		end
	end
	
	if spine ~= nil then
		-- 刚开始就他妈是苦逼脸
		spine:getAnimation():play('idle', -1, 1)
		-- spine:setAnimation(0, 'idle', true)
		hero:addChild(spine)
		-- spine:setAnimation(0, 'shengli', true)
		local herosz = hero:getContentSize()
		local _,_,heroModelConf = GlobalApi:getHeroConf(hid)
		local offsetY = heroModelConf.uiOffsetY
		spine:setPosition(cc.p(herosz.width / 2, herosz.height / 2 + offsetY * spineScale))
	end

	return node, frame, spine, layout,cardeffect
end

function TavernAnimateUI:makeAwards(awards)

	local tavernCfg = GameData:getConfData("tavern")[self.recuitetype]
	local fixAwards = {}
	for i=1,#tavernCfg.fixedAward do
		local award = tavernCfg.fixedAward[i]
		award[3] = 0
		fixAwards[award[2]] = award
	end

	local otherAward = {}
	for i=1,#awards do
		local award = awards[i]
		if fixAwards[award[2]] then
			fixAwards[award[2]][3] = fixAwards[award[2]][3] + award[3]
		else
			table.insert(otherAward, award)
		end
	end

	for k,v in pairs(otherAward) do
		table.insert(self.awards, v)
	end

	for k,v in pairs(fixAwards) do
		table.insert(self.awards, v)
	end
end

function TavernAnimateUI:goAction()
	local ele = table.remove(self.awards)
	if ele then
		self:genItemCell(ele)
	end
end

function TavernAnimateUI:genItemCell(element)

	local displayObj = DisplayData:getDisplayObj(element)
	if not displayObj then
		return
	end
	self.awardsIndex = self.awardsIndex + 1

	local startPosX,startPosY = 220,510
	if self.showType == 1 then
		startPosX = 370
		startPosY = 450
	end

	local posX = (self.awardsIndex-1)%6*110 + startPosX
	local posY = startPosY - math.ceil(self.awardsIndex/6)*120

	local lightImg
	if element[1] == 'card' then
		lightImg = ccui.ImageView:create("uires/ui_new/common/guang3.png")
		lightImg:setPosition(cc.p(posX, posY))
		lightImg:setScale(0.6)
		self.itembg:addChild(lightImg,0)
		local act = cc.RepeatForever:create(cc.RotateBy:create(2.5,360))
		lightImg:runAction(act)
		lightImg:setOpacity(0)
	end
		
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayObj, self.itembg)
	cell.awardBgImg:setPosition(cc.p(posX, posY))
	cell.awardBgImg:setScale(0.9)

	cell.awardBgImg:setCascadeOpacityEnabled(true)
	cell.awardBgImg:setOpacity(0)

	local act = cc.Sequence:create(cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
		if element[1] == 'card' then
			local role = ClassRoleObj.new(element[2], element[3])
			self.role = role
			self:singleUnderPuple(role)
			if lightImg then
				lightImg:setOpacity(255)
			end
		else
			self:goAction()
		end
	end))
	cell.awardBgImg:runAction(act)
end

function TavernAnimateUI:singleUnderPuple(role)

	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	cardeffect:setVisible(false)

	self.againBtn:setVisible(false)
	self.godieBtn:setVisible(false)
	self.costbg:setVisible(false)

	local nodeSize = hnode:getContentSize()
	local sz = self.modebg:getParent():getContentSize()
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))
	self.modebg:addChild(hnode)
	self.modebg:setVisible(true)
	self.modebg:addClickEventListener(function ()
		hnode:runAction(cc.Sequence:create(cc.Spawn:create(
			cc.FadeOut:create(0.4), cc.ScaleTo:create(0.4, 1), cc.RotateTo:create(0.4, 720)),
			cc.CallFunc:create(function()
				hnode:removeFromParent()
				self.againBtn:setVisible(true)
				self.godieBtn:setVisible(true)
				self.costbg:setVisible(true)
				self.modebg:setVisible(false)
				self:goAction()
		end)))
	end)

	AudioMgr.playEffect("media/effect/normal_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
				end)
				if heroSpine ~= nil then
					role:playSound('sound')
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
						end
					end)
				end
			end)))
end

function TavernAnimateUI:onFinish(black_bg, spine)
	local sz = black_bg:getContentSize()

	if recruitAudioId then
		AudioMgr.stopEffect(recruitAudioId)
		recruitAudioId = nil;
	end

	spine:runAction(cc.Sequence:create(
		cc.Spawn:create(cc.ScaleTo:create(0.4, 8), cc.FadeOut:create(0.4)),
		cc.DelayTime:create(1), 
    	cc.CallFunc:create(function()

      		black_bg:removeFromParent()
                	-- 烟花爆竹
			math.randomseed(os.clock()*10000)
			local num = math.random(3,4)
			for i=1,num do
				local totaldelaytime = 0
				local delaytime = math.random(1,3)
				totaldelaytime = totaldelaytime + 1/delaytime						
				self.mask_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(totaldelaytime),cc.CallFunc:create(
					function ()
						local winSize = cc.Director:getInstance():getWinSize()
						local scale = math.random(1,2)
						local list = math.random(1,5)
						local particle = cc.ParticleSystemQuad:create("particle/ui_tavern_fireworks_"..list..".plist")
						particle:setAutoRemoveOnFinish(true)
						local posx = math.random(0,winSize.width)
						local posy = math.random(200,winSize.height+200)
						particle:setPosition(cc.p(posx,posy))
						particle:setScale(scale)
						self.mask_bg:addChild(particle,1)
					end))))
			end
			self:goAction()
      	end)))
end

return TavernAnimateUI