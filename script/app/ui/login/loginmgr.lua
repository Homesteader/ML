local ClassLoginUI = require("script/app/ui/login/loginui")
local LoginHelper = require('script/app/ui/login/loginhelper')
cc.exports.LoginMgr = {
	uiClass = {
		loginUI = nil
	},
	animationMap= {}
}

setmetatable(LoginMgr.uiClass, {__mode = "v"})

function LoginMgr:showLogin()
    YVSdkMgr:cpLogout()
	if self.uiClass.loginUI == nil then
		self.uiClass.loginUI = ClassLoginUI.new()
		self.uiClass.loginUI:showUI()
	end
end

function LoginMgr:hideLogin()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:hideUI()
		self.uiClass.loginUI = nil
	end
end

function LoginMgr:setLoginServerName()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:setServerName()
	end
end

function LoginMgr:showCreateName()
	LoginHelper:loginAccount()
end

function LoginMgr:loginUpdateChildren()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:updateChild()
	end
end

function LoginMgr:getNewServer(serverlistTab)
	local serverTab
	local nowId = 1
	local statusTab = {}
	for k,v in pairs(serverlistTab) do
		if v.status == 3 then
			table.insert(statusTab,v)
		end
		if tonumber(v.id) > nowId then
			nowId = tonumber(v.id)
			serverTab = v
		end
	end
	if #statusTab > 0 then
		serverTab = statusTab[math.random(1,#statusTab)]
	end
	return serverTab or serverlistTab[1]
end

function LoginMgr:afterGetServerList()
	local serverId = cc.UserDefault:getInstance():getIntegerForKey('serverID_1',-1)
	local serverlistTab = GlobalData:getServerTab()
	local url
	local serverName
	local serverID
	local userId
	local tab = GlobalData:getServerInfoById(serverId)
	--printall(serverlistTab)
	if not tab or serverId < 1 then
		local tab1 = self:getNewServer(serverlistTab)
		url = tab1.host
		serverName = tab1.name
		serverID = tab1.id
		userId = tab1.uid
		cc.UserDefault:getInstance():setIntegerForKey('serverID_1',serverID)
	else
		url = tab.host
		serverName = tab.name
		userId = tab.uid
		serverID = serverId
	end
	GlobalData:setSelectSeverUid(serverID)
	GlobalData:setSelectSeverName(serverName)
	GlobalData:setGateWayUrl(url)
	GlobalData:setSelectUid(userId)
	self:checkUpdate()
end

function LoginMgr:StartEnteringGame(callback)
	local getGateWayUrl = GlobalData:getGateWayUrl()
	local openKey,openId,openTime = GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	local userId = GlobalData:getSelectUid()
	local url = getGateWayUrl..'?openkey='..openKey..'&act=login&openid='..openId..'&uid='..(userId or '')..'&opentime='..openTime
	print(url)
    LoginMgr:footprint('client_requestLoginGateway')
	MessageMgr:requsetGet(url, function(response)
		if response.code == 0 then
            LoginMgr:footprint('client_loginGatewaySucceed')
			local data = response.data
		    GlobalData:setAuthTime(data.auth_time)
		    GlobalData:setServerTime(data.auth_time)
		    GlobalData:setAuthKey(data.auth_key)
		    GlobalData:setGameServerUrl(data.game_server)
		    GlobalData:setSelectUid(data.uid)
            GlobalData:setServerId(data.serverId)
		    local timezone = data.timezone or 8
    		GlobalData:setTimeZoneOffset(timezone)
    		
			if callback then
				callback(2)
			end
			self:OnResponse(callback)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("GET_UID_FAILED"), MESSAGE_BOX_TYPE.MB_OK, function ()
				self:StartEnteringGame(callback)
			end)
		end
	end)
end

function LoginMgr:OnResponse(callback)
    local args = {
	    name = GlobalData:getOpenId(),
	    platform = Third:Get():getSDKPlatform(),
	    device_info = Third:Get():getSDKRequestJson()
	}
    LoginMgr:footprint('client_requestLoginGame')
	MessageMgr:sendPost('login','user',json.encode(args),function (jsonObj)
		if jsonObj.code == 0 then
            LoginMgr:footprint('client_loginGameSucceed')
			if callback then
				callback(3)
			end
			self:OnLoginResponse(jsonObj,callback)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr('LOGIN_ERROR_MESSAGE_' .. jsonObj.code), MESSAGE_BOX_TYPE.MB_OK, function ()
				self:OnResponse(callback)
			end)
		end
	end)
