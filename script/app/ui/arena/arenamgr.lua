local ClassArenaUI = require("script/app/ui/arena/arenaui")
local ClassArenaEntranceUI = require("script/app/ui/arena/arenaentranceui")
local ClassArenaAwardUI = require("script/app/ui/arena/arenaaward")
local ClassArenaAchieveUI = require("script/app/ui/arena/arenaachieve")
local ClassArenaPreviewUI = require("script/app/ui/arena/arenapreview")
local ClassArenaHighestRank = require('script/app/ui/arena/arenahighestrank')
local ClassArenaRankUI = require("script/app/ui/arena/arenarankui")
local ClassArenaChangeRankUI = require("script/app/ui/arena/arenachangerankui")
local ClassArenaV2Report = require('script/app/ui/arena/arenav2report')
local ClassArenaAward = require('script/app/ui/arena/arenav2award')
local ClassArenaV2Daily = require('script/app/ui/arena/arenav2daily')

cc.exports.ArenaMgr = {
	uiClass = {
		arenaUI = nil,
		arenaEntranceUI = nil,
		arenaAwardUI = nil,
		arenaAchieveUI = nil,
		arenaPreviewUI = nil,
		arenaHighestRankUI = nil,
		arenaRankUI = nil,
		arenaChangeRankUI = nil,
		arenav2reportUI = nil,
		arenaawardUI = nil,
		arenav2dailyUI = nil,
		
	},
	myRank = 0,
	myLevel = 1,
}

setmetatable(ArenaMgr.uiClass, {__mode = "v"})

function ArenaMgr:showArena(arenaType)

	arenaType = arenaType or 1
	local args = {
		type = arenaType
	}
	if self.uiClass["arenaUI"] == nil then
		MessageMgr:sendPost('get', 'arena', json.encode(args), function (jsonObj)
			if jsonObj.code == 0 then
				local count = jsonObj.data.count
                self.arenaData = jsonObj.data
				UserData:getUserObj():setArenaCount(count)
				self.uiClass['arenaUI'] = ClassArenaUI.new(jsonObj,arenaType)
				self.uiClass['arenaUI']:showUI()
			end
		end)
	end
end

function ArenaMgr:hideArena()
	if self.uiClass["arenaUI"] ~= nil then
		self.uiClass["arenaUI"]:hideUI()
		self.uiClass["arenaUI"] = nil
	end
end

function ArenaMgr:showArenaEntrance()
	if self.uiClass["arenaEntranceUI"] == nil then
		self.uiClass["arenaEntranceUI"] = ClassArenaEntranceUI.new(1)
		self.uiClass["arenaEntranceUI"]:showUI()
	end
end

function ArenaMgr:hideArenaEntrance()
	if self.uiClass["arenaEntranceUI"] then
		self.uiClass["arenaEntranceUI"]:hideUI()
		self.uiClass["arenaEntranceUI"] = nil
	end
end

function ArenaMgr:showArenaAwardUI(arenaType,rankIndx)
	if self.uiClass["arenaAwardUI"] == nil then
		self.uiClass["arenaAwardUI"] = ClassArenaAwardUI.new(arenaType,rankIndx)
		self.uiClass["arenaAwardUI"]:showUI()
	end
end

function ArenaMgr:hideArenaAwardUI()
	if self.uiClass["arenaAwardUI"] then
		self.uiClass["arenaAwardUI"]:hideUI()
		self.uiClass["arenaAwardUI"] = nil
	end
end

function ArenaMgr:showArenaAchieveUI(arenaType,myRank,maxType,maxRank,award_got)
	if self.uiClass["arenaAchieveUI"] == nil then
		self.uiClass["arenaAchieveUI"] = ClassArenaAchieveUI.new(arenaType,myRank,maxType,maxRank,award_got)
		self.uiClass["arenaAchieveUI"]:showUI()
	end
end

function ArenaMgr:hideArenaAchieveUI()
	if self.uiClass["arenaAchieveUI"] then
		self.uiClass["arenaAchieveUI"]:hideUI()
		self.uiClass["arenaAchieveUI"] = nil
	end
