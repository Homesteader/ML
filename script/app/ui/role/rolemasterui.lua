local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleMaserUI = class("RoleMaserUI", ClassRoleBaseUI)
function RoleMaserUI:initPanel()

	self.panel = cc.CSLoader:createNode("csb/rolemasterpanel.csb")
	self.panel:setName('role_master_panel')
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')

	--觉醒大师
	local awakeTitle = self.nor_pl:getChildByName("awake_title")
	awakeTitle:setString(GlobalApi:getLocalStr_new("ROLE_MASTER_TITLE1"))
	self.awakeLvTx = self.nor_pl:getChildByName("awake_lv")
	local awakebg = self.nor_pl:getChildByName("awake_bg")

	self.awakeConditionTx = awakebg:getChildByName("info")
	self.awakeArrow = awakebg:getChildByName("arrow")  
	self.awakeAttr = {}
	for i=1,2 do
		local attrName = awakebg:getChildByName("attr_tx_"..i)
		local attrValue = awakebg:getChildByName("attr_num_"..i)
		local attrName1 = awakebg:getChildByName("next_attr_tx_"..i)
		local attrValue1 = awakebg:getChildByName("next_attr_num_"..i)
		self.awakeAttr[i] = {}
		self.awakeAttr[i].curName = attrName
		self.awakeAttr[i].curValue = attrValue
		self.awakeAttr[i].nextName = attrName1
		self.awakeAttr[i].nextValue = attrValue1
	end

	self.awakePart = {}
	for i=1,MAXEQUIPNUM do
		self.awakePart[i] = awakebg:getChildByName("part_img_"..i)
	end

	--镶嵌大师
	local embedTitle = self.nor_pl:getChildByName("embed_title")
	embedTitle:setString(GlobalApi:getLocalStr_new("ROLE_MASTER_TITLE2"))
	self.embedLvTx = self.nor_pl:getChildByName("embed_lv")
	local embedbg = self.nor_pl:getChildByName("embed_bg")
	self.embedConditionTx = embedbg:getChildByName("info")
 	self.embedArrow = embedbg:getChildByName("arrow")  
 	self.embedAttr = {}
	for i=1,2 do
		local attrName = embedbg:getChildByName("attr_tx_"..i)
		local attrValue = embedbg:getChildByName("attr_num_"..i)
		local attrName1 = embedbg:getChildByName("next_attr_tx_"..i)
		local attrValue1 = embedbg:getChildByName("next_attr_num_"..i)
		self.embedAttr[i] = {}
		self.embedAttr[i].curName = attrName
		self.embedAttr[i].curValue = attrValue
		self.embedAttr[i].nextName = attrName1
		self.embedAttr[i].nextValue = attrValue1
	end

	self.embedPart = {}
	for i=1,MAXEQUIPNUM do
		self.embedPart[i] = embedbg:getChildByName("part_img_"..i)
	end
end

