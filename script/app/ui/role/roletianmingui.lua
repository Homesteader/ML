local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")

local RoleTianmingUI = class("RoleTianmingUI", ClassRoleBaseUI)
local maxlv = #GameData:getConfData('destiny')
local MAXDELTA =0.05
local leftPosX,centerPosX,offsetX = 16,110,46
local skillarr = {
	lvtx = nil,
	skillimg = nil,
	nametx = nil,
}

function RoleTianmingUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roletianmingpanel.csb")
	self.panel:setName('role_tianming_panel')
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')

	--属性
	local attrbg = self.nor_pl:getChildByName('attr_bg')
	self.attrArrowImg = attrbg:getChildByName('arrow')
	self.attarr = {}
	for i=1,4 do
		local curattrtx = attrbg:getChildByName('attr_tx_' .. i)
		local nextattrtx = attrbg:getChildByName('next_attr_tx_' .. i)
		local attantx = attrbg:getChildByName('attr_num_' .. i)
		local attbntx = attrbg:getChildByName('next_attr_num_' .. i)
		local arrowimg = attrbg:getChildByName('attr_up_img' .. i)
		
		local arr = {}
		arr.curAttrName = curattrtx
		arr.curAttrValue = attantx
		arr.nextAttrName = nextattrtx
		arr.nextAttrValue = attbntx
		arr.arrowimg = arrowimg
		self.attarr[i] = arr
	end

	--技能
	local activetx = self.nor_pl:getChildByName('skill_info_tx')
	activetx:setString(GlobalApi:getLocalStr_new('ROLE_TM_INFO'))
	self.skillaarr = {}
	for i=1,2 do
		local skillinfo = {}
		local skillbg = self.nor_pl:getChildByName('skill_'..i..'_img')
		skillinfo.bg = skillbg
		skillinfo.lvatx = skillbg:getChildByName('lva_tx')
		skillinfo.nametx = skillbg:getChildByName('name_tx')
		skillinfo.skillimg = skillbg:getChildByName('skill_img')
		skillinfo.skillimg:ignoreContentAdaptWithSize(true)
		self.skillaarr[i] = skillinfo
	end

	self.curTitleTx = self.nor_pl:getChildByName('cur_title')
	--底部控件显示
	self.bottombg = self.nor_pl:getChildByName('di')
	self.maximg = self.nor_pl:getChildByName('max_img')

	local probabilityTx = self.bottombg:getChildByName('uppercent_tx')
	probabilityTx:setString(GlobalApi:getLocalStr_new("ROLE_TM_INFO2"))
	self.probability = self.bottombg:getChildByName('uppercent_num')
	self.neednum = self.bottombg:getChildByName('need_tx')
	local barbg = self.bottombg:getChildByName('bar_bg')
	self.bartx = barbg:getChildByName('bar_tx')
	self.bar = barbg:getChildByName('bar')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(7,6,1,1))
	
	self.istouch = false
	self.tiemdelta = 0
	self.obj = nil
	self.num = 0  --长摁中计算的消耗次数
	self.energy = 0 --自己计算的剩余能量
	self.level = 0  --自己计算的等级
	self.lvbtn = self.bottombg:getChildByName('lvup_btn')
	self.lvbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			local destinyconf =GameData:getConfData('destiny')[self.obj:getDestiny().level]
			local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
			local materialobj = BagData:getMaterialById(award:getId())
			if materialobj == nil then
				promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_TM_INFO4'),COLOR_TYPE.RED)
				GetWayMgr:showGetwayUI(award,true)
				return
			else
				local costnum =	award:getNum()
				local havenum = materialobj:getNum()
				if costnum > havenum then
					promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_TM_INFO4'),COLOR_TYPE.RED)
					GetWayMgr:showGetwayUI(award,true)
				else
					-- add effect
					if self.animation1 == nil then
						self.animation1 = GlobalApi:createLittleLossyAniByName("tianming_dragon_00")
						local dsz = barbg:getContentSize()
						self.animation1:setPosition(cc.p(dsz.width / 2, dsz.height / 2 + 22))
						self.animation1:setAnchorPoint(cc.p(0.5, 0.5))
						self.animation1:getAnimation():setSpeedScale(1)
						self.animation1:getAnimation():playWithIndex(0,-1,-1)
						barbg:addChild(self.animation1, -1)
					end
					self.animation1:setScale(0.85)
					self.animation1:setOpacity(0)
					self.animation1:stopAllActions()
					self.animation1:runAction(cc.FadeIn:create(0.5))

					if self.animation2 == nil then
						self.animation2 = GlobalApi:createLittleLossyAniByName("tianming_soul_00")
						self.animation2:setAnchorPoint(cc.p(0.5, 0.5))
						self.animation2:getAnimation():setSpeedScale(1)
						self.animation2:getAnimation():playWithIndex(0,-1,-1)
						UIManager:addAction(self.animation2)
						local barsz = self.bar:getContentSize()
						local x2 = self.bar:getPercent() * barsz.width / 100
						local y2 = barsz.height / 2
						local pos2 = self.bar:convertToWorldSpace(cc.p(x2 - 23, y2))
						self.animation2:setPosition(cc.p(pos2.x, pos2.y))
					end

		   			self.istouch = true
		   			self.tiemdelta = 0
		   			local fate = self.obj:getDestiny()
		   			self.energy = fate.energy
		   			self.level = fate.level
		   		end
	   		end
   		elseif eventType ==  ccui.TouchEventType.ended or eventType ==  ccui.TouchEventType.canceled then
   			if self.animation1 ~= nil then
	   			self.animation1:stopAllActions()
	   			self.animation1:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), 
	   				cc.CallFunc:create(function()
	   						self.animation1:removeFromParent()
	   						self.animation1 = nil
	   					end)))
   			end
   			if self.animation2 ~= nil then
	   			self.animation2:removeFromParent()
				self.animation2 = nil
			end

   			self.istouch = false
   			if self.num > 0 then
				self:lvUpPost()
			end
   		end
	end)
	self.havenum = self.lvbtn:getChildByName('num_tx')
	self.panel:scheduleUpdateWithPriorityLua(function (dt)
			self:updatepush(dt)
		end, 0)

	self.animation1 = nil
	self.animation2 = nil
