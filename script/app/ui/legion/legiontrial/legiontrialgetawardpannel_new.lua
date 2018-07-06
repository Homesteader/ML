-- 文件：秘境矿洞领取奖励
-- 创建：zzx
-- 日期：2017-12-06

local LegionTrialGetAwardPannelNewUI = class("LegionTrialGetAwardPannelNewUI", BaseUI)

function LegionTrialGetAwardPannelNewUI:ctor(trial,curChoosePage,callBack)
    self.uiIndex                        = GAME_UI.UI_LEGION_TRIAL_GET_AWARD_NEW_PANNEL
    self.trial                          = trial
    self.curChoosePage                  = curChoosePage
    self.callBack                       = callBack

    self.legionTrialCoinIncreaSetype    = GameData:getConfData('trialcoinincreasetype')
    self.legionTrialBaseConfig          = GameData:getConfData('trialbaseconfig')
end

function LegionTrialGetAwardPannelNewUI:init()
    local activeBgImg       = self.root:getChildByName("active_bg_img")
    local activeImg         = activeBgImg:getChildByName("active_img")

    self:adaptUI(activeBgImg, activeImg)


    self.neiBgImg           = activeImg:getChildByName('nei_bg_img')
    local closeBtn          = activeImg:getChildByName("close_btn")

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
        end
    end)

    local titleTx           = activeImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC16'))

    local okBtn             = self.neiBgImg:getChildByName('ok_btn')
    local okTx              = okBtn:getChildByName('ok_tx')

    okTx:setString(GlobalApi:getLocalStr('STR_GET'))

    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            local function callBack1(data)
                LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
                self.callBack(data)
            end

            LegionTrialMgr:legionTrialGetExploreAwardFromServer(self.curChoosePage,callBack1)
        end
    end)

    local cancleBtn         = self.neiBgImg:getChildByName('cancel_btn')
    local cancelTx          = cancleBtn:getChildByName('cancel_tx')

    cancelTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC17'))

    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
        end
    end)

    local infoBg1           = self.neiBgImg:getChildByName('info_bg_1')

    local descTx1           = infoBg1:getChildByName('desc_tx')
    local valueTx1          = infoBg1:getChildByName('value_tx')
    local addTx1            = valueTx1:getChildByName('add_tx')

    local infoBg2           = self.neiBgImg:getChildByName('info_bg_2')

    local descTx2           = infoBg2:getChildByName('desc_tx')
    local valueTx2          = infoBg2:getChildByName('value_tx')
    local addTx2            = valueTx2:getChildByName('add_tx')

    descTx1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC8'))
    descTx2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC9'))

    local round             = self.trial.round
    local coins             = round[tostring(self.curChoosePage)].coins
    local temp              = {}
    local hasGetNum         = 0

    for i = 1,9 do
        temp[i] = coins[tostring(i)]
        if temp[i] > 0 then
            hasGetNum = hasGetNum + 1
        end
    end

    local rates             = LegionTrialMgr:getLegionTrialAddAwardRate(temp)

    -- 奖励倍率
    local baseRateValue     = LegionTrialMgr:getLegionTrialBaseRate()
    local addRateValue      = 0

    if rates[tostring(4)] == 1 then
        addRateValue        = 2
    else
        for i = 1,3 do
            if rates[tostring(i)] > 0 then
                local awardIncrease = self.legionTrialCoinIncreaSetype[i].awardIncrease
                addRateValue = addRateValue + rates[tostring(i)] * awardIncrease
            end
        end
    end

    valueTx1:setString( baseRateValue )
    addTx1:setString( string.format("+%.1f", addRateValue) )
    addTx1:setPositionPercent(cc.p(1, 0.5))

    -- 奖励积分
    local legionTrialBaseConfigData = self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]

    local coinBaseValue             = tonumber(legionTrialBaseConfigData.coinBaseAward)
    local coinAddValue              = legionTrialBaseConfigData.coinBaseAward * addRateValue

    valueTx2:setString( coinBaseValue )
    addTx2:setString( string.format("+%.1f", coinAddValue) )
    addTx2:setPositionPercent(cc.p(1, 0.5))
end

return LegionTrialGetAwardPannelNewUI