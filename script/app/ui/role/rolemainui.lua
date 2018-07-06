local RoleInfo = require("script/app/ui/role/roleinfoui")
local RoleTupo = require("script/app/ui/role/roletupoui")

local RoleEquipSelect = require("script/app/ui/role/roleequipselectui")
local RoleEquipInfo = require("script/app/ui/role/roleequipinfoui")
local RoleTianmingUI = require("script/app/ui/role/roletianmingui")
local RoleSoldierUI = require("script/app/ui/role/rolesoldierui")
local RoleLvUpUI = require('script/app/ui/role/rolelvupui')
local RoleRiseStarUI = require('script/app/ui/role/rolerisestar')
local RoleGemUI = require('script/app/ui/role/rolegemui')
local RolePartUI = require('script/app/ui/role/rolepartui')
local RoleMasterUI = require('script/app/ui/role/rolemasterui')
local RoleSuitUI = require('script/app/ui/role/rolesuitui')
local RoleDestinyUI = require('script/app/ui/role/roledestinyui')				--缘分

local ClassItemCell = require('script/app/global/itemcell')
local RoleMainUI = class("RoleMainUI", BaseUI)
local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}

local defecanquipIcon = 'uires/ui_new/common/add_green.png'

local RolechildName = {
	[1] = 'TITLE_WJSX',
	[2] = 'TITLE_TP',
	[3] = 'TITLE_ZBXZ',
	[4] = 'TITLE_XB',
	[5] = 'TITLE_TM',
	[6] = 'TITLE_WJSX',
	[7] = 'TITLE_ZBXX',
	[8] = 'TITLE_WJXZ',
	[9] = 'TITLE_WJSJ',
	[10] = 'TITLE_ZBSX',
	[11] = 'TITLE_ZBCC',
	[12] = 'TITLE_BSXQ',
	[13] = 'TITLE_PZTS',
	[14] = 'TITLE_WJSX'
}
local MAXDELTA = 0.5

function RoleMainUI:ctor(pos,pltype,equippos)
	self.uiIndex = GAME_UI.UI_ROLEMAIN
	self.panelObjArr = {}
	self.currPanelObj = nil
	self.selecttype = nil
	self.bgimg = nil
	self.bgimg1 = nil
	self.bgimg2 = nil
	self.bgimg4 = nil
	self.soldiername = nil
	self.armsumname = nil
	self.fightforcebg = nil
	self.expbar = nil
	self.exptx = nil
	self.lv = nil
	self.anim_pl = nil
	self.select_img = nil
	self.action = ""
	self.equipTab = {}
    self.childPanelPos = 0
	self.currHid = 0
	self.obj =RoleData:getRoleByPos(pos)
	self.dirty = false
	self.onlychild = false
	self.paneltype = pltype or ROLEPANELTYPE.UI_RISESTAR
	self.cantouch = true
    self.pltype = pltype
    self.equippos = equippos or 0

    -- 英雄列表
    self.heroCellTab = {}
    self.currPos = pos or 1
end

function RoleMainUI:setDirty(onlychild)
	self.dirty = true
	self.onlychild = onlychild
end

function RoleMainUI:setUIBackInfo()
	UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_ROLEMAIN), function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr:PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.panelObjArr[ROLEPANELTYPE.UI_LVUP] then
				self.panelObjArr[ROLEPANELTYPE.UI_LVUP].firstState = false
			end
			RoleMgr:hideRoleMain()
		end
	end)
end

function RoleMainUI:onShow()
	self.currHid = self.obj:getId()
	--RoleMgr:setCurHeroChange(true)
	--小兵装备前往XX地方回来要刷新界面 突破界面也是
	if self.dirty or self.selecttype == ROLEPANELTYPE.UI_SOLDIER  
		or self.selecttype == ROLEPANELTYPE.UI_TUPO 
		or self.selecttype == ROLEPANELTYPE.UI_TIANMING 
		or self.selecttype == ROLEPANELTYPE.UI_RISESTAR 
		or self.selecttype == ROLEPANELTYPE.UI_LVUP then
		self.dirty = false
		self:update()
	end

	self:setUIBackInfo();
end

function RoleMainUI:swapTitle( idx )
	--self.title = self.bgimg4:getChildByName('type_tx')
	--self.title:setLocalZOrder(99999)
	--self.title:setString(GlobalApi:getLocalStr(RolechildName[idx]))
end

function RoleMainUI:setTitleName( str )
	--self.title = self.bgimg4:getChildByName('type_tx')
	--self.title:setString(str)
end

