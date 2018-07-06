local hookbulletmgr = require("script/app/ui/hook/hookbulletmgr")
local MainCityUI = class("MainCityUI", BaseUI)
local openTypes = {
    [1] = 'arena',
    [2] = 'tower',
    [3] = 'altar',
    [4] = 'mail',
    [5] = 'shop',
    [6] = 'pub',
    [7] = 'exploreMonster',
    [8] = 'goldmine_enter',
    [9] = 'legion',
    [10] = 'boat',
}
local function getDistance(x1, y1, x2, y2)
    return math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
end
function MainCityUI:ctor(callback,stype,ntype,waitUIIndex)
	self.uiIndex = GAME_UI.UI_MAINCITY
    self.callback = callback
    self.panelTouchEnable = true
    self.ntype = ntype
    self.stype = stype -- 屏幕位置
    self.allPos = {}
    self.npcPos = nil
    self.waitUIIndex = waitUIIndex
    self.ppindex = 1
    self.ppImg = {}
end

function MainCityUI:getMainCity()
    return self.root
end

function MainCityUI:update()
    self:updateSigns()
end

function MainCityUI:onShow()
    UIManager:setBlockTouch(false)
    self:update()
    self:handAction()
    UIManager:showSidebar({1,2,3,4,5,6,7,9,10,11,12,16},{1,2,3},true)
    self:setMapBtn()
end

function MainCityUI:setMapBtn()

    local function callback()
        self:printScreen()
    end
    UIManager.sidebar:setMapBtnCallback(GlobalApi:getLocalStr_new("MAINSCENE_BTN_STE1"),callback)
end

function MainCityUI:openPanel(index)
    UIManager:setBlockTouch(false)
    GlobalApi:getGotoByModule_new(openTypes[index])
    self.panelTouchEnable = true
    self.panel1:setTouchEnabled(self.panelTouchEnable)
end

function MainCityUI:updateSigns()
    if self.newImgs then
        local signs = {
            UserData:getUserObj():getSignByType('arena'),
            UserData:getUserObj():getSignByType('tower'),
            UserData:getUserObj():getSignByType('altar'),
            UserData:getUserObj():getSignByType('mail'),
            UserData:getUserObj():getSignByType('shop'),
            UserData:getUserObj():getSignByType('pub'),
            UserData:getUserObj():getSignByType('camp'),
            UserData:getUserObj():getSignByType('goldmine_enter'),
            UserData:getUserObj():getSignByType('legion'),
            UserData:getUserObj():getSignByType('boat'),
        }
        local open = {
            true,
            GlobalApi:getOpenInfo('tower'),
            GlobalApi:getOpenInfo('altar'),
            GlobalApi:getOpenInfo('mail'),
            GlobalApi:getOpenInfo('shop'),
            GlobalApi:getOpenInfo('pub'),
            GlobalApi:getOpenInfo('camp'),
            GlobalApi:getOpenInfo('goldmine_enter'),
            GlobalApi:getOpenInfo('legion'),
            GlobalApi:getOpenInfo('boat'),
        }
        for i,v in ipairs(self.newImgs) do
            v:setVisible(signs[i] and open[i])
        end
    end
end

--- 更新金矿和挖矿
function MainCityUI:updateGoldMineDiggingSign()
    if self.newImgs then
        if self.newImgs[8]:isVisible() == false then
            local sign = UserData:getUserObj():getSignByType('goldmine_digging')
            local open = GlobalApi:getOpenInfo('goldmine')
            self.newImgs[8]:setVisible(sign and open)
            print('================++++++=====-------------99999')
        end      
    end
end

--- 更新玩法大厅
function MainCityUI:updateBoatSign()
    if self.newImgs then
        if self.newImgs[10]:isVisible() == false then
            local sign = UserData:getUserObj():getSignByType('boat')
            local open = GlobalApi:getOpenInfo('boat')
            self.newImgs[10]:setVisible(sign and open)
            print('================++++++=====-------------88888')
        end      
    end
end

