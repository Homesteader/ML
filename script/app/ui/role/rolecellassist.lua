local RoleCellUI = class("RoleCellUI")
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

local defequipIcon = 'uires/ui_new/common/add_yellow_2.png'
local defecanquipIcon = 'uires/ui_new/common/add_green.png'

function RoleCellUI:ctor(parentUI, index, obj)
	self.parentUI = parentUI
	self.obj = obj
	self.nor_pl = nil     		--右边主panel
	self.openinfotx = nil 		--同norpanel同级的其他提示信息
	--self.openinfoImg = nil 		--同norpanel同级的其他提示信息
	self.equip_pl = nil			--装备panel	
	self.lv = nil				--等级
	self.soldiertypeimg = nil   --兵种类型
	self.name = nil				--武将名称
	self.equipTab = {}
	self.info = nil				--提示
	self.pos = self.obj:getPosId()
	self.index = index
	self.iscanmerge = false
	self:initPanel()
end

function RoleCellUI:initPanel()
	local panel = cc.CSLoader:createNode("csb/rolecellassist.csb")
	local bgimg = panel:getChildByName("bg_img")
	bgimg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(bgimg)
	self.panel:setName("rolecellassist_" .. self.index)
	self.nor_pl = bgimg:getChildByName('nor_pl')
	self.openinfotx = bgimg:getChildByName('openinfo_tx')

	self.headIcon = self.nor_pl:getChildByName("head_icon")

	self.frameBg = bgimg
	
	self.lockimg = bgimg:getChildByName("lock_img")
	self.addimg = bgimg:getChildByName("add_img")

	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.info = self.nor_pl:getChildByName('info_img')
	self.lv = namebg:getChildByName('lv_tx')
	self.soldiertypeimg = namebg:getChildByName('soldiertype_img')
	self.equip_pl = self.nor_pl:getChildByName('equip_pl')
	for i=1,6 do
		local node = self.equip_pl:getChildByName('node_' .. i)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
		tab.awardBgImg:ignoreContentAdaptWithSize(true)
		tab.awardImg:ignoreContentAdaptWithSize(true)
		local nodeSize = node:getContentSize()
		tab.awardBgImg:setPosition(cc.p(nodeSize.width/2, nodeSize.height/2))
		tab.upImg:setAnchorPoint(cc.p(1,1))
		tab.upImg:setPosition(cc.p(94,94))
		tab.upImg:setScale(1.5)
		tab.awardBgImg:setTouchEnabled(false)
		tab.awardBgImg:setScale(0.4)
		tab.addImg:ignoreContentAdaptWithSize(true)
		node:addChild(tab.awardBgImg)
		self.equipTab[i] = tab
	end
   	bgimg:setTouchEnabled(true)
   	local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    bgimg:addClickEventListener(function ()
    	if RoleData:getRoleByPos(self.pos):getId() > 0 then 
			RoleMgr:showRoleMain(self.obj:getPosId())
			RoleMgr:setSelectRolePos(self.obj:getPosId())
		else
			if UserData:getUserObj():getLv() >= GlobalApi:getAssistLvByNum(self.pos) then
				RoleMgr:showRoleSelectListOutSide(HANDLE_ROLE.ASSIST)
				RoleMgr:setSelectRolePos(self.obj:getPosId())
			else
				local s = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN') , GlobalApi:getAssistLvByNum(self.pos))
				self.openinfotx:setString(s)
			end
		end
    end)
end

function RoleCellUI:getPanel()
	return self.panel
end

function RoleCellUI:setVisible(vis)
	self.panel:setVisible(vis)
end