function RoleMainUI:init()
	local winSize = cc.Director:getInstance():getVisibleSize()

	self.bgimg = self.root:getChildByName("bg_img")
	self.bgimg1 = self.bgimg:getChildByName("bg_1_pl")
	self:adaptUI(self.bgimg, self.bgimg1)

	self:setUIBackInfo();

	-- 几个根节点
	self.frameImg = self.bgimg1:getChildByName('frame_img')
	self.roleModelBg = self.frameImg:getChildByName('role_model')
	self.partPl = self.bgimg1:getChildByName('part_pl')
	self.bgimg4 = self.bgimg1:getChildByName('role_info')

	local partpl_bg = self.partPl:getChildByName('bg_img')
	self.checkEquipBtn = partpl_bg:getChildByName('check_info_btn')
	self.checkBtnTx = self.checkEquipBtn:getChildByName("text")

	self.checkEquipBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			if self.paneltype == ROLEPANELTYPE.UI_PART then	
				self.childPanelPos = self.childPanelPos==0 and 1 or self.childPanelPos
				local equipObj = self.obj:getEquipByIndex(self.childPanelPos)
				if equipObj then
					self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO,self.obj,self.childPanelPos)
				else
					self:swappanel(ROLEPANELTYPE.UI_EQUIP,self.obj,self.childPanelPos)
				end
			else
				self:swappanel(ROLEPANELTYPE.UI_PART,self.obj,self.childPanelPos)
			end
		end
	end)

	--觉醒大师
	self.awakeMasterBtn = partpl_bg:getChildByName('awake_btn')
	self.awakeMasterBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_MASTER,self.obj)
		end
	end)

	--套装按钮
	self.suitBtn = partpl_bg:getChildByName('suit_btn')
	self.suitBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_SUIT,self.obj,self.childPanelPos)
		end
	end)

	self.partPl:setVisible(false)
	
	self.riseBg = self.roleModelBg:getChildByName("mingjiang_btn")
	self.riseStarBtn = self.riseBg:getChildByName("rise_btn")
	self.riseImg = self.riseBg:getChildByName('new_img')
	self.riseImg:setLocalZOrder(1)
	self.riseImg:setVisible(self.obj:isCanRiseStar())
	self.riseStarBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_RISESTAR,self.obj)
		 end
	end)

	-- 背景特效
	self.starBgImg = self.riseBg:getChildByName("effect_img")
	local size = self.riseBg:getContentSize()
	local ani = GlobalApi:createLittleLossyAniByName("ui_mj77")
	ani:setPosition(cc.p(size.width/2 + 4,size.height/2))
	ani:getAnimation():playWithIndex(0, -1, 1)
	ani:setName('ui_mj77')
	self.riseBg:addChild(ani,-1)
	self:refreshTitleStar()

	if self.paneltype == ROLEPANELTYPE.UI_RISESTAR then
		self.starBgImg:setVisible(false)
		ani:setVisible(true)
	else
		self.starBgImg:setVisible(false)
		ani:setVisible(false)
	end

	self.tabList = self.bgimg1:getChildByName('tab_list')
	self.tabArr = {}
	for i = 1,5 do
		self.tabArr[i] = {}
		self.tabArr[i].btn = self.tabList:getChildByName('tab_' .. i)
		self.tabArr[i].tx = self.tabArr[i].btn:getChildByName('func_tx')
		self.tabArr[i].tx:setString(GlobalApi:getLocalStr_new('ROLE_TAB_TEXT_' .. i))

		self.tabArr[i].btn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self:refreshTabState(i)
				if i == 1 then
					-- 装备
					local equipIndex = 1
					for i = 1,6 do	
						local equipObj = self.obj:getEquipByIndex(i)
						if equipObj then
							equipIndex = i
							break
						end
					end
					local posX,posY = self.equipTab[equipIndex].node:getPosition()
					self.chooseImg:setPosition(posX,posY)
					local equipObj = self.obj:getEquipByIndex(equipIndex)
					if equipObj then
						self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO,self.obj,equipIndex)
					else
						self:swappanel(ROLEPANELTYPE.UI_EQUIP,self.obj,equipIndex)
					end
				elseif i == 2 then
					--缘分
					self:swappanel(ROLEPANELTYPE.UI_DESTINY,self.obj)
				elseif i == 3 then
					-- 突破
					local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('reborn')
					local desc = ''
					local errCode = 0
					local str = ''
					local cityData = MapData.data[id]
					if isOpen then
						self:swappanel(ROLEPANELTYPE.UI_TUPO,self.obj)
					else
						if level then
			        		str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
			    		elseif cityData then
			        		desc = cityData:getName()
			        		str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
			    		else
			        		str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
			    		end

		        		if not isOpen and not isNotIn then
			        		promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			        		return
			    		end
			    	end
				elseif i == 4 then
					-- 军队
					self:swappanel(ROLEPANELTYPE.UI_SOLDIER,self.obj)
				elseif i == 5 then
					-- 天命
					local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('destiny')
					local desc = ''
					local errCode = 0
					local str = ''
					local cityData = MapData.data[id]
					if isOpen then
						self:swappanel(ROLEPANELTYPE.UI_TIANMING,self.obj)
					else
						if level then
			        		str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
			    		elseif cityData then
			        		desc = cityData:getName()
			        		str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
			    		else
			        		str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
			    		end

		        		if not isOpen and not isNotIn then
			        		promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			        		return
			    		end
					end
				end
			end
		end)
	end

	--部位/装备格子信息
	self.chooseImg = partpl_bg:getChildByName("choose_img")
	for i=1,6 do
		local armnode = partpl_bg:getChildByName('part_' .. i)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil, true)
		tab.awardBgImg:ignoreContentAdaptWithSize(true)    
        tab.awardBgImg.index = i	

		local nodeSize = armnode:getContentSize()
		tab.awardBgImg:setPosition(cc.p(nodeSize.width/2, nodeSize.height/2))
		tab.awardBgImg:setScale(0.85)
		tab.addImg:setVisible(false)
		tab.addImg:ignoreContentAdaptWithSize(true)
		local equiparr = {}
		equiparr.node = armnode
		equiparr.tab = tab
		self.equipTab[i] = equiparr
		armnode:addChild(tab.awardBgImg)
		
		self.equipTab[i].tab.awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
			if eventType == ccui.TouchEventType.ended then
				local posX,posY = self.equipTab[i].node:getPosition()
				self.chooseImg:setPosition(posX,posY)
				if self.paneltype == ROLEPANELTYPE.UI_PART then
					
					self:swappanel(ROLEPANELTYPE.UI_PART, self.obj, sender.index)
				elseif self.paneltype == ROLEPANELTYPE.UI_EQUIP_INFO or self.paneltype == ROLEPANELTYPE.UI_EQUIP then
					
					local equipObj = self.obj:getEquipByIndex(sender.index)
					if equipObj then
						self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO,self.obj,sender.index)
					else
						self:swappanel(ROLEPANELTYPE.UI_EQUIP,self.obj,sender.index)
					end
				elseif self.paneltype == ROLEPANELTYPE.UI_MASTER then
					self:swappanel(ROLEPANELTYPE.UI_PART, self.obj, sender.index)
				elseif self.paneltype == ROLEPANELTYPE.UI_SUIT then
					local equipObj = self.obj:getEquipByIndex(sender.index)
					if equipObj then
						self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO,self.obj,sender.index)
					else
						self:swappanel(ROLEPANELTYPE.UI_EQUIP,self.obj,sender.index)
					end
				end
			end
		end)
	end

	local namebg = self.frameImg:getChildByName('hero_name_bg')
	self.nameTx = namebg:getChildByName("hero_name_tx")
	namebg:setTouchEnabled(true)
	namebg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			TipsMgr:showProfessTips(self.obj)
		end
	end)

	self.type = namebg:getChildByName('hero_type_img')
	self.swapbtn = namebg:getChildByName("swap_hero_btn")
	self.swapbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			--self:swappanel(ROLEPANELTYPE.UI_SWAP_ROLE,self.obj)
			RoleMgr:showRoleSelectListOutSide(HANDLE_ROLE.CHANGE)
		end
	end) 

	local rolebg = self.roleModelBg:getChildByName('role_stand_img')
	self.anim_pl = rolebg:getChildByName('anm_pl')

	-- 强化按钮
	local detailsBtn = self.roleModelBg:getChildByName('details_btn')
	detailsBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_INFO,self.obj)
		end
	end)

	-- 战斗力
	self.fightforcebg = self.roleModelBg:getChildByName('fight_force_bg')
	--local leftLabel = cc.LabelAtlas:_create(RoleData:getPosFightForceByPos(self.obj), "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
	local leftLabel = cc.LabelBMFont:create()
    leftLabel:setFntFile('uires/ui_new/number/font_fightforce_1.fnt')
	leftLabel:setAnchorPoint(cc.p(0,0.5))
	leftLabel:setPosition(cc.p(60,18.5))
	self.fightforcebg:addChild(leftLabel)
	self.leftLabel = leftLabel

	-- 经验条
	local expbg = self.roleModelBg:getChildByName('exp_bar_bg')
	self.expbar = expbg:getChildByName('exp_bar')
    self.expbar:setScale9Enabled(true)
    self.expbar:setCapInsets(cc.rect(10,15,1,1))
	self.exptx = expbg:getChildByName('exp_tx')
	local lvbg = expbg:getChildByName('level_bg')
	self.lv = lvbg:getChildByName('level_tx')

	local lvlabel = cc.LabelAtlas:_create(level, "uires/ui/number/font_sz.png", 17, 23, string.byte('.'))
	lvlabel:setAnchorPoint(cc.p(0.5,0.5))
	lvlabel:setPosition(cc.p(0,0))
	self.lv:addChild(lvlabel)
	self.lvlabel = lvlabel

	local expbtn = expbg:getChildByName("add_exp_btn")
	self.expbtn = expbtn
	expbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_LVUP,self.obj)
		end
	end)

	self.objarr = {}
	for k, v in pairs(RoleData:getRoleMap()) do
		self.objarr[tonumber(k)] = v
	end

	RoleMgr:sortByQuality(self.objarr, ROLELISTTYPE.UI_ASSIST)
	RoleMgr:setCurHeroChange(true)
	self:swappanel(self.paneltype,self.obj)
	self:setAtt()

	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.swapbtn:setVisible(not self.obj:isJunZhu())
    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self:updatepush(dt)
    end, 0)

    -- 英雄列表
    --self.heroListSv = self.frameImg:getChildByName('hero_list_sv')
    self.heroPl = self.frameImg:getChildByName('hero_pl')

    --self:updateRoleList()
    --self.heroListSv:setVisible(false)

    self:initPos()
    self:resetHeroList()
    if self.num >= 3 then
    	self:registerHandler()
	end