function MainCityUI:createBuilding()

    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityLandImg = panel3:getChildByName("main_city_land_img")

    local conf = GameData:getConfData("local/building")
    self.buildingPls = {}
    local buildCont = #conf
    self.newImgs = {}
    self.nameTx = {}
    self.lockImg = {}
    for i=1,buildCont do
        local pl = cityLandImg:getChildByName('building_'..i..'_pl')
        local bgImg = pl:getChildByName('bg_img')
        self.newImgs[i] = bgImg:getChildByName('new_img')
        self.newImgs[i]:loadTexture('uires/ui_new/common/new_dot.png')
        self.newImgs[i]:ignoreContentAdaptWithSize(true)
        self.buildingPls[#self.buildingPls + 1] = pl
        self.newImgs[i]:setLocalZOrder(9)
        pl:setSwallowTouches(false)
        bgImg:setScale(1.5)
        bgImg:setLocalZOrder(1)
        self.nameTx[i] = bgImg:getChildByName('text')
        self.lockImg[i] = bgImg:getChildByName('lock')
    end

    self.buildings = {}
    for i,v in ipairs(conf) do
        local plPos = cc.p(self.buildingPls[v.pos]:getPositionX(),self.buildingPls[v.pos]:getPositionY())
        self.allPos[v.url] = plPos
        if v.url == 'camp' then
            self.buildingPls[v.pos]:setLocalZOrder(10)
        else
            self.buildingPls[v.pos]:setLocalZOrder(10000-plPos.y)
        end
        self.buildings[v.pos] = ccui.ImageView:create('uires/ui_new/maincity/'..v.url..'.png')
        local size = self.buildingPls[v.pos]:getContentSize()
        self.buildings[v.pos]:setPosition(cc.p(size.width/2,size.height/2))
        self.buildingPls[v.pos]:addChild(self.buildings[v.pos])
        self.buildings[v.pos]:setScale(v.scale)
        self.buildings[v.pos]:setTouchEnabled(true)
        self.buildings[v.pos]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:openPanel(v.pos)
            end
        end)
        self.nameTx[v.pos]:setString(v.name)
        local isOpen = GlobalApi:getOpenInfo(openTypes[v.pos])
        self.lockImg[v.pos]:setVisible(not isOpen)

        if v.url == 'tavern' then
            self:createTavernPP(v.pos)
        end
    end

end

function MainCityUI:createTavernPP(index)
    
    local size = self.buildingPls[index]:getContentSize()
    for i=1,4 do 
        local ppImg = ccui.ImageView:create("uires/ui_new/tavern/pp"..i..".png")
        ppImg:setPosition(cc.p(size.width/2,size.height))
        ppImg:setScale(2.5)
        self.buildingPls[index]:addChild(ppImg)
        if i==3 then
            local ppSize = ppImg:getContentSize()
            local heroNameTx = ccui.Text:create()
            heroNameTx:setFontName("font/gamefont.ttf")
            heroNameTx:setFontSize(16)
            heroNameTx:setPosition(cc.p(ppSize.width/2, ppSize.height/2+10))
            heroNameTx:setName("heroname")
            heroNameTx:setAnchorPoint(cc.p(0,0.5))
            ppImg:addChild(heroNameTx)
            ppImg:setCascadeOpacityEnabled(true)

            local headIcon = ccui.ImageView:create()
            headIcon:setPosition(cc.p(40,ppSize.height/2+10))
            headIcon:setName("headIcon")
            headIcon:setScale(0.4)
            ppImg:addChild(headIcon)
        end
        self.ppImg[i] = ppImg
        self.ppImg[i]:setOpacity(0)
        self.ppImg[i]:setScale9Enabled(true)
    end

    local act = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()   
        if self.ppindex > 4 then
            self.ppindex = 1
            for i=1,4 do 
                self.ppImg[i]:setOpacity(0)
            end
        else

            if self.ppindex == 3 then
                local heroId = UserData:getUserObj():getTavenHotHero()
                local heroBaseConf,combatConf,modelConf = GlobalApi:getHeroConf(heroId)
                if heroBaseConf and combatConf and modelConf then
                   local heroNameTx = self.ppImg[self.ppindex]:getChildByName("heroname")
                   heroNameTx:setString(heroBaseConf.heroName)
                   heroNameTx:setColor(COLOR_QUALITY[combatConf.quality])
                   heroNameTx:enableOutline(COLOROUTLINE_QUALITY[combatConf.quality], 2)
                   local heroIcon = self.ppImg[self.ppindex]:getChildByName("headIcon")
                   heroIcon:loadTexture("uires/icon/hero/" .. modelConf.headIcon)
                end
            end

            local ppact = cc.Sequence:create(cc.FadeIn:create(1),cc.CallFunc:create(function()
                self.ppindex = self.ppindex + 1
            end))
            self.ppImg[self.ppindex]:runAction(ppact)
            local lastIndex = self.ppindex-1
            if self.ppImg[lastIndex] then
                self.ppImg[lastIndex]:stopAllActions()
            end
        end
    end))

    self.buildingPls[index]:runAction(cc.RepeatForever:create(act))
