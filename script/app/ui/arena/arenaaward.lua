local ArenaAwardUI = class('ArenaAwardUI', BaseUI)

local headImg = {
    [1] =  'uires/ui_new/rank/head_bg1.png',
    [2] =  'uires/ui_new/rank/head_bg2.png',
    [3] =  'uires/ui_new/rank/head_bg3.png',
    [4] =  'uires/ui_new/rank/head_bg4.png',
    [5] =  'uires/ui_new/rank/head_bg5.png',
}


function ArenaAwardUI:ctor(arenaType,rankIndx)
	self.uiIndex = GAME_UI.UI_ARENA_AWARD
	self.default = nil
	self.arenaType = arenaType or 1
	self.rankIndx = rankIndx
end

function ArenaAwardUI:init()
	local bgimg = self.root:getChildByName('bg_img')
	local bg1 = bgimg:getChildByName('bg')
	self:adaptUI(bgimg, bg1)

	local arenabaseCfg = GameData:getConfData("arenabase")[self.arenaType]

	bg1:getChildByName('close_btn')
		:addClickEventListener(function ()
			ArenaMgr:hideArenaAwardUI()
		end)

	local titleStr = string.format(GlobalApi:getLocalStr_new("AREAN_TIP_TX8"),arenabaseCfg.name)
	bg1:getChildByName('title_tx')
		:setString(titleStr)

	local list = bg1:getChildByName('sv_bg')
		:getChildByName('list')

	if self.default == nil then
		local cell = cc.CSLoader:createNode('csb/arena_award_cell.csb')
		self.default = cell:getChildByName('cell_bg')
	end
	list:setItemModel(self.default)
	list:setScrollBarEnabled(false)

	local arenaRankCfg = GameData:getConfData('arenarank')[self.arenaType]

	local lastrank = 1
	for i, v in ipairs(arenaRankCfg) do
		list:pushBackDefaultItem()

		local cellBg = list:getItem(i - 1)
		local headBg = cellBg:getChildByName("head_bg")
		local rankTx = headBg:getChildByName('rank_text')
		local rankImg = headBg:getChildByName('rank_img')
		local meImg = headBg:getChildByName('me_img')
		if meImg then
			meImg:setVisible(self.rankIndx == i)
		end
		if i >= 5 then
			headBg:loadTexture(headImg[5])
		else
		 	headBg:loadTexture(headImg[i])
		end
        if i <= 3 then
            rankTx:setString('')
            rankImg:loadTexture('uires/ui_new/rank/rank_'..i..'.png')
        elseif i == #arenaRankCfg then
            rankImg:setVisible(false)
            rankTx:setString((arenaRankCfg[i - 1].rank)..GlobalApi:getLocalStr_new("COMMON_RANK_MING1"))
        else
            rankImg:setVisible(false)
            local conf1 = arenaRankCfg[i - 1]
            if arenaRankCfg[i].rank - 1 == conf1.rank then
                rankTx:setString(arenaRankCfg[i].rank..GlobalApi:getLocalStr_new("COMMON_RANK_MING"))
            else
                rankTx:setString((conf1.rank + 1)..'~'..arenaRankCfg[i].rank..GlobalApi:getLocalStr_new("COMMON_RANK_MING"))
            end
        end

		local award_rt = xx.RichText:create()
		local dis = DisplayData:getDisplayObjs(v.award)
		for i, v in ipairs(dis) do
			local icon = xx.RichTextImage:create(v:getIcon())
			icon:setScale(0.6)
			award_rt:addElement(icon)

			local num = xx.RichTextLabel:create(
				v:getNum(),
				24,
				cc.c4b(254,255,122,153))
			num:setStroke(cc.c4b(118,66,37,153), 2)
			num:setMinWidth(65)
			award_rt:addElement(num)
		end
		award_rt:setAlignment('middle')
		award_rt:setVerticalAlignment('middle')
		award_rt:format(true)
		award_rt:setContentSize(award_rt:getElementsSize())
		award_rt:setPosition(cc.p(400, 40))

		cellBg:addChild(award_rt)	
	end
end

return ArenaAwardUI
