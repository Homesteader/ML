local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleSuitUI = class("RoleSuitUI", ClassRoleBaseUI)
function RoleSuitUI:initPanel()

	self.panel = cc.CSLoader:createNode("csb/rolesuitpanel.csb")
	self.panel:setName('role_suit_panel')
	local bgimg = self.panel:getChildByName('bg_img')
	self.cardSv = bgimg:getChildByName("sv")
	self.cardSv:setScrollBarEnabled(false)
end

function RoleSuitUI:update(obj)

	self.obj = obj
	self.cardSv:setVisible(true)
	local attributeCfg = GameData:getConfData("attribute")
	local conf = GameData:getConfData("equipsuit")
	local equipCnf = GameData:getConfData("equipconf")
	local suitTab = {}
	local tabSize = 0
	for i=1,MAXEQUIPNUM do
		local equip = self.obj:getEquipByIndex(i)
		if equip then
			local suitId = equip:getSuitId()
			local suitConf = conf[suitId]
			if suitConf then
				tabSize = tabSize + 1
				if suitTab[suitId] then
					local cnt = suitTab[suitId].cnt
					cnt = cnt + 1
					suitTab[suitId].cnt = cnt
				else
					suitTab[suitId] = {}
					suitTab[suitId].cnt = 1

					--套装名字
					local suitName = suitConf.name
					suitTab[suitId].name = suitName

					--套装装备
					suitTab[suitId].equip = {}
					for j=1,MAXEQUIPNUM do
						local equipId = suitConf["equip"..j]
						suitTab[suitId].equip[j] = equipId
					end

					--套装属性加成
					suitTab[suitId].attr = {}
					for j=1,3 do
						local attr = suitConf["attribute"..(j*2)]
						suitTab[suitId].attr[j] = attr
					end
				end
			end
		end
	end

	local size1
	local i = 0
	for k,v in pairs(suitTab) do
		i = i +1
        local cell = self.cardSv:getChildByTag(i + 100)
	    local cellBg
	    if not cell then
		    local cellNode = cc.CSLoader:createNode('csb/rolesuitcell.csb')
		    cellBg = cellNode:getChildByName('cell_bg')
		    cellBg:removeFromParent(false)
		    cell = ccui.Widget:create()
		    cell:addChild(cellBg)
		    self.cardSv:addChild(cell,1,i+100)
	    else
		    cellBg = cell:getChildByName('cell_bg')
	    end
	    cell:setVisible(true)
	    size1 = cellBg:getContentSize()

	    --套装名字
	    local suitNameTx = cellBg:getChildByName("title_tx")
	    suitNameTx:setString(v.name)

	    --装备显示
	    for j=1,MAXEQUIPNUM do
	    	local outImg = cellBg:getChildByName("part_img_"..j)
	    	local equiImg = outImg:getChildByName("img")
	    	local equipId = v.equip[j]
	    	local quality = equipCnf[equipId].quality
	    	outImg:loadTexture(COLOR_FRAME_TYPE[quality])
	    	local equipIcon = equipCnf[equipId].icon
	    	equiImg:loadTexture("uires/icon/equip/" .. equipIcon)

	    	local equip = self.obj:getEquipByIndex(j)
	    	if equip then
	    		if equipId == equip:getId() then
		    		ShaderMgr:restoreWidgetDefaultShader(outImg)
					ShaderMgr:restoreWidgetDefaultShader(equiImg)
				else
					ShaderMgr:setGrayForWidget(outImg)
					ShaderMgr:setGrayForWidget(equiImg)
				end
	    	else
	    		ShaderMgr:setGrayForWidget(outImg)
				ShaderMgr:setGrayForWidget(equiImg)
	    	end
	    end

	    --套装属性
	    local suitCont = v.cnt
	    for j=1,3 do
	    	local attrBg = cellBg:getChildByName("add_bg"..j)
	    	local suitTx = attrBg:getChildByName("suit_tx")
	    	local attrTx = attrBg:getChildByName("attr_tx")
	    	local needSuitCnt = j*2
	    	local suitStr = string.format(GlobalApi:getLocalStr_new("ROLE_SUIT_INFO1"),needSuitCnt)
	    	suitTx:setString(suitStr)

	    	local attrStr = ''
	    	local attrCont = #v.attr[j]
	    	for attrIndex = 1,attrCont do
	    		local attr = v.attr[j][attrIndex]
	    		local attrId,attrValue = GlobalApi:getAttrTypeAndValue(attr)
	    		local attrDesc = attributeCfg[attrId].desc == '0' and '' or attributeCfg[attrId].desc
		    	local attrName = attributeCfg[attrId].name
		    	local attrValueStr = "+"..attrValue..attrDesc
		    	attrStr = attrStr .. attrName..attrValueStr.." "
	    	end
	    	attrTx:setString(attrStr)

	    	if suitCont >= needSuitCnt then
	    		suitTx:setTextColor(COLOR_TYPE.GREEN1)
	    		suitTx:enableOutline(COLOROUTLINE_TYPE.GREEN1, 2)
	    		attrTx:setTextColor(COLOR_TYPE.GREEN1)
	    		attrTx:enableOutline(COLOROUTLINE_TYPE.GREEN1, 2)
	    	else
	    		suitTx:setTextColor(COLOR_TYPE.GRAY1)
	    		suitTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
	    		attrTx:setTextColor(COLOR_TYPE.GRAY1)
	    		attrTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
	    	end
		end

	end

	--没有套装
	if not size1 then
		self.cardSv:setVisible(false)
		return 
	end

	local count = i
    local size = self.cardSv:getContentSize()
    if count > 0 then
	    if count * size1.height > size.height then
		    self.cardSv:setInnerContainerSize(cc.size(size.width,count * size1.height))
	    else
		    self.cardSv:setInnerContainerSize(size)
	    end
    
	    local function getPos(i)
	        local size2 = self.cardSv:getInnerContainerSize()
		    return cc.p(0,size2.height - size1.height* i)
	    end
	    for i=1,count do
		    local cell = self.cardSv:getChildByTag(i + 100)
		    if cell then
			    cell:setPosition(getPos(i))
		    end
	    end
    end
end

return RoleSuitUI