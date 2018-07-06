local RoleExchangeUI = class("RoleExchangeUI", BaseUI)

function RoleExchangeUI:ctor(callback)
	self.uiIndex = GAME_UI.UI_ROLEEXCHANGE
	self.callback = callback
end

function RoleExchangeUI:init()
	local bgImg = self.root:getChildByName("exchange_bg_img")
	local exchangeImg = bgImg:getChildByName("exchange_img")
	local cancelBtn = exchangeImg:getChildByName("cancel_btn")
	local infoTx = cancelBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_CANCEL'))
	local okBtn = exchangeImg:getChildByName("ok_btn")
	infoTx = okBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_OK'))
    self:adaptUI(bgImg, exchangeImg)
    local titletx = exchangeImg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr_new('ROLE_EXCHANGE_TITLE'))
	cancelBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleExchange()
	    end
	end)
	okBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleExchange()
			if self.callback then
				self.callback()
			end
	    end
	end)
	local closebtn = exchangeImg:getChildByName('close_btn')
	closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleExchange()
	    end
	end)	

	local p = GlobalApi:getLocalStr_new('ROLE_EXCHANGE_PERCENT')
    for i=1,6 do
    	local str = GlobalApi:getLocalStr_new('ROLE_EXCHANGE_DESC'..i)
		local infoTx = exchangeImg:getChildByName("info_tx"..i)
	    infoTx:setString(p .. " " ..str)
    end
end

return RoleExchangeUI