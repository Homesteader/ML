local GemDetailUI = class("GemDetailUI", BaseUI)
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemUpgradeUI = require("script/app/ui/gem/gemupgradeui")
local ClassItemCell = require('script/app/global/itemcell')

function GemDetailUI:ctor(roleObj, partObj, gem_pos, gemObj)
    self.uiIndex = GAME_UI.UI_GEM_DETAIL_UI
    self.obj = roleObj
    self.rolePos = self.obj:getPosId()
    self.partObj = partObj
    self.gemPos = gem_pos
    self.gemObj = gemObj
end

function GemDetailUI:init()

    local bg_img = self.root:getChildByName("bg_img")
    local outBg = bg_img:getChildByName('bg')
    self:adaptUI(bgimg, outBg)

    local bgimg = outBg:getChildByName("bg_img1")

    local titleTx = bgimg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr_new("ROLE_GEM_CONFIRM_TITLE"))
    
    -- 关闭按钮
    local clostBtn = bgimg:getChildByName("close_btn");
    clostBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local gemNode = bgimg:getChildByName("gem_node"); 
    self.Item = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    self.Item.awardBgImg:setScale(0.8)
    gemNode:addChild(self.Item.awardBgImg) 

    self.gemNameTx = bgimg:getChildByName("gem_name_tx");
    self.gemAttrTx = bgimg:getChildByName("attr_tx");
    
    local takeoffBtn = bgimg:getChildByName("takeoff_btn");
    local btnText = takeoffBtn:getChildByName("func_tx")
    btnText:setString(GlobalApi:getLocalStr_new("ROLE_GEM_CONFIRM_INFO2"))
    takeoffBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:takeoffGem()
        end
    end)

    self.upgradeBtn = bgimg:getChildByName("upgrade_btn");
    self.upgradeBtnText = self.upgradeBtn:getChildByName("func_tx")
    self.upgradeBtnText:setString(GlobalApi:getLocalStr_new("ROLE_GEM_CONFIRM_INFO3"))
    self.upgradeBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:openGemUpgradeUI()
        end
    end)

    local changeBtn = bgimg:getChildByName("change_btn");
    local btnText = changeBtn:getChildByName("func_tx")
    btnText:setString(GlobalApi:getLocalStr_new("ROLE_GEM_CONFIRM_INFO4"))
    changeBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 更换
            self:openGemSelectUI()
        end
    end)

    self:refreshUI()
end

function GemDetailUI:takeoffGem()

    local partPos = self.partObj:getPartId()
    local args = {
		pos = self.rolePos,
		part_pos = partPos,
        gem_pos = self.gemPos
	}

    MessageMgr:sendPost("takeoff_gem", "parttrain", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            self.partObj:removeGem(self.gemPos)
            self.obj:setFightForceDirty(true)
            RoleMgr:updateRoleMainUI()
 
            local costs = jsonObj.data.costs
            GlobalApi:parseAwardData(costs)
            self:hideUI()
        end
    end)
end

-- 打开宝石选择界面
function GemDetailUI:openGemSelectUI()
    local gemSelectUI = ClassGemSelectUI.new(self.gemPos,self.obj:getPosId(),self.partObj, function ()
		self.obj:setFightForceDirty(true)
        RoleMgr:updateRoleMainUI()
    end)
    gemSelectUI:showUI()
    self:hideUI()
end

-- 打开宝石升级界面
function GemDetailUI:openGemUpgradeUI()
    local gemUpgradeUI = ClassGemUpgradeUI.new(self.gemObj, self.partObj, self.gemPos, self.obj, function ()
        self.obj:setFightForceDirty(true)
        RoleMgr:updateRoleMainUI()
    end)
    gemUpgradeUI:showUI()
    self:hideUI()
end

function GemDetailUI:refreshUI()

    self.tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    ClassItemCell:updateItem(self.Item,self.gemObj,1)
    self.Item.lvTx:setVisible(false)

    local quality = self.gemObj:getQuality()
    self.gemNameTx:setString(self.gemObj:getName())
    self.gemNameTx:setTextColor(self.gemObj:getNameColor())
    self.gemNameTx:enableOutline(self.gemObj:getNameOutlineColor(), 2)
    self.gemAttrTx:setString(self.gemObj:getAttrName() .. "+" .. self.gemObj:getValue())

    local canUpgrade = self.gemObj:getUpgradeConsumeList(false)
    if canUpgrade then
        self.upgradeBtn:setEnabled(true)
        self.upgradeBtnText:setTextColor(COLOR_TYPE.GREEN_BTN)
        self.upgradeBtnText:enableOutline(COLOROUTLINE_TYPE.GREEN_BTN, 2)
        self.upgradeBtnText:enableShadow(COLOR_BTN_SHADOW.GREEN_BTN, cc.size(0, -1), 0)
    else
        self.upgradeBtn:setEnabled(false)
        self.upgradeBtnText:setTextColor(COLOR_TYPE.GRAY1)
        self.upgradeBtnText:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
        self.upgradeBtnText:enableShadow(COLOR_BTN_SHADOW.DISABLE_BTN, cc.size(0, -1), 0)
    end
end

return GemDetailUI