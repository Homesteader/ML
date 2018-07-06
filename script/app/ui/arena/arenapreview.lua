local ArenaPreviewUI = class('ArenaPreviewUI', BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ArenaPreviewUI:ctor(arenaType,geAwardLv)
	self.uiIndex = GAME_UI.UI_ARENA_PREVIEW
	self.default = nil
	self.arenaType = arenaType or 1
	self.geAwardLv = geAwardLv or 1
end

function ArenaPreviewUI:init()
	local bgimg = self.root:getChildByName('bg_img')
	local bg1 = bgimg:getChildByName('bg')
	self:adaptUI(bgimg, bg1)

	bg1:getChildByName('close_btn')
		:addClickEventListener(function ()
			ArenaMgr:hideArenaPreviewUI()
		end)
	local arenaBaseCfg = GameData:getConfData("arenabase")[self.arenaType]
	local titleStr = string.format(GlobalApi:getLocalStr_new("AREAN_TIP_TX11"),arenaBaseCfg.name)
	bg1:getChildByName('title_tx')
		:setString(titleStr)

	local list = bg1:getChildByName('sv_bg')
		:getChildByName('list')

	if self.default == nil then
		local cell = cc.CSLoader:createNode('csb/arena_achieve_cell.csb')
		self.default = cell:getChildByName('cell_bg')
	end

	list:setItemModel(self.default)
	list:setScrollBarEnabled(false)
	local achieveCfg = GameData:getConfData('arenaachievement')[self.arenaType]
	local cellId = 0
	for i=#achieveCfg,1,-1 do
		list:pushBackDefaultItem()
		cellId = cellId + 1
		local cellBg = list:getItem(cellId-1)
		local headBg = cellBg:getChildByName("head_bg")
		local badgeIcon = headBg:getChildByName('badge_icon')
		badgeIcon:loadTexture("uires/icon/badge/"..arenaBaseCfg.icon)
		local typeNameTx = headBg:getChildByName('rank_text')
		typeNameTx:setString(arenaBaseCfg.name)
		local checkBtn = headBg:getChildByName('check_btn')
		checkBtn:setVisible(false)

		local openBg = cellBg:getChildByName("open_bg")
		local grayBg = cellBg:getChildByName("gray_bg")
		grayBg:setVisible(false)

		local funcBtn = openBg:getChildByName("func_btn")
		funcBtn:setVisible(false)
		local finsihImg = openBg:getChildByName("finish_img")
		finsihImg:setVisible(self.geAwardLv >= i)

		local rankTipTx = openBg:getChildByName("rank_tip")
		rankTipTx:setString(achieveCfg[i].desc)

		local disAwards = DisplayData:getDisplayObjs(achieveCfg[i].award)
		for j=1,2 do
			local node = openBg:getChildByName("node"..j)
            local awards = disAwards[j]
            if awards then
            	node:setVisible(true)
            	local nodeSize = node:getContentSize()
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, node)
                cell.awardBgImg:setPosition(cc.p(nodeSize.width/2,nodeSize.height/2))
            else
            	node:setVisible(false)
            end
		end

	end
end

return ArenaPreviewUI
