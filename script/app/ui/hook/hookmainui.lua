
local HookMainUI = class("HookMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local taskLen = 2
local checkBtnTexture = {
    nor = "uires/ui_new/common/select_tab_nor.png",
    sel = "uires/ui_new/common/select_tab_push.png",
}
local maxExploreTaskStat = 5

local costBtnTex = {
	refresh_nor = "uires/ui_new/common/swap_btn_normal.png",
    refresh_sel = "uires/ui_new/common/swap_btn_press.png",
    upgrade_nor = "uires/ui_new/explore/upbtn_nor.png",
    upgrade_sel = "uires/ui_new/explore/upbtn_sel.png",
}

function HookMainUI:ctor(ftype,data,monsterLv,earnTime)

	self.uiIndex = GAME_UI.UI_HOOK_MAIN_UI
	self.type = ftype or 1

	self.monsterLv = data.auto_fight.monster_level or 1
	self.exploredTime = exploredTime or 1
	self.earnTime = data.auto_fight.last_get_time or 1
	self.acceleratedTime = data.auto_fight.speed_num or 1
	self.earnList = data.auto_fight.bag
	self.earnTab = {}
	self.maxStorage = 0

	self.rttab = {}
	self.droplist = {}
	self.killBossCnt = {}

	for i=1,3 do
		local bossIndex = tostring(i)
		if data.boss.boss_msg[bossIndex] then
			self.killBossCnt[i] =  data.boss.boss_msg[bossIndex].kill or 0
		else
			self.killBossCnt[i] = 0
		end
	end

	self.dispatchHero = {}
	self.already_buy = data.task_msg.already_buy
	self.exploreFinshiCount = data.task_msg.already_num
	self.exploreAward = {}
	self.exploreReset = data.task_msg.already_star_num
	local taskList = data.task_msg.task_list

	self.exploreTaskInfo = {}
	for k,v in pairs(taskList) do
		table.insert(self.exploreTaskInfo, v)
	end
end

function HookMainUI:onHide()
    self:stopSchedule()
end

function HookMainUI:init()

	local bgimg = self.root:getChildByName("bg_img")
	local bg = bgimg:getChildByName("bg")
	self:adaptUI(bgimg, bg)

	local close_btn = bg:getChildByName("close_btn")
	close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideHookMainUI()
        end
    end)

	self.titleTx = bg:getChildByName("title_tx")
	self.window = {}
	for i=1,HOOKMAIN_TYPE.LEN do
		local pl = bg:getChildByName("hookPL"..i)
		local btn = bg:getChildByName("check_btn"..i)
		local btnTx = btn:getChildByName("text")
		local titleStr = GlobalApi:getLocalStr_new("HOOK_MIAN_TITLE"..i)
		local btnStr = GlobalApi:getLocalStr_new("HOOK_MIAN_BTNTX"..i)
		btnTx:setString(btnStr)
		self.window[i] = {pl = pl,btn = btn,btnTx = btnTx,titleStr = titleStr}
		btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	self.type = i
                self:choosePL()
            end
        end)
	end

	--挂机分页
	local hookPL = bg:getChildByName("hookPL1")
	local state_tx = hookPL:getChildByName("state_tx")
	state_tx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX4"))
	self.lvTx = hookPL:getChildByName("lv_tx")
	
	local svBg = hookPL:getChildByName("sv_bg")
	self.listview = svBg:getChildByName("list")
	self.listview:setScrollBarEnabled(false)
	local cellbgimg = svBg:getChildByName("cell")
	cellbgimg:setVisible(false)
	self.listview:setItemModel(cellbgimg)
	
	self.noneBg = svBg:getChildByName("none_bg")
	local text = self.noneBg:getChildByName("text")
	text:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX6"))
	
	local barbg = hookPL:getChildByName("bar_bg")
	self.bar = barbg:getChildByName("bar")
	self.bar:setScale9Enabled(true)

	self.hookItem = {}
	for i=1,6 do
		local itembg = hookPL:getChildByName("item_bg"..i)
		local item = itembg:getChildByName("item")
		local lockImg = itembg:getChildByName("lock")
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
		tab.awardBgImg:setPosition(cc.p(47,47))
		item:addChild(tab.awardBgImg)
		self.hookItem[i] = {tab = tab,lockImg = lockImg,bg = itembg}
	end

	self.check_btn = hookPL:getChildByName("check_btn")
	self.check_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           	MainSceneMgr:showHookDetailUI(self.monsterLv+1)
        end
    end)

	--挑战
	self.fight_btn = hookPL:getChildByName("fight_btn")
	local btnTx = self.fight_btn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_BTNTX4"))
	self.fight_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:fightBattle()
        end
    end)

	--全部领取
    local get_btn = hookPL:getChildByName("get_btn")
	local btnTx = get_btn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_BTNTX5"))
	get_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('get_award','auto_fight',json.encode(args),function (response)
				local code = response.code
		        local data = response.data
		        if code == 0 then
					local awards = response.data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                    end
                    self.earnList = {}
                    self:updateHookStorage()
				end
			end)
        end
    end)

	--加速挂机
	local accelerate_btn = hookPL:getChildByName("accelerate_btn")
	local btnTx = accelerate_btn:getChildByName("text")
	btnTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_BTNTX6"))
	accelerate_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:accelerate()
        end
    end)
	
	--boss图鉴
	local hookBossPL = bg:getChildByName("hookPL2")
	self.bosslist = hookBossPL:getChildByName("list")
	self.bosslist:setScrollBarEnabled(false)
	local bossCell = hookBossPL:getChildByName("boss_clone")
	bossCell:setVisible(false)
	self.bosslist:setItemModel(bossCell)
	self.default = hookBossPL:getChildByName("default")
	local corner_img = self.default:getChildByName("corner_img")
	local tx = corner_img:getChildByName("text")
	tx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX11"))
	self.default:setVisible(false)

	self.drop = {}
	local hookBossCfg = GameData:getConfData("exploreboss")
	local dropCfg = GameData:getConfData("drop")
	for i=1,#hookBossCfg do
		self.drop[i] = {}
		self.drop[i].item = {}
		self.drop[i].type = {}
		local itemCont = 0
		local cfg = hookBossCfg[i]
	    local fixCfg = dropCfg[cfg.lootId]
	    if fixCfg.fixed ~= '0' and #fixCfg.fixed > 0 then
	    	itemCont = itemCont + 1
	    	self.drop[i].type[itemCont] = 1
	    	table.insert(self.drop[i].item,fixCfg.fixed[1])
		end
	    for j = 1,15 do
	        if fixCfg['award' .. j] ~= '0' and #fixCfg['award' .. j] > 0 then
	        	itemCont = itemCont + 1
	    	self.drop[i].type[itemCont] = 1
	            table.insert(self.drop[i].item,fixCfg['award' .. j][1])
	        end
	    end

	    local randomCfg = dropCfg[cfg.specialLootId]
	    if randomCfg.fixed ~= '0' and #randomCfg.fixed > 0 then
	    	itemCont = itemCont + 1
	    	self.drop[i].type[itemCont] = 2
	    	table.insert(self.drop[i].item,randomCfg.fixed[1])
	    end
	    for j = 1,15 do
	        if randomCfg['award' .. j] ~= '0' and #randomCfg['award' .. j] > 0 then
	        	itemCont = itemCont + 1
	    		self.drop[i].type[itemCont] = 2
	            table.insert(self.drop[i].item,randomCfg['award' .. j][1])
	        end
	    end
	end

	--搜寻任务
	local hookTaskPL = bg:getChildByName("hookPL3")
	local numberDescTx = hookTaskPL:getChildByName("number_desc")
	numberDescTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX12"))
	local descTx = hookTaskPL:getChildByName("desc_tx")
	descTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX13"))
	self.numberTx = hookTaskPL:getChildByName("number_tex")
	self.di = hookTaskPL:getChildByName("di")

	--增加搜寻任务次数
	local addTimeBtn = hookTaskPL:getChildByName("add_btn")
	addTimeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	self:addTaskNum()
            --promptmgr:showSystenHint('功能暂未开发', COLOR_TYPE.RED)
        end
    end)

	self:choosePL()