end

--[[
function MainCityUI:createBuilding()
    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityLandImg = panel3:getChildByName("main_city_land_img")
    local landImg1 = cityLandImg:getChildByName("land_1_img")

    landImg1:setLocalZOrder(2)
    local conf = GameData:getConfData("local/building")
    self.buildingPls = {}
    local buildingNameImgs = {
        'uires/ui/maincity/arena_tx_img.png',
        'uires/ui/maincity/tx_fb.png',
        'uires/ui/maincity/blacksmith_tx_img.png',
        'uires/ui/maincity/pub_tx_img.png',
        'uires/ui/maincity/email_tx_img.png',
        'uires/ui/maincity/tx_qct.png',
        'uires/ui/maincity/tx_jk.png',
        'uires/ui/maincity/altar_tx_img.png',
        'uires/ui/maincity/statue_tx_img.png',
        'uires/ui/maincity/shoulan_tx_img.png',
        'uires/ui/maincity/businessman_tx_img.png',
        'uires/ui/maincity/worldwar_tx_img.png',
    }
    self.newImgs = {}
    for i=1,12 do
        local pl = cityLandImg:getChildByName('building_'..i..'_pl')
        local bgImg = pl:getChildByName('bg_img')
        self.newImgs[i] = pl:getChildByName('new_img')
        self.newImgs[i]:loadTexture('uires/ui/buoy/new_point.png')
        self.newImgs[i]:ignoreContentAdaptWithSize(true)
        self.buildingPls[#self.buildingPls + 1] = pl
        self.newImgs[i]:setLocalZOrder(9)
        pl:setSwallowTouches(false)
        pl:setLocalZOrder(10)
        if bgImg then
            bgImg:setScale(1.2)
            bgImg:setLocalZOrder(1)
            local txImg = bgImg:getChildByName('tx_img')
            bgImg:loadTexture('uires/ui/maincity/building_bg.png')
            local size = bgImg:getContentSize()
            local lockImg = ccui.ImageView:create('uires/ui/guard/lock.png')
            lockImg:setScale(0.7)
            lockImg:setPosition(cc.p(size.width/2 + 5,0))
            lockImg:setName('lock_img')
            bgImg:addChild(lockImg)
            txImg:loadTexture(buildingNameImgs[i])
            bgImg:ignoreContentAdaptWithSize(true)
            txImg:ignoreContentAdaptWithSize(true)
            if i == 10 then
                bgImg:setVisible(false)
            end
        end
    end
    self.buildings = {}
    for i,v in ipairs(conf) do
        local plPos = cc.p(self.buildingPls[v.pos]:getPositionX(),self.buildingPls[v.pos]:getPositionY())
        self.allPos[v.url] = plPos
        self.buildingPls[v.pos]:setLocalZOrder(v.zorder)
        local url = 'spine/city_building/'.. v.url
        self.buildings[v.pos] = GlobalApi:createSpineByName(v.url, url, 1)
        local size = self.buildingPls[v.pos]:getContentSize()
        self.buildings[v.pos]:setPosition(cc.p(size.width/2,0))
        self.buildingPls[v.pos]:addChild(self.buildings[v.pos])
        self.buildings[v.pos]:setScale(v.scale*0.77)
        local action = 'idle'
        self.buildings[v.pos]:registerSpineEventHandler(function (event)
            local hadNewMail = UserData:getUserObj():getHadNewMail()
            action = ((hadNewMail == true and v.pos == 5) and 'idle_youjian') or 'idle'
            self.buildings[v.pos]:setAnimation(0, action, false)
        end, sp.EventType.ANIMATION_COMPLETE)

        self.buildings[v.pos]:registerSpineEventHandler(function (event)
            if event.animation == 'idle2' or event.animation == 'idle2_youjian' then
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                    self:openPanel(v.pos)
                end)))
            end
        end, sp.EventType.ANIMATION_END)

        local bgImg = self.buildingPls[v.pos]:getChildByName('bg_img')
        if bgImg then
            local lockImg = bgImg:getChildByName('lock_img')
            local isOpen = GlobalApi:getOpenInfo(openTypes[v.pos])
            lockImg:setVisible(not isOpen)
        end

        local point1
        local point2
        self.buildingPls[v.pos]:addTouchEventListener(function (sender, eventType)
            if v.url == 'stable' then
                return
            end
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                point1 = sender:getTouchBeganPosition()
            end
            if eventType == ccui.TouchEventType.ended then
                point2 = sender:getTouchEndPosition()
                if point1 then
                    local dis =cc.pGetDistance(point1,point2)
                    if self.panelTouchEnable == false or dis <= 50 then
                        local hadNewMail = UserData:getUserObj():getHadNewMail()
                        action = ((hadNewMail == true and v.pos == 5) and 'idle2_youjian') or 'idle2'
                        self.buildings[v.pos]:setAnimation(0, action, false)
                        UIManager:setBlockTouch(true)
                    end
                end
            end
        end)
        local hadNewMail = UserData:getUserObj():getHadNewMail() or false
        action = ((hadNewMail == true and v.pos == 5) and 'idle_youjian') or 'idle'
        self.buildings[v.pos]:setAnimation(0, action, false)
    end