end

function RoleTianmingUI:lvUpPost()
	if self.animation1 ~= nil then
		self.animation1:stopAllActions()
		self.animation1:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), 
			cc.CallFunc:create(function()
					self.animation1:removeFromParent()
					self.animation1 = nil
				end)))
	end
	if self.animation2 ~= nil then
		self.animation2:removeFromParent()
		self.animation2 = nil
	end

	self.lvbtn:setTouchEnabled(false)
	self.istouch = false
	local args = {
		num = self.num,
		pos = self.obj:getPosId(),
	}
	MessageMgr:sendPost("upgrade_destiny", "hero", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
			local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			local cd = self.obj:getDestiny()
			if cd.level < jsonObj.data.level then
				RoleMgr:showSkillUpgrade(self.obj,
					function (  )
						self.obj:setDestiny(jsonObj.data.level,jsonObj.data.energy,jsonObj.data.expect)
						self.obj:setFightForceDirty(true)
						RoleMgr:updateRoleList()
						RoleMgr:updateRoleMainUI()
						self.num = 0
						self.level =  jsonObj.data.level
						self.energy = jsonObj.data.energy
						self.tiemdelta = 0
						self.lvbtn:setTouchEnabled(true)
					end)
				return
			else
				self.obj:setDestiny(jsonObj.data.level,jsonObj.data.energy,jsonObj.data.expect)
				self.level =  jsonObj.data.level
				self.energy = jsonObj.data.energy
			end
			self.obj:setDestiny(jsonObj.data.level,jsonObj.data.energy,jsonObj.data.expect)
			self.obj:setFightForceDirty(true)
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_TM_LVUP_FAIL'), COLOR_TYPE.RED)
		end
		RoleMgr:updateRoleList()
		RoleMgr:updateRoleMainUI()
		self.num = 0
		self.energy = 0
		self.level = 0
		self.tiemdelta = 0
		self.lvbtn:setTouchEnabled(true)
	end)
end

function RoleTianmingUI:updatetitle(energyValue,hitTab)
	if energyValue <= hitTab[1] then
		self.probability:setString(GlobalApi:getLocalStr_new('ROLE_TM_PROBABILITY1'))
	elseif energyValue >hitTab[1] and energyValue <=hitTab[2] then
		self.probability:setString(GlobalApi:getLocalStr_new('ROLE_TM_PROBABILITY2'))
	elseif energyValue >hitTab[2] and energyValue <=hitTab[3] then
		self.probability:setString(GlobalApi:getLocalStr_new('ROLE_TM_PROBABILITY3'))
	elseif energyValue >hitTab[3] and energyValue <=hitTab[4] then
		self.probability:setString(GlobalApi:getLocalStr_new('ROLE_TM_PROBABILITY4'))
	elseif energyValue >hitTab[4] then
		self.probability:setString(GlobalApi:getLocalStr_new('ROLE_TM_PROBABILITY5'))
	end
