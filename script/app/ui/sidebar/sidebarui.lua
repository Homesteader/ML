local SidebarUI = class("SidebarUI")

SidebarUI.root = nil
SidebarUI.runTab = {}
SidebarUI.runLock = {}
SidebarUI.runNotEnd = {}
SidebarUI.isHide = true
SidebarUI.isEnd = true
SidebarUI.showType = 0
SidebarUI.openCount = 0
SidebarUI.chatEnd = true
SidebarUI.chatMsgs = {}
SidebarUI.littleChatMsgs = {}
SidebarUI.littleChatRts = {}
local MAX_LITTLE_MSG = 5
local MAX_ACTIVITY_ICON_NUM = 8
SidebarUI.activityWidget = {}
function SidebarUI:setBtnFadeIn(btn,b)
    if b == true and self.isFadeIn == true then
        btn:setOpacity(0)
        btn:runAction(cc.FadeIn:create(0.5))
    end
end

function SidebarUI:setRightTopBtnsVisible(b)

    if self.rightTopNode then
        self.rtBtnsAcTionEnd = true
        self.rtBtnsHide = self.rtBtnsHide or false
        self.rightTopNode:setVisible(b)
        self:setBtnFadeIn(self.rightTopNode,b)
    end
end

function SidebarUI:setChatBtnVisible(b)
    if self.chatBtn then
        self.chatBtn:setVisible(b)
        self.chatBgImg:setVisible(b)
        self:setBtnFadeIn(self.chatBtn,b)
    end
end

function SidebarUI:setGiveheroBtnVisible(b)
    if self.giveHeroBtn and self.moreBtn then
        self.moreBtn:setVisible(b)
        self.giveHeroBtn:setVisible(b)
        self:setBtnFadeIn(self.giveHeroBtn,b)
    end
end

function SidebarUI:setFriendBtnVisible(b)
    if self.friendBtn then
        self.friendBtn:setVisible(b)
        self:setBtnFadeIn(self.friendBtn,b)
    end
end

function SidebarUI:setFieldBtnVisible(b)
    if self.fieldBtn then
        self.fieldBtn:setVisible(b)
        self:setBtnFadeIn(self.fieldBtn,b)
    end
end

function SidebarUI:setCaveBtnVisible(b)
    if self.caveBtn then
        self.caveBtn:setVisible(b)
        self:setBtnFadeIn(self.caveBtn,b)
    end
end

function SidebarUI:setFightBtnVisible(b)
    if self.map_btn then
        self.map_btn:setVisible(b)
        self:setBtnFadeIn(self.map_btn,b)
    end
end

function SidebarUI:setActivityVisible(b)
    if self.activityNode then
        self.activityNode:setVisible(b)
        self:setBtnFadeIn(self.activityNode,b)
    end
end

function SidebarUI:setUiBackBtnVisible(b)
    if self.uiBackBtnPanel then
        self.uiBackBtnPanel:setVisible(b)
        self:setBtnFadeIn(self.uiBackBtnPanel, b)
    end
end

function SidebarUI:setUiBackBtnNobarVisible(b)
    if self.uiBackBtnNoBarPL then
        self.uiBackBtnNoBarPL:setVisible(b)
        self:setBtnFadeIn(self.uiBackBtnNoBarPL, b)
    end
end

function SidebarUI:setOnlyUiBackBtnVisible(b)
    if self.uiOnlyBackPL then
        self.uiOnlyBackPL:setVisible(b)
        self:setBtnFadeIn(self.uiOnlyBackPL, b)
    end
end



function SidebarUI:setSzVisible(b)
    if self.szNode then
        self.szNode:setVisible(b)
        self:setBtnFadeIn(self.szNode,b)
    end
end

function SidebarUI:setRightLowerVisible(b)
    if self.rightLowerNode then
        self.rightLowerNode:setVisible(b)
        self:setBtnFadeIn(self.rightLowerNode,b)
    end
end

function SidebarUI:setPlayerInfoVisible(b)
    if self.playerInfoNode then
        self.playerInfoNode:setVisible(b)
        self:setBtnFadeIn(self.playerInfoNode,b)
    end
end

function SidebarUI:getIsVisible()
    local judge1 = false
    if self.rightLowerNode then
        judge1 = self.rightLowerNode:isVisible()
    end
    local judge2 = false
    if self.activityNode then
        judge2 = self.activityNode:isVisible()
    end
    return judge1 or judge2
end

function SidebarUI:setChatVisible(b)
    if self.chatNode then
        if self.chatEnd == false then
            self.chatNode:setVisible(b)
        else
            self.chatNode:setVisible(false)
        end
    end
end

function SidebarUI:getShow(showId)
    for i,v in ipairs(self.showType) do
        if tonumber(v) == showId then
            return true
        end
    end
    return false
end

function SidebarUI:getSzTabs()
    return self.szTabs
end

function SidebarUI:runNum(stype,num1)
    local tab = self:getSzData(stype)
    local endNum = tab.num
    if num1 == endNum or not endNum or not num1 then
        if self.runTab[stype] then
            self.runTab[stype] = nil
        end
        return
    end
    tab.num = num1
    local isNotRun = true
    for i=1,3 do
        local data = self:getSzData(tonumber(self.showType1[i]))
        if data.stype == stype and stype ~= 'food' and stype ~= 'shas' and stype ~= 'staying_power' and stype ~= 'staying_power' and stype ~= 'dig_times' then
            isNotRun = false
            self.szTabs[i].numTx:setScale(1.1)
            self.runLock[stype] = true
            self.szTabs[i].numTx:stopAllActions()
            self:updateSz(i,tab,1)
            self.runNotEnd[stype] = true
            self.szTabs[i].numTx:runAction(cc.DynamicNumberTo:create('LabelAtlas', 1, endNum, function() 
                self.runLock[stype] = false
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                    if self.runLock[stype] == true then
                        return
                    end
                    self.szTabs[i].numTx:runAction(cc.ScaleTo:create(0.3,0.9))
                    self.szTabs[i].numTx:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                        self.runNotEnd[stype] = false
                        self.runTab[stype] = nil
                        self:updateSz(i,self:getSzData(tonumber(self.showType1[i])))
                        end)))
                end)))
            end))
        -- else
        --     print('================================2',stype,i)
        --     self.szTabs[i].numTx:stopAllActions()
        end
    end
    if isNotRun == true then
        self.runTab[stype] = {num = num1}
    -- else
    --     self.runTab[tab.stype] = nil
    end
end

-- showType 显示哪些部分
-- showType1 资源条显示类型
-- isFadeIn 是否渐隐
-- isNotUpdateNewImgs 不更新红点
function SidebarUI:show(showType,showType1,isFadeIn,isNotUpdateNewImgs)
    self.showType = showType
    self.showType1 = showType1
    self.isFadeIn = isFadeIn
    self:setSzVisible(self:getShow(1))
    self:setRightLowerVisible(self:getShow(2))
    self:setRightTopBtnsVisible(self:getShow(3))
    self:setPlayerInfoVisible(self:getShow(4))
    self:setChatVisible(self:getShow(5))
    self:setChatBtnVisible(self:getShow(6))
    self:setActivityVisible(self:getShow(7))
    self:setUiBackBtnVisible(self:getShow(8))
    self:setFriendBtnVisible(self:getShow(9))
    self:setGiveheroBtnVisible(self:getShow(10))
    self:setFieldBtnVisible(self:getShow(12))
    self:setUiBackBtnNobarVisible(self:getShow(13))
    self:setCaveBtnVisible(self:getShow(14))
    self:setOnlyUiBackBtnVisible(self:getShow(15))
    self:setFightBtnVisible(self:getShow(16))
    local winSize = cc.Director:getInstance():getVisibleSize()
    if self:getShow(1) then
        if not self:getShow(3) then
            self.szNode:setPosition(cc.p(winSize.width,winSize.height))
        else
            self.szNode:setPosition(cc.p(winSize.width-100,winSize.height))
        end
    end

    if not isNotUpdateNewImgs and self:getShow(2) then
        self:updateFrameBtnsNewImgs()
    end
    if self:getShow(7) then
        self:setActivityBtnsPosition()
    end
    self.chatVisible = false
    for i,v in ipairs(self.showType) do
        if tonumber(v) == 6 then
            self.chatVisible = true
            break
        end
    end
    if self.chatEnd then
        self:runChat()
    end
    --self:hideBtns()
    self:update()
    self:createFoodRestore()

    if UserData:getUserObj() then
        self:createActionPointRestore()
        self:createStayingPowerRestore()
    end

    if self.runTab and type(self.runTab) =='table' then
        for i,v in pairs(self.runTab) do
            self:runNum(i,v.num)
        end
    end

    self:updateChatShowStatus()

end

function SidebarUI:updateChatShowStatus()
    if self.leftNode then
        local value = false
        if ChatNewMgr then
            value =  ChatNewMgr.isChatShow
        end

        self.leftNode:getChildByName('chat_btn'):getChildByName('new_img'):setVisible(value)
    end
end

function SidebarUI:updateShowStatus()
    self:updateFrameBtnsNewImgs()
    self:setActivityBtnsPosition()
end

function SidebarUI:getNode()
	if not self.root then
		self:create()
	end
	return self.root
end

function SidebarUI:setFrameBtnsAction()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local hNum= 0
    if self.isHide == true then
        self.buoyBgImg:runAction(cc.FadeIn:create(0.5))
    else
        self.buoyBgImg:runAction(cc.FadeOut:create(0.5))
    end
    local maxNum = 0
    for i,v in ipairs(self.hIds) do
        local extraMask = GlobalApi:getOpenInfo_new(v)
        if extraMask then
            maxNum = maxNum + 1
        end
    end
    -- 横向浮标
    for i,v in ipairs(self.hButtons) do
        local size = v:getContentSize()
        local posX,posY = v:getPositionX(),0 - size.height/2-15
        local speed = math.abs(v:getPositionY())/size.height
        local num = maxNum - i + 1
        if self.isHide == true then
            num = i
            posY = size.height/2+10
        end
        v:stopAllActions()
        v:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.05*num),
            cc.MoveTo:create(maxNum*0.05*speed,cc.p(posX,posY)),
            cc.CallFunc:create(function ()
                hNum = hNum + 1
                if hNum == maxNum then
                    self.isEnd = true
                end
            end)))
    end

    self.isHide = self.isHide ~= true
    self:updateAddBtnNewImgs()
end

function SidebarUI:registerSzHandler(stype)
    GlobalApi:getGotoByModule(stype)
end

