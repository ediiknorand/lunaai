require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/idle.lua"

Profile = {}

-- private
local outfile

-- functions
local where = dofile("./AI/USER_AI/rsc/where.lua")

-- custom states

-- ftran
ftran = {}

ftran[stIdle] = function(myid)
   local out = io.open(outfile, "w")
   if not out then
     return stIdleFollow, {myid}
   end
   local mapname = where()
   if mapname then
     out:write("I think we are in "..mapname.."\n")
   else
     out:write("I don't know where we are...\n")
   end
   out:flush()
   out:close()
   return stIdleFollow, {myid}
end
-- commands and init
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid, filename)
  outfile = getSavePath(myid).."/"..filename
  return ftran, stIdleFollow, {myid}  -- ftran, fun, farg
end

return Profile
