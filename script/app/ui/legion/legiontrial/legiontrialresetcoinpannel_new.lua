-- 文件：秘境矿洞硬币重置
-- 创建：zzx
-- 日期：2017-12-05

local LegionTrialResetCoinPannelNewUI = class("LegionTrialResetCoinPannelNewUI", BaseUI)

function LegionTrialResetCoinPannelNewUI:ctor(trial,round,index,callBack,callBack2)
    self.uiIndex    = GAME_UI.UI_LEGION_TRIAL_RESET_COIN_NEW_PANNEL
    self.trial      = trial
    self.round      = round
    self.index      = index
    self.callBack   = callBack
    self.callBack2  = callBack2

    self.legiontTialCoins               = GameData:getConfData('trialcoins')
end

function LegionTrialResetCoinPannelNewUI:init()
    local activeBgImg       = self.root:getChildByName("active_bg_img")
    local activeImg         = activeBgImg:getChildByName("active_img")

    self:adaptUI(activeBgImg, activeImg)
    
    self.neiBgImg           = activeImg:getChildByName('nei_bg_img')

    local closeBtn          = activeImg:getChildByName("close_btn")

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
            self.callBack2()
        end
    end)

    local titleTx           = activeImg:getChildByName('title_tx')

    titleTx:setString(GlobalApi:getLocalStr_new('STR_TRAIL_DESC_2'))

    local cancleBtn         = self.neiBgImg:getChildByName('cancel_btn')
    local cancelBtnTx       = cancleBtn:getChildByName('cancel_tx')

    cancelBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC17'))

    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
            self.callBack2()
        end
    end)

    local reset_count       = self.trial['round'][tostring(self.round)]['reset_count']  -- 已经重置的次数

    -- print('reset_count = ' .. reset_count)

    local cost_cash         = GlobalApi:GetCostByType('trialCoinReset', reset_count + 1)

    local coinId            = self.trial.round[tostring(self.round)].coins[tostring(self.index)]

    local frame             = self.neiBgImg:getChildByName('frame')
    local icon              = frame:getChildByName('icon')

    icon:ignoreContentAdaptWithSize(true)
    icon:loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coinId].icon)

    local infoBg            = self.neiBgImg:getChildByName('info_bg')

    local descTx            = infoBg:getChildByName('desc_tx')
    local resIco            = infoBg:getChildByName('res_ico')
    local costTx            = infoBg:getChildByName('cost_tx')

    descTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_3') )

    resIco:ignoreContentAdaptWithSize(true)
    resIco:loadTexture('uires/ui/res/cash.png')

    costTx:setString( cost_cash )

    local noticeTx          = self.neiBgImg:getChildByName('notice_tx')

    noticeTx:setString( GlobalApi:getLocalStr_new('STR_TRAIL_DESC_4') )

    local okBtn             = self.neiBgImg:getChildByName('ok_btn')
    local okBtnTx           = okBtn:getChildByName('ok_tx')

    okBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC20'))

    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            local function callBack(data)
                LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
                
                self.callBack2()
                self.callBack(data,reset_count + 1)
            end

            if UserData:getUserObj():getCash() >= cost_cash then
                LegionTrialMgr:legionTrialResetExploreCoinFromServer(self.round,self.index,callBack)
            else
                UserData:getUserObj():cost('cash',cost_cash,function()
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH'),cost_cash), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        LegionTrialMgr:legionTrialResetExploreCoinFromServer(self.round,self.index,callBack)
                    end)
                end)
            end
        end
    end)
end

return LegionTrialResetCoinPannelNewUI