end

function LoginMgr:OnLoginResponse(resTab,callback)
	UserData:initWithData(resTab)
    YVSdkMgr:init()
    -- cp登陆
    YVSdkMgr:cpLogin(UserData:getUserObj().uid,UserData:getUserObj().uid)
    UIManager:getSidebar():setActivityBtnsPosition()
    ChatNewMgr:GetLog()
    MainSceneMgr:GetLog()
    FriendsMgr:GetLog()
	SocketMgr:init(resTab.data.wssPort)
    TerritorialWarMgr:init()
	SettingMgr:init()
    --TerritorialWarMgr:registerSynMsg()
	RechargeMgr:queryRecharge()
	local loginTimes = UserData:getUserObj():getMark().logins
	if loginTimes <= 1 then
		Third:Get():setFirstLogin(true)
	else
		Third:Get():setFirstLogin(false)
	end
	if Third:Get():needPostEnterGameLogBySDK() then
		local roleName = tostring(UserData:getUserObj():getName())
		local roleId = tostring(UserData:getUserObj():getUid())
		if roleName == "" then
			roleName = roleId
		end
		local roleInfoObj = {
			roleId = roleId,
			roleName = roleName,
			roleLevel = tostring(UserData:getUserObj():getLv()),
			serverId = tostring(GlobalData:getSelectSeverUid()),
			serverName = tostring(GlobalData:getSelectSeverName())
		}
		Third:Get():postEnterGameLogBySDK(json.encode(roleInfoObj))
	end

	if callback then
		callback(4)
	end
	self:preloadHookHero(callback)
	-- PlayerCore::markLoginDateDigital();
	-- CPathData::GetInst()->Init();
	-- CLoginMgr::GetInst()->hideLoginPanel();
	-- CLDObjectManager* pObjectMgr = CLDObjectManager::GetInst();
	-- pObjectMgr->ClearAllObject();
	-- CUserdata::GetInst()->ReLoadClearData();
	-- InitObject();
	-- pObjectMgr->CreateLDObject(MYSELF_ID, OBJECT_TYPE_SELF);
	-- CNewsMgr::GetInst()->StartRequest();
	-- CUserdata::GetInst()->ParseJsonUserData( pJsonDic );
	-- CUserdata::GetInst()->m_dwServerTime = pJsonDic->getItemIntValue( "serverTime", 0 );
 	-- CCopySceneMgr::getInst()->saveChapterID(-1);
 	-- self:hideLogin()
end

function LoginMgr:preloadHookHero(callback)

	self.animationMap = {}
    local hookHeroMap = RoleData:getRoleMap()
    for i=1,#hookHeroMap do
    	local roleObj  = RoleData:getRoleByPos(i)
    	if roleObj and roleObj:getId() > 0 then
    		local heroid = roleObj:getId()
    		local _,heroCombatInfo,heroModelConf = GlobalApi:getHeroConf(heroid)
    		local heroUrl = "animation/" .. heroModelConf.modelUrl .. "/" .. heroModelConf.modelUrl
			if self.animationMap[heroUrl] == nil then
				if string.sub(heroModelConf.modelUrl, 1, 4) == "nan_" then
					self.animationMap[heroUrl] = "animation/nan/nan"
				else
					self.animationMap[heroUrl] = 0
				end
			end
    	end
    end

    local countPerFrame = #self.animationMap
    local loadedCount = 0
    local co = coroutine.create(function ()
		for k, v in pairs(self.animationMap) do
			if v == 0 then
				hookheromgr:loadAnimationRes(k, k,1)
			else
				hookheromgr:loadAnimationRes(v, k,1)
			end
			loadedCount = loadedCount + 1
			if loadedCount == countPerFrame then
				coroutine.yield()
			end
		end
	end)
	if callback then
		callback(countPerFrame)
	end
    coroutine.resume(co)
end

function LoginMgr:checkUpdate()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:checkUpdate()
	end
end

--锚点
function LoginMgr:footprint(footprintType)
    local platform = Third:Get():getSDKPlatform()
    if platform == 'dev' then
        return
    end

	local openId = GlobalData:getOpenId()
	local userId = GlobalData:getSelectUid()
    
	local url = 'http://120.92.3.203/msanguo/footprint.php?openid=' .. openId .. '&uid=' .. (userId or '') .. '&platform=' .. platform .. Third:Get():getSDKRequestArgs() .. '&type=' .. footprintType
	print(url)
	MessageMgr:requsetGet(url, function(response)

	end, true)
end