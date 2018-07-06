local RoleTupoInfoUI = class("RoleTupoInfoUI", BaseUI)

local leftInterval = 5
local verticalInterval = 15
local infoInterval = 6
local fengexian_height = 3
function RoleTupoInfoUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_ROLETUPOINFO
	self.obj = obj
end

function RoleTupoInfoUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img_1')
    self:adaptUI(bgimg, bgimg1)
    local bgimg2 = bgimg1:getChildByName('bg_img_2')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleTupoInfoUI()
        end
    end)

    local titletx = bgimg2:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr_new('ROLE_TF_TITLE'))
    local node = self:genTalent()
    local bgimg3 = bgimg2:getChildByName('bg_img_3')

    local sv = bgimg3:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    if node:getContentSize().height > sv:getContentSize().height then
        sv:setInnerContainerSize(cc.size(sv:getContentSize().width,node:getContentSize().height))
    end
    node:setAnchorPoint(cc.p(0, 0))
    node:setPosition(cc.p(0,0))
    sv:addChild(node)
end

function RoleTupoInfoUI:genTalent()
	local ret = cc.Node:create()

	local txTalentinfo = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
	txTalentinfo:setTextColor(cc.c3b(255,247,228))
	txTalentinfo:enableOutline(cc.c4b(78,49,17, 255), 1)
	txTalentinfo:enableShadow(cc.c4b(78,49,17, 255), cc.size(0, -1), 0)
	txTalentinfo:setPosition(cc.p(leftInterval+5, verticalInterval))
	txTalentinfo:setAnchorPoint(cc.p(0, 0))
	txTalentinfo:setString(GlobalApi:getLocalStr_new('ROLE_TF_INFO'))

	local rt = xx.RichText:create()
	rt:setContentSize(cc.size(350, 470))
	rt:setAnchorPoint(cc.p(0, 0))
	rt:setPosition(cc.p(leftInterval, txTalentinfo:getContentSize().height + verticalInterval + infoInterval))

	local innateGroupId = self.obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
	local teamnum = 1
	for i = 2, 12 do
		local innateid = groupconf[tostring('level' .. i-1)]
		local specialtab = groupconf['highlight']
		local teamtab = groupconf['teamvaluegroup']
		local effect =groupconf[tostring('value' .. i-1)]
		local innateconf = GameData:getConfData('innate')[innateid]
		local teamheroID = groupconf['teamheroID']
		local tx1 = ''
		local tx2 = ''
		local tx3 = ''

		local re1 = xx.RichTextLabel:create(tx1, 18)
		local re3 = xx.RichTextLabel:create(tx3, 18)
		local re2 = xx.RichTextLabel:create(tx2, 18)

		local str = string.format(GlobalApi:getLocalStr_new("ROLE_TUPO_TITLE"),i)
		if innateid < 1000 then
			tx1 = innateconf['desc'] .. effect .. '%'
			if innateconf['type'] ~= 2 then
				tx1 = innateconf['desc'] .. effect
			end
			tx3 =  '【' .. str ..'】   '
		else
            tx1 = groupconf[tostring('specialDes'..innateid%1000)]
			tx3 =  '【' .. str ..'】   '
		end
		local n  = GlobalApi:tableFind(specialtab,i-1)
		local talentLevel = self.obj:getTalent()

		if  talentLevel >= i -1 then
			re3:setColor(COLOR_TYPE.YELLOW1)
			re3:setStroke(COLOROUTLINE_TYPE.YELLOW1, 2)

			re1:setString(tx1)
			re2:setString(tx2.. '\n')
			re3:setString(tx3)

			rt:addElement(re3)

			if n == 0 then
				re1:setColor(COLOR_TYPE.GREEN1)
				re1:setStroke(COLOROUTLINE_TYPE.YELLOW1, 2)
			else
				re1:setColor(COLOR_TYPE.RED1)
				re1:setStroke(COLOROUTLINE_TYPE.YELLOW1, 2)
				local re4 = xx.RichTextImage:create('uires/ui_new/common/star_awake.png')
				re4:setScale(0.9)
				rt:addElement(re4)
			end

			rt:addElement(re1)
			if s ~= 0 then
				rt:addElement(re6)
			end
			rt:addElement(re2)
		else
			re1:setColor(COLOR_TYPE.GRAY1)
			re3:setColor(COLOR_TYPE.GRAY1)
			re2:setColor(COLOR_TYPE.GRAY1)

			re1:setStroke(COLOROUTLINE_TYPE.GRAY1, 2)
			re3:setStroke(COLOROUTLINE_TYPE.GRAY1, 2)
			re2:setStroke(COLOROUTLINE_TYPE.GRAY1, 2)

			re1:setString(tx1)
			re2:setString(tx2.. '\n')
			re3:setString(tx3)
			rt:addElement(re3)

			if n ~= 0 then
				local re4 = xx.RichTextImage:create('uires/ui_new/common/star_awake_bg.png')
				re4:setScale(0.9)
				rt:addElement(re4)
			end
			rt:addElement(re1)
			rt:addElement(re2)

		end
	end
	rt:setRowSpacing(6)
 	rt:format(true)
 	local rteSize = rt:getElementsSize()
 	rt:setContentSize(rteSize)

	local frame = ccui.ImageView:create('uires/ui_new/common/bg1_alpha.png')
	frame:setScale9Enabled(true)
	frame:setAnchorPoint(cc.p(0, 0))

	local frameHeight = rteSize.height + verticalInterval * 2 + infoInterval + txTalentinfo:getContentSize().height
	frame:setContentSize(cc.size(bgWidth, frameHeight))
	frame:addChild(rt)
	frame:addChild(txTalentinfo)


	local sumHeight = frameHeight
	ret:setContentSize(cc.size(bgWidth, sumHeight))

	ret:addChild(frame)
	return ret
end

return RoleTupoInfoUI