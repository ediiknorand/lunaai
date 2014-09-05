require "./AI/USER_AI/util.lua"

M = {}

-- Module vars
local State = {
  fun = nil,
  farg = nil,
  ftran = nil
}
local Profile = nil
local MyId

-- State functions
local function tstate(state, ...)
  State.fun = state
  State.farg = shallowcopy(arg)
end

local function cstate()
  if(State.ftran == nil) then
    return
  end
  local r = false
  local farg = nil
  if(type(State.ftran[State.fun]) == "table") then
    for state,cond in pairs(State.ftran[State.fun]) do
      if(State.farg ~= nil) then
        r,farg = cond(unpack(State.farg))
      else
        r,farg = cond()
      end
      if r then
        if(farg ~= nil) then
          tstate(state, unpack(farg))
        else
          tstate(state)
        end
        return
      end
    end
  elseif(type(State.ftran[State.fun]) == "function") then
    if(State.farg ~= nil) then
      r, farg = State.ftran[State.fun](unpack(State.farg))
    else
      r, farg = State.ftran[State.fun]()
    end
    if(r ~= nil) then
      if(farg ~= nil) then
        tstate(r, unpack(farg))
      else
        tstate(r)
      end
    end
    return
  end
end

local function pstate()
  if(State.fun ~= nil) then
    cstate()
    if(State.farg ~= nil) then
      State.fun(unpack(State.farg))
    else
      State.fun()
    end
  end
end

-- Commands
local function onFollowCMD(myid)
  if (State.fun == Profile.command[FOLLOW_CMD].follow) then
    if(Profile.command[FOLLOW_CMD].unfollow ~= nil) then
      tstate(Profile.command[FOLLOW_CMD].unfollow, myid)
    end
  else
    if(Profile.command[FOLLOW_CMD].follow ~= nil) then
      tstate(Profile.command[FOLLOW_CMD].follow, myid)
    end
  end
end

local function onMoveCMD(myid, x, y)
  tstate(Profile.command[MOVE_CMD], myid, x, y)
end

local function onAttackCMD(myid, myenemy)
  tstate(Profile.command[ATTACK_CMD], myid, myenemy)
end

--   This is ugly. I know ...
local function cmdProcess(myid)
  local msg = GetMsg(myid)
  if(msg[1] == FOLLOW_CMD and Profile.command[FOLLOW_CMD] ~= nil) then
    onFollowCMD(myid)
  elseif(msg[1] == MOVE_CMD) then
    onMoveCMD(myid, msg[2], msg[3])
  elseif(msg[1] == ATTACK_CMD) then
    onAttackCMD(myid, msg[2])
  end
end

-- Profile Load
M.loadProfile =
function (path, myid, ...)
  Profile = dofile(path)
  if(arg.n == 0) then
    State.ftran, State.fun, State.farg = Profile.init(myid)
  else
    State.ftran, State.fun, State.farg = Profile.init(myid, unpack(arg))
  end
  MyId = myid
end

M.loadedProfile =
function ()
  return Profile ~= nil
end

M.run =
function ()
  if(Profile == nil) then
    return
  end
  cmdProcess(MyId)
  pstate()
end

return M
