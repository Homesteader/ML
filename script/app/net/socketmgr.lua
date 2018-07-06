cc.exports.SocketMgr = {
    socket = nil,
    jsonStr = nil,
    addTimes = 0,
    schedulerEntryId = 0
}

-- websocket
function SocketMgr:init(port)
    local host = GlobalData:getGameServerUrl()
    host = string.gsub(host, "https", "ws")
    local index = string.find(host, ":", 4)
    host = string.sub(host, 0, index)
    host = host .. port
    local createSocket = nil
    self.flag = false
    local function socketOpen()
        print("websocket was opened.")
        local obj = {
            uid = GlobalData:getSelectUid(),
            mod = "user",
            act = "handshake",
            args = {
                auth_key = GlobalData:getAnthKey(),
                auth_time = GlobalData:getAnthTime(),
                openid = GlobalData:getOpenId()
            }
        }
        self.socket:sendString(json.encode(obj))
    end

    local function socketMessage(jsonStr)
        print("==============socketMessage==============:" .. jsonStr)
        if jsonStr ~= "" then
            if self.jsonStr then
                jsonStr = self.jsonStr .. jsonStr
                self.jsonStr = jsonStr
                self.addTimes = self.addTimes + 1
            end
            local jsonObj = json.decode(jsonStr)
            if jsonObj then
                self.addTimes = 0
                self.jsonStr = nil
                if jsonObj.code == 0 then
                    local key = jsonObj.mod .. "_" .. jsonObj.act
                    jsonObj.data.act = jsonObj.act
                    jsonObj.data.mod = jsonObj.mod
                    CustomEventMgr:dispatchEvent(key, jsonObj.data)
                elseif jsonObj.code == 101 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES8'), COLOR_TYPE.RED)
                    return
                elseif jsonObj.code == 102 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_40'), COLOR_TYPE.RED)
                    return
                else
                    if jsonObj.code > 1 and jsonObj.code < 10 then
                        self.flag = true
                        if self.socket then
                            self.socket:close()
                        end
                        MessageMgr:parseCode(jsonObj.code)
                    end
                end
            elseif self.addTimes > 5 then
                self.flag = false
                if self.socket then
                    self.socket:close()
                end
            end
        end
    end

    local function socketClose()
        print("websocket closed")
        self.addTimes = 0
        self.jsonStr = nil
        if self.socket then
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_OPEN)
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_MESSAGE)
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_CLOSE)
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_ERROR)
            self.socket = nil
        end
        if not self.flag then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
            self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
                if self.schedulerEntryId > 0 then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                    self.schedulerEntryId = 0
                    createSocket()
                end
            end, 5, false)
        end
    end

    local function socketError()
        print("websocket Error")
    end

    createSocket = function ()
        local socket = cc.WebSocket:create(host)
        socket:registerScriptHandler(socketOpen, cc.WEBSOCKET_OPEN)
        socket:registerScriptHandler(socketMessage, cc.WEBSOCKET_MESSAGE)
        socket:registerScriptHandler(socketClose, cc.WEBSOCKET_CLOSE)
        socket:registerScriptHandler(socketError, cc.WEBSOCKET_ERROR)
        self.socket = socket
    end
    createSocket()
end

function SocketMgr:close()
    if self.schedulerEntryId > 0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
        self.schedulerEntryId = 0
    end
    self.flag = true
    if self.socket then
        self.socket:close()
    end
end

function SocketMgr:send(act, mod, args)
    if self.socket and cc.WEBSOCKET_STATE_OPEN == self.socket:getReadyState() then
        local obj = {
            uid = GlobalData:getSelectUid(),
            mod = mod,
            act = act,
            args = args
        }
        self.socket:sendString(json.encode(obj))
    end
end