local BagUI = class("BagUI", BaseUI)
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemUpgradeUI = require("script/app/ui/gem/gemupgradeui")
local ClassItemCell = require('script/app/global/itemcell')
local ClassGemComposeUI = require('script/app/ui/gem/gemcompose')

local BagCell = require("script/app/ui/bag/bagcell")
local BagItemCell = require("script/app/ui/bag/bagitemcell")
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

local ITEM_PAGE = 1
local EQUIP_PAGE = 2
local GEM_PAGE = 3
local FRAGMENT_PAGE = 4
local maxTab = 4
local maxSubTab = 7
function BagUI:ctor(id)
	self.uiIndex = GAME_UI.UI_BAG
	self.bagTypeId = id or 1

	self.celltab = {}
	self.oldmaxRecord = {}
	self.recordCont = {}
	self.scrollViewGeneral = {}
	self.oldChooseId = 0
end

function BagUI:setUIBackInfo()
	UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_BAG), function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr:PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			BagMgr:hideBag()
		end
	end)
end

function BagUI:onShow()
	self:setUIBackInfo()
end

function BagUI:init()

	local bgImg = self.root:getChildByName("bg_img")
	local bagImg = bgImg:getChildByName("bg")
    self:adaptUI(bgImg, bagImg)
    
    self:setUIBackInfo()

    --获取筛选信息
    local bagCfg = GameData:getConfData("bag")
    self.bagFrame = {}
    self.bagChooseCmp = {}
    for i=1,4 do
    	self.bagFrame[i] = {}
    	self.bagChooseCmp[i] = {}
    	local smallTypeLen = #bagCfg[i].filtrate
    	local bagType = bagCfg[i].key
    	local showtype = bagCfg[i].showtype
    	if bagCfg[i].filtrate[1] == '0' then
    		self.bagFrame[i].smallTypeLen = 0
    	else
    		self.bagFrame[i].bagType = bagType
    		self.bagFrame[i].smallTypeLen = smallTypeLen+1
    		self.bagChooseCmp[i][1] = bagCfg[i].filtrate
    		for smallId = 2,smallTypeLen+1 do
    			local filtrate = bagCfg[i].filtrate[smallId-1]
    			local tab = {}
    			table.insert(tab, filtrate)
    			self.bagChooseCmp[i][smallId] = tab
    		end
    	end 
    	self.bagFrame[i].svtype = showtype
    end

    local frameBg = bagImg:getChildByName("frame")
    self.rightBg = frameBg:getChildByName("right_bg")
    self.btmLBg = frameBg:getChildByName("bottom_img")
    
    --功能页签
	local tablistBg = bagImg:getChildByName("tab_list") 
	self.chooseTab = {}
	for i=1,maxTab do
		local tabbg = tablistBg:getChildByName("tab_"..i)
		local funTx = tabbg:getChildByName("func_tx")
		funTx:setString(GlobalApi:getLocalStr_new("BAG_TAB_STR"..i))
		self.chooseTab[i] = {}
		self.chooseTab[i].btn = tabbg
		self.chooseTab[i].tx = funTx
		tabbg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.bagTypeId = i
				self:chooseBagType()
				self:resetCells()
			end
		end)
	end

	--子类页签
	self.filtrateTab = {}
	local subTabBg = bagImg:getChildByName("bootm_tab_list") 
	for i=1,maxSubTab do
		local tabbg = subTabBg:getChildByName("tab_"..i)
		self.filtrateTab[i] = {}
		self.filtrateTab[i].btn = tabbg
		local dotIcon = tabbg:getChildByName("dot_img")
		if dotIcon then
			self.filtrateTab[i].dotIcon = dotIcon
		end
		tabbg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self:filtrateBag(i)
				self:resetCells()
			end
		end)
	end

	self.cardSv = bagImg:getChildByName("ScrollView_1")
    self.cardSv:setInertiaScrollEnabled(true)
    self.cardSv:setScrollBarEnabled(false)

    self.containSv = bagImg:getChildByName("ScrollView_2")
    self.containSv:setInertiaScrollEnabled(true)
    self.containSv:setScrollBarEnabled(false)

    self.list_sv = {}
    self.list_sv[1] = self.cardSv
    self.list_sv[2] = self.containSv
    for i=1,2 do
    	self.oldmaxRecord[i] = 0
		self.recordCont[i] = 0
	end

    self.currObj = nil

    --右侧信息界面
	self.somebg = self.rightBg:getChildByName("have_bg")
	self.nonebg = self.rightBg:getChildByName("none_bg")
	local tipTx = self.nonebg:getChildByName("text")
	tipTx:setString(GlobalApi:getLocalStr_new("BAG_TAB_STR5"))

	local goodsBgImg = self.somebg:getChildByName("goods_bg_img")
	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	self.awardBgImg = tab.awardBgImg
	self.awardImg = tab.awardImg
	tab.upImg:setVisible(false)
	tab.starImg:setVisible(false)
	self.awardBgImg:setPosition(goodsBgImg:getPosition())
	self.somebg:addChild(self.awardBgImg)
	local descBg = self.somebg:getChildByName("desc_bg")
	self.descTx = descBg:getChildByName("text")
	self.nameTx = goodsBgImg:getChildByName("name_tx")
	self.ownTx = goodsBgImg:getChildByName("own_tx")

	--功能按钮
	self.checkBtn = self.somebg:getChildByName("check_btn")

	self.useBtn = self.somebg:getChildByName("use_btn")
	local btnTx = self.useBtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("BAG_BTN_STR1"))

	self.mergeBtn = self.somebg:getChildByName("merge_btn")
	local btnTx = self.mergeBtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("BAG_BTN_STR3"))

	self.onekyMergeBtn = frameBg:getChildByName("onekeymerge_btn")
	self.splitBtn = frameBg:getChildByName("split_btn")

	--
	self:chooseBagType()
