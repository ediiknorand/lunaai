require "./AI/USER_AI/const.lua"
CONSOLE_PROFILE_PATH="./AI/USER_AI/console-lua/console.lua"

Profile = {}
-- Private --
consoleLoader = {}
debuglog = nil


-- Command wraper --
consoleLoader.command = {}
consoleLoader.command[MOVE_CMD] =
  function (myid, x, y)
    if consoleLoader.profile ~= nil then
      consoleLoader.profile.command[MOVE_CMD](myid, x, y)
    end
  end

consoleLoader.command[ATTACK_CMD] =
  function (myid, target)
    if consoleLoader.profile ~= nil then
      consoleLoader.profile.command[ATTACK_CMD](myid, target)
    end
  end

consoleLoader.command[FOLLOW_CMD] = {}
consoleLoader.command[FOLLOW_CMD].follow =
  function (myid)
    if consoleLoader.profile ~= nil then
      consoleLoader.profile.command[FOLLOW_CMD].follow(myid)
    end
  end


consoleLoader.command[FOLLOW_CMD].unfollow =
  function (myid)
    if consoleLoader.profile ~= nil then
      consoleLoader.profile.command[FOLLOW_CMD].unfollow(myid)
    end
  end

Profile.command = consoleLoader.command

-- Command wraper --
function wrap_command_tran(ftran, cmd_state, cmd)
  if cmd_state ~= nil then
    ftran[cmd_state] = ftran[cmd]
  end
end

-- Initial state as command state  --
function wrap_initial_state(fun, profile, command)
  if fun == profile.command[MOVE_CMD] then
    return command[MOVE_CMD]
  end
  if fun == profile.command[ATTACK_CMD] then
    return command[ATTACK_CMD]
  end
  if fun == profile.command[FOLLOW_CMD].follow then
    return command[FOLLOW_CMD].follow
  end
  if fun == profile.command[FOLLOW_CMD].unfollow then
    return command[FOLLOW_CMD].unfollow
  end
  return fun
end

-- Init --
Profile.init =
function (myid, ...)
  local owner_gid = GetV(V_OWNER, myid)
  local prefix = "./AI/USER_AI/saves/"..owner_gid.."/"
  if file_exists(prefix.."load.lua") then
    if file_exists(prefix.."define.lua") then
      dofile(prefix.."define.lua")
    end
    if file_exists(prefix.."set.lua") then
      dofile(prefix.."set.lua")
    end
    consoleLoader.param = dofile(prefix.."load.lua")
    consoleLoader.file = consoleLoader.param[1]
    if file_exists(consoleLoader.file) and (consoleLoader.file ~= CONSOLE_PROFILE_PATH) then
      consoleLoader.profile = dofile(consoleLoader.file)
      consoleLoader.param[1] = myid
      local ftran, fun, farg = consoleLoader.profile.init(unpack(consoleLoader.param))
      wrap_command_tran(ftran, consoleLoader.command[MOVE_CMD], consoleLoader.profile.command[MOVE_CMD])
      wrap_command_tran(ftran, consoleLoader.command[ATTACK_CMD], consoleLoader.profile.command[ATTACK_CMD])
      wrap_command_tran(ftran, consoleLoader.command[FOLLOW_CMD].unfollow, consoleLoader.profile.command[FOLLOW_CMD].unfollow)
      fun = wrap_initial_state(fun, consoleLoader.profile, consoleLoader.command)
      return ftran, fun, farg
    end
  end
  return nil, nil, nil -- ftran, fun, farg
end

return Profile
