require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"

Profile = {}

local homuntypes = {}
local stGoToOwner = copyfunction(stFollowCMD)

local ftran = {}
ftran[stIdle] =
function (myid, ...)
  local actors = getActors(
    function (act_list, id)
      if isHom(id, unpack(homuntypes)) and id ~= myid then
        return {stFollowTarget, {myid, id}}
      end
    end)
    if not(actors[myid])  then
      return unpack(actors)
    end
    local owner = getOwner(myid, V_MOTION)
    if owner.motion == MOTION_MOVE then
      return stGoToOwner, {myid}
    end
    return nil, nil
end

ftran[stFollowTarget] =
function (myid, target)
  if isDead(target) then
    return stGoToOwner, {myid}
  end
  return nil, nil
end

ftran[stGoToOwner] =
function (myid)
  local owner = GetV(V_OWNER, myid)
  if getDistance2(myid, owner) <= 6  then
    return stIdle, {myid}
  end
  return nil, nil
end

Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid, ...)
  homuntypes = arg
  return ftran, stIdle, {myid} -- ftran, fun, farg
end

return Profile
