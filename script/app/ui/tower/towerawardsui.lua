-- 爬塔奖励界面
local TowerAwardsUI = class("TowerAwardsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TowerAwardsUI:ctor(data)
	self.uiIndex = GAME_UI.UI_TOWER_AWARDS
	self.data = data
end

function TowerAwardsUI:init()
	local bgImg = self.root:getChildByName('bg_img')
	local bgImg1 = bgImg:getChildByName('bg_img1')
	local bgImg2 = bgImg1:getChildByName('bg_img2')
	local bgImg3 = bgImg2:getChildByName('bg_img3')

	local closeBtn = bgImg1:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideSweepAwardsUI()
        end
    end)

    local okBtn = bgImg1:getChildByName('ok_btn')
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideSweepAwardsUI()
        end
    end)

    local titleTx = bgImg1:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr_new('TOWER_SWEEP_SWARD_TITLE'))

    self.sweepFloorTx = bgImg2:getChildByName('sweep_floor_tx')

    local coinBg = bgImg3:getChildByName('coin_img')
    self.coinNumTx = coinBg:getChildByName('num_tx')

    local goldBg = bgImg3:getChildByName('gold_img')
    self.goldNumTx = goldBg:getChildByName('num_tx')

    self.itemListSv = bgImg3:getChildByName('item_list_sv')
    self.itemListSv:setScrollBarEnabled(false)

    self:update()
end

function TowerAwardsUI:update()
	-- 层数
	self.sweepFloorTx:setString(string.format(GlobalApi:getLocalStr_new('TOWER_SWEEP_FLOOR'), self.data.old_floor+1, self.data.cur_floor))

	self.itemListSv:setScrollBarEnabled(false)
	self.itemListSv:setInertiaScrollEnabled(true)
	self.itemListSv:removeAllChildren()

	local contentWidget = ccui.Widget:create()
    self.itemListSv:addChild(contentWidget)
    contentWidget:removeAllChildren()

	local itemCount = 1

	local awards = self.data.awards
	for i = 1,#awards do
		if awards[i][1] == 'user' then
			if awards[i][2] == 'cash' then
				-- 塔币
				self.coinNumTx:setString(awards[i][3])
			elseif awards[i][2] == 'soul' then
				-- 金币
				self.goldNumTx:setString(awards[i][3])
			end
		elseif awards[i][1] == 'material' then
			-- 道具
        	local displayData = DisplayData:getDisplayObj(awards[i])
        	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayData, contentWidget)
        	tab.awardBgImg:setScale(0.8)

        	local contentsize = tab.awardBgImg:getContentSize()
        	local posx = (itemCount - 1) * (contentsize.width * 0.8 + 3) + contentsize.width * 0.8/2
	    	tab.awardBgImg:setPosition(cc.p(posx, contentsize.height * 0.8/2))
	    	contentWidget:setPosition(cc.p(0, 0))
	    	itemCount = itemCount + 1
		end
	end
end

return TowerAwardsUI