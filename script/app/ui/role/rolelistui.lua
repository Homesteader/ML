local RoleCellAssist = require("script/app/ui/role/rolecellassist")
local RoleCellChip = require("script/app/ui/role/rolecellchip")
local RoleCellBeAssist = require("script/app/ui/role/rolecellbeassist")
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local RoleListUI = class("RoleListUI", BaseUI)

function RoleListUI:ctor(page)
	self.uiIndex = GAME_UI.UI_ROLELIST
	self.currtype = page or 1
	self.celltab = {}
	self.scrollViewGeneral = {}
	self.filtrateQuality = 0
	self.recordCont = {}
end

function RoleListUI:setUIBackInfo()
	UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_ROLELIST), function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr:PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleList();
		end
	end)
end

function RoleListUI:onShow()
	self:setUIBackInfo()
end

function RoleListUI:init()

	local bgimg = self.root:getChildByName("bg_img")
	local bg = bgimg:getChildByName("bg")
	self:adaptUI(bgimg, bg)

	--功能页签
	local tablistBg = bg:getChildByName("tab_list") 
	self.chooseTab = {}
	for i=1,3 do
		local tabbg = tablistBg:getChildByName("tab_"..i)
		local funTx = tabbg:getChildByName("func_tx")
		funTx:setString(GlobalApi:getLocalStr_new("ROLE_LIST_TITLE"..i))
		self.chooseTab[i] = {}
		self.chooseTab[i].btn = tabbg
		self.chooseTab[i].tx = funTx
		tabbg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.currtype = i
				self:updateFuncTabBtn()
				self:resetCells()
			end
		end)
	end

	--筛选页签
	local filtCmp = {0,QUALITY.PURPLE,QUALITY.ORANGE,QUALITY.RED,QUALITY.GOLD}
	self.filtrateTab = {}
	self.bottomTab = bg:getChildByName("bootm_tab_list")
	for i=1,5 do
		local btn = self.bottomTab:getChildByName("tab_"..i) 
		self.filtrateTab[i] = {}
		self.filtrateTab[i].btn = btn
		self.filtrateTab[i].standard = filtCmp[i] 
		btn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then

				self.filtrateQuality = filtCmp[i]
				self:filtrateCell()
				self:resetCells()
			end
		end)
		local dotImg = btn:getChildByName("dot_img")
		if dotImg then
			local quality = filtCmp[i] == 0 and 1 or filtCmp[i]
			dotImg:loadTexture("uires/ui_new/common/quality_dot" .. quality .. ".png")
		end
	end

	self:setUIBackInfo()

	self.list_sv = {}
	for i=1,3 do
		local sv = bg:getChildByName("ScrollView_"..i)
		sv:setScrollBarEnabled(false)
    	sv:setInertiaScrollEnabled(true)
    	sv:setVisible(false)
		self.list_sv[i] = sv
	end

	self:updateFuncTabBtn()
	self:updateCell()
	self:filtrateCell()
end

function RoleListUI:setDirty()
	self:updateCell()
	self:resetCells()
end

function RoleListUI:updateFuncTabBtn()
	for i=1,3 do
		if i == self.currtype then
			self.chooseTab[i].btn:loadTextureNormal('uires/ui_new/common/role_tab_select.png')
			self.chooseTab[i].tx:setTextColor(cc.c4b(196,243,241,255))
			self.chooseTab[i].tx:enableOutline(cc.c4b(46,89,81,255),1)
		else
			self.chooseTab[i].btn:loadTextureNormal('uires/ui_new/common/role_tab_normal.png')
			self.chooseTab[i].tx:setTextColor(cc.c4b(79,126,123,255))
			self.chooseTab[i].tx:enableOutline(cc.c4b(28,40,42,255),1)
		end
		self.list_sv[i]:setVisible(false)
	end
	self.bottomTab:setVisible(self.currtype ~= ROLELISTTYPE.UI_ASSIST)
end

--筛选
function RoleListUI:filtrateCell()
	for i=1,5 do
		if self.filtrateQuality == self.filtrateTab[i].standard then
			self.filtrateTab[i].btn:loadTextureNormal('uires/ui_new/role/list_btn2.png')
		else
			self.filtrateTab[i].btn:loadTextureNormal('uires/ui_new/role/list_btn1.png')
		end
	end
end

function RoleListUI:updateCell()
	
	if self.currtype == ROLELISTTYPE.UI_ASSIST then
		self:updateRoleCell()
	elseif self.currtype == ROLELISTTYPE.UI_CHIP then
		self:updateRoleChip()
	elseif self.currtype == ROLELISTTYPE.UI_BEASSIST then
		self:updateRoleCard()
	end
	self.list_sv[self.currtype]:setVisible(true)
	self:initListView()
end