end

function RoleMainUI:getRoleMainUIChangeBtn()
    return self.probtn,self.nextbtn
end

function RoleMainUI:getLv()
    return self.lvlabel:getString(),self.expbar:getPercent()

end

function RoleMainUI:autoExchangeEquip(equipidarr,equiparr,isinherit)
	local args = {
        eids = equipidarr,
        pos = self.obj:getPosId(),
        inherit = isinherit
    }
    local equips = {}
    for k, v in ipairs(equipidarr) do
    	if v > 0 and equiparr[k] then
	    	local equip = BagData:getEquipMapByType(equiparr[k])[v]
	    	equips[equiparr[k]] = equip
	    end
    end
    MessageMgr:sendPost("wear_all", "hero", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            if tonumber(isinherit) > 0 then
            	for i=1,6 do
            		local equipobj = self.obj:getEquipByIndex(i)
            		if equipobj and equipobj:getGodId() ~= 0 and equips[i] and equips[i]:getGodId() == 0  then
            			equips[i]:inheritGod(equipobj)
            		end
            		if equips[i] then
	            		RoleData:putOnEquip(self.obj:getPosId(), equips[i])
	            	end
            	end
                --self.equipObj:inheritGod(obj)
            else
            	for i=1,6 do
            		if equips[i] then
	            		RoleData:putOnEquip(self.obj:getPosId(), equips[i])
	            	end
            	end            	
            end
            GlobalApi:parseAwardData(jsonObj.data.awards)
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.obj:setFightForceDirty(true)
            --RoleData:putOnEquip(self.rolePos, self.equipObj)
            RoleMgr:updateRoleList()
            RoleMgr:updateRoleMainUI()
        end
    end)
end

function RoleMainUI:changePos( currpos,isright )

	self.anim_pl:setTouchEnabled(false)
	self.anim_pl:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function (  )
		self.anim_pl:setTouchEnabled(true)
	end)))

	self.posarr = {}
	for i=1,MAXROlENUM do
		self.posarr[i] = self.objarr[i]:getPosId()
	end
	local inposarrpos = 0
	for i=1,MAXROlENUM do
		if self.posarr[i] == currpos then
			inposarrpos = i
		end
	end
	local postemp = 0
	if isright then
		local pos = inposarrpos
		local needdoing = true
		while needdoing do
			pos = pos +1
			if pos > MAXROlENUM then
				pos = 1
			end
			if RoleData:getRoleByPos(self.posarr[pos]):getId() > 0 then
				RoleMgr:setSelectRolePos(self.posarr[pos])
				RoleMgr:updateRoleMainUI()
				RoleMgr:updateRoleList()
				needdoing = false
			end
		end
		postemp = pos
	else
		local pos = inposarrpos
		local needdoing = true
		while needdoing do
			pos = pos -1
			if pos < 1 then
				pos = MAXROlENUM
			end
			if RoleData:getRoleByPos(self.posarr[pos]):getId() > 0 then
				RoleMgr:setSelectRolePos(self.posarr[pos])
				RoleMgr:updateRoleMainUI()
				RoleMgr:updateRoleList()
				needdoing = false
			end
		end
		postemp = pos
	end

	if inposarrpos ~= postemp then
		RoleMgr:setCurHeroChange(true)
	end
	if (self.paneltype == ROLEPANELTYPE.UI_LVUP or self.paneltype == ROLEPANELTYPE.UI_SWAP_ROLE ) and self.obj:isJunZhu() then
		self:swappanel(ROLEPANELTYPE.UI_RISESTAR,self.obj)
	end

	self:update()
	-- self.obj:playSound('sound')
end

function RoleMainUI:swapanimation(spineAni)
	local seed = math.random(1, 5)
	if self.action ~= roleanim[seed] then
		self.action = roleanim[seed]
		spineAni:getAnimation():play(roleanim[seed], -1, -1)
	end
end

function RoleMainUI:createAnimation()
	self.anim_pl:removeAllChildren()
	local actionisruning = false
	local spineAni = GlobalApi:createLittleLossyAniByName(self.obj:getUrl() .. "_display", nil, self.obj:getChangeEquipState())
	-- ShaderMgr:setLightnessColorForArmature(spineAni, 'particle/wenli_00257.tga')
	local _,_,heroModelConf = GlobalApi:getHeroConf(self.obj:getId())
	if spineAni then
		local shadow = spineAni:getBone(self.obj:getUrl() .. "_display_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
			shadow:setIgnoreMovementBoneData(true)
		end
		spineAni:setPosition(cc.p(self.anim_pl:getContentSize().width/2,70+heroModelConf.uiOffsetY))
		spineAni:setLocalZOrder(999)
		self.anim_pl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		local beginPoint = cc.p(0,0)
		local endPoint = cc.p(0,0)
		self.anim_pl:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				beginPoint = sender:getTouchBeganPosition()
			end

			if eventType ==  ccui.TouchEventType.ended or 
				eventType == ccui.TouchEventType.canceled then
				endPoint = sender:getTouchEndPosition()
				local deltax = (beginPoint.x -endPoint.x)
				local deltay = math.abs(beginPoint.y -endPoint.y)
				if deltax > 25  then
					self:changePos(self.obj:getPosId(),true)
				elseif deltax <= -25 then
					self:changePos(self.obj:getPosId(),false)
				else
					if actionisruning  ~= true then
						actionisruning = true
						self:swapanimation(spineAni)
					end
				end
			end

		end) 

		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end
