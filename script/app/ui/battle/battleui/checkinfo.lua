local CheckInfoUI = class("CheckInfoUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassEquipObj = require('script/app/obj/equipobj')
function CheckInfoUI:ctor(data, uid)
    self.uiIndex = GAME_UI.UI_CHECKINFO
	self.data=data
	self.selected=1
	self.targetName=data.info.un
	self.isfriend = data.isFriend
	self.uid = tonumber(uid)
	self.heroList={}
	local tempList={}
	
	local isDroid=self:isDroid(uid)
	local headIcon=""
	local dragonUrl=""
	if isDroid==false then
		headIcon=GameData:getConfData("settingheadicon")[data.info.headpic].icon
		local id = tonumber(data.info.dragon)
		if id <= 0 then
			id = 1
		end
		dragonUrl=GameData:getConfData("playerskill")[id].roleRes
	end
	
	self.equipConfig = GameData:getConfData("equipconf")
	for k,v in pairs(data.info.pos) do
		local hero={}
		local heroBaseConf,heroCombatConf,heroModelConf = GlobalApi:getHeroConf(tonumber(v.hid))
        local obj = ClassRoleObj.new(tonumber(v.hid),0)
        obj:setPromoted(v.promote)
		if heroBaseConf~=nil then
			hero.hid=tonumber(v.hid)
			hero.pos=k
			hero.fightForce=v.fight_force
			hero.level=v.level
			hero.talent=v.talent
			hero.quality=obj:getQuality()
			hero.uiOffsetY = heroModelConf.uiOffsetY
			hero.isKing = (tonumber(k)==1) and true or false
			hero.icon=(hero.isKing==true and isDroid==false) and headIcon or "uires/icon/hero/" .. heroModelConf.headIcon
			hero.url=(hero.isKing==true and isDroid==false) and dragonUrl or heroModelConf.modelUrl			
			local name=(hero.isKing==true) and GlobalApi:getLocalStr('STR_MAIN_NAME') or heroBaseConf.heroName
			hero.name=(hero.talent>0) and name.."+"..hero.talent or name
			hero.equips={}
            hero.promoteSpecial = v.promote
            hero.camp = heroCombatConf.camp
			for m,n in pairs(v.equip) do
				local equip= {}
				local equipInfo=self.equipConfig[tonumber(n.id)]
				local equiptab = {
					id = n.id,
					grade = n.grade,
					intensify = n.intensify,
					refine_exp = n.refine_exp,
					belongName = name,
					otherEquips = v.equip,
				}
				local equipObj = ClassEquipObj.new(tonumber(n.id),equiptab)
				equip.pos=equipInfo.type
				equip.obj = equipObj
				if equipObj~=nil then
					table.insert(hero.equips, equip)
				end
			end
			if hero.isKing == true then
				table.insert(self.heroList, hero)
			else
				table.insert(tempList, hero)
			end
			if v.promote and v.promote[1] then
				hero.promote = v.promote[1]
			end
		end
	end
	table.sort(tempList, function (a, b)
        return a.fightForce > b.fightForce
    end)
	for i=1, #tempList do
		table.insert(self.heroList, tempList[i])
	end
	self.equipList={}
end	

function CheckInfoUI:onShow()
	self:updatePanel()
end

function CheckInfoUI:updatePanel()
	
end

function CheckInfoUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2))
	
	local panel = bg2:getChildByName('contentPanel')
	self.title = bg2:getChildByName('title')
	self.title:setString(self.targetName)
	
	self.tempHeadCell=ccui.Helper:seekWidgetByName(bg2, 'headCell')
    self.tempHeadCell:setVisible(false)
	self.tempHeadCell:setTouchEnabled(false)
	
	--hero head
	self.headSv = bg2:getChildByName('head_sv')
    local contentWidget = ccui.Widget:create()
    self.headSv:addChild(contentWidget)
    local svSize = self.headSv:getContentSize()
    self.headSv:setScrollBarEnabled(false)
    contentWidget:setPosition(cc.p(0, svSize.height))
	
	--contentWidget:removeAllChildren()
	local innerHeight=0
	for i = 1, #self.heroList do
		local headPic = self:createHeadCell(i)
		innerHeight = i*115
		headPic:setPosition(cc.p(svSize.width/2, 50-innerHeight))
		contentWidget:addChild(headPic)
	end
	innerHeight = innerHeight < svSize.height and svSize.height or innerHeight
	self.headSv:setInnerContainerSize(cc.size(svSize.width, innerHeight))
	contentWidget:setPosition(cc.p(0, innerHeight))
	
	--hero view
	for i=1,6 do
		local armnode = panel:getChildByName('arm_' .. i .. '_img')
		armnode:setLocalZOrder(2)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil, true)
    	tab.awardBgImg:ignoreContentAdaptWithSize(true)
		local equiparr = {}
	    equiparr.icon = tab.awardImg
	    equiparr.icon:ignoreContentAdaptWithSize(true)
	    equiparr.fram = tab.awardBgImg
	    equiparr.node = armnode
	    equiparr.star = tab.starImg
	    equiparr.num = tab.starLv
	    equiparr.lv = tab.lvTx
	    equiparr.rhombImgs = tab.rhombImgs
		equiparr.tab = tab
		equiparr.fram:loadTexture('uires/ui/common/frame_default.png')
		equiparr.icon:loadTexture(DEFAULTEQUIP[i])
		
		table.insert(self.equipList, equiparr)
		armnode:addChild(tab.awardBgImg)
	end
	self.heroName=panel:getChildByName('name')
	self.roleBg=panel:getChildByName('roleBg')
	self.fightForce=ccui.Helper:seekWidgetByName(panel,'fightforce_tx')	
	
	self:setHeroView(self.selected)
	
	--close btn
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			BattleMgr:hideCheckLastInfo()
	    end
	end)
	
	--self:updatePanel()
