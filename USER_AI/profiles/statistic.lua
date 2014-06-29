require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/follow.lua"
require "./AI/USER_AI/states/idle.lua"

Profile = {}

-- private
local log_ = nil
local gids = {}
local jobs = {}
local jobNames = {
 [0] = "Novice",
 [1] = "Swordman",
 [2] = "Magician",
 [3] = "Archer",
 [4] = "Acolyte",
 [5] = "Merchant",
 [6] = "Thief",

 [7] = "Knight",
 [8] = "Priest",
 [9] = "Wizard",
 [10] = "Blacksmith",
 [11] = "Hunter",
 [12] = "Assassin",
 [13] = "Knight riding a peco",

 [14] = "Crusader",
 [15] = "Monk",
 [16] = "Sage",
 [17] = "Rogue",
 [18] = "Alchemist",
 [19] = "Bard",
 [20] = "Dancer",
 [21] = "Crusader riding a peco",

 [23] = "Super Novice",
 [24] = "Gunslinger",
 [25] = "Ninja",

 [4001] = "High Novice",
 [4002] = "High Swordman",
 [4003] = "High Magician",
 [4004] = "High Archer",
 [4005] = "High Acolyte",
 [4006] = "High Merchant",
 [4007] = "High Thief",

 [4008] = "Lord Kngiht",
 [4009] = "High Priest",
 [4010] = "High Wizard",
 [4011] = "Whitesmith",
 [4012] = "Sniper",
 [4013] = "Assassin Cross",
 [4014] = "Lord Knight riding a peco",

 [4015] = "Paladin",
 [4016] = "Champion",
 [4017] = "Professor",
 [4018] = "Stalker",
 [4019] = "Creator",
 [4020] = "Clown",
 [4021] = "Gypsy",
 [4022] = "Paladin riding a peco",

 [4046] = "Taekwon",
 [4047] = "Star Gladiator",
 [4048] = "Flying Star Gladiator",
 [4049] = "Soul Linker"
}
-- functions

local function classOf(actor) -- requires V_HOMUNTYPE
  if isHom(actor.id) then
    if isHom(actor.id, LIF, LIF2, LIF_H, LIF_H2)  then
      return "Lif"
    elseif isHom(actor.id, AMISTR, AMISTR2, AMISTR_H, AMISTR_H2)  then
      return "Amistr"
    elseif isHom(actor.id, FILIR, FILIR2, FILIR_H, FILIR_H2)  then
      return "Filir"
    elseif isHom(actor.id, VANILMIRTH, VANILMIRTH2, VANILMIRTH_H, VANILMIRTH_H2)  then
      return "Vanilmirth"
    end
  elseif isMob(actor.id) then
    return "Mob"
  elseif actor.id >= 100000000 then
    if actor.homuntype >= 1000 then
      return "Pet"
    elseif actor.homuntype == 45 then
      return "Warp"
    else
      return "NPC"
    end
  end
  if jobNames[actor.homuntype] then
    return jobNames[actor.homuntype]
  end
  return "Other"
end

-- custom states
function stReading(myid)
  if not log_ then
    return
  end
  getActors(V_HOMUNTYPE,
    function (act, aid)
      if not gids[aid] then
        gids[aid] = true
	local j = jobs[classOf(act[aid])]
	if not j then
	  j = 0
	end
	j = j + 1
	jobs[classOf(act[aid])] = j
      end
    end)
    MoveToOwner(myid)
end
-- ftran
local ftran = {}
  -- ready
ftran[stIdle] =
function (myid)
  if log_ then
    log_:write("- - - - - - -\n")
    for job,n in pairs(jobs) do
      log_:write(n.." "..job.."\n")
    end
    log_:flush()
    jobs = {}
    gids = {}
  end
  return stIdleFollow, {myid}
end

-- init
Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stReading, unfollow = stIdle}
}

Profile.init =
function (myid, filename)
  if filename then
    log_ = io.open("./AI/USER_AI/saves/"..GetV(V_OWNER, myid).."/"..filename,"w")
    return ftran, stIdleFollow, {myid}
  end
  return ftran, stIdleFollow, {myid} -- ftran, fun, farg
end

return Profile
