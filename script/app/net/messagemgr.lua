cc.exports.MessageMgr = {
	fuckServerForceToAddThisMsg = "",
	messageSequence = 0
}

local serverListId = Third:Get():getServerListId()

local COMPRESS_TYPE = "deflate"
if CCApplication:getInstance():getTargetPlatform() == kTargetWindows then
	COMPRESS_TYPE = ""
end

function MessageMgr:decodeURI(s)
	s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
	return s
end

function MessageMgr:encodeURI(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end

local function formatGetServerListUrl()
	local serverList = GameData:getConfData("local/serverlistplatform")
	local url = ""
	url = url ..serverList[serverListId].ServerUrl
	url = url .. "?" .. GlobalData:getLoginInfo()
	url = url .. "&platform=" .. Third:Get():getSDKPlatform()
	url = url .. Third:Get():getSDKRequestArgs()
	return url
end

function MessageMgr:requsetGet(url, callback, ignoreResp)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	xhr:registerScriptHandler(function()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local jsonObj = json.decode(xhr.response)
			if self:parseJsonBeforeResponse(jsonObj) then
				callback(jsonObj)
			end
		else
            if ignoreResp == nil then
			    promptmgr:showMessageBox(GlobalApi:getLocalStr("NETWORL_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				    self:requsetGet(url, callback)
			    end)
            end
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)
	xhr:send()
end

function MessageMgr:getServerList(callback)
	local url = formatGetServerListUrl()
    LoginMgr:footprint('client_requestLoginPhp')
	self:requsetGet(url, function(jsonObj)
		if jsonObj.code == 0 then
        LoginMgr:footprint('client_loginPhpSucceed')
			self:afterGetServerList(jsonObj, callback)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("GET_SERVER_LIST_FAILED"), MESSAGE_BOX_TYPE.MB_OK, function ()
				self:getServerList(callback)
			end)
		end
	end)
end

function MessageMgr:afterGetServerList(jsonObj, callback)
	GlobalData:init()
	GlobalData:setCdkeyUrl(jsonObj['cdkey'])
	GlobalData:setOpenKeyAndOpenId(jsonObj['openkey'],jsonObj['openid'],jsonObj['opentime'])
	GlobalData:setIswhite(jsonObj['white'])
	GlobalData:setServerTab(jsonObj['server_list'])
	GlobalData:setVersionData(jsonObj['version'])
	GlobalData:setUpdateUrl(jsonObj['update_url'])
	GlobalData:setContent(jsonObj['bulletin'])
	GlobalData:setLocalServerSelectID(serverListId)
	GlobalData:setDownloadUrl(jsonObj['download'])
	if callback then
		callback()
	end
end

function MessageMgr:sendPost( act, mod, argsJson, response )
	local otherStr
	if GuideMgr:isRunning() and GuideMgr.saveWithMsg then
		local guidestep = GuideMgr:getSaveStep()
		otherStr = "&guide=" .. guidestep
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Accept-Encoding", COMPRESS_TYPE)
	xhr:open("POST", GlobalData:getGameServerUrl())
	xhr:registerScriptHandler(function()
		print(xhr.response)
		if xhr.response then
			self.fuckServerForceToAddThisMsg = self.fuckServerForceToAddThisMsg .. "\nresponse = " .. xhr.response
		end
		promptmgr:hideConnectWaiting()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local jsonObj = json.decode(xhr.response)
			if self:parseJsonBeforeResponse(jsonObj) then
                if jsonObj.data.tips and UserData and UserData:getUserObj() then
                    UserData:getUserObj():setTipsInfo(jsonObj.data.tips)
                end
				response(jsonObj)
				if GuideMgr:isRunning() and jsonObj.code == 0 then
					if GuideMgr.saveWithMsg and otherStr then
						GuideMgr:completeSave()
					end
					CustomEventMgr:dispatchEvent(CUSTOM_EVENT.MSG_RESPONSE)
				end
			end
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("NETWORL_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				self.messageSequence = self.messageSequence - 1
				self:sendPost(act, mod, argsJson, response)
			end)
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)

	local uid = GlobalData:getSelectUid()
	local openkey,openid,opentime = GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	local authkey = GlobalData:getAnthKey()
	local authtime = GlobalData:getAnthTime()
	local currTime = GlobalData:getServerTime()
	local sigT = self:getSigTime(currTime, self.messageSequence)
	local v = 	'uid=' .. uid .. 
				'&openid=' .. openid .. 
				'&act=' .. act .. 
				'&mod=' .. mod .. 
				'&auth_key=' .. authkey .. 
				'&args=' .. argsJson .. 
				'&auth_time=' .. authtime ..
				'&seq=' .. self.messageSequence .. 
				'&stime=' .. currTime ..
				'&sig=' .. sigT
	if otherStr then
		v = v .. otherStr
	end
	print(v)
	self.fuckServerForceToAddThisMsg = "request = " .. v
	self.messageSequence = self.messageSequence + 1
	xhr:send(v)
	promptmgr:showConnectWaiting()
end

function MessageMgr:sendPostByRecharge( act, mod, argsJson, response )
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Accept-Encoding", COMPRESS_TYPE)
	xhr:open("POST", GlobalData:getGameServerUrl())
	xhr:registerScriptHandler(function()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local jsonObj = json.decode(xhr.response)
			response(jsonObj)
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)

	local uid = GlobalData:getSelectUid()
	local openkey,openid,opentime = GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	local authkey = GlobalData:getAnthKey()
	local authtime = GlobalData:getAnthTime()
	local currTime = GlobalData:getServerTime()
	local sigT = self:getSigTime(currTime, 0)
	local v = 	'uid=' .. uid .. 
				'&openid=' .. openid .. 
				'&act=' .. act .. 
				'&mod=' .. mod .. 
				'&auth_key=' .. authkey .. 
				'&args=' .. argsJson .. 
				'&auth_time=' .. authtime ..
				'&seq=0' .. 
				'&stime=' .. currTime ..
				'&sig=' .. sigT
	xhr:send(v)
end

function MessageMgr:parseJsonBeforeResponse(jsonObj)
	if jsonObj.serverTime then
		GlobalData:setServerTime(jsonObj.serverTime)
	end
	return self:parseCode(jsonObj.code)
end

function MessageMgr:parseCode(code)
	local function restart()
		UIManager:backToLogin()
	end
	if code == 2 or code == 5 then
		promptmgr:showMessageBox(GlobalApi:getLocalStr("SERVER_RESTART"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 3 then
		promptmgr:showMessageBox(GlobalApi:getLocalStr("REPEAT_LOGIN"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 4 then
		promptmgr:showMessageBox(GlobalApi:getLocalStr("NI_BEI_TI_LE"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 6 then
		promptmgr:showMessageBox(GlobalApi:getLocalStr("SERVER_BUSY"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 8 then
		promptmgr:showMessageBox(GlobalApi:getLocalStr("LOGIN_OVER_TIME"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 9 then
		promptmgr:showMessageBox(GlobalApi:getLocalStr("KICK_BECAUSE_CHEAT_2"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	end
	return true
end

function MessageMgr:getSigTime(t, seq)
	local tStr = tostring(t)
	local f = tonumber(string.sub(tStr, 1, 5))
	local s = tonumber(string.sub(tStr, 6, 10))
	return xx.Utils:Get():generateMD5((s*f + t)%s + seq)
end

return MessageMgr