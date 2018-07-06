local RoleCellChipUI = class("RoleCellChipUI")
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function RoleCellChipUI:ctor(parentUI, pos, obj)
	self.parentUI = parentUI
	self.obj = obj
	self.nor_pl = nil     		--右边主panel
	self.funcbtn = nil			--获取或者上阵按钮
	self.probgimg = nil			--碎片进度条
	self.lv = nil				--等级
	self.soldiertypeimg = nil   --兵种类型
	self.name = nil				--武将名称
	self.info = nil				--提示
	self:initPanel()
	self.pos = pos
	self.iscanmerge = false
end

function RoleCellChipUI:initPanel()
	local panel = cc.CSLoader:createNode("csb/rolecellchip.csb")
	local bgimg = panel:getChildByName("bg_img")
	bgimg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(bgimg)
	self.nor_pl = bgimg:getChildByName('nor_pl')
	local headIcon = bgimg:getChildByName('head_icon')
	self.headIcon = headIcon
	self.bgimg = bgimg

	self.probgimg = self.nor_pl:getChildByName('probg_img')
	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.info = self.nor_pl:getChildByName('info_img')
	self.lv = namebg:getChildByName('lv_tx')
	self.soldiertypeimg = namebg:getChildByName('soldiertype_img')
	self.funcbtn = self.nor_pl:getChildByName('func_btn')
	self.funcbtn:addClickEventListener(function (sender, eventType)
		if self.iscanmerge then
			local args = {
                id = self.obj:getId(),
                num = self.obj:getMergeNum()
    		}
			MessageMgr:sendPost("use", "bag", json.encode(args), function (jsonObj)
				print(json.encode(jsonObj))
				local code = jsonObj.code
				if code == 0 then
					local awards = jsonObj.data.awards
					GlobalApi:parseAwardData(awards)
					TavernMgr:showTavernAnimate(awards, function (  )
						local costs = jsonObj.data.costs
	                    if costs then
	                        GlobalApi:parseAwardData(costs)
	                    end
						if self.obj:getNum() > 0 then
							self:setType()
						else
							self.parentUI:update()
						end
						promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_SUCC'), COLOR_TYPE.GREEN)
					end, 4)
				else
					promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_FAIL'), COLOR_TYPE.RED)
				end
			end)
		else
			GetWayMgr:showGetwayUI(self.obj,true)
		end
	end)
   	bgimg:setTouchEnabled(true)
   	local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
   	bgimg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
   		if eventType == ccui.TouchEventType.ended then
            ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.CHIP_MERGET,self.obj)
		end
	end)
end

function RoleCellChipUI:getPanel()
	return self.panel
end

function RoleCellChipUI:setVisible(vis)
	self.panel:setVisible(vis)
end

function RoleCellChipUI:update(pos,obj)

	if not obj then
		return
	end
	self.parentUI = parentUI
	self.obj = obj
	self:setType()
end

function RoleCellChipUI:upDateUI()
	local roleobj =RoleData:getRoleInfoById(self.obj:getId())
	--self.obj:setLightEffect(self.headIcon)
	if self.obj:getId() ~= 0 then
		self.name:setString(roleobj:getName())
		self.name:setTextColor(roleobj:getNameColor())
		self.name:enableOutline(roleobj:getNameOutlineColor(), 2)
		self.soldiertypeimg:loadTexture('uires/ui/common/soldier_'..roleobj:getSoldierId()..'.png')
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
	end
end

function RoleCellChipUI:setType()

	local quality = self.obj:getQuality()
	self.bgimg:loadTexture(COLOR_ROLE_BG[quality])
	self.headIcon:loadTexture(self.obj:getIcon())

	self.iscanmerge = false
	local id = self.obj:getId()
	local num =self.obj:getNum()
	local mergenum = self.obj:getMergeNum()
	local probar = self.probgimg:getChildByName('pro_bar')
	probar:setPercent((num/mergenum)*100)
	local probarxp =probar:getChildByName('bar_tx')
	probarxp:setString(num ..'/' .. mergenum)
	local tx =self.funcbtn:getChildByName('func_tx')
	if num >= mergenum then
		self.iscanmerge = true
		self.funcbtn:loadTextureNormal('uires/ui_new/common/common_btn_8.png')
		self.funcbtn:loadTexturePressed('uires/ui_new/common/common_btn_9.png')
		tx:setString(GlobalApi:getLocalStr_new("COMMON_STR_MERGE"))
		tx:setTextColor(COLOR_TYPE.YELLOW_BTN)
		tx:enableOutline(COLOROUTLINE_TYPE.YELLOW_BTN,2)
		tx:enableShadow(COLOR_BTN_SHADOW.YELLOW_BTN, cc.size(0, -1), 0)
	else
		self.funcbtn:loadTextureNormal('uires/ui_new/common/common_btn_10.png')
		self.funcbtn:loadTexturePressed('uires/ui_new/common/common_btn_11.png')
		tx:setString(GlobalApi:getLocalStr_new("COMMON_STR_GET"))
		tx:setTextColor(COLOR_TYPE.GREEN_BTN)
		tx:enableOutline(COLOROUTLINE_TYPE.GREEN_BTN,2)
		tx:enableShadow(COLOR_BTN_SHADOW.GREEN_BTN, cc.size(0, -1), 0)
	end
    self.info:setVisible(UserData:getUserObj():getSingleChipShowStatus(self.obj))
	self:upDateUI()
end

return RoleCellChipUI