--觉醒大师信息
function RoleMaserUI:awakeMasterInfo()

	local attributeCfg = GameData:getConfData("attribute")
	local awakeMasteCfg = GameData:getConfData("partmasterawake")
	local awakeMasterLv = self.obj:getAwakeMasterLevel()
	local isMax = (awakeMasterLv == #awakeMasteCfg)
	local nextAwakeMasterLv = awakeMasterLv+1
	if nextAwakeMasterLv >= #awakeMasteCfg then
		nextAwakeMasterLv = #awakeMasteCfg
	end
	self.awakeLvTx:setString("Lv."..awakeMasterLv)

	local curAwakeMaserCfg = awakeMasteCfg[awakeMasterLv]
	local nextAwakeMaserCfg = awakeMasteCfg[nextAwakeMasterLv]
	self.awakeArrow:setVisible(not isMax)
	for i=1,2 do

		--curAwakeMaserCfg：nil 大师等级0
		local curAttr
		if curAwakeMaserCfg then 
		  curAttr = curAwakeMaserCfg.attribute[i]
		else
		  curAttr = nextAwakeMaserCfg.attribute[i]
		end

        local curAttrId,curAttrValue = GlobalApi:getAttrTypeAndValue(curAttr)
        self.awakeAttr[i].curName:setString(attributeCfg[curAttrId].name)
        local attrDesc = attributeCfg[curAttrId].desc == '0' and '' or attributeCfg[curAttrId].desc
        if curAwakeMaserCfg then
			self.awakeAttr[i].curValue:setString("+"..curAttrValue..attrDesc)
		else
			self.awakeAttr[i].curValue:setString("+0"..attrDesc)
		end

		if isMax then
			self.awakeAttr[i].curName:setPositionX(106)
		end

		local curNameSize = self.awakeAttr[i].curName:getContentSize()
		local posX = self.awakeAttr[i].curName:getPositionX()
		self.awakeAttr[i].curValue:setPositionX(posX+curNameSize.width+5)

		local nextAttr = nextAwakeMaserCfg.attribute[i]
        local nextAttrId,nextAttrValue = GlobalApi:getAttrTypeAndValue(nextAttr)
        local nextAttrName = isMax and "" or attributeCfg[nextAttrId].name
        local nextAttrValueStr = isMax and "" or nextAttrValue
        local attrDesc = attributeCfg[nextAttrId].desc == '0' and '' or attributeCfg[nextAttrId].desc
        if isMax then
        	attrDesc = ''
        end
        self.awakeAttr[i].nextName:setString(nextAttrName)
		self.awakeAttr[i].nextValue:setString("+"..nextAttrValueStr..attrDesc)
		local nextNameSize = self.awakeAttr[i].nextName:getContentSize()
		local posX = self.awakeAttr[i].nextName:getPositionX()
		self.awakeAttr[i].nextValue:setPositionX(posX+nextNameSize.width+5)
	end

	local needAwakeNum = nextAwakeMaserCfg.needAwakeNum
	local needAwakeLevel = nextAwakeMaserCfg.needAwakeLevel

	local fitCont = 0
	for i=1,MAXEQUIPNUM do

		local partImg = self.awakePart[i]:getChildByName("img")
		partImg:setScale(0.8)
		local partObj = self.obj:getPartByIndex(i)
		if partObj then
			partImg:loadTexture(partObj:getIcon())
			local awakeLv = partObj:getAwakeLv()
			if awakeLv >= needAwakeLevel then
				fitCont = fitCont + 1
				ShaderMgr:restoreWidgetDefaultShader(self.awakePart[i])
				ShaderMgr:restoreWidgetDefaultShader(partImg)
			else
				ShaderMgr:setGrayForWidget(self.awakePart[i])
				ShaderMgr:setGrayForWidget(partImg)
			end
		end
		
	end

	local str = fitCont.."/"..needAwakeNum
	local conditionTx = string.format(GlobalApi:getLocalStr_new("ROLE_MASTER_INFO1"),needAwakeNum,needAwakeLevel,str)
	self.awakeConditionTx:setString(conditionTx)
end

--镶嵌大师信息
function RoleMaserUI:embedMasterInfo()


	local attributeCfg = GameData:getConfData("attribute")
	local embedMasteCfg = GameData:getConfData("partmasterembed")
	local embedMasterLv = self.obj:getEmbedMasterLevel()
	local isMax = (embedMasterLv == #embedMasteCfg)
	local nextEmbedMasterLv = embedMasterLv+1
	if nextEmbedMasterLv >= #embedMasteCfg then
		nextEmbedMasterLv = #embedMasteCfg
	end
	self.embedLvTx:setString("Lv."..embedMasterLv)

	local curEmbedMaserCfg = embedMasteCfg[embedMasterLv]
	local nextEmbedMaserCfg = embedMasteCfg[nextEmbedMasterLv]
	self.embedArrow:setVisible(not isMax)
	for i=1,2 do

		--curEmbedMaserCfg:nil 大师等级0
		local curAttr
		if curEmbedMaserCfg then
		  curAttr = curEmbedMaserCfg.attribute[i]
		else
		  curAttr = nextEmbedMaserCfg.attribute[i]
		end
        local curAttrId,curAttrValue = GlobalApi:getAttrTypeAndValue(curAttr)
        self.embedAttr[i].curName:setString(attributeCfg[curAttrId].name)
        local attrDesc = attributeCfg[curAttrId].desc == '0' and '' or attributeCfg[curAttrId].desc
        if curEmbedMaserCfg then
			self.embedAttr[i].curValue:setString("+"..curAttrValue..attrDesc)
		else
			self.embedAttr[i].curValue:setString("+0"..attrDesc)
		end

		if isMax then
			self.embedAttr[i].curName:setPositionX(106)
		end

		local curNameSize = self.embedAttr[i].curName:getContentSize()
		local posX = self.embedAttr[i].curName:getPositionX()
		self.embedAttr[i].curValue:setPositionX(posX+curNameSize.width+5)

		local nextAttr = nextEmbedMaserCfg.attribute[i]
        local nextAttrId,nextAttrValue = GlobalApi:getAttrTypeAndValue(nextAttr)
        local nextAttrName = isMax and "" or attributeCfg[nextAttrId].name
        local nextAttrValueStr = isMax and "" or nextAttrValue
        local attrDesc = attributeCfg[nextAttrId].desc == '0' and '' or attributeCfg[nextAttrId].desc
        if isMax then
        	attrDesc = ''
        end
        self.embedAttr[i].nextName:setString(nextAttrName)
		self.embedAttr[i].nextValue:setString("+"..nextAttrValueStr..attrDesc)
		local nextNameSize = self.embedAttr[i].nextName:getContentSize()
		local posX = self.embedAttr[i].nextName:getPositionX()
		self.embedAttr[i].nextValue:setPositionX(posX+nextNameSize.width+5)
	end

	local needGemNum = nextEmbedMaserCfg.needGemNum
	local needGemLevel = nextEmbedMaserCfg.needGemLevel

	local fitCont = 0
	for i=1,MAXEQUIPNUM do

		local partImg = self.embedPart[i]:getChildByName("img")
		partImg:setScale(0.8)
		local partObj = self.obj:getPartByIndex(i)
		if partObj then

			partImg:loadTexture(partObj:getIcon())
			local gems = partObj:getGems()
			local hasNum = 0
			for j=1,PART_GEMS_COUNT do
				if gems[j]  then
	            	local gemLv = gems[j]:getLevel()
	                if gemLv >= needGemLevel then
	                    hasNum = hasNum + 1
	                end
	            end
			end

			if hasNum >= needGemNum then
				fitCont = fitCont + 1
				ShaderMgr:restoreWidgetDefaultShader(self.embedPart[i])
				ShaderMgr:restoreWidgetDefaultShader(partImg)
			else
				ShaderMgr:setGrayForWidget(self.embedPart[i])
				ShaderMgr:setGrayForWidget(partImg)
			end
		end
		
	end

	local str = fitCont.."/"..MAXEQUIPNUM
	local conditionTx = string.format(GlobalApi:getLocalStr_new("ROLE_MASTER_INFO2"),needGemNum,needGemLevel,str)
	self.embedConditionTx:setString(conditionTx)

end

function RoleMaserUI:update(obj)

	self.obj = obj
	self:awakeMasterInfo()
	self:embedMasterInfo()
end

return RoleMaserUI