end

function HookMainUI:choosePL()

	for i=1,HOOKMAIN_TYPE.LEN do
        if i == self.type then
            self.window[i].btn:loadTextureNormal(checkBtnTexture.nor)
            self.window[i].btnTx:setTextColor(COLOR_TYPE.TAB_WHITE)
            self.window[i].btnTx:enableOutline(COLOROUTLINE_TYPE.OFFTAB_WHITE,1)
            self.window[i].btnTx:enableShadow(COLOR_BTN_SHADOW.TAB_WHITE, cc.size(0, -1), 0)
            self.window[i].btn:setScale(1)
            self.window[i].pl:setVisible(true)
        else
            self.window[i].btn:loadTextureNormal(checkBtnTexture.sel)
            self.window[i].btnTx:setTextColor(COLOR_TYPE.TAB_WHITE1)
            self.window[i].btnTx:enableOutline(COLOROUTLINE_TYPE.OFFTAB_WHITE1,1)
            self.window[i].btnTx:enableShadow(COLOR_BTN_SHADOW.TAB_WHITE1, cc.size(0, -1), 0)
            self.window[i].btn:setScale(0.9)
            self.window[i].pl:setVisible(false)
        end
    end

    self.titleTx:setString(self.window[self.type].titleStr)
    self:update(self.type)

end

function HookMainUI:update(uitype,data)

	if uitype == HOOKMAIN_TYPE.HOOK then
    	self:updateHook()
    elseif uitype == HOOKMAIN_TYPE.BOSS then
    	self:updateBoss()
    elseif uitype == HOOKMAIN_TYPE.PATROL then
    	if data then
    		local index = 0
    		for i=1,#self.exploreTaskInfo do
    			if self.exploreTaskInfo[i].task_id == data.task_id then
    				index = i
    				break
    			end
    		end
    		if index ~= 0 then
    			self.exploreTaskInfo[index] = data
    		end
    	end
    	self:updateTask()
    end

end

