require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/states/aspd-dance.lua"
require "./AI/USER_AI/const.lua"
M = {}

-- Conditions
local function attackDeadEnemy(myid, target)
  local ex, ey = GetV(V_POSITION, target)
  if(ex == -1 or GetV(V_MOTION, target) == MOTION_DEAD) then
    return true, {myid}
  end
  return false, nil
end

local function attackEnemy(myid)
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
  local actors = GetActors()
  local owner = GetV(V_OWNER, myid)
  for id,a in ipairs(actors) do
    if(GetV(V_TARGET, a) == owner) then
      return true, {myid, a}
    end
  end
  return false, nil
end

-- Commands
M.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackDance,
  [FOLLOW_CMD] = { follow = stStrictFollow,  unfollow = stIdle}
}

-- Init
M.init =
function (myid)
  local ftran = {
    [stIdle] = {
      [stAttackDance] = attackEnemy,
      [stIdleFollow] = followOwner
    },
    [stMoveCMD] = {},
    [stAttackDance] = {
      [stIdle] = attackDeadEnemy,
      [stAttackDance] = saveOwner
    },
    [stIdleFollow] = {
      [stIdle] = unfollowOwner
    },
    [stStrictFollow] = {}
  }
  return ftran, stStrictFollow, {myid}
end

return M