function RoleCellUI:upDateUI()
	if tonumber(self.obj:getId()) and tonumber(self.obj:getId()) > 0 then
		if  self.obj:getTalent() > 0  then
			self.name:setString(self.obj:getName().. ' +' .. self.obj:getTalent())
		else
			self.name:setString(self.obj:getName())
		end
		self.name:setTextColor(self.obj:getNameColor())
		self.name:enableOutline(self.obj:getNameOutlineColor(),2) 

		self.soldiertypeimg:loadTexture('uires/ui_new/common/soldier_'..self.obj:getSoldierId()..'.png')
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
		local ishavebetterarr = {}

		for i=1,6 do
			local ishaveeq,canequip = self.obj:isHavebetterEquip(i)
			local equipObj = self.obj:getEquipByIndex(i)
			if equipObj then	
				ClassItemCell:updateItem(self.equipTab[i], equipObj, 1)
				self.equipTab[i].starImg:setVisible(false)
				self.equipTab[i].addImg:setVisible(false)
				if ishaveeq and canequip then
					self.equipTab[i].upImg:setVisible(true)
					ishavebetterarr[i] = true 
				else
					self.equipTab[i].upImg:setVisible(false)
					ishavebetterarr[i] = false 
				end
				self.equipTab[i].cornerImg:setVisible(false)
				self.equipTab[i].cornerImgR:setVisible(false)
			else
				self.equipTab[i].starImg:setVisible(false)
			 	self.equipTab[i].awardBgImg:loadTexture(DEFAULT)
				self.equipTab[i].awardImg:loadTexture(DEFAULTEQUIP[i])
			 	if ishaveeq then
			 		self.equipTab[i].addImg:setVisible(true)
					self.equipTab[i].upImg:setVisible(false)
					if canequip then
						self.equipTab[i].addImg:loadTexture(defecanquipIcon) 
						ishavebetterarr[i] = true
					else
						self.equipTab[i].addImg:loadTexture(defequipIcon) 
						ishavebetterarr[i] = false
					end
				else
					self.equipTab[i].addImg:setVisible(false)
					self.equipTab[i].upImg:setVisible(false)
					ishavebetterarr[i] = false
				end
			end
		end

		for i=1,6 do
			if ishavebetterarr[i] == true then
				self.info:setVisible(false)
				break
			else
				self.info:setVisible(false)
			end
		end
		
		if self.obj:isTupo() then
			self.info:setVisible(true)
			return
		elseif self.obj:isSoldierCanLvUp() then
			self.info:setVisible(true)
			return
		elseif self.obj:isSoldierSkillCanLvUp() then
			self.info:setVisible(true)
			return
		elseif self.obj:isCanRiseStar() then
			self.info:setVisible(true)
			return
		else
			self.info:setVisible(false)
			return
		end
	end
end

function RoleCellUI:update(index,obj)

	if not obj then
		return
	end
	self.obj = obj
	self.pos = self.obj:getPosId()
	self.index = index
	self:setType()
end


function RoleCellUI:setType( )

	--有上阵英雄
	if self.obj:getId() ~= 0 then
		self.lv:setString("LV"..self.obj:getLevel())
		self.openinfotx:setString('')
		self.lockimg:setVisible(false)
		self.addimg:setVisible(false)
		local quality = self.obj:getQuality()
		self.frameBg:loadTexture(COLOR_ROLE_BG[quality])
		self.headIcon:loadTexture(self.obj:getIcon())
		self.nor_pl:setVisible(true)
		self.lv:setVisible(true)
	else
		self.nor_pl:setVisible(false)
		self.lv:setVisible(false)
		local lv = tonumber(UserData:getUserObj():getLv())
		local openLv = tonumber(GlobalApi:getAssistLvByNum(self.pos))
		local fitOpenLv = lv >= openLv
		self.addimg:setVisible(fitOpenLv)
		self.lockimg:setVisible(not fitOpenLv)
		if fitOpenLv then
			local allcards = BagData:getAllCards()
			local cardarr = {}
			for k, v in pairs(allcards) do
			 	if v:getId() < 10000 then
				 	local canassist = true
					for j = 1,MAXROlENUM do
						local hid = RoleData:getRoleByPos(j):getId()
						if hid == v:getId() then
							canassist = false
						end
					end
					if canassist then
			        	table.insert(cardarr, v)
					end
			    end
		    end
		    local num = #cardarr
		    if num > 0 then
				self.openinfotx:setString(GlobalApi:getLocalStr_new('STR_POSCANTOPEN2'))
				self.openinfotx:setTextColor(COLOR_TYPE.GREEN1)
				self.openinfotx:enableOutline(COLOROUTLINE_TYPE.GREEN1,2) 
			else
				self.openinfotx:setString(GlobalApi:getLocalStr_new('STR_POSCANTOPEN3'))
				self.openinfotx:setTextColor(COLOR_TYPE.YELLOW1)
				self.openinfotx:enableOutline(COLOROUTLINE_TYPE.YELLOW1,2)
			end
			
		else
			local s = string.format(GlobalApi:getLocalStr_new('STR_POSCANTOPEN1'),GlobalApi:getAssistLvByNum(self.pos))
			self.openinfotx:setString(s)
			self.openinfotx:setTextColor(COLOR_TYPE.RED1)
			self.openinfotx:enableOutline(COLOROUTLINE_TYPE.RED1,2)
		end
	end

	self:upDateUI()
end

return RoleCellUI