require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/atk.lua"

Profile = {}
-- new states
function stPokLifAtk(myid, target)
  stLifAttack(myid, target)
  local homtype = GetV(V_HOMUNTYPE, target)
  if(isHom(target, LIF, LIF2, LIF_H, LIF_H2) and GetV(V_MOTION, target) == MOTION_SKILL) then
    SkillObject(myid, 5, 8002, myid)
  end
end

-- ftran
local ftran = {}
ftran[stIdle] =
  function (myid)
    local owner = GetV(V_OWNER, myid)
    local actors = getActors(V_TARGET, V_HOMUNTYPE,
        function (act, id)
	  if(act[id].target == myid or act[id].target == owner) then
	    SkillObject(myid, 3, 8004, myid)
	    return {stPokLifAtk, {myid, id}}
	  end
	  act[id].dist = getDistance2(myid, id)
          if((isHom(id) and id ~= myid) and (act.dist == nil or act[id].dist < act.dist) and act[id].dist < 6) then
	    act.dist = act[id].dist
	    act.id = id
	  end
	  return nil
	end
      )
    if(actors[myid] == nil) then
      return unpack(actors)
    end
    if(actors.id ~= nil) then
      SkillObject(myid, 3, 8004, myid)
      return stPokLifAtk, {myid, actors.id}
    end
    local motion = GetV(V_MOTION, owner)
    if(motion == MOTION_MOVE) then
      return stIdleFollow, {myid}
    end
    return nil, nil
  end

ftran[stIdleFollow] =
  function (myid)
    local owner = GetV(V_OWNER, myid)
    local motion = GetV(V_MOTION, owner)
    if(motion ~= MOTION_MOVE) then
      return stIdle, {myid}
    end
    return nil, nil
  end

ftran[stPokLifAtk] =
  function (myid, target)
    if(isDead(target)) then
      return stFollowCMD, {myid}
    end
    return nil, nil
  end

ftran[stFollowCMD] = nil
ftran[stMoveCMD] = nil

-- ...
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stPokLifAtk,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid, ...)
  return ftran, stFollowCMD, {myid} -- ftran, fun, farg
end

return Profile
