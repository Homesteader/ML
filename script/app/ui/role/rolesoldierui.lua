local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleSoldierUI = class("RoleSoldierUI", ClassRoleBaseUI)
local ClassDressObj = require('script/app/obj/dressobj')
local ClassItemCell = require('script/app/global/itemcell')
local defaulticon = 'uires/ui_new/common/add_yellow_2.png'
local defaulticon1 = 'uires/ui_new/common/add_green.png'
local defaulticon2 = 'uires/ui/common/lock_2.png'
local leftPosX,centerPosX,offsetX = 16,110,46
local maxStar = 5
function RoleSoldierUI:initPanel()

	self.panel = cc.CSLoader:createNode("csb/rolesoldierpanel.csb")
	self.panel:setName("role_soldier_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')
    self.bottom1 = bgimg:getChildByName('bottom_pl1')
    self.bottom2 = bgimg:getChildByName('bottom_pl2')

    self.curTitleTx = self.nor_pl:getChildByName('cur_title')

    --属性
	self.attarr = {}
	local attbg = self.nor_pl:getChildByName('attr_bg')
    self.arrowImg = attbg:getChildByName("arrow")
	for i=1,4 do
		local attrtx = attbg:getChildByName('attr_tx_'..i)
		local nextattrtx = attbg:getChildByName('next_attr_tx_' .. i)

		local attrnum = attbg:getChildByName('attr_num_' .. i)
		local nextattrnum = attbg:getChildByName('next_attr_num_' .. i) -- +500
		local arrowimg = attbg:getChildByName('attr_up_img' .. i) -- 箭头

		local arr = {}
		arr.curattrName = attrtx
        arr.curattrValue = attrnum
		arr.nextattrName = nextattrtx
        arr.nextattrValue = nextattrnum
		arr.arrow = arrowimg
		self.attarr[i] = arr
	end

    -- 激活套装
    self.activeAtt = {}
    local infoBg = self.bottom1:getChildByName('info_bg')
    for i=1,4 do
        self.activeAtt[i] = infoBg:getChildByName('active_tx_'..i)
	end

    --小兵图片
    local soldierTx = self.nor_pl:getChildByName("soldier_tx")
    soldierTx:setString(GlobalApi:getLocalStr_new("ROLE_SOLIDER_TEXT"))
    local soldierdesc = self.nor_pl:getChildByName("soldier_desc")
    soldierdesc:setString(GlobalApi:getLocalStr_new("ROLE_SOLIDER_INFO"))
    self.soldierarraft = {}

    --小兵展示
	self.curSoldierInfo = {}
    local curSoldierPl = self.nor_pl:getChildByName('cur_soldier')
    self.curSoldierInfo.num = curSoldierPl:getChildByName('num_tx')
    self.curSoldierInfo.img = curSoldierPl:getChildByName('soldier_img')
    self.curSoldierInfo.img:ignoreContentAdaptWithSize(true)
    self.curSoldierInfo.star = {}
    self.nextSoldierInfo = {}
    local nextSoldierPl = self.nor_pl:getChildByName('next_soldier')
    self.nextSoldierInfo.num = nextSoldierPl:getChildByName('num_tx')
    self.nextSoldierInfo.img = nextSoldierPl:getChildByName('soldier_img')
    self.nextSoldierInfo.img:ignoreContentAdaptWithSize(true)
    self.nextSoldierInfo.star = {}
    for i=1,maxStar do
        self.curSoldierInfo.star[i] = curSoldierPl:getChildByName('star_'..i)
        self.nextSoldierInfo.star[i] = nextSoldierPl:getChildByName('star_'..i)
    end

    --小兵装备
	self.soldier = nil
	self.equiparr = {}
	for i=1,4 do
		local itemtab = {}
		local equipbg = self.bottom1:getChildByName('equip_' .. i)
		itemtab.icon = equipbg:getChildByName('icon')
		itemtab.icon:ignoreContentAdaptWithSize(true)
		itemtab.equipbg = equipbg
		itemtab.add = equipbg:getChildByName('add')
		itemtab.add:ignoreContentAdaptWithSize(true)
		itemtab.numtx = equipbg:getChildByName('num_tx')
        itemtab.add:setSwallowTouches(false)
		equipbg:addTouchEventListener(function (sender,eventType)
			if eventType ==ccui.TouchEventType.ended then
				if self.soldier.dress[tostring(i)] ~= 1 then
					local equiparr = self.obj:getSoldierArmArr()
					local obj = BagData:getDressById(equiparr[i].id) or  ClassDressObj.new(tonumber(equiparr[i].id), 0)
					GetWayMgr:showGetwayUI(obj,true,equiparr[i].num,self.obj,0,false)
				else 					
					local size = equipbg:getContentSize()
    				local x, y = equipbg:convertToWorldSpace(cc.p(equipbg:getPosition(size.width / 2, size.height / 2)))
					TipsMgr:showSoldierEquipTips(self.obj,i,cc.p(680,200))
				end
			end
		end)
		self.equiparr[i] = itemtab
	end

    --小兵装备
	self.equipBtn = self.bottom1:getChildByName("equip_btn")
	self.functx = self.equipBtn:getChildByName('text')
	self.functx:setString(GlobalApi:getLocalStr('SOLDIERLVUP1'))
    self.equipBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
    		local canlvup = true
    		local equiparr = self.obj:getSoldierArmArr()
    		for i=1,4 do
    			if equiparr[i].id > 0 and self.soldier.dress[tostring(i)] ~= 1 then
    				canlvup = false
    			end
    		end
            if canlvup then
                self.equipBtn:setTouchEnabled(false)
                local args = {
                    pos = self.obj:getPosId()
                }
                MessageMgr:sendPost("upgrade_soldier_star", "hero", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        self.upgrade_soldier = true
                    	RoleMgr:showSoldierUpgrade(self.obj, self.curattarr, self.nextattarr, function ()
                            for i=1,4 do
                                self.soldier.dress[tostring(i)] = 0
                            end
	                        self.obj:setSoldierLv( self.nextSoldierLv)
                            self.obj:setSoldierStar(self.nextSoldierStar)
	                        self.obj:setFightForceDirty(true)
	                        RoleMgr:updateRoleList()
	                        RoleMgr:updateRoleMainUI()
	                        promptmgr:showSystenHint(GlobalApi:getLocalStr_new("ROLE_SOLIDER_INFO5"), COLOR_TYPE.GREEN)                     
                            self.upgrade_soldier = false
                    	end)
                    end
                end)
            else
            	--todo
            	local  canquip = self.obj:isSoldierCanEquip()
            	if not canquip then
            		promptmgr:showSystenHint(GlobalApi:getLocalStr_new("ROLE_SOLIDER_INFO8"), COLOR_TYPE.RED)
            		return
            	end
                local args = {
                    pos = self.obj:getPosId()
                }
                MessageMgr:sendPost("dress_wear_all", "hero", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        local awards = jsonObj.data.awards
                        GlobalApi:parseAwardData(awards)
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        for k,v in pairs(costs) do
                    	    self.obj:setSoldierdress(v[2]%10)
                    	end
                        self.obj:setFightForceDirty(true)
                        RoleMgr:updateRoleList()
                        RoleMgr:updateRoleMainUI()
                        if #costs > 0 then
                        	promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_SOLIDER_INFO7'), COLOR_TYPE.GREEN)
                    	else
                    		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_SOLIDER_INFO8'), COLOR_TYPE.RED)
                    	end
                    end
                end)
            end
    	end	
    end)

    --放大镜查看
    local infobtn = self.nor_pl:getChildByName('check_btn')
    infobtn:addTouchEventListener(function (sender, eventType)
    	if eventType ==  ccui.TouchEventType.ended then
    		RoleMgr:showSoldierinfo(self.obj)
    	end	
    end)   

    self.maxLevel = self.nor_pl:getChildByName('max_level')
    self.upgrade_soldier = false
    self.enoughItem = false
    --升阶
    self.costInfo = {}
    for i=1,2 do
        local itemNode = self.bottom2:getChildByName("up_item"..i)
        local costTx = self.bottom2:getChildByName("item_num"..i)
        self.costInfo[i] = {}
        self.costInfo[i].itemNode = itemNode
        self.costInfo[i].costTx = costTx
    end

    self.upgradeBtn = self.bottom2:getChildByName("upgrade_btn")
    self.upgradeBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
            if not self.enoughItem then
                promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_SOLIDER_INFO9'), COLOR_TYPE.RED)
                return
            end
            local args = {
                pos = self.obj:getPosId()
            }
            MessageMgr:sendPost("upgrade_soldier", "hero", json.encode(args), function (jsonObj)
                local code = jsonObj.code
                if code == 0 then
                    RoleMgr:showSoldierUpgrade(self.obj, self.curattarr, self.nextattarr, function ()
                        for i=1,4 do
                            self.soldier.dress[tostring(i)] = 0
                        end
                        self.obj:setSoldierLv( self.nextSoldierLv)
                        self.obj:setSoldierStar(self.nextSoldierStar)
                        self.obj:setFightForceDirty(true)
                        RoleMgr:updateRoleList()
                        RoleMgr:updateRoleMainUI()
                        promptmgr:showSystenHint(GlobalApi:getLocalStr_new("ROLE_SOLIDER_INFO6"), COLOR_TYPE.GREEN)                     
                    end)
                end
            end)
        end 
    end)
