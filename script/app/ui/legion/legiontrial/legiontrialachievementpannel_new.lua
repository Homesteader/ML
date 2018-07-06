-- 文件：秘境矿洞周成就奖励
-- 创建：zzx
-- 日期：2017-12-06

local LegionTrialAchievementPannelNewUI = class("LegionTrialAchievementPannelNewUI", BaseUI)
local ClassItemCell 					= require('script/app/global/itemcell')

function LegionTrialAchievementPannelNewUI:ctor(trial,callBack)
    self.uiIndex        		= GAME_UI.UI_LEGION_TRIAL_ACHIEVEMENT_NEW_PANNEL

    self.trial 					= trial
    self.callBack 				= callBack

    self.legionTrialAchievement = GameData:getConfData('trialachievement')
    self.legionTrialBaseConfig 	= GameData:getConfData('trialbaseconfig')
end

function LegionTrialAchievementPannelNewUI:init()
	local bg_img        = self.root:getChildByName("bg_img")
    local alpha_img     = bg_img:getChildByName("alpha_img")

    self:adaptUI(bg_img, alpha_img)

    local main_img      = alpha_img:getChildByName("main_img")
    
    local close_btn     = main_img:getChildByName("close_btn")

    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialAchievementPannelUI()
        end
    end)

    local titleTx 		= main_img:getChildByName('title_tx')
    local desc1Tx 		= main_img:getChildByName('desc_1_tx')

    titleTx:setString(GlobalApi:getLocalStr_new('STR_TRAIL_DESC_5'))
    desc1Tx:setString(GlobalApi:getLocalStr_new('STR_TRAIL_DESC_6'))

    local scoreBg 		= main_img:getChildByName('score_bg')

    local scoreDescTx 	= scoreBg:getChildByName('score_desc_tx')
    local scoreNumTx 	= scoreBg:getChildByName('score_num_tx')

    scoreDescTx:setString(GlobalApi:getLocalStr_new('STR_TRAIL_DESC_7'))
    scoreNumTx:setString( self.trial.week_score )

    local listView      = main_img:getChildByName('list_sv')

    listView:setScrollBarEnabled(false)

    local cloneCell    = main_img:getChildByName('clone_cell')

    self.listView      = listView
    self.cloneCell     = cloneCell

    self:updateListView()
end

function LegionTrialAchievementPannelNewUI:updateListView()
    local conf          = self.legionTrialAchievement

    local baseConf 		= self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]
    local achieveId 	= baseConf['achievementId']

    local arr 			= conf[achieveId]

    if not arr then
    	return
    end

    -- PrintT(arr, true)

    for _, v in pairs (arr) do
        local cell      = self.cloneCell:clone()

        cell:setVisible(true)

        if type(v) == 'table' then
	        self:updateItem( cell , v )

	        self.listView:pushBackCustomItem(cell)
	    end
    end
end

function LegionTrialAchievementPannelNewUI:checkGet( id_ )
	local achObj 			= self.trial.achievement
	local isFind 			= false

	if achObj then
		for k, v in pairs (achObj) do
			if tonumber(v) == id_ then
				isFind = true
				break
			end
		end
	end

	return isFind
end

function LegionTrialAchievementPannelNewUI:updateItem( cell_ , confobj_ )
	local needScoreTx 		= cell_:getChildByName('need_score_tx')
	local unfinishTx 		= cell_:getChildByName('unfinish_tx')
	local finishIco 		= cell_:getChildByName('finish_ico')
	local okBtn  			= cell_:getChildByName('ok_btn')
	local okBtnTx 			= okBtn:getChildByName('ok_tx')

	okBtnTx:setString( GlobalApi:getLocalStr('STR_GET') )
	unfinishTx:setString( GlobalApi:getLocalStr('STR_ONDOING') )

	local aId 				= tonumber(confobj_['id'])
	local weekScore 		= self.trial.week_score
	local needScore 		= confobj_['needIntegral']

	local needScoreStr 		= string.format(GlobalApi:getLocalStr_new('STR_TRAIL_DESC_8'), needScore)

	needScoreTx:setString( needScoreStr )

	local displayAwards 	= DisplayData:getDisplayObjs(confobj_['award'])

	for i, v in pairs(displayAwards) do
		local awardCell 	= ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, cell_)

        awardCell.awardBgImg:setPosition(cc.p(260 + (i - 1) * 70, 45))
        awardCell.awardBgImg:setScale(0.7)
	end

	if self:checkGet(aId) then
		finishIco:setVisible(true)
		unfinishTx:setVisible(false)
		okBtn:setVisible(false)
	else
		if weekScore >= needScore then
			finishIco:setVisible(false)
			unfinishTx:setVisible(false)
			okBtn:setVisible(true)
		else
			finishIco:setVisible(false)
			unfinishTx:setVisible(true)
			okBtn:setVisible(false)
		end		
	end

	local function requestCallBack( jsonData )
		if jsonData.awards then
            GlobalApi:parseAwardData(jsonData.awards)
            GlobalApi:showAwardsCommon(jsonData.awards,nil,nil,true)
		end

		finishIco:setVisible(true)
		unfinishTx:setVisible(false)
		okBtn:setVisible(false)

		local len = #self.trial.achievement
		self.trial.achievement[len + 1] = aId
	end

	okBtn:setTouchEnabled(true)
	okBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:legionTrialGetWeekAchievementAwardFromServer(aId,requestCallBack)
        end
	end)
end

return LegionTrialAchievementPannelNewUI
