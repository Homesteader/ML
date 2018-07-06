local CloudOpenUI = class("CloudOpenUI", BaseUI)
function CloudOpenUI:ctor(callback,id)
    self.uiIndex = GAME_UI.UI_CLOUDOPEN
    self.callback = callback
    self.id = id
end

function CloudOpenUI:init()
    local cloudBgImg = self.root:getChildByName("cloud_bg_img")
    local pl = self.root:getChildByName("pl")
    self:adaptUI(cloudBgImg)
    cloudBgImg:setTouchEnabled(true)

    local winSize = cc.Director:getInstance():getVisibleSize()

    local cloudImg1 = cloudBgImg:getChildByName('cloud_1_img')
    local cloudImg2 = cloudBgImg:getChildByName('cloud_2_img')
    local openPl = cloudBgImg:getChildByName('open_pl')
    local openBgImg = openPl:getChildByName('open_bg_img')
    local openTx = openBgImg:getChildByName('open_tx')
    local descTx = openPl:getChildByName('desc_tx')
    openTx:setString(GlobalApi:getLocalStr('MAP_CLOUD_DESC_1'))
    descTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))

    local size = openPl:getContentSize()
    cloudImg1:setPosition(cc.p(winSize.width/2 + 220,winSize.height/2))
    cloudImg2:setPosition(cc.p(winSize.width/2 - 220,winSize.height/2))
    openPl:setPosition(cc.p(winSize.width/2,40 + size.height/2))
    pl:setPosition(cc.p(winSize.width/2,winSize.height/2))

    local fightedId = MapData:getFightedCityId()
    local conf = GameData:getConfData('local/cloudopen')
    local ids = {}
    for i=fightedId + 1,#MapData.data do
        local cityData = MapData.data[i]
        local group = cityData:getGroup()
        local funcOpen = cityData:getFuncOpen()
        if group == self.id and funcOpen and funcOpen ~= '' and conf[funcOpen] then
            ids[#ids + 1] = funcOpen
        end
    end
    local richText
    for i,v in ipairs(ids) do
        if i == 1 then
            richText = xx.RichText:create()
            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')
            richText:setContentSize(cc.size(500, 40))
            local rt = xx.RichTextImage:create(conf[v].url)
            rt:setScale(0.75)
            richText:addElement(rt)
            richText:setAnchorPoint(cc.p(0.5,0.5))
            richText:setPosition(cc.p(size.width/2,size.height/2))
            openPl:addChild(richText)
        else
            local rt = xx.RichTextImage:create('uires/ui/moduleopen/dian.png')
            rt:setScale(0.75)
            local rt1 = xx.RichTextImage:create(conf[v].url)
            rt1:setScale(0.75)
            richText:addElement(rt)
            richText:addElement(rt1)
        end
    end

    local time = 0.5
    cloudImg1:runAction(cc.MoveTo:create(time*2,cc.p(-100,winSize.height/2)))
    cloudImg1:runAction(cc.ScaleTo:create(time*2,8))
    cloudImg1:runAction(cc.FadeOut:create(time*2))

    cloudImg2:runAction(cc.MoveTo:create(time*2,cc.p(winSize.width + 100,winSize.height/2)))
    cloudImg2:runAction(cc.ScaleTo:create(time*2,8))
    cloudImg2:runAction(cc.FadeOut:create(time*2))

    local spine = GlobalApi:createSpineByName('ui_cloud_open', "spine/ui_cloud_open/ui_cloud_open", 1)
    spine:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))
    cloudBgImg:addChild(spine)
    spine:setOpacity(0)
    spine:setScale(0.01)
    spine:runAction(cc.FadeIn:create(time))
    spine:runAction(cc.Sequence:create(cc.ScaleTo:create(time,1),cc.CallFunc:create(function()
        spine:setAnimation(0, 'idle', true)
    end)))
    openPl:setOpacity(0)
    openPl:setScale(0.01)
    openPl:runAction(cc.FadeIn:create(time))
    openPl:runAction(cc.Sequence:create(cc.ScaleTo:create(time,1)))
    if #ids > 0 then
        cloudBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:hideUI()
                if self.callback then
                    self.callback()
                end
            end
        end)
    else
        spine:setPosition(cc.p(winSize.width/2,winSize.height/2 - 135))
        openPl:setVisible(false)
        cloudBgImg:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.FadeOut:create(0.5)))
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
            self:hideUI()
            if self.callback then
                self.callback()
            end
        end)))
    end
end

return CloudOpenUI