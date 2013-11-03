AI_PATH="./AI/USER_AI/"
me = require(AI_PATH.."state.lua")

function AI(myid)
  if(not me.loadedProfile()) then
    me.loadProfile(AI_PATH.."profiles/default.lua", myid)
  end
  me.run()
end
