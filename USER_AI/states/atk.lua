function stLifAttack(myid, target)
  local x,y = GetV(V_POSITION, target)
  Move(myid, x, y)
  Attack(myid, target)
end
