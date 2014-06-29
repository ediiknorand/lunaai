require "./AI/USER_AI/const.lua"

-- Very useful stuff
function shallowcopy(ori)
  local copy
  if type(ori) == 'table' then
    copy = {}
    for i,val in pairs(ori) do
      copy[i] = val
    end
  else
    copy = ori
  end
  return copy
end

function deepcopy(ori)
  local copy
  if type(ori) == 'table' then
    copy = {}
    for i,val in pairs(ori) do
      copy[i] = deepcopy(val)
    end
  else
    copy = ori
  end
  return copy
end

function copyfunction(f)
  return function (...)
    f(unpack(arg))
  end
end

function file_exists(path)
  local f = io.open(path,"r")
  if f then
    io.close(f)
    return true
  end
  return false
end

-- Math stuff
function getDistance(x0, y0, x1, y1)
  return math.floor(math.sqrt((x1-x0)^2 + (y1-y0)^2))
end

function getDistance2(id0, id1)
  local x0, y0 = GetV(V_POSITION, id0)
  local x1, y1 = GetV(V_POSITION, id1)
  if(x0*x1 < 0) then
    return -1
  end
  return getDistance(x0,y0, x1,y1)
end

-- Simple and useful functions for your profile
function isDead(id)
  local x,y = GetV(V_POSITION, id)
  return x == -1 or GetV(V_MOTION, id) == MOTION_DEAD
end

function isMob(id)
  return IsMonster(id) ~= 0
end

function isHitted(id)
  local m = GetV(V_MOTION, id)
  return m == MOTION_HIT
end

function getActorInfo(id, ...)
  local actor = {}
  local functions = {}
  local f_idx = 1
  actor.id = id
  for i,v in ipairs(arg) do
    if(v == V_OWNER) then
      actor.owner = GetV(v, id)
    elseif(v == V_POSITION) then
      actor.x, actor.y = GetV(v, id)
    elseif(v == V_TYPE) then
      actor.type_ = GetV(v, id)
    elseif(v == V_MOTION) then
      actor.motion = GetV(v, id)
    elseif(v == V_ATTACKRANGE) then
      actor.atkrange = GetV(v, id)
    elseif(v == V_TARGET) then
      actor.target = GetV(v, id)
    elseif(v == V_SKILLATTACKRANGE) then
      actor.skillatkrange = GetV(v, id)
    elseif(v == V_HOMUNTYPE) then
      actor.homuntype = GetV(v, id)
    elseif(v == V_HP) then
      actor.hp = GetV(v, id)
    elseif(v == V_SP) then
      actor.sp = GetV(v, id)
    elseif(v == V_MAXHP) then
      actor.maxhp = GetV(v, id)
    elseif(v == V_MAXSP) then
      actor.maxsp = GetV(v, id)
    elseif(type(v) == "function")  then
      functions[f_idx] = v
      f_idx = f_idx + 1
    end
  end
  return actor, functions
end

function getActors(...)
  local actors = {}
  local functions = {}
  local oldActors = GetActors()
  for i,a in ipairs(oldActors) do
    actors[a], functions = getActorInfo(a, unpack(arg))
    for j,f in ipairs(functions) do
      local rv = f(actors, a)
      if rv ~= nil then
        return rv
      end
    end
  end
  return actors
end

function getOwner(myid, ...)
  return getActorInfo(GetV(V_OWNER, myid), unpack(arg))
end

function isHom(id, ...)
  local htype = GetV(V_HOMUNTYPE, id)
  local ishom = (id >= 100000000 and htype >= 1 and htype <= 16)
  if arg.n == 0 then
    return ishom
  end
  local rhtype = false
  for i,a in ipairs(arg) do
    rhtype = rhtype or (a == htype)
  end
  return ishom and rhtype
end
