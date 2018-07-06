local ArenaAchieveUI = class('ArenaAchieveUI', BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local headImg = {
    [1] =  'uires/ui_new/rank/head_bg1.png',
    [2] =  'uires/ui_new/rank/head_bg2.png',
    [3] =  'uires/ui_new/rank/head_bg3.png',
    [4] =  'uires/ui_new/rank/head_bg4.png',
    [5] =  'uires/ui_new/rank/head_bg5.png',
}


function ArenaAchieveUI:ctor(arenaType,rank,highestType,highestRank,award_got)
	self.uiIndex = GAME_UI.UI_ARENA_ACHIEVE
	self.default = nil
	self.arenaType = arenaType or 1
	self.rank = rank or 10000
	self.highestType = highestType or 1
	self.highestRank = highestRank or 10000
	self.awardCell = {}
	self.getAwardTab = {0,0,0,0,0,0}
	for k,v in pairs(award_got) do
		local maxLevel = 0
		for key,value in pairs(v) do
			if maxLevel <= value then
				maxLevel = value	
			end
		end
		self.getAwardTab[tonumber(k)] = maxLevel
	end

end

function ArenaAchieveUI:init()
	local bgimg = self.root:getChildByName('bg_img')
	local bg1 = bgimg:getChildByName('bg')
	self:adaptUI(bgimg, bg1)

	bg1:getChildByName('close_btn')
		:addClickEventListener(function ()
			ArenaMgr:hideArenaAchieveUI()
		end)

	local arenaBaseCfg = GameData:getConfData("arenabase")
	bg1:getChildByName('title_tx')
		:setString(GlobalApi:getLocalStr_new("AREAN_TITLE_TX1"))

	--当前排名
	bg1:getChildByName("rank_tip")
	 	:setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX9"))
	bg1:getChildByName("rank_num")
		:setString(arenaBaseCfg[self.arenaType].name..self.rank)

	--历史最高排名
	local highestBg = bg1:getChildByName("highest_bg")
	highestBg:getChildByName("tip_tx")
			 :setString(GlobalApi:getLocalStr_new("AREAN_TIP_TX10"))
	highestBg:getChildByName("num_tx")
			 :setString(arenaBaseCfg[self.highestType].name..self.highestRank)

	self.list = bg1:getChildByName('sv_bg')
		:getChildByName('list')

	if self.default == nil then
		local cell = cc.CSLoader:createNode('csb/arena_achieve_cell.csb')
		self.default = cell:getChildByName('cell_bg')
	end
	self.list:setItemModel(self.default)
	self.list:setScrollBarEnabled(false)
	for i=1,#arenaBaseCfg do
		self.list:pushBackDefaultItem()
	end
	self:updateList()
end

function ArenaAchieveUI:updateList()

	local arenaBaseCfg = GameData:getConfData("arenabase")
	for i=1,#arenaBaseCfg do
		local cellBg = self.list:getItem(i - 1)
		local headBg = cellBg:getChildByName("head_bg")
		local badgeIcon = headBg:getChildByName('badge_icon')
		badgeIcon:loadTexture("uires/icon/badge/"..arenaBaseCfg[i].icon)
		local typeNameTx = headBg:getChildByName('rank_text')
		typeNameTx:setString(arenaBaseCfg[i].name)
		local checkBtn = headBg:getChildByName('check_btn')
		checkBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            ArenaMgr:showArenaPreviewUI(i,self.getAwardTab[i])
	        end
	    end)
		headBg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            ArenaMgr:showArenaPreviewUI(i,self.getAwardTab[i])
	        end
	    end)

		local openBg = cellBg:getChildByName("open_bg")
		local grayBg = cellBg:getChildByName("gray_bg")
		local desc,notOpenCode = GlobalApi:getGotoByModule_new("arena"..i,true)
		local isOpen = desc and false or true
		openBg:setVisible(isOpen)
		grayBg:setVisible(not isOpen)
		if not isOpen then
			local opentx = grayBg:getChildByName("open_tx")
			opentx:setString(desc)
		else
			local curLv,cfgAward,desc,fitget = self:getCurAchive(i)
			local funcBtn = openBg:getChildByName("func_btn")
			local funcTx = funcBtn:getChildByName("func_tx")
			funcTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_LQ"))
			funcBtn:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	local args = {
		        		type = self.arenaType,
		        		level = curLv
		        	}
		        	MessageMgr:sendPost('get_achievement_awards', 'arena', json.encode(args), function (jsonObj)
						if jsonObj.code == 0 then
							local awards = jsonObj.data.awards
				            if awards then
					            GlobalApi:parseAwardData(awards)
					            GlobalApi:showAwardsCommon(awards,nil,nil,true)
				            end
				            self.getAwardTab[i] = curLv
				            self:updateList()
						end
					end)
		        end
		    end)
			local finsihImg = openBg:getChildByName("finish_img")
			finsihImg:setVisible(false)

			local rankTipTx = openBg:getChildByName("rank_tip")
			rankTipTx:setString(desc)
			funcBtn:setVisible(fitget)
			local disAwards = DisplayData:getDisplayObjs(cfgAward)
			for j=1,2 do
				local node = openBg:getChildByName("node"..j)
	            local awards = disAwards[j]
	            if awards then
	            	node:setVisible(true)
	            	if self.awardCell[i] and self.awardCell[i][j] then
	            		ClassItemCell:updateItem(self.awardCell[i][j],awards,1)
	            	else
	            		if not self.awardCell[i] then
	            			self.awardCell[i] = {}
	            		end
		            	local nodeSize = node:getContentSize()
		                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, node)
		                cell.awardBgImg:setPosition(cc.p(nodeSize.width/2,nodeSize.height/2))
		                self.awardCell[i][j] = cell
		            end
	            else
	            	node:setVisible(false)
	            end
			end
		end

	end
end

--消息出来写成公有的
function ArenaAchieveUI:getCurAchive(arenaType)

	--每个竞技场所领取的奖励等级
	local achieveCfg = GameData:getConfData('arenaachievement')[arenaType]
	local getedAeardLv = self.getAwardTab[arenaType]
	local curLv
	for i=1,#achieveCfg do
		if getedAeardLv < i then
			curLv = i
			break
		end
	end
	--所以档位奖励都领取完成
	if not curLv then
		curLv = #achieveCfg
		return curLv,achieveCfg[curLv].award,achieveCfg[curLv].desc,false
	else
		--满足领奖条件
		local fitGet = false
		if self.highestRank <= achieveCfg[curLv].count and self.highestType >= arenaType then
			fitGet = true 
		end
		return curLv,achieveCfg[curLv].award,achieveCfg[curLv].desc,fitGet
	end
end

return ArenaAchieveUI
