-- 本程序用于测试 Z80Emulator.lua
--

Z = require("Z80Emulator")

print("R8 测试-----------------------")
R8 = Z.Register8

R8:init()
print("R8 不带初值初始化:",R8:get())
print("R8 是否为0:", R8:isZero())

-- for k,v in pairs(R8) do print(k,v) end

R8:init(0xef)
print("R8 带初值初始化:", string.format("%X",R8:get()))
print("R8 是否为0:", R8:isZero())

R8:set(0xab)
print("R8 设置新值:", string.format("%X",R8:get()))
print("R8 是否为0:", R8:isZero())

R8:add(0x11)
print("R8 增加:", string.format("%X",R8:get()))

print("R8 获得进位标志 cy:", R8:cy())
print("R8 获得进位标志 ncy:", R8:ncy())

print("R8 获得减标志:", R8:n())
print("R8 获得奇偶校验|溢出标志 pv:", R8:pv())
print("R8 获得奇偶校验|溢出标志 npv:", R8:npv())

print("R8 获得半进位标志 hc:", R8:hc())
print("R8 获得零标志 z:", R8:z())
print("R8 获得零标志 nz:", R8:nz())

print("R8 获得签名标志 s:", R8:s())
print("R8 获得签名标志 ns:", R8:ns())

print("==== R16 测试-----------------------")
R16 = Z.Register16

local h = R8:init(0x34)
for k,v in pairs(h) do print(k,v) end

local l = R8:init(0x1264)
for k,v in pairs(l) do print(k,v) end

print("h.x == l.x? :",  h.x == l.x)
print(l.x, h.x)
R16:init(l,h)
print("R16 带初值 2个R8 初始化:", string.format("%X", R16:get()))

R16:set(R16:init(h,l))
print("R16 带初值 1个R16 初始化:", string.format("%X", R16:get()))

--for k,v in pairs(R16) do print(k,v) end

R16:set(0x4567)
print("R16 设置新值:", string.format("%X",R16:get()))

R16:set(0x0)
print("R16 设置新值:", string.format("%X",R16:get())) 
print("R16 是否为0:", R16:isZero())

R16:add(0x1234)
print("R16 增加:", string.format("%X",R16:get())) 

print("==== Z80:Z80Emulator() 构造函数-------------------")
z80 = Z:Z80Emulator()
--for k,v in pairs(Z) do print(k,v) end
print(Z.iff,Z.hlt,Z.a)





