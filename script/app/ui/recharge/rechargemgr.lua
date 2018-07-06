cc.exports.RechargeMgr = {
	uiClass = {
		rechargeUI = nil,
		firstRechargeUI = nil,
		rechargeWaittingUI = nil
	},
	vipChanged = false
}

setmetatable(RechargeMgr.uiClass, {__mode = "v"})

local ClassRechargeUI = require("script/app/ui/recharge/recharge")
local ClassFirstRechargeUI = require("script/app/ui/recharge/firstrecharge")
local ClassRechargeWaittingUI = require("script/app/ui/recharge/rechargewaitting")

function RechargeMgr:showRecharge(vip)
	if self.uiClass['rechargeUI'] == nil then
		self.uiClass['rechargeUI'] = ClassRechargeUI.new(vip)
		self.uiClass['rechargeUI']:showUI()
	end
end

function RechargeMgr:updateRechargeDataByArr(data)
	UserData:getUserObj().cash = data.cash
	UserData:getUserObj():initPayment(data.payment)
	UserData:getUserObj().vip = data.vip or 0
	UserData:getUserObj():getMark().first_pay = data.first_pay
	self:updateRecharge()
	UIManager:updateSidebar()
end

function RechargeMgr:updateRechargeData(id)
	local rechargeName = Third:Get():getRechargeConfName()
	local conf = GameData:getConfData(rechargeName)[id]
	if not conf then
		return
	end
	local paymentInfo = UserData:getUserObj():getPayment()
	local cash = conf.cash
	if not paymentInfo.pay_list[tostring(id)] or paymentInfo.pay_list[tostring(id)] <= 0 then
		if conf.type ~= 'monthCard' and conf.type ~= 'longCard' then
			cash = cash*2
		end
	end
	GlobalApi:parseAwardData({{'user','cash',cash}})
	paymentInfo.pay_list[tostring(id)] = (paymentInfo.pay_list[tostring(id)] or 0) + 1
	paymentInfo.money = (paymentInfo.money or 0) + conf.amount
	paymentInfo.day_money = (paymentInfo.day_money or 0) + conf.amount
	local vip_xp = UserData:getUserObj():getVipXp()
	vip_xp = vip_xp + conf.cash
	UserData:getUserObj():setVipXp(vip_xp)
	UserData:getUserObj():initPayment(paymentInfo)
	local vipConf = GameData:getConfData('vip')
	local oldVip = UserData:getUserObj():getVip()
	local vip = 0
	for k,v in pairs(vipConf) do
		if v.cash <= vip_xp then
			vip = tonumber(k)
		else
			break
		end
	end
	if (oldVip == tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')) - 1
		and vip == tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')))
		or (oldVip == tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict')) - 1
		and vip == tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict'))) then
		self.vipChanged = true
	end
	UserData:getUserObj().vip = vip or 0
	self:updateRecharge()
	UIManager:updateSidebar()
end

function RechargeMgr:updateRecharge()
	if self.uiClass['rechargeUI'] ~= nil then
		self.uiClass['rechargeUI']:updatePanel()
	end
end

function RechargeMgr:hideRecharge()
	if self.uiClass['rechargeUI'] ~= nil then
		self.uiClass['rechargeUI']:hideUI()
		self.uiClass['rechargeUI'] = nil
	end
end

function RechargeMgr:showFirstRecharge()
    
    if self.uiClass['firstRechargeUI'] == nil then
		local args = {}
		MessageMgr:sendPost('get_first_pay','activity',json.encode(args),function (response)		
			local code = response.code
			if code == 0 then
				local data = response.data
				self.uiClass['firstRechargeUI'] = ClassFirstRechargeUI.new(data)
		        self.uiClass['firstRechargeUI']:showUI()
			end
		end)
	end
end

function RechargeMgr:hideFirstRecharge(callback)
	if self.uiClass['firstRechargeUI'] ~= nil then
		self.uiClass['firstRechargeUI']:ActionClose(callback)
		self.uiClass['firstRechargeUI'] = nil
	end
end

function RechargeMgr:queryRecharge()
	if Third:Get():getSDKPlatform() ~= "dev" then
		local RechargeHelper = require("script/app/ui/recharge/rechargehelper_" .. Third:Get():getSDKPlatform())
		RechargeHelper:queryRecharge()
	end
end

function RechargeMgr:specialRecharge(index, callback)
	if Third:Get():getSDKPlatform() ~= "dev" then
		local rechargeConf = GameData:getConfData("recharge")
		local RechargeHelper = require("script/app/ui/recharge/rechargehelper_" .. Third:Get():getSDKPlatform())
		if RechargeHelper.specialRecharge then
			RechargeHelper:specialRecharge(index, rechargeConf[index], callback)
		else
			local obj = {
				code = -1
			}
			callback(obj)
		end
	end
end

function RechargeMgr:showRechargeWatting()
	if self.uiClass['rechargeWaittingUI'] == nil then
		self.uiClass['rechargeWaittingUI'] = ClassRechargeWaittingUI.new()
		self.uiClass['rechargeWaittingUI']:showUI()
	end
end


function RechargeMgr:hideRechargeWatting()
	if self.uiClass['rechargeWaittingUI'] ~= nil then
		self.uiClass['rechargeWaittingUI']:hideUI()
		self.uiClass['rechargeWaittingUI'] = nil
	end
end

return RechargeMgr