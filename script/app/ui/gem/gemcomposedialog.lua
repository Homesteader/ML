local GemComposeDialogUI = class("GemComposeDialogUI", BaseUI)
local ClassGemObj = require('script/app/obj/gemobj')

function GemComposeDialogUI:ctor(gemType, gemLevel)
    self.uiIndex = GAME_UI.UI_GEM_COMPOSE_DIALOG_UI
    self.gemType = gemType
    self.gemLevel = gemLevel
    self.gid = self.gemType * 100 + self.gemLevel

    self.maxCount = 2
    self.curCount = 1
end

function GemComposeDialogUI:init()
    self.bgimg = self.root:getChildByName('bg_img')
    self.dialogBg = self.bgimg:getChildByName('dialog_bg_img')

    local close_btn = self.dialogBg:getChildByName('close_btn')
    close_btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    -- 宝石图标
    local gemBg = self.dialogBg:getChildByName('gem_bg')
    self.gemIconBg = gemBg:getChildByName('gem_icon_bg')
    self.gemIcon = self.gemIconBg:getChildByName('icon_img')
    self.gemNameTx = gemBg:getChildByName('gem_name_tx')
    self.gemAttrTx = gemBg:getChildByName('gem_attr_tx')

    -- 合成数量调整
    local numpl = self.dialogBg:getChildByName('num_pl')
    self.maxCountTx = numpl:getChildByName('max_count_tx')
    self.numTx = numpl:getChildByName('num_tx')
    self.incBtn = numpl:getChildByName('inc_btn')
    self.incBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.curCount < self.maxCount then
                self.curCount = self.curCount + 1
                self:refreshNumPl()
            end
        end
    end)

    self.decBtn = numpl:getChildByName('dec_btn')
    self.decBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.curCount > 1 then
                self.curCount = self.curCount - 1
                self:refreshNumPl()
            end
        end
    end)

    self.maxBtn = numpl:getChildByName('max_btn')
    self.maxBtnTx = self.maxBtn:getChildByName('func_tx')
    self.maxBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.curCount = self.maxCount
            self:refreshNumPl()
        end
    end)

    self.editbox = cc.EditBox:create(cc.size(100, 30), 'uires/ui_new/role/number_bg.png')
    self.editbox:setPosition(self.numTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    numpl:addChild(self.editbox)
    self.numTx:setLocalZOrder(2)

    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
    	local edit = pSender
		if event == "began" then
			self.editbox:setText(self.curCount)
			self.numTx:setString('')
		elseif event == "ended" then
			local num = tonumber(self.editbox:getText()) or 1
			if num > self.maxCount then
				self.curCount = self.maxCount
			elseif num < 1 then
				self.curCount = 1
			else
				self.curCount = num
			end
			self.editbox:setText('')
			self:refreshNumPl()
		end
    end)

    -- 消耗列表
    local consumePl = self.dialogBg:getChildByName('consume_pl')
    local listBg = consumePl:getChildByName('gem_list_bg')
    self.gemListSv = listBg:getChildByName('gem_list_sv')

    -- 合成按钮
    self.composeBtn = self.dialogBg:getChildByName('compose_btn')
    self.composeBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:composeRequest(self.gemType, self.gemLevel, self.curCount)
        end
    end)

    self:refreshUI()
end

function GemComposeDialogUI:refreshUI()
    local gemConf = GameData:getConfData('gem')[self.gid]
    if gemConf == nil then
        return
    end

    self.gemIconBg:loadTexture(COLOR_FRAME[gemConf.color])
    self.gemIcon:loadTexture("uires/icon/gem/" .. gemConf.icon)
    self.gemNameTx:setString(gemConf.name)
    self.gemNameTx:setColor(COLOR_QUALITY[gemConf.color])

    local attributeConf = GameData:getConfData('attribute')[gemConf.type]
    self.gemAttrTx:setString(attributeConf.name .. '+' .. gemConf.value)

    self:refreshConsumeGemList()
    self:refreshNumPl()
end

