-- 文件：排行榜脚本
-- 创建：zzx
-- 日期：2017-11-27

local ClassItemCell 		= require('script/app/global/itemcell')

local RankingListMainNewUI 	= class('RankingListMainNewUI', BaseUI)

local menuTree = {
	-- 战力排行
	[1] = {
		tab_btn_txt 		= 'COMMON_STR_FIGHT',
		left_sub_title 		= 'STR_RANK',
		middle_sub_title 	= 'STR_PLAYER_INFO',
		right_sub_title 	= 'COMMON_STR_FIGHT',
		msg_mod 			= 'user',
		msg_act 			= 'rank_list',
	},
	-- 竞技场排行
	[2] = {
		tab_btn_txt 		= 'STR_ARENA',
		left_sub_title 		= 'STR_RANK',
		middle_sub_title 	= 'STR_PLAYER_INFO',
		right_sub_title 	= 'STR_DUAN_WEI',
		msg_mod 			= 'arena',
		msg_act 			= 'rank_list',
	},
	-- 千层塔
	[3] = {
		tab_btn_txt 		= 'STR_THOUSAND_TOWER',
		left_sub_title 		= 'STR_RANK',
		middle_sub_title 	= 'STR_PLAYER_INFO',
		right_sub_title 	= 'STR_FLOOR',
		msg_mod 			= 'tower',
		msg_act 			= 'rank_list',
	},
	-- 等级
	[4] = {
		tab_btn_txt 		= 'STR_LEVEL',
		left_sub_title 		= 'STR_RANK',
		middle_sub_title 	= 'STR_PLAYER_INFO',
		right_sub_title 	= 'STR_LEVEL',
		msg_mod 			= 'user',
		msg_act 			= 'level_rank_list',
	}
}

local function getFightForceStr( fightforce_ )
	if fightforce_ >= 1000000 then
		return math.floor(fightforce_ / 10000) .. 'w'
	else
		return tostring(fightforce_)
	end
end

function RankingListMainNewUI:ctor(menutab)
	-- base data
	self.uiIndex 			= GAME_UI.UI_RANKINGLIST_V3

	self._showTab 			= {1,2,3,4}
	self._menuArr 			= menuTree

	self._rankListData 		= {}

	self._curSelectIdx 		= 1
end

function RankingListMainNewUI:setUIBackInfo()
	UIManager.sidebar:setBackBtnCallback(UIManager:getUIName(GAME_UI.UI_RANKINGLIST_V3), function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr:PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			RankingListMgr:hideRankingListMain()
		end
	end)
end

function RankingListMainNewUI:onShow()
	self:setUIBackInfo()
end

function RankingListMainNewUI:onHide()
	self:stopSchedule()
end

function RankingListMainNewUI:init()
	local bgImg 		= self.root:getChildByName("bg_img")
	local bagImg 		= bgImg:getChildByName("bg")

    self:adaptUI(bgImg, bagImg)
    
    self:setUIBackInfo()

    self._tabListPl 	= bagImg:getChildByName('tab_list')

    local frameBg 		= bagImg:getChildByName('frame')

    self._leftBg 		= frameBg:getChildByName('left_bg')
    self._rightBg 		= frameBg:getChildByName('right_bg')

    self._rankListView 	= self._rightBg:getChildByName('rank_list')
    self._rankListView:setScrollBarEnabled(false)

    self:initTabBtns()

    self:switchChannel()
end

function RankingListMainNewUI:initTabBtns()

	local startX 		= 51
	local startY 		= 442

	local itemHeight 	= 90

	for i, v in ipairs (self._showTab) do
		local tab 		= self._tabListPl:getChildByName('tab_' .. i)
		local funcTx 	= tab:getChildByName('func_tx')
		local linkImg 	= tab:getChildByName('link')

		local typeIdx 	= v
		local typeObj 	= self._menuArr[v]

		funcTx:setString( GlobalApi:getLocalStr_new(typeObj['tab_btn_txt']) )

		local posX 		= startX
		local posY 		= startY - (i - 1) * itemHeight

		tab:setPosition(cc.p(posX, posY))

		tab:addClickEventListener(function ()
			self:onClickFuncTab( typeIdx )
		end)
	end
end

function RankingListMainNewUI:getCloneCell()
	return self._rightBg:getChildByName('clone_cell'):clone()
end

function RankingListMainNewUI:onClickFuncTab( typeIdx_ )
	if typeIdx_ == self._curSelectIdx then
		return
	end

	self._curSelectIdx = typeIdx_

	self:switchChannel()
end