end

function RoleMainUI:setAtt(runfightforce)

	local talentStr = ''
	self.equipidarr, self.needinheritnum , self.inheriteritgold,self.equiparr = self.obj:getAutoExchangeEquips()
	if self.obj:getTalent() > 0 then
		talentStr = ' + ' .. self.obj:getTalent()
	end
	self.nameTx:setString(self.obj:getName()..talentStr)
	self.type:loadTexture('uires/ui/common/soldier_'..self.obj:getSoldierId()..'.png')
	self.type:ignoreContentAdaptWithSize(true)

	RoleData:runPosFightForceByPos(self.obj,self.leftLabel,'Label',1.0)

	local percent, curexp ,needexp = self.obj:getExpPercent()
	self.expbar:setPercent(percent)
	self.exptx:setString(percent .. '%')
	self.lv:setString('')
	self.lvlabel:setString(self.obj:getLevel())

	if RoleMgr:getCurHeroChange() then
		self:createAnimation()
		self.obj:playSound('sound')
		RoleMgr:setCurHeroChange(false)
	end

	RoleMgr:popupTips(self.obj)
    if self.obj:isJunZhu() then
        self:setJunZhuEXP()
    end
end

function RoleMainUI:createChildPanel(paneltype)
	local obj = nil
	if paneltype == ROLEPANELTYPE.UI_INFO then
		obj = RoleInfo.new(self.obj)
	elseif paneltype == ROLEPANELTYPE.UI_EQUIP then
		obj = RoleEquipSelect.new()
	elseif paneltype == ROLEPANELTYPE.UI_TUPO then
		obj = RoleTupo.new()
	elseif paneltype == ROLEPANELTYPE.UI_EQUIP_INFO then
		obj = RoleEquipInfo.new()
	elseif paneltype == ROLEPANELTYPE.UI_TIANMING then
		obj = RoleTianmingUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_SOLDIER then
		obj = RoleSoldierUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_LVUP then
		obj = RoleLvUpUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_GEM then
		obj = RoleGemUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_RISESTAR then
		obj = RoleRiseStarUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_PART then
		obj = RolePartUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_MASTER then
		obj = RoleMasterUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_SUIT then
		obj = RoleSuitUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_DESTINY then
		obj = RoleDestinyUI.new()
	end
	return obj
end

function RoleMainUI:childFadein()
	local time = 0.3
	local moveto = cc.MoveBy:create(time,cc.p(455, 0))
	return moveto
end

function RoleMainUI:chidlFadeOut(callback)
	local time = 0.3
	local moveto = cc.MoveBy:create(time,cc.p(-455, 0))
	local callbak = cc.CallFunc:create(callback)
	local sequence = cc.Sequence:create(moveto,callbak)
	return sequence
end

function RoleMainUI:showChildPanelByIdx(paneltype, pos, immediately)
	self:swappanel(paneltype, self.obj, pos, immediately)
	self:setAtt()
end

-- 刷新标签页状态
function RoleMainUI:refreshTabState(selectIndex)
	for i = 1,5 do
		if i == selectIndex then
			-- 选中状态
			self.tabArr[i].btn:loadTextureNormal('uires/ui_new/common/role_tab_select.png')
			self.tabArr[i].tx:setTextColor(cc.c4b(196,243,241,255))
			self.tabArr[i].tx:enableOutline(cc.c4b(46,89,81,255),1)
		else
			self.tabArr[i].btn:loadTextureNormal('uires/ui_new/common/role_tab_normal.png')
			self.tabArr[i].tx:setTextColor(cc.c4b(79,126,123,255))
			self.tabArr[i].tx:enableOutline(cc.c4b(28,40,42,255),1)
		end
	end
end

function RoleMainUI:swappanel(paneltype, obj, pos, immediately)

	self.cantouch = false
	self.tiemdelta = 0
    if self.pltype then
        pos = pos or self.equippos
        self.pltype = nil
    end
    pos = pos or self.equippos
	paneltype = paneltype or ROLEPANELTYPE.UI_SOLDIER
	self.paneltype = paneltype
	RoleMgr:swapChildName(paneltype)
	if self.selecttype == paneltype and self.childPanelPos == pos then
		if paneltype == ROLEPANELTYPE.UI_EQUIP_INFO or paneltype == ROLEPANELTYPE.UI_EQUIP then
			--同一个装备槽更换装备 or 切换英雄获取同一个装备槽的信息 不需要return
			self:refreshEquipPanel()
			if self.panelObjArr[paneltype] then
				self.panelObjArr[paneltype]:update(obj,pos)
			end
		end
		return	
	elseif self.selecttype == paneltype and self.childPanelPos ~= pos then
		self.childPanelPos = pos
		self.panelObjArr[paneltype]:update(obj,pos)
		self:setAtt()
		return
	end

	if paneltype == ROLEPANELTYPE.UI_EQUIP_INFO or paneltype == ROLEPANELTYPE.UI_PART or paneltype == ROLEPANELTYPE.UI_EQUIP then
		-- 装备界面
		self.partPl:setVisible(true)
		self.roleModelBg:setVisible(false)
		self.swapbtn:setVisible(false)
		self.chooseImg:setVisible(true)
		if paneltype == ROLEPANELTYPE.UI_PART then
			self:refreshPartPanel()
			self.checkBtnTx:setString(GlobalApi:getLocalStr_new("ROLE_EQUIP_TIP1"))
			self.awakeMasterBtn:setVisible(true)  
			self.suitBtn:setVisible(false)
		else
			self:refreshEquipPanel()
			self.checkBtnTx:setString(GlobalApi:getLocalStr_new("ROLE_EQUIP_TIP2"))
			self.awakeMasterBtn:setVisible(false)  
			self.suitBtn:setVisible(true)
		end
		
	elseif paneltype == ROLEPANELTYPE.UI_MASTER then

		self.chooseImg:setVisible(false)
		self.partPl:setVisible(true)
		self.roleModelBg:setVisible(false)
		self.swapbtn:setVisible(false)

	elseif paneltype == ROLEPANELTYPE.UI_SUIT then

		self.chooseImg:setVisible(false)
		self.partPl:setVisible(true)
		self.roleModelBg:setVisible(false)
		self.swapbtn:setVisible(false)

	else
		self.partPl:setVisible(false)
		self.roleModelBg:setVisible(true)
		self.swapbtn:setVisible(true)
	end

	self.selecttype = paneltype

	self.childPanelPos = pos
	local uiNode
	if self.panelObjArr[paneltype] == nil then
		release_print('@@@ paneltype = ' .. paneltype)
		self.panelObjArr[paneltype] = self:createChildPanel(paneltype)
		uiNode = self.panelObjArr[paneltype]:getPanel()
		uiNode:setPosition(cc.p(-230,260))
		self.bgimg4:addChild(uiNode)
	else
		uiNode = self.panelObjArr[paneltype]:getPanel()
		uiNode:setPosition(cc.p(-230,260))
	end

	self.panelObjArr[paneltype]:setVisible(true)
	uiNode:setLocalZOrder(11)

	immediately = true
	if immediately then -- 如果不播动画
		uiNode:setPosition(cc.p(205, 270))
		if self.currPanelObj then
			self.currPanelObj:onMoveOut()
			self.currPanelObj:getPanel():setLocalZOrder(10)
			self.currPanelObj:setPosition(cc.p(-230,260))
			self.currPanelObj:setVisible(false)
		end
		self.currPanelObj = self.panelObjArr[paneltype]
	end

	self.panelObjArr[paneltype]:update(obj,pos)
	local ani = self.riseBg:getChildByName('ui_mj77')
	if self.paneltype == ROLEPANELTYPE.UI_RISESTAR then
		self.starBgImg:setVisible(false)
		ani:setVisible(true)
	else
		self.starBgImg:setVisible(false)
		ani:setVisible(false)
	end
