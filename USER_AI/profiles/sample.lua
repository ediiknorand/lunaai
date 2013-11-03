require "./AI/USER_AI/const.lua"
Profile = {}

Profile.command = {
  [MOVE_CMD] = nil,
  [ATTACK_CMD] = nil,
  [FOLLOW_CMD] = {follow = nil, unfollow = nil}
}

Profile.init =
function (myid, ...)
  return nil, nil, nil -- ftran, fun, farg
end

return Profile