function SidebarUI:getSzData(ntype)
    local tab = {}
    if not UserData:getUserObj() then
        return tab
    end

    local userConf = GameData:getConfData('user')

    if ntype == 1 or ntype == 'food' then
        tab.icon = 'uires/ui/res/food.png'
        tab.num = UserData:getUserObj():getFood()
        tab.displayAddImg = true
        tab.stype = 'food'
    elseif ntype == 2 or ntype == 'gold' then
        tab.icon = 'uires/ui_new/res/gold.png'
        tab.num = UserData:getUserObj():getGold()
        tab.displayAddImg = true
        tab.stype = 'gold'
    elseif ntype == 3 or ntype == 'cash' then
        tab.icon = 'uires/ui_new/res/cash.png'
        tab.num = UserData:getUserObj():getCash()
        tab.displayAddImg = true
        tab.stype = 'cash'
    elseif ntype == 4 or ntype == 'recruit1' then
        -- tab.icon = 'uires/icon/user/icon_ntavern.png'
        tab.icon = 'uires/ui_new/res/recruit1.png'
        tab.num = UserData:getUserObj():getnToken()
        tab.displayAddImg = false
        tab.stype = 'recruit1'
    elseif ntype == 5 or ntype == 'recruit2' then
        tab.icon = 'uires/ui_new/res/recruit2.png'
        tab.num = UserData:getUserObj():gethToken()
        tab.displayAddImg = false
        tab.stype = 'recruit2'
    elseif ntype == 6 or ntype == 'soul' then
        tab.icon = 'uires/ui/res/soul.png'
        tab.num = UserData:getUserObj():getSoul()
        tab.displayAddImg = false
        tab.stype = 'soul'
    elseif ntype == 7 or ntype == 'arena' then
        tab.icon = 'uires/ui/res/arena.png'
        tab.num = UserData:getUserObj():getArena()
        tab.displayAddImg = false
        tab.stype = 'arena'
    elseif ntype == 8 or ntype == 'tower' then
        tab.icon = 'uires/ui/res/tower.png'
        tab.num = UserData:getUserObj():getTower()
        tab.displayAddImg = false
        tab.stype = 'tower'
    elseif ntype == 9 or ntype == 'legion' then
        tab.icon = 'uires/ui/res/legion.png'
        tab.num = UserData:getUserObj():getLegion()
        tab.displayAddImg = false
        tab.stype = 'legion'
    elseif ntype == 10 or ntype == 'token' then
        tab.icon = 'uires/ui/res/token.png'
        tab.num = UserData:getUserObj():getToken()
        tab.displayAddImg = false
        tab.stype = 'token'
    elseif ntype == 11 or ntype == 'wood' then
        tab.icon = 'uires/ui/res/wood.png'
        tab.num = UserData:getUserObj():getWood()
        tab.displayAddImg = false
        tab.stype = 'wood'
    elseif ntype == 12 or ntype == 'legionwar' then
        tab.icon = 'uires/ui/res/legionwar.png'
        tab.num = UserData:getUserObj():getLegionwar()
        tab.displayAddImg = false
        tab.stype = 'legionwar'
    elseif ntype == 13 or ntype == 'trial_coin' then
        tab.icon = 'uires/ui/res/trial_coin.png'
        tab.num = UserData:getUserObj():getTrialCoin()
        tab.displayAddImg = true
        tab.stype = 'trial_coin'
    elseif ntype == 14 or ntype == 'action_point' then
        tab.icon = 'uires/ui/res/actionpoint.png'
        tab.num = UserData:getUserObj():getActionPoint()
        tab.displayAddImg = true
        tab.stype = 'action_point'
    elseif ntype == 15 or ntype == 'staying_power' then
        tab.icon = 'uires/ui/res/stayingpower.png'
        tab.num = UserData:getUserObj():getEndurance()
        tab.displayAddImg = false
        tab.stype = 'staying_power'
    elseif ntype == 16 or ntype == 'love' then
        tab.icon = 'uires/ui_new/res/love.png'
        tab.num = UserData:getUserObj():getLove()
        tab.displayAddImg = false
        tab.stype = 'love'
    elseif ntype == 17 or ntype == 'shas' then
        tab.icon = 'uires/ui/res/r_token.png'
        tab.num = UserData:getUserObj():getShas()
        tab.displayAddImg = false
        tab.stype = 'shas'
    elseif ntype == 18 or ntype == 'mine_1' then
        tab.icon = 'uires/ui/res/' .. userConf['mine_1'].icon
        tab.num = UserData:getUserObj():getMine(1)
        tab.displayAddImg = false
        tab.stype = 'mine_1'
    elseif ntype == 19 or ntype == 'mine_2' then
        tab.icon = 'uires/ui/res/' .. userConf['mine_2'].icon
        tab.num = UserData:getUserObj():getMine(2)
        tab.displayAddImg = false
        tab.stype = 'mine_2'
    elseif ntype == 20 or ntype == 'mine_3' then
        tab.icon = 'uires/ui/res/' .. userConf['mine_3'].icon
        tab.num = UserData:getUserObj():getMine(3)
        tab.displayAddImg = false
        tab.stype = 'mine_3'
    elseif ntype == 21 or ntype == 'mine_4' then
        tab.icon = 'uires/ui/res/' .. userConf['mine_4'].icon
        tab.num = UserData:getUserObj():getMine(4)
        tab.displayAddImg = false
        tab.stype = 'mine_4'
    elseif ntype == 22 or ntype == 'mine_5' then
        tab.icon = 'uires/ui/res/' .. userConf['mine_5'].icon
        tab.num = UserData:getUserObj():getMine(5)
        tab.displayAddImg = false
        tab.stype = 'mine_5'
    elseif ntype == 23 or ntype == 'goods' then
        tab.icon = 'uires/ui/res/goods.png'
        tab.num = UserData:getUserObj():getGoods()
        tab.displayAddImg = false
        tab.stype = 'goods'
    elseif ntype == 24 or ntype == 'countrywar' then
        tab.icon = 'uires/ui/res/countrywar.png'
        tab.num = UserData:getUserObj():getCountryWar()
        tab.displayAddImg = false
        tab.stype = 'countrywar'
    elseif ntype == 25 or ntype == 'salary' then
        tab.icon = 'uires/ui/res/salary.png'
        tab.num = UserData:getUserObj():getSalary()
        tab.displayAddImg = false
        tab.stype = 'salary'
    elseif ntype == 26 or ntype == 'sky_book' then
        tab.icon = 'uires/ui/res/skybook.png'
        tab.num = UserData:getUserObj():getSkybook()
        tab.displayAddImg = false
        tab.stype = 'sky_book'
    elseif ntype == 27 or ntype == 'dig_times' then
        tab.icon = 'uires/ui_new/res/meat.png'
        tab.num = UserData:getUserObj():getDiggingLeftTimes()
        tab.displayAddImg = true
        tab.stype = 'dig_times'
    elseif ntype == 27 or ntype == 'dig_times' then
        tab.icon = 'uires/ui_new/res/rum.png'
        tab.num = UserData:getUserObj():getWine()
        tab.displayAddImg = true
        tab.stype = 'rum'
    end
    return tab
end

function SidebarUI:updateSz(i,tab,ntype)
    if type(tab) == 'table' and tab.num then
        self.szTabs[i].bgImg:setVisible(true)
        local str = ""
        local space = 20
        local bgSize = self.szTabs[i].bgImg:getContentSize()
        if tab.num > 100000000 and not ntype then
            str = math.floor(tab.num / 100000000)
            self.szTabs[i].numImg:setVisible(true)
            self.szTabs[i].numImg:loadTexture('uires/ui/text/hundred_million.png')
            self.szTabs[i].numImg:setAnchorPoint(cc.p(1,0.5))
            self.szTabs[i].numImg:ignoreContentAdaptWithSize(true)
            local size = self.szTabs[i].numImg:getContentSize()
            self.szTabs[i].numImg:setPosition(cc.p(130 + ((tab.displayAddImg == true and 0) or 1)*30, 18))

            self.szTabs[i].numTx:setPosition(cc.p(bgSize.width - space - size.width*0.8 + ((tab.displayAddImg == true and 0) or 1)*25,bgSize.height/2))
        elseif tab.num > 100000 and not ntype then
            str = math.floor(tab.num / 10000)
            self.szTabs[i].numImg:setVisible(true)
            self.szTabs[i].numImg:loadTexture('uires/ui/text/ten_thousand.png')
            self.szTabs[i].numImg:setAnchorPoint(cc.p(1,0.5))
            self.szTabs[i].numImg:ignoreContentAdaptWithSize(true)
            local size = self.szTabs[i].numImg:getContentSize()
            self.szTabs[i].numImg:setPosition(cc.p(130 + ((tab.displayAddImg == true and 0) or 1)*30,18))
            self.szTabs[i].numTx:setPosition(cc.p(bgSize.width - space - size.width*0.8 + ((tab.displayAddImg == true and 0) or 1)*10,bgSize.height/2))
        else
            self.szTabs[i].numImg:setVisible(false)
            str = tostring(tab.num)
            self.szTabs[i].numTx:setPosition(cc.p(bgSize.width - space + ((tab.displayAddImg == true and 0) or 1)*10, bgSize.height/2))
        end
        if tab.stype == 'food' then
            self.szTabs[i].numTx:setString(tab.num..'/'..GlobalApi:getGlobalValue('foodMax'))
            self.szTabs[i].numTx:setPosition(cc.p(bgSize.width - space, bgSize.height/2))
            self.szTabs[i].numImg:setVisible(false)
        elseif tab.stype == 'shas' then
            self.szTabs[i].numTx:setString(str..'/'..GlobalApi:getGlobalValue('shasMaxCount'))
        elseif tab.stype == 'staying_power' then
            local stayingPowerMax = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
            self.szTabs[i].numTx:setString(tab.num..'/'..stayingPowerMax)
        elseif tab.stype == 'action_point' then
            local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
            local max = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
            self.szTabs[i].numTx:setString(tab.num..'/'..max)
        elseif tab.stype == 'dig_times' then
            self.szTabs[i].numTx:setString(str..'/'..GlobalApi:getGlobalValue('diggingToolInit'))
        else
            self.szTabs[i].numTx:setString(str)
        end
        -- DynamicNumberXX eg.
        -- self.szTabs[i].numTx:setString('0')
        -- self.szTabs[i].numTx:runAction(cc.DynamicNumberTo:create('LabelAtlas', 10, tab.num, function() 
        --         print('dynamic number to : create callback function execute..')
        --     end))
        self.szTabs[i].iconImg:loadTexture(tab.icon)
        self.szTabs[i].iconImg:ignoreContentAdaptWithSize(true)

        self.szTabs[i].addBtn:setVisible(tab.displayAddImg)
        self.szTabs[i].addBtn:setTouchEnabled(tab.displayAddImg)
        -- self.szTabs[i].addImg:addTouchEventListener(function (sender, eventType)
        --     if eventType == ccui.TouchEventType.began then
        --         AudioMgr.PlayAudio(11)
        --     elseif eventType == ccui.TouchEventType.ended then
        --         self:registerSzHandler(tab.stype)
        --     end
        -- end)
        self.szGotoType[i] = tab.stype
        if tab.stype == 'food' or tab.stype == 'action_point' or tab.stype == 'staying_power' then
            local resType = 1
            if tab.stype == 'food' then
                resType = 1
            elseif tab.stype == 'action_point' then
                resType = 14
            elseif tab.stype == 'staying_power' then
                resType = 15
            end
            self.szTabs[i].bgImg:setTouchEnabled(true)
            self.szTabs[i].bgImg.resType = resType
        else
            self.szTabs[i].bgImg:setTouchEnabled(false)
            self.foodNode:setVisible(false)
        end
    else
        self.szTabs[i].bgImg:setVisible(false)
    end
