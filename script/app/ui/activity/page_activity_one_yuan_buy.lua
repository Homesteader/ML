local ActivityOneYuanBuyUI = class("ActivityOneYuanBuyUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActivityOneYuanBuyUI:ctor(data)
	self.uiIndex = GAME_UI.UI_ACTIVITY_ONE_YUAN_BUY
    self.data = data
    UserData:getUserObj().activity.money_buy = self.data.money_buy
end

function ActivityOneYuanBuyUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            UserData:getUserObj().activity.money_buy = self.data.money_buy
            MainSceneMgr:hideOneYuanBuyUI()
        end
    end)
    self.closebtn = closebtn
    self.bgimg2 = bgimg2
    self:adaptUI(bgimg1, bgimg2)
    
    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(510, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES1'), 25, cc.c4b(254,227,134,255))
	re1:setStroke(cc.c4b(140,56,0,255),1)
    --re1:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextImage:create('uires/ui/onemoneybuy/500.png')

	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES2'), 25, cc.c4b(254,227,134,255))
	re3:setStroke(cc.c4b(140,56,0,255),1)
    --re3:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(340,277))
    self.bgimg2:addChild(richText)
    richText:format(true)

    -- 
    local buyBtn = self.bgimg2:getChildByName('buy_btn')
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rechageData = GameData:getConfData('recharge')
            if not rechageData[9] then
                return
            end
            if self.data.money_buy.status == 0 then -- 充值
                self.buyBtn:setTouchEnabled(false)
                self.buyBtn:setBright(false)
                --self.closebtn:setTouchEnabled(false)
                local function callBack(obj)
                    if obj.code == 0 then
                        self.data.money_buy.status = 1
                        self:refreshBtnStatus()
                        --self.closebtn:setTouchEnabled(true)
                    else
                        self.buyBtn:setTouchEnabled(true)
                        self.buyBtn:setBright(true)
                        --self.closebtn:setTouchEnabled(true)
                    end
                end
                RechargeMgr:specialRecharge(9,callBack)
                self.buyBtn:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
					self.buyBtn:setTouchEnabled(true)
                    self.buyBtn:setBright(true)
                    --self.closebtn:setTouchEnabled(true)
                end)))
            end
        end
    end)
    self.buyBtn = buyBtn
    self.buyBtnTx = buyBtn:getChildByName('tx')

    -- 
    local avOneYuanBuyConf = GameData:getConfData("avoneyuanbuy")
    for i = 1,4 do
        local icon = self.bgimg2:getChildByName("icon_" .. i)

        local awardData = avOneYuanBuyConf[i].awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]

        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell.awardBgImg:setPosition(cc.p(94/2, 94/2))
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        -- 名字
        local richTextName = xx.RichText:create()
	    richTextName:setContentSize(cc.size(510, 40))

        local color = COLOR_TYPE.RED
        if i == 1 then
            color = COLOR_TYPE.BLUE
        elseif i == 2 then
            color = COLOR_TYPE.GREEN
        elseif i == 3 then
            color = COLOR_TYPE.RED
        else
            color = COLOR_TYPE.YELLOW
        end

	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES' .. i + 3), 24, color)
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES3'), 20, COLOR_TYPE.ORANGE)
        re2:setFont('font/gamefont.ttf')

	    richTextName:addElement(re1)
	    richTextName:addElement(re2)

        richTextName:setAlignment('middle')
        richTextName:setVerticalAlignment('middle')

	    richTextName:setAnchorPoint(cc.p(0.5,0.5))
	    richTextName:setPosition(cc.p(icon:getContentSize().width/2,-22))
        icon:addChild(richTextName)
        richTextName:format(true)
    end

    self.getBtns = {}
    for i = 1,4 do
        local getBtn = bgimg2:getChildByName('get_btn_' .. i)
        getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES9'))
        table.insert(self.getBtns,getBtn)
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.money_buy.status == 1 then -- 领取
                    local function callBack()
                        local args = {
                            id = i
                        }
                        MessageMgr:sendPost('get_money_buy_reward','activity',json.encode(args),function (jsonObj)
                        print(json.encode(jsonObj))
                            if jsonObj.code == 0 then
                                local awards = jsonObj.data.awards
                                if awards then
                                    GlobalApi:parseAwardData(awards)
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                                end
                                local costs = jsonObj.data.costs
                                if costs then
                                    GlobalApi:parseAwardData(costs)
                                end
                                self.data.money_buy.status = 2
                                self:refreshBtnStatus()
                            elseif jsonObj.code == 100 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
                            end
                        end)
                    end

                    promptmgr:showMessageBox(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES11'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        callBack()
                    end)

                end
            end
        end)
    end
    
    local btn = HelpMgr:getBtn(25)
    btn:setScale(0.9)
    btn:setPosition(cc.p(50 ,422))
    bgimg2:addChild(btn)

    self:refreshBtnStatus()
end

-- sdk购买成功
function ActivityOneYuanBuyUI:buySuccess()

end

-- sdk购买失败
function ActivityOneYuanBuyUI:buyFail()
    
end

-- 刷新按钮状态
function ActivityOneYuanBuyUI:refreshBtnStatus()
    for i = 1,4 do
        self.getBtns[i]:setVisible(false)
    end
    if self.data.money_buy.status == 0 then -- 待充值
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(true)
        self.buyBtn:setTouchEnabled(true)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES8'))
    elseif self.data.money_buy.status == 1 then -- 待领取
        self.buyBtn:setVisible(false)
        for i = 1,4 do
            self.getBtns[i]:setVisible(true)
        end
    elseif self.data.money_buy.status == 2 then -- 已领取
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(false)
        self.buyBtn:setTouchEnabled(false)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES10'))
    end
end

return ActivityOneYuanBuyUI