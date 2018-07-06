local ClassTowerMainUI = require("script/app/ui/tower/towermainui")
local ClassSweepAwardsUI = require("script/app/ui/tower/towerawardsui")
local ClassAchievementUI = require("script/app/ui/tower/towerachievementui")

cc.exports.TowerMgr = {
	uiClass = {
		towerMainUI = nil,
		towerSweepAwardsUI = nil,
		towerAchievementUI = nil,
	},

	towerdata = nil,
	towerAction = false,
    towerShowAttReward = false,
}

setmetatable(TowerMgr.uiClass, {__mode = "v"})
function TowerMgr:showTowerMain(stype)
	if self.uiClass['towerMainUI'] == nil then
		MessageMgr:sendPost('get','tower',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
                UserData:getUserObj():initTower(response.data)
				self.uiClass['towerMainUI'] = ClassTowerMainUI.new(data,stype)
				self.towerdata = data
				self.uiClass['towerMainUI']:showUI()

				local awards = data.awards
				if  awards and #awards > 0 then
					GlobalApi:parseAwardData(awards)
					self:showSweepAwardsUI(data)
				end
			end
		end)
	end
end

function TowerMgr:hideTowerMain()
	if self.uiClass['towerMainUI'] then
		self.uiClass['towerMainUI']:hideUI()
		self.uiClass['towerMainUI'] = nil
	end
end

-- 显示扫荡奖励界面
function TowerMgr:showSweepAwardsUI(data)
	if self.uiClass['towerSweepAwardsUI'] == nil then
		self.uiClass['towerSweepAwardsUI'] = ClassSweepAwardsUI.new(data)
		self.uiClass['towerSweepAwardsUI']:showUI()
	end
end

-- 关闭扫荡奖励界面
function TowerMgr:hideSweepAwardsUI()
	if self.uiClass['towerSweepAwardsUI'] then
		self.uiClass['towerSweepAwardsUI']:hideUI()
		self.uiClass['towerSweepAwardsUI'] = nil
	end
end

-- 显示成就界面
function TowerMgr:showAchievementUI(maxFloor, getRecord)
	if self.uiClass['towerAchievementUI'] == nil then
		self.uiClass['towerAchievementUI'] = ClassAchievementUI.new(maxFloor, getRecord)
		self.uiClass['towerAchievementUI']:showUI()
	end
end

-- 关闭成就界面
function TowerMgr:hideAchievementUI()
	if self.uiClass['towerAchievementUI'] then
		self.uiClass['towerAchievementUI']:hideUI()
		self.uiClass['towerAchievementUI'] = nil
	end
end

function TowerMgr:setTowerAction(value)
	self.towerAction = value
end

function TowerMgr:getTowerAction()
	return self.towerAction
end

function TowerMgr:setTowerShowAttReward(value)
	self.towerShowAttReward = value
end

function TowerMgr:getTowerShowAttReward()
	return self.towerShowAttReward
end

function TowerMgr:getTowerData()
	return self.towerdata
end

function TowerMgr:setTowerData(data)
	self.towerdata = data
end

-- 更新成就领取记录
function TowerMgr:updateAchievementGetRecord(id)
	if self.uiClass['towerMainUI'] then
		self.uiClass['towerMainUI']:updateAchievementGetRecord(id)
	end
end