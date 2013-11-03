require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"

Profile = {}
-- Custom States
local function stAttackStack(myid, target, stack)
  stAttackCMD(myid, target)
end

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
      if(isMob(a) and (at == myid or at == owner)) then
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
    for i,a in ipairs(actors) do
      at = GetV(V_TARGET, a)
      if(not isMob(a)) then
        if(a ~= myid and a ~= owner and at == target) then
          return stKSed, {myid, target, a}
        end
      else
        if((a ~= target) and ((isDead(target) and at == myid) or (at == owner))) then
          return stFollowTarget, {myid, a}
        end
        if(a ~= target and at == myid and isHitted(target)) then
          return stAttackStack, {myid, a, {[target]=true}}
        end
      end
    end
    if(isDead(target)) then
      return stIdle, {myid}
    end
    return nil, nil
  end

ftran[stAttackStack] =
  function (myid, target, stack)
    local actors = GetActors()
    local owner = GetV(V_OWNER, myid)
    local at
    for i,a in ipairs(actors) do
      at = GetV(V_TARGET, a)
      if(not isMob(a)) then
        if(a ~= myid and a ~= owner and stack[at] == true) then
          return stKSed, {myid, at, a}
        end
      else
        if((a ~= target) and ((isDead(target) and at == myid) or (at == owner))) then
          return stFollowTarget, {myid, a}
        end
        if(a ~= target and at == myid and isHitted(target) and stack[a] == nil) then
          stack[a] = true
          return stAttackStack, {myid, a, stack}
        end
      end
    end
    if(isDead(target)) then
      at = next(stack)
      if(at ~= nil) then
        return stAttackCMD, {myid, at}
      else
        return stIdle, {myid}
      end
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
