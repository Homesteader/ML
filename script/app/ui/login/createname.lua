-- require "script/app/data/globaldata"
local CreateNameUI = class("CreateNameUI", BaseUI)
	
function CreateNameUI:ctor()
	self.uiIndex = GAME_UI.UI_CREATENAME
end

function CreateNameUI:init()
    local bgImg = self.root:getChildByName("create_name_img")
    local nameBgImg = bgImg:getChildByName("name_bg_img")
    self:adaptUI(bgImg, nameBgImg)
	local enterGameBtn = nameBgImg:getChildByName("enter_game_btn")
  	local editbox = cc.EditBox:create(cc.size(244, 48), 'uires/ui/common/common_bg.png')
    editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    editbox:setPosition(433, 350)
    editbox:setFontColor(cc.c3b(255, 255, 255))
    editbox:setMaxLength(10)
    nameBgImg:addChild(editbox)

    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 38)
    nameTx:setPosition(cc.p(310, 350))
    nameTx:setColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0,0.5))
    nameTx:setName('name_tx')
    nameBgImg:addChild(nameTx)
    nameTx:setString(cc.UserDefault:getInstance():getStringForKey('uid',''))
    if nameTx:getString() == '' then
        editbox:setPlaceHolder(GlobalApi:getLocalStr('STR_INPUT_NAME'))
    end

	enterGameBtn:addClickEventListener(function (sender)
        local name = nameTx:getString()
        if name and name ~= '' then
            GlobalData:setLoginInfo("uid=" .. name)
            cc.UserDefault:getInstance():setStringForKey('uid', name)
            MessageMgr:getServerList(function()
                LoginMgr:afterGetServerList()
            end)
            self:hideUI()
        else
            promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NEED_NAME'), MESSAGE_BOX_TYPE.MB_OK)
    	end
	end)

    editbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            editbox:setText(nameTx:getString())
            editbox:setPlaceHolder('')
            nameTx:setString('')
        elseif event == "ended" then
            local str = editbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,10*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            nameTx:setString(str)
            editbox:setText('')
            if str == '' then
                editbox:setPlaceHolder(GlobalApi:getLocalStr('STR_INPUT_NAME'))
            else
                editbox:setPlaceHolder('')
            end
        end
    end)
end

return CreateNameUI