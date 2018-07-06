local LegionLevelsMainUI = class("LegionLevelsMainUI", BaseUI)

local MAXLEVELS = 20
local MAXCOPY = 6
function LegionLevelsMainUI:ctor()
  self.uiIndex = GAME_UI.UI_LEGIONLEVELSMAIN
  self.data = LegionMgr:getLegionLevelsData()
  --printall(self.data)
end

function LegionLevelsMainUI:onShow()
    self.data = LegionMgr:getLegionLevelsData()
    self:update()
end
function LegionLevelsMainUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bgimg = self.root:getChildByName("bg_img")
    self.levesnode = bgimg:getChildByName('levels_node')
    local bgimg1 = self.levesnode:getChildByName("bg_img1")
    bgimg:setContentSize(winsize)
    local winsize = cc.Director:getInstance():getVisibleSize()
    self.bgImgSize = bgimg1:getContentSize()
    local limitLW = winsize.width - self.bgImgSize.width
    local limitRW = 0
    local preMovePos = nil
    local movePos = nil
    local bgImgDiffPos = nil
    local bgImgPosX = 0
    local bgImgPosY = -(self.bgImgSize.height-winsize.height)/2
    local beganPos = nil
    bgimg1:setPosition(cc.p(bgImgPosX, bgImgPosY))
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            preMovePos = movePos
            movePos = sender:getTouchMovePosition()
            if preMovePos then
                bgImgDiffPos = cc.p(movePos.x - preMovePos.x, movePos.y - preMovePos.y)
                local targetPos = cc.p(bgImgPosX + bgImgDiffPos.x, bgImgPosY)
                if targetPos.x > limitRW then
                    targetPos.x = limitRW
                end
                if targetPos.x < limitLW then
                    targetPos.x = limitLW
                end
                bgImgPosX = targetPos.x
                bgimg1:setPosition(targetPos)
            end
        elseif eventType == ccui.TouchEventType.began then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
            beganPos = sender:getTouchBeganPosition()
            self.touchMine = false
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
        elseif eventType == ccui.TouchEventType.canceled then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
        end
    end)

    local closebtn = bgimg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionLevelsMainUI()
        end
    end)
    closebtn:setPosition(cc.p(winsize.width,winsize.height))

    local winSize = cc.Director:getInstance():getWinSize()
    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.LEGION_LEVEL_BATTLE)
    btn:setPosition(cc.p(40,winSize.height - 40))
    bgimg:addChild(btn)

    self.maptab = {}
    self.cloudtab = {}
    for i=1,MAXLEVELS do
        local arr = {}
        local pl = bgimg1:getChildByName('pl_'..i)
        arr.btn = pl:getChildByName('city_btn')
        arr.btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionMgr:showLegionLevelsUI(i)
            end
        end)
        arr.pl = pl
        arr.btn:setTouchEnabled(false)
        arr.namebg = pl:getChildByName('name_bg')
        arr.namebg:setVisible(false)
        arr.nametx = arr.namebg:getChildByName('name_tx')
        arr.barbg = pl:getChildByName('bar_bg')
        arr.barbg:setVisible(false)
        arr.bar = arr.barbg:getChildByName('bar')

        arr.bar:setScale9Enabled(true)
        arr.bar:setCapInsets(cc.rect(10,15,1,1))


        arr.bartx = arr.bar:getChildByName('bar_tx')
        arr.sucimg = pl:getChildByName('suc_img')
        arr.sucimg:setVisible(false)
        self.maptab[i] = arr
        self.cloudtab[i] = bgimg1:getChildByName('cloud_'..i..'_img')
    end
    local numbg = bgimg:getChildByName("num_bg")
    numbg:setPosition(cc.p(winsize.width/2,45))
    self.numtx = numbg:getChildByName('num_tx')
    local addbtn = numbg:getChildByName('add_btn')
    addbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local vip = UserData:getUserObj():getVip()
            local vipconf = GameData:getConfData("vip")
            local maxbuycount = vipconf[tostring(vip)].legionCopy
            local buyvalue = GameData:getConfData('buy')[self.data.copy_buy+1].legionCopyChallenge
            if self.data.copy_buy < maxbuycount then
                -- promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("LEGION_LEVELS_DESC13"), buyvalue,maxbuycount-self.data.copy_buy), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                --     self:sendMsg()
                -- end)
                local str = string.format(GlobalApi:getLocalStr("LEGION_LEVELS_DESC13"), buyvalue,maxbuycount-self.data.copy_buy)
                UserData:getUserObj():cost('cash',buyvalue,function()
                    self:sendMsg()
                end,true,str)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC14'), COLOR_TYPE.RED)
            end
        end
    end)
    self:update()
