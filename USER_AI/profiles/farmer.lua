require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"

Profile = {}
-- Custom States
local function stKSed(myid, target, kser)
  stAttackCMD(myid, target)
end

-- Transitions table
local ftran = {}
ftran[stIdle] =
  function (myid)
    local actors = GetActors()
    local at
    local owner = GetV(V_OWNER, myid)
    for id,a in ipairs(actors) do
      at = GetV(V_TARGET, a)
      if(at == myid or at == owner) then
        return stFollowTarget, {myid, a}
      end
    end
    if(GetV(V_MOTION, owner) == MOTION_MOVE) then
      return stIdleFollow, {myid}
    end
    return nil,nil
  end

ftran[stIdleFollow] =
  function (myid)
    local owner = GetV(V_OWNER, myid)
    if(GetV(V_MOTION, owner) ~= MOTION_MOVE) then
      return stIdle, {myid}
    end
    return nil, nil
  end

ftran[stFollowTarget] =
  function (myid, target)
    if(getDistance2(myid, target) <= 2) then
      return stAttackCMD, {myid, target}
    end
    local actors = GetActors()
    local at
    local owner = GetV(V_OWNER, myid)
    for id, a in ipairs(actors) do
      at = GetV(V_TARGET, a)
      if(isDead(target) or (a~=myid and a~=owner and at==target)) then
        return stIdle, {myid}
      end
      if(at==owner) then
        return stFollowTarget, {myid, a}
      end
    end
    return nil, nil
  end

ftran[stAttackCMD] =
  function (myid, target)
    local actors = GetActors()
    local owner = GetV(V_OWNER, myid)
    local at
    for id,a in ipairs(actors) do
      at = GetV(V_TARGET, a)
      if((a ~= target) and ((isDead(target) and at == myid) or (at == owner))) then
        return stFollowTarget, {myid, a}
      end
      if(a ~= myid and a ~= owner and at == target) then
        return stKSed, {myid, target, a}
      end
    end
    if(isDead(target)) then
      return stIdle, {myid}
    end
    return nil, nil
  end

ftran[stKSed] =
  function (myid, target, kser)
    return ftran[stAttackCMD](myid, target)
  end

ftran[stStrictFollow] = nil
ftran[stMoveCMD] = nil

-- Commands
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stStrictFollow, unfollow = stIdle}
}

-- Init
Profile.init =
  function (myid)
    return ftran, stStrictFollow, {myid}
  end

return Profile