end

-- 设置君主经验条
function RoleMainUI:setJunZhuEXP()
    local level = UserData:getUserObj().level
    if level >= 100 then
        return
    end
    local curlvexp = UserData:getUserObj().xp -- 现在拥有的经验值
    local lvupneedxp = GameData:getConfData('level')[level + 1].exp
    local percent = string.format("%.2f", curlvexp/lvupneedxp*100)

	self.expbar:setPercent(percent)
    self.exptx:setString(percent .. '%')
end

function RoleMainUI:setEXP()
    if self.obj:getLevel() >= 100 then
        return
    end

    require('script/app/utils/scheduleActions'):remove(self.expbar)

    self.lvlabel:setString(self.obj:getLevel())
    local percent, curexp ,needexp = self.obj:getExpPercent()
    --print('rrrrrrrrrrrrrrrrrrrrr' .. percent)
	self.expbar:setPercent(percent)
	self.exptx:setString(percent .. '%')

    
end


function RoleMainUI:updateOutSide()
	self.obj:stopSound('sound')
	self.obj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
	self:setAtt()

	-- fucking JunZhu special
	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.swapbtn:setVisible(not self.obj:isJunZhu())
	self.currPanelObj:update(self.obj, self.childPanelPos)
end

-- 刷新头衔星星
function RoleMainUI:refreshTitleStar( )
	local quality = self.obj:getHeroQuality()
	local conf = GameData:getConfData('heroquality')[quality]

	self.riseStarBtn:loadTextureNormal('uires/ui_new/role/flag_'..conf.quality..'.png')

	for i=1,3 do
		local starImg = self.riseBg:getChildByName('star_'..i..'_img')
		if conf.star >= i then
			starImg:loadTexture('uires/ui_new/common/star_awake.png');
		else
			starImg:loadTexture('uires/ui_new/common/star_awake_bg.png');
		end
	end
end

function RoleMainUI:update()
	if not self.onlychild then
		self.obj:stopSound('sound')
		self.obj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		self:setAtt()
	else
		self.onlychild = false
	end

	-- JunZhu special
	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.swapbtn:setVisible(not self.obj:isJunZhu())

	if self.paneltype == ROLEPANELTYPE.UI_PART then
		self:refreshPartPanel()
	elseif self.paneltype == ROLEPANELTYPE.UI_EQUIP_INFO or self.paneltype == ROLEPANELTYPE.UI_EQUIP then
		local equipObj = self.obj:getEquipByIndex(self.childPanelPos)
		if equipObj then
			self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO,self.obj,self.childPanelPos)
		else
			self:swappanel(ROLEPANELTYPE.UI_EQUIP,self.obj,self.childPanelPos)
		end
	elseif self.paneltype == ROLEPANELTYPE.UI_MASTER then
		self:refreshPartPanel()
	elseif self.paneltype == ROLEPANELTYPE.UI_SUIT then
		self:refreshEquipPanel()
	end

	self.currPanelObj:update(self.obj, self.childPanelPos)
	self:refreshTitleStar()

	local ani = self.riseBg:getChildByName('ui_mj77')
	if self.paneltype == ROLEPANELTYPE.UI_RISESTAR then
		self.starBgImg:setVisible(false)
		ani:setVisible(true)
	else
		self.starBgImg:setVisible(false)
		ani:setVisible(false)
	end

	self.riseImg:setVisible(self.obj:isCanRiseStar())
	self:updateRoleCellByPosID(self.obj:getPosId())
end

function RoleMainUI:lvUpdate()
	if not self.onlychild then
		self.obj:stopSound('sound')
		self.obj =RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		self.equipidarr, self.needinheritnum , self.inheriteritgold,self.equiparr = self.obj:getAutoExchangeEquips()

	    RoleData:runPosFightForceByPos(self.obj,self.leftLabel,'Label',1.0)
	    local percent, curexp ,needexp = self.obj:getExpPercent()
	    self.expbar:setPercent(percent)
	    self.exptx:setString(percent .. '%')
	    self.lv:setString('')
	    self.lvlabel:setString(self.obj:getLevel())

	    if self.obj:isTupo() then
		    self.lvinfo:setVisible(true)
	    else
		    self.lvinfo:setVisible(false)
	    end

	    if self.obj:isSoldierCanLvUp() then
		    self.soldierinfo:setVisible(true)
	    elseif self.obj:isSoldierSkillCanLvUp() then
		    self.soldierinfo:setVisible(true)
	    else
		    self.soldierinfo:setVisible(false)
	    end
	    self.select_img:setVisible(false)
	    if self.childPanelPos ~= 0 then
		    self.select_img:setVisible(true)
	    end

	    RoleMgr:popupTips(self.obj)

        if self.obj:isJunZhu() then
            self:setJunZhuEXP()
        end

	else
		self.onlychild = false
	end
	self.currPanelObj:update(self.obj, self.childPanelPos)

end