function RankingListMainNewUI:switchChannel()

	local function update()
		self:updateTabBtnsSelect()
		self:updateMyItem()
		self:updateLeftBg()
		self:updateListView()
	end

	if self._rankListData[self._curSelectIdx] then
		update()
		return
	end

	local typeObj 		= self._menuArr[self._curSelectIdx]

	if not typeObj then
		print('no find typeObj <<<')
		return
	end

	local msgMod 		= typeObj['msg_mod']
	local msgAct 		= typeObj['msg_act']

	local msgArgs 		= {}

	-- 竞技场参数特殊处理
	if self._curSelectIdx == 2 then
		msgArgs['type'] = 1
	end

	MessageMgr:sendPost(msgAct, msgMod,json.encode(msgArgs),function (jsonObj)

		if 0 ~= jsonObj.code then
			return
		end
		print('*********************************************************')
		PrintT(jsonObj, true)
		print('*********************************************************')

		local data = jsonObj.data

		self._rankListData[self._curSelectIdx] = data
		
		update()
	end)
end

function RankingListMainNewUI:updateTabBtnsSelect()
	for i, v in ipairs (self._showTab) do
		local tab 		= self._tabListPl:getChildByName('tab_' .. i)
		local funcTx 	= tab:getChildByName('func_tx')
		
		if self._curSelectIdx == v then
			tab:setTouchEnabled(false)
			tab:loadTextureNormal('uires/ui_new/common/role_tab_select.png')
			funcTx:setTextColor(cc.c4b(196,243,241,255))
			funcTx:enableOutline(cc.c4b(46,89,81,255),1)
		else
			tab:setTouchEnabled(true)
			tab:loadTextureNormal('uires/ui_new/common/role_tab_normal.png')
			funcTx:setTextColor(cc.c4b(79,126,123,255))
			funcTx:enableOutline(cc.c4b(28,40,42,255),1)
		end
	end
end

function RankingListMainNewUI:updateListView()
	local curData 			= self._rankListData[self._curSelectIdx]

	if not curData then
		print('no curData in updateListView <<<')
	end

	local typeObj 			= self._menuArr[self._curSelectIdx]

	if not typeObj then
		print('no typeObj in updateListView <<<')
		return
	end

	self:stopSchedule()

	self._rankListView:removeAllChildren()
	self._rankListView:jumpToTop()

	local rankListBg 		= self._rightBg:getChildByName('ranklist_bg')
	local leftDescTx 		= rankListBg:getChildByName('left_desc_tx')
	local middleDescTx 		= rankListBg:getChildByName('middle_desc_tx')
	local rightDescTx 		= rankListBg:getChildByName('right_desc_tx')

	leftDescTx:setString( GlobalApi:getLocalStr_new(typeObj['left_sub_title']) )
	middleDescTx:setString( GlobalApi:getLocalStr_new(typeObj['middle_sub_title']) )
	rightDescTx:setString( GlobalApi:getLocalStr_new(typeObj['right_sub_title']) )

	local curIndex 			= 1
	local rankListArr 		= curData['rank_list']

	self._rankListView:setTouchEnabled(false)

	local function callBack()
		if rankListArr[curIndex] then

			local item = self:getCloneCell()

			self:updateItem(item, curIndex, rankListArr[curIndex])

			self._rankListView:pushBackCustomItem(item)

			curIndex = curIndex + 1
		else
			self:stopSchedule()

			self._rankListView:setTouchEnabled(true)
		end
	end

	self._scheduleId 		= GlobalApi:interval(callBack,0.05)
end

function RankingListMainNewUI:stopSchedule()
	if self._scheduleId then
		GlobalApi:clearScheduler(self._scheduleId)
		self._scheduleId = nil
	end
end