end

function RoleTianmingUI:updatebar(level,energy,need,have,oldenergy)
	local destinyconf =GameData:getConfData('destiny')[level]
	local percent =string.format("%.2f", (energy/destinyconf['maxEnergy'])*100)  
	self:updatetitle(energy,destinyconf.upgradeHint)
	self.bar:setPercent(percent)
	self.bartx:setString(GlobalApi:getLocalStr_new('ROLE_TM_INFO3') ..' ' .. energy ..'/' ..destinyconf['maxEnergy'])
	local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
	self.neednum:setString(GlobalApi:getLocalStr_new('ROLE_TM_INFO1')..award:getNum())
	if award:getId() == 300001 then
		self.lvbtn:loadTextureNormal('uires/ui_new/role/tm_btn1.png')
	elseif award:getId() == 300019 then
		self.lvbtn:loadTextureNormal('uires/ui_new/role/tm_btn1.png')
	end
	self.havenum:setString(have)
	if have < award:getNum() then
		self.havenum:setTextColor(cc.c3b(255,0,0))
	else
		self.havenum:setTextColor(cc.c3b(255,255,255))
	end
	if oldenergy and energy - oldenergy > 0 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_TM_INFO3') ..GlobalApi:getLocalStr_new('ROLE_TM_ADD_STR')..(energy - oldenergy),COLOR_TYPE.GREEN)
	end

	local barsz = self.bar:getContentSize()
	local x2 = percent * barsz.width / 100
	local pos = self.bar:convertToWorldSpace(cc.p(x2 - 23, 0))
	if	self.animation2 then
		self.animation2:setPositionX(pos.x)
	end
end

function RoleTianmingUI:onMoveOut()
end

function RoleTianmingUI:calFunction()
	local destinyconf =GameData:getConfData('destiny')[self.level]
	local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
	local materialobj = BagData:getMaterialById(award:getId())
	if materialobj == nil then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_TM_INFO4'),COLOR_TYPE.RED)
		return
	end
	local costnum =	award:getNum()
	local havenum = materialobj:getNum()
	
	if costnum <= havenum-self.num*costnum then
		if self.energy < destinyconf['minUpEnergy'] then
			self.num = self.num + 1
			local energy = clone(self.energy)
			self.energy = self.energy + destinyconf['getEnergy']
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum, energy)
			--print('self.energy===='..self.energy)
			return
		end

		if self.energy >= destinyconf['maxEnergy'] then
			local energy = clone(self.energy)
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum ,energy)
			self:lvUpPost()
			--print('self.energy===='..self.energy)
			return
		end
		--print('self.energy===='..self.energy)
		
		local lvupneedExp = self.obj:getDestiny().expect
		--print('lvupneedExp===='..lvupneedExp)
		if self.energy >= lvupneedExp then
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum )
			self:lvUpPost()
			return
		else
			self.num = self.num + 1
			local energy = clone(self.energy)
			self.energy = self.energy + destinyconf['getEnergy']
			if self.energy >= destinyconf['maxEnergy'] then
				self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum )
				self:lvUpPost()
				return
			end
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum ,energy)
		end
	else
		if self.num > 0 then
			self:lvUpPost()
		end
	end

	self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum )
end

function RoleTianmingUI:updatepush(dt)
	self.tiemdelta = self.tiemdelta + dt 
	if self.istouch and self.tiemdelta > MAXDELTA then
		--todo
		self:calFunction(self.obj)
		self.tiemdelta = 0
	end
end

