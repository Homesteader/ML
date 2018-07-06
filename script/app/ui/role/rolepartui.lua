--===============================================================
-- 部位界面
--===============================================================
local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassItemCell = require('script/app/global/itemcell')
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemDetailUI = require("script/app/ui/gem/gemdetail")

local RolePartUI = class("RolePartUI", ClassRoleBaseUI)

local AWAKE_TYPE = {
    NORMAL = 1, -- 普通觉醒
    MAX = 2,    -- 极限觉醒
}

function RolePartUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/rolepartpanel.csb")
	self.panel:setName("role_part_panel")
	
	local bgimg = self.panel:getChildByName('bg_img')
	local bg1img = bgimg:getChildByName('bg1_img')
	local awakeNode = bg1img:getChildByName('awake_node')
	local embedNode = bg1img:getChildByName('embed_node')

	local awakeTitleBg = awakeNode:getChildByName('title_bg')
	self.awakeTitleTx = awakeTitleBg:getChildByName('title_tx')

	local embedTitleBg = embedNode:getChildByName('title_bg')
	self.embedTitleTx = embedTitleBg:getChildByName('title_tx')

	local starList = awakeNode:getChildByName("star_list")
    self.awakeStarImgArr = {}
    for i = 1, 10 do
        local starImg = starList:getChildByName("star_" .. i)
        self.awakeStarImgArr[i] = starImg  
    end

    self.maxAwakePl = awakeNode:getChildByName('max_awake_pl')
    self.maxAwakeBtn = self.maxAwakePl:getChildByName('max_awake_btn')
    self.maxAwakeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			-- 极限觉醒
			self:requestAwakeCurPart(AWAKE_TYPE.MAX)
		end
	end)

    -- 极限觉醒消耗
	self.maxAwakeItemConsumeBg = self.maxAwakePl:getChildByName('item_comsume')
	self.maxAwakeItemConsumeIcon = self.maxAwakeItemConsumeBg:getChildByName('icon_img')
	self.maxAwakeItemConsumeNum = self.maxAwakeItemConsumeBg:getChildByName('num_tx')
	self.maxAwakeAttrInit = self.maxAwakePl:getChildByName('max_awake_attr')

	-- 普通觉醒消耗
	self.awakeConsumeBg = awakeNode:getChildByName('awake_consume')
	self.awakeItemConsumeIcon = self.awakeConsumeBg:getChildByName('icon_img')
	self.awakeItemConsumeNum = self.awakeConsumeBg:getChildByName('item_num_tx')
	local awakeBtn = self.awakeConsumeBg:getChildByName('awake_btn')
	local awakeBtnTx = awakeBtn:getChildByName('func_tx')
	awakeBtn:addTouchEventListener(function ( sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			-- 觉醒
			self:requestAwakeCurPart(AWAKE_TYPE.NORMAL)
		end
	end)

	self.awakeAttrImg = awakeNode:getChildByName('awake_attr_img')

	-- 镶嵌
	self.gemList = embedNode:getChildByName('gem_list')
	self.embedSlotArr = {}
    for i = 1, 4 do
        local embedObj = {}
        embedObj.bg = self.gemList:getChildByName("slot_img_" .. i)
        embedObj.icon = embedObj.bg:getChildByName("icon_img")
        embedObj.levelTx = embedObj.bg:getChildByName("level_tx")
        embedObj.levelUpImg = embedObj.bg:getChildByName("levelup_img")
        embedObj.lock = embedObj.bg:getChildByName("lock_img")
        embedObj.openImg = embedObj.bg:getChildByName("open_img")
        embedObj.openTx = embedObj.openImg:getChildByName("num_tx")
        embedObj.addImg = embedObj.bg:getChildByName("add_img")
        embedObj.bg:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
                local gems = self.partObj:getGems()
                if gems[i] then
                	local gemDetailUI = ClassGemDetailUI.new(self.obj,self.partObj, i, gems[i])
                	gemDetailUI:showUI()
                else
                    self.obj:getEmbedAttr()
                	local gemSelectUI = ClassGemSelectUI.new(i,self.obj:getPosId(),self.partObj, function ()
                        self.obj:getEmbedAttr()
						self.obj:setFightForceDirty(true)
				    	RoleMgr:refreshPartPanel()
                    	RoleMgr:popupTips(self.obj)
                    	self:update(self.obj, self.part_pos)
                	end)
                	gemSelectUI:showUI()
                end
	           	
			end
        end)
        
        self.embedSlotArr[i] = embedObj
    end

    self.embedAttrImg = embedNode:getChildByName('gem_att_bg_img')