end]]

function MainCityUI:monsterMove(pl,npc,npos)
    local posX,posY = npos.x,npos.y
    local pos = {cc.p(posX - 200,posY),cc.p(posX,posY),cc.p(posX + 200,posY)}
    local function getRandom()
        repeat
            local random =math.random(1,3)
            if random == self.random then
                self.random = random %3 + 1
                return
            else
                self.random = random
                return
            end
        until false
    end
    getRandom()
    local posX1 = pos[self.random].x
    local currPosX = pl:getPositionX()
    local time = math.abs(currPosX - posX1)/100
    if currPosX < posX1 then
        npc:setScaleX(math.abs(npc:getScaleX()))
    else
        npc:setScaleX(-math.abs(npc:getScaleX()))
    end

    npc:setAnimation(0,'walk', false)
    pl:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,cc.p(posX1,posY)),
        cc.CallFunc:create(function()
            npc:setAnimation(0,'idle', false)
        end),
        cc.DelayTime:create(math.random(3,5)),
        cc.CallFunc:create(function()
            self:monsterMove(pl,npc,npos)
        end)
    ))
end

function MainCityUI:createNPC()
    local pl = self.cityLandImg:getChildByName('building_13_pl')
    self.newImgs[13] = pl:getChildByName('new_img')
    self.newImgs[13]:loadTexture('uires/ui/buoy/new_point.png')
    self.newImgs[13]:ignoreContentAdaptWithSize(true)
    self.newImgs[13]:setLocalZOrder(9)
    local npc = GlobalApi:createSpineByName("train", "spine/city_building/train", 1)
    npc:setScale(0.77)
    local size = pl:getContentSize()
    npc:setName('train')
    npc:setPosition(cc.p(size.width/2,0))
    -- npc:setName('train')
    pl:addChild(npc)
    pl:setLocalZOrder(9)

    npc:registerSpineEventHandler(function (event)
        if event.animation == 'walk' then
            npc:setAnimation(0, 'walk', false)
        else
            npc:setAnimation(0, 'idle', false)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    npc:registerSpineEventHandler(function (event)
        if event.animation == 'idle2' then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                self:openPanel(13)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function( )
                local pos = cc.p(pl:getPositionX(),pl:getPositionY())
                self:monsterMove(pl,npc,pos)
            end)
            ))
        end
    end, sp.EventType.ANIMATION_END)

    local point1
    local point2
    pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            point1 = sender:getTouchBeganPosition()
        end
        if eventType == ccui.TouchEventType.ended then
            point2 = sender:getTouchEndPosition()
            if point1 then
                local dis =cc.pGetDistance(point1,point2)
                if self.panelTouchEnable == false or dis <= 50 then
                    npc:setAnimation(0, 'idle2', false)
                    pl:stopAllActions()
                    UIManager:setBlockTouch(true)
                end
            end
        end
    end)
    npc:setAnimation(0, 'idle', false)
    
    local pos = cc.p(pl:getPositionX(),pl:getPositionY())
    self:monsterMove(pl,npc,pos)