end

function SidebarUI:update()
    if UserData:getUserObj() then
        if self.showType1 and tonumber(self.showType[1]) >  0 then
            for i=1,3 do
                local tab = self:getSzData(tonumber(self.showType1[i]))
                if not self.runNotEnd[tab.stype] or self.runNotEnd[tab.stype] == false then
                    self:updateSz(i,self:getSzData(tonumber(self.showType1[i])))
                end
            end
        end
        if self.playerInfoNode then

            local headbg = self.playerInfoNode:getChildByName('head_bg')
            --等级
            local lvBgImg = headbg:getChildByName('lv_bg')
            local lvBgImgSize = lvBgImg:getContentSize()
            local progress = lvBgImg:getChildByName('progress')
            if not progress then
                progress = cc.ProgressTimer:create(cc.Sprite:create('uires/ui_new/buoy/bar.png'))
                progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
                progress:setPosition(cc.p(lvBgImgSize.width*0.5,lvBgImgSize.height*0.5))
                lvBgImg:addChild(progress)
                progress:setName('progress')
            end
            progress:setPercentage(UserData:getUserObj():lvPrecent())

            local lvTx = lvBgImg:getChildByName('lv_tx')
            lvTx:setString(UserData:getUserObj():getLv())

            --头像
            local roleImg = headbg:getChildByName('role_img')
            roleImg:loadTexture(UserData:getUserObj():getHeadpic())

            --战斗力
            local fightForceTx = headbg:getChildByName('fight_force_tx')
            UserData:getUserObj():runFightforce(fightForceTx,'sidebarui')

            --vip
            local vip = UserData:getUserObj():getVip()
            local size = headbg:getContentSize()
            local vipBtn = self.playerInfoNode:getChildByName('vip_btn')
            local vipNumTx = vipBtn:getChildByName("vip_num")
            vipNumTx:setString(vip)
        end
    end
end

function SidebarUI:getIsHide()
    return self.isHide
end


function SidebarUI:hideAllPanel(ntype)
    local functions = {
        function()
            RoleMgr:hideRoleList()
        end,
        function()
            BagMgr:hideBag()
        end,
        function()
            MapMgr:hidePatrolPanel()
        end
    }
    for i,v in ipairs(functions) do
        if i ~= ntype then
            v()
        end
    end
end

function SidebarUI:openPanel(stype)
    local functions = {
        ['military'] = function()
            MainSceneMgr:showMilitary()
        end,
        ['war_college'] = function()
            WarCollegeMgr:showWarCollege()
        end,
        ['open_seven'] = function()
            FirstWeekActivityMgr:showUI()
        end,
        ['first_pay'] = function()
            RechargeMgr:showFirstRecharge()
        end,
        ['activitys'] = function()
            if UserData:getUserObj():getActivityStatus('value_package_new') then
                ActivityMgr:showActivityPage("value_package_new")
            elseif UserData:getUserObj():getActivityStatus('tavern_recruit_level') then
                ActivityMgr:showActivityPage("tavern_recruit_level")
            else
                if UserData:getUserObj():getActivityStatus('sign') then
                    ActivityMgr:showActivityPage("sign")               
                else
                    ActivityMgr:showActivityPage("levelgift")
                end
            end

            
        end,
        ['time_limit_activitys'] = function()
            ActivityMgr:showTimeLimitActivityByType(3)
        end,
        ['sale'] = function()
            ActivityMgr:showActivityPage("week")

        end,
        ['lucky_dragon'] = function()
            ActivityMgr:showGetMoneyDragon()
        end,
        ['chicken_suit'] = function()
            MainSceneMgr:showChickenSuitUI()
        end,
         ['money_buy'] = function()
             MainSceneMgr:showOneYuanBuyUI()
         end,
        ['three_money_buy'] = function()
             MainSceneMgr:showThreeYuanBuyUI()
         end,
         ['tavern_recruit_level'] = function()
             ActivityMgr:showActivityPage("tavern_recruit_level")
         end,
		['res_back'] = function()
			MainSceneMgr:showResGetBackUI()
		end,
		['open_rank'] = function()
			MainSceneMgr:showOpenRankUI()
		end,
    }
    if functions[stype] then
        functions[stype]()
    end
end

function SidebarUI:runActivityBtns(callback)
    local size = self.topBgImg:getContentSize()
    local size1 = self.topPl:getContentSize()
    local stypes = self:getActivityBtnsVisible()
    self.isActivityBtnActionEnd = false
    local pos1 = cc.p(size1.width + size.width +5,150)
    local pos2 = cc.p(size1.width,150)
    self:updateTopBtnNewImgs()
    if not self.isHideActivityBtn then
        self.topBgImg:setPosition(pos1)
        self.topBgImg:runAction(cc.Sequence:create(cc.MoveTo:create(#stypes * 0.1,pos2),cc.CallFunc:create(function()
            self.isActivityBtnActionEnd = true
            if callback then
                callback()
            end
        end)))
    else
        self.topBgImg:setPosition(pos2)
        self.topBgImg:runAction(cc.Sequence:create(cc.MoveTo:create(#stypes * 0.1,pos1),cc.CallFunc:create(function()
            self.isActivityBtnActionEnd = true
            if callback then
                callback()
            end
        end)))
    end
end

