require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
M = {}
-- Private vars
local cobaia = 0
local log_fifo = nil

-- Custom States
local function stCustomMove(myid, x, y)
  if(cobaia ~= 0 and log_fifo ~= nil) then
    local ex, ey = GetV(V_POSITION, cobaia)
    if(ex == -1 or GetV(V_MOTION,cobaia) == MOTION_DEAD) then
      log_fifo:write(cobaia.." is dead. ( "..ex..", "..ey..")\n")
      log_fifo:flush()
      --log_fifo:close()
    else
      log_fifo:write(cobaia.." is ".. GetV(V_MOTION,cobaia)..".\n")
      log_fifo:flush()
    end
  end
  stMoveCMD(myid, x, y)
end

local function stCustomAttack(myid, target)
  cobaia = target
  stAttackCMD(myid, target)
end

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
  [MOVE_CMD] = stCustomMove,
  [ATTACK_CMD] = stCustomAttack,
  [FOLLOW_CMD] = { follow = stStrictFollow,  unfollow = stIdle}
}

-- Init
M.init =
function (myid)
  local ftran = {
    [stIdle] = {
      [stAttackCMD] = attackEnemy,
      [stIdleFollow] = followOwner
    },
    [stCustomMove] = {},
    [stAttackCMD] = {
      [stIdle] = attackDeadEnemy,
      [stAttackCMD] = saveOwner
    },
    [stIdleFollow] = {
      [stIdle] = unfollowOwner
    },
    [stStrictFollow] = {},
    [stCustomAttack] = {}
  }
  log_fifo = io.open("./AI/USER_AI/test.fifo","w")
  return ftran, stStrictFollow, {myid}
end

return M