end

function RoleSoldierUI:updateNorPanel(obj)

	local soldier = obj:getSoldier()
	local dresstab = soldier.dress                                          --小兵装备

    local soldierid = obj:getSoldierId()                                    --小兵id
    local soldierLv = obj:getSoldier().level                                --当前小兵等级
    local soldierStar = obj:getSoldier().star                               --当前小兵星级
    local soldierlvCfg = GameData:getConfData("soldierlevel")[soldierid]
    local maxsoldierLv = #soldierlvCfg                                      --小兵最高等阶
    local soldierStarCfg = soldierlvCfg[soldierLv]
    local maxsoldierStar = #soldierStarCfg                                  --小兵最高星级

    local isMax =  soldierLv >= maxsoldierLv                                --是否是最大等阶
    local isMaxStar = soldierStar >= maxsoldierStar                         --是否是最大星级

    self.bottom1:setVisible(not isMaxStar)
    self.bottom2:setVisible(isMaxStar)
    self.maxLevel:setVisible(false)
    self.arrowImg:setVisible(true)
    
    local nextSoldierStar = soldierStar+1                                  --下星小兵状态
    local nextSoldierLv = soldierLv                                      
    if nextSoldierStar > maxsoldierStar then                   
        nextSoldierLv = nextSoldierLv + 1
        if nextSoldierLv >= maxsoldierLv then
            nextSoldierStar = maxsoldierStar                               --满阶满星
            self:updateMaxPanel(obj)
            return
        else
           nextSoldierStar = 0 
        end
    end
    self.nextSoldierLv = nextSoldierLv
    self.nextSoldierStar = nextSoldierStar

    local str1 = string.format(GlobalApi:getLocalStr_new('ROLE_SOLIDER_JIE'),soldierLv,soldierStar)
    self.curTitleTx:setString(str1)

    local curSoldierCfg =  soldierStarCfg[soldierStar]
    local nextSoldierCfg = soldierlvCfg[nextSoldierLv][nextSoldierStar]
    local soldconf = GlobalApi:getSoldierConf(curSoldierCfg['soldierId'])
    local soldierdressConf = GameData:getConfData('dress')                 --小兵装备cfg
    local attconf = GameData:getConfData('attribute')                      --小兵属性cfg

    --升阶消耗
    if isMaxStar then
        local cost = curSoldierCfg.cost
        local disPlayData = DisplayData:getDisplayObjs(cost)
        local posX = #disPlayData == 1 and 189 or 110
        self.costInfo[1].itemNode:setPositionX(posX)
        self.costInfo[1].costTx:setPositionX(posX)
        for i=1,2 do
            local awards = disPlayData[i]
            if awards then
                self.costInfo[i].itemNode:setVisible(true)
                self.costInfo[i].costTx:setVisible(true)
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, self.costInfo[i].itemNode)
                cell.awardBgImg:setPosition(cc.p(0,0))
                cell.awardBgImg:setScale(0.7)
                local num = awards:getNum()
                local ownNum = 0
                local itemId = awards:getId()
                local itemobj = BagData:getMaterialById(itemId)
                if itemobj then
                  ownNum = itemobj:getNum()
                end
                local color = ownNum >= num and COLOR_TYPE.GREEN or COLOR_TYPE.RED
                self.costInfo[i].costTx:setTextColor(color)
                self.costInfo[i].costTx:setString(ownNum.."/"..num)
                self.enoughItem = ownNum >= num
            else
                self.costInfo[i].itemNode:setVisible(false)
                self.costInfo[i].costTx:setVisible(false)
            end
        end
    end

    --小兵信息显示(图片，数量，星星)
    self.curSoldierInfo.num:setString('x '..curSoldierCfg.num)
    self.curSoldierInfo.img:loadTexture('uires/ui/role/' ..curSoldierCfg.soldierIcon)
    self.nextSoldierInfo.num:setString('x '..nextSoldierCfg.num)
    self.nextSoldierInfo.img:loadTexture('uires/ui/role/' ..nextSoldierCfg.soldierIcon)
    for i=1,maxStar do
        self.curSoldierInfo.star[i]:setVisible(soldierStar>=i)
        self.nextSoldierInfo.star[i]:setVisible(nextSoldierStar>=i)
    end

    --装备信息
	local equiparr = obj:getSoldierArmArr()
	for i=1,4 do
		self.equiparr[i].numtx:setString('')		
		if equiparr[i].id > 0 and soldier.dress[tostring(i)] == 1 then
			local img = 'uires/icon/dress/' .. soldierdressConf[equiparr[i].id]['icon']
			self.equiparr[i].icon:loadTexture(img)
			self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
			self.equiparr[i].add:setVisible(false)
			self.equiparr[i].equipbg:setTouchEnabled(true)
			self.equiparr[i].numtx:setString(equiparr[i].num)	
           -- ShaderMgr:restoreWidgetDefaultShader(self.equiparr[i].equipbg)
           -- ShaderMgr:restoreWidgetDefaultShader(self.equiparr[i].icon)
		elseif equiparr[i].id == 0 then
			self.equiparr[i].add:setVisible(true)
			self.equiparr[i].equipbg:setTouchEnabled(false)
		 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.GRAY)
		 	self.equiparr[i].add:loadTexture(defaulticon2)	
           -- ShaderMgr:setGrayForWidget(self.equiparr[i].equipbg)
           -- ShaderMgr:setGrayForWidget(self.equiparr[i].icon)
		else
		 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.DEFAULT)
		 	local dressobj = BagData:getDressById(equiparr[i].id)
		 	self.equiparr[i].icon:loadTexture(DEFAULTSOLDEREQUIP[i])
		 	if dressobj ~= nil and equiparr[i].num <= dressobj:getNum() then
		 		self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
		 		self.equiparr[i].add:loadTexture(defaulticon1)
		 		self.equiparr[i].add:setVisible(true)
		 		self.equiparr[i].equipbg:setTouchEnabled(true)
		 	elseif dressobj ~= nil and equiparr[i].num <= dressobj:getNum() then
		 		self.equiparr[i].add:loadTexture(defaulticon)
		 		self.equiparr[i].add:setVisible(true)
			 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
			 	self.equiparr[i].equipbg:setTouchEnabled(true)
			else
				self.equiparr[i].add:loadTexture(defaulticon)
				self.equiparr[i].add:setVisible(true)
				self.equiparr[i].equipbg:setTouchEnabled(true)
			 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
		 	end
		end
	end


	local canlvup = true
    for i=1,4 do
        --soldier.dress[tostring(i)] 1:已装备 0:未装备
        if equiparr[i].id >0 and soldier.dress[tostring(i)] ~= 1 then
            canlvup = false
        end
    end

	if canlvup then
		self.functx:setString(GlobalApi:getLocalStr_new('ROLE_SOLIDER_INFO3'))
        if self.equipBtn:getChildByName('ui_yijianzhuangbei') then
            self.equipBtn:removeChildByName('ui_yijianzhuangbei')
        end
        local size = self.equipBtn:getContentSize()
        local effect = GlobalApi:createLittleLossyAniByName('ui_yijianzhuangbei')
        effect:setName('ui_yijianzhuangbei')
        effect:setPosition(cc.p(size.width/2 ,size.height/2))
        effect:setAnchorPoint(cc.p(0.5,0.5))
        effect:getAnimation():playWithIndex(0, -1, 1)
        self.equipBtn:addChild(effect)
	else
        if self.equipBtn:getChildByName('ui_yijianzhuangbei') then
            self.equipBtn:removeChildByName('ui_yijianzhuangbei')
        end
		self.functx:setString(GlobalApi:getLocalStr_new('ROLE_SOLIDER_INFO4'))
	end

    --属性
    local attcount = #attconf
	local att = RoleData:getPosAttByPos(obj)
	local attsoidlerbefor,percentattbefer = obj:getSoldierUpgradeAtt(soldierLv,soldierStar,false)
	local attsoidlerafter,percentattafter = obj:getSoldierUpgradeAtt(nextSoldierLv,nextSoldierStar,true)
	local curattarr = {}
	local addarr = {}
	for i=1,attcount do
		addarr[i] = 0
	end

	for i=1,attcount do
		addarr[i] = addarr[i] + (attsoidlerafter[i]-attsoidlerbefor[i]) -- -dressarr[i]+ dressnextarr[i]) 
		addarr[i] = addarr[i] + math.floor(att[i]*((percentattafter[i]-percentattbefer[i])/100))
	end

	curattarr[1] = math.floor(att[1])--*soldconf['attPowPercent']/100)
	curattarr[2] = math.floor(att[4])--*soldconf['heaPowPercent']/100)
	curattarr[3] = math.floor(att[2])--*soldconf['phyArmPowPercent']/100) 
	curattarr[4] = math.floor(att[3])--*soldconf['magArmPowPercent']/100) 
	self.curattarr = curattarr
	local nextattarr = {}

	nextattarr[1] = math.floor((att[1] + addarr[1] ))--*soldconf['attPowPercent']/100) 
	nextattarr[2] = math.floor((att[4] + addarr[4]))--*soldconf['heaPowPercent']/100)
	nextattarr[3] = math.floor((att[2] + addarr[2] ))--*soldconf['phyArmPowPercent']/100) 
	nextattarr[4] = math.floor((att[3] + addarr[3]))--*soldconf['magArmPowPercent']/100) 
	self.nextattarr = {}
	self.nextattarr[1] = math.floor((att[1] + addarr[1]))--*soldconf['attPowPercent']/100) 
	self.nextattarr[2] = math.floor((att[4] + addarr[4]))--*soldconf['heaPowPercent']/100)
	self.nextattarr[3] = math.floor((att[2] + addarr[2]))--*soldconf['phyArmPowPercent']/100) 
	self.nextattarr[4] = math.floor((att[3] + addarr[3]))--*soldconf['magArmPowPercent']/100) 	

    --套装激活
    local atts,allAtts = obj:getSoldierdressAtts(soldierLv,soldierStar)
    local num = obj:getSoldierdressNum()
    if atts and allAtts then
        for i=1,4 do
            if allAtts[i] then
                local attId = allAtts[i].att1
                local attrValue = allAtts[i].value1
                local attrName = GameData:getConfData('attribute')[attId].name
                local str = string.format(GlobalApi:getLocalStr_new('ROLE_SOLIDER_SUIT'),i,attrName,attrValue)
                self.activeAtt[i]:setString(str)
                local color = i <= num and COLOR_TYPE.GREEN1 or COLOR_TYPE.GRAY1
                local outcolor = i <= num and COLOROUTLINE_TYPE.GREEN1 or COLOROUTLINE_TYPE.GRAY1
                self.activeAtt[i]:setTextColor(color)
                self.activeAtt[i]:enableOutline(outcolor,2)
            end
        end
    end

    --属性显示
	for i=1,4 do
        local attrName = GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i)
        self.attarr[i].curattrName:setString(attrName)
        self.attarr[i].nextattrName:setString(attrName)
        self.attarr[i].curattrValue:setString(curattarr[i])
		self.attarr[i].nextattrValue:setString('+' .. nextattarr[i])

        self.attarr[i].arrow:setVisible(true)
        local posY = self.attarr[i].curattrName:getPositionY()
        self.attarr[i].curattrName:setPosition(leftPosX, posY)
        self.attarr[i].curattrValue:setPosition(leftPosX+offsetX, posY)

        local size = self.attarr[i].nextattrValue:getContentSize()
        local posX = self.attarr[i].nextattrValue:getPositionX()
        self.attarr[i].arrow:setPositionX(posX + size.width + 10)
	end
	local str = soldconf['soldierName'].. soldierLv .. GlobalApi:getLocalStr_new('ROLE_SOLIDER_INF10')
	RoleMgr:setRoleMainTitle(str)