function SidebarUI:getActivityBtnsVisible()
    local extraMask = {
        ['res_back'] = UserData:getUserObj():getResGetBack(),
        ['military'] = true,
        ['war_college'] = UserData:getUserObj():judgeWarCollegeSign(),
        ['first_pay'] = UserData:getUserObj():judgeFirstPayIsOpen(),
        ['sale'] = true,
        ['activitys'] = true,
        ['time_limit_activitys'] = true,
        ['open_seven'] = true,
        ['lucky_dragon'] = true,
        ['chicken_suit'] = true,
        ['money_buy'] = UserData:getUserObj():judgeMoneyBuyIsGet(),
        ['three_money_buy'] = UserData:getUserObj():judgeThreeMoneyBuyIsGet(),
        ['tavern_recruit_level'] = UserData:getUserObj():getActivityStatus('tavern_recruit_level'),
		['open_rank'] = true,
    }
    local stypes = {}
    for k,v in pairs(self.activityOrder) do
        local visible = false
        if v.key == 'time_limit_activitys' then
            visible = ActivityMgr:judgeLimitActivityIsOpen()
        else
            visible = extraMask[v.key] and UserData:getUserObj():getActivityStatus(v.key)
        end

        if visible then
            local btn = self.topBgImg:getChildByName('activity_btn_'..(#stypes + 1))
            if not btn then
                btn = ccui.Button:create()
                local newImg = ccui.ImageView:create('uires/ui_new/common/new_dot.png')
                newImg:setPosition(cc.p(55,55))
                newImg:setName('new_img')
                btn:setName('activity_btn_'..(#stypes + 1))
                btn:setLocalZOrder(150)
                btn:addChild(newImg)
                local nameTx = ccui.Text:create()
                nameTx:setPosition(cc.p(37.5,10))
                nameTx:setFontName("font/gamefont1.ttf")
                nameTx:setFontSize(18)
                nameTx:setColor(cc.c4b(254,254,254, 255))
                nameTx:enableOutline(cc.c4b(34,28,44, 255),2)
                nameTx:setName("name_tx")
                btn:addChild(nameTx)
                self.topBgImg:addChild(btn)
                self.maxActivityBtn = (self.maxActivityBtn or 0) + 1
            end

            local conf = GameData:getConfData('activities')[v.key]
            if conf and conf.isGuangEffect == 1 then
                local guang1 = self.topBgImg:getChildByName('activity_btn_guang1'..(#stypes + 1))
                if not guang1 then
                    guang1 = ccui.ImageView:create('uires/ui/buoy/acitivity_guang_1.png')
                    guang1:setName('activity_btn_guang1'..(#stypes + 1))
                    guang1:setLocalZOrder(99)
                    self.topBgImg:addChild(guang1)
                end
                guang1:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.5, 360)))
                
                local guang2 = self.topBgImg:getChildByName('activity_btn_guang2'..(#stypes + 1))
                if not guang2 then
                    local guang2 = ccui.ImageView:create('uires/ui/buoy/acitivity_guang_2.png')
                    guang2:setName('activity_btn_guang2'..(#stypes + 1))
                    guang2:setLocalZOrder(98)
                    self.topBgImg:addChild(guang2)
                end
                
            end

            if conf and conf.isRemainTime == 1 then
                local timeTx = self.topBgImg:getChildByName('activity_btn_timetx'..(#stypes + 1))
                if not timeTx then
                    timeTx = ccui.Text:create()
                    timeTx:setFontName("font/gamefont.ttf")
                    timeTx:setFontSize(16)
                    timeTx:setTextColor(COLOR_TYPE.GREEN)
                    timeTx:enableOutline(COLOR_TYPE.BLACK, 1)
                    timeTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    timeTx:setAnchorPoint(cc.p(0.5,0.5))
                    timeTx:setLocalZOrder(111)
                    timeTx:setName('activity_btn_timetx'..(#stypes + 1))
                    self.topBgImg:addChild(timeTx)
                end

                local node = timeTx:getChildByName('activity_btn_node')
                if not node then
                    local node = cc.Node:create()
                    node:setName('activity_btn_node')
                    timeTx:addChild(node)
                end

                local barBg = self.topBgImg:getChildByName('activity_btn_bar_bg'..(#stypes + 1))
                if not barBg then
                    local barBg = ccui.ImageView:create('uires/ui/common/bar_bg_7.png')
                    barBg:setName('activity_btn_bar_bg'..(#stypes + 1))
                    barBg:setLocalZOrder(110)
                    self.topBgImg:addChild(barBg)
                end

            end

            stypes[#stypes + 1] = v.key
        else
            self.activityWidget[v.key] = nil
        end
    end
    return stypes
end

function SidebarUI:setActivityBtnsPosition()
    local signs = {
        ['res_back'] = true,
        ['military'] = UserData:getUserObj():getMilitarySign(),
        ['war_college'] = UserData:getUserObj():getWarCollegeSign(),
        ['first_pay'] = UserData:getUserObj():getSignByType('firstrecharge'),
        ['sale'] = UserData:getUserObj():getSignByType('sale'),
        ['activitys'] = UserData:getUserObj():getSignByType('activitys'),
        ['time_limit_activitys'] = UserData:getUserObj():getSignByType('time_limit_activitys'),
        ['open_seven'] = UserData:getUserObj():getSignByType('open_seven'),
        ['lucky_dragon'] = UserData:getUserObj():getSignByType('lucky_dragon'),
        ['chicken_suit'] = false,
        ['money_buy'] = UserData:getUserObj():getSignByType('money_buy'),
        ['three_money_buy'] = UserData:getUserObj():getSignByType('three_money_buy'),
        ['tavern_recruit_level'] = UserData:getUserObj():getSignByType('tavern_recruit_level'),
		['open_rank'] = true,
    }
    local stypes = self:getActivityBtnsVisible()
    local btn = self.topBgImg:getChildByName('activity_btn_1')
    local size = btn:getContentSize()
    local space = 8
    local horizontal = size.width + space
    local maxWidth = #stypes
    self.topBgImg:setContentSize(cc.size(((maxWidth > MAX_ACTIVITY_ICON_NUM) and MAX_ACTIVITY_ICON_NUM or maxWidth)*horizontal + 25,
        self.topBgImg:getContentSize().height))
    local size1 = self.topBgImg:getContentSize()
    local x,y = size1.width-65,44
    self.isTopArrowNew = false
    for i=1,self.maxActivityBtn do
        local btn = self.topBgImg:getChildByName('activity_btn_'..i)
        local guang1 = self.topBgImg:getChildByName('activity_btn_guang1'..i)
        local guang2 = self.topBgImg:getChildByName('activity_btn_guang2'..i)
        local timeTx = self.topBgImg:getChildByName('activity_btn_timetx'..i)
        local barBg = self.topBgImg:getChildByName('activity_btn_bar_bg'..i)
        if i <= #stypes then
            local conf = GameData:getConfData('activities')[stypes[i]]
            btn:setVisible(true)
            self.activityWidget[stypes[i]] = 'activity_btn_'..i
            btn:setPosition(cc.p(x,y))
            if guang1 and guang2 then
                if conf and conf.isGuangEffect == 1 then
                    guang1:setVisible(true)
                    guang1:setPosition(cc.p(x,y))
                    guang2:setVisible(false)
                    guang2:setPosition(cc.p(x,y))
                else
                    guang1:setVisible(false)
                    guang2:setVisible(false)
                end
            end

            if timeTx and barBg then
                local node = timeTx:getChildByName('activity_btn_node')
                if node then
                    timeTx:removeChildByName('activity_btn_node')
                end
                local node = cc.Node:create()
                node:setName('activity_btn_node')
                timeTx:addChild(node)

                if conf and conf.isRemainTime == 1 then
                    timeTx:setVisible(false)
                    timeTx:setPosition(cc.p(x,y -  46))
                    barBg:setVisible(false)
                    barBg:setPosition(cc.p(x,y -  46))
                    node:setPosition(cc.p(-28 + 0.5,0))

                    if UserData:getUserObj():getActivityStatus(stypes[i]) == true then
                        local time1,time2 = ActivityMgr:getActivityTime(stypes[i])
                        local time = time1
                        if time2 then
                            time = time2
                        end
                        if time > 0 then
                            barBg:setVisible(true)
                            timeTx:setVisible(true)
                            local hour = time/3600
                            if hour >= 24 then
                                local day = math.floor(time / (24 * 3600))
                                local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME4'),day)
                                timeTx:setString(str)
                                node:setVisible(false)
                            else
                                timeTx:setString('')
                                node:setVisible(true)
                                Utils:createCDLabel(node,time,COLOR_TYPE.RED,COLOR_TYPE.BLACK,CDTXTYPE.FRONT,'',COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,18,nil,5)
                            end
                        end
                    end

                else
                    timeTx:setVisible(false)
                    barBg:setVisible(false)
                end
            end
            local newImg = btn:getChildByName('new_img')
            newImg:setVisible(signs[stypes[i]])
            self.isTopArrowNew = signs[stypes[i]] or self.isTopArrowNew
            x = x - horizontal
            btn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self:openPanel(stypes[i])
                end
            end)
            if conf then
                btn:loadTextureNormal('uires/ui_new/buoy/'..conf.url..'.png')
                local nameTx = btn:getChildByName("name_tx")
                if nameTx then
                    nameTx:setString(conf.name)
                end
            end
            if i == MAX_ACTIVITY_ICON_NUM then
                x,y = size1.width-65,-44-10
            end
        else
            btn:setVisible(false)
            if guang1 and guang2 then
                guang1:setVisible(false)
                guang2:setVisible(false)
            end
            if timeTx and barBg then
                timeTx:setVisible(false)
                barBg:setVisible(false)
            end
        end
    end
    self:updateTopBtnNewImgs()
end

function SidebarUI:setFrameBtnsVisible(b)
    self.isHide = b ~= true
    self:setFrameBtnsPosition(b)
end

function SidebarUI:setHide(b)
    self.hideImg:setTouchEnabled(b)
end

function SidebarUI:mapBtnsFly(key,callback,index)
    local time = 1
    local winSize = cc.Director:getInstance():getVisibleSize()
    local btnsInfo = {
        ['lord'] = {scale = 1,url = 'uires/ui/mainscene/prefecture_nor_btn.png',pos = cc.p(winSize.width,winSize.height - 137),anchor = cc.p(1,1)},
        ['star'] = {scale = 0.01,url = 'uires/ui/expedition/icon_star.png',pos = cc.p(winSize.width - 55,55),anchor = cc.p(0.5,0.5)},
        ['egg'] = {scale = 0.01,url = 'uires/ui/treasure/egg_%d.png',pos = cc.p(winSize.width - 385,55),anchor = cc.p(0.5,0.5)},
        ['didi'] = {scale = 0.01,url = 'uires/ui/activity/dididalong.png',pos = cc.p(winSize.width/2,winSize.height - 100),anchor = cc.p(0.5,0.5)},
    }
    if key == 'lord' then
        MapMgr:setLordBtnVisible(false)
    end
    self.hideImg:setTouchEnabled(true)
    local action,opacity
    local bgImg = ccui.ImageView:create('uires/ui/common/bg1_gray11.png')
    if key == 'egg' then
        btnsInfo[key].url = string.format(btnsInfo[key].url,index + 1)
    end
    if key == 'star' then
        bgImg:loadTexture('uires/ui/common/bg1_alpha.png')
        local isOpen = GlobalApi:getOpenInfo('jadeSeal')
        if not isOpen then
            return
        end
        time = 0.5
        opacity = 0
        action = cc.FadeIn:create(0.5)
    else
        bgImg:loadTexture('uires/ui/common/bg1_gray11.png')
        action = cc.DelayTime:create(time)
        opacity = 255
    end
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(winSize.width,winSize.height))
    bgImg:setPosition(cc.p(-winSize.width/2,winSize.height/2))
    self.rightLowerNode:addChild(bgImg)
    bgImg:setLocalZOrder(2)

    local flyImg = ccui.ImageView:create(btnsInfo[key].url)
    local size = flyImg:getContentSize()
    flyImg:setPosition(cc.p(winSize.width/2 + size.width * (btnsInfo[key].anchor.x - 0.5),winSize.height/2 + size.height * (btnsInfo[key].anchor.y - 0.5)))
    flyImg:setAnchorPoint(btnsInfo[key].anchor)
    flyImg:setLocalZOrder(3)
    bgImg:addChild(flyImg)

    flyImg:setOpacity(opacity)
    flyImg:runAction(cc.Sequence:create(action,cc.MoveTo:create(0.5,btnsInfo[key].pos),cc.CallFunc:create(function()
        if key ~= 'star' then
            self.hideImg:setTouchEnabled(false)
        end
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            flyImg:removeFromParent()
            bgImg:removeFromParent()
            if callback then
                callback()
            end
        end)))
    end)))
    flyImg:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.ScaleTo:create(0.5,btnsInfo[key].scale)))
end

function SidebarUI:btnsFly(key, callback)
    self:setFrameBtnsVisible(true)
    local conf = GameData:getConfData('moduleopen')[key]
    if not conf then
        return
    end
    local index = 0
    local bottom = 0
    for i,v in ipairs(self.hIds) do
        if v == key then
            self.hButtons[i]:setVisible(false)
            bottom = 1
            index = i
        end
    end
    if index == 0 then
        return
    end

    self.hideImg:setTouchEnabled(true)
    local bgImg = ccui.ImageView:create('uires/ui/common/bg1_gray11.png')
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(winSize.width,winSize.height))
    bgImg:setPosition(cc.p(-winSize.width/2,winSize.height/2))
    self.rightLowerNode:addChild(bgImg)
    bgImg:setLocalZOrder(2)

    local x,y
    if bottom == 1 then
        local size = self.hButtons[1]:getContentSize()
        x,y  = -size.width*(0.5 + index),size.height/2
    end
    local flyImg = ccui.ImageView:create('uires/ui/buoy/'..conf.contentRes)
    flyImg:setPosition(cc.p(-winSize.width/2,winSize.height/2))
    flyImg:setLocalZOrder(3)
    self.rightLowerNode:addChild(flyImg)

    flyImg:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.MoveTo:create(0.5,cc.p(x,y)),cc.CallFunc:create(function()

        self:setFrameBtnsVisible(true)
        
        self.hideImg:setTouchEnabled(false)
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            flyImg:removeFromParent()
            bgImg:removeFromParent()
            if callback then
                callback()
            end
        end)))
    end)))
end

function SidebarUI:updateTopBtnNewImgs()
    local newImg = self.topArrowBtn:getChildByName('new_img')
    newImg:setVisible(self.isTopArrowNew and self.isHideActivityBtn)
end

function SidebarUI:updateAddBtnNewImgs()
    local newImg = self.addBtn:getChildByName('new_img')
    newImg:setVisible(self.isAddNew and self.isHide)
end

function SidebarUI:updateFrameBtnsNewImgs()
    -- print('===============================updateFrameBtnsNewImgs')
    local signs = {
        self:CalcRoleInfo(),
        false,
        UserData:getUserObj():getSignByType('treasure'),
        UserData:getUserObj():getSignByType('task'),
        UserData:getUserObj():getSignByType('report'),
        false,
        UserData:getUserObj():getSignByType('legion'),
        UserData:getUserObj():getSignByType('country'),
        UserData:getUserObj():getSignByType('hook'),
    }
    local open = {
        true,
        true,
        true,
        GlobalApi:getOpenInfo('task'),
        GlobalApi:getOpenInfo('report'),
        GlobalApi:getOpenInfo('weapon'),
        false,
        false,
        false,
    }
    self.isAddNew = false
    for i=1,#self.hButtons do
        local newImg = self.hButtons[i]:getChildByName('new_img')
        newImg:setVisible(signs[i] and open[i])
        self.hButtons[i]:setVisible(open[i])
        self.isAddNew = (signs[i] and open[i]) or self.isAddNew
    end
    local isShow,isFull = UserData:getUserObj():getSignByType('bag')
    if isShow then
        local newImg = self.hButtons[2]:getChildByName('new_img')
        newImg:setVisible(true)
        if isFull then
            newImg:loadTexture('uires/ui/buoy/full_point.png')
        else
            newImg:loadTexture('uires/ui/buoy/new_point.png')
        end
    end

    local newImg = self.addBtn:getChildByName('new_img')
    newImg:setVisible(self.isAddNew and self.isHide)

    --左侧按钮组
    local leftSigns = {
        self:CalcJadeseal(),
        UserData:getUserObj():getSignByType('friend'),
    }
    local leftOpens = {
        GlobalApi:getOpenInfo('friend'),
        GlobalApi:getOpenInfo('jadeSeal'),
    }
    for i=1,#self.leftButtons do
        local newImg = self.leftButtons[i]:getChildByName('new_img')
        newImg:setVisible(leftSigns[i] and leftOpens[i])
    end

    --帝王星星
    local isVisiable = self:CalcJadeseal()
    if isVisiable then
        self.starBgImg:setOpacity(0)
    else
        self.starBgImg:runAction(cc.FadeIn:create(0.5))
    end
end


function SidebarUI:setFrameBtnsPosition(b)

    
    local extraMask = {}
    for i,v in ipairs(self.hIds) do
        extraMask[i] = GlobalApi:getOpenInfo(v)
    end

    local size = self.hButtons[1]:getContentSize()
    local space = 10
    local x,y  = 7 - size.width/2 - size.width - space,0 - size.height/2
    if b == true then
        y  = size.height/2+10
    end

    local horizontal = size.width + space
    local hNum = 0
    for i=1,#self.hButtons do
        local visible = extraMask[i]
        self.hButtons[i]:stopAllActions()
        self.hButtons[i]:setPosition(cc.p(x,y))
        self.hButtons[i]:setVisible(visible)
        if visible then
            hNum = hNum + 1
            x = x - horizontal
        end
    end

    self.buoyBgImg:setPosition(cc.p(0,0))
    self.buoyBgImg:setOpacity(255)
    self.isEnd = true
    if self.isHide == false then
        local isVisiable = self:CalcJadeseal()
        if isVisiable then
            self.starBgImg:setOpacity(0)
        else
            self.starBgImg:setOpacity(255)
        end
        self.addBtn:loadTextureNormal('uires/ui_new/buoy/del_nor_btn.png')
    else
        self.starBgImg:setOpacity(0)
        self.addBtn:loadTextureNormal('uires/ui_new/buoy/add_nor_btn.png')
    end

end

function SidebarUI:runMsgAction(msg,again)
    if not self.chatVisible then
        self.chatNode:setVisible(false)
        -- return
    end

    self.chatNode:setVisible(true)
    local chatBgImg = self.chatNode:getChildByName('chat_bg_img')
    local nameTx = chatBgImg:getChildByName('name_tx')
    local chatPl = chatBgImg:getChildByName('chat_pl')
    if chatPl:getChildByName('system_richtext') then
        chatPl:removeChildByName('system_richtext')
    end
    local msgTx = chatPl:getChildByName('msg_tx')
    local maohaoTx = chatBgImg:getChildByName('maohao_tx')
    local size = chatPl:getContentSize()
    if msg.act == 'system' then
        maohaoTx:setVisible(false)
        nameTx:setString(GlobalApi:getLocalStr('CHAT_DESC_3'))
        local chatNoticeConf = GameData:getConfData('chatnotice')
        local str,htmlstr = ChatNewMgr:getDesc(msg.sub_type,msg.str_array)
        local delay = 5
        local num = string.len(str)/3
        if num <= 1 then
            delay = 5
        elseif num <= 64 then
            delay = 5 + 15*(num/64)
        else
            delay = 20
        end

        local richText = xx.RichText:create()
        richText:setName('system_richtext')
        richText:setAlignment('left')
        richText:setVerticalAlignment('bottom')
	    richText:setContentSize(cc.size(5000, 40))
	    richText:setAnchorPoint(cc.p(0,0))
	    richText:setPosition((cc.p(size.width - 20,-2)))
	    chatPl:addChild(richText)

        local re1 = xx.RichTextLabel:create('\n',20, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont1.TTF')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,htmlstr)

        msgTx:setString(str)
        msgTx:setVisible(false)
        local size1 = msgTx:getContentSize()
        richText:setContentSize(cc.size(size1.width + 20, 40))
        richText:format(true)
        richText:runAction(cc.Sequence:create(cc.MoveTo:create(delay,cc.p(-size1.width + 20,-2)),cc.CallFunc:create(function()
            if again then
                self.chatNode:setVisible(false)
                -- if #self.chatMsgs > 0 then
                    self:runChat()
                -- else
                --     self.chatEnd = true
                -- end
            else
                if #self.chatMsgs > 0 then
                    self.chatNode:setVisible(false)
                    self:runChat()
                else
                    self:runMsgAction(msg,true)
                end
            end
        end)))

    else
        nameTx:setString(msg.user.un)
        msgTx:setVisible(true)    
        msgTx:setString(msg.content)
        msgTx:setPosition(cc.p(size.width,3))
        maohaoTx:setVisible(true)
        local delay = 5
        local num = string.len(msg.content)/3
        if num <= 1 then
            delay = 5
        elseif num <= 64 then
            delay = 5 + 15*(num/64)
        else
            delay = 20
        end
        local size1 = msgTx:getContentSize()
        msgTx:runAction(cc.Sequence:create(cc.MoveTo:create(delay,cc.p(-size1.width,3)),cc.CallFunc:create(function()
            if again then
                self.chatNode:setVisible(false)
                -- if #self.chatMsgs > 0 then
                    self:runChat()
                -- else
                --     self.chatEnd = true
                -- end
            else
                if #self.chatMsgs > 0 then
                    self.chatNode:setVisible(false)
                    self:runChat()
                else
                    self:runMsgAction(msg,true)
                end
            end
        end)))
    end
end

function SidebarUI:runChat()
    self.chatEnd = true
    if not self.chatVisible then
        self.chatNode:setVisible(false)
        return
    end
    local msg = self.chatMsgs[1]
    if msg then
        self.chatEnd = false
        table.remove(self.chatMsgs,1)
        self:runMsgAction(msg)
    else
        self.chatEnd = true
    end
end

function SidebarUI:setChatMsg(msg)
    self.chatMsgs[#self.chatMsgs + 1] = msg
    if self.chatEnd and self.chatVisible then
        -- self.chatEnd = false
        self:runChat()
    end
end

function SidebarUI:updateLittleChatMsg()
    self.chatBgImg:stopAllActions()
    self.root:stopAllActions()
    if #self.littleChatMsgs > MAX_LITTLE_MSG then
        table.remove(self.littleChatMsgs,1)
    end
    local maxHeight = 0
    local heights = {}
    for i=1,MAX_LITTLE_MSG do
        if self.littleChatMsgs[i] then
            local isVoice = ChatNewMgr.judgeIsVoice(self.littleChatMsgs[i])

            local stype = ''
            if self.littleChatMsgs[i].type == 'world' then
                stype = GlobalApi:getLocalStr('CHAT_CHANNEL1')
            elseif self.littleChatMsgs[i].type == 'legion' then
                stype = GlobalApi:getLocalStr('CHAT_CHANNEL2')
            end
            local un = self.littleChatMsgs[i].user.un
            local vip = self.littleChatMsgs[i].user.vip
            local content = self.littleChatMsgs[i].content
            if not self.littleChatRts[i] then
                local pl = ccui.Widget:create()
                pl:setAnchorPoint(cc.p(0,1))
                self.littleChatRts[i] = pl
                self.chatSv:addChild(pl)

                local channelTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                channelTx:setColor(COLOR_TYPE.ORANGE)
                channelTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                channelTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                channelTx:setAnchorPoint(cc.p(0,1))
                channelTx:setName('channel_tx')

                local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                nameTx:setColor(COLOR_TYPE.WHITE)
                nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                nameTx:setAnchorPoint(cc.p(0,1))
                nameTx:setName('name_tx')

                local vipTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                vipTx:setColor(COLOR_TYPE.RED)
                vipTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                vipTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                vipTx:setAnchorPoint(cc.p(0,1))
                vipTx:setName('vip_tx')

                local contentTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                contentTx:setColor(cc.c3b(132,212,210))
                contentTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                contentTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                contentTx:setAnchorPoint(cc.p(0,1))
                contentTx:setName('content_tx')
                contentTx:setMaxLineWidth(246)

                local voiceImg = ccui.ImageView:create('uires/ui/chat/yuyin.png')
                voiceImg:setScale(0.5)
                voiceImg:setAnchorPoint(cc.p(0,1))
                voiceImg:setName('voice_img')

                pl:addChild(channelTx)
                pl:addChild(nameTx)
                pl:addChild(vipTx)
                pl:addChild(contentTx)
                pl:addChild(voiceImg)
            end

            local pl = self.littleChatRts[i]
            local channelTx = pl:getChildByName('channel_tx')
            local nameTx = pl:getChildByName('name_tx')
            local vipTx = pl:getChildByName('vip_tx')
            local contentTx = pl:getChildByName('content_tx')
            local voiceImg = pl:getChildByName('voice_img')
            channelTx:setString('['..stype..']')
            nameTx:setString(un..':')
            vipTx:setString('VIP'..vip)
            contentTx:setString(content)
            local size = channelTx:getContentSize()
            local size1 = nameTx:getContentSize()
            local size2 = vipTx:getContentSize()
            heights[i] = contentTx:getContentSize().height + size.height
            pl:setContentSize(cc.size(250,heights[i]))
            channelTx:setPosition(cc.p(0,heights[i]))
            nameTx:setPosition(cc.p(5 + size.width,heights[i]))
            vipTx:setPosition(cc.p(10 + size.width + size1.width,heights[i]))
            voiceImg:setPosition(cc.p(10 + size.width + size1.width + size1.width,heights[i]))
            contentTx:setPosition(cc.p(0,heights[i] - size.height))
            if isVoice then    -- 是语音
                voiceImg:setVisible(true)
            else
                voiceImg:setVisible(false)
            end
            pl:setVisible(true)
            maxHeight = maxHeight + heights[i]
        end
    end
    local size = self.chatSv:getContentSize()
    self.chatSv:setClippingType(0)
    if maxHeight > size.height then
        self.chatSv:setInnerContainerSize(cc.size(246,maxHeight))
    else
        self.chatSv:setInnerContainerSize(size)
        maxHeight = size.height
    end
    local currHeight = maxHeight
    for i=1,MAX_LITTLE_MSG do
        if self.littleChatRts[i] then
            self.littleChatRts[i]:setPosition(cc.p(0,currHeight))
            currHeight = currHeight - heights[i]
        end
    end
    self.chatSv:jumpToBottom()
    self.chatBgImg:setOpacity(255)
    self.chatBgImg:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.FadeOut:create(0.5)))
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(6.3),cc.CallFunc:create(function()
        for i=1,MAX_LITTLE_MSG do
            if self.littleChatRts[i] then
                self.littleChatRts[i]:setVisible(false)
            end
        end
    end)))
end

function SidebarUI:setLittleChatMsg(msg)
    self.littleChatMsgs[#self.littleChatMsgs + 1] = msg
    self:updateLittleChatMsg()
end

function SidebarUI:setTime(time, create, resType)
    local timeTx = self.root:getChildByName('time_tx' .. resType)
    local function updateTime()
        local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
        local winSize = cc.Director:getInstance():getVisibleSize()
        label:setName('time_tx' .. resType)
        label:setPosition(cc.p(winSize.width/2,-100))
        label:setVisible(false)
        -- label:setPosition(cc.p(winSize.width/2,winSize.height/2))
        self.root:addChild(label)

        Utils:createCDLabel(label, time, COLOR_TYPE.WHITE, COLOR_TYPE.BLACK,CDTXTYPE.FRONT, nil, nil, nil, 25, function ()
            if resType == 1 then
                local food = UserData:getUserObj():getFood()
                UserData:getUserObj():setFoodTime(GlobalData:getServerTime())
                if food < tonumber(GlobalApi:getGlobalValue('foodMax')) then
                    self:setTime(GlobalApi:getGlobalValue('foodInterval')*60, nil, resType)
                    GlobalApi:parseAwardData({{'user','food',1}})
                    self:update()
                end
            elseif resType == 14 then
                local num = tonumber(GameData:getConfData('dfbasepara').actionRecoverInterval.value[1])
                local interval = TerritorialWarMgr:getRealCount('actionRecoverRate',num)

                local maxValue = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
                maxValue = TerritorialWarMgr:getRealCount('actionMax', maxValue)

                local actionPoint = UserData:getUserObj():getActionPoint()
                UserData:getUserObj():setActionPointTime(GlobalData:getServerTime())
                if actionPoint < maxValue then
                    self:setTime(interval, nil, resType)
                    GlobalApi:parseAwardData({{'user','action_point',1}})
                    self:update()
                end
            elseif resType == 15 then
                local recover = tonumber(GameData:getConfData('dfbasepara').enduranceRecoverInterval.value[1])
                local interval = TerritorialWarMgr:getRealCount('enduranceRecoverRate',recover)

                local maxValue = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])

                local stayingPower = UserData:getUserObj():getEndurance()
                UserData:getUserObj():setStayingPowerTime(GlobalData:getServerTime())
                if stayingPower < maxValue then
                    self:setTime(interval, nil, resType)
                    GlobalApi:parseAwardData({{'user','staying_power',1}})
                    self:update()
                end
            end
        end)
    end

    if time <= 0 then
        if resType == 1 then
            self:setTime(GlobalApi:getGlobalValue('foodInterval')*60, nil, resType)
        elseif resType == 14 then
            local num = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
            local interval = TerritorialWarMgr:getRealCount('actionRecoverRate',num)
            self:setTime(interval, nil, resType)
        elseif resType == 15 then
            local recover = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
            local interval = TerritorialWarMgr:getRealCount('enduranceRecoverRate',recover)
            self:setTime(interval, nil, resType)
        end
        
        return
    end

    if not timeTx then
        updateTime()
    elseif not create then
        timeTx:removeFromParent()
        updateTime()
    end
end

function SidebarUI:removeFoodRestore()
    local timeTx = self.root:getChildByName('time_tx1')
    if timeTx then
        timeTx:removeFromParent()
    end
end

function SidebarUI:resetFoodRestore()
    local maxFood = tonumber(GlobalApi:getGlobalValue('foodMax'))
    if UserData:getUserObj() and UserData:getUserObj():getFood() < maxFood then
        local timeTx = self.root:getChildByName('time_tx1')
        if timeTx then
            timeTx:removeFromParent()
        end
        local time = UserData:getUserObj():getFoodTime()
        if time then
            local diffTime = GlobalApi:getGlobalValue('foodInterval')*60 + time - GlobalData:getServerTime()
            self:setTime(diffTime, true, 1)
        end
    end
end

function SidebarUI:createFoodRestore()
    local maxFood = tonumber(GlobalApi:getGlobalValue('foodMax'))
    if UserData:getUserObj() and UserData:getUserObj():getFood() < maxFood then
        local time = UserData:getUserObj():getFoodTime()
        if time then
            local diffTime = GlobalApi:getGlobalValue('foodInterval')*60 + time - GlobalData:getServerTime()
            self:setTime(diffTime,true, 1)
        end
    end
end

-----------------------------------------------------------
function SidebarUI:removeStayingPowerRestore()
    local timeTx = self.root:getChildByName('time_tx15')
    if timeTx then
        timeTx:removeFromParent()
    end
end

function SidebarUI:resetStayingPowerRestore()
    local stayingPowerMax = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
    if UserData:getUserObj() and UserData:getUserObj():getEndurance() and UserData:getUserObj():getEndurance() < stayingPowerMax then
        local timeTx = self.root:getChildByName('time_tx15')
        if timeTx then
            timeTx:removeFromParent()
        end
        local time = UserData:getUserObj():getStayingPowerTime()
        if time then
            local recover = tonumber(GameData:getConfData('dfbasepara').enduranceRecoverInterval.value[1])
            recover = TerritorialWarMgr:getRealCount('enduranceRecoverRate',recover)
            local diffTime = recover + time - GlobalData:getServerTime()
            self:setTime(diffTime,true, 15)
        end
    end
end

function SidebarUI:createStayingPowerRestore()
    local stayingPowerMax = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
    if UserData:getUserObj() and UserData:getUserObj():getEndurance() and UserData:getUserObj():getEndurance() < stayingPowerMax then
        local time = UserData:getUserObj():getStayingPowerTime()
        if time then
            local recover = tonumber(GameData:getConfData('dfbasepara').enduranceRecoverInterval.value[1])
            recover = TerritorialWarMgr:getRealCount('enduranceRecoverRate',recover)
            local diffTime =  recover + time - GlobalData:getServerTime()
            self:setTime(diffTime,true, 15)
        end
    end
end
------------------------------------------------------------------
function SidebarUI:removeActionPointRestore()
    local timeTx = self.root:getChildByName('time_tx14')
    if timeTx then
        timeTx:removeFromParent()
    end
end

function SidebarUI:resetActionPointRestore()

    local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
    actionPointMax = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
    if UserData:getUserObj() and UserData:getUserObj():getActionPoint() and UserData:getUserObj():getActionPoint() < actionPointMax then
        local timeTx = self.root:getChildByName('time_tx14')
        if timeTx then
            timeTx:removeFromParent()
        end
        local time = UserData:getUserObj():getActionPointTime()
        if time then
            local num = tonumber(GameData:getConfData('dfbasepara').actionRecoverInterval.value[1])
            local recoverRate = TerritorialWarMgr:getRealCount('actionRecoverRate',num)
            local diffTime = recoverRate + time - GlobalData:getServerTime()
            self:setTime(diffTime, true, 14)
        end
    end
end

function SidebarUI:createActionPointRestore()
    local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
    actionPointMax = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
    if UserData:getUserObj() and UserData:getUserObj():getActionPoint() and UserData:getUserObj():getActionPoint() < actionPointMax then
        local time = UserData:getUserObj():getActionPointTime()
        if time then
            local num = tonumber(GameData:getConfData('dfbasepara').actionRecoverInterval.value[1])
            local recoverRate = TerritorialWarMgr:getRealCount('actionRecoverRate',num)
            local diffTime = recoverRate + time - GlobalData:getServerTime()
            self:setTime(diffTime, true, 14)
        end
    end
end
----------------------------------------------------------------------------
function SidebarUI:setDiggingTime(diffTime)
    local isOpen = GlobalApi:getOpenInfo('digging')
    if not isOpen then
        return
    end
    local diggingLabel = self.diggingLabel
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
    if diggingLabel:getChildByTag(9527) then
        diggingLabel:removeChildByTag(9527)
    end
	diggingLabel:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.NONE,nil,nil,nil,18,function ()
		--if diffTime <= 0 then
            local sumTime = tonumber(GlobalApi:getGlobalValue('diggingToolCD')) * 60
            self:setDiggingTime(sumTime)

            local maxNum = GameData:getConfData("level")[UserData:getUserObj().level or 1].diggingMax
            if UserData:getUserObj().digging < maxNum then
                UserData:getUserObj().digging = UserData:getUserObj().digging + 1
            end
            --print('++++++++++++++++====' .. UserData:getUserObj().digging)
            -- 更新红点
            if UserData:getUserObj().digging >= maxNum then
                MainSceneMgr:updateSigns()
            end
        
		--end
	end)
end

function SidebarUI:registerLeftBtn()

    self.chatBgImg = self.leftNode:getChildByName('chat_bg_img')
    self.chatBgImg:setCascadeOpacityEnabled(true)
    self.chatBgImg:setOpacity(0)
    self.chatSv = self.chatBgImg:getChildByName('sv')
    self.chatSv:setScrollBarEnabled(false)

    self.chatBtn  = self.leftNode:getChildByName('chat_btn')
    self.chatBtn:ignoreContentAdaptWithSize(true)
    self.chatBtn:getChildByName('new_img'):setVisible(false)
    self.chatBtn:getChildByName('new_img'):setPositionY(self.chatBtn:getChildByName('new_img'):getPositionY() + 32)
    
    self.fieldBtn = self.leftNode:getChildByName('field_btn')
    local btnTx = self.fieldBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR12"))

    self.caveBtn = self.leftNode:getChildByName('cave_btn')
    local btnTx = self.caveBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR14"))

    self.map_btn = self.leftNode:getChildByName('map_btn')

    self.giveHeroBtn = self.leftNode:getChildByName('give_hero_btn')
    local btnTx = self.giveHeroBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR11"))

    self.friendBtn = self.leftNode:getChildByName('friend_btn') 
    self.moreBtn = self.leftNode:getChildByName('more_btn')
    self.leftButtons = {self.giveHeroBtn,self.friendBtn}

    self.chatBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
            ChatNewMgr:showChat()            
        end
    end)

    self.chatBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
            ChatNewMgr:showChat()            
        end
    end)
  
    self.giveHeroBtn:ignoreContentAdaptWithSize(true)
    self.giveHeroBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showJadesealUI()
        end
    end)

    self.friendBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('friend')
        end
    end)

    self.fieldBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showMapUI()
        end
    end)

    self.caveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CaveAdventureMgr:showMainUI()
        end
    end)

    --帝王星星
    self.starBgImg = self.giveHeroBtn:getChildByName('star_bg_img')
    self.starBgImg:setOpacity(0)