--大本营挂机
function HookMainUI:updateHook()

	local hookPL = self.window[self.type].pl
	local stateNumTx = hookPL:getChildByName("state_num")
	local fightTx = hookPL:getChildByName("fight_tx") 
	fightTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX2"))
	local posX = fightTx:getPositionX()
	local size = fightTx:getContentSize()
	local fightNumTx = hookPL:getChildByName("fight_num") 
	fightNumTx:setPositionX(posX+size.width+3)
	local monsterimg = hookPL:getChildByName("monster")
	local expbg = hookPL:getChildByName("exp_bg")
	local expText = expbg:getChildByName("exp_text")
	local hookInfo = hookPL:getChildByName("info_tx")

	local explorebaseCfg = GameData:getConfData("explorebase")
	local exploreMonster = GameData:getConfData("exploremonster")
	local exploreMonsterCfg = exploreMonster[self.monsterLv]

	local existTime = explorebaseCfg['ExistTime'].value
	local restTime = explorebaseCfg['RestTime'].value
	local minKillCount = explorebaseCfg['OnceKillMin'].value
	local maxKillCount = explorebaseCfg['OnceKillMax'].value

	local soldierCfg,modelConf = GlobalApi:getSoldierConf(exploreMonsterCfg.soldierId)
	monsterimg:loadTexture('uires/icon/soldier/'..modelConf.bodyIcon)
	
	local intervaTime = existTime+ restTime/(minKillCount+maxKillCount)*2
	local exp = math.floor(3600/intervaTime * exploreMonsterCfg.singleExp)
	expText:setString(string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX3"),exp))

	local fullTx = hookPL:getChildByName("full_info")
	fullTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX7"))

	self.lvTx :setString("lv."..self.monsterLv)

	--满级处理
	local nextMonsterLv = self.monsterLv+1
	if nextMonsterLv <= #exploreMonster then
		fullTx:setVisible(false)
		hookInfo:setVisible(true)
		hookInfo:setString(string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX1"),nextMonsterLv))
		fightTx:setVisible(true)

		local nextMonsterCfg = exploreMonster[nextMonsterLv]
		local formationConf = GameData:getConfData('formation')[nextMonsterCfg.challengeId]
    	local fightForce = formationConf.fightforce
    	fightNumTx:setString(fightForce)
    	fightNumTx:setVisible(true)
    	self.fight_btn:setVisible(true)
    	self.check_btn:setVisible(true)
	else
		fullTx:setVisible(true)
		hookInfo:setVisible(false)
		fightTx:setVisible(false)
		fightNumTx:setVisible(false)
		self.fight_btn:setVisible(false)
		self.check_btn:setVisible(false)
	end

	--显示奖励
	for i=1,6 do 		   
		
		local displayobj = DisplayData:getDisplayObj(exploreMonsterCfg["award"..i][1])
		if displayobj then
			self.hookItem[i].bg:setVisible(true)
			local openLv = explorebaseCfg["LootLevel"..i].value
			self.hookItem[i].lockImg:setVisible(self.monsterLv<openLv)
			ClassItemCell:updateItem(self.hookItem[i].tab,displayobj,1)
			local str = self.monsterLv>=openLv and "+"..exploreMonsterCfg["improve"..i].."%" or "Lv."..openLv
			self.hookItem[i].tab.lvTx:setString(str)
		else
			self.hookItem[i].bg:setVisible(false)
		end
	end
	
	local svBg = hookPL:getChildByName("sv_bg")
	self.sv = svBg:getChildByName("list")
	self.sv:setScrollBarEnabled(false)
	self.noneBg = svBg:getChildByName("none_bg")
	local text = self.noneBg:getChildByName("text")
	text:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX6"))
	self.cloneCell = svBg:getChildByName("cell")

	self.noneBg:setVisible(#self.earnList == 0)
	
	--显示精度
	local earnings_state = hookPL:getChildByName("earnings_state")
	earnings_state:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX5"))
	local time = GlobalData:getServerTime() - self.earnTime
	local percent = time/(24*3600)*100
	self.bar:setPercent(percent) 
	stateNumTx:setString(string.format("%.2f", percent).."%")
	if self.earnTime >= 24*3600 then
		earnings_state:setVisible(true)
	else
		earnings_state:setVisible(false)
	end

	self:updateHookStorage()
end

--挂机仓库
function HookMainUI:updateHookStorage()

	 
	if self.maxStorage <= #self.earnList then
		self.maxStorage = #self.earnList
	end
	--显示列表
	for i=1,self.maxStorage do
		local cellbg = self.listview:getItem(i-1)
		if not self.earnList[i] and cellbg then
			cellbg:setVisible(false)
		else
			if not cellbg then
			self.listview:pushBackDefaultItem()
			cellbg = self.listview:getItem(i - 1)
			end
			cellbg:setVisible(true)
			local num_bg = cellbg:getChildByName("num_bg")
			local text = num_bg:getChildByName("text")
			local dispalyObj = DisplayData:getDisplayObj(self.earnList[i])
			if not self.earnTab[i] then
				local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
				tab.lvTx:setVisible(false)
				self.earnTab[i] = tab
				tab.awardBgImg:setScale(0.7)
				tab.awardBgImg:setPosition(cc.p(55,83))
				cellbg:addChild(tab.awardBgImg)
			end
			if dispalyObj then
				ClassItemCell:updateItem(self.earnTab[i],dispalyObj,1)
				text:setString(dispalyObj:getNum())
			end
		end
	end
end

--Boss图鉴
function HookMainUI:updateBoss()

	local hookBossCfg = GameData:getConfData("exploreboss")
	local model = GameData:getConfData("model")
	for i=1,#hookBossCfg do
		local cfg = hookBossCfg[i]
		local cellbg = self.bosslist:getItem(i-1)
		if not cellbg then
			self.bosslist:pushBackDefaultItem()
			cellbg = self.bosslist:getItem(i - 1)
		end
		cellbg:setVisible(true)

		local headImg = cellbg:getChildByName("head_img")
		local bossNameTx = headImg:getChildByName("name_tx")
		local bossNameStr = GlobalApi:getGeneralText(cfg.name)
		bossNameTx:setString(bossNameStr)
		bossNameTx:setColor(COLOR_QUALITY[cfg.quality])
		bossNameTx:enableOutline(COLOROUTLINE_QUALITY[cfg.quality], 2)

		local roleImg = headImg:getChildByName("role")
		local roleRes = model[cfg.moduleId].bodyIcon
		roleImg:loadTexture("uires/icon/soldier"..roleRes)

		local barbg = cellbg:getChildByName("bar_bg")
		local bar = barbg:getChildByName("bar")
		local barTx = barbg:getChildByName("text")
		local percent = self.killBossCnt[i]/cfg.awardNeed
		local barSize = bar:getContentSize()
		bar:setContentSize(cc.size(184*percent,barSize.height))
		barTx:setString(self.killBossCnt[i].."/"..cfg.awardNeed)

		--宝箱奖励信息
		local boxAwardName = ''
		local displayObj = DisplayData:getDisplayObj(cfg.awardId[1])
		if displayObj then
			boxAwardName = displayObj:getName()
		end

		local boxBtn = cellbg:getChildByName("box_btn")
		boxBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	local args = {
	        		type = i
	        	}
	            MessageMgr:sendPost('convert_awards','auto_fight',json.encode(args),function (response)
					local code = response.code
			        local data = response.data
			        if code == 0 then
			        	self.killBossCnt[i] = 0
			        	local awards = response.data.awards
	                    if awards then
	                        GlobalApi:parseAwardData(awards)
	                        GlobalApi:showAwardsCommon(awards,nil,nil,true) 
	                    end
						self:updateBoss()
					end
				end)
	        end
	    end)
	   	
	   	local boxlight = cellbg:getChildByName("box_light")
		if percent >= 1 then
			boxlight:setVisible(true)
			boxlight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
		else
			boxlight:setVisible(false)
		end
		if not self.rttab then
			self.rttab[i] = {}
		end

		if not self.rttab[i] then
			local rt = xx.RichText:create()
	        rt:setAnchorPoint(cc.p(0, 0.5))
	        local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX9"), 18, COLOR_TYPE.WHITE1)
	        rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	        rt1:clearShadow()
	        local rt2 = xx.RichTextLabel:create(cfg.awardNeed, 18, COLOR_TYPE.GREEN1)
	        rt2:setStroke(COLOROUTLINE_TYPE.GREEN1, 2)
	        rt2:clearShadow()
	        local str = bossNameStr..GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX10")
	        local rt3 = xx.RichTextLabel:create(str, 18, COLOR_TYPE.WHITE1)
	        rt3:clearShadow()
	        rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	        local rt4 = xx.RichTextLabel:create(boxAwardName, 18,COLOR_QUALITY[cfg.quality])
	        rt4:setStroke(COLOROUTLINE_QUALITY[cfg.quality], 2)
	        rt4:clearShadow()
	        self.rttab[i] = {rt = rt, rt1 = rt1, rt2 = rt2 ,rt3 = rt3, rt4 = rt4}
	        rt:addElement(rt1)
	        rt:addElement(rt2)
	        rt:addElement(rt3)
	        rt:addElement(rt4)
	        rt:setAlignment("left")
	        rt:setPosition(cc.p(178, 130))
	        rt:setContentSize(cc.size(400, 30))
	        rt:format(true)
	        cellbg:addChild(rt)
	    end

	    local descTx = cellbg:getChildByName("desc_tx")
		descTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX8"))

    	local itemlistbg = cellbg:getChildByName("itemlist_bg")
		self.droplist[i] = itemlistbg:getChildByName("item_list")
		self.droplist[i]:setScrollBarEnabled(false)
		self.droplist[i]:setSwallowTouches(false)
		self.droplist[i]:setItemsMargin(4)

	end

	self:updateBossDropList()
end

function HookMainUI:stopSchedule()
    if self._scheduleId then
        GlobalApi:clearScheduler(self._scheduleId)
        self._scheduleId = nil
    end
end

function HookMainUI:updateBossDropList()

	self:stopSchedule()
    local curIndex = 1
    local myRankIndex = 1
    local bossCellIndex = 1
    local function callBack()
        if self.drop[bossCellIndex] then
			if self.drop[bossCellIndex].item[curIndex] then

				local item = self.droplist[bossCellIndex]:getItem(curIndex-1)
				if not item then
	            	item = self.default:clone()
	            	self.droplist[bossCellIndex]:pushBackCustomItem(item)
	            end
	            self:updateBossDropItem(item,self.drop[bossCellIndex].item[curIndex],self.drop[bossCellIndex].type[curIndex])
	            curIndex = curIndex + 1
	        else
	        	self.droplist[bossCellIndex]:setTouchEnabled(true)
	        	bossCellIndex = bossCellIndex + 1
	        	curIndex = 1
	        end
        else
            self:stopSchedule()
        end
    end
    self._scheduleId        = GlobalApi:interval(callBack,0.05)
end

function HookMainUI:updateBossDropItem(itemCellBg,dropItem,itemType)

	itemCellBg:stopAllActions()
    itemCellBg:setVisible(true)
    itemCellBg:setOpacity(0)
    itemCellBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

	local dispalyObj = DisplayData:getDisplayObj(dropItem)
	if dispalyObj then
		itemCellBg:setVisible(true)
		local item = itemCellBg:getChildByName("item")
		if not item then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			tab.awardBgImg:setPosition(cc.p(32.9,32.9))
			tab.awardBgImg:setName("item")
			item = tab.awardBgImg
			tab.awardBgImg:setScale(0.7)
			tab.awardBgImg:setTouchEnabled(false)
			itemCellBg:addChild(tab.awardBgImg,1)
		end
		ClassItemCell:updateItem(item,dispalyObj)
		local fixIcon = itemCellBg:getChildByName("corner_img")
		if fixIcon then
			fixIcon:setVisible(itemType == 1)
			fixIcon:setLocalZOrder(2)
		end
	else
		itemCellBg:setVisible(false)
	end		
end


--搜寻任务
function HookMainUI:updateTask()

	local levelCfg = GameData:getConfData("level")
	local level = UserData:getUserObj():getLv()
	local freshCost = levelCfg[level].exploreTask

	local exploreBaseCfg = GameData:getConfData("explorebase")
	local taskBaseCfg = GameData:getConfData("exploretaskbasic")
	local taskDetailCfg = GameData:getConfData("exploretaskdetail")

	--探索任务次数
	local taskBasicTimes = exploreBaseCfg["taskBasicTimes"].value
	local totalTaskNum = taskBasicTimes+self.already_buy
	local remainTimes = totalTaskNum - self.exploreFinshiCount
	if remainTimes < 0 then
		remainTimes = 0
	end
	self.numberTx:setString(remainTimes)

	for i=1,taskLen do

		local taskCell = self.di:getChildByName("task_cell"..i)
		if not self.exploreTaskInfo[i] then
			taskCell:setVisible(false)
		else
			taskCell:setVisible(true)
			local taskType = self.exploreTaskInfo[i].type
			local taskLevel = self.exploreTaskInfo[i].task_level
			local taskStarLv = self.exploreTaskInfo[i].star
			local startTime = self.exploreTaskInfo[i].start_time
			local exploreHeroId = self.exploreTaskInfo[i].hid or 0
			local taskId = self.exploreTaskInfo[i].task_id
			local finish = self.exploreTaskInfo[i].finish == 1 and true or false
		
			local detailcfg = taskDetailCfg[taskType][taskLevel]
			local basecfg = taskBaseCfg[taskType]

			--任务名字
			local titleBg = taskCell:getChildByName("title_bg")
			local taskNameTx = titleBg:getChildByName("task_name")
			taskNameTx:setString(GlobalApi:getGeneralText(basecfg.name))

			--高级任务
			local bestTx = titleBg:getChildByName("best")
			local bestStr = basecfg.isAdvanced == 1 and GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX14") or ''
			bestTx:setString(bestStr)

			--星级
			for j =1,maxExploreTaskStat do
				local starimg = titleBg:getChildByName("star"..j)
				local starUrl = taskStarLv>=j and "star_awake.png" or "star_awake_bg.png"
				starimg:loadTexture("uires/ui_new/common/"..starUrl)
			end

			local finishTx = taskCell:getChildByName("finish_tx")
			finishTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX36"))
			finishTx:setVisible(finish)

			--是否在探索中
			local exploring = (startTime ~= 0 and not finish)

			--显示奖励
			if not self.exploreAward[i] then
				self.exploreAward[i] = {}
			end
			local displayObj = DisplayData:getDisplayObjs(detailcfg["award"..taskStarLv])
			for j=1,3 do
				local itemBg = taskCell:getChildByName("item"..j)
				itemBg:setVisible(true)	
				local itemType = j==1 and ITEM_CELL_TYPE.HERO or ITEM_CELL_TYPE.ITEM
				if not self.exploreAward[i][j] then
					local tab = ClassItemCell:create(itemType)
					tab.awardBgImg:setPosition(cc.p(47,47))
					tab.lvTx:setVisible(false)
					itemBg:addChild(tab.awardBgImg)
					self.exploreAward[i][j] = tab
				end

				if j==1 then
					if exploreHeroId == 0 then
						self.exploreAward[i][j].awardBgImg:loadTexture(DEFAULT)
						self.exploreAward[i][j].awardImg:loadTexture("uires/ui_new/explore/question.png")
						self.exploreAward[i][j].fragmentMaskImg:setVisible(false)
						self.exploreAward[i][j].lvTx:setVisible(true)
					else
						local obj = RoleData:getRoleById(exploreHeroId)
						if obj then
							local quality = obj:getQuality()
							local needTupoLv = 20
							if exploreBaseCfg['taskSpecialAwardNeed'..quality] then
								needTupoLv = exploreBaseCfg['taskSpecialAwardNeed'..quality].value
							end
							local tupoLv = obj:getTalent() or 0
							local num = tupoLv >= needTupoLv and basecfg.specialAward[taskStarLv] or basecfg.normalAward[taskStarLv]
							ClassItemCell:updateItem(self.exploreAward[i][j], obj,1)
							self.exploreAward[i][j].fragmentMaskImg:setVisible(true)
							self.exploreAward[i][j].lvTx:setVisible(true)
							self.exploreAward[i][j].lvTx:setString("x"..num)
						end
					end
				else
					local obj = displayObj[j-1]
					if obj then
						ClassItemCell:updateItem(self.exploreAward[i][j], obj,1) 
					else
						itemBg:setVisible(false)
					end
				end
			end

			--消耗
			local costbg = titleBg:getChildByName("cost")
			local costIcon = costbg:getChildByName("icon")
			local costTx = costbg:getChildByName("text")
			local costBtn = costbg:getChildByName("cost_btn")

			local timeImg = taskCell:getChildByName("time_img")
			local timeTx = taskCell:getChildByName("time_tx")
			local bodyImg = taskCell:getChildByName("body_img")
			local addimg = bodyImg:getChildByName("add")
			addimg:setVisible(exploreHeroId == 0)
			bodyImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	MainSceneMgr:showHookDispatchUI(taskId)
		        end
		    end)


			if exploreHeroId ~= 0 then

				if self.dispatchHero[i] then
					self.dispatchHero[i]:setDispatchFlag(false)
					local spineAni = bodyImg:getChildByName('mode')
					if spineAni then
						spineAni:removeFromParent()
					end
				end

				local roleobj = RoleData:getRoleById(exploreHeroId)
				if roleobj then
					roleobj:setDispatchFlag(true)
					self.dispatchHero[i] = roleobj
				end

				local _,_,heroModelInfo = GlobalApi:getHeroConf(exploreHeroId)
				bodyImg:loadTexture("uires/ui_new/common/bg1_alpha.png")
				local bodyImgSize = bodyImg:getContentSize()
				local spineAni = GlobalApi:createLittleLossyAniByName(heroModelInfo.modelUrl.."_display")
		        spineAni:setScale(0.5)
		        spineAni:setAnchorPoint(cc.p(0.5, 0))
		        spineAni:setPositionX(bodyImgSize.width/2)
		        if not exploring then
		        	spineAni:getAnimation():play('idle', -1, 1)
		        else
		        	spineAni:getAnimation():play('run', -1, 1)
		        end
		        spineAni:setName('mode')
		        bodyImg:addChild(spineAni)
			else

				if self.dispatchHero[i] then
					self.dispatchHero[i]:setDispatchFlag(false)
					local spineAni = bodyImg:getChildByName('mode')
					if spineAni then
						spineAni:removeFromParent()
					end
					self.dispatchHero[i] = nil
				end
				bodyImg:loadTexture("uires/ui_new/explore/nobody.png")
			end

			costbg:setVisible(true)
			local exploreTotalTime = basecfg.needTime[taskStarLv]
			if not exploring then
				--基础刷新次数
				local baseFreshCnt = exploreBaseCfg['taskRefreshFreeTimes'].value 
				local surplusFreshCnt = baseFreshCnt - self.exploreReset 
				costIcon:loadTexture("uires/ui_new/res/gold.png")
				if surplusFreshCnt <= 0 then
					costTx:setString(freshCost)
				else
					local costStr = string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX16"),surplusFreshCnt)
					costTx:setString(costStr)
				end

				timeImg:setVisible(not finish)
				costbg:setVisible(not finish)

				timeTx:removeAllChildren()
				if finish then
					timeTx:setString('')
				else
					timeTx:setString(string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX15"),exploreTotalTime))
				end
				costBtn:loadTextureNormal(costBtnTex.refresh_nor)
				costBtn:loadTexturePressed(costBtnTex.refresh_sel)
			else

				local costdisplayObj = DisplayData:getDisplayObj(basecfg.starAddCost[1])
				costIcon:loadTexture(costdisplayObj:getIcon())
				costTx:setString(costdisplayObj:getNum())

				timeImg:setVisible(false)
				timeTx:setString('')
				if not finish then
					self:timeoutCallback(timeTx,startTime,exploreTotalTime,i)
				end
				costBtn:loadTextureNormal(costBtnTex.upgrade_nor)
				costBtn:loadTexturePressed(costBtnTex.upgrade_sel)
			end

			costBtn:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		            self:taskCostMsg(exploring,i)
		        end
		    end)

			local funcbtn = taskCell:getChildByName("func_btn")
			local btnTx = funcbtn:getChildByName("text")
			local btnStr = exploring and "HOOK_MIAN_INFOTX18" or "HOOK_MIAN_INFOTX19"
			if finish then
				btnStr = "HOOK_MIAN_BTNTX7"
			end
			
			btnTx:setString(GlobalApi:getLocalStr_new(btnStr))
			funcbtn:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	if finish then
		        		MessageMgr:sendPost('finish','auto_fight',json.encode({task_id = taskId}),function (response)
							local code = response.code
					        local data = response.data
					        if code == 0 then
					        	local awards = response.data.awards
			                    if awards then
			                        GlobalApi:parseAwardData(awards)
			                        GlobalApi:showAwardsCommon(awards,nil,nil,true) 
			                    end
					        	self.exploreTaskInfo[i] = data.task
								self:updateTask()
							end
						end)
		        	else
		            	self:taskFucMsg(exploring,i)
		            end
		        end
		    end)
		end
		
	end
