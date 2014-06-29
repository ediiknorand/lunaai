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
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET,
      function (act, id)
        if(isMob(id) and (act[id].target == myid or act[id].target == owner)) then
	  return {stFollowTarget, {myid, id}}
	end
	return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
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
    if(isDead(target)) then
      return stIdle, {myid}
    end
    if(getDistance2(myid, target) <= 2) then
      return stAttackCMD, {myid, target}
    end
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET,
      function (act, id)
        if(id ~= myid and id ~= owner and act[id].target == target) then
	  return {stIdle, {myid}}
	end
	if(id ~= target and act[id].target == owner) then
	  return {stFollowTarget, {myid, id}}
	end
	return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    return nil, nil
  end

ftran[stAttackCMD] =
  function (myid, target)
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET,
      function (act, id)
        if(not isMob(id)) then
	  if(id ~= myid and id ~= owner and act[id].target == target) then
	    return {stKSed, {myid, target, id}}
	  end
	else
	  if(id ~= target and (isDead(target) and act[id].target == myid) or (act[id].target == owner)) then
	    return {stFollowTarget, {myid, id}}
	  end
	  if(id ~= target and act[id].target == myid and isHitted(target)) then
	    return {stAttackStack, {myid, id, {[target]=true}}}
	  end
	end
	return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    if(isDead(target)) then
      return stIdle, {myid}
    end
    return nil, nil
  end

ftran[stAttackStack] =
  function (myid, target, stack)
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET,
      function (act,id)
        if(not isMob(id)) then
	  if(id ~= myid and id ~= owner and stack[act[id].target]) then
	    return {stKSed, {myid, act[id].target, id}}
	  end
	else
	  if(id ~= target and (isDead(target) and act[id].target == myid) or (act[id].target == owner)) then
	    return {stFollowTarget, {myid, id}}
	  end
	  if(id ~= target and act[id].target == myid and isHitted(target) and stack[id] == nil) then
	    stack[id] = true
	    return {stAttackStack, {myid, id, stack}}
	  end
	end
	return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    if(isDead(target)) then
      local at = next(stack)
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