end


function RoleSoldierUI:updateMaxPanel(obj)

    self.bottom1:setVisible(false)
    self.bottom2:setVisible(false)
    self.maxLevel:setVisible(true)
    self.arrowImg:setVisible(false)
	local soldierid = obj:getSoldierId()
	local soldier = obj:getSoldier()
	local dresstab = soldier.dress
    
    local soldierid = obj:getSoldierId()                                    --小兵id
    local soldierLv = obj:getSoldier().level                                --当前小兵等级
    local soldierStar = obj:getSoldier().star                               --当前小兵星级
    local soldierlvCfg = GameData:getConfData("soldierlevel")[soldierid][soldierLv][soldierStar]
	local soldconf = GlobalApi:getSoldierConf(soldierlvCfg['soldierId'])

	local soldierdressConf = GameData:getConfData('dress')
	local attconf = GameData:getConfData('attribute')

    local str1 = string.format(GlobalApi:getLocalStr_new('ROLE_SOLIDER_JIE'),soldierLv,soldierStar)
    self.curTitleTx:setString(str1)

    --小兵信息显示(图片，数量，星星)
    self.curSoldierInfo.num:setString('x '..soldierlvCfg.num)
    self.curSoldierInfo.img:loadTexture('uires/ui/role/' ..soldierlvCfg.soldierIcon)
    self.nextSoldierInfo.num:setString('')
    self.nextSoldierInfo.img:loadTexture('uires/ui/role/' ..soldierlvCfg.soldierIcon)      --有满阶的替代资源
    for i=1,maxStar do
        self.curSoldierInfo.star[i]:setVisible(soldierStar>=i)
        self.nextSoldierInfo.star[i]:setVisible(false)
    end

	local att = RoleData:getPosAttByPos(obj)
	local curattarr = {}
	curattarr[1] = math.floor(att[1])--*soldconf['attPowPercent']/100)
	curattarr[2] = math.floor(att[4])--*soldconf['heaPowPercent']/100)
	curattarr[3] = math.floor(att[2])--*soldconf['phyArmPowPercent']/100) 
	curattarr[4] = math.floor(att[3])--*soldconf['magArmPowPercent']/100) 

	for i=1,4 do
    	self.attarr[i].curattrName:setString(GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i))
		self.attarr[i].curattrValue:setString(curattarr[i])
        self.attarr[i].nextattrName:setString('')
        self.attarr[i].nextattrValue:setString('')
        self.attarr[i].arrow:setVisible(false)
        local posY = self.attarr[i].curattrName:getPositionY()
        self.attarr[i].curattrName:setPosition(centerPosX, posY)
        self.attarr[i].curattrValue:setPosition(centerPosX+offsetX, posY)
	end

	local str = soldconf['soldierName'].. soldierLv .. GlobalApi:getLocalStr_new('ROLE_SOLIDER_INF10')
	RoleMgr:setRoleMainTitle(str)
end

function RoleSoldierUI:update(obj)

    self.equipBtn:setTouchEnabled(true)
	self.obj = obj
    self.soldier = obj:getSoldier()
    self:updateNorPanel(obj)
end

return RoleSoldierUI