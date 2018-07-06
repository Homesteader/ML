local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideTalk = class("GuideTalk", ClassGuideBase)

function GuideTalk:ctor(guideNode, guideObj)
    self.guideObj = guideObj
    self.guideNode = guideNode
end

function GuideTalk:startGuide()
    local guideObj = self.guideObj
    local conf = GameData:getConfData("local/guidetext")[guideObj.text]
    local node = cc.Node:create()
    --local dialogNode = cc.Node:create()
    --dialogNode:setVisible(false)
    local npc = GlobalApi:createLittleLossyAniByName("guide_npc_" .. guideObj.npc)
    local aniName = guideObj.animation or "idle"
    npc:getAnimation():play(aniName, -1, -1)
    npc:setAnchorPoint(cc.p(0.5, 0))
    if guideObj.npcscalex then
        npc:setScaleX(guideObj.npcscalex)
    end
    local dialog = cc.Sprite:create("uires/ui/guide/bg_dialog.png")
    local dialogSize = dialog:getContentSize()
    dialog:setVisible(false)

    local label = cc.Label:createWithTTF(conf.text, "font/gamefont.ttf", 20)
    label:setMaxLineWidth(250)
    label:setAnchorPoint(cc.p(0, 1))
    label:setTextColor(COLOR_TYPE.BLACK)
    label:enableOutline(cc.c4b(255, 255, 255, 255), 1)
    -- 表情
    local emoticonSp = cc.Sprite:create("uires/ui/guide/emoticon_".. guideObj.emoticon .. ".png")
    -- 提示文字
    local label2 = cc.Label:createWithTTF(GlobalApi:getLocalStr("CLICK_ANY_POS_CONTINUE"), "font/gamefont.ttf", 14)
    label2:setTextColor(cc.c4b(68,68,68, 255))
    node:addChild(npc)
    dialog:addChild(label)
    dialog:addChild(emoticonSp)
    dialog:addChild(label2)
    node:addChild(dialog)
    
    local winsize = cc.Director:getInstance():getWinSize()
    local act
    local startPos
    local scaleX = 1
    self.audioId = -1
    local function showTalk()
        self.clickFlag = false
        dialog:setVisible(true)
        dialog:setScale(0)
        dialog:runAction(cc.ScaleTo:create(0.1, scaleX, 1))
        if conf.soundRes ~= "0" then
            self.audioId = AudioMgr.playEffect("media/guide/" .. conf.soundRes, false)
        end
        -- node:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function ()
        --     dialog:setVisible(false)
        --     label:setVisible(false)
        --     npc:runAction(cc.Sequence:create(cc.RotateTo:create(0.1, 0), cc.MoveTo:create(0.2, cc.p(startPos)), cc.CallFunc:create(function ()
        --         node:removeFromParent()
        --         self:finish()
        --     end)))
        -- end)))
    end
    if guideObj.direction == "down" then
        startPos = cc.p(winsize.width/2 - 200, -200)
        npc:setPosition(startPos)
        act = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 150)), cc.CallFunc:create(showTalk))
        scaleX = -1
        dialog:setScaleX(-1)
        label:setScaleX(-1)
        emoticonSp:setScaleX(-1)
        label2:setScaleX(-1)
        dialog:setAnchorPoint(cc.p(1, 0))
        dialog:setPosition(cc.p(winsize.width/2 - 70, 100))
        label:setPosition(cc.p(dialogSize.width - 60, dialogSize.height - 20))
        emoticonSp:setPosition(cc.p(dialogSize.width/2 - 15, 70))
        label2:setPosition(cc.p(dialogSize.width/2 - 15, 20))
        -- dialog:setPosition(cc.p(winsize.width/2 + 60, 220))
        -- label:setPosition(cc.p(winsize.width/2 - 50, 290))
        -- emoticonSp:setPosition(cc.p(winsize.width/2 + 75, 180))
    elseif guideObj.direction == "left" then
        startPos = cc.p(-100, winsize.height/2 - 100)
        npc:setPosition(startPos)
        act = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.RotateTo:create(0.1, 30), cc.CallFunc:create(showTalk))
        scaleX = -1
        dialog:setScaleX(-1)
        label:setScaleX(-1)
        emoticonSp:setScaleX(-1)
        label2:setScaleX(-1)
        dialog:setAnchorPoint(cc.p(1, 0))
        dialog:setPosition(cc.p(180, winsize.height/2))
        label:setPosition(cc.p(dialogSize.width - 60, dialogSize.height - 20))
        emoticonSp:setPosition(cc.p(dialogSize.width/2 - 15, 70))
        label2:setPosition(cc.p(dialogSize.width/2 - 15, 20))
        --dialog:setPosition(cc.p(350, winsize.height/2 + 100))
        --label:setPosition(cc.p(240, winsize.height/2 + 170))
        --emoticonSp:setPosition(cc.p(370, winsize.height/2 + 60))
    elseif guideObj.direction == "right" then
        startPos = cc.p(winsize.width + 100, winsize.height/2 - 100)
        npc:setPosition(startPos)
        act = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.RotateTo:create(0.1, -45), cc.RotateTo:create(0.1, -30), cc.CallFunc:create(showTalk))
        scaleX = 1
        dialog:setAnchorPoint(cc.p(1, 0))
        dialog:setPosition(cc.p(winsize.width - 190, winsize.height/2))
        label:setPosition(cc.p(30, dialogSize.height - 20))
        emoticonSp:setPosition(cc.p(dialogSize.width/2 - 18, 70))
        label2:setPosition(cc.p(dialogSize.width/2 - 18, 20))
        -- dialog:setPosition(cc.p(winsize.width - 360, winsize.height/2 + 100))
        -- label:setPosition(cc.p(winsize.width - 500, winsize.height/2 + 170))
        -- emoticonSp:setPosition(cc.p(winsize.width - 375, winsize.height/2 + 60))
    end
    self.guideNode:addChild(node)
    npc:runAction(act)
    self.dialog = dialog
    self.npc = npc
    self.mainNode = node
    self.clickFlag = true
    self.startPos = startPos
end

function GuideTalk:onClickScreen()
    if not self.clickFlag then
        self.clickFlag = true
        self.dialog:setVisible(false)
        self.npc:runAction(cc.Sequence:create(cc.RotateTo:create(0.1, 0), cc.MoveTo:create(0.2, cc.p(self.startPos)), cc.CallFunc:create(function ()
            if self.audioId ~= -1 then
                AudioMgr.stopEffect(self.audioId)
            end
            self.mainNode:removeFromParent()
            self:finish()
        end)))
    end
end

return GuideTalk