end

function MainCityUI:createFly1(animal1)
    local size = self.cityMountainImg:getContentSize()
    local index = math.random(1,2)
    local height = size.height - math.random(110,180)
    local beginPos = {
        cc.p(-100,height),
        cc.p(size.width + 100,height),
    }
    local endPos = {
        cc.p(size.width + 100,height),
        cc.p(-100,height),
    }
    animal1:setPosition(cc.p(beginPos[index]))
    if beginPos[index].x < endPos[index].x then
        animal1:setScaleX(-math.abs(animal1:getScaleX()))
    else
        animal1:setScaleX(math.abs(animal1:getScaleX()))
    end
    local time = math.abs(endPos[index].x - beginPos[index].x)/math.random(80,120)
    animal1:runAction(cc.Sequence:create(
        cc.DelayTime:create(math.random(5,8)),
        cc.MoveTo:create(time,endPos[index]),
        cc.CallFunc:create(function()
            self:createFly1(animal1)
        end)
        ))
end

function MainCityUI:createFly2(animal2)
    local size = self.cityMountainImg:getContentSize()
    local index = math.random(1,3)
    local beginPos = {
        cc.p(size.width/2 + math.random(-50,50),0),
        cc.p(size.width/2 + math.random(50,150),0),
        cc.p(size.width/2 + math.random(150,250),0)
    }
    local endPos = {
        cc.p(-100,size.height - math.random(50,120)),
        cc.p(size.width/2 - math.random(450,550),size.height + 100),
        cc.p(size.width + 100,size.height - math.random(100,180))
    }
    animal2:setPosition(cc.p(beginPos[index]))
    local time = math.abs(endPos[index].x - beginPos[index].x)/math.random(80,120)
    animal2:runAction(cc.Sequence:create(
        cc.DelayTime:create(math.random(5,8)),
        cc.MoveTo:create(time,endPos[index]),
        cc.CallFunc:create(function()
            self:createFly2(animal2)
        end)
        ))
end

function MainCityUI:createPubu()
    local pubu1 = GlobalApi:createLittleLossyAniByName('scene_tx_pubu_01')
    pubu1:setPosition(cc.p(1750,280))
    -- pubu1:setPosition(cc.p(1745,275))
    pubu1:getAnimation():playWithIndex(0, -1, 1)
    self.cityMountainImg:addChild(pubu1)
    pubu1:setScaleY(1.2)

    local pubu2 = GlobalApi:createLittleLossyAniByName('scene_tx_pubu_02')
    pubu2:setPosition(cc.p(1288,335))
    pubu2:getAnimation():playWithIndex(0, -1, 1)
    self.cityMountainImg:addChild(pubu2)

    local size = self.cityMountainImg:getContentSize()
    local animal1 = GlobalApi:createSpineByName('mainscene_animal_1', "spine/mainscene_animal_1/mainscene_animal_1", 1)
    animal1:setAnchorPoint(cc.p(0.5,0))
    animal1:setPosition(cc.p(size.width/2,0))
    animal1:setAnimation(0, 'fly', true)
    self.cityMountainImg:addChild(animal1)

    local animal2 = GlobalApi:createSpineByName('mainscene_animal_2', "spine/mainscene_animal_2/mainscene_animal_2", 1)
    animal2:setAnchorPoint(cc.p(0.5,0))
    animal2:setPosition(cc.p(size.width/2,0))
    animal2:setAnimation(0, 'fly', true)
    self.cityMountainImg:addChild(animal2)

    local animal3 = GlobalApi:createSpineByName('mainscene_animal_3', "spine/mainscene_animal_3/mainscene_animal_3", 1)
    animal3:setAnchorPoint(cc.p(0.5,0))
    animal3:setPosition(cc.p(953,176))
    animal3:setAnimation(0, 'idle', true)
    self.cityMountainImg:addChild(animal3)

    local penquan = GlobalApi:createLittleLossyAniByName('scene_tx_penquan_01')
    penquan:setScale(1)
    penquan:setAnchorPoint(cc.p(0,0))
    penquan:setPosition(cc.p(3350,220))
    penquan:getAnimation():playWithIndex(0, -1, 1)
    self.cityLandImg:addChild(penquan,2)

    local shuiwen = GlobalApi:createLittleLossyAniByName('scene_tx_shuiwen_01')
    shuiwen:setScale(2.6)
    shuiwen:setAnchorPoint(cc.p(0,0))
    shuiwen:setPosition(cc.p(0,0))
    shuiwen:getAnimation():playWithIndex(0, -1, 1)
    self.cityLandImg:addChild(shuiwen)

    self:createFly1(animal1)
    self:createFly2(animal2)
