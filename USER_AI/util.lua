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

function copyfunction(f)
  return function (...)
    f(unpack(arg))
  end
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

function getActors(...)
  local actors = {}
  local oldActors = GetActors()
  for i,a in ipairs(oldActors) do
    actors[a] = {}
    for j,v in ipairs(arg) do
      if(v == V_OWNER) then
        actors[a].owner = GetV(v, a)
      elseif(v == V_POSITION) then
        actors[a].x, actors[a].y = GetV(v, a)
      elseif(v == V_TYPE) then
        actors[a].type_ = GetV(v, a)
      elseif(v == V_MOTION) then
        actors[a].motion = GetV(v, a)
      elseif(v == V_ATTACKRANGE) then
        actors[a].atkrange = GetV(v, a)
      elseif(v == V_TARGET) then
        actors[a].target = GetV(v, a)
      elseif(v == V_SKILLATTACKRANGE) then
        actors[a].skillatkrange = GetV(v, a)
      elseif(v == V_HOMUNTYPE) then
        actors[a].homuntype = GetV(v, a)
      elseif(v == V_HP) then
        actors[a].hp = GetV(v, a)
      elseif(v == V_SP) then
        actors[a].sp = GetV(v, a)
      elseif(v == V_MAXHP) then
        actors[a].maxhp = GetV(v, a)
      elseif(v == V_MAXSP) then
        actors[a].maxsp = GetV(v, a)
      elseif(type(v) == "function") then
        local rv = v(actors, a)
	if rv ~= nil then
	  return rv
	end
      end
    end
  end
  return actors
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
