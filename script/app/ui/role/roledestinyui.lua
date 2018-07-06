local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleDestinyUI = class("RoleDestinyUI", ClassRoleBaseUI)
function RoleDestinyUI:initPanel()

	self.panel = cc.CSLoader:createNode("csb/roledestinypanel.csb")
	self.panel:setName('role_destiny_panel')
	local bgimg = self.panel:getChildByName('bg_img')
	self.heroSv = bgimg:getChildByName("other_sv")
	self.heroSv:setScrollBarEnabled(false)

	self.lordPL = bgimg:getChildByName("lord_pl")
	self.lordSv = self.lordPL:getChildByName("lord_sv")
	self.lordSv:setScrollBarEnabled(false)
	local lordtitleTx = self.lordPL:getChildByName("title_tx")
	lordtitleTx:setString(GlobalApi:getLocalStr_new("ROLE_DESTINY_TITLE"))
	local tipTx = self.lordPL:getChildByName("tip_tx")
	tipTx:setString(GlobalApi:getLocalStr_new("ROLE_DESTINY_INFO1"))

end

function RoleDestinyUI:update(roleObj)

	self.roleObj = roleObj
	local isLord = self.roleObj:isJunZhu()
	self.heroSv:setVisible(not isLord)
	self.lordPL:setVisible(isLord)

	if isLord then
		self:updateLordDestiny()
	else
		self:updateHeroDestiny()
	end
end

--刷新主公缘分
function RoleDestinyUI:updateLordDestiny()
end

