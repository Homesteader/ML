cc.exports.GameData = {
	data = {}
}

function GameData:purge()
	local filepath
	for filename, v in pairs(self.data) do
		filepath = "data/" .. filename
		if package.loaded[filepath] then
			package.loaded[filepath] = nil
		end
	end
	self.data = {}
end

function GameData:purgeActivity()
	if self.data then
		if UserData and UserData:getUserObj() then
		 	local activityNames = UserData:getUserObj().activity_value_key
		 	if activityNames then
				for filenNme, v in pairs(activityNames) do
					if self.data[filenNme] then
						self.data[filenNme] = nil
					end
				end
			end
		end
	end
end

function GameData:getConfData(filename)
	if filename == "activities" and UserData and UserData:getUserObj() then
		local values = UserData:getUserObj().avconf
        if values then
            return values
        end
	end
	if not self.data[filename] then
		local filepath = "data/" .. filename
		if package.loaded[filepath] then
			package.loaded[filepath] = nil
		end
        if UserData and UserData:getUserObj() and UserData:getUserObj().activity_value_key and UserData:getUserObj().activity_value_key[filename] then
            local values = require(filepath)
            local activity = UserData:getUserObj().avconf
            local key = UserData:getUserObj().activity_value_key[filename].key
            local stage = tonumber(activity[key].stage)
            local temp = {}
            for k,v in ipairs(values[stage]) do
                if type(v) ~= "string" then
                    temp[k] = v
                end
            end
            self.data[filename] = temp
        else
            self.data[filename] = require(filepath)
        end
	end
	return self.data[filename]
end