local PowerEndUI = class("PowerEndUI", BaseUI)
local BASE_YEAR = 221

function PowerEndUI:ctor(name,callback,id)
	self.uiIndex = GAME_UI.UI_POWEREND
    self.callback = callback
    self.name = name
    self.id = id
    print('====================xxxx',self.id)
end

function PowerEndUI:eggsFly()
    local id = MapData.data[self.id]:getDragon() - 2
    local currChipImg
    local currEggImg
    for i=1,10 do
        local eggImg = self.bgImg2:getChildByName('egg_img_'..i)
        local chipImg = self.bgImg2:getChildByName('chip_img_'..i)
        local index = i
        if i == 10 then
            index = 9
        end
        if i < id then
            -- eggImg:setVisible(false)
            eggImg:loadTexture('uires/ui/mainscene/flag.png')
            eggImg:setScale(1)
            chipImg:setVisible(true)
        elseif i == id then
            eggImg:loadTexture('uires/ui/treasure/egg_'..(index + 1)..'.png')
            currChipImg = chipImg
            currEggImg = eggImg
        else
            eggImg:loadTexture('uires/ui/treasure/egg_'..(index + 1)..'.png')
            eggImg:setVisible(true)
            chipImg:setVisible(false)
        end
        eggImg:ignoreContentAdaptWithSize(true)
    end
    self.bgImg1:setVisible(false)
    self.bgImg2:setVisible(true)
    currChipImg:setOpacity(0)
    local size = self.bgImg2:getContentSize()
    local effect = GlobalApi:createLittleLossyAniByName('ui_dan_light')
    effect:setPosition(cc.p(size.width/2,size.height/2))
    -- effect:getAnimation():playWithIndex(0, -1, -1)
    effect:setName('ui_dan_light')
    -- effect:setScale(1.25)
    effect:setLocalZOrder(8)
    effect:setVisible(false)
    self.bgImg2:addChild(effect)
    currChipImg:runAction(cc.Sequence:create(cc.Repeat:create(
        cc.Sequence:create(
            cc.FadeIn:create(0.2),
            cc.DelayTime:create(0.1),
            cc.FadeOut:create(0.2),
            cc.DelayTime:create(0.1)
            ),
        2),cc.FadeIn:create(0.2),cc.CallFunc:create(function()
            effect:setVisible(true)
            effect:getAnimation():play('start', -1, 0)
            currEggImg:setLocalZOrder(9)
            currEggImg:runAction(cc.ScaleTo:create(0.5,1))
            currEggImg:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(size.width/2,size.height/2)),cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                MapData.data[self.id]:setBfirst(false)
                MapMgr:hidePowerEndPanel()
                if id == 10 then
                    if self.callback then
                        self.callback()
                    end
                else
                    UIManager:getSidebar():mapBtnsFly('egg',function()
                        if self.callback then
                            self.callback()
                        end
                    end,id)
                end
            end)))
        end)))
end

function PowerEndUI:init()
	self.bgImg = self.root:getChildByName("bg_img")
    self.bgImg1 = self.root:getChildByName("bg_1_img")
    self.bgImg2 = self.root:getChildByName("bg_2_img")
    self.bgImg1:setVisible(true)
    self.bgImg2:setVisible(false)
	local powerEndPl = self.bgImg:getChildByName("power_end_pl")
    self:adaptUI(self.bgImg)

    local powerEndBgImg = powerEndPl:getChildByName('powe_end_bg_img')
    powerEndBgImg:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('POWERENDDES1'))
    local nameTx = powerEndBgImg:getChildByName('name_tx')
    local topImg = powerEndPl:getChildByName('top_img')
    local bottomImg = powerEndPl:getChildByName('bottom_img')
    local winSize = cc.Director:getInstance():getVisibleSize()
    nameTx:setString(self.name)
    -- 386
    powerEndPl:setContentSize(cc.size(winSize.width,300))
    topImg:setContentSize(cc.size(winSize.width,10))
    bottomImg:setContentSize(cc.size(winSize.width,10))
    topImg:setPosition(cc.p(winSize.width/2,304))
    bottomImg:setPosition(cc.p(winSize.width/2,-4))
    topImg:setLocalZOrder(2)
    bottomImg:setLocalZOrder(2)
    powerEndPl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    powerEndBgImg:setPosition(cc.p(winSize.width/2,41))
    self.bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.bgImg2:setPosition(cc.p(winSize.width/2,winSize.height/2))

    local id = MapData.data[self.id]:getDragon() - 2
    local year = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_year_'..id,''))
    if not year then
        local baseYear = BASE_YEAR + (id - 1)*6
        year = math.random(baseYear,baseYear + 5)
        cc.UserDefault:getInstance():setStringForKey('power_end_year_'..id,year)
    end
    local size = self.bgImg:getContentSize()
    local size1 = powerEndPl:getContentSize()
    local richText = xx.RichText:create()
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(600, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POWER_END_DESC_1')..year..GlobalApi:getLocalStr('POWER_END_DESC_2'),28,COLOR_TYPE.WHITE)
    local re2 = xx.RichTextLabel:create(UserData:getUserObj():getName(),28,COLOR_TYPE.YELLOW)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POWER_END_DESC_3'),28,COLOR_TYPE.WHITE)
    local re4 = xx.RichTextLabel:create(self.name,28,COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
    re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re4:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(size.width/2,120))
    self.bgImg:addChild(richText)

    local powerEnd = GlobalApi:createSpineByName('power_end', "spine/power_end/power_end", 1)
    topImg = powerEndPl:getChildByName('top_img')
    bottomImg = powerEndPl:getChildByName('bottom_img')
    powerEnd:setLocalZOrder(1)
    powerEndBgImg:setLocalZOrder(2)
    powerEnd:registerSpineEventHandler(function (event)
        if event.animation == 'idle' then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                -- MapData.data[self.id]:setBfirst(false)
                -- MapMgr:hidePowerEndPanel()
                -- if self.callback then
                --     self.callback()
                -- end
                self:eggsFly()
            end)))
        end
    end, sp.EventType.ANIMATION_END)
    -- powerEnd:setPosition(cc.p(winSize.width/2,winSize.height/2 - 193))
    powerEnd:setPosition(cc.p(size1.width/2,size1.height/2))
    powerEndPl:addChild(powerEnd)

    richText:setCascadeOpacityEnabled(true)
    richText:setOpacity(0)
    richText:runAction(cc.Sequence:create(cc.FadeIn:create(4)))
    powerEndBgImg:setOpacity(0)
    powerEndBgImg:runAction(cc.Sequence:create(cc.FadeIn:create(2),cc.CallFunc:create(function()
        self.bgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                -- powerEnd:stopAllActions()
                print('=======================1')
                -- MapData.data[self.id]:setBfirst(false)
                -- MapMgr:hidePowerEndPanel()
                -- if self.callback then
                --     self.callback()
                -- end
                self:eggsFly()
            end
        end)
    end)))
    powerEnd:setAnimation(0, "idle", false)
    powerEnd:runAction(cc.Sequence:create(cc.ScaleTo:create(2,1.2)))
end

return PowerEndUI