end

function HookMainUI:timeoutCallback(parent,startime,exploreTotalTime,taskIndex)
	local diffTime = 0
	if startime ~= 0 then
		diffTime = exploreTotalTime - (GlobalData:getServerTime()-startime)-1
	end

	if diffTime < 0 then
		return
	end

	local node = cc.Node:create()
	node:setTag(9527)	 
	node:setPosition(cc.p(0,0))
	parent:removeChildByTag(9527)
	parent:addChild(node)
	
	local str = GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX17")
	Utils:createCDLabel(node,diffTime,COLOR_TYPE.GREEN1,COLOROUTLINE_TYPE.GREEN1,CDTXTYPE.FRONT,str,COLOR_TYPE.YELLOW1,COLOROUTLINE_TYPE.YELLOW1,16,function ()	
		parent:removeAllChildren()
		self.exploreTaskInfo[taskIndex].finish = 1
		self:updateTask()
	end)		
end

function HookMainUI:fightBattle()
   
    local exploreMonster = GameData:getConfData("exploremonster")
    local nextMonsterLv = self.monsterLv + 1
    if nextMonsterLv > #exploreMonster then
    	return
    end
	local exploreMonsterCfg = exploreMonster[nextMonsterLv]

    local formationId = exploreMonsterCfg.challengeId
    local customObj = {
        formationId = formationId,
    }

    BattleMgr:playBattle(BATTLE_TYPE.HOOK_MONSTER, customObj, function ()
        MainSceneMgr:showMainCity(function()
            MainSceneMgr:showHookMainUI(1)
        end, nil, GAME_UI.UI_HOOK_MAIN_UI)
    end)
