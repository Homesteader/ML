local RaidsUI = class("RaidsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RaidsUI:ctor(awards,id)

	self.uiIndex = GAME_UI.UI_RAIDSUI
	self.awards = awards
	self.isEnd = false
	self.id = id
	self.oldNum = 0

end

function RaidsUI:getPos(i,size)
	local size1 = self.awardSv:getInnerContainerSize()
	return cc.p(0,size1.height - i*size.height)
end

function RaidsUI:updateAward(node,index,maxIndex)
	local awards = self.awards[index]
	local pl = node:getChildByName('award_pl')
	local otherAwards = {}
	local userAwards = {}
	local awardInfo = DisplayData:getDisplayObjs(awards)
	for k, v in pairs(awardInfo) do
        if v:getType() == "user" then
            local name = v:getId()
            if userAwards[name] then
                userAwards[name] = userAwards[name] + v:getNum()
            else
                userAwards[name] = v:getNum()
            end
        else
            otherAwards[#otherAwards + 1] = v
        end
    end
    local pos = cc.p(84,64)
	for i=1,5 do
		local str = 'award_bg_'..i..'_img'
		local awardBgImg = pl:getChildByName(str)
		if not awardBgImg then
		    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
		    awardBgImg = tab.awardBgImg
		    awardBgImg:setTouchEnabled(true)
		    awardBgImg:setPosition(cc.p(pos.x + 110 * i,pos.y))
		    awardBgImg:setName(str)
		    pl:addChild(awardBgImg)
		end
		if otherAwards[i] then
			awardBgImg:setVisible(true)
			ClassItemCell:updateItem(awardBgImg, otherAwards[i], 2)
			local numTx = awardBgImg:getChildByName('lv_tx')
			local doubleImg = awardBgImg:getChildByName('double_img')
			numTx:setVisible(true)
            if otherAwards[i]:getObjType() == 'equip' then
                numTx:setString('Lv.'..otherAwards[i]:getLevel())
            else
                numTx:setString('x'..otherAwards[i]:getNum())
            end
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(otherAwards[i],false)
                end
            end)
            ClassItemCell:setGodLight(awardBgImg)
            if otherAwards[i]:getExtraBg() then
                doubleImg:setVisible(true)
            else
                doubleImg:setVisible(false)
            end
		else
			awardBgImg:setVisible(false)
		end
	end
	local nameTx = pl:getChildByName('name_tx')
	nameTx:setString(string.format(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX8'),index))

end

function RaidsUI:update()
	self.currMax = self.currMax + 1
	local node = cc.CSLoader:createNode("csb/raidscell.csb")
	local pl = node:getChildByName('award_pl')
    pl:removeFromParent(false)
    local widget = ccui.Widget:create()
    widget:addChild(pl)
	local size = pl:getContentSize()
	self.awardSv:addChild(widget)
	self.cells[#self.cells + 1] = widget
	
	self.awardSv:setInnerContainerSize(cc.size(self.awardSv:getContentSize().width,self.currMax*size.height))
	for i,v in ipairs(self.cells) do
		self:updateAward(v,i,self.currMax)
		v:setPosition(self:getPos(i,size))
	end
	self.awardSv:jumpToBottom()
	if self.currMax >= self.maxAward then
		self.actionEnd = true
		local userAwards = {}
		local materialAwards = {}
		local equipAwards = {}
		for i=self.oldNum + 1,#self.awards do
			for j,k in ipairs(self.awards[i]) do
		        if k[1] == "user" then
		            userAwards[k[2]] = (userAwards[k[2]] or 0) + k[3]
		        elseif k[1] == "material" then
		            materialAwards[k[2]] = (materialAwards[k[2]] or 0) + k[3]
		        else
		            equipAwards[#equipAwards + 1] = k
		        end
			end
		end
		local awards = {}
		for k,v in pairs(userAwards) do
			local tab = {'user',k,v}
			awards[#awards + 1] = tab
		end
		for k,v in pairs(materialAwards) do
			local tab = {'material',tonumber(k),v}
			awards[#awards + 1] = tab
		end
		for k,v in pairs(equipAwards) do
			awards[#awards + 1] = v
		end
		local showWidgets = {}
		for i,v in ipairs(awards) do
			local awardTab = DisplayData:getDisplayObj(v)
			local w = cc.Label:createWithTTF(GlobalApi:getLocalStr_new('COMMON_STR_CONGRATS')..':'..awardTab:getName()..'x'..awardTab:getNum(), 'font/gamefont.ttf', 24)
			w:setTextColor(awardTab:getNameColor())
			w:enableOutline(awardTab:getNameOutlineColor(),1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		end
		promptmgr:showAttributeUpdate(showWidgets)
		self.oldNum = #self.awards
	else
		self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
			self:update()
	    end)))
	end
end

function RaidsUI:init()
	local raidsBgImg = self.root:getChildByName("raids_bg_img")
	local raidsImg = raidsBgImg:getChildByName("raids_nei_bg_img")
    self:adaptUI(raidsBgImg, raidsImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    raidsImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = raidsImg:getChildByName('close_btn')
    local infoTx = closeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr_new('COMMON_STR_OK'))
    local raidsBtn = raidsImg:getChildByName('raids_btn')

    local nameTx = raidsImg:getChildByName('city_name_tx')
    nameTx:setString(GlobalApi:getLocalStr_new('CUSTOMS_MAP_INFOTX9'))
    self.cells = {}
    self.maxAward = #self.awards
	self.currMax = 0
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           MapMgr:hideRainsPanel()
        end
    end)


	self.awardSv = raidsImg:getChildByName('award_sv')
	self.awardSv:setScrollBarEnabled(false)
	self.awardSv:setAnchorPoint(cc.p(0, 1))
	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
		self:update()
    end)))
end

return RaidsUI