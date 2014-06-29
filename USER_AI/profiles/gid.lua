require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/commands.lua"

Profile = {}

-- Private
local out_ = nil
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


-- Functions
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
    return "Mob("..actor.homuntype..")"
  elseif actor.id >= 100000000 then
    if actor.homuntype >= 1000 then
      return "Pet("..actor.homuntype..")"
    elseif actor.homuntype == 45 then
      return "Warp"
    else
      return "NPC("..actor.homuntype..")"
    end
  end
  if jobNames[actor.homuntype] then
    return jobNames[actor.homuntype]
  end
  return "Player("..actor.homuntype..")"
end

-- ftran
local ftran = {}

ftran[stIdle] =
  function (myid)
    if not out_ then
      return stIdleFollow,{myid}
    end
    out_:write("- - - - - - - - -\n")
    local owner = GetV(V_OWNER, myid)
    getActors(V_HOMUNTYPE, V_POSITION,
      function (act, aid)
        out_:write(aid.."(x:".. act[aid].x ..", y:".. act[aid].y ..") : is a ".. classOf(act[aid]))
	if aid == myid then
	  out_:write("(Me)")
	end
	if aid == owner then
	  out_:write("(You)")
	end
	out_:write("\n")
      end)
    out_:flush()
    return stIdleFollow,{myid}
  end

-- Init and command

Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stIdle, unfollow = stIdle}
}

Profile.init =
function (myid, outfile)
  if outfile then
    out_ = io.open("./AI/USER_AI/saves/"..GetV(V_OWNER, myid).."/"..outfile,"w")
  end
  return ftran, stIdleFollow, {myid}
end

return Profile
