local CityCraftUI = class("CityCraftUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CityCraftUI:ctor(flag)
    self.uiIndex = GAME_UI.UI_CITYCRAFT
    self.myPosition = 32
    self.challenge = 0
    self.buy = 0
    self.moveFlag = false
    self.actFlag = false
    self.showOffice = flag
    self.conf = GameData:getConfData("position")
end

function CityCraftUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local citycraftAlphaImg = self.root:getChildByName("citycraft_alpha_img")

    -- 添加战报按钮提醒mark
    local enterBtn = citycraftAlphaImg:getChildByName("report_btn")
    if not self.mark then
        local mark = ccui.ImageView:create('uires/ui/common/new_img.png')
		enterBtn:addChild(mark)
		mark:setPosition(cc.p(88, 88))

        self.mark = mark
    end
    self.mark:setVisible(UserData:getUserObj():getSignByType('country_fight_report'))


    self:adaptUI(citycraftAlphaImg)
    local closeBtn = citycraftAlphaImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winsize.width, winsize.height))
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        CityCraftMgr:hideCityCraft()
        --更新皇城按钮mark
        if CountryMgr then
            CountryMgr:updateCountry()
        end
    end)

    local mapNode = citycraftAlphaImg:getChildByName("map_node")
    self.mapNode = mapNode
    local map1 = mapNode:getChildByName("map_1")
    local map2 = mapNode:getChildByName("map_2")
    local size1 = map1:getContentSize()
    local size2 = map2:getContentSize()
    local limitLW = winsize.width - size1.width - size2.width
    local limitRW = 0
    local limitLH = winsize.height - size1.height
    local limitRH = 0
    local preMovePos = nil
    local movePos = nil
    local bgImgDiffPos = nil
    local bgImgPosX = 0
    local bgImgPosY = 0
    local beganPos = nil
    citycraftAlphaImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            if self.actFlag then
                self.mapNode:stopAllActions()
                self.actFlag = false
                bgImgPosX, bgImgPosY = self.mapNode:getPosition()
            end
            preMovePos = movePos
            movePos = sender:getTouchMovePosition()
            if preMovePos then
                bgImgDiffPos = cc.p(movePos.x - preMovePos.x, movePos.y - preMovePos.y)
                local targetPos = cc.p(bgImgPosX + bgImgDiffPos.x, bgImgPosY + bgImgDiffPos.y)
                if targetPos.x > limitRW then
                    targetPos.x = limitRW
                end
                if targetPos.x < limitLW then
                    targetPos.x = limitLW
                end
                if targetPos.y < limitLH then
                    targetPos.y = limitLH
                end
                if targetPos.y > limitRH then
                    targetPos.y = limitRH
                end
                bgImgPosX = targetPos.x
                bgImgPosY = targetPos.y
                mapNode:setPosition(targetPos)
            end
            if not self.moveFlag then
                local dis = cc.pGetDistance(beganPos, movePos)
                if dis > 10 then
                    self.moveFlag = true
                end
            end
        elseif eventType == ccui.TouchEventType.began then
            preMovePos = nil
            movePos = nil
            beganPos = sender:getTouchBeganPosition()
        elseif eventType == ccui.TouchEventType.ended then
            self.moveFlag = false
        elseif eventType == ccui.TouchEventType.canceled then
            self.moveFlag = false
        end
    end)

    local cities = {}
    self.cityShake = false
    for i = 1, 32 do
        local city = mapNode:getChildByName("city_" .. i)
        local sprite = mapNode:getChildByName("sprite_" .. i)
        sprite:setLocalZOrder(2)
        local nameBg = mapNode:getChildByName("name_bg_" .. i)
        nameBg:setLocalZOrder(3)
        local posLabel = nameBg:getChildByName("pos_tx")
        local titleLabel = nameBg:getChildByName("title_tx")
        posLabel:setString(self.conf[i].posName)
        if i == 1 then
            titleLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
        else
            titleLabel:setString(self.conf[i].title)
        end
        cities[i] = city
        city:setSwallowTouches(false)
        city:addClickEventListener(function ()
            if self.moveFlag or self.cityShake then
                return
            end
            AudioMgr.PlayAudio(11)
            self.cityShake = true
            sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.9), cc.EaseElasticOut:create(cc.ScaleTo:create(0.8, 1)), cc.CallFunc:create(function()
               CityCraftMgr:showCityCraftOffice(self.myPosition, i)
               self.cityShake = false
            end)))
        end)
    end

    local arrowImg = mapNode:getChildByName("arrow_img")
    arrowImg:setLocalZOrder(4)

    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headCell.awardBgImg:loadTexture(RoleData:getMainRole():getBgImg())
    headCell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
    headCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
    headCell.awardBgImg:setPosition(cc.p(20, 80))
    arrowImg:addChild(headCell.awardBgImg)

    local infoNode = citycraftAlphaImg:getChildByName("info_node")
    local reportBtn = citycraftAlphaImg:getChildByName("report_btn")
    reportBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        MessageMgr:sendPost("get_report","country", "{}", function (response)
            if response.code == 0 then
                CityCraftMgr:showCityCraftReport(response.data.reports)
                UserData:getUserObj().tips.country_report = nil
                self.mark:setVisible(UserData:getUserObj():getSignByType('country_fight_report'))
            end
        end)
    end)
    local rankBtn = citycraftAlphaImg:getChildByName("rank_btn")
    rankBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        RankingListMgr:showRankingListMain(4,1)
    end)
    local shopBtn = citycraftAlphaImg:getChildByName("shop_btn")
    shopBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        local positionConf = GameData:getConfData('position')[self.myPosition]
        MainSceneMgr:showShop(71,{min = 71,max = 72},positionConf.position)
    end)

    local salaryTime = GlobalApi:getGlobalValue("countrySalaryTime")
    local tab = string.split(salaryTime, '-')
    local descBgImg = citycraftAlphaImg:getChildByName("desc_bg_img")
    local descTx1 = descBgImg:getChildByName('desc_tx_1')
    local descTx2 = descBgImg:getChildByName('desc_tx_2')
    local descTx3 = descBgImg:getChildByName('desc_tx_3')
    descTx1:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT17"))
    descTx2:setString(GlobalApi:getGlobalValue("countryBalanceTime")..':00')
    descTx3:setString(GlobalApi:getLocalStr("STR_OFFICE_DESC_3"))
    descTx2:setPosition(cc.p(descTx1:getPositionX() + descTx1:getContentSize().width,descTx1:getPositionY()))
    descTx3:setPosition(cc.p(descTx2:getPositionX() + descTx2:getContentSize().width,descTx2:getPositionY()))
    local size = rankBtn:getContentSize()
    rankBtn:setPosition(cc.p(winsize.width - size.width*0.5,size.height/2))
    reportBtn:setPosition(cc.p(winsize.width - size.width*1.5,size.height/2))
    shopBtn:setPosition(cc.p(winsize.width - size.width*2.5,size.height/2))
    descBgImg:setPosition(cc.p(0,30))

    local infoBgImg = infoNode:getChildByName("info_bg_img")
    self.numTx1 = infoBgImg:getChildByName('num_tx_1')
    local numTx2 = infoBgImg:getChildByName('num_tx_2')
    self.officeLabel = infoBgImg:getChildByName("office_tx")
    self.officeImg = infoBgImg:getChildByName("office_img")
    local descTx1 = infoBgImg:getChildByName('desc_tx_1')
    local descTx2 = infoBgImg:getChildByName('desc_tx_2')
    local descTx3 = infoBgImg:getChildByName('desc_tx_3')
    self.salaryLabel = infoBgImg:getChildByName("salary_tx")
    self.timesLabel = infoBgImg:getChildByName("times_tx")
    numTx2:setString(tab[1]..':00-'..tab[2]..':00')
    descTx1:setString(GlobalApi:getLocalStr("STR_OFFICE_DESC_4")..'：')
    descTx2:setString(GlobalApi:getLocalStr("STR_OFFICE_DESC_1")..'：')
    descTx3:setString(GlobalApi:getLocalStr("STR_OFFICE_DESC_2")..'：')

    local maxChallengeTimes = GlobalApi:getGlobalValue("countryChallengeLimit")
    local addBtn = infoBgImg:getChildByName("add_btn")
    addBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        if self.buy == self.challenge then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("CHALLENGE_TIMES_FULL"), COLOR_TYPE.RED)
        else
            local vip = UserData:getUserObj():getVip()
            local maxBuy = GameData:getConfData("vip")[tostring(vip)].citycraftChallenge
            if self.buy >= maxBuy then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("TIMES_OVER_NEED_UPGRADE_VIP"), COLOR_TYPE.RED)
            else
                local buyConf = GameData:getConfData("buy")
                local needCash = 0
                if buyConf[self.buy + 1] then
                    needCash = buyConf[self.buy + 1].countryChallenge
                else
                    needCash = buyConf[#buyConf].countryChallenge
                end
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("LEGION_LEVELS_DESC13"), needCash, maxBuy - self.buy), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    local currCash = UserData:getUserObj():getCash()
                    if currCash < needCash then -- 元宝不足
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
                    else
                        MessageMgr:sendPost("buy", "country", "{}", function (response)
                            if response.code == 0 then
                                self.buy = self.buy + 1
                                CityCraftMgr.challengeTimes = maxChallengeTimes + self.buy - self.challenge
                                GlobalApi:parseAwardData(response.data.costs)
                                self:updateInfo()
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'), COLOR_TYPE.GREEN)
                            end
                        end)
                    end
                end)
            end
        end
    end)

    MessageMgr:sendPost("get_city","country", "{}", function (response)
        if response.code == 0 then
            self.myPosition = response.data.position
            self.buy = response.data.buy
            self.challenge = response.data.challenge
            self.salary = response.data.salary
            UserData:getUserObj():setCountryCount(response.data.challenge)
            CityCraftMgr.challengeTimes = maxChallengeTimes + self.buy - self.challenge
            local posx, posy = cities[self.myPosition]:getPosition()
            arrowImg:setVisible(true)
            arrowImg:setPosition(cc.p(posx, posy))
            arrowImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.MoveBy:create(0.5, cc.p(0, -10)))))
            self:updateInfo()
            bgImgPosX = winsize.width/2 - posx
            bgImgPosY = winsize.height/2 - posy
            if self.showOffice then
                self.mapNode:setPosition(cc.p(bgImgPosX, bgImgPosY))
                CityCraftMgr:showCityCraftOffice(self.myPosition, self.myPosition)
            else
                self:moveToTarget(bgImgPosX, bgImgPosY)
            end
            GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.CITYCRAFT)
        end
    end)

    local sprite4 = infoBgImg:getChildByName('sprite_4')
    local winSize = cc.Director:getInstance():getVisibleSize()
    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.CITY_CRAFT)
    btn:setScale(0.7)
    btn:setPosition(cc.p(sprite4:getPositionX() + sprite4:getContentSize().width/2 ,sprite4:getPositionY() + 2))
    infoBgImg:addChild(btn)
end

function CityCraftUI:updateInfo()
    if self.myPosition == 1 then
        self.officeLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
    else
        self.officeLabel:setString(self.conf[self.myPosition].title .. "(" .. self.conf[self.myPosition].posName ..  ")")
    end
    self.officeLabel:setTextColor(COLOR_QUALITY[self.conf[self.myPosition].quality])
    self.officeImg:setTexture("uires/ui/jadeseal/jadeseal_" .. 10 - self.conf[self.myPosition].position .. ".png")
    self.numTx1:setString(self.conf[self.myPosition].salary .. "/" .. GlobalApi:getLocalStr("STR_HOUR"))
    self.salaryLabel:setString(GlobalApi:toWordsNumber(self.salary))
    local maxChallengeTimes = GlobalApi:getGlobalValue("countryChallengeLimit")
    self.timesLabel:setString(GlobalApi:getLocalStr("FREE_TIMES_1") .. CityCraftMgr.challengeTimes .. "/" .. maxChallengeTimes)
end

function CityCraftUI:moveToTarget(x, y)
    local time = math.sqrt( x*x + y*y )/1400
    self.mapNode:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(x, y)), cc.CallFunc:create(function()
        self.actFlag = false
    end)))
    self.actFlag = true
end

return CityCraftUI
