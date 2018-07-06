local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassItemObj = require('script/app/obj/itemobj')

local RoleRiseStarUI = class("RoleRiseStarUI", ClassRoleBaseUI)
local MAXDELTA = 0.2
local FIRSTDELT = 1.0
local INTERVEAL = 10.0

local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
}

local leftPosX,centerPosX,offsetX = 16,110,46
local riseBtnPosX,riseBtnCenterPosX = 300,189
function RoleRiseStarUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/rolerisestar.csb")
	self.panel:setName("role_risestar_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	local nor_pl = bgimg:getChildByName('nor_pl')

	--标题
	self.title = nor_pl:getChildByName("cur_title")
	self.titleIcon = nor_pl:getChildByName("title_icon")
	self.star = {}
	for i=1,3 do
		self.star[i] = nor_pl:getChildByName("star_"..i)
	end

	--属性
	self.attarr = {}
	local attbg = nor_pl:getChildByName('attr_bg')
	self.attrArrowImg = attbg:getChildByName('arrow')
	for i=1,4 do
		local curAttrTx = attbg:getChildByName('attr_tx_' .. i)
		local nextAttrTx = attbg:getChildByName('next_attr_tx_' .. i)
		local curAttrValue = attbg:getChildByName('attr_num_' .. i)
		local nextAttrValue = attbg:getChildByName('next_attr_num_' .. i)
		local addarrow = attbg:getChildByName('attr_up_img' .. i)
		local arr = {}
		arr.curAttrName = curAttrTx
		arr.curAttrValue = curAttrValue
		arr.nextAttrName = nextAttrTx
		arr.nextAttrValue = nextAttrValue
		arr.addarrow = addarrow
		self.attarr[i] = arr
	end

	--描述
	local desctx = nor_pl:getChildByName('desc_tx')
	desctx:setString(GlobalApi:getLocalStr_new("ROLE_RISESTAR_INFO"))
	local tipTx = nor_pl:getChildByName('tip_tx')
	tipTx:setString(GlobalApi:getLocalStr_new("ROLE_RISESTAR_INFO1"))

	--max
	self.maxImg = nor_pl:getChildByName('max_img')

	--next
	self.next_pl = nor_pl:getChildByName('next_pl')
	local nextdescTx = self.next_pl:getChildByName("desc_tx")
	nextdescTx:setString(GlobalApi:getLocalStr_new("ROLE_RISESTAR_INFO2"))

	local goto = {ROLEPANELTYPE.UI_LVUP,ROLEPANELTYPE.UI_SOLDIER,ROLEPANELTYPE.UI_TUPO}
	self.conditionCell = {}
	for i=1,3 do
		local cellbg = self.next_pl:getChildByName("itembg_"..i.."_img")
		local goTx = cellbg:getChildByName("go_tx")
		goTx:setString(GlobalApi:getLocalStr_new("ROLE_RISESTAR_INFO6"))
		local nameTx = cellbg:getChildByName("name_tx") 
		local finishIcon = cellbg:getChildByName("finish_icon") 
		self.conditionCell[i] = {}
		self.conditionCell[i].nameTx = nameTx
		self.conditionCell[i].finishIcon = finishIcon
		self.conditionCell[i].goTx = goTx
		self.conditionCell[i].goto = goto[i]
		cellbg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	self:skipUI(i)
	        end
	    end)
	end

	--升阶按钮
	self.risebtn = self.next_pl:getChildByName("rise_btn")
	self.btnTx = self.risebtn:getChildByName("func_tx")

    --消耗
    self.costbg = self.next_pl:getChildByName("cost_img")
    self.costnum = self.costbg:getChildByName("num_tx")
    self.itemImg = self.costbg:getChildByName("itemImg")
end