function RoleTianmingUI:updateNorPanel(obj)

	local skilltab = obj:getSkillIdTab()
	local fate =obj:getDestiny()
	local curFateLv = fate.level
	local nextFateLv = fate.level+1
	if nextFateLv >= maxlv then
		nextFateLv = maxlv
	end

	local isMaxLv = curFateLv >= maxlv
	self.bottombg:setVisible(not isMaxLv)
	self.attrArrowImg:setVisible(not isMaxLv)
	self.maximg:setVisible(isMaxLv)

    local str1 = string.format(GlobalApi:getLocalStr_new('ROLE_TM_TITLE'),curFateLv)
    self.curTitleTx:setString(str1)

	local destinyconf =GameData:getConfData('destiny')[curFateLv]
	local destinyconfnext = GameData:getConfData('destiny')[nextFateLv]
    local skillconf = GameData:getConfData("skill")
    for i=1,#skilltab do
        local skill = skillconf[skilltab[i]]
        local skillName = skill['name']
        local skillicon ='uires/icon/skill/' .. skill['skillIcon']
        self.skillaarr[i].lvatx:setString('Lv.' .. nextFateLv)
        self.skillaarr[i].nametx:setString(skillName)
        self.skillaarr[i].skillimg:setScale(0.70)
        self.skillaarr[i].skillimg:loadTexture(skillicon)
        self:addEvent(self.skillaarr[i].bg,skilltab[i])
    end

    local baseatt = RoleData:getPosAttByPos(obj)
    local curattarr = {}
    curattarr[1] = math.floor(baseatt[1])
    curattarr[2] = math.floor(baseatt[4])
    curattarr[3] = math.floor(baseatt[2])
    curattarr[4] = math.floor(baseatt[3])
    self.curattarr = curattarr

    local tempobj = clone(obj)
    tempobj:setDestiny(nextFateLv,0,tempobj:getDestiny().expect)
    local baseatttemp = RoleData:CalPosAttByPos(tempobj,true)
    local nextattarr = {}
    nextattarr[1] = math.floor(baseatttemp[1])
    nextattarr[2] = math.floor(baseatttemp[4])
    nextattarr[3] = math.floor(baseatttemp[2])
    nextattarr[4] = math.floor(baseatttemp[3])
    self.nextattarr = nextattarr

    for i=1,4 do
    	self.attarr[i].curAttrName:setString(GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i))
    	self.attarr[i].curAttrValue:setString(curattarr[i])

    	local nextName = isMaxLv and '' or GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i)
        local nextValue = isMaxLv and '' or nextattarr[i]
		self.attarr[i].nextAttrName:setString(nextName)
		self.attarr[i].nextAttrValue:setString(nextValue)
		
		--提升图标位置
		local size = self.attarr[i].nextAttrValue:getContentSize()
        local posX = self.attarr[i].nextAttrValue:getPositionX()
        self.attarr[i].arrowimg:setPositionX(posX + size.width + 10)
        self.attarr[i].arrowimg:setVisible(not isMaxLv)
        
        --当前属性位置
        local posY = self.attarr[i].curAttrName:getPositionY()
        local posX = isMaxLv and centerPosX or leftPosX
        self.attarr[i].curAttrName:setPosition(posX, posY)
        self.attarr[i].curAttrValue:setPosition(posX+offsetX, posY)
    end

	local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
	self.neednum:setString(GlobalApi:getLocalStr_new('ROLE_TM_INFO1')..award:getNum())
	local materialobj = BagData:getMaterialById(award:getId())
	if materialobj then
		self.havenum:setString(materialobj:getNum())
		if materialobj:getNum() < award:getNum() then
			self.havenum:setTextColor(cc.c3b(255,0,0))
		else
			self.havenum:setTextColor(cc.c3b(255,255,255))
		end
	else
		self.havenum:setString("0")
	end
	local percent =string.format("%.2f", (fate.energy/destinyconf['maxEnergy'])*100)  
	self:updatetitle(fate.energy,destinyconf.upgradeHint)
	self.bar:setPercent(percent)
	self.bartx:setString(GlobalApi:getLocalStr_new('ROLE_TM_INFO3') ..' ' ..fate.energy ..'/' ..destinyconf['maxEnergy'])
	if award:getId() == 300001 then
		self.lvbtn:loadTextureNormal('uires/ui_new/role/tm_btn1.png')
	elseif award:getId() == 300019 then
		self.lvbtn:loadTextureNormal('uires/ui_new/role/tm_btn1.png')
	end
end

function RoleTianmingUI:update(obj)
	self.obj = obj
	self:updateNorPanel(obj)
end

function RoleTianmingUI:addEvent(parent,skillid,pos)
	parent:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
        	local size = parent:getContentSize()
			local x, y = parent:convertToWorldSpace(cc.p(parent:getPosition(size.width / 2, size.height / 2)))
  	    	TipsMgr:showRoleSkillTips(self.obj:getDestiny().level,skillid,cc.p(x,y),true)
         end
    end)
end

return RoleTianmingUI