local ClassSettingChangeNameUI = require("script/app/ui/setting/settingchangenameui")

local GuideChangeNameUI = class("GuideChangeNameUI", ClassSettingChangeNameUI)

function GuideChangeNameUI:guideSpecialHandle()
	local bg1 = self.root:getChildByName("bg1")
	bg1:setTouchEnabled(false)
end

function GuideChangeNameUI:onChangeNameSuccess(name)
	if Third:Get():needPostUserLevelUpGameLogBySDK() then
		local roleName = name
		if roleName == "" then
			roleName = tostring(UserData:getUserObj():getUid())
		end
		local obj = {
			roleId = tostring(UserData:getUserObj():getUid()),
			roleName = roleName,
			roleLevel = tostring(UserData:getUserObj():getLv()),
			serverId = tostring(GlobalData:getSelectSeverUid()),
			serverName = tostring(GlobalData:getSelectSeverName()),
			roleCTime = tostring(UserData:getUserObj():getCreateTime()),
			roleLevelMTime = tostring(UserData:getUserObj():getCreateTime())
		}
		Third:Get():postUserLevelUpGameLogBySDK(json.encode(obj))
	end
	UserData:getUserObj():setName(name)
	self:hideUI()
	GuideMgr:finishCurrGuide()
end

return GuideChangeNameUI