local RoleSelectListOutSideUI = class("RoleSelectListOutSideUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

function RoleSelectListOutSideUI:ctor(type)
	self.uiIndex = GAME_UI.UI_ROLESELECTLISTOUTSIDE
	self.dirty = false
	self.type = type
end

function RoleSelectListOutSideUI:setDirty(onlychild)
	self.dirty = true
end
function RoleSelectListOutSideUI:init()

	local bgimg = self.root:getChildByName("bg_img")
    local bgalpha = bgimg:getChildByName('bg_alpha')
    self:adaptUI(bgimg, bgalpha)

    local bgimg1 =bgalpha:getChildByName('bg_img1')
    
    local closebtn = bgimg1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleSelectListOutSide()
        end
    end)

	
	local titletx =bgimg1:getChildByName('title_tx')
	local titleStr = ''
	if self.type == HANDLE_ROLE.ASSIST then
		titleStr = GlobalApi:getLocalStr_new('ROLE_SELECT_TITLE1')
	elseif self.type == HANDLE_ROLE.CHANGE then
		titleStr = GlobalApi:getLocalStr_new('ROLE_SELECT_TITLE2')
	end
	titletx:setString(titleStr)

	self.noroleimg = bgimg1:getChildByName('norole_img')
	local nonTx = self.noroleimg:getChildByName("text")
	nonTx:setString(GlobalApi:getLocalStr_new("ROLE_SELECT_INFO1"))

	local svBg = bgimg1:getChildByName("sv_bg")
	self.listview = svBg:getChildByName('role_listview')
	self.listview:setScrollBarEnabled(false)
    self.viewSize = self.listview:getContentSize() -- 可视区域的大小

    self:update()
end

function RoleSelectListOutSideUI:update()
	self.rolecards = {}
	local assistmap = RoleData:getRoleAssistMap()
	local allcards = BagData:getAllCards()
	for k, v in pairs(allcards) do
		 if assistmap[v:getId()] == nil and v:getId() < 10000  then
		 	table.insert(self.rolecards, v)
		 end
	end
	self.cardsNum = #self.rolecards
	if self.cardsNum > 0 then
		RoleMgr:sortByQuality(self.rolecards,ROLELISTTYPE.UI_BEASSIST)
		self:initListView()
		self.noroleimg:setVisible(false)
	else
		self.noroleimg:setVisible(true)
	end
end

function RoleSelectListOutSideUI:initListView()

    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.rolecards
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    ScrollViewGeneral.new(self.listview,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)
    
end

function RoleSelectListOutSideUI:initItemData(index)
    if self.rolecards[index] then
        local w = 398
        local h = 110
        
        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function RoleSelectListOutSideUI:addItem(tempCellData,widgetItem)
    if self.rolecards[tempCellData.index] then
        local index = tempCellData.index
        local item = cc.CSLoader:createNode("csb/roleselectcell.csb")
        local cellbgimg = item:getChildByName("bg_img")
	    local iconImg = cellbgimg:getChildByName("icon_img")
	    local iconImgSize = iconImg:getContentSize()
	    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	    iconCell.awardBgImg:setTouchEnabled(false)
	    iconCell.awardBgImg:setPosition(cc.p(iconImgSize.width/2, iconImgSize.height/2))
	    iconImg:addChild(iconCell.awardBgImg)
        local data = self.rolecards[index] 
        item:setName("roleselectcell_" .. index)
        self:updatecell(item:getChildByName("bg_img"),data,index)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(item)
        item:setPosition(cc.p(w*0.5,h*0.5))
    end
end

function RoleSelectListOutSideUI:updatecell( parent,obj,pos )
   
	self.nor_pl = parent:getChildByName('nor_pl')
	local iconbg = parent:getChildByName('icon_img')

	local iconbigbg = iconbg:getChildByName('award_bg_img')
	local icon = iconbigbg:getChildByName('award_img')
	local objtemp  = RoleData:getRoleInfoById(obj:getId())
	ClassItemCell:updateItem(iconbigbg, objtemp, 2)

	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.soldiertypeimg = parent:getChildByName('soldiertype_img')

	self.ownTx = self.nor_pl:getChildByName('own_tx')
	self.ownTx:setString(GlobalApi:getLocalStr_new("ROLE_SELECT_INFO2")..obj:getNum())

	self.funcbtn = self.nor_pl:getChildByName('func_btn')
    self.funcbtn:setPropagateTouchEvents(false)
    local tx =self.funcbtn:getChildByName('btn_tx')
    local btnStr = ''
    if self.type == HANDLE_ROLE.ASSIST then
		btnStr = GlobalApi:getLocalStr_new('ROLE_SELECT_INFO3')
	elseif self.type == HANDLE_ROLE.CHANGE then
		btnStr = GlobalApi:getLocalStr_new('ROLE_SELECT_INFO4')
	end
	tx:setString(btnStr)

	if obj.isFate then
		self.funcbtn:setVisible(false)
		ShaderMgr:setGrayForWidget(icon)
		ShaderMgr:setGrayForWidget(iconbigbg)
	else
		self.funcbtn:setVisible(true)
		ShaderMgr:restoreWidgetDefaultShader(icon)
		ShaderMgr:restoreWidgetDefaultShader(iconbigbg)
	end

	if obj:getId() ~= 0 then
		self.name:setString(objtemp:getName())
		self.name:setTextColor(objtemp:getNameColor())
		self.name:enableOutline(objtemp:getNameOutlineColor(), 2)
		self.soldiertypeimg:loadTexture('uires/ui_new/common/soldier_'..obj:getSoldierId()..'.png')
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
	end

	parent:setTouchEnabled(true)
	parent:setSwallowTouches(false)

	self.funcbtn:addClickEventListener(function (sender, eventType)
		local oldobj = clone(RoleData:getRoleByPos(RoleMgr:getSelectRolePos()))
		local function exchange()
			local args = {
				pos = RoleMgr:getSelectRolePos(),
	            hid = obj:getId()
			}

			MessageMgr:sendPost("exchange", "hero", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					local awards = jsonObj.data.awards
					GlobalApi:parseAwardData(awards)
					local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end

                    if awards then
	                    for k,v in pairs (awards) do
	                    	if v[1] == 'dress' then
	                    		local obj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
	                    		obj:cleanSoldierDress()
	                    		break
		                    end
	                    end
	                end

					RoleData:exchangeRole(RoleMgr:getSelectRolePos(),obj:getId(),false)

					RoleMgr:setCurHeroChange(true)

					if self.type == HANDLE_ROLE.ASSIST then
						RoleMgr:updateRoleList(true)
						local obj = RoleData:getRoleByPos(pos)
						obj:setFightForceDirty(true)
						RoleData:getFightForce()
					else
						local orirole = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		                if orirole ~= nil then
		                	orirole:cleanupAssist()
		                end
		                RoleMgr:updateRoleList(true)
						RoleMgr:updateRoleMainUI()
					end
					hookheromgr:updateHero()
					RoleMgr:hideRoleSelectListOutSide()
				elseif code == 101 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_SELECT_INFO5'), COLOR_TYPE.RED)
				end
			end)
		end
		local role = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		if role and role.hid ~= 0 then
			RoleMgr:showRoleExchange(exchange)
		else
			exchange()
		end
	end)
end

return RoleSelectListOutSideUI