--刷新其他英雄缘分
function RoleDestinyUI:updateHeroDestiny()

	local heroId = self.roleObj:getId()
	local heroBaseInfo,heroCombatInfo,heroModelInfo = GlobalApi:getHeroConf(heroId)
	if not heroBaseInfo or not heroCombatInfo or not heroModelInfo then
		return
	end

	local innategroupId = heroCombatInfo.innateGroup
	local innategroupCfg = GameData:getConfData("innategroup")[innategroupId]
	local teamheroID = innategroupCfg.teamheroID
	local innateCfg = GameData:getConfData("innate")
	local fateCfg = GameData:getConfData("fate")
	local attributeCfg = GameData:getConfData("attribute")
	local roleCardMap = BagData.roleCardMap

	local size1
	local sizeTab = {}

	--羁绊缘分
	if teamheroID ~= 0 then 							--teamheroID:0 没有羁绊缘分
		local cell = self.heroSv:getChildByTag(1 + 100)
	    local cellBg
	    if not cell then
		    local cellNode = cc.CSLoader:createNode('csb/herodestinycell1.csb')
		    cellBg = cellNode:getChildByName('cell_bg')
		    cellBg:removeFromParent(false)
		    cell = ccui.Widget:create()
		    cell:addChild(cellBg)
		    self.heroSv:addChild(cell,1,1+100)
	    else
		    cellBg = cell:getChildByName('cell_bg')
	    end
	    size1 = cellBg:getContentSize()
	    sizeTab[1] = size1

	    local titleTx = cellBg:getChildByName("title_tx")
	    titleTx:setString(GlobalApi:getLocalStr_new("ROLE_DESTINY_TITLE1"))

	    local mineHeroBg = cellBg:getChildByName("hero_img")
	    local mineHeroHead = mineHeroBg:getChildByName("img")
	    mineHeroHead:loadTexture(self.roleObj:getIcon())
	    local mineHeroName = mineHeroBg:getChildByName("name")
	    mineHeroName:setString(self.roleObj:getName())

	    local teamheroInfo,teamheroCombatInfo,teamheroModelInfo = GlobalApi:getHeroConf(teamheroID)
		if not teamheroInfo or not teamheroCombatInfo or not teamheroModelInfo then
			return
		end

		local teamHeroBg = cellBg:getChildByName("hero_img1")
	    local teamHeroHead = teamHeroBg:getChildByName("img")
	    teamHeroHead:loadTexture('uires/icon/hero/' .. teamheroModelInfo['headIcon'])
	    local teamHeroName = teamHeroBg:getChildByName("name")
	    teamHeroName:setString(teamheroInfo.heroName)

	    --突破等级
	    local mineTuPoLv = self.roleObj:getTalent()
	    local otherTuPoLv = 0
	    --是否是上阵英雄
	    local battleHeroObj = RoleData:getRoleById(teamheroID)
	    if battleHeroObj then
	    	ShaderMgr:restoreWidgetDefaultShader(teamHeroBg)
			ShaderMgr:restoreWidgetDefaultShader(teamHeroHead)
			teamHeroName:setTextColor(COLOR_TYPE.YELLOW1)
			teamHeroName:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
			otherTuPoLv = battleHeroObj:getTalent()
	    else
	    	ShaderMgr:setGrayForWidget(teamHeroBg)
			ShaderMgr:setGrayForWidget(teamHeroHead)
			teamHeroName:setTextColor(COLOR_TYPE.GRAY1)
			teamHeroName:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
	    end

	    --显示缘分加成
	    local fatebg = cellBg:getChildByName("fate_bg")
	    for i=1,4 do
	    	local conditionTx = fatebg:getChildByName("condition_tx"..i)
	    	local conditionValueTx = fatebg:getChildByName("condition_value"..i)
	    	local needValue = innategroupCfg.teamvaluegroup[i]
	    	if needValue == 0 then
	    		conditionTx:setString(GlobalApi:getLocalStr_new("ROLE_DESTINY_INFO3"))
	    	else
	    		local str = string.format(GlobalApi:getLocalStr_new("ROLE_DESTINY_INFO2"),needValue)
	    		conditionTx:setString(str)
	    	end

	    	local teamId,teamValues = innategroupCfg["teamId"..i],innategroupCfg["teamValues"..i] 
	    	local desc = innateCfg[teamId].desc
	    	conditionValueTx:setString(desc.." "..teamValues)
	    	if battleHeroObj then
	    		
	    		if mineTuPoLv >= needValue and otherTuPoLv >= needValue then
		    		conditionTx:setTextColor(COLOR_TYPE.YELLOW1)
					conditionTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
		    		conditionValueTx:setTextColor(COLOR_TYPE.GREEN1)
			    	conditionValueTx:enableOutline(COLOROUTLINE_TYPE.GREEN1, 2)
			    else
			    	conditionTx:setTextColor(COLOR_TYPE.GRAY1)
					conditionTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
		    		conditionValueTx:setTextColor(COLOR_TYPE.GRAY1)
			    	conditionValueTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
			    end
	    	else
	    		conditionTx:setTextColor(COLOR_TYPE.GRAY1)
				conditionTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
	    		conditionValueTx:setTextColor(COLOR_TYPE.GRAY1)
		    	conditionValueTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
	    	end 
	    end
	end
	
	--图鉴缘分标题
	local titleBg = self.heroSv:getChildByName("title_bg")
	local titleTx = titleBg:getChildByName("title_tx")
	titleTx:setString(GlobalApi:getLocalStr_new("ROLE_DESTINY_TITLE2"))
	local tipTx = titleBg:getChildByName("tip_tx")
	tipTx:setString(GlobalApi:getLocalStr_new("ROLE_DESTINY_INFO4"))
    titleBg:setVisible(false)

	--图鉴缘分
	local fategroup = heroCombatInfo.fateGroup
	local fateCont = #fategroup

	if fateCont >= 1 and fategroup[1] ~=0 then

		titleBg:setTag(#sizeTab+100+1)
		local titlesize1 = titleBg:getContentSize()
		sizeTab[#sizeTab+1] = titlesize1
		titleBg:setVisible(true)

		local fateIndex = 0
		for i=#sizeTab+1,#sizeTab+fateCont do
	    	local cell = self.heroSv:getChildByTag(i + 100)
		    local cellBg
		    if not cell then
			    local cellNode = cc.CSLoader:createNode('csb/herodestinycell2.csb')
			    cellBg = cellNode:getChildByName('cell_bg')
			    cellBg:removeFromParent(false)
			    cell = ccui.Widget:create()
			    cell:addChild(cellBg)
			    self.heroSv:addChild(cell,1,i+100)
		    else
			    cellBg = cell:getChildByName('cell_bg')
		    end
		    size1 = cellBg:getContentSize()
		    sizeTab[#sizeTab+1] = size1

		    fateIndex = fateIndex + 1
		    local fateId = fategroup[fateIndex]
		    local fateName = fateCfg[fateId].name
		    local fatebg = cellBg:getChildByName("fate_bg")
		    local conditionTx = fatebg:getChildByName("condition_tx")
		    conditionTx:setString("【"..fateName.."】")

		    --属性显示
		    local attrStr = ''
		    for j=1,2 do
		    	local attrIdTab = fateCfg[fateId]["att1"..j]
		    	local attrValue = fateCfg[fateId]["value1"..j]
		    	if attrIdTab then
		    		if #attrIdTab > 1 then
		    			local attrName = GlobalApi:getLocalStr_new("ROLE_STR_ATTR_DEFENSE")
		    			local str = attrName..attrValue.."%"
		    			if j==2 and attrIdTab[1] ~= 0 then
		    				attrStr = attrStr .. "，" .. str
		    			elseif j==1 then
		    				attrStr = attrStr .. str
		    			end
		    		else
		    			local attrId = attrIdTab[1]
		    			if attrId ~= 0 then
			    			local attrName = attributeCfg[attrIdTab[1]].name
			    			local str = attrName..attrValue.."%"
			    			if j==2 and attrIdTab[1] ~= 0 then
			    				attrStr = attrStr .. "，" .. str
			    			elseif j==1 then
			    				attrStr = attrStr .. str
			    			end
			    		end
		    		end
		    	end
		    end
		    local conditionValueTx = fatebg:getChildByName("condition_value")
		    conditionValueTx:setString(attrStr)

		    --图鉴英雄
		    local fateHeroTab = {}
		    for j=1,5 do
		    	local fateHeroId = fateCfg[fateId]["hid"..j]
		    	if heroId ~= fateHeroId then
		    		fateHeroTab[#fateHeroTab+1] = fateHeroId
		    	end
		    end

		    local ownCont = 0
		    for j=1,4 do
		    	local herobg = fatebg:getChildByName("head_img"..j)
		    	local heroNameTx = herobg:getChildByName("name")
		    	local heroHead = herobg:getChildByName("img")
		    	local fateHeroId = fateHeroTab[j]
		    	if not fateHeroId or fateHeroId == 0 then
		    		herobg:setVisible(false)
		    	else
		    		herobg:setVisible(true)
			    	local fateheroInfo,fateheroCombatInfo,fateheroModelInfo = GlobalApi:getHeroConf(fateHeroId)
					if not fateheroInfo or not fateheroCombatInfo or not fateheroModelInfo then
						return
					end
					if roleCardMap[fateHeroId] then
						ShaderMgr:restoreWidgetDefaultShader(herobg)
						ShaderMgr:restoreWidgetDefaultShader(heroHead)
						heroNameTx:setTextColor(COLOR_TYPE.YELLOW1)
						heroNameTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
						ownCont = ownCont + 1
					else
						ShaderMgr:setGrayForWidget(herobg)
						ShaderMgr:setGrayForWidget(heroHead)
						heroNameTx:setTextColor(COLOR_TYPE.GRAY1)
						heroNameTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
					end
				    heroHead:loadTexture('uires/icon/hero/' .. fateheroModelInfo['headIcon'])
				    heroNameTx:setString(fateheroInfo.heroName)
				end
		    end

		    if ownCont >= #fateHeroTab then
		    	conditionTx:setTextColor(COLOR_TYPE.YELLOW1)
		    	conditionTx:enableOutline(COLOROUTLINE_TYPE.YELLOW1, 2)
		    	conditionValueTx:setTextColor(COLOR_TYPE.GREEN1)
		    	conditionValueTx:enableOutline(COLOROUTLINE_TYPE.GREEN1, 2)
		    else
		    	conditionTx:setTextColor(COLOR_TYPE.GRAY1)
		    	conditionTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
		    	conditionValueTx:setTextColor(COLOR_TYPE.GRAY1)
		    	conditionValueTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
		    end
	    end
	end
    
    local count = #sizeTab
    local heightSum = 0
    for i=1,count do
    	heightSum = heightSum + sizeTab[i].height
    end

    local size = self.heroSv:getContentSize()
    if count > 0 then
	    if heightSum > size.height then
		    self.heroSv:setInnerContainerSize(cc.size(size.width,heightSum))
	    else
		    self.heroSv:setInnerContainerSize(size)
	    end

	    local function getPos(i)
	        local size2 = self.heroSv:getInnerContainerSize()
	        local delHeight = 0
	        for j=1,i do
	        	delHeight = delHeight + sizeTab[j].height
	        end
	        return cc.p(0,size2.height - delHeight)
	    end
	    for i=1,count do
		    local cell = self.heroSv:getChildByTag(i + 100)
		    if cell then
			    cell:setPosition(getPos(i))
		    end
	    end
    end
end

return RoleDestinyUI