end

function SidebarUI:registerBtnHandler()

    local heroBtn = self.rightLowerNode:getChildByName('hero_btn')
    local btnTx = heroBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR1"))

    local bagBtn = self.rightLowerNode:getChildByName('bag_btn')
    local btnTx = bagBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR2"))

    --暂时是打开巨龙
    local treasureBtn = self.rightLowerNode:getChildByName('family_btn')
    local btnTx = treasureBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR3"))

    local taskBtn = self.rightLowerNode:getChildByName('task_btn')
    local btnTx = taskBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR4"))

    local reportBtn = self.rightLowerNode:getChildByName('report_btn')
    local btnTx = reportBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR5"))

    local pokedexBtn = self.rightLowerNode:getChildByName('pokedex_btn')
    local btnTx = pokedexBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR6"))

    local patrolBtn = self.rightLowerNode:getChildByName('patrol_btn')
    local legionBtn = self.rightLowerNode:getChildByName('legion_btn')
    local countryWarBtn = self.rightLowerNode:getChildByName('country_war_btn')
    
    self.hIds = {"hero","bag","treasure","task","report","weapon","legion","country","hook"}
    self.hButtons = {
        heroBtn,bagBtn,treasureBtn,taskBtn,reportBtn,pokedexBtn,legionBtn,countryWarBtn,patrolBtn
    }

    self.topPl = self.activityNode:getChildByName('top_pl')
    self.topPl:setClippingEnabled(false)
    self.topBgImg = self.topPl:getChildByName('bg_img')
    self.topBgImg:loadTexture('uires/ui_new/common/bg1_alpha.png')
    self.topPl:setPosition(self.topPl:getPositionX() + 50,self.topPl:getPositionY())
    self.topArrowBtn =self.activityNode:getChildByName('top_arrow_btn')
    self.topArrowBtn:setVisible(false)
    self.topArrowBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if not self.isActivityBtnActionEnd then
                return
            end
            self.isHideActivityBtn = not self.isHideActivityBtn
            self:runActivityBtns(function()
                if self.isHideActivityBtn then
                    self.topArrowBtn:loadTextures('uires/ui/buoy/arrow_nor_btn.png','','')
                else
                    self.topArrowBtn:loadTextures('uires/ui/buoy/arrow_sel_btn.png','','')
                end
            end)
        end
    end)

    reportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('report')
        end
    end)

    heroBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideAllPanel(1)
            RoleMgr:showRoleList()
        end
    end)
    bagBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideAllPanel(2)
            BagMgr:showBag(id)
        end
    end)
    countryWarBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryMgr:showCountryMain()
        end
    end)
    legionBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showMainUI()
        end
    end)
    treasureBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showTreasure()
        end
    end)
    
    taskBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --MainSceneMgr:showTask(1)
            MainSceneMgr:showTaskNewUI()
        end
    end)
    pokedexBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('weapon')
        end
    end)
    patrolBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           self:hideAllPanel(3)
           MapMgr:showPatrolPanel()
        end
    end)
    self.addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.isEnd then
                self.isEnd = false
                self:setFrameBtnsAction()
                if self.isHide == false then
                    self.addBtn:loadTextureNormal('uires/ui_new/buoy/del_nor_btn.png')
                else
                    self.addBtn:loadTextureNormal('uires/ui_new/buoy/add_nor_btn.png')
                end
            end
        end
    end)