end

function RolePartUI:onMoveOut()
end

function RolePartUI:update(obj, part_pos)

	self.obj = obj
	if part_pos == 0 then
		part_pos = 1
	end
    self.partObj = self.obj:getPartByIndex(part_pos)

	self.part_pos = part_pos
	self:refreshPartAwakeInfo(part_pos)
	self:refreshPartEmbedInfo(part_pos)

	-- 刷新标题
	self.awakeTitleTx:setString(GlobalApi:getLocalStr_new('EQUIP_TYPE_' .. part_pos) .. GlobalApi:getLocalStr_new('PART_AWAKE_TITLE_POSTFIX'))
	self.embedTitleTx:setString(GlobalApi:getLocalStr_new('EQUIP_TYPE_' .. part_pos) .. GlobalApi:getLocalStr_new('PART_EMBED_TITLE_POSTFIX'))
end

function RolePartUI:setAwakeStar(awake_level, max_awake)
    for i = 1, 10 do
        if i <= awake_level then
            if max_awake then
                self.awakeStarImgArr[i]:loadTexture("uires/ui_new/common/star_awake.png")
            else
                self.awakeStarImgArr[i]:loadTexture("uires/ui_new/common/star_awake.png")
            end
        else
            self.awakeStarImgArr[i]:loadTexture("uires/ui_new/common/star_awake_bg.png")
        end
    end
end