end

--挂机加速
function HookMainUI:accelerate()

	local exploreBase = GameData:getConfData("explorebase")
	local buyConf = GameData:getConfData("buy")
	local nextExploreTime = self.exploredTime + 1
	if nextExploreTime >= #buyConf then
		nextExploreTime = #buyConf
	end
	local costYB = buyConf[nextExploreTime].exploreAccelerate

	local vipLv = UserData:getUserObj():getVip()
	local accelerateTimes = GameData:getConfData("vip")[tostring(vipLv)].exploreAccelerateTimes

	local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0.5, 0.5))
    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX21"), 18, COLOR_TYPE.WHITE1)
    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt1:clearShadow()
    local rt2 = xx.RichTextImage:create("uires/ui_new/res/cash.png")
    local rt3 = xx.RichTextLabel:create(costYB, 18, COLOR_TYPE.WHITE1)
    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt3:clearShadow()
    local str = string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX22"),exploreBase["exploreAccelerateTime"].value) 
    local rt4 = xx.RichTextLabel:create(str, 18,COLOR_TYPE.WHITE1)
    rt4:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt4:clearShadow()
    local remainTims = accelerateTimes - self.acceleratedTime
    if remainTims < 0 then
    	remainTims = 0
    end

    local str1 = "\n"..string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX23"),remainTims,accelerateTimes) 
    local rt5 = xx.RichTextLabel:create(str1, 18,cc.c4b(137, 0, 0, 255))
    rt5:setStrokeSize(0)
    rt5:clearShadow()

    self.accelerateRts = {rt = rt, rt1 = rt1, rt2=rt2, rt3=rt3, rt4=rt4,rt5 = rt5}
    rt:addElement(rt1)
    rt:addElement(rt2)
    rt:addElement(rt3)
    rt:addElement(rt4)
    rt:addElement(rt5)
    rt:setAlignment("middle")
    rt:setPosition(cc.p(195,160))
    rt:setContentSize(cc.size(400, 30))
	rt:format(true)

	

	local titleStr = GlobalApi:getLocalStr_new('HOOK_MIAN_INFOTX25')
    promptmgr:showMessageBoxWithTitle(titleStr,rt, MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()

    	if remainTims <= 0 then
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX29"), COLOR_TYPE.RED)
			return
		end

    	local hasCash = UserData:getUserObj():getCash()
    	if hasCash >= costYB then
    		MessageMgr:sendPost('speed_up_hook','auto_fight',json.encode(args),function (response)
				local code = response.code
		        local data = response.data
		        if code == 0 then
					local cost = response.data.cost
					if cost then
						GlobalApi:parseAwardData(cost)
					end
					local awards = response.data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                    end
				end
			end)
    	else
    		promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                GlobalApi:getGotoByModule("cash")
            end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
    	end
    end)