end

function SidebarUI:registerRightTopBtns()

    local limiteBtn = self.rightTopNode:getChildByName('limite_btn')
    local btnTx = limiteBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR7"))

    local activityBtn = self.rightTopNode:getChildByName('activity_btn')
    local btnTx = activityBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR8"))

    local guideBtn = self.rightTopNode:getChildByName('guide_btn')
    local btnTx = guideBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR9"))

    local rankBtn = self.rightTopNode:getChildByName('rank_btn')
    local btnTx = rankBtn:getChildByName("text")
    btnTx:setString(GlobalApi:getLocalStr_new("SIDEBR_BTN_STR10"))

    limiteBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if UserData:getUserObj():getActivityStatus('value_package_new') then
                ActivityMgr:showActivityPage("value_package_new")
            elseif UserData:getUserObj():getActivityStatus('tavern_recruit_level') then
                ActivityMgr:showActivityPage("tavern_recruit_level")
            else
                if UserData:getUserObj():getActivityStatus('sign') then
                    ActivityMgr:showActivityPage("sign")               
                else
                    ActivityMgr:showActivityPage("levelgift")
                end
            end
        end
    end)

    activityBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ActivityMgr:showActivityPage("week")
        end
    end)

    guideBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showMilitary()
        end
    end)

    rankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showOpenRankUI()
        end
    end)
    self.rtBtns = {limiteBtn,activityBtn,guideBtn,rankBtn}
    self.oldBtnsPos = {}
    for i=1,#self.rtBtns do
       local posX,posY = self.rtBtns[i]:getPosition()
       self.oldBtnsPos[i] = cc.p(posX,posY)
    end

    self.rightTopRootBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.rtBtnsAcTionEnd then
                self.rtBtnsAcTionEnd = false
                self:playRTBtnsAction()
            end
        end
    end)
