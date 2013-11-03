-- command states
function stFollowCMD(myid)
  MoveToOwner(myid)
end

function stMoveCMD(myid, x, y)
  Move(myid, x, y)
end

function stAttackCMD(myid, target)
  local x,y = GetV(V_POSITION, target)
  Move(myid, x, y)
  Attack(myid, target)
end
