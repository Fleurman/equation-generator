math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )

gen = require "equationGen"

print(gen.newEquation())