require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"

Profile = {}
-- Private
local poi = 0

--  ftran
local ftran = {}

ftran[stIdle] =
  function (myid, target)
    if not target then
      target = poi
    end
    local actors = getActors()
    if not actors[target] then
      return nil, nil
    end
    return stFollowTarget, {myid, target}
  end

ftran[stFollowTarget] =
  function (myid, target)
    if not target then
      target = poi
    end
    local actors = getActors()
    if not actors[target] then
      return stIdle, {myid, target}
    end
    return nil, nil
  end

ftran[stAttackCMD] =
  function (myid, target)
    poi = target
    return stIdle, {myid, target}
  end

--  Commands
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid, target)
  poi = target
  return ftran, stIdle, {myid, target} -- ftran, fun, farg
end

return Profile
