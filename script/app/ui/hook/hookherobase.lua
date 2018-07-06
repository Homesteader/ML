local hookherobase = class("hookherobase")

function hookherobase:ctor(heroId)

	self.baseinfo = heroId
end

--寻敌
function hookherobase:searchTarget()
end

function hookherobase:fight()
end

return hookherobase