end

function CheckInfoUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bg1")
	local panel=ccui.Helper:seekWidgetByName(bg1,"bg2")
     panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
     panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
            if(call ~= nil) then
                return call()
            end
        end)))
end

function CheckInfoUI:createHeadCell(idx)
	local hero=self.heroList[idx]
	
    local newCell = self.tempHeadCell:clone()
    ---------------------------
    ClassItemCell:setHeroPromote(newCell,hero.hid,hero.promoteSpecial)
    ---------------------------
	newCell:setName('cell'..idx)
	newCell.icon = ccui.Helper:seekWidgetByName(newCell,"icon")
    newCell.selectPic = ccui.Helper:seekWidgetByName(newCell,"selectPic")
    newCell.kingPic = ccui.Helper:seekWidgetByName(newCell,"kingPic")
	newCell.lvText = ccui.Helper:seekWidgetByName(newCell,"lv")
	
	newCell.icon:loadTexture(hero.icon)
	newCell.selectPic:setVisible(false)
	newCell.kingPic:setVisible(hero.isKing)
	newCell.lvText:setString("Lv."..hero.level)
	
    newCell:setVisible(true)
	newCell:setTouchEnabled(true)
	
	newCell:addClickEventListener(function ()
			self:setHeroView(idx)
        end)
		
    return newCell
end

function CheckInfoUI:setHeroView(idx)
	self.selected=idx
	for i = 1, #self.heroList do
		local cell=ccui.Helper:seekWidgetByName(self.headSv, 'cell'..i)
		cell.selectPic:setVisible( (i==idx) and true or false )
	end
	
	local hero=self.heroList[idx]
	if hero==nil then
		return
	end
	
	for i=1, 6 do
		local equipObj=nil
		local partLevel = 0
		for k,v in pairs(hero.equips) do
			if v.pos==i then
				equipObj=v.obj
			end
		end

		if equipObj~=nil then
			ClassItemCell:updateItem(self.equipList[i].tab, equipObj,1)
			self.equipList[i].icon:setTouchEnabled(true)
            self.equipList[i].icon:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
		        	if equipObj then
						GetWayMgr:showGetwayUI(equipObj,false)
					end
		        end
		    end)
		else
			self.equipList[i].fram:loadTexture('uires/ui/common/frame_default.png')
			self.equipList[i].star:setVisible(false)
			self.equipList[i].icon:loadTexture(DEFAULTEQUIP[i]) 
			self.equipList[i].lv:setString('')
			self.equipList[i].icon:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
		        	if equipObj then
						GetWayMgr:showGetwayUI(equip,false)
					end
		        end
		    end)
		end
	end
	
	local promote = hero.promote
	local weapon_illusion = nil
	local wing_illusion = nil
	if hero.camp == 5 then
		if self.data.info.weapon_illusion and self.data.info.weapon_illusion > 0 then
            weapon_illusion = self.data.info.weapon_illusion
        end
        if self.data.info.wing_illusion and self.data.info.wing_illusion > 0 then
            wing_illusion = self.data.info.wing_illusion
        end
	end
	local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
	local model = GlobalApi:createLittleLossyAniByName(hero.url .. "_display", nil, changeEquipObj)
	self.roleBg:removeAllChildren()
	if model~=nil then
		model:getAnimation():play('idle', -1, 1)
		model:setPosition(cc.p(0,20+hero.uiOffsetY))
		self.roleBg:addChild(model)
	end
	
	self.fightForce:setString(hero.fightForce)
	self.heroName:setString(hero.name)
	self.heroName:setTextColor(COLOR_QUALITY[hero.quality])
end

function CheckInfoUI:isDroid(uid)
	if tonumber(uid) <= 1000000 then
		return true
	else
		return false
	end
end

return CheckInfoUI