--===============================================================
-- 武将突破界面
--===============================================================
local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassItemCell = require('script/app/global/itemcell')

local RoleTupo = class("RoleTupo", ClassRoleBaseUI)
local maxlv = 10
local leftPosX,centerPosX,offsetX = 16,110,46
function RoleTupo:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roletupopanel.csb")
	self.panel:setName("role_tupo_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')
	
	self.attarr = {}
	local attbg = self.nor_pl:getChildByName('attr_bg')
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
	
	local descTx = self.nor_pl:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr_new("ROLE_TUPO_INFO"))
	local infobtnnor = self.nor_pl:getChildByName('check_btn')
	infobtnnor:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleTupoInfoUI(self.obj)
        end
    end)

    self.next_pl = self.nor_pl:getChildByName("next_pl")
    self.max_pl = self.nor_pl:getChildByName('max_pl')
    self.maxDesc = self.max_pl:getChildByName("max_tx")
    self.maxDesc:setString(GlobalApi:getLocalStr_new("ROLE_TUPO_INFO4"))

    self.activatttx = self.next_pl:getChildByName("desc_tx")
    self.nextdescName = self.next_pl:getChildByName("desc_name")

    self.curTitleTx = self.nor_pl:getChildByName("cur_title")

	self.ismaterialnumok = true
	self.obj = nil
	self.tupobtn = self.next_pl:getChildByName("tupo_btn")
	self.btntx =self.tupobtn:getChildByName('func_tx')
	self.btntx1 =self.tupobtn:getChildByName('func_tx1')

	--突破消耗
    self.costInfo = {}
    for i=1,2 do
    	local itemimg = self.next_pl:getChildByName('iconbg_' .. i .. '_img')
    	local numTx = itemimg:getChildByName('num_tx')
    	local itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    	itemCell.awardBgImg:setPosition(cc.p(itemimg:getPosition()))
    	itemCell.awardBgImg:setScale(0.72)
    	self.next_pl:addChild(itemCell.awardBgImg)
    	self.costInfo[i] = {}
    	self.costInfo[i].numTx = numTx
    	self.costInfo[i].item = itemCell
    	self.costInfo[i].itemBg = itemimg
    end
end

function RoleTupo:onMoveOut()
end