end

function BagUI:chooseBagType()

	for i=1,maxTab do
		if i == self.bagTypeId then
			self.chooseTab[i].btn:loadTextureNormal('uires/ui_new/common/role_tab_select.png')
			self.chooseTab[i].tx:setTextColor(cc.c4b(196,243,241,255))
			self.chooseTab[i].tx:enableOutline(cc.c4b(46,89,81,255),1)
		else
			self.chooseTab[i].btn:loadTextureNormal('uires/ui_new/common/role_tab_normal.png')
			self.chooseTab[i].tx:setTextColor(cc.c4b(79,126,123,255))
			self.chooseTab[i].tx:enableOutline(cc.c4b(28,40,42,255),1)
		end
	end

	self.svtype = self.bagFrame[self.bagTypeId].svtype
	self.bagType = self.bagFrame[self.bagTypeId].bagType

	local showMaxSv = self.svtype == 2
	self.rightBg:setVisible(not showMaxSv)
    self.btmLBg:setVisible(showMaxSv)

    self.list_sv[1]:setVisible(not showMaxSv)
    self.list_sv[2]:setVisible(showMaxSv)

    self.onekyMergeBtn:setVisible(self.bagTypeId == GEM_PAGE)
    self.splitBtn:setVisible(self.bagTypeId == EQUIP_PAGE)
	self:filtrateBag(1)
end