end

-- ntype 是否直接定位
-- 定位
function MainCityUI:setWinPosition(stype,lock)
    print(stype)
    local pos = self.allPos[stype]
    if stype == 'train' then
        local pl = self.cityLandImg:getChildByName('building_13_pl')
        local npc = pl:getChildByName('train')
        if npc then
            npc:setAnimation(0, 'idle', false)
        end
        pl:stopAllActions()
        pos = cc.p(pl:getPositionX(),pl:getPositionY())
    end
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    local pos1 = pos.x - winSize.width/2
    local posX,posY = winSize.width/2 - pos.x*self.scale,self.imgs:getPositionY()
    local point = cc.p(posX*0.83,posY*0.83)
    self:detectEdges(point)
    local per = (point.x - self.limitLWs)/(self.limitRWs - self.limitLWs)
    self.imgs:setPosition(point)

    if lock then
        self.panelTouchEnable = false
        self.panel1:setTouchEnabled(self.panelTouchEnable)
    end
end
--边界检测
function MainCityUI:detectEdges(point )
    if point.x > self.limitRWs then
        point.x = self.limitRWs
    end
    if point.x < self.limitLWs then
        point.x = self.limitLWs
    end
    if point.y > self.limitUHs then
        point.y = self.limitUHs
    end
    if point.y < self.limitDHs then
        point.y = self.limitDHs
    end
end

function MainCityUI:initCity()
    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityImg = panel3:getChildByName("main_city_land_img")
    cityImg:loadTexture('uires/ui_new/maincity/city_bg.png')
    cityImg:ignoreContentAdaptWithSize(true)
    self.panel1 = panel1

    local winSize = cc.Director:getInstance():getVisibleSize()
    local width = cityImg:getContentSize().width
    local height1 = cityImg:getContentSize().height
    local scale = winSize.height/768
    scale = 0.5
    cityImg:setScale(scale)
    
    local point = cityImg:getAnchorPoint()
    
    self.limitLWs = winSize.width - width*scale*(1 - point.x)
    self.limitRWs = width*scale*point.x
    self.limitUHs = height1*scale*point.y
    self.limitDHs = winSize.height - height1*scale*(1 - point.y)


    self.abs = abs
    self.imgs = cityImg
    self.scale = scale

    local function onKeyboardPressed(keyCode,event)
        if tonumber(keyCode) == 140 then
			UIManager:backToLogin()
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyboardPressed,cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher1 = self.root:getEventDispatcher()
    eventDispatcher1:addEventListenerWithSceneGraphPriority(listener, self.root)

    local bgPanelPrePos = nil
    local bgPanelPos = nil
    local bgPanelDiffPos = nil
    local cliclBeginPos = nil
    panel1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
                bgPanelDiffPos = cc.p(bgPanelPos.x - bgPanelPrePos.x, bgPanelPos.y - bgPanelPrePos.y)
                local targetPos = cc.pAdd(cc.p(cityImg:getPositionX(),cityImg:getPositionY()),bgPanelDiffPos)
                self:detectEdges(targetPos)
                cityImg:setPosition(targetPos)
            end
        else
            bgPanelPrePos = nil
            bgPanelPos = nil
            bgPanelDiffPos = nil
            if eventType == ccui.TouchEventType.began then
                cliclBeginPos = sender:getTouchBeganPosition()
            elseif eventType == ccui.TouchEventType.ended then
                --[[local point = sender:getTouchEndPosition()
                if getDistance(cliclBeginPos.x, cliclBeginPos.y, point.x, point.y) == 0 then
                    local convertPos = cityImg:convertToNodeSpace(point)
                    logger(convertPos.x,convertPos.y)
                    local img = ccui.ImageView:create("uires/ui_new/common/new_dot.png")
                    img:setPosition(convertPos)
                    cityImg:addChild(img)
                end]]
            end
        end
    end)

    hookbulletmgr:init(self.imgs)
    hookheromgr:init(self.imgs)
    
    self:createBuilding()
    self:setWinPosition(self.stype or 'arena')
    self:handAction()
    --self:createNPC()
    --self:createPubu()
    self:update()

    UIManager:showSidebar({1,2,3,4,5,6,7,9,10,11,12,16},{1,2,3},true)

    if self.callback then
        self.callback()
    end
    self:addCustomEventListener(CUSTOM_EVENT.GUIDE_FINISH,function()
        if self:isOnTop() then
            UIManager:showSidebar({1,2,3,4,5,6,7,9,10,11,12,16},{1,2,3},true)
        end
    end)
    self:addCustomEventListener(CUSTOM_EVENT.GUIDE_START,function()
        self:handAction(true)
    end)