end

--消耗消息
function HookMainUI:taskCostMsg(exploring,taskIndex)

	if not self.exploreTaskInfo[taskIndex] then
		return
	end

	local explorebaseCfg = GameData:getConfData("explorebase")
	local levelCfg = GameData:getConfData("level")
	local level = UserData:getUserObj():getLv()

	local taskId = self.exploreTaskInfo[taskIndex].task_id
	local taskType = self.exploreTaskInfo[taskIndex].type
	if not exploring then

		local freshCost = levelCfg[level].exploreTask
		local baseFreshCnt = explorebaseCfg['taskRefreshFreeTimes'].value 
		local surplusFreshCnt = baseFreshCnt - self.exploreReset 
		local openMsgBox = false
		if surplusFreshCnt > 0 then
			freshCost = 0
		end

		local gold = UserData:getUserObj():getGold()
		if freshCost > gold then
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new("COMMON_NO_GOLD"), COLOR_TYPE.RED)
			return
		end

		local args = {
			task_id = taskId
		}

		MessageMgr:sendPost('refresh_task','auto_fight',json.encode(args),function (response)
			local code = response.code
	        local data = response.data
	        if code == 0 then
				local cost = data.cost
				if cost then
					GlobalApi:parseAwardData(cost)
				end
				self.exploreTaskInfo[taskIndex] = data.task
				self.exploreReset = data.already_num
				self:updateTask()
			end
		end)
	else

		if self.exploreTaskInfo[taskIndex].star >= maxExploreTaskStat then
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX37"), COLOR_TYPE.RED)
			return
		end

		local taskBaseCfg = GameData:getConfData("exploretaskbasic")
		local basecfg = taskBaseCfg[taskType]
		local costdisplayObj = DisplayData:getDisplayObj(basecfg.starAddCost[1])
		local cost = costdisplayObj:getNum()
		local ownNum = costdisplayObj:getOwnNum()

		if ownNum >= cost then
			local args = {
				task_id = taskId
			}
			UserData:getUserObj():cost('cash',tonumber(cost),function()
				MessageMgr:sendPost('up_star','auto_fight',json.encode(args),function (response)
					local code = response.code
			        local data = response.data
			        if code == 0 then
						local cost = response.data.cost
						if cost then
							GlobalApi:parseAwardData(cost)
						end
						self.exploreTaskInfo[taskIndex].star = data.task.star
						self:updateTask()
					end
				end)
			end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),tonumber(cost)))
		else
		end
	end
	
	