function BagUI:filtrateBag(subType)

	self.smallTypeLen = self.bagFrame[self.bagTypeId].smallTypeLen
	for i=1,maxSubTab do
		self.filtrateTab[i].btn:setVisible(i<=self.smallTypeLen)
		if i == subType then
			self.filtrateTab[i].btn:loadTextureNormal('uires/ui_new/role/list_btn2.png')
		else
			self.filtrateTab[i].btn:loadTextureNormal('uires/ui_new/role/list_btn1.png')
		end
 
		if self.bagTypeId == EQUIP_PAGE then
			if self.filtrateTab[i].dotIcon then
				self.filtrateTab[i].dotIcon:loadTexture(DEFAULTEQUIPPART[i-1])
			end
		end
	end

	self.filtrateType = subType
	if self.bagTypeId == ITEM_PAGE then 
		self:updateNormalItem()
	elseif self.bagTypeId == GEM_PAGE then
		self:updateGem()
	elseif self.bagTypeId == FRAGMENT_PAGE then
		self:updateFragment()
	elseif self.bagTypeId == EQUIP_PAGE then
		self:updateEquip()
	end

	local cont = self.recordCont[self.svtype]
	self.somebg:setVisible(cont~=0)
	self.nonebg:setVisible(cont==0)
end

local function sortFn(a, b)
    local q1 = a:getQuality()
    local q2 = b:getQuality()
    local l1 = a:getLevel()
	local l2 = b:getLevel()
	local id1 = a:getId()
	local id2 = b:getId()
    if q1 == q2 then
    	if level1 == level2 then
	        if l1 == l2 then
	        	return id1 < id2
	        else
	        	return l1 > l2
	        end
	    else
	    	return level1 > level2
	    end
    else
        return q1 > q2
    end
end

local function sortFn1(a, b)
    local q1 = a:getQuality()
    local q2 = b:getQuality()
    local u1 = a:getUseable()
    local u2 = b:getUseable()
    local s1 = a:getObjType()
    local s2 = b:getObjType()
    if u1 == u2 then
    	if s1 == s2 then
		    if q1 == q2 then
		        local id1 = a:getId()
		        local id2 = b:getId()
		        return id1 > id2
		    else
		        return q1 > q2
		    end
		else
			if s1 == 'dress' then
				return false
			elseif s1 == 'dragon' then
				return false
			elseif s1 == 'limitmat' then
				return false
			else
				return true

			end
		end
	else
		return u1 > u2
	end
end

--刷新道具容器
function BagUI:updateNormalItem()

	self.objarr = {}
	local tab = BagData:getAllMaterial()
	local tab1 = BagData:getAllDresses()
	local tab2 = BagData:getAllLimitMat()
	local showTab = {}
	if tab then
        for k, v in pairs(tab) do
            table.insert(showTab, v)
        end
    end
    if tab1 then
        for k, v in pairs(tab1) do
            table.insert(showTab, v)
        end
    end
    if tab2 then
    	for k, v in pairs(tab2) do
            table.insert(showTab, v)
        end
    end

    self:insertData(showTab)
    table.sort( self.objarr, sortFn1 )
	self:formateSv()
end

--刷新宝石容器
function BagUI:updateGem()

	self.objarr = {}
	local gemTab = BagData:getAllGems()
	for i=1,4 do
		local tab = gemTab[i]
		self:insertData(tab)
	end
	table.sort( self.objarr, sortFn )
	self:formateSv()
end

--刷新碎片容器
function BagUI:updateFragment()

	self.objarr = {}
	local standard = self.bagChooseCmp[self.bagTypeId][self.filtrateType]
	local materialtab = BagData:getAllMaterial()
	if materialtab then
	    self:insertData(materialtab)
	end

  	table.sort( self.objarr, sortFn1 )
	self:formateSv()

end

--刷新装备容器
function BagUI:updateEquip()

	self.objarr = {}
	local standard = self.bagChooseCmp[self.bagTypeId][self.filtrateType]
	for i=1,#standard do
		local tab = BagData:getEquipMapByType(tonumber(standard[i]))
	    for k, v in pairs(tab) do
            table.insert(self.objarr, v)
        end
    end

	if #self.objarr > 2 then
		table.sort(self.objarr,sortFn)
	end

	self:formateSv()
end

