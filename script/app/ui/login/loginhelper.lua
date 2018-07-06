local LoginHelper = {}

function LoginHelper:loginAccount()
	if Third:Get():getSDKPlatform() == "dev" then
		local createnameUi = require('script/app/ui/login/createname').new()
		createnameUi:showUI()
	elseif Third:Get():getSDKPlatform() == "gyyx" then
        LoginMgr:footprint('client_requestLoginSdk')
		Third:Get():login(json.encode(obj), function (jsonStr)
			local jsonObj = json.decode(jsonStr)
			if jsonObj and jsonObj.code and jsonObj.code == 0 then
                LoginMgr:footprint('client_LoginSdkSucceed')
				GlobalData:setLoginInfo(jsonObj.msg)
				MessageMgr:getServerList(function()
					local userId = string.split(GlobalData:getOpenId(), "_")[2]
					Third:Get():setUserId(userId)
					LoginMgr:afterGetServerList()
				end)
			else
				local scheduler = cc.Director:getInstance():getScheduler()
				local schedulerEntry
				schedulerEntry = scheduler:scheduleScriptFunc(function ()
					scheduler:unscheduleScriptEntry(schedulerEntry)
			        Third:Get():showLoginUI()
			    end, 0.1, false)
			end
		end)
		Third:Get():showLoginUI()
	elseif Third:Get():getSDKPlatform() == "ysdk" then
		local ysdkLoginType = Third:Get():getAutoLoginType()
		if ysdkLoginType == "" then
			local createnameUi = require('script/app/ui/login/loginui_ysdk').new()
			createnameUi:showUI()
		else
			local obj = {
				loginType = ysdkLoginType
			}
            LoginMgr:footprint('client_requestLoginSdk')
			Third:Get():login(json.encode(obj), function (jsonStr)
				local jsonObj = json.decode(jsonStr)
				if jsonObj and jsonObj.code and jsonObj.code == 0 then
                    LoginMgr:footprint('client_LoginSdkSucceed')
					GlobalData:setLoginInfo(jsonObj.msg)
					MessageMgr:getServerList(function()
						LoginMgr:afterGetServerList()
					end)
				else
					local createnameUi = require('script/app/ui/login/loginui_ysdk').new()
					createnameUi:showUI()
				end
			end)
		end
	end
end

return LoginHelper