end

--增加搜寻任务次数
function HookMainUI:addTaskNum()

	local boughtTime = self.already_buy
	local nextBuyTime = boughtTime + 1
	local buyCfg = GameData:getConfData("buy")
	if nextBuyTime > #buyCfg then
		nextBuyTime = #buyCfg
	end
	local costYB = buyCfg[nextBuyTime].exploreTask

	local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0.5, 0.5))
    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX21"), 18, COLOR_TYPE.WHITE1)
    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt1:clearShadow()
    local rt2 = xx.RichTextImage:create("uires/ui_new/res/cash.png")
    local rt3 = xx.RichTextLabel:create(costYB, 18, COLOR_TYPE.WHITE1)
    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt3:clearShadow()
    local str = string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX30")) 
    local rt4 = xx.RichTextLabel:create(str, 18,COLOR_TYPE.WHITE1)
    rt4:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt4:clearShadow()
    local vipLv = UserData:getUserObj():getVip()
	local vipBuyTimes = GameData:getConfData("vip")[tostring(vipLv)].exploreTaskExtra
	local remainBuyTimes = vipBuyTimes - boughtTime 
	if remainBuyTimes < 0 then
		remainBuyTimes = 0
	end
    local str1 = "\n"..string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX31"),vipLv,remainBuyTimes) 
    local rt5 = xx.RichTextLabel:create(str1, 18,cc.c4b(137, 0, 0, 255))
    rt5:setStrokeSize(0)
    rt5:clearShadow()

    rt:addElement(rt1)
    rt:addElement(rt2)
    rt:addElement(rt3)
    rt:addElement(rt4)
    rt:addElement(rt5)
    rt:setAlignment("middle")
    rt:setPosition(cc.p(195,160))
    rt:setContentSize(cc.size(400, 30))
	rt:format(true)

    local titleStr = GlobalApi:getLocalStr_new('HOOK_MIAN_INFOTX32')
    promptmgr:showMessageBoxWithTitle(titleStr,rt, MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()

    	if remainBuyTimes <= 0 then
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX33"), COLOR_TYPE.RED)
			return
		end

    	local hasCash = UserData:getUserObj():getCash()
    	if hasCash >= costYB then

    		MessageMgr:sendPost('buy','auto_fight',json.encode({}),function (response)
				local code = response.code
		        local data = response.data
		        if code == 0 then
					local cost = response.data.cost
					if cost then
						GlobalApi:parseAwardData(cost)
					end
					self.already_buy = data.already_buy
					self:updateTask()
				end
			end)
    	else
    		promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                GlobalApi:getGotoByModule("cash")
            end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
    	end
    end)

