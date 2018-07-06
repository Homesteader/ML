-- 宝石合成
local ClassGemComposeDialogUI = require("script/app/ui/gem/gemcomposedialog")
local GemComposeUI = class("GemComposeUI", BaseUI)

function GemComposeUI:ctor(gemType)
    self.uiIndex = GAME_UI.UI_GEM_COMPOSE_UI
    self.showGemType = gemType
    self.gemCellTab = {}
end

function GemComposeUI:init()
    self.bgImg = self.root:getChildByName("bg_img")
    self.bgImg1 = self.bgImg:getChildByName("bg1_img")

    self.closeBtn = self.bgImg1:getChildByName("close_btn")
    self.closeBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    self.tabArr = {}
    for i = 1, 3 do
        self.tabArr[i] = {}
        self.tabArr[i].btn = self.bgImg1:getChildByName("tab_" .. i)
        self.tabArr[i].btnTx = self.tabArr[i].btn:getChildByName("func_tx")
        self.tabArr[i].btnTx:setString(GlobalApi:getLocalStr('STR_GEM_NAME_' .. i))

        self.tabArr[i].btn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:switchTab(i)
            end
        end)
    end

    local listBg = self.bgImg1:getChildByName("list_bg")
    self.gemListSv = listBg:getChildByName("gem_list_sv")

    self:refreshUI()
end

-- 切换标签页
function GemComposeUI:switchTab(index)
    self.showGemType = index

    local num, consumeList = BagData:getGemComposeData(self.showGemType, 12)
    self:refreshGemList(self.showGemType)  

    for i = 1, 3 do
        if i == index then
            self.tabArr[i].btn:loadTextureNormal('uires/ui_new/common/tab_up_select.png')
            self.tabArr[i].btn:setTouchEnabled(false)
            self.tabArr[i].btnTx:enableShadow(COLOR_BTN_SHADOW.TAB_SELECTED, cc.size(-2, 2), 0)
        else
            self.tabArr[i].btn:loadTextureNormal('uires/ui_new/common/tab_up_normal.png')
            self.tabArr[i].btn:loadTexturePressed('uires/ui_new/common/tab_up_normal_pressed.png')
            self.tabArr[i].btn:setTouchEnabled(true)
            self.tabArr[i].btnTx:enableShadow(COLOR_BTN_SHADOW.TAB_NORMAL, cc.size(-2, 2), 0)
        end
    end
end

-- 刷新界面
function GemComposeUI:refreshUI()
    self:switchTab(self.showGemType)
end

function GemComposeUI:onShow()
	self:refreshUI()
end

-- 刷新宝石合成列表
function GemComposeUI:refreshGemList(gemType)
    self.gemListSv:setScrollBarEnabled(false)
	self.gemListSv:setInertiaScrollEnabled(true)
	self.gemListSv:removeAllChildren()

    local contentWidget = ccui.Widget:create()
    self.gemListSv:addChild(contentWidget)
    contentWidget:removeAllChildren()

    -- 筛选出要显示的宝石
    self.showedGemArr = {}
    local gemConf = GameData:getConfData('gem')
    for k, v in pairs(gemConf) do
        if v.type == gemType then
           table.insert(self.showedGemArr, v);
        end
    end

    local function sortGem(a, b)
        return a.level < b.level
    end

    table.sort(self.showedGemArr, sortGem)

    local num = #self.showedGemArr
    local ui_index = 1
    for k, v in pairs(self.showedGemArr) do
        local node = cc.CSLoader:createNode("csb/gemupgradecell.csb")
        local bgimg = node:getChildByName("bg_img")
	    bgimg:removeFromParent(false)

        self.gemCellTab[ui_index]= ccui.Widget:create()
	    self.gemCellTab[ui_index]:setName('gemcompose_gem_cell'..ui_index)
	    self.gemCellTab[ui_index]:addChild(bgimg)

        self:updateGemCell(ui_index)

        local contentsize = bgimg:getContentSize()
	    if math.ceil(num*(contentsize.height+5)) > self.gemListSv:getContentSize().height then
	        self.gemListSv:setInnerContainerSize(cc.size(contentsize.width,num*(contentsize.height+5)))
	    end

	    local posx = 0
	    local posy = -ui_index * (contentsize.height + 5)
	    self.gemCellTab[ui_index]:setPosition(cc.p(posx,posy))

	    contentWidget:addChild(self.gemCellTab[ui_index])
	    contentWidget:setPosition(cc.p(0, self.gemListSv:getInnerContainerSize().height ))

        ui_index = ui_index + 1
    end
end

function GemComposeUI:updateGemCell(index)
    local bgimg = self.gemCellTab[index]:getChildByName("bg_img")

    local gemBg = bgimg:getChildByName("gem_bg")
    local gemIcon = gemBg:getChildByName("icon_img")
    local hasNumTx = gemBg:getChildByName("num_tx")
    local gemName = bgimg:getChildByName("name_tx")
    local gemAttr = bgimg:getChildByName("attr_tx")
    local totalNumTx = bgimg:getChildByName("total_num_tx")
    local composeBtn = bgimg:getChildByName("upgrade_btn")
    local composeBtnTx = composeBtn:getChildByName("func_tx")
    
    local hasNum = BagData:getGemNumByTypeAndLevel(self.showGemType, index)
    hasNumTx:setString('x' .. hasNum)

    local attributeConf = GameData:getConfData('attribute')
    local gemConf = self.showedGemArr[index]
    if gemConf then
        gemBg:loadTexture(COLOR_FRAME[gemConf.quality])
        gemIcon:loadTexture("uires/icon/gem/" .. gemConf.icon)
        gemName:setString(gemConf.name)
        gemName:setColor(COLOR_QUALITY[gemConf.quality])

        local maxCount = BagData:getGemComposeCount(gemConf.level)
        totalNumTx:setString(maxCount)

        local attrName = attributeConf[gemConf.type].name
        gemAttr:setString(attrName .. "+" .. gemConf.value)

        if gemConf.level == 1 then
            composeBtn:setVisible(false)
        else
            composeBtn:setVisible(true)
            if maxCount == 0 then
                composeBtn:loadTextureNormal('uires/ui_new/common/common_btn_disable.png')
                composeBtn:setTouchEnabled(false)
                composeBtnTx:enableShadow(COLOR_BTN_SHADOW.DISABLE_BTN, cc.size(-2, 2), 0)
            else
                composeBtn:loadTextureNormal('uires/ui_new/common/common_btn_5.png')
                composeBtn:setTouchEnabled(true)
                composeBtnTx:enableShadow(COLOR_BTN_SHADOW.YELLOW_BTN, cc.size(-2, 2), 0)
            end
        end
        composeBtn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local dialogUI = ClassGemComposeDialogUI.new(gemConf.type, gemConf.level)
                dialogUI:showUI()
            end
        end)
    end
end

return GemComposeUI