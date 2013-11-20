require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/atk.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"

Profile = {}
-- Private
local hunted = {}

-- Useful functions
function isAttackable(myid, mob_data) -- Depends on mob's target and homuntype
  return mob_data.target == myid or ((mob_data.target == 0 or mob_data.target == -1 or isMob(mob_data.target)) and hunted[mob_data.homuntype])
end

function nextTarget(myid, memory)
  for id, mem_data in pairs(memory) do
    if(isMob(id)) then
      return {stFollowTarget, {myid, id, memory}}
    end
  end
  return {stIdle, {myid}}
end

-- Transitions
local ftran = {}

ftran[stIdle] =
  function (myid)
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET, V_HOMUNTYPE, V_ATTACKRANGE, 
      function (act, id)
        if(id ~= myid and id ~= owner and isMob(id) and not isDead(id)) then
          if(act[id].target == myid or act[id].target == owner) then
	    return {stFollowTarget, {myid, id, {[owner] = act[id].target == owner}}}
	  end
	  act[id].dist = getDistance2(myid, id)
	  if(isAttackable(myid, act[id]) and (act.dist == nil or act.dist > act[id].dist)) then
	    act.dist = act[id].dist
	    act.id = id
	  end
        end
        return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    local id = actors.id
    if(id ~= nil and  getDistance2(owner, id) <= 12-actors[id].atkrange) then
      return stFollowTarget, {myid, id, {}}
    end
    if(GetV(V_MOTION, owner) == MOTION_MOVE or getDistance2(myid, owner) > 4) then
      return stIdleFollow, {myid}
    end
    return nil, nil
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
  function (myid, target, memory)
    local target_t = GetV(V_TARGET, target)
    local owner = GetV(V_OWNER, myid)
    if(isDead(target) or (target_t ~= myid and target_t ~= owner and not isMob(target_t) and target_t ~= 0 and target_t ~= -1)) then
      return unpack(nextTarget(myid, memory))
    end
    if(getDistance2(myid, target) <= 2) then
      SkillObject(myid, 3, 8004, myid)
      memory[owner] = false
      return stLifAttack, {myid, target, memory}
    end
    local actors = getActors(V_TARGET, V_HOMUNTYPE,
      function (act, id)
        if(isMob(id) and not isDead(id)) then
          if(id ~= target and act[id].target == owner) then
	    memory[owner] = true
	    return {stFollowTarget, {myid, id, memory}}
	  end
	  if(id ~= target and isAttackable(myid, act[id]) and getDistance2(myid, id) < getDistance2(myid, target) and not memory[owner]) then
	    return {stFollowTarget, {myid, id, memory}}
	  end
	elseif(not isDead(id) and act[id].target == target and id ~= owner and id ~= myid) then
	  return nextTarget(myid, memory)
	end
	return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    if(getDistance2(owner, target) > 14-GetV(V_ATTACKRANGE, target)) then
      return unpack(nextTarget(myid, memory))
    end
    return nil, nil
  end

ftran[stLifAttack] =
  function (myid, target, memory)
    if(isDead(target)) then
      memory[target] = nil
      return unpack(nextTarget(myid, memory))
    end
    local t_motion = GetV(V_MOTION, target) == MOTION_HIT
    if(memory[target] == nil) then
      memory[target] = 0
    elseif(t_motion) then
      memory[target] = memory[target] + 1
    end
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET, V_HOMUNTYPE, V_ATTACKRANGE,
      function (act, id)
        if(isMob(id) and not isDead(id)) then
	  if(id ~= target) then
	    if(act[id].target == owner) then
	      memory[owner] = true
	      return {stFollowTarget, {myid, id, memory}}
	    end
	    if(isAttackable(myid, act[id]) and getDistance2(myid, id) < 6 and getDistance2(owner, id) < 14-act[id].atkrange and memory[id] == nil and not memory[owner]) then
	      return {stFollowTarget, {myid, id, memory}}
	    end
	    if(t_motion and memory[id] ~= nil and (act.hits == nil or memory[id] < act.hits)) then
	      act.hits = memory[id]
	      act.id = id
	    end
	    if(isDead(id) and memory[id] ~= nil) then
	      memory[id] = nil
	    end
	  end
	else
	if(not isDead(id) and id ~= myid and id ~= owner and isMob(act[id].target) and memory[act[id].target] ~= nil) then
	    memory[act[id].target] = 0
	    return {stLifAttack, {myid, act[id].target, memory}}
	  end
	end
	return nil
      end)
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    if(actors.id ~= nil and actors.hits < memory[target]) then
      return stFollowTarget, {myid, actors.id, memory}
    end
    return nil, nil
  end

ftran[stAttackCMD] =
  function (myid, target)
    if(isDead(target)) then
      local x,y = GetV(V_POSITION, myid)
      return stMoveCMD, {myid, x, y}
    end
    return nil, nil
  end

-- Commands
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

-- Init
Profile.init =
function (myid, ...)
  for i,id in ipairs(arg) do
    hunted[id] = true
  end
  return ftran, stFollowCMD, {myid} -- ftran, fun, farg
end

return Profile