end

--加速完成搜寻
function HookMainUI:taskFucMsg(exploring,taskIndex)

	if not self.exploreTaskInfo[taskIndex] then
		return
	end
	local exploreBase = GameData:getConfData("explorebase")
	local taskId = self.exploreTaskInfo[taskIndex].task_id
	if exploring then

		local costYB = exploreBase['taskQuickAchieve'].value
		local rt = xx.RichText:create()
	    rt:setAnchorPoint(cc.p(0.5, 0.5))
	    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX21"), 18, COLOR_TYPE.WHITE1)
	    rt1:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt1:clearShadow()
	    local rt2 = xx.RichTextImage:create("uires/ui_new/res/cash.png")
	    local rt3 = xx.RichTextLabel:create(costYB, 18, COLOR_TYPE.WHITE1)
	    rt3:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
	    rt3:clearShadow()
	    local rt4 = xx.RichTextLabel:create(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX24"), 18,COLOR_TYPE.WHITE1)
    	rt4:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    	rt4:clearShadow()
    	rt:addElement(rt1)
	    rt:addElement(rt2)
	    rt:addElement(rt3)
	    rt:addElement(rt4)
	    rt:setAlignment("middle")
	    rt:setPosition(cc.p(195,160))
	    rt:setContentSize(cc.size(400, 30))
		rt:format(true)
    	promptmgr:showMessageBox(rt,MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()
	    	local hasCash = UserData:getUserObj():getCash()
	    	if hasCash >= costYB then
	    		local args = {
					task_id = taskId
				}
				MessageMgr:sendPost('get_awards','auto_fight',json.encode(args),function (response)
					local code = response.code
			        local data = response.data
			        if code == 0 then
						local cost = response.data.cost
						if cost then
							GlobalApi:parseAwardData(cost)
						end
						local awards = response.data.awards
	                    if awards then
	                        GlobalApi:parseAwardData(awards)
	                        GlobalApi:showAwardsCommon(awards,nil,nil,true) 
	                    end

	                    self.exploreTaskInfo[taskIndex] = data.task
						self:updateTask()
					end
				end)
	    	else
	    		promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
	                GlobalApi:getGotoByModule("cash")
	            end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
	    	end
	    end)
	else

		local taskBasicTimes = exploreBase["taskBasicTimes"].value
		local totalTaskNum = taskBasicTimes+self.already_buy
		local remainTimes = totalTaskNum - self.exploreFinshiCount
		if remainTimes <= 0 then
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new('HOOK_MIAN_INFOTX38'), COLOR_TYPE.RED)
			return
		end

		if self.exploreTaskInfo[taskIndex].hid == 0 then
			promptmgr:showSystenHint(GlobalApi:getLocalStr_new('HOOK_MIAN_INFOTX34'), COLOR_TYPE.RED)
			return
		end

		local args = {
			task_id = taskId
		}
		MessageMgr:sendPost('start_search','auto_fight',json.encode(args),function (response)
			local code = response.code
	        local data = response.data
	        if code == 0 then
	        	self.exploreFinshiCount = data.already_num
				self.exploreTaskInfo[taskIndex].start_time = data.task.start_time
				self:updateTask()
			end
		end)
	end
end

return HookMainUI