function RankingListMainNewUI:updateMyItem()
	local curData 			= self._rankListData[self._curSelectIdx]

	if not curData then
		print('no curData in updateMyItem <<<')
	end

	local typeObj 			= self._menuArr[self._curSelectIdx]

	if not typeObj then
		print('no typeObj in updateMyItem <<<')
		return
	end

	local myItem 			= self._rightBg:getChildByName('my_item')
	local infoBg 			= myItem:getChildByName('info_bg')

	local rankImg  			= infoBg:getChildByName('rank_img')
	local rankIco 			= infoBg:getChildByName('rank_ico')
	local rankTx 			= infoBg:getChildByName('rank_tx')

	local headpicFrame 		= infoBg:getChildByName('headpic_frame')
	local headPic 			= headpicFrame:getChildByName('headpic')
	local vipBMTx 			= headpicFrame:getChildByName('vip_bm_tx')

	local fightforcePl 		= infoBg:getChildByName('fightforce_pl')
	local rankPl 			= infoBg:getChildByName('rank_pl')
	local towerPl 			= infoBg:getChildByName('tower_pl')
	local levelPl 			= infoBg:getChildByName('level_pl')

	local userObj 			= UserData:getUserObj()
	-- local myData 			= {}

	-- myData['name'] 			= userObj:getName()
	-- myData['level'] 		= userObj:getLv()
	-- myData['frame'] 		= RoleData:getMainRole():getBgImg()
	-- myData['headframe'] 	= userObj:getHeadFrame()
	-- myData['headpic'] 		= userObj:getHeadpic()
	-- myData['vip'] 			= userObj:getVip()
	-- myData['fight_force'] 	= userObj:getFightforce()

	local myRank 			= curData['rank'] or 0

	if myRank < 5 then
		rankImg:loadTexture('uires/ui_new/ranklist/rank_bg' .. myRank .. '.png')
	else
		rankImg:loadTexture('uires/ui_new/ranklist/rank_bg5.png')
	end

	if myRank >= 1 and myRank <= 3 then
		rankIco:setVisible(true)
		rankTx:setVisible(false)
		rankIco:loadTexture('uires/ui_new/rank/rank_' .. myRank .. '.png')
	else
		rankIco:setVisible(false)
		rankTx:setVisible(true)
		rankTx:setString(myRank == 0 and GlobalApi:getLocalStr_new('STR_NOT_ON_THE_LIST') or myRank)
	end

	headpicFrame:loadTexture( RoleData:getMainRole():getBgImg() )
	-- headPic:ignoreContentAdaptWithSize(true)
	headPic:loadTexture( userObj:getHeadpic() )

	vipBMTx:setString('vip' .. userObj:getVip())

	fightforcePl:setVisible(false)
	rankPl:setVisible(false)
	towerPl:setVisible(false)
	levelPl:setVisible(false)

	-- local legionInfo		= userObj:getLegionInfo()

	-- PrintT(legionInfo, true)

	local function updateFightforcePl()
		fightforcePl:setVisible(true)

		local nameTx 		= fightforcePl:getChildByName('name_tx')
		local legionIco 	= fightforcePl:getChildByName('legion_ico')
		local legionNameTx 	= fightforcePl:getChildByName('legion_name_tx')
		local fightForceBmTx = fightforcePl:getChildByName('fightforce_bm_tx')

		nameTx:setString( userObj:getName() )
			
		if userObj.lname ~= '' then
			legionNameTx:setFontSize(15)
			legionIco:setVisible(true)
			legionIco:loadTexture('uires/ui/legion/1_jun.png')
			legionNameTx:setString( userObj.lname )
			legionNameTx:setPosition(cc.p(32, 30.5))
		else
			legionNameTx:setFontSize(15)
			legionIco:setVisible(false)
			legionNameTx:setString( GlobalApi:getLocalStr_new('STR_NOT_JOIN_LEGION') )
			legionNameTx:setPosition(cc.p(0, 30.5))
		end 

		fightForceBmTx:setString( getFightForceStr(userObj:getFightforce()) )
	end

	local function updateRankPl()
		rankPl:setVisible(true)

		local nameTx 		= rankPl:getChildByName('name_tx')
		local fightforceIco = rankPl:getChildByName('fightforce_ico')
		local fightForceTx 	= rankPl:getChildByName('fightforce_tx')
		local stageIco 		= rankPl:getChildByName('stage_ico')
		local stageLvBg 	= rankPl:getChildByName('stage_lv_bg')
		local stageLvTx 	= stageLvBg:getChildByName('lv_tx')

		nameTx:setString( userObj:getName() )
		fightForceTx:setString( getFightForceStr(userObj:getFightforce()) )
	end

	local function updateTowerPl()
		towerPl:setVisible(true)

		local nameTx 		= towerPl:getChildByName('name_tx')
		local fightforceIco = towerPl:getChildByName('fightforce_ico')
		local fightForceTx 	= towerPl:getChildByName('fightforce_tx')
		local towerNumTx 	= towerPl:getChildByName('tower_num_tx')

		nameTx:setString( userObj:getName() )
		fightForceTx:setString( userObj:getFightforce() )

		towerNumTx:setString( curData['floor'] .. GlobalApi:getLocalStr_new('STR_FLOOR_1') )
	end

	local function updateLevelPl()
		levelPl:setVisible(true)

		local nameTx 		= levelPl:getChildByName('name_tx')
		local levelTx 		= levelPl:getChildByName('level_tx')

		local lvBarBg 		= levelPl:getChildByName('lv_bar_bg')
		local bar 			= lvBarBg:getChildByName('bar')
		local tx 			= lvBarBg:getChildByName('tx')

		nameTx:setString( userObj:getName() )
		levelTx:setString( 'Lv.' .. userObj:getLv() )

		local per 			= math.floor(userObj:lvPrecent() * 100) / 100
		
		bar:setPercent(per)
		tx:setString(per..'%')
	end

	if self._curSelectIdx == 1 then
		updateFightforcePl()
	elseif self._curSelectIdx == 2 then
		updateRankPl()
	elseif self._curSelectIdx == 3 then
		updateTowerPl()
	elseif self._curSelectIdx == 4 then
		updateLevelPl()
	end