function RoleListUI:resetCells()

	local oldCellCont = self.recordCont[self.currtype] or 0
	self:updateCell()
	local newCellCont = #self.cellsData
	local maxCont = newCellCont >= oldCellCont and newCellCont or oldCellCont
	for i=1,maxCont do
		local cell = self.list_sv[self.currtype]:getChildByName("cell"..i)
		if cell then
			if self.objarr[i] then
				cell:setVisible(true)
			else
				cell:setVisible(false)
			end
		end
	end
	self.scrollViewGeneral[self.currtype]:updateItems()
	self.recordCont[self.currtype] = newCellCont
end

function RoleListUI:updateRoleCell()

	self.objarr = {}
	for k, v in pairs(RoleData:getRoleMap()) do
		if v:getId() < 10000 then
			self.objarr[tonumber(k)] = v
		end
	end
	self.viewSize = self.list_sv[self.currtype]:getContentSize() -- 可视区域的大小
	RoleMgr:sortByQuality(self.objarr,self.currtype)
end

function RoleListUI:updateRoleChip()
	self.objarr = {}
	local allfragment = BagData:getFragment()
	for k, v in pairs(allfragment) do
		if v:getId() < 10000 then
			if self.filtrateQuality == 0 then
				table.insert(self.objarr, v)
			else
				local quality = v:getQuality()
				if self.filtrateQuality == quality then 
					table.insert(self.objarr, v)
				end
			end
		end
	end
	self.viewSize = self.list_sv[self.currtype]:getContentSize() -- 可视区域的大小
end

function RoleListUI:updateRoleCard()
	self.objarr = {}
	local allcards = BagData:getAllCards()
	for k, v in pairs(allcards) do
	 	if v:getId() < 10000 then
	        if self.filtrateQuality == 0 then
				table.insert(self.objarr, v)
			else
				local quality = v:getQuality()
				if self.filtrateQuality == quality then 
					table.insert(self.objarr, v)
				end
			end
	    end
	end

	table.sort( self.objarr, function (a,b)
    	local id1 = a:getId()
    	local id2 = b:getId()
    	return id1 > id2
    end )
	self.viewSize = self.list_sv[self.currtype]:getContentSize() -- 可视区域的大小
end

function RoleListUI:initListView()

	self.cellSpace = 8
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.objarr
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (math.ceil(allNum/2) - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addCells(tempCellData,widgetItem)
    end
  	
  	local function updateCallBack(tempCellData,widgetItem)
  		self:updateItem(tempCellData,widgetItem)
  	end
    if self.scrollViewGeneral[self.currtype] == nil then
    	self.recordCont[self.currtype] = #self.cellsData
        self.scrollViewGeneral[self.currtype] = ScrollViewGeneral.new(self.list_sv[self.currtype],self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,2)
    else
    	local innerHeight = self.allHeight
    	if self.allHeight <= self.viewSize.height then
	        innerHeight = self.viewSize.height
	    end
    	local height = self.viewSize.height - innerHeight
        self.scrollViewGeneral[self.currtype]:resetScrollView(self.list_sv[self.currtype],self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,2,height,updateCallBack)
    end
end

function RoleListUI:initItemData(index)
    if self.objarr[index] then
        local w = 375
        local h = 118
        
        local curCellHeight = 0
        if index%2 == 1 then
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

function RoleListUI:addCells(tempCellData,widgetItem)
    if self.objarr[tempCellData.index] then
        local i = tempCellData.index
        local obj = self.objarr[tempCellData.index]
        local id = obj:getId()
        if not self.celltab[self.currtype] then
        	self.celltab[self.currtype] = {}
        end

        if self.currtype == ROLELISTTYPE.UI_ASSIST then
			self.celltab[self.currtype][i] = RoleCellAssist.new(self, i,self.objarr[i])
		elseif self.currtype == ROLELISTTYPE.UI_CHIP then
			self.celltab[self.currtype][i] = RoleCellChip.new(self, i,self.objarr[i])
		elseif self.currtype == ROLELISTTYPE.UI_BEASSIST then
			self.celltab[self.currtype][i] = RoleCellBeAssist.new(self, i,self.objarr[i])
		end

        local panel = self.celltab[self.currtype][i]:getPanel()
		local contentsize = panel:getChildByName('bg_img'):getContentSize()
		self.celltab[self.currtype][i]:setType(self.isassis)

        local w = tempCellData.w
        local h = tempCellData.h

     	local posx = w * 0.5+15
     	local centerPosX = self.viewSize.width/2
        if i % 2 == 0 then
            posx = centerPosX+ w*0.5+5
        end
        widgetItem:addChild(panel)
        panel:setPosition(cc.p(posx,h*0.5-15))
    end
end

function RoleListUI:updateItem(tempCellData,widgetItem)
	
    if self.objarr[tempCellData.index] then
    	local i = tempCellData.index
        local obj = self.objarr[tempCellData.index]
        local id = obj:getId()
		
		if self.celltab[self.currtype] and self.celltab[self.currtype][i] then
			self.celltab[self.currtype][i]:update(i,self.objarr[i])
		end
		
    end
end

return RoleListUI