-- 刷新消耗列表
function GemComposeDialogUI:refreshConsumeGemList()
    local function createGemItem(obj, consumeNum)
        local gemBg = ccui.ImageView:create()
        gemBg:loadTexture(obj:getBgImg())
        gemBg:setTouchEnabled(true)

        local gemIcon = ccui.ImageView:create()
        gemIcon:loadTexture(obj:getIcon())
        gemIcon:setPosition(cc.p(47, 47))
        gemBg:addChild(gemIcon)

        local LevelLabel = cc.Label:createWithTTF("", "font/gamefont1.ttf", 20)
        LevelLabel:setAnchorPoint(cc.p(0, 0.5))
        LevelLabel:enableOutline(obj:getNameOutlineColor(), 1)
        LevelLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        LevelLabel:setTextColor(obj:getNameColor())
        LevelLabel:setString("Lv." .. obj:getLevel())
        LevelLabel:setPosition(cc.p(7, 71))
        gemBg:addChild(LevelLabel)

        local numLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
        numLabel:setAnchorPoint(cc.p(1, 0.5))
        numLabel:enableOutline(cc.c4b(84,65,39, 255), 1)
        numLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        numLabel:setTextColor(cc.c4b(255, 255, 255, 255))
        numLabel:setString(tostring(consumeNum))
        numLabel:setPosition(cc.p(80, 16))
        gemBg:addChild(numLabel)

        return gemBg
    end

    self.gemListSv:removeAllChildren()
    self.gemListSv:setScrollBarEnabled(false)

    local svSize = self.gemListSv:getContentSize()
    local contentWidget = ccui.Widget:create()
    self.gemListSv:addChild(contentWidget)
    contentWidget:setAnchorPoint(cc.p(0, 0.5))

    local tmpGid = self.gemType * 100 + self.gemLevel - 1
    local gemObj = BagData:getGemById(tmpGid)
    if gemObj == nil then
        gemObj = ClassGemObj.new(tmpGid, 0)
    end

    -- 刷新消耗列表
    local canUpgrade, consumeList = gemObj:getUpgradeConsumeList(true, self.curCount)
    if canUpgrade then
        local gemIndex = 0
        local innerWidth = 0
        for k, v in pairs(consumeList) do
            local gemItem = createGemItem(v.gemObj, v.num)

            local gemItemSize = gemItem:getContentSize()
            gemItem:setPosition(cc.p(gemIndex * (gemItemSize.width + 5) + 45, 0))
            contentWidget:addChild(gemItem)

            gemIndex = gemIndex + 1
            innerWidth = innerWidth + gemItemSize.width + 5
        end

        self.gemListSv:setInnerContainerSize(cc.size(innerWidth, svSize.height))
        contentWidget:setPosition(cc.p(0, svSize.height/2))
    end
end

function GemComposeDialogUI:refreshNumPl()
    local num = BagData:getGemComposeData(self.gemType, self.gemLevel)
    self.maxCount = num

    self.numTx:setString(self.curCount)
    self.maxCountTx:setString(self.maxCount)

    if self.curCount <= 1 then
        self.decBtn:setTouchEnabled(false)
    else
        self.decBtn:setTouchEnabled(true)
    end

    if self.curCount >= self.maxCount then
        self.incBtn:setTouchEnabled(false)
    else
        self.incBtn:setTouchEnabled(true)
    end

    self:refreshConsumeGemList()
end

-- 请求合成
function GemComposeDialogUI:composeRequest(gemType, gemLevel, num)
    local args = {
        gem_type = gemType,     -- 宝石类型
        gem_level = gemLevel,   -- 宝石等级
        gem_num = num           -- 合成数量
    }

    MessageMgr:sendPost("gemCompose", "bag", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            local costs = jsonObj.data.costs
            GlobalApi:parseAwardData(costs)

            local awards = jsonObj.data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards, nil, nil, true)
            end

            self:hideUI()
        else
            -- 合成失败提示
            self:hideUI()
        end
    end)
end

return GemComposeDialogUI