function RoleMainUI:updatelvbar(oldlv,percent,level,index,callBack)
    --local lastLv = self.lvlabel:getString()
    --self.lvlabel:setString(math.max(tonumber(lastLv),oldlv))
    self.lvlabel:setString(oldlv)
    --print('LLLLLLLLLLLL' .. oldlv .. 'NNNNNNNNN' .. level)
    --if level < oldlv then
        --return
    --end

	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.leftLabel:setString(RoleData:getPosFightForceByPos(self.obj))
	--self.expbar:setPercent(percent)
	-- GlobalApi:runExpBar(self.expbar, 0.2, level-oldlv+1, tonumber(percent),function (lv)
	-- 	self.lvlabel:setString(level-lv+1)
	-- end,self.exptx)
	require('script/app/utils/scheduleActions'):runExpBar(
		self.expbar, 
		0.2, 
		level - oldlv + 1, 
		tonumber(percent),
		function (e)
			if e.status == SAS.START then
				self.exptx:setScale(1.2)
			elseif e.status == SAS.FRAME then
				local p = string.format('%.2f', e.percent) 
				self.exptx:setString(p .. '%')
			elseif e.status == SAS.SINGLE_END then
                if index and index == 1 then
                else
                    RoleMgr:playRoleUpgradeEffect()
                end
                
				local lv = e.count
				self.lvlabel:setString(level - lv + 1)
				local p = string.format('%.2f', e.percent) 
				self.exptx:setString(p .. '%')
			elseif e.status == SAS.END then
				local p = string.format('%.2f', e.percent) 
				self.exptx:setString(p .. '%')
				self.exptx:setScale(1)
                if callBack then
                    callBack()
                end
                
			end
		end)
	self.lv:setString('')
	
end

function RoleMainUI:hideChildPanelByIdx(idx)
	if self.panelObjArr[idx] then
		self.panelObjArr[idx]:setVisible(false)
		self.panelObjArr[idx]:getPanel():runAction(self:chidlFadeOut(function()
		end))
		self.selecttype = nil
		self.currPanelObj = nil
	end
end

function RoleMainUI:getExpBarPos()
	local size = self.expbar:getContentSize()
	local pos = self.expbar:convertToWorldSpace(cc.p(self.expbar:getPosition(size.width / 2, size.height / 2)))
	local x = pos.x + size.width / 2
	return x,pos.y
end

function RoleMainUI:onShowUIAniOver()
	-- self.obj:playSound('sound')
end

function RoleMainUI:onClose()
	self.obj:stopSound('sound')
end

function RoleMainUI:playFateGuild()
	if self.panelObjArr[ROLEPANELTYPE.UI_INFO] ~= nil then
		self.panelObjArr[ROLEPANELTYPE.UI_INFO]:playGuild()
	end
end

function RoleMainUI:stopFateGuild()
	if self.panelObjArr[ROLEPANELTYPE.UI_INFO] ~= nil then
		self.panelObjArr[ROLEPANELTYPE.UI_INFO]:stopGuild()
	end	
end

function RoleMainUI:updatepush(dt)
    self.tiemdelta = self.tiemdelta + dt 
    if self.tiemdelta > MAXDELTA then
        self.tiemdelta = 0
        self.cantouch = true
    end
end

function RoleMainUI:showHeroInfo(posId)
    self.anim_pl:setTouchEnabled(false)
	self.anim_pl:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function (  )
		self.anim_pl:setTouchEnabled(true)
	end)))

	RoleMgr:setCurHeroChange(true)

    if RoleData:getRoleByPos(posId):getId() > 0 then
		RoleMgr:setSelectRolePos(posId)
		RoleMgr:updateRoleMainUI()
		RoleMgr:updateRoleList()
	end

    if (self.paneltype == ROLEPANELTYPE.UI_LVUP or self.paneltype == ROLEPANELTYPE.UI_SWAP_ROLE ) and self.obj:isJunZhu() then
		self:swappanel(ROLEPANELTYPE.UI_RISESTAR,self.obj)
	end
end

-- 刷新英雄列表
function RoleMainUI:updateRoleList()
    self.heroListSv:setScrollBarEnabled(false)
	self.heroListSv:setInertiaScrollEnabled(true)
	self.heroListSv:removeAllChildren()

    local rolelistsvcontentWidget = ccui.Widget:create()
    self.heroListSv:addChild(rolelistsvcontentWidget)
    rolelistsvcontentWidget:removeAllChildren()

    local rolenum = RoleData:getRoleNum()
    for i = 1, rolenum do
    	local roleObj = RoleData:getRoleByPos(i)
    	if roleObj and tonumber(roleObj:getId()) > 0 then
            -- 创建一个节点
    		local node = cc.CSLoader:createNode("csb/rolemain_cell.csb")
	        local bgimg = node:getChildByName("bg_img")
	        bgimg:removeFromParent(false)
            bgimg:addClickEventListener(function ()            
                local posid = roleObj:getPosId();
                if self.curSelectPosId ~= nil and self.curSelectPosId == posid then
                    return
                end

                self:showHeroInfo(posid)
                self.curSelectPosId = posid;

                -- 隐藏上一次选中状态
                if self.curSelectNode ~= nil then
                	self.curSelectNode:loadTexture('uires/ui_new/role/role_cell_bg.png')
                	self.curSelectNode:setScale(0.8)
                end

                -- 设置新的选中状态
                self.curSelectNode = bgimg;
                self.curSelectNode:loadTexture('uires/ui_new/role/role_cell_bg_select.png')
                self.curSelectNode:setScale(1)
            end)

            -- 设置英雄节点信息
            self.heroCellTab[i]= ccui.Widget:create()
            bgimg:setAnchorPoint(cc.p(0.5,0))
	        self.heroCellTab[i]:addChild(bgimg)
            self.heroCellTab[i].bg = bgimg
	        self:updateRoleCellInfo(bgimg, roleObj)

            local contentsize = bgimg:getContentSize()
	        if math.ceil(i * (contentsize.width+5)) > self.heroListSv:getContentSize().width then
	            self.heroListSv:setInnerContainerSize(cc.size(i * (contentsize.width + 5), contentsize.height))
	        end

	        local posx = (i - 1) * (contentsize.width + 5) + contentsize.width / 2
	        self.heroCellTab[i]:setPosition(cc.p(posx, 0))
	        rolelistsvcontentWidget:addChild(self.heroCellTab[i])
	        rolelistsvcontentWidget:setPosition(cc.p(0, 0))

            -- 设置初始选中状态
            if self.obj ~= nil and self.obj:getPosId() == roleObj:getPosId() then
                self.curSelectNode = bgimg;
                self.curSelectNode:loadTexture('uires/ui_new/role/role_cell_bg_select.png')
                self.curSelectNode:setScale(1)
                self.curPos = roleObj:getPosId()
            end
    	end
    end