-- 根据部位索引刷新界面
function RolePartUI:refreshPartAwakeInfo(part_pos)
    local partBaseConf = GameData:getConfData("partbase")
    local partAwakeConf = GameData:getConfData("partawake")
    local attributeConf = GameData:getConfData("attribute")
    local titleAwakeConf = GameData:getConfData("parttitleactivate")

    local awakeLevel = self.partObj:getAwakeLv()
    local maxAwwake = self.partObj:getMaxAwakeLv()
    self:setAwakeStar(awakeLevel, maxAwwake)

    local reachMaxAwakeLevel = false -- 是否到达最高级
    local nextLevel = awakeLevel + 1
    if partAwakeConf[part_pos][nextLevel] == nil then
        nextLevel = awakeLevel
        reachMaxAwakeLevel = true
    end 

    release_print('part_pos = ' .. part_pos .. ', nextLevel = ' .. nextLevel)
    if reachMaxAwakeLevel then
    	self.awakeConsumeBg:setVisible(false)
    else
    	local consumeItems = partAwakeConf[part_pos][nextLevel].costNormalAwake
    	local itemID = tonumber(consumeItems[1][2])
    	local itemNum = math.abs(consumeItems[1][3])
    	local itemConf = GameData:getConfData("item")[itemID]

    	local existCnt = 0
    	local existItem = BagData:getMaterialById(itemID)
    	if existItem then
        	existCnt = existItem:getNum()
    	end

    	self.awakeConsumeBg:setVisible(true)
    	self.awakeConsumeBg:loadTexture(COLOR_ITEMFRAME[COLOR_QUALITY[itemConf.quality]]);
    	self.awakeItemConsumeIcon:loadTexture("uires/icon/material/" .. itemConf.icon)
    	self.awakeItemConsumeIcon:setScale(0.5)
    	self.awakeItemConsumeNum:setString(existCnt .. "/" .. itemNum)
    end

    if maxAwwake == false then
    	-- 还没有极限觉醒
    	self.maxAwakePl:setVisible(true)

    	if awakeLevel >= 3 then
    		-- 觉醒等级大于等于3星
    		local maxAwakeConsumeItems = partBaseConf[part_pos].costMaxAwake 
    		local itemID = tonumber(maxAwakeConsumeItems[1][2])
    		local itemNum = math.abs(maxAwakeConsumeItems[1][3])
    		local itemConf = GameData:getConfData("item")[itemID]

    		local existCnt = 0
    		local existItem = BagData:getMaterialById(itemID)
    		if existItem then
        		existCnt = existItem:getNum()
    		end

    		self.maxAwakeItemConsumeBg:setVisible(true)
    		self.maxAwakeBtn:setVisible(true)
    		self.maxAwakeItemConsumeBg:loadTexture(COLOR_ITEMFRAME[COLOR_QUALITY[itemConf.quality]]);
    		self.maxAwakeItemConsumeIcon:loadTexture("uires/icon/material/" .. itemConf.icon)
    		self.maxAwakeItemConsumeNum:setString(existCnt .. "/" .. itemNum)

    		local maxAttrTypeName = attributeConf[partBaseConf[part_pos].maxAtt].name
    		local maxAttrValue = partAwakeConf[part_pos][awakeLevel].maxVal

    		local titleLevel = self.obj:getHeroQuality()
        	local titleActivieConf = titleAwakeConf[part_pos][titleLevel]
        	while titleActivieConf ~= nil and awakeLevel < titleActivieConf.needAwakeLevel do
            	titleLevel = titleLevel - 1
            	titleActivieConf = titleAwakeConf[part_pos][titleLevel]
        	end
        	local maxExtendAttrValue = 0
            if titleActivieConf then
              maxExtendAttrValue = titleActivieConf.maxActivateVal
            end
        	local totalValue = maxAttrValue + maxExtendAttrValue
        	self.maxAwakeAttrInit:setString(maxAttrTypeName .. '+' .. totalValue .. '%')
    	else
    		self.maxAwakeItemConsumeBg:setVisible(false)
    		self.maxAwakeBtn:setVisible(false)
    		self.maxAwakeItemConsumeNum:setString(GlobalApi:getLocalStr_new('AWAKE_OPEN_CONDITION'))
    	end
    else
    	self.maxAwakePl:setVisible(false)
    end

    self:refreshAwakeAttr(part_pos, awakeLevel, nextLevel, maxAwake)
end

function RolePartUI:getEquipMainAttrName( part_pos )
	local attrName = GlobalApi:getLocalStr_new('EQUIP_TYPE_' .. part_pos) .. GlobalApi:getLocalStr_new('STR_ATTR_DES_1')
	return attrName
end