end

function SidebarUI:playRTBtnsAction()

    for i=#self.rtBtns,1,-1 do
        self.rtBtns[i]:stopAllActions()
        self.rtBtns[i]:setVisible(true)

        local tagetPos = self.rtBtnsHide == true and self.oldBtnsPos[i] or self.oldBtnsPos[1]
        local opacity = self.rtBtnsHide == true and 255 or 0
        self.rtBtns[i]:setTouchEnabled(self.rtBtnsHide)
        local spawnAct = cc.Spawn:create(cc.MoveTo:create(i*0.1,tagetPos),cc.FadeTo:create(i*0.1,opacity))
        local sequenceAction = cc.Sequence:create(spawnAct,
        cc.CallFunc:create(function() 
            if i == 1 then
                self.rtBtnsAcTionEnd = true
                self.rtBtnsHide = not self.rtBtnsHide
                if self.rtBtnsHide then
                    self.rightTopRootBtn:loadTextureNormal('uires/ui_new/buoy/top_open.png')
                else
                    self.rightTopRootBtn:loadTextureNormal('uires/ui_new/buoy/top_close.png')
                end
            end
        end))
        self.rtBtns[i]:runAction(sequenceAction)
    end
end

function SidebarUI:showTip(resType)
    if resType ~= 1 and resType ~= 14 and resType ~= 15 then
        return
    end

    if self.isOpen == true then
        return
    end

    self.isOpen = true
    self.foodNode:setVisible(true)

    self.foodImg = self.foodNode:getChildByName('food_bg_img')
    local tx1 = self.foodImg:getChildByName('desc_tx_1')
    local tx2 = self.foodImg:getChildByName('desc_tx_2')
    local tx3 = self.foodImg:getChildByName('desc_tx_3')

    local desc1 = ''
    local desc2 = ''
    local desc3 = ''

    local curValue = 0 
    local maxValue = 0
    local diffValue = 0
    local diffTime = 0
    self.interval = 1

    if resType == 1 then    -- 粮草
        self.interval = tonumber(GlobalApi:getGlobalValue('foodInterval')) * 60
        local intervalStr = self.interval/60
        desc1 = GlobalApi:getLocalStr('FOOD_RESTORE_DESC_1').. intervalStr .. GlobalApi:getLocalStr('STR_MINUTE')

        curValue = UserData:getUserObj():getFood()
        maxValue = tonumber(GlobalApi:getGlobalValue('foodMax'))
        diffValue = maxValue - curValue - 1

        local time = UserData:getUserObj():getFoodTime()
        diffTime = self.interval + time - GlobalData:getServerTime() + 1
        if (curValue >= maxValue) then
            desc2 = (GlobalApi:getLocalStr('FOOD_RESTORE_DESC_2') .. GlobalApi:getLocalStr('FOOD_RESTORE_DESC_4'))
            desc3 = (GlobalApi:getLocalStr('FOOD_RESTORE_DESC_3') .. GlobalApi:getLocalStr('FOOD_RESTORE_DESC_4'))
        else
            desc2 = GlobalApi:getLocalStr('FOOD_RESTORE_DESC_2')
            desc3 = GlobalApi:getLocalStr('FOOD_RESTORE_DESC_3')
        end
    elseif resType == 14 then   -- 行动力

        local num = tonumber(GameData:getConfData('dfbasepara').actionRecoverInterval.value[1])
        self.interval = TerritorialWarMgr:getRealCount('actionRecoverRate',num)
        local intervalStr = TerritorialWarMgr:getTime(self.interval, true)
        desc1 = GlobalApi:getLocalStr('ACTION_POINT_RESTORE_DESC_1') .. intervalStr

        curValue = UserData:getUserObj():getActionPoint()
        maxValue = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
        maxValue = TerritorialWarMgr:getRealCount('actionMax',maxValue)
        diffValue = maxValue - curValue - 1

        local time = UserData:getUserObj():getActionPointTime()
        diffTime = self.interval + time - GlobalData:getServerTime() + 1
        if (curValue >= maxValue) then
            desc2 = (GlobalApi:getLocalStr('ACTION_POINT_RESTORE_DESC_2') .. GlobalApi:getLocalStr('FOOD_RESTORE_DESC_4'))
            desc3 = (GlobalApi:getLocalStr('ACTION_POINT_RESTORE_DESC_3') .. GlobalApi:getLocalStr('FOOD_RESTORE_DESC_4'))
        else
            desc2 = GlobalApi:getLocalStr('ACTION_POINT_RESTORE_DESC_2')
            desc3 = GlobalApi:getLocalStr('ACTION_POINT_RESTORE_DESC_3')
        end 
    elseif resType == 15 then   -- 耐力
        local recover = tonumber(GameData:getConfData('dfbasepara').enduranceRecoverInterval.value[1])
        self.interval = TerritorialWarMgr:getRealCount('enduranceRecoverRate',recover)
        local intervalStr = TerritorialWarMgr:getTime(self.interval, true)
        desc1 = GlobalApi:getLocalStr('STAYING_POWER_RESTORE_DESC_1') .. intervalStr

        curValue = UserData:getUserObj():getEndurance()
        maxValue = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
        diffValue = maxValue - curValue - 1

        local time = UserData:getUserObj():getStayingPowerTime()
        diffTime = self.interval + time - GlobalData:getServerTime() + 1
        if (curValue >= maxValue) then
            desc2 = (GlobalApi:getLocalStr('STAYING_POWER_RESTORE_DESC_2') .. GlobalApi:getLocalStr('FOOD_RESTORE_DESC_4'))
            desc3 = (GlobalApi:getLocalStr('STAYING_POWER_RESTORE_DESC_3') .. GlobalApi:getLocalStr('FOOD_RESTORE_DESC_4'))
        else
            desc2 = GlobalApi:getLocalStr('STAYING_POWER_RESTORE_DESC_2')
            desc3 = GlobalApi:getLocalStr('STAYING_POWER_RESTORE_DESC_3')
        end
    end

    tx1:setString(desc1)

    if diffValue < 0 then
        diffValue = 0
    end
    
    local function resetTime(noUpdate)
        local function updateTime(num,time,pos,tx)
            local label = self.foodImg:getChildByName('time_tx_'..num)
                if label then
                    label:removeFromParent()
                end

                label = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
                self.foodImg:addChild(label)

                local winSize = cc.Director:getInstance():getVisibleSize()
                label:setName('time_tx_'..num)
                label:setPosition(pos)
                label:setAnchorPoint(cc.p(0,0.5))
                -- label:setPosition(cc.p(winSize.width/2,winSize.height/2))
                Utils:createCDLabel(label,time,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.BLACK,CDTXTYPE.FRONT, tx,
                    COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.BLACK,20,
                    function ()
                        if num == 2 then
                            resetTime(true)
                        end
                end)
        end

        if (curValue >= maxValue) then
            tx2:setString(desc2)
            tx3:setString(desc3)

            local label = self.foodImg:getChildByName('time_tx_'..2)
            if label then
                label:removeFromParent()
            end

            local label = self.foodImg:getChildByName('time_tx_'..3)
            if label then
                label:removeFromParent()
            end
        else
            tx2:setString('')
            tx3:setString('')

            if (diffTime <= 0) and (curValue < maxValue) then
                if resType == 1 then
                    UserData:getUserObj().mark.food_time = GlobalData:getServerTime() + self.interval
                elseif resType == 14 then
                    UserData:getUserObj().mark.action_point_time = GlobalData:getServerTime() + self.interval
                elseif resType == 15 then
                    UserData:getUserObj().mark.staying_power_time = GlobalData:getServerTime() + self.interval
                end
                 
                 diffTime = self.interval
            end

            updateTime(2, diffTime, cc.p(143, 50), desc2)

            if not noUpdate then
                updateTime(3, diffTime + diffValue * self.interval, cc.p(143,22), desc3)
            end
        end
    end

    resetTime()                                   