end

function RoleMainUI:updateRoleCellInfo(cell, roleObj)
	cell:setScale(0.8)
    local roleicon = cell:getChildByName('icon_img')
    local levelBg = cell:getChildByName('level_bg_img')
    local rolelvtx = levelBg:getChildByName('level_tx')
    local heroType = cell:getChildByName('type_img')

    -- 加载头像
    roleicon:loadTexture(roleObj:getIcon())
    rolelvtx:setString("Lv " .. tostring(roleObj:getLevel()))
    heroType:loadTexture('uires/ui/common/soldier_'..roleObj:getSoldierId()..'.png')
    levelBg:loadTexture(COLOR_NAME[roleObj:getQuality()])
end

-- 刷新指定posid的英雄信息
function RoleMainUI:updateRoleCellByPosID(posid)
    local cell = self.imgs[posid]
    local roleObj = RoleData:getRoleByPos(posid)
    self:updateRoleCellInfo(cell, roleObj)

    cell:setScale(1)

    release_print('hero_name = ' .. roleObj:getName())
end

function RoleMainUI:setPartAwakeLevel(pos, level, maxAwake)
    local partObj = self.equipTab[pos].tab
    if partObj == nil then
        return
    end

    partObj.starLv:setVisible(true)
    partObj.starLv:setString(level)
    partObj.starImg:setVisible(true)
    ClassItemCell:setGodLight(partObj.awardBgImg, level, maxAwake)
end

function RoleMainUI:setPartGem(part_pos, gem_pos, gem)
    local partObj = self.equipTab[part_pos].tab
    if partObj == nil then
        return
    end

    local gemObj = partObj.gemArr[gem_pos]
    if gemObj == nil then
        return
    end

    local openCount = self.obj:getGemSlotCount(part_pos)

    if gem_pos <= openCount then
        gemObj:setVisible(true)
        if gem ~= nil then
            --gemObj:loadTexture(gem:getIcon())
            gemObj:loadTexture('uires/ui_new/common/gem_small.png')
        else
            gemObj:loadTexture('uires/ui_new/common/gem_small_bg.png')
            gemObj:setScale(1)
        end
    else
        gemObj:setVisible(false)
    end
end

function RoleMainUI:hideAllGems(part_pos)
    local partObj = self.equipTab[part_pos]
    if partObj == nil then
        return
    end
    for i = 1,4 do
        partObj.gemArr[i]:setVisible(false)
    end
end

function RoleMainUI:refreshPartPanel()

	for i = 1,6 do
		local partObj = self.obj:getPartByIndex(i)
		if partObj then
			ClassItemCell:updateItem(self.equipTab[i].tab, partObj, 1)
		end
	end

end

--刷新装备面板
function RoleMainUI:refreshEquipPanel()

	for i = 1,6 do	
		local equipObj = self.obj:getEquipByIndex(i)
		local ishaveeq,canequip = self.obj:isHavebetterEquip(i)	
		self.equipTab[i].tab.upImg:setVisible(false)
		if ishaveeq then
			if canequip then
				if equipObj then
					self.equipTab[i].tab.upImg:setVisible(true)
				else
					self.equipTab[i].tab.addImg:loadTexture(defecanquipIcon)
					self.equipTab[i].tab.addImg:setVisible(true)
				end
			else
				self.equipTab[i].tab.addImg:setVisible(false)
			end
        else
            self.equipTab[i].tab.addImg:setVisible(false)
		end

		--已经装备的装备
		if equipObj then
			ClassItemCell:updateItem(self.equipTab[i].tab, equipObj, 1)
			self.equipTab[i].tab.addImg:setVisible(false)
		else
			self.equipTab[i].tab.awardBgImg:loadTexture(DEFAULT)
			self.equipTab[i].tab.awardImg:loadTexture(DEFAULTEQUIP[i])
			self.equipTab[i].tab.cornerImg:setVisible(false)
			self.equipTab[i].tab.cornerImgR:setVisible(false)
			self.equipTab[i].tab.starImg:setVisible(false)
		end

	end

end

-- ========================================新版武将列表代码==========================================
-- 初始化武将节点位置
function RoleMainUI:initPos()
	self.num = RoleData:getFightRoleNum()
	--self.num = RoleData:getRoleNum()
	self.pos = {}
	self.lastSelectPos = nil
	self.maxLen = 100

	local halfNum = math.ceil(self.num/2)
	release_print('role num = ' .. self.num .. ', half = ' .. halfNum)

	local size = self.heroPl:getContentSize()
	local midWidth = size.width/2
	local midHeight = size.height/2

	for i = 1, self.num do
		if i <= halfNum then
			self.pos[i] = {pos = cc.p(midWidth + (i - 1)*105, (((i == 1) and midHeight) or midHeight - 10)), zorder = (((i == 1) and 3) or 1), scale = (((i == 1) and 1) or 0.7)}
		else
			self.pos[i] = {pos = cc.p(midWidth + (i - self.num - 1)*105, midHeight - 10), zorder = (((i == 1) and 3) or 1), scale = (((i == 1) and 1) or 0.7)}
		end
	end
end

-- 创建武将列表
function RoleMainUI:resetHeroList()
	self.imgs = {}
	self.heroPl:removeAllChildren()

    for i = 1, self.num do
    	local roleObj = RoleData:getRoleByPos(i)
    	if roleObj then
			-- 创建一个节点
    		local node = cc.CSLoader:createNode("csb/rolemain_cell.csb")
	        local bgimg = node:getChildByName("bg_img")
	        local scheduler = bgimg:getScheduler()
	        bgimg:removeFromParent(false)
            bgimg:addClickEventListener(function ()            
            	if eventType == ccui.TouchEventType.began then
            		AudioMgr.PlayAudio(11)
            	else 
            		release_print('++++++++++++++++++++++++++ ' .. i)
            		self.currPos = i
            		self.currPos1 = self.currPos

            		if self.lastSelectPos == nil or self.lastSelectPos ~= self.currPos then
						-- 刷新信息
                		self:showHeroInfo(self.currPos)
                		self.lastSelectPos = self.currPos

                		release_print('222222 showHeroInfo currPos = ' .. self.currPos)
            		end

            		self:setImgsPosition()
            	end
            end)

	        local index = (i - self.currPos) % self.num + 1

	        bgimg:setAnchorPoint(cc.p(0.5,0.5))
            bgimg:setSwallowTouches(false)	-- 鼠标事件不向下传递
            bgimg:setTouchEnabled(true)
            bgimg:setCascadeOpacityEnabled(true)	-- 子控件的透明度随父控件的透明度变化而变化

            self.heroPl:addChild(bgimg)

            self:updateRoleCellInfo(bgimg, roleObj)

            if i == self.currPos then
				bgimg:loadTexture('uires/ui_new/role/role_cell_bg_select.png')
			else
				bgimg:loadTexture('uires/ui_new/role/role_cell_bg.png')
			end

            bgimg:setPosition(self.pos[index].pos)
            bgimg:setLocalZOrder(self.pos[index].zorder)
            bgimg:setScale(self.pos[index].scale)

            self.imgs[i] = bgimg
        end
    end
