local LegionMainUI = class("LegionMainUI", BaseUI)
function LegionMainUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONMAIN
  self.data = data
  self.membertab = {}
  self.selectsorttype = 3 --默认职位排序
end

function LegionMainUI:onShow()
    self:update()
    if self.guideWhenOnShow then
        self.guideWhenOnShow = nil
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.LEGION)
    end
end
function LegionMainUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getWinSize()
    bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.alphabg = self.root:getChildByName('alpha_bg')
    self.alphabg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.alphabg:setTouchEnabled(false)
    local stageImg = bgimg:getChildByName('stage_img')
    stageImg:setLocalZOrder(4)
    local closebtn = self.root:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionMainUI()
        end
    end)
    closebtn:setPosition(cc.p(winSize.width,winSize.height))
    local rankbtn = self.root:getChildByName('rank_btn')
    rankbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RankingListMgr:showRankingListMain(5,nil)
        end
    end)
    rankbtn:setPosition(cc.p(winSize.width,200))
    local logbtn = self.root:getChildByName('log_btn')
    logbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionLogUI()
        end
    end)
    logbtn:setPosition(cc.p(winSize.width,100))

    local donatebtn = self.root:getChildByName('donate_btn')
    donatebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionDonateUI()
        end
    end)
    donatebtn:setPosition(cc.p(winSize.width,300)) 
    self.donateinfo = donatebtn:getChildByName('new_img')  
    local conf = GameData:getConfData('local/legionbuilding')
    self.plarr = {}
    for i=1,#conf do
        self.plarr[i] = bgimg:getChildByName('func_'..i..'_pl') 
    end
    for i,v in ipairs(conf) do
        local plPos = cc.p(self.plarr[v.pos]:getPositionX(),self.plarr[v.pos]:getPositionY())
        self.plarr[v.pos]:setLocalZOrder(v.zorder)
        if tonumber(conf.visble) == 0 then
            self.plarr[v.pos]:setVisible(false)
        end
        local namebg = self.plarr[v.pos]:getChildByName('name_bg')
        namebg:setLocalZOrder(99999)
        if  i == 2  then
            namebg:setVisible(false)
        end
        local nametx = namebg:getChildByName('name_tx')
        nametx:setString('')
        local newimg = namebg:getChildByName('new_img')
        newimg:setVisible(false)
        local nameimg = namebg:getChildByName('name_img')
        nameimg:loadTexture('uires/ui/legion/'..v.nameurl)
        nameimg:ignoreContentAdaptWithSize(true)
        local url = 'spine/legion_building/'..v.url
        local building = GlobalApi:createSpineByName(v.url, url, 1)
        local size = self.plarr[v.pos]:getContentSize()
        building:setPosition(cc.p(size.width/2,size.height/2))
        self.plarr[v.pos]:addChild(building)
        building:setScale(v.scale)
        building:registerSpineEventHandler(function (event)
            if event.animation == 'city_shake_1' then
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                    self:openPanel(i)
                    self.alphabg:setTouchEnabled(false)
                end)))
            end
        end, sp.EventType.ANIMATION_END)

        --玩家城池满行动力
        if i == 6 then
            self:showFullActionTip(self.plarr[v.pos])
        end

        self.plarr[v.pos]:addTouchEventListener(function (sender, eventType)
            if i == 2  then
                return
            end
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                building:setAnimation(0, 'city_shake_1', false)
                self.alphabg:setTouchEnabled(true)
            end
        end)
        
    end
    local roles = {'lvbu','daqiao','xiaoqiao'}
    for i,v in ipairs(roles) do
        self:runRole(v)
    end
    -- self:runRole()
    self:update()
end

function LegionMainUI:showFullActionTip(obj)


    local step = UserData:getUserObj():getMark().step or {}
    local flag = (not step[tostring(GUIDE_ONCE.TERRITORIAL_CITY)]) and true or false
    if flag then
        return
    end

    local maopaoBg = ccui.ImageView:create('uires/ui/activity/limitbuy_qipao.png')
    maopaoBg:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height-20))
    obj:addChild(maopaoBg,9998)
    maopaoBg:setScale(0.4)
    local maopaoTx = ccui.Text:create()
    maopaoTx:setFontName("font/gamefont1.TTF")
    maopaoTx:setFontSize(20)
    maopaoTx:setColor(COLOR_TYPE.OFFWHITE)
    maopaoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    maopaoTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT51"))
    maopaoTx:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height-12))
    obj:addChild(maopaoTx,9999)

    --满行动力提示
    local curPoint = UserData:getUserObj():getActionPoint()
    local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
    local max = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
    maopaoTx:setVisible(curPoint >= max)
    maopaoBg:setVisible(curPoint >= max)
end

function LegionMainUI:onShowUIAniOver()
    if not UserData:getUserObj():getName() or UserData:getUserObj():getName() == "" then
        self.guideWhenOnShow = true
    else
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.LEGION)
    end
end