--点击按钮条状
function RoleRiseStarUI:skipUI(id)

	if not self.conditionCell[id] then
		return
	end

	local goto = self.conditionCell[id].goto
	if goto == ROLEPANELTYPE.UI_LVUP then
		if self.obj:getCamp() == 5 then
    		local award = DisplayData:getDisplayObj({'user','xp',1000})
    		GetWayMgr:showGetwayUI(award,true)
    		return
    	end
	else
		local moduleName = goto == ROLEPANELTYPE.UI_SOLDIER and 'elite' or 'reborn'
		local desc,code = GlobalApi:getGotoByModule(moduleName,true)
    	if desc then
    		promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr_new('FUNCTION_OPEN_NEED'),desc), COLOR_TYPE.RED)
    		return
    	end
	end
	RoleMgr:showChildPanelByIdx(goto)
end


function RoleRiseStarUI:update(obj)

	self.obj = obj
	local isRise = false
	local quality = obj:getHeroQuality()
	local conf = GameData:getConfData('heroquality')
	local qualityCfg = conf[quality]
	local isMax = quality >= #conf

	self.maxImg:setVisible(isMax)
	self.next_pl:setVisible(not isMax)
	self.attrArrowImg:setVisible(not isMax)

	--标题显示
	local star = qualityCfg.star
	local titleStr = string.format(GlobalApi:getLocalStr_new("ROLE_RISESTAR_TITLE"),qualityCfg.title,star)
	self.title:setString(titleStr)
	self.titleIcon:loadTexture('uires/ui_new/role/flag_'..qualityCfg.quality..'.png')
	for i=1,3 do
		if star >= i then
			self.star[i]:loadTexture('uires/ui_new/common/star_awake.png');
		else
			self.star[i]:loadTexture('uires/ui_new/common/star_awake_bg.png');
		end
	end

	--条件显示
	local fitCondition = true
	for id=1,3 do
		local needConditon,curValue,conditionStr
		if id == 1 then
			curValue = self.obj:getLevel()
			needConditon = qualityCfg.conditionHeroLevel
			conditionStr = "Lv."..needConditon
		elseif id == 2 then
			curValue = self.obj:getSoldier().level
			needConditon = qualityCfg.conditionHeroSoldier
			conditionStr = string.format(GlobalApi:getLocalStr_new("ROLE_RISESTAR_INFO4"),needConditon)
		elseif id == 3 then
			curValue = self.obj:getTalent()
			needConditon = qualityCfg.conditionHeroTalent
			conditionStr = string.format(GlobalApi:getLocalStr_new("ROLE_RISESTAR_INFO3"),needConditon)
		end
		self.conditionCell[id].nameTx:setString(conditionStr)
		self.conditionCell[id].finishIcon:setVisible(curValue>=needConditon)
		self.conditionCell[id].goTx:setVisible(curValue<needConditon)
		self.conditionCell[id].condition = curValue>=needConditon
		fitCondition = fitCondition and curValue>=needConditon
	end

	--显示属性
	local baseatt = RoleData:getPosAttByPos(self.obj)
    local curattarr = {}
    curattarr[1] = math.floor(baseatt[1])
    curattarr[2] = math.floor(baseatt[4])
    curattarr[3] = math.floor(baseatt[2])
    curattarr[4] = math.floor(baseatt[3])
    local nextattarr = {}
    local objtemp = clone(self.obj)

    if (conf[quality + 1]) then
    	objtemp:setHeroQuality(quality + 1)
    end

    local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    nextattarr[1] = math.floor(atttemp[1])
    nextattarr[2] = math.floor(atttemp[4])
    nextattarr[3] = math.floor(atttemp[2])
    nextattarr[4] = math.floor(atttemp[3])

	for i=1,4 do
    	self.attarr[i].curAttrName:setString(GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i))
    	self.attarr[i].curAttrValue:setString(curattarr[i])

    	local nextName = isMax and '' or GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i)
        local nextValue = isMax and '' or nextattarr[i]
		self.attarr[i].nextAttrName:setString(nextName)
		self.attarr[i].nextAttrValue:setString(nextValue)
		
		--提升图标位置
		local size = self.attarr[i].nextAttrValue:getContentSize()
        local posX = self.attarr[i].nextAttrValue:getPositionX()
        self.attarr[i].addarrow:setPositionX(posX + size.width + 10)
        self.attarr[i].addarrow:setVisible(not isMax)

        --当前属性位置
        local posY = self.attarr[i].curAttrName:getPositionY()
        local posX = isMax and centerPosX or leftPosX
        self.attarr[i].curAttrName:setPosition(posX, posY)
        self.attarr[i].curAttrValue:setPosition(posX+offsetX, posY)
    end

    --消耗和升阶按钮显示
    local costnum = qualityCfg.itemNum
    local posX = (costnum ~=0) and riseBtnPosX or riseBtnCenterPosX
    self.risebtn:setPositionX(posX)
    self.costbg:setVisible(costnum ~=0)

    local num = RoleMgr:clacUpgradeStarMaxNum(self.obj) 
	local autoisOpen,isNotIn,id,level = GlobalApi:getOpenInfo('autoupgrade')
	if num > 1 and autoisOpen then
		self.btnTx:setString(GlobalApi:getLocalStr_new('ROLE_RISESTAR_INFO8'))
	else
		self.btnTx:setString(GlobalApi:getLocalStr_new('ROLE_RISESTAR_INFO7'))
	end

	local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
	local itemobj = BagData:getMaterialById(itemId)
	if not itemobj then
		itemobj = ClassItemObj.new(tonumber(itemId),0)
	end
	self.costnum:setString(GlobalApi:toWordsNumber(itemobj:getNum())..'/'..GlobalApi:toWordsNumber(costnum))
	local itemEnough = itemobj:getNum() >= costnum
	local color = itemEnough and COLOR_TYPE.WHITE or COLOR_TYPE.RED
	self.costnum:setColor(color)
	self.itemImg:loadTexture(itemobj:getIcon())

	self.risebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            if self.risebtn:getChildByName('ui_yijianzhuangbei') then
                self.risebtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.5)
            end
        elseif eventType == ccui.TouchEventType.moved then
            if self.risebtn:getChildByName('ui_yijianzhuangbei') then
                self.risebtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.risebtn:getChildByName('ui_yijianzhuangbei') then
                self.risebtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        elseif eventType == ccui.TouchEventType.ended then

            if self.risebtn:getChildByName('ui_yijianzhuangbei') then
                self.risebtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end

        	if not fitCondition then
        		for i=1,3 do
	    			if not self.conditionCell[i].condition then
	    				self.conditionCell[i].nameTx:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.ScaleTo:create(0.2,2),cc.ScaleTo:create(0.2,1)))
	    			end
        		end
        		self.panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
        			promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_RISESTAR_INFO9'), COLOR_TYPE.RED)
        		end)))
        		return
        	end

        	if not itemEnough then
        		promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_RISE_STAR_7'), COLOR_TYPE.RED)
        		local award = DisplayData:getDisplayObj({'material',itemId,1000})
        		GetWayMgr:showGetwayUI(award,true)
        		return
        	end

        	if num > 1 and autoisOpen then
        		RoleMgr:showRoleAutoUpgradeStar(obj)
        	else
        		RoleMgr:sendUpgradeStarMsg(obj,1,curattarr,nextattarr,function()
        			self:update()
        		end)
        	end

        end
    end)

	--增加按钮特效
    if fitCondition and itemEnough then
        if self.risebtn:getChildByName('ui_yijianzhuangbei') then
            self.risebtn:removeChildByName('ui_yijianzhuangbei')
        end
        local size = self.risebtn:getContentSize()
        local effect = GlobalApi:createLittleLossyAniByName('ui_yijianzhuangbei')
        effect:setScaleX(1)
        effect:setScaleY(0.8)
        effect:setName('ui_yijianzhuangbei')
        effect:setPosition(cc.p(size.width/2 ,size.height/2+4))
        effect:setAnchorPoint(cc.p(0.5,0.5))
        effect:getAnimation():playWithIndex(0, -1, 1)
        self.risebtn:addChild(effect)
	else
        if self.risebtn:getChildByName('ui_yijianzhuangbei') then
            self.risebtn:removeChildByName('ui_yijianzhuangbei')
        end
	end
end


return RoleRiseStarUI