end

-- 注册滑动处理
function RoleMainUI:registerHandler()
	local bgPanelPrePos = nil
    local bgPanelPos = nil
    self.isMove = false
    self.heroPl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
            	local isEnd = self:getMove(self.currPos, bgPanelPos, bgPanelPrePos)
            	if isEnd == false then
            		for i = 1, self.num do
            			local _, pos, scale, shade = self:getMove(i, bgPanelPos, bgPanelPrePos)
            			self.imgs[i]:setPosition(pos)
            			self.imgs[i]:setScale(scale)
            		end
            	else
			    	bgPanelPrePos = nil
			    	self:setImgsPosition()
			    	self.heroPl:setTouchEnabled(true)
            	end
            end
        else
            bgPanelPrePos = nil
            bgPanelPos = nil
            if eventType == ccui.TouchEventType.began then
            	AudioMgr.PlayAudio(11)
            	self.currPos1 = self.currPos
            	release_print('began self.currPos1 = ' .. self.currPos1)
            else
            	self.currPos = self.currPos1
            	release_print('currPos = ' .. self.currPos .. ', currPos1 = ' .. self.currPos1)

            	if self.lastSelectPos == nil or self.lastSelectPos ~= self.currPos then
					-- 刷新信息
                	self:showHeroInfo(self.currPos)
                	self.lastSelectPos = self.currPos

                	release_print('11111 showHeroInfo currPos = ' .. self.currPos)
            	end

            	if self.isMove == true then
            		self:setImgsPosition()
            	end

            	self.isMove = false
            end
        end
    end)
end

-- 松开鼠标的时候设置位置
function RoleMainUI:setImgsPosition()
	for i = 1, self.num do
		local index = (i - self.currPos) % self.num + 1

		-- 设置选中状态
		if i == self.currPos then
			self.imgs[i]:loadTexture('uires/ui_new/role/role_cell_bg_select.png')
		else
			self.imgs[i]:loadTexture('uires/ui_new/role/role_cell_bg.png')
		end

		self.imgs[i]:setPosition(self.pos[index].pos)
		self.imgs[i]:setLocalZOrder(self.pos[index].zorder)
		self.imgs[i]:setScale(((index == 1) and 1) or 0.7)
	end
end

function RoleMainUI:getMove(index, bgPanelPos, bgPanelPrePos)
	local bgPanelDiffPos = nil
	local isEnd = false
	local diffPosX = (bgPanelPos.x - bgPanelPrePos.x)/2
    local per = math.abs(diffPosX/self.maxLen)
    local per1 = 0
	local lePosX, lePosY, sPosX, sPosY, cPosX, cPosY, rePosX, rePosY
	local startIndex = (index - self.currPos) % self.num + 1
	local lEndIndex = (index - self.currPos - 1) % self.num + 1
	local rEndIndex = (index - self.currPos + 1) % self.num + 1

	lePosX = self.pos[lEndIndex].pos.x
	lePosY = self.pos[lEndIndex].pos.y
	rePosX = self.pos[rEndIndex].pos.x
	rePosY = self.pos[rEndIndex].pos.y
	sPosX = self.pos[startIndex].pos.x
	sPosY = self.pos[startIndex].pos.y

	cPosX = self.imgs[index]:getPositionX()
	cPosY = self.imgs[index]:getPositionY()

	local isBig = 1
	local diffPosX1 = 1
	local scale = 0.7
	local shade = 127.5
	if cPosX < sPosX then
		if diffPosX < 0 then
			bgPanelDiffPos = cc.p(per * (lePosX - sPosX), per * (lePosY - sPosY))
		else
			bgPanelDiffPos = cc.p(per * (sPosX - lePosX), per * (sPosY - lePosY))
		end
		isBig = self.currPos % self.num + 1
		diffPosX1 = lePosX - sPosX
	elseif cPosX > sPosX then
		if diffPosX < 0 then
			bgPanelDiffPos = cc.p(per * (sPosX - rePosX), per * (sPosY - rePosY))
		else
			bgPanelDiffPos = cc.p(per * (rePosX - sPosX), per * (rePosY - sPosY))
		end
		isBig = (self.currPos - 2) % self.num + 1
		diffPosX1 = rePosX - sPosX
	else
		if diffPosX < 0 then
			bgPanelDiffPos = cc.p(per*(lePosX - sPosX), per*(lePosY - sPosY))
			isBig = self.currPos%self.num + 1
			diffPosX1 = lePosX - sPosX
		else
			bgPanelDiffPos = cc.p(per*(rePosX - sPosX), per*(rePosY - sPosY))
			isBig = (self.currPos - 2)%self.num + 1
			diffPosX1 = rePosX - sPosX
		end
	end

	local pos = cc.pAdd(cc.p(cPosX,cPosY), bgPanelDiffPos)
	local diffLendX = pos.x - lePosX
	local diffLharfEndX = pos.x - ((lePosX + sPosX)/2)
	local diffRendX = pos.x - rePosX
	local diffRharfEndX = pos.x - ((rePosX + sPosX)/2)
	local diffStartX = pos.x - sPosX

	if diffPosX1 ~= 0 then
		per1 = (pos.x - sPosX)/diffPosX1
	end

	if index == self.currPos then
		scale = 1 - 0.3*per1
		shade = 127.5*per1
	elseif index == isBig then
		scale = 0.7 + 0.3*per1
		shade = 127.5 - 127.5*per1
	end

	shade = ((shade < 0 ) and 0) or shade
	local bCanMove = false
	if startIndex == 1 then
		if math.abs(diffStartX) > 0 and self.isMove == false then
			self.isMove = true
		end

		if (diffLendX >= 0 and diffRendX <= 0) then
			isEnd = false
		elseif diffLendX < 0 then
			self.currPos = self.currPos % self.num + 1
			isEnd = true
		elseif diffRendX > 0 then
			self.currPos = (self.currPos - 2)%self.num + 1
			isEnd = true
		end

		if isEnd == false then
			if diffLharfEndX < 0 then
				self.currPos1 = self.currPos%self.num + 1
			elseif diffRharfEndX > 0 then
				self.currPos1 = (self.currPos - 2)%self.num + 1
			else
				self.currPos1 = self.currPos
			end
		end
	end

    return isEnd,pos,scale,shade
end

return RoleMainUI