function BagUI:insertData(showTab)

	if not showTab then
		return
	end

	if self.smallTypeLen == 0 then
    	for k,v in pairs(showTab) do
	    	table.insert(self.objarr,v)
	    end
    else
	    local standard = self.bagChooseCmp[self.bagTypeId][self.filtrateType]
	    for k,v in pairs(showTab) do
	    	local showtype = v:getBagTab()
	    	local itemBagType = v:getBagType()
	    	if itemBagType == self.bagType then
				for i=1,#standard do
					if  showtype == standard[i] then
						table.insert(self.objarr,v)
					end
				end
			end
	    end
	end
end

function BagUI:formateSv()

	self.recordCont[self.svtype] = #self.objarr
	if self.oldmaxRecord[self.svtype] < self.recordCont[self.svtype] then
		self.oldmaxRecord[self.svtype] = self.recordCont[self.svtype]
	end

	self.viewSize = self.list_sv[self.svtype]:getContentSize()
	self:initListView()
end

function BagUI:initListView()

	self.cellSpace = 8
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.objarr
    for i = 1,allNum do
        self:initItemData(i)
    end

    local lineNumber = self.svtype == 1 and 4 or 2
    self.allHeight = self.allHeight + (math.ceil(allNum/lineNumber) - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addCells(tempCellData,widgetItem)
    end

    local function updateCallBack(tempCellData,widgetItem)
    	self:updateCellItems(tempCellData,widgetItem)
    end

    if self.scrollViewGeneral[self.svtype] == nil then
        self.scrollViewGeneral[self.svtype] = ScrollViewGeneral.new(self.list_sv[self.svtype],self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,lineNumber)
  	else
  		local innerHeight = self.allHeight
    	if self.allHeight <= self.viewSize.height then
	        innerHeight = self.viewSize.height
	    end
    	local height = self.viewSize.height - innerHeight
        self.scrollViewGeneral[self.svtype]:resetScrollView(self.list_sv[self.svtype],self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,lineNumber,height,updateCallBack)
  	end
end

function BagUI:initItemData(index)
    if self.objarr[index] then
        local w = self.svtype == 1 and 84.6 or 375
        local h = self.svtype == 1 and 84.6 or 118
        
        local curCellHeight = 0
        local num = self.svtype == 1 and 4 or 2
        if index%num == 1 then
            curCellHeight = h
        end

        self.allHeight = curCellHeight + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w
        table.insert(self.cellsData,tempCellData)
    end
end

function BagUI:addCells(tempCellData,widgetItem)
    if self.objarr[tempCellData.index] then
        local i = tempCellData.index
        local obj = self.objarr[tempCellData.index]

        if not self.celltab[self.svtype] then
        	self.celltab[self.svtype] = {}
        end

        if self.bagTypeId == EQUIP_PAGE then
			self.celltab[self.svtype][i] = BagCell.new(obj,'equip')
		elseif self.bagTypeId == FRAGMENT_PAGE then
			self.celltab[self.svtype][i] = BagCell.new(obj,'fragment')
		elseif self.bagTypeId == ITEM_PAGE or self.bagTypeId == GEM_PAGE then
			self.celltab[self.svtype][i] = BagItemCell.new(obj,self.bagTypeId,i)
		end

        local panel = self.celltab[self.svtype][i]:getPanel()
		local contentsize = panel:getChildByName('cell_bg'):getContentSize()

        local w = tempCellData.w
        local h = tempCellData.h

        local posx = 15
        if self.svtype == 2 then
	     	local centerPosX = self.viewSize.width/2
	        if i % 2 == 0 then
	            posx = centerPosX+5
	        end
	    else
	    	posx = 6
	    	local index = (i-1) % 4
	    	posx = posx + (w+5)*index
	    end
	
        widgetItem:addChild(panel)
        panel:setPosition(cc.p(posx,-15))
    end
end

function BagUI:updateCellItems(tempCellData,widgetItem)
	if self.objarr[tempCellData.index] then
    	local i = tempCellData.index
        local obj = self.objarr[tempCellData.index]
		if self.celltab[self.svtype] and self.celltab[self.svtype][i] then
			if self.bagTypeId == EQUIP_PAGE then
				self.celltab[self.svtype][i]:update(self.objarr[i],'equip')
			elseif self.bagTypeId == FRAGMENT_PAGE then
				self.celltab[self.svtype][i]:update(self.objarr[i],'fragment')
			elseif self.bagTypeId == ITEM_PAGE or self.bagTypeId == GEM_PAGE then
				self.celltab[self.svtype][i]:update(self.objarr[i],self.bagTypeId,i)
			end
		end
    end
end

function BagUI:resetCells()

	for i=1,self.oldmaxRecord[self.svtype] do
		local cell = self.list_sv[self.svtype]:getChildByName("cell"..i)
		if cell then
			cell:setVisible(i<=self.recordCont[self.svtype])
		end
	end
	self.scrollViewGeneral[self.svtype]:updateItems()

end

function BagUI:updateRightPanel(obj,ntype,cellId,lightImg)

	if not obj then
		return
	end

	self.awardImg:loadTexture(obj:getIcon())
	self.awardImg:ignoreContentAdaptWithSize(true)
	self.awardBgImg:loadTexture(obj:getBgImg())

	self.nameTx:setString(obj:getName())
    self.nameTx:setTextColor(obj:getNameColor())
	self.nameTx:enableOutline(obj:getNameOutlineColor(),2)

	local ownnum = obj:getNum() or 0
	self.ownTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_OWN")..ownnum)

	self.descTx:setString(obj:getDesc())

	if ntype == ITEM_PAGE then
		self:updateRightItemPanel(obj)
	elseif ntype == GEM_PAGE then
		self:updateRightGemPanel(obj)
	end

	if self.oldChooseId == cellId then
		return
	end
	self.oldChooseId =  cellId

	if not lightImg then
		return
	end

	if self.oldLightBg then
		self.oldLightBg:setVisible(false)
	end
	self.oldLightBg = lightImg
	self.oldLightBg:retain()
end

--刷新道具页签功能按钮
function BagUI:updateRightItemPanel(obj)

	--查看
	local btnTx = self.checkBtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("BAG_BTN_STR2"))
	if obj:judgeHasDrop(obj) then
        self.checkBtn:setBright(true)
        self.checkBtn:setTouchEnabled(true)
        btnTx:setTextColor(COLOR_TYPE.GREEN_BTN)
        btnTx:enableOutline(COLOROUTLINE_TYPE.GREEN_BTN, 2)
    else
    	self.checkBtn:setBright(false)
        self.checkBtn:setTouchEnabled(false)
        btnTx:setTextColor(COLOR_TYPE.GRAY1)
        btnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
    end

    self.checkBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI(obj,false)
        end
    end)

    --合成和使用
    self.useBtn:setVisible(false)
    self.mergeBtn:setVisible(false)
    if obj:getCategory() == 'dress' or obj:getUseable() == 2 then
		self.mergeBtn:setVisible(true)
	else
		self.useBtn:setVisible(true)
	end

	local num = obj:getNum()
	local mergeNum = ((obj.getMergeNum and obj:getMergeNum() == 0) and 1) or obj:getMergeNum()
	local useable = obj:getUseable() or 0
	local canMerge = useable >0 and (num / mergeNum) >= 1
	self.mergeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
    		if obj:getCategory() == 'dress' then
        		local id = obj:getId()
        		BagMgr:showDressMerge(id,true)
        	else
        		local function showstatus()
					local level = UserData:getUserObj():getLv()
					local str = string.format(GlobalApi:getLocalStr('MERGE_DESTINY_LIMIT_DESC'),obj:getMergeLvLimit())
		        	if level >= obj:getMergeLvLimit() then
		        		BagMgr:showDestinyMerge(obj:getId(),true)
		        	else	
		        		promptmgr:showSystenHint(str, COLOR_TYPE.RED)
		        	end
				end
        		if obj:getId() == 300001 then
    				promptmgr:showMessageBox(GlobalApi:getLocalStr("MERGE_DESTINY_DESC"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()	
    					showstatus()
		            end)
    			else
    				showstatus()
    			end
        	end
    	end
    end)
	
	self.useBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

    		if obj:getId() == 200079 then
                local food = UserData:getUserObj():getFood()
                local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                if food >= maxFood then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                    return
                end
    		end
    		local userType = obj:getUseType()
        	if userType == 'herobox' then
                if obj:getId() == 200131 or obj:getId() == 200132 or obj:getId() == 200133 or obj:getId() == 200134 then
                    BagMgr:showJadeSealAwardNewUI(obj)
                else
        		    local userEffect = tonumber(obj:getUseEffect())
        		    BagMgr:showHeroBox(userEffect,obj:getId(),obj:getNum())
                end
            elseif userType == 'trialbox' then
                BagMgr:showOpenBox(obj)
        	else
        		local moduleOpen = obj:getModule()
        		if moduleOpen and moduleOpen ~= '' then
		            local desc,isOpen = GlobalApi:getGotoByModule(moduleOpen,true)
		            if desc then
		            	promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
		                return
		            end
    			end
    			self:useItemByTarget(obj,num,mergeNum)
	        end
        end
    end)
