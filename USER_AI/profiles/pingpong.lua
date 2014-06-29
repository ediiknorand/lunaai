require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"

Profile = {}
-- Private
local poi = 0
local poii = 0

--  ftran
local ftran = {}

ftran[stIdle] =
  function (myid, dst, src)
    if not dst then
      dst = poi
    end
    if not src then
      src = poii
    end
    local actors = getActors()
    if not (actors[dst] or actors[src]) then
      return nil, nil
    end
    return stFollowTarget, {myid, dst, src}
  end

ftran[stFollowTarget] =
  function (myid, dst, src)
    local actors = getActors()
    if not (actors[dst] or actors[src]) then
      return stIdle, {myid, dst, src}
    end
    if getDistance2(dst, myid) <= 2 then
      return stFollowTarget, {myid, src, dst}
    end
    return nil, nil
  end

ftran[stAttackCMD] =
  function (myid, target)
    poi = target
    local owner = getOwner(myid)
    return stIdle, {myid, target, owner.id}
  end

--  Commands
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid, dst, src)
  poi = dst
  if not src then
    local owner = getOwner(myid)
    src = owner.id
  end
  poii = src
  return ftran, stIdle, {myid, dst, src} -- ftran, fun, farg
end

return Profile