end

function ArenaMgr:showArenaPreviewUI(arenaType,getAwardLv)
	if self.uiClass["arenaPreviewUI"] == nil then
		self.uiClass["arenaPreviewUI"] = ClassArenaPreviewUI.new(arenaType,getAwardLv)
		self.uiClass["arenaPreviewUI"]:showUI()
	end
end

function ArenaMgr:hideArenaPreviewUI()
	if self.uiClass["arenaPreviewUI"] then
		self.uiClass["arenaPreviewUI"]:hideUI()
		self.uiClass["arenaPreviewUI"] = nil
	end
end

function ArenaMgr:showArenaHighestRank(highestRank, diffRank, displayAwards)
	if self.uiClass.arenaHighestRankUI == nil then
		self.uiClass.arenaHighestRankUI = ClassArenaHighestRank.new(highestRank, diffRank, displayAwards)
		self.uiClass.arenaHighestRankUI:showUI()
	end
end

function ArenaMgr:hideArenaHighestRank()
	if self.uiClass.arenaHighestRankUI ~= nil then
		self.uiClass.arenaHighestRankUI:hideUI()
		self.uiClass.arenaHighestRankUI = nil
	end
end

function ArenaMgr:showArenaRank(index)
	if self.uiClass["arenaRankUI"] == nil then
		self.uiClass["arenaRankUI"] = ClassArenaRankUI.new(index)
		self.uiClass["arenaRankUI"]:showUI()
	end
end

function ArenaMgr:hideArenaRank()
	if self.uiClass["arenaRankUI"] ~= nil then
		self.uiClass["arenaRankUI"]:hideUI()
		self.uiClass["arenaRankUI"] = nil
	end
end

function ArenaMgr:showArenaChangeRank(headpic, quality,frameid, name1, fightforce1, name2, fightforce2, rank1, rank2, diff)
	if self.uiClass["arenaChangeRankUI"] == nil then
		self.uiClass["arenaChangeRankUI"] = ClassArenaChangeRankUI.new(headpic, quality,frameid, name1, fightforce1, name2, fightforce2, rank1, rank2, diff)
		self.uiClass["arenaChangeRankUI"]:showUI()
	end
end

function ArenaMgr:hideArenaChangeRank()
	if self.uiClass["arenaChangeRankUI"] ~= nil then
		self.uiClass["arenaChangeRankUI"]:hideUI()
		self.uiClass["arenaChangeRankUI"] = nil
	end
end

function ArenaMgr:getArenaShopSign()
    if not self.arenaData then
        return false
    end
    local judge = false
    local conf = GameData:getConfData('arenarank')
    for k,v in pairs(conf) do
        if self.arenaData.max_rank <= v.count and not self.arenaData.shop[tostring(k)] then
            local cost = DisplayData:getDisplayObj(v.cost[1])
            if cost:getNum() <= UserData:getUserObj():getArena() then
                judge = true
                break
            end
        end
    end

    return judge
end


function ArenaMgr:showArenaV2Report()
	if self.uiClass.arenav2reportUI == nil then
		UserData:getUserObj():setSignByType('arena_report',0)
		self.uiClass.arenav2reportUI = ClassArenaV2Report.new()
		self.uiClass.arenav2reportUI:showUI()
	end
end

function ArenaMgr:hideArenaV2Report()
	if self.uiClass.arenav2reportUI ~= nil then
		self.uiClass.arenav2reportUI:hideUI()
		self.uiClass.arenav2reportUI = nil
	end
end

function ArenaMgr:showArenaAward(ntype,tx,callback)
	if self.uiClass.arenaawardUI == nil then
		self.uiClass.arenaawardUI = ClassArenaAward.new(ntype,tx,callback)
		self.uiClass.arenaawardUI:showUI(UI_SHOW_TYPE.STUDIO)
	end
end

function ArenaMgr:hideArenaAward()
	if self.uiClass.arenaawardUI ~= nil then
		self.uiClass.arenaawardUI:hideUI()
		self.uiClass.arenaawardUI = nil
	end
end