function RolePartUI:refreshAwakeAttr(part_pos, awake_level, nextLevel, maxAwake)
    local attributeConf = GameData:getConfData("attribute")
    local partBaseConf = GameData:getConfData("partbase")
    local partAwakeConf = GameData:getConfData("partawake")
    local heroQualityConf = GameData:getConfData("heroquality")
    local titleAwakeConf = GameData:getConfData("parttitleactivate")

    self.awakeAttrImg:removeAllChildren()
    local rt = xx.RichText:create()
	rt:setContentSize(cc.size(300, 144))
	rt:setAnchorPoint(cc.p(0, 1))
    rt:setPosition(cc.p(0, 142))
    rt:setRowSpacing(4)

    local showNextLevel = false
    if awake_level < nextLevel then
        showNextLevel = true
    end

    local maxAwake = self.partObj:getMaxAwakeLv()
    local showBestAttr = false
    if maxAwake then
        showBestAttr = true
    end

    local showTitleAttr = true
    if awake_level == 0 then
        showTitleAttr = false
    end

    local fontSize = 18

    local normalAttrTypeName = self:getEquipMainAttrName(part_pos)
    local normalAttrValue = 0
    if awake_level > 0 then
    	release_print('part_pos = ' .. part_pos .. ', awake_level = ' .. awake_level)
        normalAttrValue = partAwakeConf[part_pos][awake_level].addEquipMainAtt
    end

    local normalAttrValueStr = "+" .. normalAttrValue .. "%"

    if showNextLevel == false then
        normalAttrValueStr = normalAttrValueStr .. '\n'
    end

    local re1 = xx.RichTextLabel:create(normalAttrTypeName, fontSize, COLOR_TYPE.RED)
    re1:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

    local re2 = xx.RichTextLabel:create(normalAttrValueStr, fontSize, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

    local reflagBlank = xx.RichTextImage:create('uires/ui_new/common/flag_blank.png')
    rt:addElement(reflagBlank)

    rt:addElement(re1)
    rt:addElement(re2)

    if showNextLevel then
        local nextNormalAttrValue = partAwakeConf[part_pos][nextLevel].addEquipMainAtt
        local str = string.format(GlobalApi:getLocalStr_new("AWAKE_NORMAL_NEXT_ATTR_LABEL"), nextLevel, nextNormalAttrValue);
        local nextAttrStr = "[" .. str .. "%]\n"

        local re3 = xx.RichTextLabel:create(nextAttrStr, fontSize, COLOR_TYPE.GRAY)
		re3:setStroke(COLOROUTLINE_TYPE.PART_ATTR_GRAY, 2)

        rt:addElement(re3)
    end

    local maxAttrTypeName = attributeConf[partBaseConf[part_pos].maxAtt].name

    if showBestAttr then
        local maxAttrValue = 0
        if awake_level > 0 and maxAwake then
            maxAttrValue = partAwakeConf[part_pos][awake_level].maxVal
        end

        local maxAttrValueStr = "+" .. maxAttrValue .. "%"
        if showNextLevel == false then
            maxAttrValueStr = maxAttrValueStr .. '\n'
        end

        local re4 = xx.RichTextLabel:create(maxAttrTypeName, fontSize, COLOR_TYPE.RED)
		re4:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

        local re5 = xx.RichTextLabel:create(maxAttrValueStr, fontSize, COLOR_TYPE.WHITE)
		re5:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

        rt:addElement(re4)
        rt:addElement(re5)

        if showNextLevel then
            local nextMaxAttrValue = partAwakeConf[part_pos][nextLevel].maxVal

            local maxStr = string.format(GlobalApi:getLocalStr_new("AWAKE_NORMAL_NEXT_ATTR_LABEL"), nextLevel, nextMaxAttrValue);
            if maxAwake == false then
                maxStr = GlobalApi:getLocalStr_new("AWAKE_TYPE_MAX") .. GlobalApi:getLocalStr_new("STR_JIHUO") .. "+" .. nextMaxAttrValue
            end
            
            local nextMaxAttrStr = "[" .. maxStr .. "%]\n"

            local re6 = xx.RichTextLabel:create(nextMaxAttrStr, fontSize, COLOR_TYPE.GRAY)
		    re6:setStroke(COLOROUTLINE_TYPE.PART_ATTR_GRAY, 2)

            rt:addElement(re6)
        end
    end
        
    if showTitleAttr then
        local titleLevel = self.obj:getHeroQuality()
        local titleActivieConf = titleAwakeConf[part_pos][titleLevel]
        while titleActivieConf ~= nil and awake_level < titleActivieConf.needAwakeLevel do
            titleLevel = titleLevel - 1
            titleActivieConf = titleAwakeConf[part_pos][titleLevel]
        end

        local nextTitleActiveConf = titleAwakeConf[part_pos][titleLevel + 1]
        local showNext = false
        if self.obj:getHeroQuality() < titleLevel + 1 and nextTitleActiveConf ~= nil  then
            showNext = true
        end

        local normalExtendAttrValue = 0
        if titleActivieConf ~= nil then
            normalExtendAttrValue = titleActivieConf.addEquipMainAtt
        end

        local normalExtendAttrValueStr = "+" .. normalExtendAttrValue .. "%"
        if showNext == false then
            normalExtendAttrValueStr = normalExtendAttrValueStr .. "\n"
        end

        local re7 = xx.RichTextLabel:create(normalAttrTypeName, fontSize, COLOR_TYPE.RED)
		re7:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

        local re8 = xx.RichTextLabel:create(normalExtendAttrValueStr, fontSize, COLOR_TYPE.WHITE)
		re8:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

        rt:addElement(re7)
        rt:addElement(re8)

        release_print('### showNext = ' .. tostring(showNext))
        if showNext then
            local nextNormalAttrValue = nextTitleActiveConf.addEquipMainAtt
            local nextTitleLevel = tonumber(nextTitleActiveConf.titileLevel)
            local titleName = heroQualityConf[nextTitleLevel].title
            local titleStar = heroQualityConf[nextTitleLevel].star

            local nextAttrStr = "[" .. titleName .. tostring(titleStar) .. GlobalApi:getLocalStr_new("STR_STAR") .. "+" .. tostring(nextNormalAttrValue) .. "%]\n"

            local re9 = xx.RichTextLabel:create(nextAttrStr, fontSize, COLOR_TYPE.GRAY)
		    re9:setStroke(COLOROUTLINE_TYPE.PART_ATTR_GRAY, 2)

            rt:addElement(re9)
        end

        if showBestAttr then
            local maxExtendAttrValue = 0
            if titleActivieConf ~= nil and maxAwake then
                maxExtendAttrValue = titleActivieConf.maxActivateVal
            end

            local maxExtendAttrValueStr = "+" .. maxExtendAttrValue .. "%"
            if showNext == false then
                maxExtendAttrValueStr = maxExtendAttrValueStr .. "\n"
            end

            local re10 = xx.RichTextLabel:create(maxAttrTypeName, fontSize, COLOR_TYPE.RED)
		    re10:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

            local re11 = xx.RichTextLabel:create(maxExtendAttrValueStr, fontSize, COLOR_TYPE.WHITE)
		    re11:setStroke(COLOROUTLINE_TYPE.PART_ATTR, 2)

            rt:addElement(re10)
            rt:addElement(re11)

            if showNext then
                local nextMaxAttrValue = nextTitleActiveConf.maxActivateVal
                local nextTitleLevel = tonumber(nextTitleActiveConf.titileLevel)
                local titleName = heroQualityConf[nextTitleLevel].title
                local titleStar = heroQualityConf[nextTitleLevel].star

                local nextAttrStr = "[" .. titleName .. tostring(titleStar) .. GlobalApi:getLocalStr_new("STR_STAR") .. "+" .. tostring(nextMaxAttrValue) .."%]\n"
                if maxAwake == false then
                    nextAttrStr = "[" ..  GlobalApi:getLocalStr_new("AWAKE_TYPE_MAX") .. "+" .. tostring(nextMaxAttrValue) .."%]\n"
                end

                local re12 = xx.RichTextLabel:create(nextAttrStr, fontSize, COLOR_TYPE.GRAY)
		        re12:setStroke(COLOROUTLINE_TYPE.PART_ATTR_GRAY, 2)

                rt:addElement(re12)
            end
        end
    end

    self.awakeAttrImg:addChild(rt)
end

function RolePartUI:requestAwakeCurPart(awake_type)
    local args = {
		pos = self.obj:getPosId(),
		part_pos = self.part_pos,
	}

    self.obj:getAwakeAttr()
    if awake_type == AWAKE_TYPE.NORMAL then

        local curAwakeLevel = self.partObj:getAwakeLv()
        local nextAwakeLevel = curAwakeLevel + 1
        MessageMgr:sendPost("normal_awake", "parttrain", json.encode(args), function (jsonObj)
            local code = jsonObj.code
            if code == 0 then

                self.partObj:setAwakeLv(nextAwakeLevel)
                self.obj:getAwakeAttr()
                self.obj:setFightForceDirty(true)

                local costs = jsonObj.data.costs
                GlobalApi:parseAwardData(costs)

                RoleMgr:refreshPartPanel()
                RoleMgr:popupTips(self.obj)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr_new('AWAKE_FAIL'),COLOR_TYPE.RED)
            end
        end)
    elseif awake_type == AWAKE_TYPE.MAX then
        MessageMgr:sendPost("max_awake", "parttrain", json.encode(args), function (jsonObj)
            local code = jsonObj.code
            if code == 0 then
                self.partObj:setMaxAwakeLv(true)
                self.obj:getAwakeAttr()
                self.obj:setFightForceDirty(true)

                local costs = jsonObj.data.costs
                GlobalApi:parseAwardData(costs)

                RoleMgr:refreshPartPanel()
                RoleMgr:popupTips(self.obj)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr_new('AWAKE_FAIL'),COLOR_TYPE.RED)
            end
        end)
    end
