-- 爬塔成就界面
local TowerAchievementUI = class("TowerAchievementUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TowerAchievementUI:ctor(maxFloor, getRecord)
	self.uiIndex = GAME_UI.UI_TOWER_ACHIEVEMENT
	self.maxFloor = maxFloor
	self.getRecord = getRecord
end

function TowerAchievementUI:init()
	local bgImg = self.root:getChildByName('bg_img')
	local bgImg1 = bgImg:getChildByName('bg1_img')
	local bgImg2 = bgImg1:getChildByName('bg2_img')
	local bgImg3 = bgImg2:getChildByName('bg3_img')

	local closeBtn = bgImg1:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideAchievementUI()
        end
    end)

    local titleTx = bgImg1:getChildByName('title_tx')

    local maxLabelTx = bgImg2:getChildByName('max_label_tx')
    maxLabelTx:setString(GlobalApi:getLocalStr_new('TOWER_HISTORY_MAX_LABEL'))

    local maxFloorTx = bgImg2:getChildByName('max_floor_tx')
    maxFloorTx:setString(string.format(GlobalApi:getLocalStr_new('TOWER_FLOOR_FORMAT'), self.maxFloor))

    self.listSv = bgImg3:getChildByName('list_sv')
    self.listSv:setScrollBarEnabled(false)

    self.cellTab = {}

    self:update()
end

function TowerAchievementUI:update()
	self:refreshAchievemenList()
end

function TowerAchievementUI:updateCellInfo(cell, index)
	local bgImg1 = cell:getChildByName('bg1_img')
	local achieveConf = GameData:getConfData('towerresultaward')
	local conf = achieveConf[index]

	local itemList = bgImg1:getChildByName('list_sv')
	local getBtn = bgImg1:getChildByName('get_btn')
	local getBtnTx = getBtn:getChildByName('func_tx')
	local targetTx = bgImg1:getChildByName('target_tx')
	local iconImg = bgImg1:getChildByName('icon_img')
	local head_text = bgImg1:getChildByName('head_text')
	head_text:setString(GlobalApi:getLocalStr_new("TOWER_BTN_STR"))
	getBtnTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_LQ"))
	local finishImg = bgImg1:getChildByName('finish_img')
	local notfinsihTx = bgImg1:getChildByName('not_finsih')
	notfinsihTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_NOFINISH"))

	getBtn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:getAwards(index)
        end
	end)

	targetTx:setString(string.format(GlobalApi:getLocalStr_new('TOWER_ACHIEVEMENT_TARGET'), conf.number))

	-- 判断是否达成
	if self.maxFloor >= conf.number then
		getBtn:setVisible(true)

		-- 检查是否已领取
		local exist = false
		for i = 1,#self.getRecord do
			if self.getRecord[i] == index then
				exist = true
				break
			end
		end
		finishImg:setVisible(exist)
		getBtn:setVisible(not exist)
		notfinsihTx:setVisible(false)
	else
		finishImg:setVisible(false)
		getBtn:setVisible(false)
		notfinsihTx:setVisible(true)
	end

	itemList:setScrollBarEnabled(false)
	itemList:setInertiaScrollEnabled(true)
	itemList:removeAllChildren()

	local contentWidget = ccui.Widget:create()
    itemList:addChild(contentWidget)
    contentWidget:removeAllChildren()

	--奖励列表
	local awards = conf.award
	for i = 1,#awards do
		local displayData = DisplayData:getDisplayObj(awards[i])
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayData, contentWidget)
        tab.awardBgImg:setScale(0.8)

        local contentsize = tab.awardBgImg:getContentSize()
        local posx = (i - 1) * (contentsize.width * 0.8 + 6) + contentsize.width * 0.8/2
	    tab.awardBgImg:setPosition(cc.p(posx, contentsize.height/2))
	    contentWidget:setPosition(cc.p(0, 0))
	end
end

-- 刷新成就列表
function TowerAchievementUI:refreshAchievemenList()
	self.listSv:setInertiaScrollEnabled(true)
	self.listSv:removeAllChildren()

	local achieveConf = GameData:getConfData('towerresultaward')

	local contentWidget = ccui.Widget:create()
    self.listSv:addChild(contentWidget)
    contentWidget:removeAllChildren()
    local listSize = self.listSv:getContentSize()
    local total = #achieveConf
    for i = 1,total do
    	local node = cc.CSLoader:createNode("csb/towerachievementcell.csb")
	    local bgimg = node:getChildByName("bg_img")
	    bgimg:removeFromParent(false)

	    self.cellTab[i]= ccui.Widget:create()
        bgimg:setAnchorPoint(cc.p(0.5,0))
	    self.cellTab[i]:addChild(bgimg)
        self.cellTab[i].bg = bgimg
	    self:updateCellInfo(bgimg, i)

	    local contentsize = bgimg:getContentSize()
	    if math.ceil(i * (contentsize.height+5)) > self.listSv:getContentSize().height then
	        self.listSv:setInnerContainerSize(cc.size(contentsize.widht, i * (contentsize.height + 5)))
	    end

	    local posy = (total - i) * (contentsize.height + 5)
	    self.cellTab[i]:setPosition(cc.p(listSize.width/ 2, posy))
	    contentWidget:addChild(self.cellTab[i])
	    contentWidget:setPosition(cc.p(0, 0))
    end
end

function TowerAchievementUI:getAwards(index)
	local args = {
		id = index,
	}
    MessageMgr:sendPost('get_effort', 'tower', json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = response.data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end

            table.insert(self.getRecord, index)
            self:update()
        end
    end)
end

return TowerAchievementUI