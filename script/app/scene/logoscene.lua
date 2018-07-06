local ClassMainScene = require('script/app/scene/mainscene')

local LogoScene = class('LogoScene')

-- 构造函数
function LogoScene:ctor()
	self.scene = cc.Scene:create()
	local winSize = cc.Director:getInstance():getWinSize()
	self.layer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
	self.scene:addChild(self.layer)

	local widget = ccui.Widget:create()
	widget:setOpacity(0)
	widget:setCascadeOpacityEnabled(true)
	widget:setPosition(cc.p(winSize.width * 0.5, winSize.height * 0.5))
	self.layer:addChild(widget)
	local text1 = ccui.Text:create()
	text1:setFontName("font/gamefont.ttf")
	text1:setFontSize(40)
	text1:setColor(COLOR_TYPE.BLACK)
	text1:setString(GlobalApi:getLocalStr("HEALTH_GAME_NOTICE_1"))
	text1:setPosition(cc.p(0, 160))
	widget:addChild(text1)
	for i = 2, 5 do
		local text = ccui.Text:create()
		text:setFontName("font/gamefont.ttf")
		text:setFontSize(40)
		text:setColor(COLOR_TYPE.BLACK)
		text:setString(GlobalApi:getLocalStr("HEALTH_GAME_NOTICE_" .. i))
		text:setPosition(cc.p(0, 180 - i*60))
		widget:addChild(text)
	end
	widget:runAction(cc.Sequence:create( cc.DelayTime:create(0.1),
										cc.FadeIn:create(0.5),
										cc.DelayTime:create(1.0),
										cc.FadeOut:create(0.5),
										cc.DelayTime:create(0.1),
										cc.CallFunc:create(function ()
											local logo = cc.Sprite:create('uires/logo/logo.png')
											logo:setPosition(cc.p(winSize.width * 0.5, winSize.height * 0.5))
											logo:setOpacity(0)
											self.layer:addChild(logo)
											local delayAct = cc.DelayTime:create(0.3)
											local fadeinAct = cc.FadeIn:create(0.5)
											local delayAct2 = cc.DelayTime:create(1.0)
											local fadeoutAct = cc.FadeOut:create(0.5)
											local delayAct3 = cc.DelayTime:create(0.1)
											local sequence = cc.Sequence:create(delayAct, fadeinAct, delayAct2, fadeoutAct, delayAct3, cc.CallFunc:create(self.exit))
											logo:runAction(sequence)
										end)))
end

function LogoScene:enter()
	--cc.Director:getInstance():runWithScene(self.scene)
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.scene)
    else
        cc.Director:getInstance():runWithScene(self.scene)
    end
end

function LogoScene:exit()
	local mainScene = ClassMainScene.new()
	mainScene:enter()
end

return LogoScene