end

function MainCityUI:handAction(b)
    --[[征战按钮提示
    local panel1 = self.root:getChildByName("Panel_1")
    local level = UserData:getUserObj():getLv()
    local guideImg = panel1:getChildByName('guide_img')
    local size = self.fightBtn:getContentSize()
    if not guideImg then
        guideImg = ccui.ImageView:create('uires/ui/maincity/new.png')
        guideImg:setPosition(cc.p(size.width*3/4,size.height))
        panel1:addChild(guideImg)
        guideImg:setName('guide_img')
        guideImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.DelayTime:create(0.5),cc.FadeIn:create(2))))
        guideImg:setCascadeOpacityEnabled(true)

        local descTx = ccui.Text:create()
        descTx:setFontName("font/gamefont1.TTF")
        descTx:setFontSize(24)
        descTx:setPosition(cc.p(size.width/2 - 5,43))
        descTx:setTextColor(COLOR_TYPE.WHITE)
        descTx:enableOutline(cc.c3b(146,58,5), 1)
        descTx:setAnchorPoint(cc.p(0.5,0.5))
        descTx:setName('desc_tx')
        guideImg:addChild(descTx)
    end
    local descTx = guideImg:getChildByName('desc_tx')
    guideImg:setVisible(false)
    if not b and level <= 15 and GuideMgr:isRunning() ~= true then
        guideImg:setVisible(true)
        descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_1'))
    elseif not b and level <= 25 and GuideMgr:isRunning() ~= true then
        guideImg:setVisible(true)
        descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_2'))
    elseif MapMgr.thief then
        local hadThief = false
        local nowTime = GlobalData:getServerTime()
        local conf = GameData:getConfData("thief")
        for k,v in pairs(MapMgr.thief) do
            local thiefConf = conf[tonumber(v.id)]
            local beginTime = tonumber(v.time)
            local diffTime = beginTime + tonumber(thiefConf.liveTime)*60 - GlobalData:getServerTime()
            if diffTime > 0 then
                hadThief = true
                break
            end
        end
        if hadThief then
            guideImg:setVisible(true)
            descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_3'))
        end
    end]]
end

function MainCityUI:printScreen()
     print(socket.gettime())
     hookheromgr:clearArmature()
     UIManager:runLoadingAction(nil,function()
        MainSceneMgr:hideMainCity()
        MapMgr:showMainScene(1,nil,nil,true,function()
            UIManager:removeLoadingAction()
        end)
    end)
end