function LegionMainUI:openPanel(index)
    local legionconf = GameData:getConfData('legion')
    if index == 1 then
        --军团战
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        if self.data.level < tonumber(legionconf['legionWarShowMinJoinLevel'].value) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionWarShowMinJoinLevel'].value), COLOR_TYPE.RED)
            return
        end
        LegionMgr:showLegionWarMainUI()
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 2 then
        --后宫
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 3 then
        --摇钱树
        if self.data.level < tonumber(legionconf['legionGoldTreeOpenLevel'].value) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionGoldTreeOpenLevel'].value), COLOR_TYPE.RED)
            return
        end
        LegionMgr:showLegionActivityShakeUI(self.data)
    elseif index == 4 then
        --活动大厅
        LegionMgr:showLegionActivityMainUI(self.data)
    elseif index == 5 then
        LegionMgr:showLegionMemberListUI()
        --成员大厅
    elseif index == 6 then

        --玩家城池
        local legionCfg = GameData:getConfData("legion")
        local limitLv = tonumber(legionCfg["legionDfOpenLevel"].value)
        local llevel = tonumber(UserData:getUserObj():getLLevel())
              llevel = llevel and llevel or 0
        local legionOpen = (llevel >= limitLv) and true or false 
        if not legionOpen then
            local errStr = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO46'),limitLv)
            promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
            return
        end
        
        LegionMgr:showLegionCityMainUI()
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 7 then
        --组队挂机
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        GlobalApi:getGotoByModule('legionTrial')
    elseif index == 8 then
        --待定
        -- promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        MainSceneMgr:showShop(51,{min = 51,max = 54})
    elseif index == 9 then
        --待定
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 10 then
        if self.data.level < tonumber(legionconf['legionCopyOpenLevel'].value) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionCopyOpenLevel'].value), COLOR_TYPE.RED)
            return
        end
        LegionMgr:showLegionLevelsMainUI()
        --军团远征
    end
end

function LegionMainUI:runRole(url)
    local bgimg = self.root:getChildByName("bg_img")
    local obj = RoleData:getMainRole()
    local conf = GameData:getConfData('local/legionnpcpos')
    local id = math.random(1,#conf)
    -- local spine = GlobalApi:createAniByName(obj:getUrl())
    local spine = GlobalApi:createLittleLossyAniByName(url.."_display")
    spine:setScale(0.28)
    spine:setLocalZOrder(conf[id].order)
    spine:setPosition(cc.p(conf[id].posX,conf[id].posY))
    bgimg:addChild(spine)

    -- spine:registerSpineEventHandler(function (event)
    --     spine:setAnimation(0, event.animation, false)
    -- end, sp.EventType.ANIMATION_COMPLETE)

    local oldId = id
    local function run(currId)
        -- spine:setAnimation(0, 'idle', false)
        spine:getAnimation():play('idle', -1, 1)
        local arr = conf[currId].nextIds
        local function getRandom()
            -- local random = math.random(1,#arr)
            -- print(arr[random] , oldId)
            -- if arr[random] ~= oldId then
            --     return arr[random]
            -- else
            --     return arr[getRandom()]
            -- end
            repeat
                local random = math.random(1,#arr)
                if arr[random] ~= oldId then
                    return arr[random]
                end
            until false
        end
        -- local endId = arr[math.random(1,#arr)]
        local endId = getRandom()
        local pos = cc.p(spine:getPositionX(),spine:getPositionY())
        local endPos = cc.p(conf[endId].posX,conf[endId].posY)
        spine:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2,4)),
            cc.CallFunc:create(function()
                local order = spine:getLocalZOrder()
                if conf[endId].order < order then
                    spine:setLocalZOrder(conf[endId].order)
                end
                if conf[endId].order == conf[currId].order then
                    spine:setLocalZOrder(conf[endId].order)
                end
                if pos.x < endPos.x then
                    spine:setScaleX(math.abs(spine:getScaleX()))
                else
                    spine:setScaleX(-math.abs(spine:getScaleX()))
                end
                spine:getAnimation():play('run', -1, 1)
            end),
            cc.MoveTo:create(5,cc.p(endPos)),
            cc.CallFunc:create(function()
                oldId = currId
                run(endId)
            end)))
    end
    run(id)
end

function LegionMainUI:update()

    local function getState()
        local step = UserData:getUserObj():getMark().step or {}
        local flag = (not step[tostring(GUIDE_ONCE.TERRITORIAL_CITY)]) and true or false
        return flag
    end

    local conf = GameData:getConfData('legion')
    local buildingconf = GameData:getConfData('local/legionbuilding')
    local legioninfo = UserData:getUserObj():getLegionInfo()
    local llevel = UserData:getUserObj():getLLevel()
    local status = {
        UserData:getUserObj():getSignByType('legion_war'),
        false,
        UserData:getUserObj():getSignByType('legion_goldtree'),
        UserData:getUserObj():getSignByType('legion_boon') or 
        UserData:getUserObj():getSignByType('legion_trial') or 
        UserData:getUserObj():getSignByType('legion_mercenary') or
        UserData:getUserObj():getSignByType('legion_wish'),
        UserData:getUserObj():getSignByType('legion_member_hall'),
        getState(),
        UserData:getUserObj():getSignByType('legionTrial'),
        false,
        false,
        UserData:getUserObj():getSignByType('legion_copy'),
    }
    for i=1,10 do
        local namebg = self.plarr[buildingconf[i].pos]:getChildByName('name_bg')
        local newimg = namebg:getChildByName('new_img')
        if newimg then
            newimg:setVisible(status[i])
        end
    end
    if UserData:getUserObj():getSignByType('legion_construct') then
        self.donateinfo:setVisible(true)
    else
        self.donateinfo:setVisible(false)
    end

end

function LegionMainUI:CalcRedInfo()
    
end
return LegionMainUI