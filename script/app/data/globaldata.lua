local platform = "pc"
local targetPlatform = CCApplication:getInstance():getTargetPlatform()
if targetPlatform == kTargetAndroid then
    platform = "android"
elseif targetPlatform == kTargetIphone or targetPlatform == kTargetIpad then
    platform = "ios"
end

cc.exports.GlobalData = {
	openkey = '' ,
	openId = 0 ,
	cdkey = '' , --cdkey兑换url
	serverlisttab = {} , --服务器列表
	selectUid = 0 , --选择服务器角色对应的uid
	selectSeverId = 0 , --选择的服务器id
    serverId = 0,   --真实的服务器id
	selectSeverName = "", --选择的服务器名称
	authTime = 0 , --上次收到服务器短消息回执时间
	differenceTime = 0, -- 服务器和本地时间的差值
	authKey = '' , --用户密钥
	isWhite = false ,--是否是白名单
	content = '' , --公告内容
	gatewayurl = 'http://172.31.244.2/login2.php', --游戏逻辑地址
	gameServerUrl = '',
	versiondata = '0', --版本信息
	updateurl = "",	--动态更新服务器
	localServerSelID = 0,
	loginInfo = "", -- 平台登录信息
	downloadUrl = "", -- 需要更新的客户端地址
	timeZoneOffset = 0 -- 默认时区差为0
}

function GlobalData:init()
	self.openkey = ''
	self.openId = 0
	self.cdkey = ''
	self.serverlisttab = {}
	self.selectUid = 0
	self.selectSeverId = 0
    self.serverId = 0
	self.selectSeverName = ""
	self.authTime = 0
	self.authKey = ''
	self.isWhite = false
	self.content = ''
	self.gatewayurl = 'http://172.31.244.2/login2.php'
	self.gameServerUrl = ''
	self.versiondata = '0'
end

function GlobalData:setOpenKeyAndOpenId( key ,id ,time)
	self.openkey = key
	self.openId = id
	self.openTime = time
end

function GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	return self.openkey ,self.openId , self.openTime
end

function GlobalData:getOpenId()
	return self.openId
end

function GlobalData:setCdkeyUrl( url )
	self.cdkey = url
end

function GlobalData:getCdKeyUrl()
	return self.cdkey
end

function GlobalData:setLocalServerSelectID(id)
	self.localServerSelID = id
end
function GlobalData:setSelectUid(uid)
	self.selectUid = uid
end

function GlobalData:getSelectUid()
	return self.selectUid
end

function GlobalData:setAuthTime( time )
	self.authTime = time
end

function GlobalData:getAnthTime( )
	return self.authTime
end

function GlobalData:setServerTime(time)
	self.differenceTime = time - os.time()
end

function GlobalData:getServerTime(delaytime)
	local time = delaytime or 0
	return os.time() + self.differenceTime - time
end

function GlobalData:setTimeZoneOffset(timeZone)
	local localTime = os.time({year = 1970,month = 1,day = 2,hour = 0})
	--该值是本地真实时区
	local localTimeZone = (24*3600 - localTime)/3600

    -- 是否是夏令时
    if os.date("*t",os.time()).isdst then
        localTimeZone = localTimeZone + 1
    end

    self.timeZoneOffset = timeZone - localTimeZone
end

function GlobalData:getTimeZoneOffset()
	return self.timeZoneOffset or 0
end

function GlobalData:setAuthKey( key )
	self.authKey = key
end

function GlobalData:getAnthKey( )
	return self.authKey
end

function GlobalData:setIswhite( iswhite )
	self.isWhite = iswhite
end

function GlobalData:getIsWhite( )
	return self.isWhite
end

function GlobalData:setSelectSeverUid( serverid )
	self.selectSeverId = serverid
end

function GlobalData:getSelectSeverUid( )
	return self.selectSeverId
end

function GlobalData:setServerId(serverId)
    self.serverId = serverId
end

function GlobalData:getServerId()
    return self.serverId
end

function GlobalData:setSelectSeverName( serverName )
	self.selectSeverName = serverName
end

function GlobalData:getSelectSeverName()
	return self.selectSeverName
end

function GlobalData:setContent( cont )
	self.content =cont
end

function GlobalData:getContent()
	return self.content
end

function GlobalData:setServerTab( servertab )
	for i,v in pairs(servertab) do
		self.serverlisttab[#self.serverlisttab + 1] = v
	end
	-- self.serverlisttab = servertab
	-- for i,v in ipairs(self.serverlisttab) do
	-- 	print(i,v)
	-- end
end

function GlobalData:getServerTab()
	return self.serverlisttab
end

function GlobalData:getServerInfoById(id)
	local tab
	for i,v in ipairs(self.serverlisttab) do
		if tonumber(v.id) == id then
			tab = v
		end
	end
	return tab
end

function GlobalData:setGameServerUrl( url )
	self.gameServerUrl = url
end

function GlobalData:getGameServerUrl()
	return self.gameServerUrl
end

function GlobalData:setGateWayUrl( url )
	self.gatewayurl = url
end

function GlobalData:getGateWayUrl()
	return self.gatewayurl
end


function GlobalData:setUpdateUrl( url )
	self.updateurl = url
end


function GlobalData:getUpdateUrl()
	return self.updateurl
end

function GlobalData:setVersionData( version)
	self.versiondata = version
end

function GlobalData:getVersionData()
	return self.versiondata
end

function GlobalData:getUpdateUrlReal()
	local serverList = GameData:getConfData("local/serverlistplatform")
	return self.updateurl .. '/' .. serverList[self.localServerSelID].ResourceServerName .. '/' .. self.versiondata .. '/' .. platform .. '/'
end

function GlobalData:setLoginInfo(v)
	self.loginInfo = v
end

function GlobalData:getLoginInfo()
	return self.loginInfo
end

function GlobalData:setDownloadUrl(url)
	self.downloadUrl = url
end

function GlobalData:getDownloadUrl()
	return self.downloadUrl
end