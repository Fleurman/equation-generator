--[[ 
# Equation Generator
module written by Martin Ashton-Lomax
https://github.com/Fleurman/equation-generator

= How-To =


= TODO =
-[ ] handle for parameters
-[ ] clean up
-[ ] comments
-[ ] unlimited nb of operators

]]

generator = {}
generator.nbsize = 2
generator.limit = 9

function generator.largeRandom(arg) --size= of number, max= of highest unit, multiple= of the number
  local nb = 0
  for i=0,arg.size-1 do
    if i == arg.size-1 then
      nb = nb + math.random(1,arg.max)*(10^i)
    elseif i > 0 then
      nb = nb + math.random(0,9)*(10^i)
    else
      if arg.multiple == 2 then
        nb = generator.getPair()
      elseif arg.multiple == 3 then
        nb = generator.getTriple()
      elseif arg.multiple == 5 then
        nb = generator.getQuint()
      else
        nb = nb + math.random(0,9)
      end
    end
  end
  return nb
end

function generator.getPair()
  return 2 * math.random(4)
end
function generator.getTriple()
  return 3 * math.random(3)
end
function generator.getQuint()
  return math.random(2) == 2 and 5 or 0
end

function generator.newEquation()
  nbs = {}
  ops = {}
  local n1 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
  local n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    while n1 == n2 do
      --n1 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
      n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    end
  local rslt = 0
  local eq = ""
  local op = math.random(4)
  
  if op == 1 then
  table.insert(ops,"+")
    rslt = n1+n2
  elseif op == 2 then
  table.insert(ops,"-")
    if n1<n2 then n1,n2 = n2,n1 end
      rslt = n1-n2
  elseif op == 3 then
    table.insert(ops,"*")
    while n1*n2 > 999 do
      n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    end
    rslt = n1*n2
  elseif op == 4 then
  table.insert(ops,"/")
    while n1%n2 ~= 0 or n1 == n2 do
      n1 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
      n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    end
    rslt = n1/n2
  end
  table.insert(nbs,n1)
  table.insert(nbs,n2)
  table.insert(nbs,rslt)
  table.insert(ops,"=")
  
  
  eq = generator.processLargest()
  --equation = eq
  return eq
end

function generator.processLargest()
  local lrg = 1
  local pr = 0
  for i=1,3 do
    if nbs[i] > pr then 
      lrg = i
      pr = nbs[i]
    end
  end
  --print(nbs[1],nbs[2],nbs[3], "["..lrg.."]")
  generator.calcForLargest(nbs[lrg],lrg)
  return generator.writeEquation()
end

function generator.writeEquation()
  local s = ""
  s = tostring(math.ceil(nbs[1])) .. tostring(ops[1]) .. tostring(math.ceil(nbs[2])) .. tostring(ops[2]) .. tostring(math.ceil(nbs[3])) .. tostring(ops[3]) .. tostring(math.ceil(nbs[4]))
  return s
end

function generator.newOp(n,o)
  local l = {"+","-","*","/"}
  local r = math.random(n)+o
  local nop = l[r]
  while nop == ops[1] or nop == ops[2] do
    r = math.random(4)
    nop = l[r]
  end
  return r
end

function generator.calcForLargest(nb1,lrg)
  local n1 = nb1
  local n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    while n1 == n2 do
      n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    end
  local op = 0
  if ops[1] == "*" or ops[1] == "/" then
    op = generator.newOp(2,2)
  else
    op = generator.newOp(4,0)
  end
  
  local new_op = ""
  
  if op == 1 then
    --print("check for [+]")
    new_op = "+"
    while n1<n2 do
      n2 = generator.largeRandom({size=generator.nbsize,max=generator.limit})
    end
    nbs[lrg] = nbs[lrg] - n2
  elseif op == 2 then
    new_op = "-"
    --print("check for [-]")
    while n1<n2 or n1+n2 > 999 do
      n2 = math.random(1,n1-1)
    end
    nbs[lrg] = nbs[lrg] + n2
  elseif op == 3 then
    --print("check for [*]")
    new_op = "*"
    while n1%n2 ~= 0 or n1 == n2 do
      n2 = math.random(9999)
    end
    nbs[lrg] = nbs[lrg] / n2
  elseif op == 4 then
    --print("check for [/]")
    new_op = "/"
    while n1*n2 > 999 or n1 == n2 do
      n2 = math.random(1,99)
    end
    nbs[lrg] = nbs[lrg] * n2
  end
      table.insert(ops,lrg,new_op)
      table.insert(nbs,lrg+1,n2)
      --print("--------------------")
      --print(nbs[1],nbs[2],nbs[3],nbs[4])
      --print(ops[1],ops[2],ops[3], "["..ops[lrg].."]")
      --print("\n")
  if not verify() then
    --print("False !")
    generator.newEquation()
    return
  end
  if nbs[1] == nbs[3] and nbs[2] == nbs[4] or 
     nbs[1] == nbs[4] and nbs[2] == nbs[3] then
       --print("Same Numbers !")
       generator.newEquation()
       return
  end
end

-- Check wether the generated equation is valid
function verify()
  local nbs2 = {}
  for i,n in ipairs(nbs) do table.insert(nbs2,n) end
  local ops2 = {}
  for i,n in ipairs(ops) do table.insert(ops2,n) end
  -- replace the '=' operator with a '==' operator to perform a check
  for i,n in ipairs(ops2) do if n == "=" then ops2[i] = "==" end end
  local s = tostring(nbs2[1]) .. tostring(ops2[1]) .. tostring(nbs2[2]) .. tostring(ops2[2]) .. tostring(nbs2[3]) .. tostring(ops2[3]) .. tostring(nbs2[4])
  local func = assert(load("return " .. s))
  return func()
end

return generator
