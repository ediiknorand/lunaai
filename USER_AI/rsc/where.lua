require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"

-- Private
local mapname
local checked_npc = {}

local time_before
local time_cooldown = 0

local function delta()
  local time_now = GetTick()/1000
  local d = time_now-time_before
  time_before = time_now
  return d
end

local function isNpc(id)
  return id >= 100000000 and not isHom(id) and not isMob(id)
end

local function canCheckNPCs()
  local a = getActors(
    function(act, aid)
      if isNpc(aid) and not checked_npc[aid] then
        return true
      end
   end)
   return type(a) == "boolean"
end

local function checkNPCs()
  local npcdb = dofile("./AI/USER_AI/rsc/npcdb.lua") -- Yup. An entire NPC database...
  local maps = {}
  local map = getActors(V_HOMUNTYPE, V_POSITION,
    function(act, aid)
      if isNpc(aid) and act[aid].x ~= -1 and not checked_npc[aid] then
        checked_npc[aid] = true
        local conflict = 0
	local map_con
	local x,y,job = act[aid].x, act[aid].y, act[aid].homuntype
	for i,v in pairs(npcdb) do
          if string.find(i, "[(]"..x..","..y..",(%d+),"..job.."[)]") then
	    conflict = conflict + 1
	    map_con = v.map
	    if not maps[v.map] then
	      maps[v.map] = 1
	    else
	      maps[v.map] = maps[v.map] + 1
	    end
	  end
	end
	if conflict == 1 then
	  return map_con
	end
      end
    end)
  if type(map) == "string" then
    npcdb = nil
    collectgarbage()
    return map -- One NPC that confirms his location
  end

  -- Not eenough information? Democracy mode
  local popular_map = nil
  local votes = 1
  for i,v in pairs(maps) do
    if v > votes then
      votes = v
      popular_map = i
    end
  end
  npcdb = nil
  collectgarbage()
  return popular_map -- More npc that believes they are in this map (at least 2 NPCs)
end

local function where(cooldown)
  if mapname then
    return mapname
  end
  -- Time management to avoid unnecessary database reading
  if cooldown then
    if not time_before then
      time_before = GetTick()/1000
    end
    time_cooldown = time_cooldown + delta()
    if time_cooldown > cooldown then
      time_cooldown = 0
    end
  end
  if time_cooldown > 0 then
    return nil
  end
  -- Check if some NPC can confirm its location
  if canCheckNPCs() then
    mapname = checkNPCs()
  end

  return mapname
end

return where
