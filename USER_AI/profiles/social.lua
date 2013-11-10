require "./AI/USER_AI/const.lua"
require "./AI/USER_AI/util.lua"
require "./AI/USER_AI/states/commands.lua"
require "./AI/USER_AI/states/idle.lua"
require "./AI/USER_AI/states/aspd-dance.lua"

Profile = {}

Profile.command = {
  [MOVE_CMD] = stMoveCMD,
  [ATTACK_CMD] = stAttackCMD,
  [FOLLOW_CMD] = {follow = stFollowCMD, unfollow = stIdle}
}

Profile.init =
function (myid)
  local ftran = {
    [stMoveCMD] = {},
    [stAttackCMD] = {},
    [stFollowCMD] = {},
    [stIdle] = {
      [stAttackCMD] =
        function (myid)
	  local t
	  local actors = GetActors()
	  for i,a in ipairs(actors) do
	    t = GetV(V_HOMUNTYPE, a)
	    if(not isMob(a) and t >= 0 and t <= 16 and a >= 100000000) then
	      return true, {myid, a}
	    end
	  end
	  return false, nil
	end
    }
  }
  return ftran, stIdle, {myid} -- ftran, fun, farg
end

return Profile
