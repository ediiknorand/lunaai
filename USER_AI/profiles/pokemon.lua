require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/idle.lua"

-- Profile for a "pokemon"-type event

Profile = {}

local ftran = {}
ftran[stIdle] =
  function (myid)
    local actors = getActors(V_TARGET, V_HOMUNTYPE)
    local owner = GetV(V_OWNER, myid)
    local d = 100
    local p_id = 0
    local a_d
    for id, a in pairs(actors) do
      if(a.target == myid or a.target == owner) then
        return stAttackCMD, {myid, id}
      end
      a_d = getDistance2(myid, id)
      if(a_d <= d and id >= 100000000 and a.homuntype >= 1 and a.homuntype <= 16 and id ~= myid) then
        d = a_d
	p_id = id
      end
    end
    if(p_id ~= 0) then
      return stAttackCMD, {myid, p_id}
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

ftran[stAttackCMD] =
  function (myid, target)
    if(isDead(target)) then
      return stFollowCMD, {myid}
    end
    local x,y = GetV(V_POSITION, target)
    return nil, nil
  end

ftran[stFollowCMD] = nil
ftran[stMoveCMD] = nil

-- ...
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid, ...)
  return ftran, stFollowCMD, {myid} -- ftran, fun, farg
end

return Profile