function RoleTupo:updateNorPanel(obj)

	local curLv = obj:getTalent() 
	local nextLv = obj:getTalent()+1
	if nextLv >= maxlv then
		nextLv = maxlv
	end

	--是否满级
	local isMaxLv = curLv >= maxlv
    self.max_pl:setVisible(isMaxLv)
    self.next_pl:setVisible(not isMaxLv)
    self.attrArrowImg:setVisible(not isMaxLv)

	local conf = obj:getrebornConfByLv(curLv)
	local conf1 = obj:getrebornConfByLv(nextLv)

    local str = string.format(GlobalApi:getLocalStr_new('ROLE_TUPO_TITLE'),curLv)
    self.curTitleTx:setString(str)

    local nextstr2 = string.format(GlobalApi:getLocalStr_new('ROLE_TUPO_TITLE'),nextLv)
    self.nextdescName:setString("【"..nextstr2.."】")
    
	--属性
	local att = RoleData:getPosAttByPos(obj)
	self.curattarr = {}
    self.curattarr[1] = math.floor(att[1])--(conf['baseAtk']+obj:getLevel()*conf['atkGrowth'])
    self.curattarr[2] = math.floor(att[4]) --(conf['baseHp']+obj:getLevel()*conf['hpGrowth'])
    self.curattarr[3] = math.floor(att[2]) --(conf['baseDef']+obj:getLevel()*conf['defGrowth'])
    self.curattarr[4] = math.floor(att[3]) --(conf['baseMagDef']+obj:getLevel()*conf['magDefGrowth'])
    self.nextattarr = {}
    local objtemp = clone(self.obj)
    objtemp:setTalent(nextLv)
    local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    self.nextattarr[1] = math.floor(atttemp[1])
    self.nextattarr[2] = math.floor(atttemp[4])
    self.nextattarr[3] = math.floor(atttemp[2])
    self.nextattarr[4] = math.floor(atttemp[3])

    local addarr = {}
    addarr[1] = math.floor(self.nextattarr[1] -self.curattarr[1])
    addarr[2] = math.floor(self.nextattarr[2] -self.curattarr[2])
    addarr[3] = math.floor(self.nextattarr[3] -self.curattarr[3])
    addarr[4] = math.floor(self.nextattarr[4] -self.curattarr[4])

    for i=1,4 do
    	self.attarr[i].curAttrName:setString(GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i))
    	self.attarr[i].curAttrValue:setString(self.curattarr[i])

    	local nextName = isMaxLv and '' or GlobalApi:getLocalStr_new('ROLE_STR_ATT' .. i)
        local nextValue = isMaxLv and '' or self.nextattarr[i]
		self.attarr[i].nextAttrName:setString(nextName)
		self.attarr[i].nextAttrValue:setString(nextValue)
		
		--提升图标位置
		local size = self.attarr[i].nextAttrValue:getContentSize()
        local posX = self.attarr[i].nextAttrValue:getPositionX()
        self.attarr[i].addarrow:setPositionX(posX + size.width + 10)
        self.attarr[i].addarrow:setVisible(not isMaxLv)

        --当前属性位置
        local posY = self.attarr[i].curAttrName:getPositionY()
        local posX = isMaxLv and centerPosX or leftPosX
        self.attarr[i].curAttrName:setPosition(posX, posY)
        self.attarr[i].curAttrValue:setPosition(posX+offsetX, posY)
    end

    --天赋显示
	local innateGroupId = obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
	local innateid = groupconf[tostring('level' .. nextLv)]
	local effect =groupconf[tostring('value' .. nextLv)]
	local innateconf = GameData:getConfData('innate')[innateid]
	local tx1 = ''
	if innateid < 1000 then
		tx1 = innateconf['desc'] .. effect .. '%'
		if innateconf['type'] ~= 2 then
			tx1 = innateconf['desc'] .. effect
		end
	else
		tx1 = groupconf[tostring('specialDes'..innateid%1000)]
	end
 	self.activatttx:setString("                    "..tx1)

 	--按钮文字显示需求
 	local satisfyUpLv = curLv >= conf1['roleLevel']
 	self.tupobtn:setBright(satisfyUpLv)
	self.tupobtn:setEnabled(satisfyUpLv)
	self.btntx:setVisible(satisfyUpLv)
	self.btntx1:setVisible(not satisfyUpLv)
	self.btntx:setString( GlobalApi:getLocalStr_new('ROLE_TUPO_INFO2'))
 	local str = string.format(GlobalApi:getLocalStr_new('ROLE_TUPO_INFO1'),conf1['roleLevel'])
 	self.btntx1:setString(str)

 	--突破消耗
 	local disPlayData = DisplayData:getDisplayObjs(conf1['cost'])
 	for i=1,2 do
		local award = disPlayData[i]
		if award then
			self.costInfo[i].numTx:setString(GlobalApi:toWordsNumber(award:getOwnNum())..'/'..GlobalApi:toWordsNumber(award:getNum()))
		   	if award:getOwnNum() < award:getNum() then
		    	self.ismaterialnumok  = false
		    	self.materialObj = award
		    	self.costInfo[i].numTx:setColor(COLOR_TYPE.RED)
		    else
		    	self.costInfo[i].numTx:setColor(COLOR_TYPE.WHITE)
			end
			ClassItemCell:updateItem(self.costInfo[i].item, award, 1)
			self.costInfo[i].item.lvTx:setVisible(false)
			self.costInfo[i].item.awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				end
		        if eventType == ccui.TouchEventType.ended then
		            GetWayMgr:showGetwayUI(award,true)
		        end
		    end)
		    self.costInfo[i].item.awardBgImg:setVisible(true)
		    self.costInfo[i].itemBg:setVisible(true)
		else
			self.costInfo[i].item.awardBgImg:setVisible(false)
			self.costInfo[i].itemBg:setVisible(false)
		end
	end

	--计算可以提升到的最高等级
   	local maxlvnum = RoleMgr:calcRebornLvUpMaxNum(obj)
   	-- print('obj:getTalent()=='..obj:getTalent())
   	local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('autotupo')
    if maxlvnum > 1 and isOpen then
    	self.btntx:setString(GlobalApi:getLocalStr_new('ROLE_TUPO_INFO3'))
    	self.tupobtn:addTouchEventListener(function (sender, eventType)
	    	if eventType ==  ccui.TouchEventType.ended then
	    		RoleMgr:showRoleAutoReborn(obj)
			end
	    end)
    else
    	self.btntx:setString(GlobalApi:getLocalStr_new('ROLE_TUPO_INFO2'))
    	self.tupobtn:addTouchEventListener(function (sender, eventType)
	    	if eventType ==  ccui.TouchEventType.ended then
	    		RoleMgr:sendRebornMsg(obj, 1, self.curattarr, self.nextattarr, function ()
	    			self:update(obj)
	    		end)
			end
	    end)
    end
end

function RoleTupo:update(obj)
	self.obj = obj
	self.ismaterialnumok = true

	self:updateNorPanel(self.obj)
end

return RoleTupo