end

function RankingListMainNewUI:updateItem( item_, rank_, data_ )

	item_:stopAllActions()
	item_:setVisible(true)
	item_:setOpacity(0)

	item_:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

	local rankImg  		= item_:getChildByName('rank_img')
	local rankIco 		= item_:getChildByName('rank_ico')
	local rankTx 		= item_:getChildByName('rank_tx')

	local headpicFrame 	= item_:getChildByName('headpic_frame')
	local headPic 		= headpicFrame:getChildByName('headpic')
	local vipBMTx 		= headpicFrame:getChildByName('vip_bm_tx')

	local fightforcePl 	= item_:getChildByName('fightforce_pl')
	local rankPl 		= item_:getChildByName('rank_pl')
	local towerPl 		= item_:getChildByName('tower_pl')
	local levelPl 		= item_:getChildByName('level_pl')

	if rank_ < 5 then
		rankImg:loadTexture('uires/ui_new/ranklist/rank_bg' .. rank_ .. '.png')
	else
		rankImg:loadTexture('uires/ui_new/ranklist/rank_bg5.png')
	end

	if rank_ >= 1 and rank_ <= 3 then
		rankIco:setVisible(true)
		rankTx:setVisible(false)
		rankIco:loadTexture('uires/ui_new/rank/rank_' .. rank_ .. '.png')
	else
		rankIco:setVisible(false)
		rankTx:setVisible(true)
		rankTx:setString(rank_ == 0 and GlobalApi:getLocalStr_new('STR_NOT_ON_THE_LIST') or rank_)
	end

	local picObj 		= RoleData:getHeadPicObj(data_['headpic'])

	-- headPic:ignoreContentAdaptWithSize(true)
	headPic:loadTexture( picObj:getIcon() )

	if data_['uid'] <= 1000000 then -- 机器人
		headpicFrame:loadTexture(COLOR_ITEMFRAME.ORANGE)
	else
		local _,heroCombatConf 	= GlobalApi:getHeroConf(data_['main_role'])
		local quality 			= heroCombatConf['quality']
		headpicFrame:loadTexture(COLOR_FRAME[quality])
	end

	if data_['vip'] then
		vipBMTx:setString('vip' .. data_['vip'] )
	else
		vipBMTx:setString( '' )
	end

	fightforcePl:setVisible(false)
	rankPl:setVisible(false)
	towerPl:setVisible(false)
	levelPl:setVisible(false)

	local function updateFightforcePl()
		fightforcePl:setVisible(true)

		local nameTx 		= fightforcePl:getChildByName('name_tx')
		local legionIco 	= fightforcePl:getChildByName('legion_ico')
		local legionNameTx 	= fightforcePl:getChildByName('legion_name_tx')
		local fightForceBmTx = fightforcePl:getChildByName('fightforce_bm_tx')

		nameTx:setString( data_['un'] )

		if data_['legion_name']  ~= '' then
			legionNameTx:setFontSize(15)
			legionIco:setVisible(true)
			legionIco:loadTexture('uires/ui/legion/' .. data_['legion_icon'] .. '_jun.png')
			legionNameTx:setString( data_['legion_name'] )
			legionNameTx:setPosition(cc.p(32, 30.5))
		else
			legionNameTx:setFontSize(15)
			legionIco:setVisible(false)
			legionNameTx:setString( GlobalApi:getLocalStr_new('STR_NOT_JOIN_LEGION') )
			legionNameTx:setPosition(cc.p(0, 30.5))
		end 

		fightForceBmTx:setString( getFightForceStr(data_['fight_force']) )
	end

	local function updateRankPl()
		rankPl:setVisible(true)

		local nameTx 		= rankPl:getChildByName('name_tx')
		local fightforceIco = rankPl:getChildByName('fightforce_ico')
		local fightForceTx 	= rankPl:getChildByName('fightforce_tx')
		local stageIco 		= rankPl:getChildByName('stage_ico')
		local stageLvBg 	= rankPl:getChildByName('stage_lv_bg')
		local stageLvTx 	= stageLvBg:getChildByName('lv_tx')

		nameTx:setString( data_['un'] )
		fightForceTx:setString( getFightForceStr(data_['fight_force']) )
	end

	local function updateTowerPl()
		towerPl:setVisible(true)

		local nameTx 		= towerPl:getChildByName('name_tx')
		local fightforceIco = towerPl:getChildByName('fightforce_ico')
		local fightForceTx 	= towerPl:getChildByName('fightforce_tx')
		local towerNumTx 	= towerPl:getChildByName('tower_num_tx')

		nameTx:setString( data_['un'] )
		fightForceTx:setString( data_['fight_force'] or 0 )

		towerNumTx:setString( (data_['floor'] or 0) .. GlobalApi:getLocalStr_new('STR_FLOOR_1') )
	end

	local function updateLevelPl()
		levelPl:setVisible(true)

		local nameTx 		= levelPl:getChildByName('name_tx')
		local levelTx 		= levelPl:getChildByName('level_tx')

		local lvBarBg 		= levelPl:getChildByName('lv_bar_bg')
		local bar 			= lvBarBg:getChildByName('bar')
		local tx 			= lvBarBg:getChildByName('tx')

		nameTx:setString( data_['un'] )
		levelTx:setString( 'Lv.' .. data_['level'] )

		local lvConf 		= GameData:getConfData("level")[data_['level']]
		local per 			= math.floor(data_['xp'] / lvConf['exp'] * 10000) / 100

		bar:setPercent(per)
		tx:setString(per..'%')
	end

	if self._curSelectIdx == 1 then
		updateFightforcePl()
	elseif self._curSelectIdx == 2 then
		updateRankPl()
	elseif self._curSelectIdx == 3 then
		updateTowerPl()
	elseif self._curSelectIdx == 4 then
		updateLevelPl()
	end
