require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
M = {}

-- Custom States
function stLookingForFoes(myid, target)

end

-- Conditions

local function checkFoes(myid, target)
  local ex, ey = GetV(V_POSITION, target)
  if(GetV(V_MOTION, target) ~= MOTION_DEAD and ex ~= -1) then
    return false, nil
  end
  local actors = GetActors()
  local owner = GetV(V_OWNER, myid)
  local at
  for id, a in ipairs(actors) do
    at = GetV(V_TARGET, a)
    if(target ~= a and GetV(V_MOTION, a) ~= MOTION_DEAD and (at == owner or at == myid)) then
      return true, {myid, a}
    end
  end
  return true, {myid, 0}
end

local function moreFoes(myid, target)
  if(target ~= 0) then
    return true, {myid, target}
  end
  return false, nil
end

local function noMoreFoes(myid, target)
  if(target == 0) then
    return true, {myid}
  end
  return false, nil
end

local function chaseEnemy(myid)
  local actors = GetActors()
  local owner = GetV(V_OWNER, myid)
  local itstarget
  for id,a in ipairs(actors) do
    itstarget = GetV(V_TARGET, a)
    if(GetV(V_MOTION, a) ~= MOTION_DEAD and (itstarget == owner) or (itstarget == myid)) then
      return true, {myid, a}
    end
  end
  return false, nil
end

local function chaseFailed(myid, target)
  local x,y = GetV(V_POSITION, target)
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  if(x == -1 or getDistance2(myid, target) > 20) then
    return true, {myid}
  end
  for i,a in ipairs(actors) do
    if(a ~= myid and a ~= owner and a~= target) then
      if(GetV(V_TARGET, a) == target) then
        return true, {myid}
      end
    end
  end
  return false, nil
end

local function followOwner(myid)
  if(GetV(V_MOTION, GetV(V_OWNER, myid)) == MOTION_MOVE) then
    return true, {myid}
  end
  return false, nil
end

local function unfollowOwner(myid)
  if(GetV(V_MOTION, GetV(V_OWNER, myid)) ~= MOTION_MOVE) then
    return true, {myid}
  end
  return false, nil
end

local function saveOwner(myid, target)
  --local ex, ey = GetV(V_POSITION, target)
  --if(GetV(V_MOTION, target) == MOTION_DEAD or ex == -1) then
  --  return false, nil
  --end
  local actors = GetActors()
  local owner = GetV(V_OWNER, myid)
  local targetStatus = GetV(V_MOTION, target)
  local a_target
  for id,a in ipairs(actors) do
    a_target = GetV(V_TARGET, a)
    if(a ~= target and a_target == owner) then
      return true, {myid, a}
    end
  end
  return false, nil
end

local function targetReached(myid, target)
  local x,y = GetV(V_POSITION, target)
  if(x ~= -1 and getDistance2(myid, target) <= 1) then
    return true, {myid, target}
  end
  return false, nil
end

-- Commands
M.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = { follow = stStrictFollow,  unfollow = stIdle}
}

-- Init
M.init =
function (myid)
  local ftran = {
    [stIdle] = {
      [stFollowTarget] = chaseEnemy,
      [stIdleFollow] = followOwner
    },
    [stMoveCMD] = {},
    [stFollowTarget] = {
      [stAttackCMD] = targetReached,
      [stIdle] = chaseFailed,
      [stFollowTarget] = saveOwner
    },
    [stAttackCMD] = {
      [stLookingForFoes] = checkFoes,
      [stAttackCMD] = saveOwner
    },
    [stIdleFollow] = {
      [stIdle] = unfollowOwner
    },
    [stStrictFollow] = {},
    [stLookingForFoes] = {
      [stFollowTarget] = moreFoes,
      [stIdleFollow] = noMoreFoes
    }
  }
  return ftran, stStrictFollow, {myid}
end

return M
