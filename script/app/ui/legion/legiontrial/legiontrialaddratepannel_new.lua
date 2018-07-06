-- 文件：秘境矿洞倍率加成
-- 创建：zzx
-- 日期：2017-12-05

local LegionTrialAddRatePannelNewUI = class("LegionTrialAddRatePannelNewUI", BaseUI)

function LegionTrialAddRatePannelNewUI:ctor()
    self.uiIndex        = GAME_UI.UI_LEGION_TRIAL_ADD_RATE_NEW_PANNEL
end

function LegionTrialAddRatePannelNewUI:init()
	local bg_img        = self.root:getChildByName("bg_img")
    local alpha_img     = bg_img:getChildByName("alpha_img")

    self:adaptUI(bg_img, alpha_img)

    local main_img      = alpha_img:getChildByName("main_img")
    
    local close_btn     = main_img:getChildByName("close_btn")

    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialAddRatePannelUI()
        end
    end)

    local title_tx      = main_img:getChildByName('title_tx')

    title_tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC24'))

    local listView      = main_img:getChildByName('list_sv')

    listView:setScrollBarEnabled(false)

    local cloneCell    = main_img:getChildByName('clone_cell')

    self.listView      = listView
    self.cloneCell     = cloneCell

    self:updateListView()
end

function LegionTrialAddRatePannelNewUI:updateListView()
    local conf          = GameData:getConfData('trialcoinincreasetype')

    for _, v in pairs (conf) do
        local cell      = self.cloneCell:clone()

        cell:setVisible(true)

        local frame     = cell:getChildByName('frame')
        local ico       = frame:getChildByName('ico')

        local descBg    = cell:getChildByName('desc_bg')
        local descTx    = descBg:getChildByName('desc_tx')

        local addTx     = cell:getChildByName('add_tx')

        ico:loadTexture('uires/icon/legiontrial/' .. v.icon)
        descTx:setString( GlobalApi:getGeneralText( v.desc ) )
        addTx:setString( '+' .. v.awardIncrease )

        self.listView:pushBackCustomItem(cell)
    end
end

return LegionTrialAddRatePannelNewUI