end

function RankingListMainNewUI:updateLeftBg()
	local curData 			= self._rankListData[self._curSelectIdx]

	if not curData then
		print('no curData in updateLeftBg <<<')
	end

	local firstImg 			= self._leftBg:getChildByName('first_img')
	local stoneSite 		= self._leftBg:getChildByName('stone_site')
	local modelNode 		= stoneSite:getChildByName('model_node')
	local nameBg 			= self._leftBg:getChildByName('name_bg')

	local nameTx 			= nameBg:getChildByName('name_tx')
	local legionTx 			= nameBg:getChildByName('legion_tx')

	local rankListArr 		= curData['rank_list']

	local firstData 		= rankListArr[1]

	local function deleteLastModelAni()
		local oldAni 		= modelNode:getChildByName('spineAni')
		if oldAni then
			oldAni:removeFromParent()
			oldAni = nil
		end
	end

	if not firstData then
		nameTx:setString('')
		legionTx:setString('')
		deleteLastModelAni()
		return
	end

	nameTx:setString( 'Lv.' .. firstData['level'] .. ' ' .. firstData['un'] )

	if firstData['legion_name'] and firstData['legion_name'] ~= '' then
		legionTx:setString( GlobalApi:getLocalStr_new('STR_LEGION') .. firstData['legion_name'] )
	else
		legionTx:setString( GlobalApi:getLocalStr_new('STR_NOT_JOIN_LEGION') )
	end

	deleteLastModelAni()

	if firstData['max_force_hid'] then
		--模型
	    local hid 				= tonumber(firstData['max_force_hid'])
	    local promote 			= firstData.promote
	    local weapon_illusion 	= firstData.weapon_illusion
	    local wing_illusion 	= firstData.wing_illusion
	    local _,heroCombatConf 	= GlobalApi:getHeroConf(hid)


	    local promote 			= nil
    	local weapon_illusion 	= nil
    	local wing_illusion 	= nil

	    if firstData.promote and firstData.promote[1] then
	        promote = firstData.promote[1]
	    end

	    if heroCombatConf.camp == 5 then
	        if firstData.weapon_illusion and firstData.weapon_illusion > 0 then
	            weapon_illusion = firstData.weapon_illusion
	        end
	        if firstData.wing_illusion and firstData.wing_illusion > 0 then
	            wing_illusion 	= firstData.wing_illusion
	        end
	    end

	    local changeEquipObj 	= GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
	    local spineAni 			= GlobalApi:createLittleLossyAniByRoleId(hid,changeEquipObj)
	   
	    spineAni:setPosition(cc.p(0,-10))
	    spineAni:getAnimation():play("idle")
	    spineAni:setName('spineAni')
	  
	    modelNode:addChild(spineAni)
	end
end

return RankingListMainNewUI