end

function RolePartUI:setEmbedGemInfo(gem_pos, gemObj)

    local openCnt = self.partObj:getGemSlotCount()
    if gemObj == nil then
        self.embedSlotArr[gem_pos].bg:loadTexture(DEFAULT)
        self.embedSlotArr[gem_pos].icon:setVisible(false)
        self.embedSlotArr[gem_pos].lock:setVisible(false)
        self.embedSlotArr[gem_pos].levelTx:setVisible(false)
        self.embedSlotArr[gem_pos].levelUpImg:setVisible(false)
        self.embedSlotArr[gem_pos].bg:setTouchEnabled(false)

        if gem_pos <= openCnt then
            self.embedSlotArr[gem_pos].addImg:setVisible(true)
            self.embedSlotArr[gem_pos].bg:setTouchEnabled(true)
        else
            self.embedSlotArr[gem_pos].addImg:setVisible(false)
            self.embedSlotArr[gem_pos].lock:setVisible(true)
            self.embedSlotArr[gem_pos].lock:loadTexture("uires/ui_new/common/lock_3.png")
            self.embedSlotArr[gem_pos].icon:addTouchEventListener(function(sender, eventType)

            end)
        end
    else
    	self.embedSlotArr[gem_pos].bg:setTouchEnabled(true)
        self.embedSlotArr[gem_pos].lock:setVisible(false)
        self.embedSlotArr[gem_pos].icon:setVisible(true)
        self.embedSlotArr[gem_pos].levelTx:setVisible(true)

        local canUpgrade = gemObj:getUpgradeConsumeList(false)
        if canUpgrade then
            self.embedSlotArr[gem_pos].levelUpImg:setVisible(true)
        else
            self.embedSlotArr[gem_pos].levelUpImg:setVisible(false)
        end

        self.embedSlotArr[gem_pos].addImg:setVisible(false)
        self.embedSlotArr[gem_pos].bg:loadTexture(COLOR_ITEMFRAME[COLOR_QUALITY[gemObj:getQuality()]])
        self.embedSlotArr[gem_pos].icon:setVisible(true)
        self.embedSlotArr[gem_pos].icon:loadTexture("uires/icon/gem/gem" .. gemObj:getId() .. ".png")

        self.embedSlotArr[gem_pos].icon:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local gemDetailUI = ClassGemDetailUI.new(self.obj, self.curPart, gem_pos, gemObj)
                gemDetailUI:showUI()
            end
        end)

        self.embedSlotArr[gem_pos].levelTx:setString("Lv." .. gemObj:getLevel())
    end