end

function SidebarUI:create()

	self.root = cc.CSLoader:createNode("csb/buoy.csb")

    self.maskImg = self.root:getChildByName('mask_img')

    self.rightLowerNode = self.root:getChildByName('right_lower_node')
    self.leftNode = self.root:getChildByName('left_node')
    self.playerInfoNode = self.root:getChildByName('player_info_node')
    self.activityNode = self.root:getChildByName('activity_node')
    self.chatNode = self.root:getChildByName('chat_node')
    self.foodNode = self.root:getChildByName('food_node')
    self.hideImg = self.root:getChildByName('hide_img')
    self.uiBackBtnPanel = self.root:getChildByName('ui_back_btn')
    self.uiBackBtnPanel:setVisible(false)
    self.uiBackBtnNoBarPL = self.root:getChildByName('ui_back_nobar')
    self.uiOnlyBackPL = self.root:getChildByName('ui_only_back')
    self.rightTopNode = self.root:getChildByName('right_top_node')

    self.chatNode:setVisible(false)
    self.foodNode:setVisible(false)

    self.isHideActivityBtn = false
    self.isActivityBtnActionEnd = true
    
    self.isBottomBtnActionEnd = true
    self.activityOrder = GameData:getConfData("local/activityorder")

    local diggingLabel = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    local winSize = cc.Director:getInstance():getVisibleSize()
    diggingLabel:setName('time_tx_digging')
    diggingLabel:setPosition(cc.p(winSize.width/2,-1000))
    diggingLabel:setVisible(false)
    self.root:addChild(diggingLabel)
    self.diggingLabel = diggingLabel

	local settingBtn = self.playerInfoNode:getChildByName('setting_btn')
	settingBtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            SettingMgr:showSettingInfo()
        end
	end)

    local vipBtn = self.playerInfoNode:getChildByName('vip_btn')
    vipBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RechargeMgr:showRecharge()
        end
    end)
		
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.szNode = self.root:getChildByName('sz_node')
	self.szTabs = {}
    self.szGotoType = {}
    self.schedulerEntry = {}
	for i=1,3 do
		local str = 'bg_'..i..'_img'
		local bgImg = self.szNode:getChildByName(str)
		local iconImg = bgImg:getChildByName('icon_img')
		local numImg = bgImg:getChildByName('num_img')
        local addBtn = bgImg:getChildByName('add_btn')
        local bgSize = bgImg:getContentSize()

        local numTx = cc.LabelAtlas:_create('', "uires/ui/number/font_sz.png", 17, 23, string.byte('.'))
        numTx:setScale(0.8)
        numImg:setScale(0.8)
        numTx:setAnchorPoint(cc.p(1, 0.5))
        local bgSize = bgImg:getContentSize()
        numTx:setPosition(cc.p(bgSize.width - 50,bgSize.height/2))
        bgImg:addChild(numTx)

		self.szTabs[i] = {bgImg = bgImg, numTx = numTx, numImg = numImg, iconImg = iconImg, addBtn = addBtn}
        self.szTabs[i].addBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local stype = self.szGotoType[i]
                self:registerSzHandler(stype)
            end
        end)

        
        local scheduler = self.szTabs[i].bgImg:getScheduler()
        self.isOpen = false
        self.szTabs[i].bgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                if self.schedulerEntry[i] then
                    scheduler:unscheduleScriptEntry(self.schedulerEntry[i])
                    self.schedulerEntry[i] = nil
                end
                self.schedulerEntry[i] = scheduler:scheduleScriptFunc(function()
                    self:showTip(self.szTabs[i].bgImg.resType)
                end,0.2,false)
            elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
                if self.schedulerEntry[i] then
                    scheduler:unscheduleScriptEntry(self.schedulerEntry[i])
                    self.schedulerEntry[i] = nil
                end
                self.foodNode:setVisible(false)
                self.isOpen = false
            end
        end)
        
        local size = iconImg:getContentSize()
        local run = GlobalApi:createLittleLossyAniByName("ui_zhucheng_blink")
        run:setPosition(cc.p(size.width/2,size.height/3))
        iconImg:addChild(run)
        run:getAnimation():playWithIndex(0,-1,1)
	end

    self.rightTopRootBtn = self.rightTopNode:getChildByName('root_btn')
    self.addBtn = self.rightLowerNode:getChildByName('add_btn')
    self.buoyBgImg = self.rightLowerNode:getChildByName('buoy_bg_img')

    local size1 = self.addBtn:getContentSize()
    self.maskImg:setVisible(true)
    self.maskImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.maskImg:setContentSize(winSize)

    self.rightLowerNode:setPosition(cc.p(winSize.width,0))
    self.playerInfoNode:setPosition(cc.p(0,winSize.height))
    self.leftNode:setPosition(cc.p(0,winSize.height/2-20))
	self.szNode:setPosition(cc.p(winSize.width,winSize.height))
    self.addBtn:setPosition(0 - size1.width/2-10, size1.height/2+15)
    self.activityNode:setPosition(cc.p(winSize.width-80,winSize.height))
    self.chatNode:setPosition(cc.p(winSize.width/2,winSize.height - 170))
    self.foodNode:setPosition(cc.p(winSize.width,winSize.height))
    self.hideImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.rightTopNode:setPosition(cc.p(winSize.width,winSize.height))

    self:registerLeftBtn()
    self:registerBtnHandler()
    self:registerRightTopBtns()

    self.uiBack_bg = self.uiBackBtnPanel:getChildByName('bg_img')
    self.uiInfoBg = self.uiBack_bg:getChildByName('ui_info_bg_img')
    self.uiBack_text = self.uiInfoBg:getChildByName('ui_info')
    self.uiBack_btn = self.uiBack_bg:getChildByName('back_btn')

    self.uiBack_bg:setContentSize(cc.size(winSize.width, self.uiBack_bg:getContentSize().height))
    local top_pos = winSize.height - self.uiBack_bg:getContentSize().height/2
    self.uiBackBtnPanel:setPosition(cc.p(winSize.width/2, top_pos))

    local uibtnNoBarBg = self.uiBackBtnNoBarPL:getChildByName("bg")
    uibtnNoBarBg:setContentSize(cc.size(winSize.width, uibtnNoBarBg:getContentSize().height))
    local uiOnlyBackBg = self.uiOnlyBackPL:getChildByName("bg")
    uiOnlyBackBg:setContentSize(cc.size(winSize.width, uibtnNoBarBg:getContentSize().height))

    local top_pos = winSize.height - uibtnNoBarBg:getContentSize().height/2
    self.uiBackBtnNoBarPL:setPosition(cc.p(winSize.width/2, top_pos))
    self.nobar_titleBg = uibtnNoBarBg:getChildByName("title_bg")
    self.nobar_titleTx = self.nobar_titleBg:getChildByName('title_tx')
    self.nobar_backBtn = uibtnNoBarBg:getChildByName("back_btn")
    self.uiOnlyBackPL:setPosition(cc.p(winSize.width/2, top_pos))
    self.onlybackBtn = uiOnlyBackBg:getChildByName("back_btn")
end

function SidebarUI:CalcRoleInfo()
    --local time1 = socket.gettime()
    local havenew = false
    --local infoarr = RoleData:getWorstEquipArr()
    local lv = UserData:getUserObj():getLv()
    local heronum  = GameData:getConfData('level')[lv].heroNum
    local havenewassist = 0
    for i=1,MAXROlENUM do
        local obj = RoleData:getRoleByPos(i)
        if obj and obj:getId() > 0 then
            havenewassist = havenewassist + 1
        end
    end
    local allcards = BagData:getAllCards()
    local cardarr = {}
    for k, v in pairs(allcards) do
        if v:getId() < 10000 then
            local canassist = true
            for j = 1,MAXROlENUM do
                local hid = RoleData:getRoleByPos(j):getId()
                if hid == v:getId() then
                    canassist = false
                end
            end
            if canassist then
                table.insert(cardarr, v)
            end
        end
    end
    local num = #cardarr
    if heronum > havenewassist and num > 0  then
        return true
    end
    local promoteOpen = GlobalApi:getOpenInfo('promote')
    for i=1,MAXROlENUM do
        local obj = RoleData:getRoleByPos(i)
        if obj and obj:getId() > 0 then
            local ishaveeqtab = obj:isHavebetterEquipOutSide()
            for j=1,6 do
                if ishaveeqtab[j] then
                    -- havenew = true
                    return true
                    --break
                end
            end
            if obj:isTupo() then
                return true
                -- havenew = true
                --break
            elseif obj:isSoldierCanLvUp() then
                --havenew = true
                return true
                --break
            elseif obj:isFateCanAcitive() then
                --havenew = true
                return true
                --break
            elseif obj:isSoldierSkillCanLvUp() then
                --havenew = true
                return true
                --break
            elseif obj:isCanRiseStar() then
                return true
            elseif obj:isCanrPromoted() and promoteOpen then
                return true
            elseif RechargeMgr.vipChanged and promoteOpen then
                return true
            end
        end
    end

    if UserData:getUserObj():getSignByType('chip') == true then
        return true
    end


    return havenew
end

function SidebarUI:CalcJadeseal()
    return true
end

function SidebarUI:getActivityWidget(funname)
    return self.activityWidget[funname]
end

-- 设置回退按钮文本和回调
function SidebarUI:setBackBtnCallback(info, callback,type)

    if type == 1 then
        
        local onlyBackBtnVisible = self.uiOnlyBackPL:isVisible()
        if onlyBackBtnVisible then
            self.onlybackBtn:addTouchEventListener(function (sender, eventType)
                if callback then
                    callback(sender, eventType)
                end
            end)
        else
            self.nobar_titleTx:setString(info)
            self.nobar_backBtn:addTouchEventListener(function (sender, eventType)
                if callback then
                    callback(sender, eventType)
                end
            end)
        end
    else
        if self.uiBack_text then
            self.uiBack_text:setString(info)
        end

        if self.uiBack_btn then
            self.uiBack_btn:addTouchEventListener(function (sender, eventType)
                if callback then
                    callback(sender, eventType)
                end
            end)

        end
    end
    
end

function SidebarUI:setMapBtnCallback(info, callback)

    if self.map_btn then
        local text = self.map_btn:getChildByName("text")
        text:setString(info)
        self.map_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
            elseif eventType == ccui.TouchEventType.ended then
                if callback then
                    callback()
                end
            end
        end)
    end
end

return SidebarUI