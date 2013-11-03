function stStrictFollow(myid, ...)
  local owner = GetV(V_OWNER, myid)
  x,y = GetV(V_POSITION, owner)
  Move(myid, x,y)
end

function stFollowTarget(myid, target, ...)
  local x,y = GetV(V_POSITION, target)
  Move(myid, x, y)
end
