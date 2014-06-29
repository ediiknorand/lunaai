require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"

Profile = {}
-- custom states
stHolding = copyfunction(stIdle)

-- ftran
ftran={}

ftran[stMoveCMD] = function(myid, s_x, s_y)
  local x,y = GetV(V_POSITION, myid)
  if getDistance(x,y, s_x,s_y) <= 2 then
    return stHolding, {myid}
  end
end

ftran[stIdle] = function(myid)
  local owner = GetV(V_OWNER, myid)
  if getDistance2(myid, owner) >= 10 then
    return stHolding,{myid}
  end
  return stIdleFollow,{myid}
end

Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stFollowCMD}
}

Profile.init =
function (myid, ...)
  return ftran, stIdle, {myid} -- ftran, fun, farg
end

return Profile