end

--刷新宝石页签功能按钮
function BagUI:updateRightGemPanel(obj)

	self.checkBtn:setVisible(true)
	self.useBtn:setVisible(false)
	self.mergeBtn:setVisible(true)

	local btnTx = self.checkBtn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("BAG_BTN_STR4"))
	self.checkBtn:setBright(true)
    self.checkBtn:setTouchEnabled(true)
    btnTx:setTextColor(COLOR_TYPE.GREEN_BTN)
    btnTx:enableOutline(COLOROUTLINE_TYPE.GREEN_BTN, 2)

	self.mergeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local gemUpgradeUI = ClassGemUpgradeUI.new(obj,0, 0, nil, function ()
               	self:updatePanel()
            end)
            local desc,isOpen = GlobalApi:getGotoByModule('gem_merge',true)
            if desc then
            	promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
                return
            end
            gemUpgradeUI:showUI()
        end
    end)

	self.onekyMergeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local gemComposeUI = ClassGemComposeUI.new(obj:getType(), 0, 0, nil, function ()
        		self:updatePanel()
        	end)
        	gemComposeUI:showUI()
        end
    end)

    self.checkBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	promptmgr:showSystenHint('功能暂未开发', COLOR_TYPE.RED)
        end
    end)
end

function BagUI:useItemByTarget(obj, num, mergeNum)
	if (num / mergeNum) >= 1 and (num / mergeNum) < 2 then
       	local cost = obj:getCost()
		if cost and cost:getId() == 'cash' then
            UserData:getUserObj():cost('cash',cost:getNum(),function()
               self:useItem(mergeNum, obj, 'use_day_box')
            end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost:getNum()))
		else
			self:useItem(mergeNum, obj)
		end
	elseif (num / mergeNum) >= 2 then	
        BagMgr:showUse(obj,self.bagTypeId)
	end
end

function BagUI:useItem(mergeNum,obj,act)
    local act = act or 'use'
	local args = {
  		type = 'material',
  		id = obj:getId(),
  		num = mergeNum
  	}
  	MessageMgr:sendPost(act,'bag',json.encode(args),function (response)
		local code = response.code
		local data = response.data
		if code == 0 then
			local awards = data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            local useEffect = obj:getUseEffect()
            if useEffect then
            	local tab = string.split(useEffect,':')
            	if tab and tab[1] == 'arena' then
            		promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('BAG_GET_DESC_1'),1), COLOR_TYPE.GREEN)
            	end

                if tonumber(obj:getId()) == 500001 then                   
                    Third:Get():openUrl(useEffect)
                end

            end
            self:filtrateBag(self.filtrateType)
		end
	end)
end
return BagUI