function MainCityUI:loadingTexture()

    self.animationMap = {}
    local hookHeroMap = RoleData:getRoleMap()
    for i=1,#hookHeroMap do
        local roleObj  = RoleData:getRoleByPos(i)
        if roleObj and roleObj:getId() > 0 then
            local heroid = roleObj:getId()
            local _,heroCombatInfo,heroModelConf = GlobalApi:getHeroConf(heroid)
            local heroUrl = "animation/" .. heroModelConf.modelUrl .. "/" .. heroModelConf.modelUrl
            if self.animationMap[heroUrl] == nil then
                if string.sub(heroModelConf.modelUrl, 1, 4) == "nan_" then
                    self.animationMap[heroUrl] = "animation/nan/nan"
                else
                    self.animationMap[heroUrl] = 0
                end
            end
        end
    end
    self.loadingUI = UIManager:getLoadingUI()
    self.loadingUI:setPercent(0)
    local loadedImgCount = 0
    local asyncImgCount = 15
    local loadedImgMaxCount = asyncImgCount+#hookHeroMap
    local function imageLoaded()
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        self.loadingUI:setPercent(loadingPercent)
        if loadedImgCount >= asyncImgCount then
            self:loadAnimationRes(loadedImgCount,loadedImgMaxCount,#hookHeroMap)
        end
    end
    UserData:getUserObj():getMainCityInfo(imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/cash.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/food.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/gold.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/city_bg.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/altar.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/arena.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/bravertower.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/honourhall.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/mail.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/store.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/tavern.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/union.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/mine.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui_new/maincity/gold.png',imageLoaded)

    --[[
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/arena_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/tx_fb.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/blacksmith_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/pub_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/email_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/tx_qct.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/tx_jk.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/trainer_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/businessman_tx_img.png',imageLoaded) 
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/altar_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/rank_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/shoulan_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/worldwar_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/building_bg.png',imageLoaded)

    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_house_01.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_house_02.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_land_01.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_land_02.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_land_03.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_mountain_01.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_cloud_01.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_shadow.png',imageLoaded)
    
    GlobalApi:createSpineAsyncByName('arena','spine/city_building/arena', imageLoaded)
    GlobalApi:createSpineAsyncByName('blacksmith','spine/city_building/blacksmith', imageLoaded)
    GlobalApi:createSpineAsyncByName('boat','spine/city_building/boat', imageLoaded)
    GlobalApi:createSpineAsyncByName('email','spine/city_building/email', imageLoaded)
    GlobalApi:createSpineAsyncByName('altar','spine/city_building/altar', imageLoaded)
    GlobalApi:createSpineAsyncByName('stable','spine/city_building/stable', imageLoaded)
    GlobalApi:createSpineAsyncByName('statue','spine/city_building/statue', imageLoaded)
    GlobalApi:createSpineAsyncByName('goldmine','spine/city_building/goldmine', imageLoaded)
    GlobalApi:createSpineAsyncByName('altar','spine/city_building/altar', imageLoaded)
    GlobalApi:createSpineAsyncByName('stable','spine/city_building/stable', imageLoaded)
    GlobalApi:createSpineAsyncByName('statue','spine/city_building/statue', imageLoaded)
    GlobalApi:createSpineAsyncByName('tower','spine/city_building/tower', imageLoaded)
    GlobalApi:createSpineAsyncByName('pub','spine/city_building/pub', imageLoaded)]]   
end

function MainCityUI:loadAnimationRes(loadedImgCount,loadedImgMaxCount,totalCount)

    local countPerFrame = math.ceil(totalCount/30)
    local loadedCount = 0
    local count = 0
    local co = coroutine.create(function ()
        for k, v in pairs(self.animationMap) do
            if v == 0 then
                hookheromgr:loadAnimationRes(k, k)
            else
                hookheromgr:loadAnimationRes(v, k)
            end
            
            loadedCount = loadedCount + 1
            if loadedCount == totalCount then
                coroutine.yield()
            end
        end
    end)
    
    --[[self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
        loadingUI:runToPercent(0.2, 100, function ()
            if self.waitUIIndex then
                self:addCustomEventListener(CUSTOM_EVENT.UI_SHOW, function (uiIndex)
                    if uiIndex == self.waitUIIndex then
                        self:removeCustomEventListener(CUSTOM_EVENT.UI_SHOW)
                        self.waitUIIndex = nil
                        UIManager:hideLoadingUI()
                    end
                end)
            else
                UIManager:hideLoadingUI()
            end
            self:initCity()
        end)
    end)))]]

    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self.loadingUI:setPercent((loadedImgCount+loadedCount)/loadedImgMaxCount*90)
        if not coroutine.resume(co) then
            self.root:unscheduleUpdate()
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                local function callback()
                    if self.waitUIIndex then
                        self:addCustomEventListener(CUSTOM_EVENT.UI_SHOW, function (uiIndex)
                            if uiIndex == self.waitUIIndex then
                                self:removeCustomEventListener(CUSTOM_EVENT.UI_SHOW)
                                self.waitUIIndex = nil
                                UIManager:hideLoadingUI()
                            end
                        end)
                    else
                        UIManager:hideLoadingUI()
                    end
                    self:initCity()
                end
                self.loadingUI:runToPercent(0.2, 100, function ()
                    self.loadingUI = nil
                    callback()
                end)
            end)))
        end
    end, 0)
end

function MainCityUI:init()
    if self.ntype then
        self:initCity()
    else
        self:loadingTexture()
    end
    self:setMapBtn()
end

return MainCityUI