end

function LegionLevelsMainUI:update()
    
    local legioncopyconf = GameData:getConfData("legioncopy")
    local legionconf = GameData:getConfData('legion')
    for i=1,MAXLEVELS do
        self.maptab[i].btn:removeChildByTag(9527)
        self.maptab[i].namebg:setVisible(false)
        self.maptab[i].sucimg:setVisible(true)
        self.maptab[i].sucimg:ignoreContentAdaptWithSize(true)
        if i < self.data.chapter then
            self.maptab[i].sucimg:loadTexture('uires/ui/text/tx_yijipo.png')
            if self.cloudtab[i] then
                self.cloudtab[i]:setVisible(false)
            end
            self.maptab[i].btn:setBright(true)
            self.maptab[i].btn:setTouchEnabled(false)
            self.maptab[i].barbg:setVisible(false)
        elseif i == self.data.chapter then
            self.maptab[i].btn:setTouchEnabled(true)
            self.maptab[i].namebg:setVisible(true)
            self.maptab[i].nametx:setString(legioncopyconf[i].name)
            self.maptab[i].barbg:setVisible(true)
            
            self.maptab[i].bar:setPercent(LegionMgr:calccopypercent(self.data,self.data.chapter))
            self.maptab[i].sucimg:setVisible(false)
            self.maptab[i].bartx:setString(LegionMgr:calccopypercent(self.data,self.data.chapter).."%")
            self.maptab[i].btn:setBright(true)
            if self.cloudtab[self.data.chapter] then
                self.cloudtab[self.data.chapter]:setVisible(false)
            end
            local fightainmintion = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
            if fightainmintion then
                fightainmintion:setPosition(cc.p(80,60))
                fightainmintion:setTag(9527)
                fightainmintion:setAnimation(0, 'animation', true)
                self.maptab[i].btn:addChild(fightainmintion)
            end

            local pos = self.maptab[i].pl:getPositionX()
            local winsize = cc.Director:getInstance():getWinSize()
            local limitLW = winsize.width - self.bgImgSize.width
            local limitRW = 0
            if pos > limitRW then
                pos = limitRW
            end
            if pos < limitLW then
                pos = limitLW
            end
            self.levesnode:setPosition(cc.p(pos,self.levesnode:getPositionY()))
        elseif i > self.data.chapter and i < self.data.chapter + 4 then  
            self.maptab[i].sucimg:setVisible(false)
            self.cloudtab[i]:setVisible(false) 
            if self.cloudtab[i] then
                self.cloudtab[i]:setVisible(false)
            end
            self.maptab[i].btn:setBright(false)
        elseif i > self.data.chapter then
            --self.maptab[i].sucimg:loadTexture('uires/ui/guard/lock.png')
            self.maptab[i].sucimg:setVisible(false)
            self.cloudtab[i]:setVisible(true) 
            if self.cloudtab[i] then
                self.cloudtab[i]:setVisible(true)
            end
            self.maptab[i].btn:setBright(false)       
        end
    end
    self.numtx:setString(string.format(GlobalApi:getLocalStr('LEGION_LEVELS_NUMS'),legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy))
    UserData:getUserObj():setLegionCopyCount(self.data.copy_count)
end

function LegionLevelsMainUI:sendMsg()
    MessageMgr:sendPost('buy_count','legion','{}',function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.data.copy_buy = self.data.copy_buy + 1
            UserData:getUserObj():setLegionCopyBuy(self.data.copy_buy)
            self:update()   
            promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'), COLOR_TYPE.GREEN) 
        end
    end)  
end
return LegionLevelsMainUI