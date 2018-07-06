local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")

local RoleLvUpUI = class("RoleLvUpUI", ClassRoleBaseUI)
local MAXDELTA = 0.2 -- 10sËõÐ¡Ò»±¶£¬×îµÍ0.05s
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

function  RoleLvUpUI:sortByQuality(arr)
	table.sort(arr, function (a, b)
			local q1 = a.quality
			local q2 = b.quality
			if q1 == q2 then
				local f1 = a.id
				local f2 = b.id
				return f1 < f2
			else
				return q1 < q2
			end
	end)
end

function RoleLvUpUI:initPanel()

    self.firstState = true
    self.isLvPostState = false
    self.istouch = false
    self.count = 1
	self.tiemdelta = 0
    self.allTime = 0
    self.initSpeed = 0
	self.isfirst = true
	self.curridx = 0
	self.mid = 0
	self.num = 0

	self.panel = cc.CSLoader:createNode("csb/rolelvuppanel.csb")
	self.panel:setName("role_lvup_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	local nor_pl = bgimg:getChildByName("nor_pl")

	local descTx = nor_pl:getChildByName("desc_tx")
	descTx:setString(GlobalApi:getLocalStr_new("ROLE_LV_DESC"))

	--标题
	self.titleTx = nor_pl:getChildByName("cur_title")

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

	--升级所需经验
	local needexpbg = nor_pl:getChildByName('desc_info_bg')
	self.needExpTx = needexpbg:getChildByName("text")

	--升级消耗道具
	local itembg = nor_pl:getChildByName('item_bg')
	self.costInfo = {}
    for i=1,3 do
    	local itemimg = itembg:getChildByName('iconbg_' .. i .. '_img')
    	local item = itemimg:getChildByName('item')
    	local numTx = itemimg:getChildByName('num_tx')
    	local addTx = itemimg:getChildByName('add_tx')
 		
    	self.costInfo[i] = {}
    	self.costInfo[i].numTx = numTx
    	self.costInfo[i].addTx = addTx
    	self.costInfo[i].item = item
    	self.costInfo[i].itemimg = itemimg
    	itemimg:addTouchEventListener(function (sender, eventType)

			if eventType ==  ccui.TouchEventType.canceled then -- 这里是鼠标拖到未选中的图片的区域的事件,逻辑和ended大部分一样
                self.istouch = false
                if self:judge(i) == false then
                    for j=1,3 do
                        self.costInfo[j].itemimg:setTouchEnabled(false)
                    end
                end
                if self.count == 2 then
                    return
                end

	   			if (self.isfirst  and self.tiemdelta < 0.5 ) then
                    if self:judge(i) == false then
                        self.count = 2
                    end
                    local function callBack()
                        self:lvUpPost(i)
                    end			
                    self.isLvPostState = true
                    self:refreshLvPostState()
                    self:calFunction(i,callBack)	
                    if self.num > 0 then
                        
                    else
                        self.tiemdelta = 0
		   			    self.mid = 0
		   			    self.level = 0
		   			    self.xp = 0
		   			    self.curridx = 0
                        for j=1,3 do
                            self.costInfo[j].itemimg:setTouchEnabled(true)
                        end
                    end
                    return
	   			end
	   			if self.num > 0 then
                    self:lvUpPost(i)
				else
					self.tiemdelta = 0
		   			self.mid = 0
		   			self.level = 0
		   			self.xp = 0
		   			self.curridx = 0
                    for j=1,3 do
                        self.costInfo[j].itemimg:setTouchEnabled(true)
                    end
				end
			elseif eventType == ccui.TouchEventType.began then
                self.allTime = 0
                self.initSpeed = MAXDELTA  
				self.isfirst = true
				local rolelvconf = GameData:getConfData('level')
				local materialobj = BagData:getMaterialById(self.itemdata[i].id)
				if materialobj == nil or (materialobj and materialobj:getNum() < 1)  then
					self.istouch = false
					self.tiemdelta = 0 
					self.isfirst = false
					promptmgr:showSystenHint(GlobalApi:getLocalStr_new('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
					GetWayMgr:showGetwayUI(materialobj,true)
					return
				elseif tonumber(self.obj:getLevel()) >= #rolelvconf then
					self.istouch = false
					self.tiemdelta = 0 
					self.isfirst = false
					promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LV_DESC4'), COLOR_TYPE.RED)
					return
				elseif tonumber(self.obj:getLevel() )>= tonumber(UserData:getUserObj():getLv()) then
					self.istouch = false
					self.tiemdelta = 0 
					self.isfirst = false
					promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LV_DESC5'), COLOR_TYPE.RED)
					return
				else
                    if self.count == 2 then
                        return
                    end
		   			self.istouch = true
		   			self.tiemdelta = 0
		   			self.mid = self.itemdata[i].id
		   			self.level = self.obj:getLevel()
		   			self.xp = self.obj:getXp()
		   			self.curridx = i
                    self:needExpNum(i)
		   		end
	   		elseif eventType ==  ccui.TouchEventType.ended then
 
                self.istouch = false
                if self:judge(i) == false then
                    for j=1,3 do
                        self.costInfo[j].itemimg:setTouchEnabled(false)
                    end
                end
                if self.count == 2 then
                    return
                end
	   			if (self.isfirst and self.tiemdelta < 0.5) then
                    if self:judge(i) == false then
                        self.count = 2
                    end    
                    local function callBack()
                        self:lvUpPost(i)
                    end
                    self.isLvPostState = true
                    self:refreshLvPostState()
	   				self:calFunction(i,callBack)
                    if self.num > 0 then
                        
                    else
                        self.tiemdelta = 0
		   			    self.mid = 0
		   			    self.level = 0
		   			    self.xp = 0
		   			    self.curridx = 0
                    end
                    return
	   			end
	   			if self.num > 0 then
                    self:lvUpPost(i)
				else    -- 按一次（不是长按），但是松手时间刚好大于0.5s，就会出现经验丹无法点击的情况
                    for j=1,3 do
                        self.costInfo[j].itemimg:setTouchEnabled(true)
                    end
					self.tiemdelta = 0
		   			self.mid = 0
		   			self.level = 0
		   			self.xp = 0
		   			self.curridx = 0
				end					
	   		end
	   	end)
    end

    --
    local uptipTx = itembg:getChildByName('tip_tx')
    uptipTx:setString(GlobalApi:getLocalStr_new("ROLE_LV_DESC3"))

    --升一级
    self.upgradeBtn = nor_pl:getChildByName('lvup_btn')
    local btntx = self.upgradeBtn:getChildByName("func_tx")
    btntx:setString(GlobalApi:getLocalStr_new("ROLE_LV_DESC1"))
    self.upgradeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            if self.isLvPostState == true then
                return
            end
            local rolelvconf = GameData:getConfData('level')
            if tonumber(self.obj:getLevel()) >= #rolelvconf then
			    promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LV_DESC4'), COLOR_TYPE.RED)
			    return
            end
            if tonumber(self.obj:getLevel() )>= tonumber(UserData:getUserObj():getLv()) then
			    promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LV_DESC5'), COLOR_TYPE.RED)
			    return
            end
            local oldlv = self.obj:getLevel()
            local remainXp = rolelvconf[oldlv].roleExp - self.obj:getXp()
            local temp = {}
            local xp = 0
            for i = 1,3 do
                local materialobj = BagData:getMaterialById(self.itemdata[i].id)
                if materialobj and materialobj:getNum() >= 1 then
                    local costExp = tonumber(materialobj.conf.useEffect)
                    local needMaxNum = 1
                    if remainXp <= costExp then
                        needMaxNum = 1
                    else
                        needMaxNum = math.ceil(remainXp/costExp)
                        if needMaxNum >= materialobj:getNum() then
                            needMaxNum = materialobj:getNum()
                        end
                    end
                    remainXp = remainXp - costExp*needMaxNum
                    local itemConf = {}
                    itemConf.id = self.itemdata[i].id
                    itemConf.needMaxNum = needMaxNum
                    table.insert(temp,itemConf)
                    xp = xp + costExp*needMaxNum
                    if remainXp <= 0 then
                        break
                    end
                end
            end
            if #temp == 0 or remainXp > 0 then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr_new('ROLE_LV_DESC6'),self.obj:getName()), COLOR_TYPE.RED)
                local obj = BagData:getMaterialById(self.itemdata[1].id)
                GetWayMgr:showGetwayUI(obj,true)
            else
                local function callBack(jsonObj)
                    local code = jsonObj.code
		            if code == 0 then
			            local awards = jsonObj.data.awards
			            GlobalApi:parseAwardData(awards)
			            local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end

                        local nextLv = self.obj:getLevel() + 1
                        local maxLv = tonumber(UserData:getUserObj():getLv())
                        local allXp = xp + self.obj:getXp() - rolelvconf[self.obj:getLevel()].roleExp   -- 至少升1级
                        local remainXp = allXp
                        for i = nextLv,maxLv do
                            local roleExp = rolelvconf[i].roleExp
                            local nowXp = remainXp - roleExp
                            nextLv = i
                            if nowXp < 0 then
                                break
                            else
                                remainXp = remainXp - roleExp
                            end
                            if i == maxLv and nowXp >= 0 then
                                remainXp = roleExp - 1
                            end

                        end
			            self.obj:setLevelandXp(nextLv,remainXp)
			            self.obj:setFightForceDirty(true)
                        self:playUpgradeEffect()
		            else
			            promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LVUP_FAIL'),COLOR_TYPE.RED)
		            end
		            RoleMgr:updateRoleList()
		            RoleMgr:updateRoleMainUI()
                end
                RoleMgr:showRoleLvUpOneLevelPannel(temp,self.obj:getPosId(),callBack)
            end
        end
    end)
	
	--升5级
    self.upgrade5Btn = nor_pl:getChildByName('lvup_btn5')
    local btntx1 = self.upgrade5Btn:getChildByName("func_tx")
    btntx1:setString(GlobalApi:getLocalStr_new("ROLE_LV_DESC2"))
    self.upgrade5Btn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            if self.isLvPostState == true then
                return
            end
            self:requestLevelUp(5)
        end
    end)

	self.itemdata = {}
	local itemdat = GameData:getConfData('item')
	for k,v in pairs(itemdat) do
		if tostring(v.useType) == 'xp' then
			table.insert(self.itemdata,v)
		end
	end
	self:sortByQuality(self.itemdata)
	self.panel:scheduleUpdateWithPriorityLua(function (dt)
		self:updatepush(dt)
	end, 0)
    
end

function RoleLvUpUI:judge(i)
    local rolelvconf = GameData:getConfData('level')
	local materialobj = BagData:getMaterialById(self.itemdata[i].id)
	if materialobj == nil then
		return true
	elseif tonumber(self.obj:getLevel()) >= #rolelvconf then
		return true
	elseif tonumber(self.obj:getLevel() )>= tonumber(UserData:getUserObj():getLv()) then
		return true
	else
        return false
    end
end

function RoleLvUpUI:updateUI(oldlv,level,xp,num,index,callBack)

	local rolelvconf = GameData:getConfData('level')[self.level]
	local percent = string.format("%.2f", xp / rolelvconf.roleExp*100) 
	local materialobj = BagData:getMaterialById(self.itemdata[self.curridx].id)
	local num = materialobj:getNum()-self.num
	RoleMgr:updateMainUIExpBar(oldlv,percent,level,index,callBack)
	self.costInfo[self.curridx].numTx:setString(num)

	local midX, midY = RoleMgr:getRoleMainExpBarPos()
    local fSprite = self.costInfo[self.curridx].itemimg:clone()
    local eSprite = self.costInfo[self.curridx].item:clone()

    local size = self.costInfo[self.curridx].itemimg:getContentSize()
	local pos = self.costInfo[self.curridx].itemimg:convertToWorldSpace(cc.p(self.costInfo[self.curridx].itemimg:getPosition()))
	fSprite:addChild(eSprite)
	local startPos = cc.p(500+(self.curridx-1)*100,pos.y)
	fSprite:setPosition(startPos)
	UIManager:addAction(fSprite)

   	local label = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
	label:setAnchorPoint(cc.p(0.5, 0.5))
	label:setTextColor(COLOR_TYPE.GREEN)
	label:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	label:setPosition(cc.p(midX, midY))
	label:setString('EXP+'..materialobj:getUseEffect())
	UIManager:addAction(label)

    label:runAction(cc.Sequence:create(
	cc.MoveBy:create(1, cc.p(0, 100)), 
	cc.CallFunc:create(function (  )
		label:removeFromParent()
	end)))

	local endPos = cc.p(midX,midY)
	local scendPos = cc.p(startPos.x-207,startPos.y+150+(self.curridx-1)*30)
	local bezier1 ={
        startPos,
        scendPos,
        endPos
    }

   	local action = cc.Spawn:create(cc.ScaleTo:create(1, 0.2),  cc.BezierTo:create(1, bezier1))
    fSprite:runAction(cc.Sequence:create(action, cc.CallFunc:create(function ()
            fSprite:removeFromParent()
   	 end)))
end

--- 计算一直点击最多需要多少个同类型的经验丹
function RoleLvUpUI:needExpNum(index)

    local oldlv = self.level
    local newlv = UserData:getUserObj():getLv()
    local rolelvconf = GameData:getConfData('level')
    
    local allExp = 0
    for i = oldlv,newlv do
        allExp = allExp + rolelvconf[i].roleExp
    end

    local xp  = self.xp
    allExp = allExp - xp

    local materialobj = BagData:getMaterialById(self.itemdata[index].id)
    local costExp = tonumber(materialobj.conf.useEffect)
    if allExp <= costExp then
        self.maxNum = 1
    else
        self.maxNum = math.ceil(allExp/costExp)
    end
    print('====================' .. self.maxNum)

end


function RoleLvUpUI:calFunction(index,callBack)
	local oldlv  = self.level
    local judge = true
	if not self.itemdata[self.curridx] or (not self.itemdata[self.curridx].id) then
		return
	end
	local materialobj = BagData:getMaterialById(self.itemdata[self.curridx].id)
	local rolelvconf = GameData:getConfData('level')[self.level]
	if materialobj == nil then
		promptmgr:showSystenHint(GlobalApi:getLocalStr_new('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
		return
	end
	local havenum = materialobj:getNum()
	local rolelvconf = GameData:getConfData('level')
	if tonumber(self.num) < tonumber(havenum) then
		self.num = self.num + 1
		self.xp = self.xp + tonumber(materialobj:getUseEffect())
		local needlvup = true
		local xp = 0
		while needlvup do 
			if tonumber(self.level) >= tonumber(UserData:getUserObj():getLv()) then
				self.level = UserData:getUserObj():getLv()
				if self.xp >= rolelvconf[self.level].roleExp then
					self.xp = rolelvconf[self.level].roleExp-1
				end
				break
			end
			if self.xp >= rolelvconf[self.level].roleExp then
				self.xp = self.xp - rolelvconf[self.level].roleExp
				self.level = self.level + 1
			else
				needlvup = false
			end
		end
	else
		if self.num > 0 then    -- 当道具数量到最后的时候，数量不足，则不更新ui
			self:lvUpPost(index)
            self.itembg[self.curridx]:loadTexture('uires/ui/common/common_bg_6.png')
            judge = false
		end
	end

    if judge == true then
	    self:updateUI(oldlv,self.level,self.xp,self.num,index,callBack)
    end
end

--计算长按时间
function RoleLvUpUI:updatepush(dt)

    if self.istouch then
        self.allTime = self.allTime + dt
        if self.allTime > 5 then-- 5秒缩小一倍
            self.allTime = 0
            self.initSpeed = self.initSpeed/2
            if self.initSpeed < 0.05 then
                self.initSpeed = 0.05
            end
        end
    end

	self.tiemdelta = self.tiemdelta + dt 
	if self.isfirst then
		if self.istouch and self.tiemdelta > FIRSTDELT then
            self.isLvPostState = true
            self:refreshLvPostState()
			self:calFunction(self.obj)
			self.tiemdelta = 0
			self.isfirst = false
		end
	else
		if self.istouch and self.tiemdelta > self.initSpeed then
        
            if self.maxNum and self.num < self.maxNum then
                self:calFunction(self.obj)
            end	
		    self.tiemdelta = 0
		end
	end
end

-- 检查经验道具是否足够
-- cousumeExp：需要消耗的经验值
function RoleLvUpUI:checkItemEnoughOrNot(consumeExp)
    local isEnough = false
    local consumeArr = {}   -- 预计消耗列表
    local lackExp = consumeExp;
    for i = 1, 3 do
        local itemobj = BagData:getMaterialById(self.itemdata[i].id)
        if itemobj then
            local itemExp = self.itemdata[i].useEffect * itemobj:getNum()

            if itemExp >= lackExp then
                local realItemCount = math.ceil(lackExp / self.itemdata[i].useEffect)
                local itemCell = {itemID = self.itemdata[i].id, itemNum = realItemCount}
                table.insert(consumeArr, itemCell)
                isEnough = true
                break
            else
                -- 全部消耗
                local itemCell = {itemID = self.itemdata[i].id, itemNum = itemobj:getNum()}
                table.insert(consumeArr, itemCell)
                lackExp = lackExp - itemExp
            end
        end
    end

    return isEnough, consumeArr
end

-- 根据道具经验获得能升多少级
function RoleLvUpUI:GetLevelCountByExp(itemExp)
    local lvconf = GameData:getConfData('level')
    local maxLevel = UserData:getUserObj():getLv()
    local toLevel = self.obj:getLevel()
    local toExp = 0
    while true do
        if toLevel >= maxLevel then
            toLevel = maxLevel
            if itemExp >= lvconf[toLevel].roleExp then
                toExp = lvconf[toLevel].roleExp - 1
            else
                toExp = itemExp
            end
            break
        end

        if itemExp - lvconf[toLevel].roleExp >= 0 then
            itemExp = itemExp - lvconf[toLevel].roleExp
            toLevel = toLevel + 1
        else
            toExp = itemExp
            break
        end
    end

    return toLevel,toExp
end

function RoleLvUpUI:getItemTotalExp(itemList)
    local itemdat = GameData:getConfData('item')
    local totalExp = 0
    for i = 1,#itemList do
        totalExp = totalExp + itemdat[itemList[i].itemID].useEffect * itemList[i].itemNum
    end

    return totalExp
end

--可以升5级
--count:等级
function RoleLvUpUI:requestLevelUp(count)

	for i=1,3 do
		self.costInfo[i].itemimg:setTouchEnabled(false)
	end

    local maxLevel = UserData:getUserObj():getLv()  -- 最高不能超过君主等级
    if self.obj:getLevel() >= maxLevel then
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LV_DESC5'),COLOR_TYPE.RED)
        return
    end

    local levelTo = self.obj:getLevel() + count
    if levelTo > maxLevel then
        levelTo = maxLevel
    end

    -- 检查经验丹够不够
    local lvconf = GameData:getConfData('level')
    local totalNeedExp = 0
    for i = self.obj:getLevel(), (levelTo - 1) do
        totalNeedExp = totalNeedExp + lvconf[i].roleExp
    end

    -- 算出还缺多少经验
    local lackExp = totalNeedExp - self.obj:getXp()
    local isEnougn, consumeItems = self:checkItemEnoughOrNot(lackExp)

    local totalExp = self.obj:getXp() + self:getItemTotalExp(consumeItems)
    self.level,self.exp = self:GetLevelCountByExp(totalExp)

    if self.level <= self.obj:getLevel() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr_new('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
        return
    end

    if self.level < levelTo then
        -- 不够升五级，安装实际等级再计算一遍，所需的道具，刚刚好升到对应等级就好，不要多吃
        totalNeedExp = 0
        for i = self.obj:getLevel(), (self.level - 1) do
            totalNeedExp = totalNeedExp + lvconf[i].roleExp
        end

        lackExp = totalNeedExp - self.obj:getXp()
        isEnougn, consumeItems = self:checkItemEnoughOrNot(lackExp)

        totalExp = self.obj:getXp() + self:getItemTotalExp(consumeItems)
        self.level,self.exp = self:GetLevelCountByExp(totalExp)
    end

    local args = {
		pos = self.obj:getPosId(),
		toLevel = self.level,
        toExp = self.exp,
        arr = consumeItems
	}

	MessageMgr:sendPost("level_to", "hero", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
			local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			self.obj:setLevelandXp(self.level,self.exp)
			self.obj:setFightForceDirty(true)

            if self.obj:getLevelIsChange() then
                self:playUpgradeEffect()     
            end

            RoleMgr:updateRoleList()
		    RoleMgr:updateRoleMainUI()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LVUP_FAIL'),COLOR_TYPE.RED)
		end
		self.num = 0
		self.xp = 0
		self.level = 0
		self.tiemdelta = 0
		self.mid = 0
		self.curridx = 0
        GlobalApi:timeOut(function()
            self.isLvPostState = false
            for i=1,3 do
                if self.firstState and self.costInfo[i] then
                    self.costInfo[i].itemimg:setTouchEnabled(true)              
                end
			    self.count = 1
		    end
            self:refreshLvPostState()
        end,0.5)
	end)
end

--发送吃经验丹的消息
function RoleLvUpUI:lvUpPost(index)
	for i=1,3 do
		self.costInfo[i].itemimg:setTouchEnabled(false)
	end
	self.istouch = false
	local args = {
		mid = self.mid,
		num = self.num,
		pos = self.obj:getPosId(),
		level = self.level,
		xp = self.xp
	}
	MessageMgr:sendPost("level_up", "hero", json.encode(args), function (jsonObj)
		print(json.encode(jsonObj))
		local code = jsonObj.code
		if code == 0 then
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
			local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			self.obj:setLevelandXp(self.level,self.xp)
			self.obj:setFightForceDirty(true)

            if index and index == 1 and self.obj:getLevelIsChange() then
                self:playUpgradeEffect()     
            end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new('ROLE_LVUP_FAIL'),COLOR_TYPE.RED)
		end
		RoleMgr:updateRoleList()
		RoleMgr:updateRoleMainUI()
		self.num = 0
		self.xp = 0
		self.level = 0
		self.tiemdelta = 0
		self.mid = 0
		self.curridx = 0
        GlobalApi:timeOut(function()
            self.isLvPostState = false
            for i=1,3 do
                if self.firstState and self.costInfo[i] then
                    self.costInfo[i].itemimg:setTouchEnabled(true)              
                end
			    self.count = 1
		    end
            self:refreshLvPostState()
        end,0.5)
	end)
end

function RoleLvUpUI:update(obj)

	self.obj = obj

	local curlv = self.obj:getLevel()
	local curExp = self.obj:getXp()
	local nextlv = curlv+1
	local rolelvconf = GameData:getConfData('level')
	local zhujueLv = UserData:getUserObj():getLv()
	local maxLv = #rolelvconf >= zhujueLv and zhujueLv or #rolelvconf
	local isMax = curlv >= maxLv
	if nextlv >= maxLv then
		nextlv = maxLv
	end
	self.attrArrowImg:setVisible(not isMax)

	--显示等级
	self.titleTx:setString("Lv."..curlv)
	
	--显示属性
	local att = RoleData:getPosAttByPos(obj)
	local curattarr = {}
    curattarr[1] = math.floor(att[1])
    curattarr[2] = math.floor(att[4]) 
   	curattarr[3] = math.floor(att[2])
    curattarr[4] = math.floor(att[3])
    
    local objtemp = clone(self.obj)
    objtemp:setLevelandXp(nextlv,curExp)
    local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    local nextattarr = {}
    nextattarr[1] = math.floor(atttemp[1])
    nextattarr[2] = math.floor(atttemp[4])
    nextattarr[3] = math.floor(atttemp[2])
    nextattarr[4] = math.floor(atttemp[3])

    local addarr = {}
    addarr[1] = math.floor(nextattarr[1] -curattarr[1])
    addarr[2] = math.floor(nextattarr[2] -curattarr[2])
    addarr[3] = math.floor(nextattarr[3] -curattarr[3])
    addarr[4] = math.floor(nextattarr[4] -curattarr[4])

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
        local posX = isMax and centerPosX or leftPosX
        self.attarr[i].curAttrName:setPositionX(posX)
        self.attarr[i].curAttrValue:setPositionX(posX+offsetX)
    end
	
	--显示升级所需经验
	local percent, curexp ,needexp = self.obj:getExpPercent()
	local deltaExp = isMax and 'max' or needexp-curexp
	if curexp and needexp then
		self.needExpTx:setString(deltaExp)
	end

	--显示消耗的道具
	for i=1,3 do
		if self.isLvPostState == false then -- 切换页面的时候，不在升级的状态设置可触摸
            self.costInfo[i].itemimg:setTouchEnabled(true)
        end
		self.costInfo[i].itemimg:loadTexture(COLOR_ITEMFRAME[FRAME_COLOR[self.itemdata[i].quality]])
		self.costInfo[i].item:loadTexture('uires/icon/material/' .. self.itemdata[i].icon)
		local itemobj = BagData:getMaterialById(self.itemdata[i].id)
		if itemobj then
			self.costInfo[i].numTx:setString(itemobj:getNum())
		else
			self.costInfo[i].numTx:setString('0')
		end
		self.costInfo[i].addTx:setString('+' .. self.itemdata[i].useEffect)
	end
    self:refreshLvPostState()
end

function RoleLvUpUI:refreshLvPostState()
    if self.isLvPostState == false then
        ShaderMgr:restoreWidgetDefaultShader(self.upgradeBtn)
        ShaderMgr:restoreWidgetDefaultShader(self.upgrade5Btn)
        self.upgradeBtn:setTouchEnabled(true)
        self.upgrade5Btn:setTouchEnabled(true)
    else
        ShaderMgr:setGrayForWidget(self.upgradeBtn)
        ShaderMgr:setGrayForWidget(self.upgrade5Btn)
        self.upgradeBtn:setTouchEnabled(false)
        self.upgrade5Btn:setTouchEnabled(false)
    end
end

function RoleLvUpUI:playUpgradeEffect()
    RoleMgr:playRoleUpgradeEffect()
end


return RoleLvUpUI