end

function RolePartUI:refreshPartEmbedInfo(part_pos)

    local gems = self.partObj:getGems()
    local embedSlotOpenCount = self.partObj:getGemSlotCount()
    for i = 1, PART_GEMS_COUNT do
        self:setEmbedGemInfo(i, gems[i])
        if i > embedSlotOpenCount then
        	self.embedSlotArr[i].openImg:setVisible(true)
        	self.embedSlotArr[i].openTx:setString(GlobalApi:getLocalStr_new('partEmbedLimit' .. i))
        else
        	self.embedSlotArr[i].openImg:setVisible(false)
        end
    end

    local partEmbedConf = GameData:getConfData("partembed")
    local attributeConf = GameData:getConfData("attribute")

    self.embedAttrImg:removeAllChildren()
    local rt = xx.RichText:create()
	rt:setContentSize(cc.size(300, 90))
	rt:setAnchorPoint(cc.p(0, 1))
    rt:setPosition(cc.p(0, 90))
    rt:setRowSpacing(4)

    local objEquip = self.obj:getEquipByIndex(part_pos)
    local flag = xx.RichTextImage:create('uires/ui_new/common/flag_treasure_attr.png')
    rt:addElement(flag)

    local mainAttrDesc = GlobalApi:getLocalStr_new("EQUIP_TYPE_" .. part_pos) .. GlobalApi:getLocalStr_new("STR_ATTR_DES_1")
    local re1 = xx.RichTextLabel:create(mainAttrDesc, 18, COLOR_TYPE.RED)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    rt:addElement(re1)

    local embedLevel = self.partObj:getPartEmbedLevel()
    local addPercent = 0
    if embedLevel > 0 then
        addPercent = partEmbedConf[embedLevel].addEquipMainAtt
    end 
    local mainAttr = "+" .. addPercent .. "%"
    local re2 = xx.RichTextLabel:create(mainAttr, 18, COLOR_TYPE.YELLOW)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    rt:addElement(re2)

    if embedLevel < 12 then
        local nextembedLevel = embedLevel + 1
        local attrPercent = partEmbedConf[nextembedLevel].addEquipMainAtt
        local needGemNum = partEmbedConf[nextembedLevel].needGemNum
        local needGemLevel = partEmbedConf[nextembedLevel].needGemLevel
        local str = string.format(GlobalApi:getLocalStr_new("STR_EMBED_EQUIP_MAIN_ATTR_ADD"), needGemNum, needGemLevel, attrPercent);

        local str = "\n[" .. str .. "%]"

        local re3 = xx.RichTextLabel:create(str, 18, COLOR_TYPE.GRAY)
	    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        rt:addElement(re3)
    end

    local reEnd = xx.RichTextLabel:create("\n", 18, cc.c4b(255, 0, 0, 255))
    rt:addElement(reEnd)
    

    local totalVal = 0
    local attrType = 0
    for i = 1, 4 do
        local gemObj = gems[i]
        if gemObj ~= nil then
        	totalVal = totalVal + gemObj:getValue()
        	attrType = gemObj:getAttrId()
        end
    end

    if attrType ~= 0 then
    	local totalValStr = GlobalApi:getLocalStr_new('PART_GEM_TOTAL_ATTR_LABEL') .. '：' .. attributeConf[attrType].name .. '+' .. totalVal
    	release_print('@@@ totalValStr = ' .. totalValStr)
    	local re4 = xx.RichTextLabel:create(totalValStr, 18, COLOR_TYPE.GREEN)
		re4:setStroke(COLOROUTLINE_TYPE.BLACK, 2)
		rt:addElement(re4)
    end

    self.embedAttrImg:addChild(rt)

    self:refreshEmbedSlotOpenCondition()
end

function RolePartUI:refreshEmbedSlotOpenCondition()
    local embedSlotOpenCount = self.partObj:getGemSlotCount()
    if embedSlotOpenCount >= 4 then
        return
    end

    local nextOpenSlot = embedSlotOpenCount + 1
    local needAwakeLevel = tonumber(GlobalApi:getGlobalValue("partEmbedLimit" .. nextOpenSlot))

end

return RolePartUI