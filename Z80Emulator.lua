--[[
--Zilog Z80 emulator for Lua
--]]

Z80Emulator = {}

local Z80 = Z80Emulator

--
-- 8位寄存器
Z80.Register8  = {}
local R8 = Z80.Register8

-- 构造函数
function R8:init(value)
	if value then
		self.x = value & 0xff;
	elseif value == nil then
		self.x = 0 & 0xff; 
	end

	local instance = {}
	instance.x = self.x
	setmetatable(instance, {__index = self})

	return instance
end

-- 获取值 int get()
function R8:get() return self.x end

-- 设置值 int set(int value)
function R8:set(value)  self.x = value & 0xff; return R8:get(); end

-- 若该值为零 boolean isZero()
function R8:isZero() return self.x == 0; end

-- 增加值 int add(int value)
function R8:add(value)  return R8:set(R8:get() + value) end

-- 获得进位标志 int cy() | int ncy()
function R8:cy()  return self.x & Z80Emulator.MASK_CY; end

function R8:ncy() return R8:cy() ~ Z80Emulator.MASK_CY; end

-- 获得减标志 int n()
function R8:n()  return self.x & Z80Emulator.MASK_N end

-- 获得奇偶校验/溢出标志 int pv() | int npv()
function R8:pv() return self.x & Z80Emulator.MASK_PV end

function R8:npv()  return R8:pv() ~ Z80Emulator.MASK_PV end

-- 获得半进位标志 int hc()
function R8:hc() return self.x & Z80Emulator.MASK_HC; end

-- 获取零标志 int z() | int nz()
function R8:z()  return self.x & Z80Emulator.MASK_Z; end
function R8:nz() return R8:z() ~ Z80Emulator.MASK_Z; end

-- 获取签署标志 int s() | int ns()
function R8:s()  return self.x & Z80Emulator.MASK_S; end
function R8:ns() return R8:s() ~ Z80Emulator.MASK_S; end

-- 16位寄存器
Z80.Register16 = {l = R8, h = R8}
local R16 = Z80.Register16

-- 构造函数 Register16(Register8 low, Register8 high)
function R16:init(low, high)
	self.l = low;
	self.h = high
	
	local instance = {} 
	instance.l = self.l
	instance.h = self.h
	setmetatable(instance, {__index = self})

	return instance
end

-- 获取值 int get()
function R16:get()
	return ((self.h.x << 8) | self.l.x);
end

-- 设置值 int set(int value | Register16 value)
function R16:set(value)
	local valueType = type(value)
	if valueType == "number" then
		self.l.x  = value & 0xff;
		--R16:h.x = (value >>> 8) & 0xff;
		self.h.x = (value >> 8) & 0xff;
	elseif valueType == "table" then
		self.l.x = value.l.x;
		self.h.x = value.h.x;
	end
	return R16:get();
end 

-- 若该值为零 boolean isZero()
function R16:isZero() 
	return R16:get() == 0;
end 

-- 增加值 int add(int value)
function R16:add(value)
	return R16:set(R16:get() + value);
end

-- 进位标志 static final int MASK_CY
Z80Emulator.MASK_CY = 0x01

-- 减标记 static final int MASK_N
Z80Emulator.MASK_N  = 0x02

-- 奇偶/溢出标志 static final int MASK_PV
Z80Emulator.MASK_PV = 0x04

-- 半进位标志 static final int MASK_HC
Z80Emulator.MASK_HC = 0x10

-- 零标志 static final int MASK_Z
Z80Emulator.MASK_Z  = 0x40

-- 注册标志 static final int MASK_S
Z80Emulator.MASK_S  = 0x80

local MASK_CY = Z80Emulator.MASK_CY 
local MASK_N  = Z80Emulator.MASK_N
local MASK_PV = Z80Emulator.MASK_PV
local MASK_HC = Z80Emulator.MASK_HC
local MASK_Z  = Z80Emulator.MASK_Z
local MASK_S  = Z80Emulator.MASK_S

-- 状态的（XX）的数量 static final int[] statesXX
local statesXX = { 
		4, 10,  7,  6,  4,  4,  7,  4,  4, 11,  7,  6,  4,  4,  7,  4,
		8, 10,  7,  6,  4,  4,  7,  4,  7, 11,  7,  6,  4,  4,  7,  4,
		7, 10, 16,  6,  4,  4,  7,  4,  7, 11, 16,  6,  4,  4,  7,  4,
		7, 10, 13,  6, 11, 11, 10,  4,  7, 11, 13,  6,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		7,  7,  7,  7,  7,  7,  4,  7,  4,  4,  4,  4,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
		5, 10, 10, 10, 10, 11,  7, 11,  5,  4, 10,  0, 10, 10,  7, 11,
		5, 10, 10, 11, 10, 11,  7, 11,  5,  4, 10, 11, 10,  0,  7, 11,
		5, 10, 10, 19, 10, 11,  7, 11,  5,  4, 10,  4, 10,  0,  7, 11,
		5, 10, 10,  4, 10, 11,  7, 11,  5,  6, 10,  4, 10,  0,  7, 11
}

-- 状态的数目（CB XX）static final int[] statesCBXX
local statesCBXX = {
		8, 8, 8, 8, 8, 8, 15, 8, 8, 8, 8, 8, 8, 8, 15, 8,
		8, 8, 8, 8, 8, 8, 15, 8, 8, 8, 8, 8, 8, 8, 15, 8,
		8, 8, 8, 8, 8, 8, 15, 8, 8, 8, 8, 8, 8, 8, 15, 8,
		8, 8, 8, 8, 8, 8, 15, 8, 8, 8, 8, 8, 8, 8, 15, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8,
		8, 8, 8, 8, 8, 8, 12, 8, 8, 8, 8, 8, 8, 8, 12, 8
	}

-- 状态（DD/ FD XX）的数量 static final int[] statesDDXX
local statesDDXX = {
		 8,  8,  8,  8,  8,  8,  8,  8,  8, 10,  8,  8, 8, 8,  8, 8,
		 8,  8,  8,  8,  8,  8,  8,  8,  8, 10,  8,  8, 8, 8,  8, 8,
		 8, 14, 20, 10,  8,  8, 12,  8,  8, 10, 20, 10, 8, 8, 12, 8,
		 8,  8,  8,  8, 19, 19, 19,  8,  8, 10,  8,  8, 8, 8,  8, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		19, 19, 19, 19, 19, 19,  8, 19,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8, 19,  8,  8,  8,  8,  8, 8, 8, 19, 8,
		 8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  0, 8, 8,  8, 8,
		 8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8, 8, 8,  8, 8,
		 8, 14,  8, 23,  8, 15,  8,  8,  8,  8,  8,  8, 8, 8,  8, 8,
		 8,  8,  8,  8,  8,  8,  8,  8,  8, 10,  8,  8, 8, 8,  8, 8
	}

-- 状态（DD/ FD XX）的数量 static final int[] statesDDCBXX
local statesDDCBXX = {
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 20, 12, 12, 12, 12, 12, 12, 12, 20, 12,
		12, 12, 12, 12, 12, 12, 20, 12, 12, 12, 12, 12, 12, 12, 20, 12,
		12, 12, 12, 12, 12, 12, 20, 12, 12, 12, 12, 12, 12, 12, 20, 12,
		12, 12, 12, 12, 12, 12, 20, 12, 12, 12, 12, 12, 12, 12, 20, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12,
		12, 12, 12, 12, 12, 12, 23, 12, 12, 12, 12, 12, 12, 12, 23, 12
	}

-- 状态数(ED xx) static final int[] statesEDXX
local statesEDXX = {
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		12, 12, 15, 20, 8, 14, 8,  9, 12, 12, 15, 20, 8, 14, 8,  9,
		12, 12, 15, 20, 8,  8, 8,  9, 12, 12, 15, 20, 8,  8, 8,  9,
		12, 12, 15 ,16, 8,  8, 8, 18, 12, 12, 15, 20, 8,  8, 8, 18,
		 8,  8, 15, 20, 8,  8, 8,  8, 11, 12, 15, 20, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		16, 16, 16, 16, 8,  8, 8,  8, 16, 16, 16, 16, 8,  8, 8,  8,
		 0,  0,  0,  0, 8,  8, 8,  8,  0,  0,  0,  0, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8,
		 8,  8,  8,  8, 8,  8, 8,  8,  8,  8,  8,  8, 8,  8, 8,  8
	}

-- 命令長(xx) static final int[] lengthXX
local lengthXX = {
		1, 3, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1,
		2, 3, 3, 1, 1, 1, 2, 1, 2, 1, 3, 1, 1, 1, 2, 1,
		2, 3, 3, 1, 1, 1, 2, 1, 2, 1, 3, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 3, 3, 3, 1, 2, 1, 1, 1, 3, 0, 3, 3, 2, 1,
		1, 1, 3, 2, 3, 1, 2, 1, 1, 1, 3, 2, 3, 0, 2, 1,
		1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 0, 2, 1,
		1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 0, 2, 1
	}

-- 命令長(CB xx) static final int[] lengthCBXX
local lengthCBXX = {
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	}

-- 命令長(DD/FD xx) static final int[] lengthDDXX
local lengthDDXX = {
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 3, 3, 1, 1, 1, 2, 1, 1, 1, 3, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 2, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	}

-- 命令長(DD/FD CB xx) static final int[] lengthDDCBXX
local lengthDDCBXX = {
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	}

-- 命令長(ED xx) static final int[] lengthEDXX
local lengthEDXX = {
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1,
		1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1,
		1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1,
		1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	}

-- 奇偶校验结果表 static final int[] parity
local parity = {
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0,
		MASK_PV, 0, 0, MASK_PV, 0, MASK_PV, MASK_PV, 0, 0, MASK_PV, MASK_PV, 0, MASK_PV, 0, 0, MASK_PV
	}


-- 对R寄存器的随机数 static int rnd
Z80.rnd = 0xffffffff

-- 命令長	length
-- 状态数	states
-- 工作寄存器（8位）	init tmpreg8
-- 工作寄存器 (16位) 	init tmpreg16
-- 累加器		init a
-- 标志位		init f
-- 通用寄存器B		init b
-- 通用寄存器C          init c
-- 通用寄存器D          init d
-- 通用寄存器E          init e
-- 通用寄存器H          init h
-- 通用寄存器L          init l
-- 索引寄存器IX（上部）	init ixh
-- 索引寄存器IX（下部） init ixl
-- 索引寄存器IY（上部）	init iyh
-- 索引寄存器IY（下部） init iyl
-- 累加器标志		init af
-- 通用寄存器BC		init bc
-- 通用寄存器DE		init de
-- 通用寄存器HL		init hl
-- 索引指针IX		init ix
-- 索引指针IY		init iy
-- 辅助寄存器AF'	init af_d
-- 辅助寄存器BC'	init bc_d
-- 辅助寄存器DE'	init de_d
-- 辅助寄存器HL'	init hl_d
-- 堆栈指针		init sp
-- 中断寄存器		init i
-- 程序计数器		pc
-- 中断模式		im
-- IFF			iff
-- 是否停机?		hlt
-- 执行状态		executeStates
-- 剩余状态数		restStates
-- 是否跟踪		trace


-- 构造函数
function Z80:Z80Emulator()
	Z80.im = 0;
	Z80.iff = 0;
	Z80.hlt = false;
	Z80.a = R8:init(0xff);
	Z80.f = R8:init(0xff);
	Z80.b = R8:init(0xff);
	Z80.c = R8:init(0xff);
	Z80.d = R8:init(0xff);
	Z80.e = R8:init(0xff);
	Z80.h = R8:init(0xff);
	Z80.l = R8:init(0xff);
	Z80.ixh = R8:init(0xff);
	Z80.ixl = R8:init(0xff);
	Z80.iyh = R8:init(0xff);
	Z80.iyl = R8:init(0xff);
	Z80.af = R16:init(f, a);
	Z80.bc = R16:init(c, b);
	Z80.de = R16:init(e, d);
	Z80.hl = R16:init(l, h);
	Z80.ix = R16:init(ixl, ixh);
	Z80.iy = R16:init(iyl, iyh);
	Z80.sp = R16:init(R8:init(0xff), R8:init(0xff));
	Z80.af_d = R16:init(R8:init(0xff), R8:init(0xff));
	Z80.bc_d = R16:init(R8:init(0xff), R8:init(0xff));
	Z80.de_d = R16:init(R8:init(0xff), R8:init(0xff));
	Z80.hl_d = R16:init(R8:init(0xff), R8:init(0xff));
	Z80.i = R8:init(0xff);
	Z80.tmpreg8 = R8:init();
	Z80.tmpreg16 = R16:init(tmpreg8, R8:init());
	Z80.pc = 0x0000;
	Z80.restStates = 0;
	Z80.trace = false;	
end

--
local rnd	=	Z80.rnd
local im	=	Z80.im
local iff	=	Z80.iff 
local a		= 	Z80.a
local f		=	Z80.f
local b		= 	Z80.b
local c		=	Z80.c
local d		= 	Z80.d
local e		=	Z80.e
local h		= 	Z80.h
local l		= 	Z80.l
local ixh	=	Z80.ixh
local ixl	=	Z80.ixl
local iyh	=	Z80.iyh
local iyl	=	Z80.iyl
local af	=	Z80.af
local bc	=	Z80.bc
local de	=	Z80.de
local hl	=	Z80.hl
local ix	=	Z80.ix
local iy	=	Z80.iy
local sp	=	Z80.sp
local af_d	=	Z80.af_d
local bc_d	=	Z80.bc_d
local de_d	=	Z80.de_d
local hl_d	=	Z80.hl_d
local i		=	Z80.i
local tmpreg8	=	Z80.tmpreg8
local tmpreg16	=	Z80.tmpreg16
local pc	=	Z80.pc
local restStates	=	Z80.restStates
local trace	=	Z80.trace

-- 内存Ram (0x0000~0xffff) 
--	private byte[] memory;
local memory = {}

-- Ram 初始值 (0x0000~0x003f)
-- private byte[] base = new byte[] {...}
local base = {
		 0xc3,  0xf4,  0xbf,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x03,  0xbd,  0x00,  0x00,  0x00,  0x00,  0x00,
		 0xc9,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00
	}

-- ROM (0x8000~0xffff)
-- private byte[][] rom;
local rom = {{}}

-- 输出日志 abstract void log(String message);
function Z80:log(message)

end

-- 读取内存（8位）abstract byte read(int address);
function Z80:read(address)

end

-- 只读存储器（覆盖）
-- @Override public byte read(int address)
function Z80:read(address)
	return memory[address];
end

-- int read8(int address | Register16 address)
function Z80:read8(address)
	local typeAddress = type(address)
	if typeAddress == "number" then
		return (Z80:read(address)) & 0xff;
	elseif typeAddress == "table" then
		return (Z80:read(address.get())) & 0xff;
	end
end

function Z80:read8(address)
	local address1 = nOrReg(address)
	return (Z80:read(address1)) & 0xff;
end

-- 读取内存（16位）int read16(int address | Register16 address)
function Z80:read16(address)
	local typeAddress = type(address)
	if typeAddress == "number" then
		return Z80:read8(address) | (Z80:read8((address + 1) & 0xffff) << 8);
	elseif typeAddress == "table" then
		return Z80:read8(address.get()) | ((Z80:read8(address.get() + 1) & 0xffff) << 8);
	end
end

-- 写入内存（8位）abstract void write(int address, byte value);
function Z80:write(address, value)

end

-- 写入到存储器（超驰）
-- @Override public void write(int address, byte value)
function Z80:write(address, value)
	if(address < 0x8000) then
		memory[address] = value;
	end
end

-- void write8(int address | Register16 address, int value | Register8 value)
function Z80:write8(address, value)
	local typeAddress, typeValue = type(address), type(value)
	if typeAddress == "number" and typeValue == "number" then
		Z80:write(address, value);
	elseif typeAddress == "table" and typeValue == "number" then
		Z80:write(address.get(), value);
	elseif typeAddress == "number" and typeValue == "table" then
		Z80:write(address, value.get());
	elseif typeAddress == "table" and typeValue == "table" then
		Z80:write(address.get(), value.get());
	end
end

-- 写入内存（16位）void write16(int address | Register16 address, int value | Register16 value)
function Z80:write16(address, value)
	local typeAddress, typeValue = type(address), type(value)
	if typeAddress == "number" and typeValue == "number" then
		Z80:write8(address, value & 0xff);
		--Z80write8((address + 1) & 0xffff, value >>> 8);
		Z80write8((address + 1) & 0xffff, value >> 8);
	elseif typeAddress == "table" and typeValue == "number" then
		Z80:write16(address.get(), value);
	elseif typeAddress == "number" and typeValue == "table" then
		Z80:write16(address, value.get());
	elseif typeAddress == "table" and typeValue == "table" then
		Z80:write16(address.get(), value.get());
	end
end

-- 输入到 I/O abstract int inport(int address)
function Z80:inport(address)

end

-- int inport(Register8 address)
function Z80:inport(address)
	return inport(address.get());
end

-- 输出到 I/O abstract void outport(int address, int value);
function Z80:outport(address, value)

end

-- void outport(Register8 address | int address, int value | Register8 value)
function Z80:outport(address, value)
	local typeAddress, typeValue = type(address), type(value)
	if typeAddress == "table" and typeValue == "number" then
		Z80:outport(address.get(), value);
	elseif typeAddress == "number" and typeValue == "table" then
		Z80:outport(address, value.get());
	elseif typeAddress == "table" and typeValue == "table" then
		Z80:outport(address.get(), value.get());
	end
end

-- 子程序 abstract int subroutine(int address)
function Z80:subroutine(address)

end

-- 无符号数变为符号数 int toSigned(int value) 
local function toSigned(value)
	return (value & 0xff);
end

-- 获取R的值 int getR()
local function getR()
	rnd = rnd * 8197 + 1;
	--return (rnd >>> 25) & 0xff;
	return (rnd >> 25) & 0xff;
end

-- 改变进位标志（8位加法）int setCy8(int acc)
local function setCy8(acc)
	return ((acc & 0x00000100) ~= 0 and {MASK_CY} or {0})[1];
end

-- 改变进位标志（16位加法）int setCy16(int acc)
local function setCy16(acc) 
	return ((acc & 0x00010000) ~= 0 and {MASK_CY} or {0})[1];
end

-- 改变进位标志（减法）int setCyS(int acc)
local function setCyS(acc)
	return ((acc & 0x80000000) ~= 0 and {MASK_CY} or {0})[1];
end

-- 改变奇偶校验/溢出标志（奇偶校验）int setP(int acc | Register8 r)
local function setP(accr)
	local typeAccr = type(accr)
	if typeAccr == "number" then 
		return parity[acc & 0xff];
	elseif typeAccr == "table" then
		return parity[r.get() & 0xff];
	end
end

-- 改变奇偶校验/溢出标志（8位加法）int setV8(int acc, int x | Register8 x, int y)
local function setV8(acc, x, y)
	local typeX = type(x)
	if typeX == "number" then
		return (((x ~ y) & 0x80) ~= 0 and {0} or {(((x ~ acc) & 0x80) ~= 0 and {MASK_PV} or {0})[1]})[1];
	elseif typeX == "table" then
		local _x = x.get();
		return (((_x ~ y) & 0x80) ~= 0 and {0} or {(((_x ~ acc) & 0x80) ~= 0 and {MASK_PV} or {0})[1]})[1];
	end
end

-- 改变奇偶校验/溢出标志（16位加法）int setV16(int acc, Register16 x, Register16 y)
local function setV16(acc, x, y)
	local _x = x.get();
	local _y = y.get();
	return (((_x ~ _y) & 0x8000) ~= 0 and {0} or {(((_x ~ acc) & 0x8000) ~= 0 and {MASK_PV} or {0})[1]})[1];
end

-- 改变奇偶校验/溢出标志（8位减法）int setV8S(int acc, int x | Register8 x, int y | Register8 y)
local function setV8S(acc, x, y)
	local typeX, typeY = type(x), type(y)
	if typeX == "number" and typeY == "number" then
		return (((x ~ y) & 0x80) ~= 0 and {(((x ~ acc) & 0x80) ~= 0 and {MASK_PV} or {0})[1]} or {0})[1];
	elseif typeX == "table" and typeY == "number" then
		local _x = x.get();
		return (((_x ~ y) & 0x80) ~= 0 and {(((_x ~ acc) & 0x80) ~= 0 and {MASK_PV} or {0})[1]} or {0})[1];
	elseif typeX == "number" and typeY == "table" then
		return (((x ~ y.get()) & 0x80) ~= 0 and {(((x ~ acc) & 0x80) ~= 0 and {MASK_PV} or {0})[1]} or {0})[1];
	end	
end

-- 改变奇偶校验/溢出标志（16位减法）int setV16S(int acc, Register16 x, Register16 y)
local function setV16S(acc, x, y)
	local _x = x.get();
	return (((_x ~ y.get()) & 0x80) ~= 0 and {(((_x ~ acc) & 0x80) ~= 0 and {MASK_PV} or {0})[1]} or {0})[1];
end

-- 更改半进位标志（8位加法）int setHC8(Register8 x | int x, int y, int cy)
local function setHC8(x, y, cy)
	local typeX = type(x) 
	if cy ~= nil then
		return ((x.get() & 0x0f) + (y & 0x0f) + cy) & 0x10;
	elseif cy == nil and typeX == "number" then
		return ((x & 0x0f) + (y & 0x0f)) & 0x10;
	elseif cy == nil and typeX == "table" then  
		return ((x.get() & 0x0f) + (y & 0x0f)) & 0x10;
	end
end


-- 更改半进位标志（8位减法）int setHC8S(Register8 x | int x, int y | Register8 y, int cy)
local function setHC8S(x, y, cy)
	local typeX, typeY = type(x), type(y)
	if cy ~= nil and typeX == "table" and typeY == "number" then
		return ((x.get() & 0x0f) - (y & 0x0f) - cy) & 0x10;
	elseif cy == nil and typeX == "number" and typeY == "number" then
		return ((x & 0x0f) - (y & 0x0f)) & 0x10;
	elseif cy == nil and typeX == "table" and typeY == "number" then
		return ((x.get() & 0x0f) - (y & 0x0f)) & 0x10;
	elseif cy == nil and typeX == "number" and typeY == "table" then
		return ((x & 0x0f) - (y.get() & 0x0f)) & 0x10;
	end 	
end

-- 更改半进位标志（16位加法）int setHC16(Register16 x, Register16 y, int cy)
local function setHC16(x, y, cy) 
	if cy ~= nil then
		return ((((x.get() & 0x0fff) + (y.get() & 0x0fff) + cy) & 0x1000) ~= 0 and {MASK_HC} or {0})[1];
	elseif cy == nil then
		return ((((x.get() & 0x0fff) + (y.get() & 0x0fff)) & 0x1000) ~= 0 and {MASK_HC} or {0})[1];
	end
end

-- 更改半进位标志（16位减法）int setHC16S(Register16 x, Register16 y, int cy)
local function setHC16S(x, y, cy)
	return ((((x.get() & 0x0fff) - (y.get() & 0x0fff) - cy) & 0x1000) ~= 0 and {MASK_HC} or {0})[1];
end

-- 改变零标志位（8位）int setZ8(int acc | Register8 r)
local function setZ8(accr)
	local typeAccr = type(accr)
	if typeAccr == "number" then
		return ((acc & 0xff) ~= 0 and {0} or {MASK_Z})[1];
	elseif typeAccr == "table" then
		return ((r.get() & 0xff) ~= 0 and {0} or {MASK_Z})[1];
	end
end

-- 改变零标志位（16位）int setZ16(int acc)
local function setZ16(acc)
	return ((acc & 0xffff) ~= 0 and {0} or {MASK_Z})[1];
end

-- 更改符号标志（8位）int setS8(int acc | Register8 r)
local function setS8(accr)
	local typeAccr = type(accr)
	if typeAccr == "number" then
		return ((acc & 0x80) ~= 0 and {MASK_S} or {0})[1];
	elseif typeAccr == "table" then
		return ((r.get() & 0x80) ~= 0 and {MASK_S} or {0})[1];
	end
end

-- 更改符号标志（16位）int setS16(int acc)
local function setS16(acc)
	return ((acc & 0x8000) ~= 0 and {MASK_S} or {0})[1];
end

--[[	
	void adc8(int n)

		adc imm
		adc (HL)
		adc (IX+d)
		adc (IY+d)

	void adc8(Register8 r)

		adc B
		adc C
		adc D
		adc E
		adc H
		adc L
		adc A
		adc IXH
		adc IXL
		adc IYH
		adc IYL
--]]

-- 根据 nr 的类型来返回不同的值:数字返回其本身,表返回 get() 方法
local function nOrReg(nr)
	local typeNr = type(nr)
	if typeN == "number" then
		return nr
	elseif typeN == "table" then
		return nr:get()
	end
end

-- void adc8(int n | Register8 r)
local function adc8(nr)
	local n = nOrReg(nr)
	local acc = a.get() + n + f.cy();
	f.set(setCy8(acc) | setV8(acc, a, n) | setHC8(a, n, f.cy()) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
		
end


--[[	void adc16(Register16 r1, Register16 r2)

		adc HL,BC
		adc HL,DE
		adc HL,HL
		adc HL,SP
--]]
local function adc16(r1, r2)
	local acc = r1.get() + r2.get() + f.cy();
	f.set(setCy16(acc) | setV16(acc, r1, r2) | setHC16(r1, r2, f.cy()) | setZ16(acc) | setS16(acc));
	r1.set(acc);
	pc = pc + length;
end

--[[	void add8(int n)

		add imm
		add (HL)
		add (IX+d)
		add (IY+d)

	void add8(Register8 r)

		add HL,BC
		add HL,DE
		add HL,HL
		add HL,SP
		add IX,BC
		add IX,DE
		add IX,IX
		add IX,SP
		add IY,BC
		add IY,DE
		add IY,IX
		add IY,SP
--]]
local function add8(nr)
	local n = nOrReg(nr)
	local acc = a.get() + n;

	f.set(setCy8(acc) | setV8(acc, a, n) | setHC8(a, n) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

--[[	void add16(Register16 r1, Register16 r2)
		add HL,BC
		add HL,DE
		add HL,HL
		add HL,SP
		add IX,BC
		add IX,DE
		add IX,IX
		add IX,SP
		add IY,BC
		add IY,DE
		add IY,IX
		add IY,SP
--]]
local function add16(r1, r2)
	local acc = r1.get() + r2.get();
	f.set(setCy16(acc) | f.pv() | setHC16(r1, r2) | f.z() | f.s());
	r1.set(acc);
	pc = pc + length;
end

--[[	void and(int n)
		and imm
		and (HL)
		and (IX+d)
		and (IY+d)

	void and(int n)

		and B
		and C
		and D
		and E
		and H
		and L
		and A
		and IXH
		and IXL
		and IYH
		and IYL
--]]
local function And(nr)
	local n = nOrReg(nr)
	local acc = a.get() & n;
	f.set(setP(acc) | MASK_HC | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

--[[	void bit(int b, int n)

		bit n, (HL)
		bit n, (IX+d)
		bit n, (IY+d)

	void bit(int b, Register8 r)

		bit n, B
		bit n, C
		bit n, D
		bit n, E
		bit n, H
		bit n, L
		bit n, A		
--]]
local function bit(b, nr)
	local n = nOrReg(nr)
	f.set(f.cy() | ((n & (1 << b)) ~= 0  and {0} or {MASK_PV})[1] | MASK_HC | ((n & (1 << b)) ~= 0 and {0} or {MASK_Z})[1] | (n & 0x80 & (1 << b)));
	pc = pc + length;

end

-- 中断或 call interrupt(int address)
local function interrupt(address)
	states = states + 7
	local s = subroutine(address);
	sp.add(-2);
	Z80:write16(sp, pc);
	pc = address;

	if(s < 0) then
		-- 通常的 call 调用
		return false;
	else
		-- 模拟的子程序
		pc = Z80:read16(sp);
		sp.add(2);
		states = states + s;
		return (s == 0);
	end
end

--[[ boolean call(int condition, int address) 
		call mn
		call NZ, mn
		call Z, mn
		call NC, mn
		call C, mn
		call PO, mn
		call PE, mn
		call P, mn
		call M, mn
--]]
local function call(condition, address)
	pc = pc + length;

	if(condition ~= 0) then
		if(interrupt(address)) then
			pc = pc - length;
			return true;
		end
	end

	return false;
end

-- ccf void ccf()
local function ccf()
	local f = Z80.f
	f.set((f.cy() ~ MASK_CY) | f.pv() | (f.cy() ~= 0 and {MASK_HC} or {0})[1] | f.z() | f.s());
	pc = pc + length;
end

--[[ void cp(int n)
		cp imm
		cp (HL)
		cp (IX+d)
		cp (IY+d)

void cp(Register8 r)

		cp B
		cp C
		cp D
		cp E
		cp H
		cp L
		cp A
		cp IXH
		cp IXL
		cp IYH
		cp IYL
--]]
local function cp(nr)
	local n = nOrReg(nr)
	local acc = a.get() - n;

	f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
	pc = pc + length;
end

-- cpd
local function cpd()
	local n = Z80:read8(hl);
	local acc = a.get() - n;

	f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
	bc.add(-1);
	hl.add(-1);
	pc = pc + length;
end 

-- cpdr
local function cpdr()
	while(~bc.isZero() and acc ~= 0) do
		local n = Z80:read8(hl);
		local acc = a.get() - n;
		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		bc.add(-1);
		hl.add(-1);
		states = states + 21;
	end 
	states = states - 5;
	pc = pc + length;
end

-- cpi private void cpi()
local function cpi()
		local n = Z80:read8(hl);
		local acc = a.get() - n;

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		bc.add(-1);
		hl.add(1);
		pc = pc + length;
end

-- cpir private void cpir()
local function cpir()
	repeat
		local n = Z80:read8(hl);
		local acc = a.get() - n;
		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));			
		bc.add(-1);
		hl.add(1);
		states = states + 21;
	until (~bc.isZero() and acc ~= 0)
	states = states - 5;
	pc = pc + length;
end

-- cpl private void cpl()
local function cpl()
	local acc = ~a.get();

	f.set(f.get() | MASK_N | MASK_HC);
	a.set(acc);
	pc = pc + length;
end

-- daa private void daa()
local function daa()

	local f0 = f.get() & (MASK_CY | MASK_N | MASK_HC)
	if f0 == 0 then	
			if(a.get() < 0x9a) then
				if((a.get() & 0x0f) < 0x0a) then
					n  = 0x00;
					cy = 0;
				else 
					n  = 0x06;
					cy = 0;
				end
			else 
				if((a.get() & 0x0f) < 0x0a) then
					n = 0x60;
					cy = MASK_CY;
				else 
					n  = 0x66;
					cy = MASK_CY;
				end
			end
			
	elseif f0 ==  MASK_CY then
			if((a.get() & 0x0f) < 0x0a) then
				n  = 0x60;
				cy = MASK_CY;
			else 
				n  = 0x66;
				cy = MASK_CY;
			end
			
	elseif f0 ==  MASK_N then
			if(a.get() < 0x9a) then
				if((a.get() & 0x0f) < 0x0a) then
					n  = 0x00;
					cy = 0;
				else 
					n  = 0xfa;
					cy = 0;
				end
			else 
				if((a.get() & 0x0f) < 0x0a) then
					n  = 0xa0;
					cy = MASK_CY;
				else
					n  = 0x9a;
					cy = MASK_CY;
				end
			end
			
	elseif f0 ==  MASK_CY | MASK_N then
			if((a.get() & 0x0f) < 0x0a)  then
				n  = 0xa0;
				cy = MASK_CY;
			else 
				n  = 0x9a;
				cy = MASK_CY;
			end
	elseif f0 == MASK_HC then
			if(a.get() < 0x9a) then
				n  = 0x06;
				cy = 0;
			else
				n  = 0x66;
				cy = MASK_CY;
			end
	elseif f0 == MASK_CY | MASK_HC then
			n  = 0x66;
			cy = MASK_CY;
	elseif f0 == MASK_N | MASK_HC then
			if(a.get() < 0x9a) then
				n  = 0xfa;
				cy = 0;
			else
				n  = 0x9a;
				cy = MASK_CY;
			end
	elseif f0 == MASK_CY | MASK_N | MASK_HC then
			n  = 0x9a;
			cy = MASK_CY;
	else
			n  = 0;
			cy = 0;
	end

		acc = a.get() + n;

		f.set(cy | f.n() | setP(acc) | setHC8(a, n) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc = pc + length;
end

--[[	void dec8_r(Register8 r)
		dec B
		dec C
		dec D
		dec E
		dec H
		dec L
		dec A
		dec IXH
		dec IXL
		dec IYH
		dec IYL
--]]
local function dec8_r(r)
	
	local acc = r.get() - 1;

	f.set(f.cy() | MASK_N | setV8S(acc, r, 1) | setHC8S(r, 1) | setZ8(acc) | setS8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void dec8_m(int address)
		
		dec (IX+d)
		dec (IY+d)

	private void dec8_m(Register16 address)

		dec (HL)
--]]
local function dec8_m(address)
	
	local address = nOrReg(address) 
	local n = Z80:read8(address);
	local acc = n - 1;

	f.set(f.cy() | MASK_N | setV8S(acc, n, 1) | setHC8S(n, 1) | setZ8(acc) | setS8(acc));
	Z80:write8(address, acc);
	pc = pc + length;
end

--[[	private void dec16(Register16 r)
		dec BC
		dec DE
		dec HL
		dec SP
		dec IX
		dec IY
--]]
local function dec16(r)
	
	r.add(-1);
	pc = pc + length;

end

-- di private void di()
local function di()
	iff = 0;
	pc = pc + length;
end

-- djnz d private void djnz(int d)
local function djnz(d)

	b.add(-1);
	if(~b.isZero()) then
		pc = pc + d;
		states = states + 5;
	end
	pc = pc + length;
end

-- ei private boolean ei()
local function ei()
	pc = pc + length;
	if(iff ~= 3) then
		iff = 3;
		restStates = restStates - states;
		return true;
	else
		return false;
	end
end

--[[ private void ex_r(Register16 r1, Register16 r2)
		ex AF, AF'
		ex DE, HL
--]]
local function ex_r(r1, r2)
	
	tmpreg16.set(r1); r1.set(r2); r2.set(tmpreg16);
	pc =  pc + length;
end

--[[	private void ex_sp(Register16 r)
		ex (SP), HL
		ex (SP), IX
		ex (SP), IY
--]]
local function ex_sp(r)
	
	local tmp  = Z80:read16(sp); Z80:write16(sp, r); r.set(tmp);
	pc = pc + length;
end

-- exx private void exx()
local function  exx()

		tmpreg16.set(bc); bc.set(bc_d); bc_d.set(tmpreg16);
		tmpreg16.set(de); de.set(de_d); de_d.set(tmpreg16);
		tmpreg16.set(hl); hl.set(hl_d); hl_d.set(tmpreg16);
		pc = pc + length;
end

-- halt private void halt()
local function halt()
	hlt = true;
	restStates = 0;
	pc = pc + length;
end

--[[	private void im(int mode)	
		im 0
		im 1
		im 2
--]]
local function im(mode)
	
		im = mode;
		pc = pc + length;
end


-- in A, (n) private void in_n(int n)
local function in_n(n)
		a.set(inport(n));
		pc = pc + length;
end 

--[[	private void in_c(Register8 r)
		in B, (C)
		in C, (C)
		in D, (C)
		in E, (C)
		in H, (C)
		in L, (C)
		in F, (C)
		in A, (C)
--]]
local function in_c(r)
	
		r.set(inport(c));
		f.set(f.cy() | setP(r) | setZ8(r) | setS8(r));
		pc = pc + length;
end

-- ind private void ind()
local function ind()
	local n = inport(c);
	Z80:write8(hl, n);
		b.add(-1);
		hl.add(-1);
		f.set(f.cy() | ((n & 0x80) ~= 0 and {MASK_N} or {0})[1] | f.pv() | f.hc() | (b.isZero() and {MASK_Z} or {0})[1] | f.s());
		pc = pc + length;
end

	
-- indr private void indr()
local function indr()

		while(~b.isZero()) do
			local n = inport(c);
			Z80:write8(hl, n);
			b.add(-1);
			hl.add(-1);
			states = states + 21;
		end
		states = states - 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc = pc + length;
end

-- ini private void ini()
local function ini()

		local n = inport(c);
		Z80:write8(hl, n);
		b.add(-1);
		hl.add(1);
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() and {MASK_Z} or {0})[1] | f.s());
		pc = pc + length;
end

-- inir private void inir()
local function inir()

	while(~b.isZero()) do
			local n = inport(c);
			Z80:write8(hl, n);
			b.add(-1);
			hl.add(1);
			states = states + 21;
	end

		states = states - 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc = pc + length;
end

--[[	private void inc8_r(Register8 r)
		inc B
		inc C
		inc D
		inc E
		inc H
		inc L
		inc A
		inc IXH
		inc IXL
		inc IYH
		inc IYL
--]]
local function inc8_r(r)
	
	local acc = r.get() + 1;

	f.set(f.cy() | setV8(acc, r, 1) | setHC8(r, 1) | setZ8(acc) | setS8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void inc8_m(int address)	
	
		int n;
		inc (IX+d)
		inc (IY+d)

		private void inc8_m(Register16 address)

		inc (HL)
--]]
local function inc8_m(address)
	local address = nOrReg(address)
	local n = Z80:read8(address);
	local acc = n + 1;

	f.set(f.cy() | setV8(acc, n, 1) | setHC8(n, 1) | setZ8(acc) | setS8(acc));
	Z80:write8(address, acc);
	pc = pc + length;
end

--[[	private void inc16(Register16 r)	
		inc BC
		inc DE
		inc HL
		inc SP
		inc IX
		inc IY
--]]
local function inc16(r)
	
		r.add(1);
		pc = pc + length;
end

--[[	private boolean jp(int condition, int address)

		jp mn
		jp NZ, mn
		jp Z, mn
		jp NC, mn
		jp C, mn
		jp PO, mn
		jp PE, mn
		jp P, mn
		jp M, mn

	private boolean jp(int condition, Register16 address)

        jp (HL)
        jp (IX)
        jp (IY)
--]]
local function jp(condition, address)
	local address = nOrReg(address)

		if(condition ~= 0) then

			local s = subroutine(address);
			local old_pc = pc;
			pc = address;

			if(s < 0) then
				return false;
			elseif(s > 0) then
				pc = Z80:read16(sp);
				sp.add(2);
				states = states + s;
				return false;
			else 
				pc = old_pc;
				return true;
			end
		else 
			pc = pc + length;
			return false;
		end
end

--[[	private void jr(int condition, int d)	
		jr d
		jr NZ, d
		jr Z, d
		jr NC, d
		jr C, d
--]]
local function jr(condition, d)
	
	if(condition ~= 0) then
			states = states + 5;
			pc = pc + d;
	end
	pc = pc + length;
end

--[[	private void ld8(Register8 r, int n)	
		ld B, n
		ld C, n
		ld D, n
		ld E, n
		ld H, n
		ld L, n
		ld A, n
		ld IXH, n
		ld IXL, n
		ld IYH, n
		ld IYL, n
		ld A, (mn)
		ld A, (BC)
		ld A, (DE)
		ld B, (HL)
		ld C, (HL)
		ld D, (HL)
		ld E, (HL)
		ld H, (HL)
		ld L, (HL)
		ld A, (HL)
		ld B, (IX+d)
		ld C, (IX+d)
		ld D, (IX+d)
		ld E, (IX+d)
		ld H, (IX+d)
		ld L, (IX+d)
		ld A, (IX+d)
		ld B, (IY+d)
		ld C, (IY+d)
		ld D, (IY+d)
		ld E, (IY+d)
		ld H, (IY+d)
		ld L, (IY+d)
		ld A, (IY+d)

	private void ld8(Register8 r1, Register8 r2)

		ld B, r
        ld C, r
        ld D, r
        ld E, r
        ld H, r
        ld L, r
        ld A, r
        ld IXH, r
        ld IXL, r
        ld IYH, r
        ld IYL, r
        ld I, A

--]]
local function ld8(r, n)
	local n = nOrReg(n)
	r.set(n);
	pc = pc + length;
end

--[[	private void ld16(Register16 r, int n)

		ld BC, mn
		ld DE, mn
		ld HL, mn
		ld IX, mn
		ld IY, mn
		ld SP, mn
		ld BC, (mn)
		ld DE, (mn)
		ld HL, (mn)
		ld IX, (mn)
		ld IY, (mn)
		ld SP, (mn)

	private void ld16(Register16 r1, Register16 r2)

		ld SP, HL
        ld SP, IX
        ld SP, IY
--]]	
local function ld16(r, nr)
	local n = nOrReg(nr)
	r.set(n);
	pc = pc + length;
end

-- ld A, I private void ld_a_i()
local function ld_a_i()
	local acc = i.get();

	f.set(f.cy() | ((iff & 0x02) ~= 0 and {0} or {MASK_PV})[1] | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

-- ld A, R private void ld_a_r()
local function ld_a_r()
	local acc = getR();

	f.set(f.cy() | ((iff & 0x02) ~= 0 and {0} or {MASK_PV})[1] | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

--[[	private void st8(int address, int n)

		ld (IX+d), n
		ld (IY+d), n

	private void st8(Register16 address, int n)

		ld (HL), n

	private void st8(int address, Register8 r)

		ld (mn), A
        ld (IX+d), r
        ld (IY+d), r

	private void st8(Register16 address, Register8 r)

		ld (BC), A
        ld (DE), A
        ld (HL), r	
--]]
local function st8(address, n)
	local address = nOrReg(address)
	local n = nOrReg(n)
	Z80:write8(address, n);
	pc = pc + length;
end

--[[	private void st16(int address, Register16 r)
		ld (mn), BC
		ld (mn), DE
		ld (mn), HL
		ld (mn), IX
		ld (mn), IY
		ld (mn), SP
--]]
local function st16(address, r)
	Z80:write16(address, r);
	pc = pc + length;
end

--	ldd private void ldd()
local function ldd()
	Z80:write8(de, Z80:read8(hl));
	de.add(-1);
	hl.add(-1);
	bc.add(-1);
	f.set(f.cy() | (~bc.isZero() and {MASK_PV} or {0})[1] | f.z() | f.s());
	pc = pc + length;
end


-- lddr private void lddr()
local function lddr()
		repeat
			Z80:write8(de, Z80:read8(hl));
			de.add(-1);
			hl.add(-1);
			bc.add(-1);
			states = states + 21;
		until(~bc.isZero());
		states = states - 5;
		f.set(f.cy() | f.z() | f.s());
		pc = pc + length;
end


-- ldi private void ldi()
local function ldi()
	Z80:write8(de, Z80:read8(hl));
	bc.add(-1);
	de.add(1);
	hl.add(1);
	f.set(f.cy() | (~bc.isZero() and {MASK_PV} or {0})[1] | f.z() | f.s());
	pc = pc + length;
end


-- ldir private void ldir()
local function ldir()
	repeat
		Z80:write8(de, Z80:read8(hl));
		bc.add(-1);
		de.add(1);
		hl.add(1);
		states = states + 21;
	until(~bc.isZero());
		states = states - 5;
		f.set(f.cy() | f.z() | f.s());
		pc = pc + length;
end

-- neg private void neg()
local function neg()
	local acc = -a.get();

	f.set(setCyS(acc) | MASK_N | setV8S(acc, 0, a) | setHC8S(0, a) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

-- nop private void nop()
local function nop()
	pc = pc + length;
end

--[[	private void or(int n)

		or imm
		or (HL)
		or (IX+d)
		or (IY+d)

	private void or(Register8 r)

		or B
        or C
        or D
        or E
        or H
        or L
        or A
        or IXH
        or IXL
        or IYH
        or IYL
--]]
local function Or(n)
	local n = nOrReg(n)
	local acc = a.get() | n;

	f.set(setP(acc) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end
		
-- out (n), A	private void out_n(int n)
local function out_n(n)
		outport(n, a);
		pc = pc + length;
end

--[[
		out (C), B
		out (C), C
		out (C), D
		out (C), E
		out (C), H
		out (C), L
		out (C), A
--]]
local function out_c(r)
	outport(c, r);
	pc = pc + length;
end

-- out (C), 0	private void out_c_0()
local function out_c_0()
	outport(c, 0);
	pc = pc + length;
end

-- outd private void outd()
local function outd()
	outport(c, Z80:read8(hl));
	b.add(-1);
	hl.add(-1);
	f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() and {MASK_Z} or {0})[1] | f.s());
	pc = pc + length;
end

-- otdr private void otdr()
local function otdr()
		while(~b.isZero()) do
			outport(c, Z80:read8(hl));
			b.add(-1);
			hl.add(-1);
			states = states + 21;
		end
		states = states - 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc = pc + length;
end

-- outi private void outi()
local function outi()
	outport(c, Z80:read8(hl));
	b.add(-1);
	hl.add(1);
	f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() and {MASK_Z} or {0})[1] | f.s());
	pc = pc + length;
end


-- otir private void otir()
local function otir()
	while(~b.isZero()) do
		outport(c, Z80:read8(hl));
		b.add(-1);
		hl.add(1);
		states = states + 21;
	end
	states = states - 5;
	f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
	pc = pc + length;
end

--[[	private void pop(Register16 r)

		pop AF
		pop BC
		pop DE
		pop HL
		pop IX
		pop IY
--]]
local function pop(r)	
	r.l.set(Z80:read8(sp));
	sp.add(1);
	r.h.set(Z80:read8(sp));
	sp.add(1);
	pc = pc + length;
end

--[[	private void push(Register16 r)
	
		push AF
		push BC
		push DE
		push HL
		push IX
		push IY
--]]
local function push(r)
	
	sp.add(-1);
	Z80:write8(sp, r.h.get());
	sp.add(-1);
	Z80:write8(sp, r.l.get());
	pc = pc + length;
end

--[[	private void res_r(int b, Register8 r)	
	
		res n, B
		res n, C
		res n, D
		res n, E
		res n, H
		res n, L
		res n, A
--]]
local function res_r(b, r)
	
		r.set(r.get() & ~(1 << b));
		pc = pc + length;
end

--[[	private void res_m_r(int b, int address, Register8 r)

		res n, (IX+d), r
		res n, (IY+d), r
--]]
local function res_m_r(b, address, r)
	
		r.set(Z80:read8(address));
		res_r(b, r);
		Z80:write8(address, r);
end

--[[	private void res_m(int b, int address)
	
		res n, (IX+d)
		res n, (IY+d)

	private void res_m(int b, Register16 address)

		res n, (HL)
--]]
local function res_m(b, address)
	
	local address = nOrReg(address)
	res_m_r(b, address, tmpreg8);
end

--[[	private void ret(int condition)

		ret
		ret NZ
		ret Z
		ret NC
		ret C
		ret PO
		ret PE
		ret P
		ret M
--]]
local function ret(condition)
	
		if(condition ~= 0) then
			pc = Z80:read16(sp);
			sp.add(2);
			states = states + 6;
		else
			pc = pc + length;
		end
end

-- reti private void reti()
local function reti()
		ret(1);
end

-- retn private void retn()
local function retn()
	iff = (iff << 1) & 0x03;
	ret(1);
end

--[[	private void rl_r(Register8 r)

		rl B
		rl C
		rl D
		rl E
		rl H
		rl L
		rl A
--]]
local function rl_r(r)
	
	local acc = (r.get() << 1) | f.cy();

	f.set(((r.get() & 0x80) ~= 0 and {MASK_CY} or {0})[1] | setP(acc) | setZ8(acc) | setS8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void rl_m_r(int address, Register8 r)	
	
		rl (IX+d), r
		rl (IY+d), r
--]]
local function rl_m_r(address, r)
	
	r.set(Z80:read8(address));
	rl_r(r);
	Z80:write8(address, r);
end

--[[	private void rl_m(int address)
	
		rl (IX+d)
		rl (IY+d)

	private void rl_m(Register16 address)

		rl (HL)
--]]
local function rl_m(address)
	local address1 = nOrReg(address) 
	rl_m_r(address1, tmpreg8);
end

-- rla private void rla()
local function rla()
	local acc = (a.get() << 1) | f.cy();

	f.set(((a.get() & 0x80) ~= 0 and {MASK_CY} or {0})[1] | f.pv() | f.z() | f.s());
	a.set(acc);
	pc = pc + length;
end

--[[	private void rlc_r(Register8 r)

		rlc B
		rlc C
		rlc D
		rlc E
		rlc H
		rlc L
		rlc A
--]]
local function rlc_r(r)
	
	local acc = (r.get() << 1) | ((r.get() & 0x80) ~= 0 and {0x01} or {0})[1];

		f.set(((r.get() & 0x80) ~= 0 and {MASK_CY} or {0})[1] | setP(acc) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc = pc + length;
end

--[[	private void rlc_m_r(int address, Register8 r)

		rlc (IX+d), r
		rlc (IY+d), r
--]]
local function rlc_m_r(address, r)
	
		r.set(Z80:read8(address));
		rlc_r(r);
		Z80:write8(address, r);
end

--[[	private void rlc_m(int address)

		rlc (IX+d)
		rlc (IY+d)

	private void rlc_m(Register16 address)

		rlc (HL)
--]]
local function rlc_m(address)
	local address1 = nOrReg(address)	
	rlc_m_r(address1, tmpreg8);
end


-- rlca`private void rlca()
local function rlca()
	local acc = (a.get() << 1) | ((a.get() & 0x80) ~= 0 and {0x01} or {0})[1];

	f.set(((a.get() & 0x80) ~= 0 and {MASK_CY} or {0})[1] | f.pv() | f.z() | f.s());
	a.set(acc);
	pc = pc + length;
end

-- rld private void rld()
local function rld()	
	--local acc = (a.get() & 0xf0) | (Z80:read8(hl) >>> 4);
	local acc = (a.get() & 0xf0) | (Z80:read8(hl) >> 4);

	Z80:write8(hl, (Z80:read8(hl) << 4) | (a.get() & 0x0f));
	f.set(f.cy() | setP(acc) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

--[[	private void rr_r(Register8 r)	
	
		rr B
		rr C
		rr D
		rr E
		rr H
		rr L
		rr A
--]]
local function rr_r(r)
	
	--local acc = (r.get() >>> 1) | (f.cy() = 0 and {0x80} or {0})[1];
	local acc = (r.get() >> 1) | (f.cy() ~= 0 and {0x80} or {0})[1];

		f.set((r.get() & 0x01) | setP(acc) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc = pc + length;
end

--[[	private void rr_m_r(int address, Register8 r)

		rr (IX+d), r
		rr (IY+d), r
--]]
local function rr_m_r(address, r)
	r.set(Z80:read8(address));
	rr_r(r);
	Z80:write8(address, r);
end

--[[	private void rr_m(int address)

		rr (IX+d)
		rr (IY+d)

	private void rr_m(Register16 address)

		rr (HL)
--]]
local function rr_m(address)
	local address1 = nOrReg(address)
	rr_m_r(address, tmpreg8);
end

-- rra private void rra()
local function rra()
	--local acc = (a.get() >>> 1) | (f.cy() = 0 and {0x80} or {0})[1];
	local acc = (a.get() >> 1) | (f.cy() ~= 0 and {0x80} or {0})[1];

		f.set((a.get() & 0x01) | f.pv() | f.z() | f.s());
		a.set(acc);
		pc = pc + length;
end

--[[	private void rrc_r(Register8 r)

		rrc B
		rrc C
		rrc D
		rrc E
		rrc H
		rrc L
		rrc A
--]]
local function rrc_r(r)
	
	--local acc = (r.get() >>> 1) | ((r.get() & 0x01) = 0 and {0x80} or {0})[1];
	local acc = (r.get() >> 1) | ((r.get() & 0x01) ~= 0 and {0x80} or {0})[1];

	f.set((r.get() & 0x01) | setP(acc) | setZ8(acc) | setS8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void rrc_m_r(int address, Register8 r)

		rrc (IX+d), r
		rrc (IY+d), r
--]]
local function rrc_m_r(address, r)
	
	r.set(Z80:read8(address));
	rrc_r(r);
	Z80:write8(address, r);
end

--[[	private void rrc_m(int address)

		rrc (IX+d)
		rrc (IY+d)

	private void rrc_m(Register16 address)

		rrc (HL)

--]]
local function rrc_m(address)
	local address1 = nOrReg(address)
	rrc_m_r(address1, tmpreg8);
end

-- rrca private void rrca()
local function rrca()
	--local acc = (a.get() >>> 1) | ((a.get() & 0x01) = 0 and {0x80} or {0})[1];
	local acc = (a.get() >> 1) | ((a.get() & 0x01) ~= 0 and {0x80} or {0})[1];

	f.set((a.get() & 0x01) | f.pv() | f.z() | f.s());
	a.set(acc);
	pc = pc + length;
end

-- rrd private void rrd()
local function rrd()
	local acc = (a.get() & 0xf0) | (Z80:read8(hl) & 0x0f);

	--Z80:write8(hl, (Z80:read8(hl) >>> 4) | (a.get() << 4));
	Z80:write8(hl, (Z80:read8(hl) >> 4) | (a.get() << 4));

	f.set(f.cy() | setP(acc) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

--[[	private void rst(int address)

		rst 0x00
		rst 0x08
		rst 0x10
		rst 0x18
		rst 0x20
		rst 0x28
		rst 0x30
		rst 0x38
--]]
local function rst(address)
	call(1, address);
end

--[[	private void sbc8(int n)

		sbc imm
		sbc (HL)
		sbc (IX+d)
		sbc (IY+d)

	private void sbc8(Register8 r)

		sbc B
        sbc C
        sbc D
        sbc E
        sbc H
        sbc L
        sbc A
        sbc IXH
        sbc IXL
        sbc IYH
        sbc IYL
--]]
local function sbc8(nr)
	
	local n = nOrReg(nr)
	local acc = a.get() - n - f.cy();

	f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n, f.cy()) | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

--[[	private void sbc16(Register16 r1, Register16 r2)

		sbc HL,BC
		sbc HL,DE
		sbc HL,HL
		sbc HL,SP
--]]
local function sbc16(r1, r2)
	
	local acc = r1.get() - r2.get() - f.cy();

	f.set(setCyS(acc) | MASK_N | setV16S(acc, r1, r2) | setHC16S(r1, r2, f.cy()) | setZ16(acc) | setS16(acc));
	r1.set(acc);
	pc = pc + length;
end

-- scf private void scf()
local function scf()
	f.set(f.get() | MASK_CY);
	pc = pc + length;
end

--[[	private void set_r(int n, Register8 r)

		set n, B
		set n, C
		set n, D
		set n, E
		set n, H
		set n, L
		set n, A
--]]
function set_r(n, r)
	
	r.set(r.get() | (1 << n));
	pc = pc + length;
end

--[[	private void set_m_r(int n, int address, Register8 r)

		set n, (IX+d), r
		set n, (IY+d), r
--]]
local function set_m_r(n, address, r)
	
	r.set(Z80:read8(address));
	set_r(n, r);
	Z80:write8(address, r);
end

--[[	private void set_m(int n, int address)

		set n, (IX+d)
		set n, (IY+d)

	private void set_m(int n, Register16 address)

		set n, (HL)
--]]
local function set_m(n, address)
	local address1 = nOrReg(address)
	set_m_r(n, address1, tmpreg8);
end

--[[	private void sla_r(Register8 r)

		sla B
		sla C
		sla D
		sla E
		sla H
		sla L
		sla A
--]]
local function sla_r(r)
	local acc = r.get() << 1;

	f.set(((r.get() & 0x80) ~= 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void sla_m_r(int address, Register8 r)

		sla (HL), r
		sla (IX+d), r
		sla (IY+d), r
--]]
local function sla_m_r(address, r)
	
	r.set(Z80:read8(address));
	sla_r(r);
	Z80:write8(address, r);
end

--[[	private void sla_m(int address)

		sla (HL)
		sla (IX+d)
		sla (IY+d)

	private void sla_m(Register16 address)

		sla (HL)
--]]
local function sla_m(address)
	local address1 = nOrReg(address)
	sla_m_r(address1, tmpreg8);
end

--[[	private void sll_r(Register8 r)

		sll B
		sll C
		sll D
		sll E
		sll H
		sll L
		sll A
--]]
local function sll_r(r)
	
	local acc = (r.get() << 1) | 1;

	f.set(((r.get() & 0x80) ~= 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void sll_m_r(int address, Register8 r)

		sll (IX+d), r
		sll (IY+d), r
--]]
local function sll_m_r(address, r)
	
	r.set(Z80:read8(address));
	sll_r(r);
	Z80:write8(address, r);
end

--[[	private void sll_m(int address)

		sll (IX+d)
		sll (IY+d)

	private void sll_m(Register16 address)

		sll (HL)
--]]
local function sll_m(address)
	local address1 = nOrReg(address)
	sll_m_r(address, tmpreg8);
end

--[[	private void sra_r(Register8 r)

		sra B
		sra C
		sra D
		sra E
		sra H
		sra L
		sra A
--]]
local function sra_r(r)
	--local acc = (r.get() >>> 1) | (r.get() & 0x80);
	local acc = (r.get() >> 1) | (r.get() & 0x80);

	f.set(((r.get() & 0x01) ~= 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
	r.set(acc);
	pc = pc + length;
end

--[[	private void sra_m_r(int address, Register8 r)

		sra (IX+d), r
		sra (IY+d), r
--]]
local function sra_m_r(address, r)
	r.set(Z80:read8(address));
	sra_r(r);
	Z80:write8(address, r);
end

--[[	private void sra_m(int address)

		sra (IX+d)
		sra (IY+d)

	private void sra_m(Register16 address)

		sra (HL)
--]]
local function sra_m(address)
	local address1 = nOrReg(address)
	sra_m_r(address1, tmpreg8);
end

--[[ 	private void srl_r(Register8 r)

		srl B
		srl C
		srl D
		srl E
		srl H
		srl L
		srl A
--]]
local function srl_r(r)
	--local acc = r.get() >>> 1;
	local acc = r.get() >> 1;

		f.set(((r.get() & 0x01) ~= 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
		r.set(acc);
		pc = pc + length;
end

--[[	private void srl_m_r(int address, Register8 r)

		srl (IX+d), r
		srl (IY+d), r
--]]
local function srl_m_r(address, r)
	
	r.set(Z80:read8(address));
	srl_r(r);
	Z80:write8(address, r);
end

--[[	private void srl_m(int address)

		srl (IX+d)
		srl (IY+d)

	private void srl_m(Register16 address)

		srl (HL)
--]]
local function srl_m(address)
	local address1 = nOrReg(address)
	srl_m_r(address, tmpreg8);
end

--[[	private void sub8(int n)

		sub imm
		sub (HL)
		sub (IX+d)
		sub (IY+d)

	private void sub8(Register8 r)

		sub B
        sub C
        sub D
        sub E
        sub H
        sub L
        sub A
        sub IXH
        sub IXL
--]]
local function sub8(nr)
	local n = nOrReg(nr)
		local acc = a.get() - n;

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc = pc + length;
end

--[[	private void xor(int n)

		xor imm
		xor (HL)
		xor (IX+d)
		xor (IY+d)

	private void xor(Register8 r)

		xor B
        xor C
        xor D
        xor E
        xor H
        xor L
        xor A
        xor IXH
        xor IXL
        xor IYH
        xor IYL
--]]
local function Xor(nr)
	local n = nOrReg(nr)
	local acc = a.get() ~ n;

		f.set(setP(acc) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc = pc + length;
end

-- 为了获取（XX）private int fetchXX()
local function fetchXX()
		local op = Z80:read8(pc);

		length = lengthXX[op];
		states = statesXX[op];
		return op;
end

-- 获取(CB xx) private int fetchCBXX()
local function fetchCBXX()
	local op = Z80:read8(pc);

	length = lengthCBXX[op];
	states = statesCBXX[op];
	return op;
end

	
-- 获取 (DD xx) private int fetchDDXX()
local function fetchDDXX()
	local op = Z80:read8(pc);

	length = lengthDDXX[op];
	states = statesDDXX[op];
	return op;
end

-- 获取 (DD CB xx) private int fetchDDCBXX()
local function fetchDDCBXX()
	local op = Z80:read8((pc + 2) & 0xffff);

	length = lengthDDCBXX[op];
	states = statesDDCBXX[op];
	return op;
end

-- 获取 (ED xx) private int fetchEDXX()
local function fetchEDXX()
	local op = Z80:read8(pc);

	length = lengthEDXX[op];
	states = statesEDXX[op];
	return op;
end

-- 获取 (FD xx) private int fetchFDXX()
local function fetchFDXX()
	return fetchDDXX();
end

-- 获取 (FD CB xx) private int fetchFDCBXX()
local function fetchFDCBXX()
	return fetchDDCBXX();
end

-- 获取内存 (8bit) private int mem8(int address | Register16 address)
local function mem8(address)
	local address1 = nOrReg(address)
	return Z80:read8(address1);
end

--  获取内存 (16bit) private int mem16(int address)
local function mem16(address)
	return Z80:read16(address);
end

-- 获取即时 (8bit) private int imm8()
local function imm8()
	return Z80:read8(pc + 1);
end

-- 获取即时 (16bit) private int imm16()
local function imm16()
	return Z80:read16(pc + 1);
end

-- 获得一个相对地址	private int dis()
local function dis()
	return toSigned(Z80:read8(pc + 1));
end

-- 发送RESET信号 public boolean reset()
function Z80:reset()
		im = 0;
		iff = 0;
		hlt = false;
		af.set(0xffff);
		bc.set(0xffff);
		de.set(0xffff);
		hl.set(0xffff);
		ix.set(0xffff);
		iy.set(0xffff);
		af_d.set(0xffff);
		bc_d.set(0xffff);
		de_d.set(0xffff);
		hl_d.set(0xffff);
		sp.set(0xffff);
		i.set(0xff);
		pc = 0;
		restStates = 0;

		return true;
end

-- 发送INT信号（IM1） public boolean int1()
function Z80:int1()
	if(~(im == 1 and iff == 3)) then
		return false;
	end

	hlt = false;
	iff = 0;
	states = states - 13;

	interrupt(0x38);
	return true;
end

-- 输出跟踪 private void disassemble()
local function disassemble()
		log(String.format(
		"%c%c%c%c%c%c(%02x) A=%02x BC=%04x DE=%04x HL=%04x SP=%04x PC=%04x %s" + System.getProperty("line.separator") +
		"%c%c%c%c%c%c(%02x) A'%02x BC'%04x DE'%04x HL'%04x IX=%04x IY=%04x %s" + System.getProperty("line.separator") +
		"%dclocks" + System.getProperty("line.separator"),
		((f.get() & 0x80) ~= 0 and {'S'} or {'-'})[1],
		((f.get() & 0x40) ~= 0 and {'Z'} or {'-'})[1],
		((f.get() & 0x10) ~= 0 and {'H'} or {'-'})[1],
		((f.get() & 0x04) ~= 0 and {'P'} or {'-'})[1],
		((f.get() & 0x02) ~= 0 and {'N'} or {'-'})[1],
		((f.get() & 0x01) ~= 0 and {'C'} or {'-'})[1],
		f.get(),
		a.get(),
		bc.get(),
		de.get(),
		hl.get(),
		sp.get(),
		pc,
		Z80Disassembler.disassemble( { Z80:read8(pc + 0), Z80:read8(pc + 1), Z80:read8(pc + 2), Z80:read8(pc + 3), Z80:read8(pc + 4) }),
		((af_d.l.get() & 0x80) ~= 0 and {'S'} or {'-'})[1],
		((af_d.l.get() & 0x40) ~= 0 and {'Z'} or {'-'})[1],
		((af_d.l.get() & 0x10) ~= 0 and {'H'} or {'-'})[1],
		((af_d.l.get() & 0x04) ~= 0 and {'P'} or {'-'})[1],
		((af_d.l.get() & 0x02) ~= 0 and {'N'} or {'-'})[1],
		((af_d.l.get() & 0x01) ~= 0 and {'C'} or {'-'})[1],
		af_d.l.get(),
		af_d.h.get(),
		bc_d.get(),
		de_d.get(),
		hl_d.get(),
		ix.get(),
		iy.get(),
		(hlt and {"HALT"} or {""})[1],
		0
		));
end
--]]

-- 执行 int execute(int execute_states)
function Z80:execute(execute_state)
	restStates = execute_states;
	executeStates = restStates

	if (hlt) then 
		if (trace) then
			Z80:disassemble();
		end
		restStates = 0;
		return 0
	end

	while (restStates > 0) do
	--repeat 	
		
		if (trace) then Z80:disassemble(); end

		local f1 = fetchXX()

		if 	   f1 == 0x00 then nop();		-- nop 
		elseif f1 == 0x01 then ld16(bc, imm16());		-- ld BC, mn
		elseif f1 == 0x02 then st8(bc, a);		-- ld (BC), A 
		elseif f1 == 0x03 then inc16(bc);		-- inc BC
		elseif f1 == 0x04 then inc8_r(b);		-- inc B 
		elseif f1 == 0x05 then dec8_r(b);		-- dec B
		elseif f1 == 0x06 then ld8(b, imm8());		-- ld B, n
		elseif f1 == 0x07 then rlca();		-- rlca

		elseif f1 == 0x08 then ex_r(af, af_d);		-- ex AF, AF'
		elseif f1 == 0x09 then add16(hl, bc);		-- add HL, BC
		elseif f1 == 0x0a then ld8(a, mem8(bc));		--ld A, (BC)
		elseif f1 == 0x0b then dec16(bc);		-- dec BC
		elseif f1 == 0x0c then inc8_r(c);		-- inc C
        elseif f1 == 0x0d then dec8_r(c);		-- dec C
		elseif f1 == 0x0e then ld8(c, imm8());		-- ld C, n
		elseif f1 == 0x0f then rrca();		-- rrca

		elseif f1 == 0x10 then djnz(dis());		-- djnz e
		elseif f1 == 0x11 then ld16(de, imm16());		-- ld DE, mn
		elseif f1 == 0x12 then st8(de, a);		-- ld (DE), A
		elseif f1 == 0x13 then inc16(de);		-- inc DE
		elseif f1 == 0x14 then inc8_r(d);		-- inc D
		elseif f1 == 0x15 then dec8_r(d);		-- dec D
		elseif f1 == 0x16 then ld8(d, imm8());		-- ld D, n
		elseif f1 == 0x17 then rla();		-- rla
	
		elseif f1 == 0x18 then jr(1, dis());		-- jr e
		elseif f1 == 0x19 then add16(hl, de);		-- add HL, DE
		elseif f1 == 0x1a then ld8(a, mem8(de));		-- ld A, (DE)
		elseif f1 == 0x1b then dec16(de);		-- dec DE
		elseif f1 == 0x1c then inc8_r(e);		-- inc E
        elseif f1 == 0x1d then dec8_r(e);		-- dec E
		elseif f1 == 0x1e then ld8(e, imm8());		-- ld E, n
		elseif f1 == 0x1f then rra();		-- rra

		elseif f1 == 0x20 then jr(f.nz(), dis());  	-- jr NZ, e  
		elseif f1 == 0x21 then ld16(hl, imm16());  	-- ld HL, mn  
		elseif f1 == 0x22 then st16(imm16(), hl);  	-- ld (mn), HL  
		elseif f1 == 0x23 then inc16(hl);          	-- inc HL  
		elseif f1 == 0x24 then inc8_r(h);          	-- inc H  
		elseif f1 == 0x25 then dec8_r(h);          	-- dec H  
		elseif f1 == 0x26 then ld8(h, imm8());     	-- ld H, n  
		elseif f1 == 0x27 then daa();              	-- daa  

		elseif f1 == 0x28 then jr(f.z(), dis());          	-- jr Z, e  
		elseif f1 == 0x29 then add16(hl, hl);             	-- add HL, HL  
		elseif f1 == 0x2a then ld16(hl, mem16(imm16()));  	-- ld HL, (mn)  
		elseif f1 == 0x2b then dec16(hl);                 	-- dec HL  
		elseif f1 == 0x2c then inc8_r(l);                 	-- inc L  
		elseif f1 == 0x2d then dec8_r(l);                 	-- dec L  
		elseif f1 == 0x2e then ld8(l, imm8());            	-- ld L, n  
		elseif f1 == 0x2f then cpl();                     	-- cpl  

		elseif f1 == 0x30 then jr(f.ncy(), dis());  	-- jr NC, e  
		elseif f1 == 0x31 then ld16(sp, imm16());   	-- ld SP, mn  
		elseif f1 == 0x32 then st8(imm16(), a);     	-- ld (mn), A  
		elseif f1 == 0x33 then inc16(sp);           	-- inc SP  
		elseif f1 == 0x34 then inc8_m(hl);          	-- inc (HL)  
		elseif f1 == 0x35 then dec8_m(hl);          	-- dec (HL)  
		elseif f1 == 0x36 then st8(hl, imm8());     	-- ld (HL), n  
		elseif f1 == 0x37 then scf();               	-- scf  

		elseif f1 == 0x38 then jr(f.cy(), dis());      	-- jr C, e  
		elseif f1 == 0x39 then add16(hl, sp);          	-- add HL, SP  
		elseif f1 == 0x3a then ld8(a, mem8(imm16()));  	-- ld A, (mn)  
		elseif f1 == 0x3b then dec16(sp);              	-- dec SP  
		elseif f1 == 0x3c then inc8_r(a);              	-- inc A  
		elseif f1 == 0x3d then dec8_r(a);              	-- dec A  
		elseif f1 == 0x3e then ld8(a, imm8());         	-- ld A, n  
		elseif f1 == 0x3f then ccf();                  	-- ccf  

		elseif f1 == 0x40 then ld8(b, b);         	-- ld B, B  
		elseif f1 == 0x41 then ld8(b, c);         	-- ld B, C  
		elseif f1 == 0x42 then ld8(b, d);         	-- ld B, D  
		elseif f1 == 0x43 then ld8(b, e);         	-- ld B, E  
		elseif f1 == 0x44 then ld8(b, h);         	-- ld B, H  
		elseif f1 == 0x45 then ld8(b, l);         	-- ld B, L  
		elseif f1 == 0x46 then ld8(b, mem8(hl));  	-- ld B, (HL)  
		elseif f1 == 0x47 then ld8(b, a);         	-- ld B, A  

		elseif f1 == 0x48 then ld8(c, b);         	-- ld C, B  
		elseif f1 == 0x49 then ld8(c, c);         	-- ld C, C  
		elseif f1 == 0x4a then ld8(c, d);         	-- ld C, D  
		elseif f1 == 0x4b then ld8(c, e);         	-- ld C, E  
		elseif f1 == 0x4c then ld8(c, h);         	-- ld C, H  
		elseif f1 == 0x4d then ld8(c, l);         	-- ld C, L  
		elseif f1 == 0x4e then ld8(c, mem8(hl));  	-- ld C, (HL)  
		elseif f1 == 0x4f then ld8(c, a);         	-- ld C, A  

		elseif f1 == 0x50 then ld8(d, b);         	-- ld D, B  
		elseif f1 == 0x51 then ld8(d, c);         	-- ld D, C  
		elseif f1 == 0x52 then ld8(d, d);         	-- ld D, D  
		elseif f1 == 0x53 then ld8(d, e);         	-- ld D, E  
		elseif f1 == 0x54 then ld8(d, h);         	-- ld D, H  
		elseif f1 == 0x55 then ld8(d, l);         	-- ld D, L  
		elseif f1 == 0x56 then ld8(d, mem8(hl));  	-- ld D, (HL)  
		elseif f1 == 0x57 then ld8(d, a);         	-- ld D, A  

		elseif f1 == 0x58 then ld8(e, b);         	-- ld E, B  
		elseif f1 == 0x59 then ld8(e, c);         	-- ld E, C  
		elseif f1 == 0x5a then ld8(e, d);         	-- ld E, D  
		elseif f1 == 0x5b then ld8(e, e);         	-- ld E, E  
		elseif f1 == 0x5c then ld8(e, h);         	-- ld E, H  
		elseif f1 == 0x5d then ld8(e, l);         	-- ld E, L  
		elseif f1 == 0x5e then ld8(e, mem8(hl));  	-- ld E, (HL)  
		elseif f1 == 0x5f then ld8(e, a);         	-- ld E, A  

		elseif f1 == 0x60 then ld8(h, b);         	-- ld H, B  
		elseif f1 == 0x61 then ld8(h, c);         	-- ld H, C  
		elseif f1 == 0x62 then ld8(h, d);         	-- ld H, D  
		elseif f1 == 0x63 then ld8(h, e);         	-- ld H, E  
		elseif f1 == 0x64 then ld8(h, h);         	-- ld H, H  
		elseif f1 == 0x65 then ld8(h, l);         	-- ld H, L  
		elseif f1 == 0x66 then ld8(h, mem8(hl));  	-- ld H, (HL)  
		elseif f1 == 0x67 then ld8(h, a);         	-- ld H, A  

		elseif f1 == 0x68 then ld8(l, b);         	-- ld L, B  
		elseif f1 == 0x69 then ld8(l, c);         	-- ld L, C  
		elseif f1 == 0x6a then ld8(l, d);         	-- ld L, D  
		elseif f1 == 0x6b then ld8(l, e);         	-- ld L, E  
		elseif f1 == 0x6c then ld8(l, h);         	-- ld L, H  
		elseif f1 == 0x6d then ld8(l, l);         	-- ld L, L  
		elseif f1 == 0x6e then ld8(l, mem8(hl));  	-- ld L, (HL)  
		elseif f1 == 0x6f then ld8(l, a);         	-- ld L, A  

		elseif f1 == 0x70 then st8(hl, b);  	-- ld (HL), B  
		elseif f1 == 0x71 then st8(hl, c);  	-- ld (HL), C  
		elseif f1 == 0x72 then st8(hl, d);  	-- ld (HL), D  
		elseif f1 == 0x73 then st8(hl, e);  	-- ld (HL), E  
		elseif f1 == 0x74 then st8(hl, h);  	-- ld (HL), H  
		elseif f1 == 0x75 then st8(hl, l);  	-- ld (HL), L  
		elseif f1 == 0x76 then halt(); return 1;	-- halt  
		elseif f1 == 0x77 then st8(hl, a);  	-- ld (HL), A  

		elseif f1 == 0x78 then ld8(a, b);         	-- ld A, B  
		elseif f1 == 0x79 then ld8(a, c);         	-- ld A, C  
		elseif f1 == 0x7a then ld8(a, d);         	-- ld A, D  
		elseif f1 == 0x7b then ld8(a, e);         	-- ld A, E  
		elseif f1 == 0x7c then ld8(a, h);         	-- ld A, H  
		elseif f1 == 0x7d then ld8(a, l);         	-- ld A, L  
		elseif f1 == 0x7e then ld8(a, mem8(hl));  	-- ld A, (HL)  
		elseif f1 == 0x7f then ld8(a, a);         	-- ld A, A  

		elseif f1 == 0x80 then add8(b);         	-- add B  
		elseif f1 == 0x81 then add8(c);         	-- add C  
		elseif f1 == 0x82 then add8(d);         	-- add D  
		elseif f1 == 0x83 then add8(e);         	-- add E  
		elseif f1 == 0x84 then add8(h);         	-- add H  
		elseif f1 == 0x85 then add8(l);         	-- add L  
		elseif f1 == 0x86 then add8(mem8(hl));  	-- add (HL)  
		elseif f1 == 0x87 then add8(a);         	-- add A  

		elseif f1 == 0x88 then adc8(b);         	-- adc B  
		elseif f1 == 0x89 then adc8(c);         	-- adc C  
		elseif f1 == 0x8a then adc8(d);         	-- adc D  
		elseif f1 == 0x8b then adc8(e);         	-- adc E  
		elseif f1 == 0x8c then adc8(h);         	-- adc H  
		elseif f1 == 0x8d then adc8(l);         	-- adc L  
		elseif f1 == 0x8e then adc8(mem8(hl));  	-- adc (HL)  
		elseif f1 == 0x8f then adc8(a);         	-- adc A  

		elseif f1 == 0x90 then sub8(b);         	-- sub B  
		elseif f1 == 0x91 then sub8(c);         	-- sub C  
		elseif f1 == 0x92 then sub8(d);         	-- sub D  
		elseif f1 == 0x93 then sub8(e);         	-- sub E  
		elseif f1 == 0x94 then sub8(h);         	-- sub H  
		elseif f1 == 0x95 then sub8(l);         	-- sub L  
		elseif f1 == 0x96 then sub8(mem8(hl));  	-- sub (HL)  
		elseif f1 == 0x97 then sub8(a);         	-- sub A  

		elseif f1 == 0x98 then sbc8(b);         	-- sbc B  
		elseif f1 == 0x99 then sbc8(c);         	-- sbc C  
		elseif f1 == 0x9a then sbc8(d);         	-- sbc D  
		elseif f1 == 0x9b then sbc8(e);         	-- sbc E  
		elseif f1 == 0x9c then sbc8(h);         	-- sbc H  
		elseif f1 == 0x9d then sbc8(l);         	-- sbc L  
		elseif f1 == 0x9e then sbc8(mem8(hl));  	-- sbc (HL)  
		elseif f1 == 0x9f then sbc8(a);         	-- sbc A  

		elseif f1 == 0xa0 then And(b);         	-- and B  
		elseif f1 == 0xa1 then And(c);         	-- and C  
		elseif f1 == 0xa2 then And(d);         	-- and D  
		elseif f1 == 0xa3 then And(e);         	-- and E  
		elseif f1 == 0xa4 then And(h);         	-- and H  
		elseif f1 == 0xa5 then And(l);         	-- and L  
		elseif f1 == 0xa6 then And(mem8(hl));  	-- and (HL)  
		elseif f1 == 0xa7 then And(a);         	-- and A  

		elseif f1 == 0xa8 then Xor(b);         	-- xor B  
		elseif f1 == 0xa9 then Xor(c);         	-- xor C  
		elseif f1 == 0xaa then Xor(d);         	-- xor D  
		elseif f1 == 0xab then Xor(e);         	-- xor E  
		elseif f1 == 0xac then Xor(h);         	-- xor H  
		elseif f1 == 0xad then Xor(l);         	-- xor L  
		elseif f1 == 0xae then Xor(mem8(hl));  	-- xor (HL)  
		elseif f1 == 0xaf then Xor(a);         	-- xor A  

		elseif f1 == 0xb0 then Or(b);         	-- or B  
		elseif f1 == 0xb1 then Or(c);         	-- or C  
		elseif f1 == 0xb2 then Or(d);         	-- or D  
		elseif f1 == 0xb3 then Or(e);         	-- or E  
		elseif f1 == 0xb4 then Or(h);         	-- or H  
		elseif f1 == 0xb5 then Or(l);         	-- or L  
		elseif f1 == 0xb6 then Or(mem8(hl));  	-- or (HL)  
		elseif f1 == 0xb7 then Or(a);         	-- or A  

		elseif f1 == 0xb8 then cp(b);         	-- cp B  
		elseif f1 == 0xb9 then cp(c);         	-- cp C  
		elseif f1 == 0xba then cp(d);         	-- cp D  
		elseif f1 == 0xbb then cp(e);         	-- cp E  
		elseif f1 == 0xbc then cp(h);         	-- cp H  
		elseif f1 == 0xbd then cp(l);         	-- cp L  
		elseif f1 == 0xbe then cp(mem8(hl));  	-- cp (HL)  
		elseif f1 == 0xbf then cp(a);         	-- cp A  

		elseif f1 == 0xc0 then ret(f.nz());            	-- ret NZ  
		elseif f1 == 0xc1 then pop(bc);                	-- pop BC  
		elseif f1 == 0xc2 then jp(f.nz(), imm16());    	-- jp NZ, mn  
		elseif f1 == 0xc3 then jp(1, imm16());         	-- jp mn  
		elseif f1 == 0xc4 then call(f.nz(), imm16());  	-- call NZ, mn  
		elseif f1 == 0xc5 then push(bc);               	-- push BC  
		elseif f1 == 0xc6 then add8(imm8());           	-- add n  
		elseif f1 == 0xc7 then rst(0x00);              	-- rst 00H  

		elseif f1 == 0xc8 then ret(f.z());		-- ret Z
		elseif f1 == 0xc9 then ret(1);		-- ret
		elseif f1 == 0xca then jp(f.z(), imm16());		-- jp Z, mn		
		elseif f1 == 0xcb then
			pc = pc + 1
			local f11 = fetchCBXX()
			if     f11 == 0x00 then rlc_r(b);		-- rlc B
			elseif f11 == 0x01 then rlc_r(c);		-- rlc C
			elseif f11 == 0x02 then rlc_r(d);		-- rlc D
		    
			elseif f11 == 0x03 then rlc_r(e);   	 -- rlc E  
			elseif f11 == 0x04 then rlc_r(h);   	 -- rlc H  
			elseif f11 == 0x05 then rlc_r(l);   	 -- rlc L  
			elseif f11 == 0x06 then rlc_m(hl);  	 -- rlc (HL)  
			elseif f11 == 0x07 then rlc_r(a);   	 -- rlc A  

			elseif f11 == 0x08 then rrc_r(b);   	 -- rrc B  
			elseif f11 == 0x09 then rrc_r(c);   	 -- rrc C  
			elseif f11 == 0x0a then rrc_r(d);   	 -- rrc D  
			elseif f11 == 0x0b then rrc_r(e);   	 -- rrc E  
			elseif f11 == 0x0c then rrc_r(h);   	 -- rrc H  
			elseif f11 == 0x0d then rrc_r(l);   	 -- rrc L  
			elseif f11 == 0x0e then rrc_m(hl);  	 -- rrc (HL)  
			elseif f11 == 0x0f then rrc_r(a);   	 -- rrc A  

			elseif f11 == 0x10 then rl_r(b);   	 -- rl B  
			elseif f11 == 0x11 then rl_r(c);   	 -- rl C  
			elseif f11 == 0x12 then rl_r(d);   	 -- rl D  
			elseif f11 == 0x13 then rl_r(e);   	 -- rl E  
			elseif f11 == 0x14 then rl_r(h);   	 -- rl H  
			elseif f11 == 0x15 then rl_r(l);   	 -- rl L  
			elseif f11 == 0x16 then rl_m(hl);  	 -- rl (HL)  
			elseif f11 == 0x17 then rl_r(a);   	 -- rl A  

			elseif f11 == 0x18 then rr_r(b);   	 -- rr B  
			elseif f11 == 0x19 then rr_r(c);   	 -- rr C  
			elseif f11 == 0x1a then rr_r(d);   	 -- rr D  
			elseif f11 == 0x1b then rr_r(e);   	 -- rr E  
			elseif f11 == 0x1c then rr_r(h);   	 -- rr H  
			elseif f11 == 0x1d then rr_r(l);   	 -- rr L  
			elseif f11 == 0x1e then rr_m(hl);  	 -- rr (HL)  
			elseif f11 == 0x1f then rr_r(a);   	 -- rr A  

			elseif f11 == 0x20 then sla_r(b);   	 -- sla B  
			elseif f11 == 0x21 then sla_r(c);   	 -- sla C  
			elseif f11 == 0x22 then sla_r(d);   	 -- sla D  
			elseif f11 == 0x23 then sla_r(e);   	 -- sla E  
			elseif f11 == 0x24 then sla_r(h);   	 -- sla H  
			elseif f11 == 0x25 then sla_r(l);   	 -- sla L  
			elseif f11 == 0x26 then sla_m(hl);  	 -- sla (HL)  
			elseif f11 == 0x27 then sla_r(a);   	 -- sla A  

			elseif f11 == 0x28 then sra_r(b);   	 -- sra B  
			elseif f11 == 0x29 then sra_r(c);   	 -- sra C  
			elseif f11 == 0x2a then sra_r(d);   	 -- sra D  
			elseif f11 == 0x2b then sra_r(e);   	 -- sra E  
			elseif f11 == 0x2c then sra_r(h);   	 -- sra H  
			elseif f11 == 0x2d then sra_r(l);   	 -- sra L  
			elseif f11 == 0x2e then sra_m(hl);  	 -- sra (HL)  
			elseif f11 == 0x2f then sra_r(a);   	 -- sra A  

			elseif f11 == 0x30 then sll_r(b);   	 -- sll B  
			elseif f11 == 0x31 then sll_r(c);   	 -- sll C  
			elseif f11 == 0x32 then sll_r(d);   	 -- sll D  
			elseif f11 == 0x33 then sll_r(e);   	 -- sll E  
			elseif f11 == 0x34 then sll_r(h);   	 -- sll H  
			elseif f11 == 0x35 then sll_r(l);   	 -- sll L  
			elseif f11 == 0x36 then sll_m(hl);  	 -- sll (HL)  
			elseif f11 == 0x37 then sll_r(a);   	 -- sll A  

			elseif f11 == 0x38 then srl_r(b);   	 -- srl B  
			elseif f11 == 0x39 then srl_r(c);   	 -- srl C  
			elseif f11 == 0x3a then srl_r(d);   	 -- srl D  
			elseif f11 == 0x3b then srl_r(e);   	 -- srl E  
			elseif f11 == 0x3c then srl_r(h);   	 -- srl H  
			elseif f11 == 0x3d then srl_r(l);   	 -- srl L  
			elseif f11 == 0x3e then srl_m(hl);  	 -- srl (HL)  
			elseif f11 == 0x3f then srl_r(a);   	 -- srl A  

			elseif f11 == 0x40 then bit(0, b);         	 -- bit 0, B  
			elseif f11 == 0x41 then bit(0, c);         	 -- bit 0, C  
			elseif f11 == 0x42 then bit(0, d);         	 -- bit 0, D  
			elseif f11 == 0x43 then bit(0, e);         	 -- bit 0, E  
			elseif f11 == 0x44 then bit(0, h);         	 -- bit 0, H  
			elseif f11 == 0x45 then bit(0, l);         	 -- bit 0, L  
			elseif f11 == 0x46 then bit(0, mem8(hl));  	 -- bit 0, (HL)  
			elseif f11 == 0x47 then bit(0, a);         	 -- bit 0, A  

			elseif f11 == 0x48 then bit(1, b);         	 -- bit 1, B  
			elseif f11 == 0x49 then bit(1, c);         	 -- bit 1, C  
			elseif f11 == 0x4a then bit(1, d);         	 -- bit 1, D  
			elseif f11 == 0x4b then bit(1, e);         	 -- bit 1, E  
			elseif f11 == 0x4c then bit(1, h);         	 -- bit 1, H  
			elseif f11 == 0x4d then bit(1, l);         	 -- bit 1, L  
			elseif f11 == 0x4e then bit(1, mem8(hl));  	 -- bit 1, (HL)  
			elseif f11 == 0x4f then bit(1, a);         	 -- bit 1, A  

			elseif f11 == 0x50 then bit(2, b);         	 -- bit 2, B  
			elseif f11 == 0x51 then bit(2, c);         	 -- bit 2, C  
			elseif f11 == 0x52 then bit(2, d);         	 -- bit 2, D  
			elseif f11 == 0x53 then bit(2, e);         	 -- bit 2, E  
			elseif f11 == 0x54 then bit(2, h);         	 -- bit 2, H  
			elseif f11 == 0x55 then bit(2, l);         	 -- bit 2, L  
			elseif f11 == 0x56 then bit(2, mem8(hl));  	 -- bit 2, (HL)  
			elseif f11 == 0x57 then bit(2, a);         	 -- bit 2, A  

			elseif f11 == 0x58 then bit(3, b);         	 -- bit 3, B  
			elseif f11 == 0x59 then bit(3, c);         	 -- bit 3, C  
			elseif f11 == 0x5a then bit(3, d);         	 -- bit 3, D  
			elseif f11 == 0x5b then bit(3, e);         	 -- bit 3, E  
			elseif f11 == 0x5c then bit(3, h);         	 -- bit 3, H  
			elseif f11 == 0x5d then bit(3, l);         	 -- bit 3, L  
			elseif f11 == 0x5e then bit(3, mem8(hl));  	 -- bit 3, (HL)  
			elseif f11 == 0x5f then bit(3, a);         	 -- bit 3, A  

			elseif f11 == 0x60 then bit(4, b);         	 -- bit 4, B  
			elseif f11 == 0x61 then bit(4, c);         	 -- bit 4, C  
			elseif f11 == 0x62 then bit(4, d);         	 -- bit 4, D  
			elseif f11 == 0x63 then bit(4, e);         	 -- bit 4, E  
			elseif f11 == 0x64 then bit(4, h);         	 -- bit 4, H  
			elseif f11 == 0x65 then bit(4, l);         	 -- bit 4, L  
			elseif f11 == 0x66 then bit(4, mem8(hl));  	 -- bit 4, (HL)  
			elseif f11 == 0x67 then bit(4, a);         	 -- bit 4, A  

			elseif f11 == 0x68 then bit(5, b);         	 -- bit 5, B  
			elseif f11 == 0x69 then bit(5, c);         	 -- bit 5, C  
			elseif f11 == 0x6a then bit(5, d);         	 -- bit 5, D  
			elseif f11 == 0x6b then bit(5, e);         	 -- bit 5, E  
			elseif f11 == 0x6c then bit(5, h);         	 -- bit 5, H  
			elseif f11 == 0x6d then bit(5, l);         	 -- bit 5, L  
			elseif f11 == 0x6e then bit(5, mem8(hl));  	 -- bit 5, (HL)  
			elseif f11 == 0x6f then bit(5, a);         	 -- bit 5, A  

			elseif f11 == 0x70 then bit(6, b);         	 -- bit 6, B  
			elseif f11 == 0x71 then bit(6, c);         	 -- bit 6, C  
			elseif f11 == 0x72 then bit(6, d);         	 -- bit 6, D  
			elseif f11 == 0x73 then bit(6, e);         	 -- bit 6, E  
			elseif f11 == 0x74 then bit(6, h);         	 -- bit 6, H  
			elseif f11 == 0x75 then bit(6, l);         	 -- bit 6, L  
			elseif f11 == 0x76 then bit(6, mem8(hl));  	 -- bit 6, (HL)  
			elseif f11 == 0x77 then bit(6, a);         	 -- bit 6, A  

			elseif f11 == 0x78 then bit(7, b);         	 -- bit 7, B  
			elseif f11 == 0x79 then bit(7, c);         	 -- bit 7, C  
			elseif f11 == 0x7a then bit(7, d);         	 -- bit 7, D  
			elseif f11 == 0x7b then bit(7, e);         	 -- bit 7, E  
			elseif f11 == 0x7c then bit(7, h);         	 -- bit 7, H  
			elseif f11 == 0x7d then bit(7, l);         	 -- bit 7, L  
			elseif f11 == 0x7e then bit(7, mem8(hl));  	 -- bit 7, (HL)  
			elseif f11 == 0x7f then bit(7, a);         	 -- bit 7, A  

			elseif f11 == 0x80 then res_r(0, b);   	 -- res 0, B  
			elseif f11 == 0x81 then res_r(0, c);   	 -- res 0, C  
			elseif f11 == 0x82 then res_r(0, d);   	 -- res 0, D  
			elseif f11 == 0x83 then res_r(0, e);   	 -- res 0, E  
			elseif f11 == 0x84 then res_r(0, h);   	 -- res 0, H  
			elseif f11 == 0x85 then res_r(0, l);   	 -- res 0, L  
			elseif f11 == 0x86 then res_m(0, hl);  	 -- res 0, (HL)  
			elseif f11 == 0x87 then res_r(0, a);   	 -- res 0, A  

			elseif f11 == 0x88 then res_r(1, b);   	 -- res 1, B  
			elseif f11 == 0x89 then res_r(1, c);   	 -- res 1, C  
			elseif f11 == 0x8a then res_r(1, d);   	 -- res 1, D  
			elseif f11 == 0x8b then res_r(1, e);   	 -- res 1, E  
			elseif f11 == 0x8c then res_r(1, h);   	 -- res 1, H  
			elseif f11 == 0x8d then res_r(1, l);   	 -- res 1, L  
			elseif f11 == 0x8e then res_m(1, hl);  	 -- res 1, (HL)  
			elseif f11 == 0x8f then res_r(1, a);   	 -- res 1, A  

			elseif f11 == 0x90 then res_r(2, b);   	 -- res 2, B  
			elseif f11 == 0x91 then res_r(2, c);   	 -- res 2, C  
			elseif f11 == 0x92 then res_r(2, d);   	 -- res 2, D  
			elseif f11 == 0x93 then res_r(2, e);   	 -- res 2, E  
			elseif f11 == 0x94 then res_r(2, h);   	 -- res 2, H  
			elseif f11 == 0x95 then res_r(2, l);   	 -- res 2, L  
			elseif f11 == 0x96 then res_m(2, hl);  	 -- res 2, (HL)  
			elseif f11 == 0x97 then res_r(2, a);   	 -- res 2, A  

			elseif f11 == 0x98 then res_r(3, b);   	 -- res 3, B  
			elseif f11 == 0x99 then res_r(3, c);   	 -- res 3, C  
			elseif f11 == 0x9a then res_r(3, d);   	 -- res 3, D  
			elseif f11 == 0x9b then res_r(3, e);   	 -- res 3, E  
			elseif f11 == 0x9c then res_r(3, h);   	 -- res 3, H  
			elseif f11 == 0x9d then res_r(3, l);   	 -- res 3, L  
			elseif f11 == 0x9e then res_m(3, hl);  	 -- res 3, (HL)  
			elseif f11 == 0x9f then res_r(3, a);   	 -- res 3, A  

			elseif f11 == 0xa0 then res_r(4, b);   	 -- res 4, B  
			elseif f11 == 0xa1 then res_r(4, c);   	 -- res 4, C  
			elseif f11 == 0xa2 then res_r(4, d);   	 -- res 4, D  
			elseif f11 == 0xa3 then res_r(4, e);   	 -- res 4, E  
			elseif f11 == 0xa4 then res_r(4, h);   	 -- res 4, H  
			elseif f11 == 0xa5 then res_r(4, l);   	 -- res 4, L  
			elseif f11 == 0xa6 then res_m(4, hl);  	 -- res 4, (HL)  
			elseif f11 == 0xa7 then res_r(4, a);   	 -- res 4, A  

			elseif f11 == 0xa8 then res_r(5, b);   	 -- res 5, B  
			elseif f11 == 0xa9 then res_r(5, c);   	 -- res 5, C  
			elseif f11 == 0xaa then res_r(5, d);   	 -- res 5, D  
			elseif f11 == 0xab then res_r(5, e);   	 -- res 5, E  
			elseif f11 == 0xac then res_r(5, h);   	 -- res 5, H  
			elseif f11 == 0xad then res_r(5, l);   	 -- res 5, L  
			elseif f11 == 0xae then res_m(5, hl);  	 -- res 5, (HL)  
			elseif f11 == 0xaf then res_r(5, a);   	 -- res 5, A  

			elseif f11 == 0xb0 then res_r(6, b);   	 -- res 6, B  
			elseif f11 == 0xb1 then res_r(6, c);   	 -- res 6, C  
			elseif f11 == 0xb2 then res_r(6, d);   	 -- res 6, D  
			elseif f11 == 0xb3 then res_r(6, e);   	 -- res 6, E  
			elseif f11 == 0xb4 then res_r(6, h);   	 -- res 6, H  
			elseif f11 == 0xb5 then res_r(6, l);   	 -- res 6, L  
			elseif f11 == 0xb6 then res_m(6, hl);  	 -- res 6, (HL)  
			elseif f11 == 0xb7 then res_r(6, a);   	 -- res 6, A  

			elseif f11 == 0xb8 then res_r(7, b);   	 -- res 7, B  
			elseif f11 == 0xb9 then res_r(7, c);   	 -- res 7, C  
			elseif f11 == 0xba then res_r(7, d);   	 -- res 7, D  
			elseif f11 == 0xbb then res_r(7, e);   	 -- res 7, E  
			elseif f11 == 0xbc then res_r(7, h);   	 -- res 7, H  
			elseif f11 == 0xbd then res_r(7, l);   	 -- res 7, L  
			elseif f11 == 0xbe then res_m(7, hl);  	 -- res 7, (HL)  
			elseif f11 == 0xbf then res_r(7, a);   	 -- res 7, A  

			elseif f11 == 0xc0 then set_r(0, b);   	 -- set 0, B  
			elseif f11 == 0xc1 then set_r(0, c);   	 -- set 0, C  
			elseif f11 == 0xc2 then set_r(0, d);   	 -- set 0, D  
			elseif f11 == 0xc3 then set_r(0, e);   	 -- set 0, E  
			elseif f11 == 0xc4 then set_r(0, h);   	 -- set 0, H  
			elseif f11 == 0xc5 then set_r(0, l);   	 -- set 0, L  
			elseif f11 == 0xc6 then set_m(0, hl);  	 -- set 0, (HL)  
			elseif f11 == 0xc7 then set_r(0, a);   	 -- set 0, A  

			elseif f11 == 0xc8 then set_r(1, b);   	 -- set 1, B  
			elseif f11 == 0xc9 then set_r(1, c);   	 -- set 1, C  
			elseif f11 == 0xca then set_r(1, d);   	 -- set 1, D  
			elseif f11 == 0xcb then set_r(1, e);   	 -- set 1, E  
			elseif f11 == 0xcc then set_r(1, h);   	 -- set 1, H  
			elseif f11 == 0xcd then set_r(1, l);   	 -- set 1, L  
			elseif f11 == 0xce then set_m(1, hl);  	 -- set 1, (HL)  
			elseif f11 == 0xcf then set_r(1, a);   	 -- set 1, A  

			elseif f11 == 0xd0 then set_r(2, b);   	 -- set 2, B  
			elseif f11 == 0xd1 then set_r(2, c);   	 -- set 2, C  
			elseif f11 == 0xd2 then set_r(2, d);   	 -- set 2, D  
			elseif f11 == 0xd3 then set_r(2, e);   	 -- set 2, E  
			elseif f11 == 0xd4 then set_r(2, h);   	 -- set 2, H  
			elseif f11 == 0xd5 then set_r(2, l);   	 -- set 2, L  
			elseif f11 == 0xd6 then set_m(2, hl);  	 -- set 2, (HL)  
			elseif f11 == 0xd7 then set_r(2, a);   	 -- set 2, A  

			elseif f11 == 0xd8 then set_r(3, b);   	 -- set 3, B  
			elseif f11 == 0xd9 then set_r(3, c);   	 -- set 3, C  
			elseif f11 == 0xda then set_r(3, d);   	 -- set 3, D  
			elseif f11 == 0xdb then set_r(3, e);   	 -- set 3, E  
			elseif f11 == 0xdc then set_r(3, h);   	 -- set 3, H  
			elseif f11 == 0xdd then set_r(3, l);   	 -- set 3, L  
			elseif f11 == 0xde then set_m(3, hl);  	 -- set 3, (HL)  
			elseif f11 == 0xdf then set_r(3, a);   	 -- set 3, A  

			elseif f11 == 0xe0 then set_r(4, b);   	 -- set 4, B  
			elseif f11 == 0xe1 then set_r(4, c);   	 -- set 4, C  
			elseif f11 == 0xe2 then set_r(4, d);   	 -- set 4, D  
			elseif f11 == 0xe3 then set_r(4, e);   	 -- set 4, E  
			elseif f11 == 0xe4 then set_r(4, h);   	 -- set 4, H  
			elseif f11 == 0xe5 then set_r(4, l);   	 -- set 4, L  
			elseif f11 == 0xe6 then set_m(4, hl);  	 -- set 4, (HL)  
			elseif f11 == 0xe7 then set_r(4, a);   	 -- set 4, A  

			elseif f11 == 0xe8 then set_r(5, b);   	 -- set 5, B  
			elseif f11 == 0xe9 then set_r(5, c);   	 -- set 5, C  
			elseif f11 == 0xea then set_r(5, d);   	 -- set 5, D  
			elseif f11 == 0xeb then set_r(5, e);   	 -- set 5, E  
			elseif f11 == 0xec then set_r(5, h);   	 -- set 5, H  
			elseif f11 == 0xed then set_r(5, l);   	 -- set 5, L  
			elseif f11 == 0xee then set_m(5, hl);  	 -- set 5, (HL)  
			elseif f11 == 0xef then set_r(5, a);   	 -- set 5, A  

			elseif f11 == 0xf0 then set_r(6, b);   	 -- set 6, B  
			elseif f11 == 0xf1 then set_r(6, c);   	 -- set 6, C  
			elseif f11 == 0xf2 then set_r(6, d);   	 -- set 6, D  
			elseif f11 == 0xf3 then set_r(6, e);   	 -- set 6, E  
			elseif f11 == 0xf4 then set_r(6, h);   	 -- set 6, H  
			elseif f11 == 0xf5 then set_r(6, l);   	 -- set 6, L  
			elseif f11 == 0xf6 then set_m(6, hl);  	 -- set 6, (HL)  
			elseif f11 == 0xf7 then set_r(6, a);   	 -- set 6, A  

			elseif f11 == 0xf8 then set_r(7, b);   	 -- set 7, B  
			elseif f11 == 0xf9 then set_r(7, c);   	 -- set 7, C  
			elseif f11 == 0xfa then set_r(7, d);   	 -- set 7, D  
			elseif f11 == 0xfb then set_r(7, e);   	 -- set 7, E  
			elseif f11 == 0xfc then set_r(7, h);   	 -- set 7, H  
			elseif f11 == 0xfd then set_r(7, l);   	 -- set 7, L  
			elseif f11 == 0xfe then set_m(7, hl);  	 -- set 7, (HL)  
			elseif f11 == 0xff then set_r(7, a);   	 -- set 7, A  	
		
			end

		elseif f1 == 0xcc then call(f.z(), imm16());		-- call Z, mn
		elseif f1 == 0xcd then call(1, imm16());		-- call mn
		elseif f1 == 0xce then adc8(imm8());		-- adc n
		elseif f1 == 0xcf then rst(0x08);		-- rst 08H
		
		elseif f1 == 0xd0 then ret(f.ncy());            	 -- ret NC  
		elseif f1 == 0xd1 then pop(de);                 	 -- pop DE  
		elseif f1 == 0xd2 then jp(f.ncy(), imm16());    	 -- jp NC, mn  
		elseif f1 == 0xd3 then out_n(imm8());           	 -- out (n), A  
		elseif f1 == 0xd4 then call(f.ncy(), imm16());  	 -- call NC, mn  
		elseif f1 == 0xd5 then push(de);                	 -- push DE  
		elseif f1 == 0xd6 then sub8(imm8());            	 -- sub n  
		elseif f1 == 0xd7 then rst(0x10);               	 -- rst 10H  

		elseif f1 == 0xd8 then ret(f.cy());            	 -- ret C  
		elseif f1 == 0xd9 then exx();                  	 -- exx  
		elseif f1 == 0xda then jp(f.cy(), imm16());    	 -- jp C, mn  
		elseif f1 == 0xdb then in_n(imm8());           	 -- in A, (n)  
		elseif f1 == 0xdc then call(f.cy(), imm16());  	 -- call C, mn  
		elseif f1 == 0xdd then
			pc = pc + 1
			local f12 = fetchDDXX()
			
			if f12 == 0x09 then add16(ix, bc);  	 -- add IX, BC  

			elseif f12 == 0x19 then add16(ix, de);  	 -- add IX, DE  

			elseif f12 == 0x21 then ld16(ix, imm16());  	 -- ld IX, mn  
			elseif f12 == 0x22 then st16(imm16(), ix);  	 -- ld (mn), IX  
			elseif f12 == 0x23 then inc16(ix);          	 -- inc IX  
			elseif f12 == 0x24 then inc8_r(ixh);        	 -- inc IXh  
			elseif f12 == 0x25 then dec8_r(ixh);        	 -- dec IXh  
			elseif f12 == 0x26 then ld8(ixh, imm8());   	 -- ld IXh, n  

			elseif f12 == 0x29 then add16(ix, ix);             	 -- add IX, IX  
			elseif f12 == 0x2a then ld16(ix, mem16(imm16()));  	 -- ld IX, (mn)  
			elseif f12 == 0x2b then dec16(ix);                 	 -- dec IX  
			elseif f12 == 0x2c then inc8_r(ixl);               	 -- inc IXl  
			elseif f12 == 0x2d then dec8_r(ixl);               	 -- dec IXl  
			elseif f12 == 0x2e then ld8(ixl, imm8());          	 -- ld IXl, n  

			elseif f12 == 0x34 then inc8_m(ix.get() + dis());             	 -- inc (IX + d)  
			elseif f12 == 0x35 then dec8_m(ix.get() + dis());             	 -- dec (IX + d)  
			elseif f12 == 0x36 then st8(ix.get() + dis(), mem8(pc + 2));  	 -- ld (IX + d), n  

			elseif f12 == 0x39 then add16(ix, sp);  	 -- ADD IX, SP  

			elseif f12 == 0x44 then ld8(b, ixh);                  	 -- ld B, IXh  
			elseif f12 == 0x45 then ld8(b, ixl);                  	 -- ld B, IXl  
			elseif f12 == 0x46 then ld8(b, mem8(ix.get() + dis()));  	 -- ld B, (IX + d)  

			elseif f12 == 0x4c then ld8(c, ixh);                  	 -- ld C, IXh  
			elseif f12 == 0x4d then ld8(c, ixl);                  	 -- ld C, IXl  
			elseif f12 == 0x4e then ld8(c, mem8(ix.get() + dis()));  	 -- ld C, (IX + d)  

			elseif f12 == 0x54 then ld8(d, ixh);                  	 -- ld D, IXh  
			elseif f12 == 0x55 then ld8(d, ixl);                  	 -- ld D, IXl  
			elseif f12 == 0x56 then ld8(d, mem8(ix.get() + dis()));  	 -- ld D, (IX + d)  

			elseif f12 == 0x5c then ld8(e, ixh);                  	 -- ld E, IXh  
			elseif f12 == 0x5d then ld8(e, ixl);                  	 -- ld E, IXl  
			elseif f12 == 0x5e then ld8(e, mem8(ix.get() + dis()));  	 -- ld E, (IX + d)  

			elseif f12 == 0x60 then ld8(ixh, b);                  	 -- ld IXh, B  
			elseif f12 == 0x61 then ld8(ixh, c);                  	 -- ld IXh, C  
			elseif f12 == 0x62 then ld8(ixh, d);                  	 -- ld IXh, D  
			elseif f12 == 0x63 then ld8(ixh, e);                  	 -- ld IXh, E  
			elseif f12 == 0x64 then ld8(ixh, h);                  	 -- ld IXh, H  
			elseif f12 == 0x65 then ld8(ixh, l);                  	 -- ld IXh, L  
			elseif f12 == 0x66 then ld8(h, mem8(ix.get() + dis()));  	 -- ld H, (IX + d)  
			elseif f12 == 0x67 then ld8(ixh, a);                  	 -- ld IXh, A  

			elseif f12 == 0x68 then ld8(ixl, b);                  	 -- ld IXl, B  
			elseif f12 == 0x69 then ld8(ixl, c);                  	 -- ld IXl, C  
			elseif f12 == 0x6a then ld8(ixl, d);                  	 -- ld IXl, D  
			elseif f12 == 0x6b then ld8(ixl, e);                  	 -- ld IXl, E  
			elseif f12 == 0x6c then ld8(ixl, h);                  	 -- ld IXl, H  
			elseif f12 == 0x6d then ld8(ixl, l);                  	 -- ld IXl, L  
			elseif f12 == 0x6e then ld8(l, mem8(ix.get() + dis()));  	 -- ld L, (IX + d)  
			elseif f12 == 0x6f then ld8(ixl, a);                  	 -- ld IXl, A  

			elseif f12 == 0x70 then st8(ix.get() + dis(), b);  	 -- ld (IX + d), B  
			elseif f12 == 0x71 then st8(ix.get() + dis(), c);  	 -- ld (IX + d), C  
			elseif f12 == 0x72 then st8(ix.get() + dis(), d);  	 -- ld (IX + d), D  
			elseif f12 == 0x73 then st8(ix.get() + dis(), e);  	 -- ld (IX + d), E  
			elseif f12 == 0x74 then st8(ix.get() + dis(), h);  	 -- ld (IX + d), H  
			elseif f12 == 0x75 then st8(ix.get() + dis(), l);  	 -- ld (IX + d), L  
			elseif f12 == 0x77 then st8(ix.get() + dis(), a);  	 -- ld (IX + d), A  

			elseif f12 == 0x7c then ld8(a, ixh);                  	 -- ld A, IXh  
			elseif f12 == 0x7d then ld8(a, ixl);                  	 -- ld A, IXl  
			elseif f12 == 0x7e then ld8(a, mem8(ix.get() + dis()));  	 -- ld A, (IX + d)  

			elseif f12 == 0x84 then add8(ixh);                  	 -- add IXh  
			elseif f12 == 0x85 then add8(ixl);                  	 -- add IXl  
			elseif f12 == 0x86 then add8(mem8(ix.get() + dis()));  	 -- add (IX + d)  

			elseif f12 == 0x8c then adc8(ixh);                  	 -- adc IXh  
			elseif f12 == 0x8d then adc8(ixl);                  	 -- adc IXl  
			elseif f12 == 0x8e then adc8(mem8(ix.get() + dis()));  	 -- adc (IX + d)  

			elseif f12 == 0x94 then sub8(ixh);                  	 -- sub IXh  
			elseif f12 == 0x95 then sub8(ixl);                  	 -- sub IXl  
			elseif f12 == 0x96 then sub8(mem8(ix.get() + dis()));  	 -- sub (IX + d)  

			elseif f12 == 0x9c then sbc8(ixh);                  	 -- sbc IXh  
			elseif f12 == 0x9d then sbc8(ixl);                  	 -- sbc IXl  
			elseif f12 == 0x9e then sbc8(mem8(ix.get() + dis()));  	 -- sbc (IX + d)  

			elseif f12 == 0xa4 then And(ixh);                  	 -- and IXh  
			elseif f12 == 0xa5 then And(ixl);                  	 -- and IXl  
			elseif f12 == 0xa6 then And(mem8(ix.get() + dis()));  	 -- and (IX + d)  

			elseif f12 == 0xac then Xor(ixh);                  	 -- xor IXh  
			elseif f12 == 0xad then Xor(ixl);                  	 -- xor IXl  
			elseif f12 == 0xae then Xor(mem8(ix.get() + dis()));  	 -- xor (IX + d)  

			elseif f12 == 0xb4 then Or(ixh);                  	 -- or IXh  
			elseif f12 == 0xb5 then Or(ixl);                  	 -- or IXl  
			elseif f12 == 0xb6 then Or(mem8(ix.get() + dis()));  	 -- or (IX + d)  

			elseif f12 == 0xbc then cp(ixh);                  	 -- cp IXh  
			elseif f12 == 0xbd then cp(ixl);                  	 -- cp IXl  
			elseif f12 == 0xbe then cp(mem8(ix.get() + dis()));  	 -- cp (IX + d)  

			elseif f12 == 0xcb then
				local f121 = fetchDDCBXX()
				
				if 	   f121 == 0x00 then rlc_m_r(ix.get() + dis(), b);  	 -- rlc (IX + d), B  
				elseif f121 == 0x01 then rlc_m_r(ix.get() + dis(), c);  	 -- rlc (IX + d), C  
				elseif f121 == 0x02 then rlc_m_r(ix.get() + dis(), d);  	 -- rlc (IX + d), D  
				elseif f121 == 0x03 then rlc_m_r(ix.get() + dis(), e);  	 -- rlc (IX + d), E  
				elseif f121 == 0x04 then rlc_m_r(ix.get() + dis(), h);  	 -- rlc (IX + d), H  
				elseif f121 == 0x05 then rlc_m_r(ix.get() + dis(), l);  	 -- rlc (IX + d), L  
				elseif f121 == 0x06 then rlc_m(ix.get() + dis());       	 -- rlc (IX + d)  
				elseif f121 == 0x07 then rlc_m_r(ix.get() + dis(), a);  	 -- rlc (IX + d), A  

				elseif f121 == 0x08 then rrc_m_r(ix.get() + dis(), b);  	 -- rrc (IX + d), B  
				elseif f121 == 0x09 then rrc_m_r(ix.get() + dis(), c);  	 -- rrc (IX + d), C  
				elseif f121 == 0x0a then rrc_m_r(ix.get() + dis(), d);  	 -- rrc (IX + d), D  
				elseif f121 == 0x0b then rrc_m_r(ix.get() + dis(), e);  	 -- rrc (IX + d), E  
				elseif f121 == 0x0c then rrc_m_r(ix.get() + dis(), h);  	 -- rrc (IX + d), H  
				elseif f121 == 0x0d then rrc_m_r(ix.get() + dis(), l);  	 -- rrc (IX + d), L  
				elseif f121 == 0x0e then rrc_m(ix.get() + dis());       	 -- rrc (IX + d)  
				elseif f121 == 0x0f then rrc_m_r(ix.get() + dis(), a);  	 -- rrc (IX + d), A  

				elseif f121 == 0x10 then rl_m_r(ix.get() + dis(), b);  	 -- rl (IX + d), B  
				elseif f121 == 0x11 then rl_m_r(ix.get() + dis(), c);  	 -- rl (IX + d), C  
				elseif f121 == 0x12 then rl_m_r(ix.get() + dis(), d);  	 -- rl (IX + d), D  
				elseif f121 == 0x13 then rl_m_r(ix.get() + dis(), e);  	 -- rl (IX + d), E  
				elseif f121 == 0x14 then rl_m_r(ix.get() + dis(), h);  	 -- rl (IX + d), H  
				elseif f121 == 0x15 then rl_m_r(ix.get() + dis(), l);  	 -- rl (IX + d), L  
				elseif f121 == 0x16 then rl_m(ix.get() + dis());       	 -- rl (IX + d)  
				elseif f121 == 0x17 then rl_m_r(ix.get() + dis(), a);  	 -- rl (IX + d), A  

				elseif f121 == 0x18 then rr_m_r(ix.get() + dis(), b);  	 -- rr (IX + d), B  
				elseif f121 == 0x19 then rr_m_r(ix.get() + dis(), c);  	 -- rr (IX + d), C  
				elseif f121 == 0x1a then rr_m_r(ix.get() + dis(), d);  	 -- rr (IX + d), D  
				elseif f121 == 0x1b then rr_m_r(ix.get() + dis(), e);  	 -- rr (IX + d), E  
				elseif f121 == 0x1c then rr_m_r(ix.get() + dis(), h);  	 -- rr (IX + d), H  
				elseif f121 == 0x1d then rr_m_r(ix.get() + dis(), l);  	 -- rr (IX + d), L  
				elseif f121 == 0x1e then rr_m(ix.get() + dis());       	 -- rr (IX + d)  
				elseif f121 == 0x1f then rr_m_r(ix.get() + dis(), a);  	 -- rr (IX + d), A  

				elseif f121 == 0x20 then sla_m_r(ix.get() + dis(), b);  	 -- sla (IX + d), B  
				elseif f121 == 0x21 then sla_m_r(ix.get() + dis(), c);  	 -- sla (IX + d), C  
				elseif f121 == 0x22 then sla_m_r(ix.get() + dis(), d);  	 -- sla (IX + d), D  
				elseif f121 == 0x23 then sla_m_r(ix.get() + dis(), e);  	 -- sla (IX + d), E  
				elseif f121 == 0x24 then sla_m_r(ix.get() + dis(), h);  	 -- sla (IX + d), H  
				elseif f121 == 0x25 then sla_m_r(ix.get() + dis(), l);  	 -- sla (IX + d), L  
				elseif f121 == 0x26 then sla_m(ix.get() + dis());       	 -- sla (IX + d)  
				elseif f121 == 0x27 then sla_m_r(ix.get() + dis(), a);  	 -- sla (IX + d), A  

				elseif f121 == 0x28 then sra_m_r(ix.get() + dis(), b);  	 -- sra (IX + d), B  
				elseif f121 == 0x29 then sra_m_r(ix.get() + dis(), c);  	 -- sra (IX + d), C  
				elseif f121 == 0x2a then sra_m_r(ix.get() + dis(), d);  	 -- sra (IX + d), D  
				elseif f121 == 0x2b then sra_m_r(ix.get() + dis(), e);  	 -- sra (IX + d), E  
				elseif f121 == 0x2c then sra_m_r(ix.get() + dis(), h);  	 -- sra (IX + d), H  
				elseif f121 == 0x2d then sra_m_r(ix.get() + dis(), l);  	 -- sra (IX + d), L  
				elseif f121 == 0x2e then sra_m(ix.get() + dis());       	 -- sra (IX + d)  
				elseif f121 == 0x2f then sra_m_r(ix.get() + dis(), a);  	 -- sra (IX + d), A  

				elseif f121 == 0x30 then sll_m_r(ix.get() + dis(), b);  	 -- sll (IX + d), B  
				elseif f121 == 0x31 then sll_m_r(ix.get() + dis(), c);  	 -- sll (IX + d), C  
				elseif f121 == 0x32 then sll_m_r(ix.get() + dis(), d);  	 -- sll (IX + d), D  
				elseif f121 == 0x33 then sll_m_r(ix.get() + dis(), e);  	 -- sll (IX + d), E  
				elseif f121 == 0x34 then sll_m_r(ix.get() + dis(), h);  	 -- sll (IX + d), H  
				elseif f121 == 0x35 then sll_m_r(ix.get() + dis(), l);  	 -- sll (IX + d), L  
				elseif f121 == 0x36 then sll_m(ix.get() + dis());       	 -- sll (IX + d)  
				elseif f121 == 0x37 then sll_m_r(ix.get() + dis(), a);  	 -- sll (IX + d), A  

				elseif f121 == 0x38 then srl_m_r(ix.get() + dis(), b);  	 -- srl (IX + d), B  
				elseif f121 == 0x39 then srl_m_r(ix.get() + dis(), c);  	 -- srl (IX + d), C  
				elseif f121 == 0x3a then srl_m_r(ix.get() + dis(), d);  	 -- srl (IX + d), D  
				elseif f121 == 0x3b then srl_m_r(ix.get() + dis(), e);  	 -- srl (IX + d), E  
				elseif f121 == 0x3c then srl_m_r(ix.get() + dis(), h);  	 -- srl (IX + d), H  
				elseif f121 == 0x3d then srl_m_r(ix.get() + dis(), l);  	 -- srl (IX + d), L  
				elseif f121 == 0x3e then srl_m(ix.get() + dis());       	 -- srl (IX + d)  
				elseif f121 == 0x3f then srl_m_r(ix.get() + dis(), a);  	 -- srl (IX + d), A  

				elseif f121 == 0x40 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x41 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x42 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x43 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x44 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x45 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x46 then bit(0, mem8(ix.get() + dis()));       -- bit 0, (IX + d)
				elseif f121 == 0x47 then bit(0, mem8(ix.get() + dis()));  	 -- bit 0, (IX + d)  

				elseif f121 == 0x48 then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x49 then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x4a then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x4b then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x4c then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x4d then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x4e then bit(1, mem8(ix.get() + dis()));       -- bit 1, (IX + d)
				elseif f121 == 0x4f then bit(1, mem8(ix.get() + dis()));  	 -- bit 1, (IX + d)  

				elseif f121 == 0x50 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x51 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x52 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x53 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x54 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x55 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x56 then bit(2, mem8(ix.get() + dis()));       -- bit 2, (IX + d)
				elseif f121 == 0x57 then bit(2, mem8(ix.get() + dis()));  	 -- bit 2, (IX + d)  

				elseif f121 == 0x58 then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x59 then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x5a then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x5b then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x5c then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x5d then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x5e then bit(3, mem8(ix.get() + dis()));       -- bit 3, (IX + d)
				elseif f121 == 0x5f then bit(3, mem8(ix.get() + dis()));  	 -- bit 3, (IX + d)  

				elseif f121 == 0x60 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x61 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x62 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x63 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x64 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x65 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x66 then bit(4, mem8(ix.get() + dis()));       -- bit 4, (IX + d)
				elseif f121 == 0x67 then bit(4, mem8(ix.get() + dis()));  	 -- bit 4, (IX + d)  

				elseif f121 == 0x68 then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x69 then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x6a then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x6b then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x6c then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x6d then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x6e then bit(5, mem8(ix.get() + dis()));       -- bit 5, (IX + d)
				elseif f121 == 0x6f then bit(5, mem8(ix.get() + dis()));  	 -- bit 5, (IX + d)  

				elseif f121 == 0x70 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x71 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x72 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x73 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x74 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x75 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x76 then bit(6, mem8(ix.get() + dis()));       -- bit 6, (IX + d)
				elseif f121 == 0x77 then bit(6, mem8(ix.get() + dis()));  	 -- bit 6, (IX + d)  

				elseif f121 == 0x78 then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x79 then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x7a then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x7b then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x7c then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x7d then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x7e then bit(7, mem8(ix.get() + dis()));       -- bit 7, (IX + d)
				elseif f121 == 0x7f then bit(7, mem8(ix.get() + dis()));  	 -- bit 7, (IX + d)  

				elseif f121 == 0x80 then res_m_r(0, ix.get() + dis(), b);  	 -- res 0, (IX + d), B  
				elseif f121 == 0x81 then res_m_r(0, ix.get() + dis(), c);  	 -- res 0, (IX + d), C  
				elseif f121 == 0x82 then res_m_r(0, ix.get() + dis(), d);  	 -- res 0, (IX + d), D  
				elseif f121 == 0x83 then res_m_r(0, ix.get() + dis(), e);  	 -- res 0, (IX + d), E  
				elseif f121 == 0x84 then res_m_r(0, ix.get() + dis(), h);  	 -- res 0, (IX + d), H  
				elseif f121 == 0x85 then res_m_r(0, ix.get() + dis(), l);  	 -- res 0, (IX + d), L  
				elseif f121 == 0x86 then res_m(0, ix.get() + dis());       	 -- res 0, (IX + d)  
				elseif f121 == 0x87 then res_m_r(0, ix.get() + dis(), a);  	 -- res 0, (IX + d), A  

				elseif f121 == 0x88 then res_m_r(1, ix.get() + dis(), b);  	 -- res 1, (IX + d), B  
				elseif f121 == 0x89 then res_m_r(1, ix.get() + dis(), c);  	 -- res 1, (IX + d), C  
				elseif f121 == 0x8a then res_m_r(1, ix.get() + dis(), d);  	 -- res 1, (IX + d), D  
				elseif f121 == 0x8b then res_m_r(1, ix.get() + dis(), e);  	 -- res 1, (IX + d), E  
				elseif f121 == 0x8c then res_m_r(1, ix.get() + dis(), h);  	 -- res 1, (IX + d), H  
				elseif f121 == 0x8d then res_m_r(1, ix.get() + dis(), l);  	 -- res 1, (IX + d), L  
				elseif f121 == 0x8e then res_m(1, ix.get() + dis());       	 -- res 1, (IX + d)  
				elseif f121 == 0x8f then res_m_r(1, ix.get() + dis(), a);  	 -- res 1, (IX + d), A  

				elseif f121 == 0x90 then res_m_r(2, ix.get() + dis(), b);  	 -- res 2, (IX + d), B  
				elseif f121 == 0x91 then res_m_r(2, ix.get() + dis(), c);  	 -- res 2, (IX + d), C  
				elseif f121 == 0x92 then res_m_r(2, ix.get() + dis(), d);  	 -- res 2, (IX + d), D  
				elseif f121 == 0x93 then res_m_r(2, ix.get() + dis(), e);  	 -- res 2, (IX + d), E  
				elseif f121 == 0x94 then res_m_r(2, ix.get() + dis(), h);  	 -- res 2, (IX + d), H  
				elseif f121 == 0x95 then res_m_r(2, ix.get() + dis(), l);  	 -- res 2, (IX + d), L  
				elseif f121 == 0x96 then res_m(2, ix.get() + dis());       	 -- res 2, (IX + d)  
				elseif f121 == 0x97 then res_m_r(2, ix.get() + dis(), a);  	 -- res 2, (IX + d), A  

				elseif f121 == 0x98 then res_m_r(3, ix.get() + dis(), b);  	 -- res 3, (IX + d), B  
				elseif f121 == 0x99 then res_m_r(3, ix.get() + dis(), c);  	 -- res 3, (IX + d), C  
				elseif f121 == 0x9a then res_m_r(3, ix.get() + dis(), d);  	 -- res 3, (IX + d), D  
				elseif f121 == 0x9b then res_m_r(3, ix.get() + dis(), e);  	 -- res 3, (IX + d), E  
				elseif f121 == 0x9c then res_m_r(3, ix.get() + dis(), h);  	 -- res 3, (IX + d), H  
				elseif f121 == 0x9d then res_m_r(3, ix.get() + dis(), l);  	 -- res 3, (IX + d), L  
				elseif f121 == 0x9e then res_m(3, ix.get() + dis());       	 -- res 3, (IX + d)  
				elseif f121 == 0x9f then res_m_r(3, ix.get() + dis(), a);  	 -- res 3, (IX + d), A  

				elseif f121 == 0xa0 then res_m_r(4, ix.get() + dis(), b);  	 -- res 4, (IX + d), B  
				elseif f121 == 0xa1 then res_m_r(4, ix.get() + dis(), c);  	 -- res 4, (IX + d), C  
				elseif f121 == 0xa2 then res_m_r(4, ix.get() + dis(), d);  	 -- res 4, (IX + d), D  
				elseif f121 == 0xa3 then res_m_r(4, ix.get() + dis(), e);  	 -- res 4, (IX + d), E  
				elseif f121 == 0xa4 then res_m_r(4, ix.get() + dis(), h);  	 -- res 4, (IX + d), H  
				elseif f121 == 0xa5 then res_m_r(4, ix.get() + dis(), l);  	 -- res 4, (IX + d), L  
				elseif f121 == 0xa6 then res_m(4, ix.get() + dis());       	 -- res 4, (IX + d)  
				elseif f121 == 0xa7 then res_m_r(4, ix.get() + dis(), a);  	 -- res 4, (IX + d), A  

				elseif f121 == 0xa8 then res_m_r(5, ix.get() + dis(), b);  	 -- res 5, (IX + d), B  
				elseif f121 == 0xa9 then res_m_r(5, ix.get() + dis(), c);  	 -- res 5, (IX + d), C  
				elseif f121 == 0xaa then res_m_r(5, ix.get() + dis(), d);  	 -- res 5, (IX + d), D  
				elseif f121 == 0xab then res_m_r(5, ix.get() + dis(), e);  	 -- res 5, (IX + d), E  
				elseif f121 == 0xac then res_m_r(5, ix.get() + dis(), h);  	 -- res 5, (IX + d), H  
				elseif f121 == 0xad then res_m_r(5, ix.get() + dis(), l);  	 -- res 5, (IX + d), L  
				elseif f121 == 0xae then res_m(5, ix.get() + dis());       	 -- res 5, (IX + d)  
				elseif f121 == 0xaf then res_m_r(5, ix.get() + dis(), a);  	 -- res 5, (IX + d), A  

				elseif f121 == 0xb0 then res_m_r(6, ix.get() + dis(), b);  	 -- res 6, (IX + d), B  
				elseif f121 == 0xb1 then res_m_r(6, ix.get() + dis(), c);  	 -- res 6, (IX + d), C  
				elseif f121 == 0xb2 then res_m_r(6, ix.get() + dis(), d);  	 -- res 6, (IX + d), D  
				elseif f121 == 0xb3 then res_m_r(6, ix.get() + dis(), e);  	 -- res 6, (IX + d), E  
				elseif f121 == 0xb4 then res_m_r(6, ix.get() + dis(), h);  	 -- res 6, (IX + d), H  
				elseif f121 == 0xb5 then res_m_r(6, ix.get() + dis(), l);  	 -- res 6, (IX + d), L  
				elseif f121 == 0xb6 then res_m(6, ix.get() + dis());       	 -- res 6, (IX + d)  
				elseif f121 == 0xb7 then res_m_r(6, ix.get() + dis(), a);  	 -- res 6, (IX + d), A  

				elseif f121 == 0xb8 then res_m_r(7, ix.get() + dis(), b);  	 -- res 7, (IX + d), B  
				elseif f121 == 0xb9 then res_m_r(7, ix.get() + dis(), c);  	 -- res 7, (IX + d), C  
				elseif f121 == 0xba then res_m_r(7, ix.get() + dis(), d);  	 -- res 7, (IX + d), D  
				elseif f121 == 0xbb then res_m_r(7, ix.get() + dis(), e);  	 -- res 7, (IX + d), E  
				elseif f121 == 0xbc then res_m_r(7, ix.get() + dis(), h);  	 -- res 7, (IX + d), H  
				elseif f121 == 0xbd then res_m_r(7, ix.get() + dis(), l);  	 -- res 7, (IX + d), L  
				elseif f121 == 0xbe then res_m(7, ix.get() + dis());       	 -- res 7, (IX + d)  
				elseif f121 == 0xbf then res_m_r(7, ix.get() + dis(), a);  	 -- res 7, (IX + d), A  

				elseif f121 == 0xc0 then set_m_r(0, ix.get() + dis(), b);  	 -- set 0, (IX + d), B  
				elseif f121 == 0xc1 then set_m_r(0, ix.get() + dis(), c);  	 -- set 0, (IX + d), C  
				elseif f121 == 0xc2 then set_m_r(0, ix.get() + dis(), d);  	 -- set 0, (IX + d), D  
				elseif f121 == 0xc3 then set_m_r(0, ix.get() + dis(), e);  	 -- set 0, (IX + d), E  
				elseif f121 == 0xc4 then set_m_r(0, ix.get() + dis(), h);  	 -- set 0, (IX + d), H  
				elseif f121 == 0xc5 then set_m_r(0, ix.get() + dis(), l);  	 -- set 0, (IX + d), L  
				elseif f121 == 0xc6 then set_m(0, ix.get() + dis());       	 -- set 0, (IX + d)  
				elseif f121 == 0xc7 then set_m_r(0, ix.get() + dis(), a);  	 -- set 0, (IX + d), A  

				elseif f121 == 0xc8 then set_m_r(1, ix.get() + dis(), b);  	 -- set 1, (IX + d), B  
				elseif f121 == 0xc9 then set_m_r(1, ix.get() + dis(), c);  	 -- set 1, (IX + d), C  
				elseif f121 == 0xca then set_m_r(1, ix.get() + dis(), d);  	 -- set 1, (IX + d), D  
				elseif f121 == 0xcb then set_m_r(1, ix.get() + dis(), e);  	 -- set 1, (IX + d), E  
				elseif f121 == 0xcc then set_m_r(1, ix.get() + dis(), h);  	 -- set 1, (IX + d), H  
				elseif f121 == 0xcd then set_m_r(1, ix.get() + dis(), l);  	 -- set 1, (IX + d), L  
				elseif f121 == 0xce then set_m(1, ix.get() + dis());       	 -- set 1, (IX + d)  
				elseif f121 == 0xcf then set_m_r(1, ix.get() + dis(), a);  	 -- set 1, (IX + d), A  

				elseif f121 == 0xd0 then set_m_r(2, ix.get() + dis(), b);  	 -- set 2, (IX + d), B  
				elseif f121 == 0xd1 then set_m_r(2, ix.get() + dis(), c);  	 -- set 2, (IX + d), C  
				elseif f121 == 0xd2 then set_m_r(2, ix.get() + dis(), d);  	 -- set 2, (IX + d), D  
				elseif f121 == 0xd3 then set_m_r(2, ix.get() + dis(), e);  	 -- set 2, (IX + d), E  
				elseif f121 == 0xd4 then set_m_r(2, ix.get() + dis(), h);  	 -- set 2, (IX + d), H  
				elseif f121 == 0xd5 then set_m_r(2, ix.get() + dis(), l);  	 -- set 2, (IX + d), L  
				elseif f121 == 0xd6 then set_m(2, ix.get() + dis());       	 -- set 2, (IX + d)  
				elseif f121 == 0xd7 then set_m_r(2, ix.get() + dis(), a);  	 -- set 2, (IX + d), A  

				elseif f121 == 0xd8 then set_m_r(3, ix.get() + dis(), b);  	 -- set 3, (IX + d), B  
				elseif f121 == 0xd9 then set_m_r(3, ix.get() + dis(), c);  	 -- set 3, (IX + d), C  
				elseif f121 == 0xda then set_m_r(3, ix.get() + dis(), d);  	 -- set 3, (IX + d), D  
				elseif f121 == 0xdb then set_m_r(3, ix.get() + dis(), e);  	 -- set 3, (IX + d), E  
				elseif f121 == 0xdc then set_m_r(3, ix.get() + dis(), h);  	 -- set 3, (IX + d), H  
				elseif f121 == 0xdd then set_m_r(3, ix.get() + dis(), l);  	 -- set 3, (IX + d), L  
				elseif f121 == 0xde then set_m(3, ix.get() + dis());       	 -- set 3, (IX + d)  
				elseif f121 == 0xdf then set_m_r(3, ix.get() + dis(), a);  	 -- set 3, (IX + d), A  

				elseif f121 == 0xe0 then set_m_r(4, ix.get() + dis(), b);  	 -- set 4, (IX + d), B  
				elseif f121 == 0xe1 then set_m_r(4, ix.get() + dis(), c);  	 -- set 4, (IX + d), C  
				elseif f121 == 0xe2 then set_m_r(4, ix.get() + dis(), d);  	 -- set 4, (IX + d), D  
				elseif f121 == 0xe3 then set_m_r(4, ix.get() + dis(), e);  	 -- set 4, (IX + d), E  
				elseif f121 == 0xe4 then set_m_r(4, ix.get() + dis(), h);  	 -- set 4, (IX + d), H  
				elseif f121 == 0xe5 then set_m_r(4, ix.get() + dis(), l);  	 -- set 4, (IX + d), L  
				elseif f121 == 0xe6 then set_m(4, ix.get() + dis());       	 -- set 4, (IX + d)  
				elseif f121 == 0xe7 then set_m_r(4, ix.get() + dis(), a);  	 -- set 4, (IX + d), A  

				elseif f121 == 0xe8 then set_m_r(5, ix.get() + dis(), b);  	 -- set 5, (IX + d), B  
				elseif f121 == 0xe9 then set_m_r(5, ix.get() + dis(), c);  	 -- set 5, (IX + d), C  
				elseif f121 == 0xea then set_m_r(5, ix.get() + dis(), d);  	 -- set 5, (IX + d), D  
				elseif f121 == 0xeb then set_m_r(5, ix.get() + dis(), e);  	 -- set 5, (IX + d), E  
				elseif f121 == 0xec then set_m_r(5, ix.get() + dis(), h);  	 -- set 5, (IX + d), H  
				elseif f121 == 0xed then set_m_r(5, ix.get() + dis(), l);  	 -- set 5, (IX + d), L  
				elseif f121 == 0xee then set_m(5, ix.get() + dis());       	 -- set 5, (IX + d)  
				elseif f121 == 0xef then set_m_r(5, ix.get() + dis(), a);  	 -- set 5, (IX + d), A  

				elseif f121 == 0xf0 then set_m_r(6, ix.get() + dis(), b);  	 -- set 6, (IX + d), B  
				elseif f121 == 0xf1 then set_m_r(6, ix.get() + dis(), c);  	 -- set 6, (IX + d), C  
				elseif f121 == 0xf2 then set_m_r(6, ix.get() + dis(), d);  	 -- set 6, (IX + d), D  
				elseif f121 == 0xf3 then set_m_r(6, ix.get() + dis(), e);  	 -- set 6, (IX + d), E  
				elseif f121 == 0xf4 then set_m_r(6, ix.get() + dis(), h);  	 -- set 6, (IX + d), H  
				elseif f121 == 0xf5 then set_m_r(6, ix.get() + dis(), l);  	 -- set 6, (IX + d), L  
				elseif f121 == 0xf6 then set_m(6, ix.get() + dis());       	 -- set 6, (IX + d)  
				elseif f121 == 0xf7 then set_m_r(6, ix.get() + dis(), a);  	 -- set 6, (IX + d), A  

				elseif f121 == 0xf8 then set_m_r(7, ix.get() + dis(), b);  	 -- set 7, (IX + d), B  
				elseif f121 == 0xf9 then set_m_r(7, ix.get() + dis(), c);  	 -- set 7, (IX + d), C  
				elseif f121 == 0xfa then set_m_r(7, ix.get() + dis(), d);  	 -- set 7, (IX + d), D  
				elseif f121 == 0xfb then set_m_r(7, ix.get() + dis(), e);  	 -- set 7, (IX + d), E  
				elseif f121 == 0xfc then set_m_r(7, ix.get() + dis(), h);  	 -- set 7, (IX + d), H  
				elseif f121 == 0xfd then set_m_r(7, ix.get() + dis(), l);  	 -- set 7, (IX + d), L  
				elseif f121 == 0xfe then set_m(7, ix.get() + dis());       	 -- set 7, (IX + d)  
				elseif f121 == 0xff then set_m_r(7, ix.get() + dis(), a);  	 -- set 7, (IX + d), A  
				
				end
			
			elseif f12 == 0xe1 then pop(ix);    	 -- pop IX  
			elseif f12 == 0xe3 then ex_sp(ix);  	 -- ex (SP), IX  
			elseif f12 == 0xe5 then push(ix);   	 -- push IX  

			elseif f12 == 0xe9 then jp(1, ix);  	 -- jp (IX)  

			elseif f12 == 0xf9 then ld16(sp, ix);  	 -- ld SP, IX  
			else pc = pc + length 		-- nop
			
			end	

		elseif f1 == 0xde then sbc8(imm8());  	 -- sbc n  
		elseif f1 == 0xdf then rst(0x18);     	 -- rst 18H  

		elseif f1 == 0xe0 then ret(f.npv());            	 -- ret PO  
		elseif f1 == 0xe1 then pop(hl);                 	 -- pop HL  
		elseif f1 == 0xe2 then jp(f.npv(), imm16());    	 -- jp PO, mn  
		elseif f1 == 0xe3 then ex_sp(hl);               	 -- ex (SP), HL  
		elseif f1 == 0xe4 then call(f.npv(), imm16());  	 -- call PO, mn  
		elseif f1 == 0xe5 then push(hl);                	 -- push HL  
		elseif f1 == 0xe6 then And(imm8());             	 -- and n  
		elseif f1 == 0xe7 then rst(0x20);               	 -- rst 20H  

		elseif f1 == 0xe8 then ret(f.pv());            	 -- ret PE  
		elseif f1 == 0xe9 then jp(1, hl);              	 -- jp (HL)  
		elseif f1 == 0xea then jp(f.pv(), imm16());    	 -- jp PE, mn  
		elseif f1 == 0xeb then ex_r(de, hl);           	 -- ex DE, HL  
		elseif f1 == 0xec then call(f.pv(), imm16());  	 -- call PE, mn  
		elseif f1 == 0xed then
			pc = pc + 1
			local f13 = fetchEDXX()
			
			if     f13 == 0x40 then in_c(b);            	 -- in B, (C)  
			elseif f13 == 0x41 then out_c(b);           	 -- out (C), B  
			elseif f13 == 0x42 then sbc16(hl, bc);      	 -- sbc HL, BC  
			elseif f13 == 0x43 then st16(imm16(), bc);  	 -- ld (mn), BC  
			elseif f13 == 0x44 then neg();              	 -- neg  
			elseif f13 == 0x45 then retn();             	 -- retn  
			elseif f13 == 0x46 then im(0);              	 -- im 0  
			elseif f13 == 0x47 then ld8(i, a);          	 -- ld I, A  

			elseif f13 == 0x48 then in_c(c);                   	 -- in C, (C)  
			elseif f13 == 0x49 then out_c(c);                  	 -- out (C), C  
			elseif f13 == 0x4a then adc16(hl, bc);             	 -- adc HL, BC  
			elseif f13 == 0x4b then ld16(bc, mem16(imm16()));  	 -- ld BC, (mn)  
			elseif f13 == 0x4c then neg();                     	 -- neg  
			elseif f13 == 0x4d then reti();                    	 -- reti  
			elseif f13 == 0x4e then im(0);                     	 -- im 0  
			elseif f13 == 0x4f then nop();                     	 -- ld R, A  

			elseif f13 == 0x50 then in_c(d);            	 -- in D, (C)  
			elseif f13 == 0x51 then out_c(d);           	 -- out (C), D  
			elseif f13 == 0x52 then sbc16(hl, de);      	 -- sbc HL, DE  
			elseif f13 == 0x53 then st16(imm16(), de);  	 -- ld (mn), DE  
			elseif f13 == 0x54 then neg();              	 -- neg  
			elseif f13 == 0x55 then retn();             	 -- retn  
			elseif f13 == 0x56 then im(1);              	 -- im 1  
			elseif f13 == 0x57 then ld_a_i();           	 -- ld A, I  

			elseif f13 == 0x58 then in_c(e);                   	 -- in E, (C)  
			elseif f13 == 0x59 then out_c(e);                  	 -- out (C), E  
			elseif f13 == 0x5a then adc16(hl, de);             	 -- adc HL, DE  
			elseif f13 == 0x5b then ld16(de, mem16(imm16()));  	 -- ld DE, (mn)  
			elseif f13 == 0x5c then neg();                     	 -- neg  
			elseif f13 == 0x5d then retn();                    	 -- retn  
			elseif f13 == 0x5e then im(2);                     	 -- im 2  
			elseif f13 == 0x5f then ld_a_r();                  	 -- ld A, R  

			elseif f13 == 0x60 then in_c(h);            	 -- in H, (C)  
			elseif f13 == 0x61 then out_c(h);           	 -- out (C), H  
			elseif f13 == 0x62 then sbc16(hl, hl);      	 -- sbc HL, HL  
			elseif f13 == 0x63 then st16(imm16(), hl);  	 -- ld (mn), HL  
			elseif f13 == 0x64 then neg();              	 -- neg  
			elseif f13 == 0x65 then retn();             	 -- retn  
			elseif f13 == 0x66 then im(0);              	 -- im 0  
			elseif f13 == 0x67 then rrd();              	 -- rrd  

			elseif f13 == 0x68 then in_c(l);                   	 -- in L, (C)  
			elseif f13 == 0x69 then out_c(l);                  	 -- out (C), L  
			elseif f13 == 0x6a then adc16(hl, hl);             	 -- adc HL, HL  
			elseif f13 == 0x6b then ld16(hl, mem16(imm16()));  	 -- ld HL, (mn)  
			elseif f13 == 0x6c then neg();                     	 -- neg  
			elseif f13 == 0x6d then retn();                    	 -- retn  
			elseif f13 == 0x6e then im(0);                     	 -- im 0  
			elseif f13 == 0x6f then rld();                     	 -- rld  

			elseif f13 == 0x70 then in_c(f);            	 -- in F, (C)  
			elseif f13 == 0x71 then out_c_0();          	 -- out (C), 0  
			elseif f13 == 0x72 then sbc16(hl, sp);      	 -- sbc HL, SP  
			elseif f13 == 0x73 then st16(imm16(), sp);  	 -- ld (mn), SP  
			elseif f13 == 0x74 then neg();              	 -- neg  
			elseif f13 == 0x75 then retn();             	 -- retn  
			elseif f13 == 0x76 then im(1);              	 -- im 1  

			elseif f13 == 0x78 then in_c(a);                   	 -- in A, (C)  
			elseif f13 == 0x79 then out_c(a);                  	 -- out (C), A  
			elseif f13 == 0x7a then adc16(hl, sp);             	 -- adc HL, SP  
			elseif f13 == 0x7b then ld16(sp, mem16(imm16()));  	 -- ld SP, (mn)  
			elseif f13 == 0x7c then neg();                     	 -- neg  
			elseif f13 == 0x7d then retn();                    	 -- retn  
			elseif f13 == 0x7e then im(2);                     	 -- im 2  

			elseif f13 == 0xa0 then ldi();   	 -- ldi  
			elseif f13 == 0xa1 then cpi();   	 -- cpi  
			elseif f13 == 0xa2 then ini();   	 -- ini  
			elseif f13 == 0xa3 then outi();  	 -- outi  

			elseif f13 == 0xa8 then ldd();   	 -- ldd  
			elseif f13 == 0xa9 then cpd();   	 -- cpd  
			elseif f13 == 0xaa then ind();   	 -- ind  
			elseif f13 == 0xab then outd();  	 -- outd  

			elseif f13 == 0xb0 then ldir();  	 -- ldir  
			elseif f13 == 0xb1 then cpir();  	 -- cpir  
			elseif f13 == 0xb2 then inir();  	 -- inir  
			elseif f13 == 0xb3 then otir();  	 -- otir  

			elseif f13 == 0xb8 then lddr();  	 -- lddr  
			elseif f13 == 0xb9 then cpdr();  	 -- cpdr  
			elseif f13 == 0xba then indr();  	 -- indr  
			elseif f13 == 0xbb then otdr();  	 -- otdr  
			else pc = pc + length; 
			
			end
			
		elseif f1 == 0xee then xor(imm8());  	 -- xor n  
		elseif f1 == 0xef then rst(0x28);    	 -- rst 28H  

		elseif f1 == 0xf0 then ret(f.ns());            	 -- ret P  
		elseif f1 == 0xf1 then pop(af);                	 -- pop AF  
		elseif f1 == 0xf2 then jp(f.ns(), imm16());    	 -- jp P, mn  
		elseif f1 == 0xf3 then di();                   	 -- di  
		elseif f1 == 0xf4 then call(f.ns(), imm16());  	 -- call P, mn  
		elseif f1 == 0xf5 then push(af);               	 -- push AF  
		elseif f1 == 0xf6 then Or(imm8());             	 -- or n  
		elseif f1 == 0xf7 then rst(0x30);              	 -- rst 30H  

		elseif f1 == 0xf8 then ret(f.s());            	 -- ret M  
		elseif f1 == 0xf9 then ld16(sp, hl);          	 -- ld SP, HL  
		elseif f1 == 0xfa then jp(f.s(), imm16());    	 -- jp M, mn  
		elseif f1 == 0xfb then if(ei()) then   else  break; end	 -- ei  
		elseif f1 == 0xfc then call(f.s(), imm16());  	 -- call M, mn  
		elseif f1 == 0xfd then
			pc = pc + 1
			local f14 = fetchFDXX()

			if     f14 == 0x09 then add16(iy, bc);  	 -- add IY, BC  
			elseif f14 == 0x19 then add16(iy, de);  	 -- add IY, DE  
			elseif f14 == 0x21 then ld16(iy, imm16());  	 -- ld IY, mn  
			elseif f14 == 0x22 then st16(imm16(), iy);  	 -- ld (mn), IY  
			elseif f14 == 0x23 then inc16(iy);          	 -- inc IY  
			elseif f14 == 0x24 then inc8_r(iyh);        	 -- inc IYh  
			elseif f14 == 0x25 then dec8_r(iyh);        	 -- dec IYh  
			elseif f14 == 0x26 then ld8(iyh, imm8());   	 -- ld IYh, n  

			elseif f14 == 0x29 then add16(iy, iy);             	 -- add IY, IY  
			elseif f14 == 0x2a then ld16(iy, mem16(imm16()));  	 -- ld IY, (mn)  
			elseif f14 == 0x2b then dec16(iy);                 	 -- dec IY  
			elseif f14 == 0x2c then inc8_r(iyl);               	 -- inc IYl  
			elseif f14 == 0x2d then dec8_r(iyl);               	 -- dec IYl  
			elseif f14 == 0x2e then ld8(iyl, imm8());          	 -- ld IYl, n  

			elseif f14 == 0x34 then inc8_m(iy.get() + dis());             	 -- inc (IY + d)  
			elseif f14 == 0x35 then dec8_m(iy.get() + dis());             	 -- dec (IY + d)  
			elseif f14 == 0x36 then st8(iy.get() + dis(), mem8(pc + 2));  	 -- ld (IY + d), n  

			elseif f14 == 0x39 then add16(iy, sp);  	 -- ADD IY, SP  

			elseif f14 == 0x44 then ld8(b, iyh);                  	 -- ld B, IYh  
			elseif f14 == 0x45 then ld8(b, iyl);                  	 -- ld B, IYl  
			elseif f14 == 0x46 then ld8(b, mem8(iy.get() + dis()));  	 -- ld B, (IY + d)  

			elseif f14 == 0x4c then ld8(c, iyh);                  	 -- ld C, IYh  
			elseif f14 == 0x4d then ld8(c, iyl);                  	 -- ld C, IYl  
			elseif f14 == 0x4e then ld8(c, mem8(iy.get() + dis()));  	 -- ld C, (IY + d)  

			elseif f14 == 0x54 then ld8(d, iyh);                  	 -- ld D, IYh  
			elseif f14 == 0x55 then ld8(d, iyl);                  	 -- ld D, IYl  
			elseif f14 == 0x56 then ld8(d, mem8(iy.get() + dis()));  	 -- ld D, (IY + d)  

			elseif f14 == 0x5c then ld8(e, iyh);                  	 -- ld E, IYh  
			elseif f14 == 0x5d then ld8(e, iyl);                  	 -- ld E, IYl  
			elseif f14 == 0x5e then ld8(e, mem8(iy.get() + dis()));  	 -- ld E, (IY + d)  

			elseif f14 == 0x60 then ld8(iyh, b);                  	 -- ld IYh, B  
			elseif f14 == 0x61 then ld8(iyh, c);                  	 -- ld IYh, C  
			elseif f14 == 0x62 then ld8(iyh, d);                  	 -- ld IYh, D  
			elseif f14 == 0x63 then ld8(iyh, e);                  	 -- ld IYh, E  
			elseif f14 == 0x64 then ld8(iyh, h);                  	 -- ld IYh, H  
			elseif f14 == 0x65 then ld8(iyh, l);                  	 -- ld IYh, L  
			elseif f14 == 0x66 then ld8(h, mem8(iy.get() + dis()));  	 -- ld H, (IY + d)  
			elseif f14 == 0x67 then ld8(iyh, a);                  	 -- ld IYh, A  

			elseif f14 == 0x68 then ld8(iyl, b);                  	 -- ld IYl, B  
			elseif f14 == 0x69 then ld8(iyl, c);                  	 -- ld IYl, C  
			elseif f14 == 0x6a then ld8(iyl, d);                  	 -- ld IYl, D  
			elseif f14 == 0x6b then ld8(iyl, e);                  	 -- ld IYl, E  
			elseif f14 == 0x6c then ld8(iyl, h);                  	 -- ld IYl, H  
			elseif f14 == 0x6d then ld8(iyl, l);                  	 -- ld IYl, L  
			elseif f14 == 0x6e then ld8(l, mem8(iy.get() + dis()));  	 -- ld L, (IY + d)  
			elseif f14 == 0x6f then ld8(iyl, a);                  	 -- ld IYl, A  

			elseif f14 == 0x70 then st8(iy.get() + dis(), b);  	 -- ld (IY + d), B  
			elseif f14 == 0x71 then st8(iy.get() + dis(), c);  	 -- ld (IY + d), C  
			elseif f14 == 0x72 then st8(iy.get() + dis(), d);  	 -- ld (IY + d), D  
			elseif f14 == 0x73 then st8(iy.get() + dis(), e);  	 -- ld (IY + d), E  
			elseif f14 == 0x74 then st8(iy.get() + dis(), h);  	 -- ld (IY + d), H  
			elseif f14 == 0x75 then st8(iy.get() + dis(), l);  	 -- ld (IY + d), L  
			elseif f14 == 0x77 then st8(iy.get() + dis(), a);  	 -- ld (IY + d), A  

			elseif f14 == 0x7c then ld8(a, iyh);                  	 -- ld A, IYh  
			elseif f14 == 0x7d then ld8(a, iyl);                  	 -- ld A, IYl  
			elseif f14 == 0x7e then ld8(a, mem8(iy.get() + dis()));  	 -- ld A, (IY + d)  

			elseif f14 == 0x84 then add8(iyh);                  	 -- add IYh  
			elseif f14 == 0x85 then add8(iyl);                  	 -- add IYl  
			elseif f14 == 0x86 then add8(mem8(iy.get() + dis()));  	 -- add (IY + d)  

			elseif f14 == 0x8c then adc8(iyh);                  	 -- adc IYh  
			elseif f14 == 0x8d then adc8(iyl);                  	 -- adc IYl  
			elseif f14 == 0x8e then adc8(mem8(iy.get() + dis()));  	 -- adc (IY + d)  

			elseif f14 == 0x94 then sub8(iyh);                  	 -- sub IYh  
			elseif f14 == 0x95 then sub8(iyl);                  	 -- sub IYl  
			elseif f14 == 0x96 then sub8(mem8(iy.get() + dis()));  	 -- sub (IY + d)  

			elseif f14 == 0x9c then sbc8(iyh);                  	 -- sbc IYh  
			elseif f14 == 0x9d then sbc8(iyl);                  	 -- sbc IYl  
			elseif f14 == 0x9e then sbc8(mem8(iy.get() + dis()));  	 -- sbc (IY + d)  

			elseif f14 == 0xa4 then And(iyh);                  	 -- and IYh  
			elseif f14 == 0xa5 then And(iyl);                  	 -- and IYl  
			elseif f14 == 0xa6 then And(mem8(iy.get() + dis()));  	 -- and (IY + d)  

			elseif f14 == 0xac then Xor(iyh);                  	 -- xor IYh  
			elseif f14 == 0xad then Xor(iyl);                  	 -- xor IYl  
			elseif f14 == 0xae then Xor(mem8(iy.get() + dis()));  	 -- xor (IY + d)  

			elseif f14 == 0xb4 then Or(iyh);                  	 -- or IYh  
			elseif f14 == 0xb5 then Or(iyl);                  	 -- or IYl  
			elseif f14 == 0xb6 then Or(mem8(iy.get() + dis()));  	 -- or (IY + d)  

			elseif f14 == 0xbc then cp(iyh);                  	 -- cp IYh  
			elseif f14 == 0xbd then cp(iyl);                  	 -- cp IYl  
			elseif f14 == 0xbe then cp(mem8(iy.get() + dis()));  	 -- cp (IY + d)  

			elseif f14 == 0xcb then
				local f141 = fetchFDCBXX()

				if     f141 == 0x00 then rlc_m_r(iy.get() + dis(), b);  	 -- rlc (IY + d), B  
				elseif f141 == 0x01 then rlc_m_r(iy.get() + dis(), c);  	 -- rlc (IY + d), C  
				elseif f141 == 0x02 then rlc_m_r(iy.get() + dis(), d);  	 -- rlc (IY + d), D  
				elseif f141 == 0x03 then rlc_m_r(iy.get() + dis(), e);  	 -- rlc (IY + d), E  
				elseif f141 == 0x04 then rlc_m_r(iy.get() + dis(), h);  	 -- rlc (IY + d), H  
				elseif f141 == 0x05 then rlc_m_r(iy.get() + dis(), l);  	 -- rlc (IY + d), L  
				elseif f141 == 0x06 then rlc_m(iy.get() + dis());       	 -- rlc (IY + d)  
				elseif f141 == 0x07 then rlc_m_r(iy.get() + dis(), a);  	 -- rlc (IY + d), A  

				elseif f141 == 0x08 then rrc_m_r(iy.get() + dis(), b);  	 -- rrc (IY + d), B  
				elseif f141 == 0x09 then rrc_m_r(iy.get() + dis(), c);  	 -- rrc (IY + d), C  
				elseif f141 == 0x0a then rrc_m_r(iy.get() + dis(), d);  	 -- rrc (IY + d), D  
				elseif f141 == 0x0b then rrc_m_r(iy.get() + dis(), e);  	 -- rrc (IY + d), E  
				elseif f141 == 0x0c then rrc_m_r(iy.get() + dis(), h);  	 -- rrc (IY + d), H  
				elseif f141 == 0x0d then rrc_m_r(iy.get() + dis(), l);  	 -- rrc (IY + d), L  
				elseif f141 == 0x0e then rrc_m(iy.get() + dis());       	 -- rrc (IY + d)  
				elseif f141 == 0x0f then rrc_m_r(iy.get() + dis(), a);  	 -- rrc (IY + d), A  

				elseif f141 == 0x10 then rl_m_r(iy.get() + dis(), b);  	 -- rl (IY + d), B  
				elseif f141 == 0x11 then rl_m_r(iy.get() + dis(), c);  	 -- rl (IY + d), C  
				elseif f141 == 0x12 then rl_m_r(iy.get() + dis(), d);  	 -- rl (IY + d), D  
				elseif f141 == 0x13 then rl_m_r(iy.get() + dis(), e);  	 -- rl (IY + d), E  
				elseif f141 == 0x14 then rl_m_r(iy.get() + dis(), h);  	 -- rl (IY + d), H  
				elseif f141 == 0x15 then rl_m_r(iy.get() + dis(), l);  	 -- rl (IY + d), L  
				elseif f141 == 0x16 then rl_m(iy.get() + dis());       	 -- rl (IY + d)  
				elseif f141 == 0x17 then rl_m_r(iy.get() + dis(), a);  	 -- rl (IY + d), A  

				elseif f141 == 0x18 then rr_m_r(iy.get() + dis(), b);  	 -- rr (IY + d), B  
				elseif f141 == 0x19 then rr_m_r(iy.get() + dis(), c);  	 -- rr (IY + d), C  
				elseif f141 == 0x1a then rr_m_r(iy.get() + dis(), d);  	 -- rr (IY + d), D  
				elseif f141 == 0x1b then rr_m_r(iy.get() + dis(), e);  	 -- rr (IY + d), E  
				elseif f141 == 0x1c then rr_m_r(iy.get() + dis(), h);  	 -- rr (IY + d), H  
				elseif f141 == 0x1d then rr_m_r(iy.get() + dis(), l);  	 -- rr (IY + d), L  
				elseif f141 == 0x1e then rr_m(iy.get() + dis());       	 -- rr (IY + d)  
				elseif f141 == 0x1f then rr_m_r(iy.get() + dis(), a);  	 -- rr (IY + d), A  

				elseif f141 == 0x20 then sla_m_r(iy.get() + dis(), b);  	 -- sla (IY + d), B  
				elseif f141 == 0x21 then sla_m_r(iy.get() + dis(), c);  	 -- sla (IY + d), C  
				elseif f141 == 0x22 then sla_m_r(iy.get() + dis(), d);  	 -- sla (IY + d), D  
				elseif f141 == 0x23 then sla_m_r(iy.get() + dis(), e);  	 -- sla (IY + d), E  
				elseif f141 == 0x24 then sla_m_r(iy.get() + dis(), h);  	 -- sla (IY + d), H  
				elseif f141 == 0x25 then sla_m_r(iy.get() + dis(), l);  	 -- sla (IY + d), L  
				elseif f141 == 0x26 then sla_m(iy.get() + dis());       	 -- sla (IY + d)  
				elseif f141 == 0x27 then sla_m_r(iy.get() + dis(), a);  	 -- sla (IY + d), A  

				elseif f141 == 0x28 then sra_m_r(iy.get() + dis(), b);  	 -- sra (IY + d), B  
				elseif f141 == 0x29 then sra_m_r(iy.get() + dis(), c);  	 -- sra (IY + d), C  
				elseif f141 == 0x2a then sra_m_r(iy.get() + dis(), d);  	 -- sra (IY + d), D  
				elseif f141 == 0x2b then sra_m_r(iy.get() + dis(), e);  	 -- sra (IY + d), E  
				elseif f141 == 0x2c then sra_m_r(iy.get() + dis(), h);  	 -- sra (IY + d), H  
				elseif f141 == 0x2d then sra_m_r(iy.get() + dis(), l);  	 -- sra (IY + d), L  
				elseif f141 == 0x2e then sra_m(iy.get() + dis());       	 -- sra (IY + d)  
				elseif f141 == 0x2f then sra_m_r(iy.get() + dis(), a);  	 -- sra (IY + d), A  

				elseif f141 == 0x30 then sll_m_r(iy.get() + dis(), b);  	 -- sll (IY + d), B  
				elseif f141 == 0x31 then sll_m_r(iy.get() + dis(), c);  	 -- sll (IY + d), C  
				elseif f141 == 0x32 then sll_m_r(iy.get() + dis(), d);  	 -- sll (IY + d), D  
				elseif f141 == 0x33 then sll_m_r(iy.get() + dis(), e);  	 -- sll (IY + d), E  
				elseif f141 == 0x34 then sll_m_r(iy.get() + dis(), h);  	 -- sll (IY + d), H  
				elseif f141 == 0x35 then sll_m_r(iy.get() + dis(), l);  	 -- sll (IY + d), L  
				elseif f141 == 0x36 then sll_m(iy.get() + dis());       	 -- sll (IY + d)  
				elseif f141 == 0x37 then sll_m_r(iy.get() + dis(), a);  	 -- sll (IY + d), A  

				elseif f141 == 0x38 then srl_m_r(iy.get() + dis(), b);  	 -- srl (IY + d), B  
				elseif f141 == 0x39 then srl_m_r(iy.get() + dis(), c);  	 -- srl (IY + d), C  
				elseif f141 == 0x3a then srl_m_r(iy.get() + dis(), d);  	 -- srl (IY + d), D  
				elseif f141 == 0x3b then srl_m_r(iy.get() + dis(), e);  	 -- srl (IY + d), E  
				elseif f141 == 0x3c then srl_m_r(iy.get() + dis(), h);  	 -- srl (IY + d), H  
				elseif f141 == 0x3d then srl_m_r(iy.get() + dis(), l);  	 -- srl (IY + d), L  
				elseif f141 == 0x3e then srl_m(iy.get() + dis());       	 -- srl (IY + d)  
				elseif f141 == 0x3f then srl_m_r(iy.get() + dis(), a);  	 -- srl (IY + d), A  

				elseif f141 == 0x40 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x41 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x42 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x43 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x44 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x45 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x46 then bit(0, mem8(iy.get() + dis()));     -- bit 0, (IY + d)
				elseif f141 == 0x47 then bit(0, mem8(iy.get() + dis()));  	 -- bit 0, (IY + d)  

				elseif f141 == 0x48 then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x49 then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x4a then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x4b then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x4c then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x4d then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x4e then bit(1, mem8(iy.get() + dis()));     -- bit 1, (IY + d)
				elseif f141 == 0x4f then bit(1, mem8(iy.get() + dis()));  	 -- bit 1, (IY + d)  

				elseif f141 == 0x50 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x51 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x52 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x53 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x54 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x55 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x56 then bit(2, mem8(iy.get() + dis()));     -- bit 2, (IY + d)
				elseif f141 == 0x57 then bit(2, mem8(iy.get() + dis()));  	 -- bit 2, (IY + d)  

				elseif f141 == 0x58 then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x59 then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x5a then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x5b then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x5c then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x5d then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x5e then bit(3, mem8(iy.get() + dis()));     -- bit 3, (IY + d) 
				elseif f141 == 0x5f then bit(3, mem8(iy.get() + dis()));  	 -- bit 3, (IY + d)  

				elseif f141 == 0x60 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x61 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x62 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x63 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x64 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x65 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x66 then bit(4, mem8(iy.get() + dis()));     -- bit 4, (IY + d)
				elseif f141 == 0x67 then bit(4, mem8(iy.get() + dis()));  	 -- bit 4, (IY + d)  

				elseif f141 == 0x68 then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x69 then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x6a then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x6b then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x6c then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x6d then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x6e then bit(5, mem8(iy.get() + dis()));     -- bit 5, (IY + d)
				elseif f141 == 0x6f then bit(5, mem8(iy.get() + dis()));  	 -- bit 5, (IY + d)  

				elseif f141 == 0x70 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x71 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x72 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x73 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x74 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x75 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x76 then bit(6, mem8(iy.get() + dis()));     -- bit 6, (IY + d)
				elseif f141 == 0x77 then bit(6, mem8(iy.get() + dis()));  	 -- bit 6, (IY + d)  

				elseif f141 == 0x78 then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x79 then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x7a then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x7b then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x7c then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x7d then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x7e then bit(7, mem8(iy.get() + dis()));     -- bit 7, (IY + d)
				elseif f141 == 0x7f then bit(7, mem8(iy.get() + dis()));  	 -- bit 7, (IY + d)  

				elseif f141 == 0x80 then res_m_r(0, iy.get() + dis(), b);  	 -- res 0, (IY + d), B  
				elseif f141 == 0x81 then res_m_r(0, iy.get() + dis(), c);  	 -- res 0, (IY + d), C  
				elseif f141 == 0x82 then res_m_r(0, iy.get() + dis(), d);  	 -- res 0, (IY + d), D  
				elseif f141 == 0x83 then res_m_r(0, iy.get() + dis(), e);  	 -- res 0, (IY + d), E  
				elseif f141 == 0x84 then res_m_r(0, iy.get() + dis(), h);  	 -- res 0, (IY + d), H  
				elseif f141 == 0x85 then res_m_r(0, iy.get() + dis(), l);  	 -- res 0, (IY + d), L  
				elseif f141 == 0x86 then res_m(0, iy.get() + dis());       	 -- res 0, (IY + d)  
				elseif f141 == 0x87 then res_m_r(0, iy.get() + dis(), a);  	 -- res 0, (IY + d), A  

				elseif f141 == 0x88 then res_m_r(1, iy.get() + dis(), b);  	 -- res 1, (IY + d), B  
				elseif f141 == 0x89 then res_m_r(1, iy.get() + dis(), c);  	 -- res 1, (IY + d), C  
				elseif f141 == 0x8a then res_m_r(1, iy.get() + dis(), d);  	 -- res 1, (IY + d), D  
				elseif f141 == 0x8b then res_m_r(1, iy.get() + dis(), e);  	 -- res 1, (IY + d), E  
				elseif f141 == 0x8c then res_m_r(1, iy.get() + dis(), h);  	 -- res 1, (IY + d), H  
				elseif f141 == 0x8d then res_m_r(1, iy.get() + dis(), l);  	 -- res 1, (IY + d), L  
				elseif f141 == 0x8e then res_m(1, iy.get() + dis());       	 -- res 1, (IY + d)  
				elseif f141 == 0x8f then res_m_r(1, iy.get() + dis(), a);  	 -- res 1, (IY + d), A  

				elseif f141 == 0x90 then res_m_r(2, iy.get() + dis(), b);  	 -- res 2, (IY + d), B  
				elseif f141 == 0x91 then res_m_r(2, iy.get() + dis(), c);  	 -- res 2, (IY + d), C  
				elseif f141 == 0x92 then res_m_r(2, iy.get() + dis(), d);  	 -- res 2, (IY + d), D  
				elseif f141 == 0x93 then res_m_r(2, iy.get() + dis(), e);  	 -- res 2, (IY + d), E  
				elseif f141 == 0x94 then res_m_r(2, iy.get() + dis(), h);  	 -- res 2, (IY + d), H  
				elseif f141 == 0x95 then res_m_r(2, iy.get() + dis(), l);  	 -- res 2, (IY + d), L  
				elseif f141 == 0x96 then res_m(2, iy.get() + dis());       	 -- res 2, (IY + d)  
				elseif f141 == 0x97 then res_m_r(2, iy.get() + dis(), a);  	 -- res 2, (IY + d), A  

				elseif f141 == 0x98 then res_m_r(3, iy.get() + dis(), b);  	 -- res 3, (IY + d), B  
				elseif f141 == 0x99 then res_m_r(3, iy.get() + dis(), c);  	 -- res 3, (IY + d), C  
				elseif f141 == 0x9a then res_m_r(3, iy.get() + dis(), d);  	 -- res 3, (IY + d), D  
				elseif f141 == 0x9b then res_m_r(3, iy.get() + dis(), e);  	 -- res 3, (IY + d), E  
				elseif f141 == 0x9c then res_m_r(3, iy.get() + dis(), h);  	 -- res 3, (IY + d), H  
				elseif f141 == 0x9d then res_m_r(3, iy.get() + dis(), l);  	 -- res 3, (IY + d), L  
				elseif f141 == 0x9e then res_m(3, iy.get() + dis());       	 -- res 3, (IY + d)  
				elseif f141 == 0x9f then res_m_r(3, iy.get() + dis(), a);  	 -- res 3, (IY + d), A  

				elseif f141 == 0xa0 then res_m_r(4, iy.get() + dis(), b);  	 -- res 4, (IY + d), B  
				elseif f141 == 0xa1 then res_m_r(4, iy.get() + dis(), c);  	 -- res 4, (IY + d), C  
				elseif f141 == 0xa2 then res_m_r(4, iy.get() + dis(), d);  	 -- res 4, (IY + d), D  
				elseif f141 == 0xa3 then res_m_r(4, iy.get() + dis(), e);  	 -- res 4, (IY + d), E  
				elseif f141 == 0xa4 then res_m_r(4, iy.get() + dis(), h);  	 -- res 4, (IY + d), H  
				elseif f141 == 0xa5 then res_m_r(4, iy.get() + dis(), l);  	 -- res 4, (IY + d), L  
				elseif f141 == 0xa6 then res_m(4, iy.get() + dis());       	 -- res 4, (IY + d)  
				elseif f141 == 0xa7 then res_m_r(4, iy.get() + dis(), a);  	 -- res 4, (IY + d), A  

				elseif f141 == 0xa8 then res_m_r(5, iy.get() + dis(), b);  	 -- res 5, (IY + d), B  
				elseif f141 == 0xa9 then res_m_r(5, iy.get() + dis(), c);  	 -- res 5, (IY + d), C  
				elseif f141 == 0xaa then res_m_r(5, iy.get() + dis(), d);  	 -- res 5, (IY + d), D  
				elseif f141 == 0xab then res_m_r(5, iy.get() + dis(), e);  	 -- res 5, (IY + d), E  
				elseif f141 == 0xac then res_m_r(5, iy.get() + dis(), h);  	 -- res 5, (IY + d), H  
				elseif f141 == 0xad then res_m_r(5, iy.get() + dis(), l);  	 -- res 5, (IY + d), L  
				elseif f141 == 0xae then res_m(5, iy.get() + dis());       	 -- res 5, (IY + d)  
				elseif f141 == 0xaf then res_m_r(5, iy.get() + dis(), a);  	 -- res 5, (IY + d), A  

				elseif f141 == 0xb0 then res_m_r(6, iy.get() + dis(), b);  	 -- res 6, (IY + d), B  
				elseif f141 == 0xb1 then res_m_r(6, iy.get() + dis(), c);  	 -- res 6, (IY + d), C  
				elseif f141 == 0xb2 then res_m_r(6, iy.get() + dis(), d);  	 -- res 6, (IY + d), D  
				elseif f141 == 0xb3 then res_m_r(6, iy.get() + dis(), e);  	 -- res 6, (IY + d), E  
				elseif f141 == 0xb4 then res_m_r(6, iy.get() + dis(), h);  	 -- res 6, (IY + d), H  
				elseif f141 == 0xb5 then res_m_r(6, iy.get() + dis(), l);  	 -- res 6, (IY + d), L  
				elseif f141 == 0xb6 then res_m(6, iy.get() + dis());       	 -- res 6, (IY + d)  
				elseif f141 == 0xb7 then res_m_r(6, iy.get() + dis(), a);  	 -- res 6, (IY + d), A  

				elseif f141 == 0xb8 then res_m_r(7, iy.get() + dis(), b);  	 -- res 7, (IY + d), B  
				elseif f141 == 0xb9 then res_m_r(7, iy.get() + dis(), c);  	 -- res 7, (IY + d), C  
				elseif f141 == 0xba then res_m_r(7, iy.get() + dis(), d);  	 -- res 7, (IY + d), D  
				elseif f141 == 0xbb then res_m_r(7, iy.get() + dis(), e);  	 -- res 7, (IY + d), E  
				elseif f141 == 0xbc then res_m_r(7, iy.get() + dis(), h);  	 -- res 7, (IY + d), H  
				elseif f141 == 0xbd then res_m_r(7, iy.get() + dis(), l);  	 -- res 7, (IY + d), L  
				elseif f141 == 0xbe then res_m(7, iy.get() + dis());       	 -- res 7, (IY + d)  
				elseif f141 == 0xbf then res_m_r(7, iy.get() + dis(), a);  	 -- res 7, (IY + d), A  

				elseif f141 == 0xc0 then set_m_r(0, iy.get() + dis(), b);  	 -- set 0, (IY + d), B  
				elseif f141 == 0xc1 then set_m_r(0, iy.get() + dis(), c);  	 -- set 0, (IY + d), C  
				elseif f141 == 0xc2 then set_m_r(0, iy.get() + dis(), d);  	 -- set 0, (IY + d), D  
				elseif f141 == 0xc3 then set_m_r(0, iy.get() + dis(), e);  	 -- set 0, (IY + d), E  
				elseif f141 == 0xc4 then set_m_r(0, iy.get() + dis(), h);  	 -- set 0, (IY + d), H  
				elseif f141 == 0xc5 then set_m_r(0, iy.get() + dis(), l);  	 -- set 0, (IY + d), L  
				elseif f141 == 0xc6 then set_m(0, iy.get() + dis());       	 -- set 0, (IY + d)  
				elseif f141 == 0xc7 then set_m_r(0, iy.get() + dis(), a);  	 -- set 0, (IY + d), A  

				elseif f141 == 0xc8 then set_m_r(1, iy.get() + dis(), b);  	 -- set 1, (IY + d), B  
				elseif f141 == 0xc9 then set_m_r(1, iy.get() + dis(), c);  	 -- set 1, (IY + d), C  
				elseif f141 == 0xca then set_m_r(1, iy.get() + dis(), d);  	 -- set 1, (IY + d), D  
				elseif f141 == 0xcb then set_m_r(1, iy.get() + dis(), e);  	 -- set 1, (IY + d), E  
				elseif f141 == 0xcc then set_m_r(1, iy.get() + dis(), h);  	 -- set 1, (IY + d), H  
				elseif f141 == 0xcd then set_m_r(1, iy.get() + dis(), l);  	 -- set 1, (IY + d), L  
				elseif f141 == 0xce then set_m(1, iy.get() + dis());       	 -- set 1, (IY + d)  
				elseif f141 == 0xcf then set_m_r(1, iy.get() + dis(), a);  	 -- set 1, (IY + d), A  

				elseif f141 == 0xd0 then set_m_r(2, iy.get() + dis(), b);  	 -- set 2, (IY + d), B  
				elseif f141 == 0xd1 then set_m_r(2, iy.get() + dis(), c);  	 -- set 2, (IY + d), C  
				elseif f141 == 0xd2 then set_m_r(2, iy.get() + dis(), d);  	 -- set 2, (IY + d), D  
				elseif f141 == 0xd3 then set_m_r(2, iy.get() + dis(), e);  	 -- set 2, (IY + d), E  
				elseif f141 == 0xd4 then set_m_r(2, iy.get() + dis(), h);  	 -- set 2, (IY + d), H  
				elseif f141 == 0xd5 then set_m_r(2, iy.get() + dis(), l);  	 -- set 2, (IY + d), L  
				elseif f141 == 0xd6 then set_m(2, iy.get() + dis());       	 -- set 2, (IY + d)  
				elseif f141 == 0xd7 then set_m_r(2, iy.get() + dis(), a);  	 -- set 2, (IY + d), A  

				elseif f141 == 0xd8 then set_m_r(3, iy.get() + dis(), b);  	 -- set 3, (IY + d), B  
				elseif f141 == 0xd9 then set_m_r(3, iy.get() + dis(), c);  	 -- set 3, (IY + d), C  
				elseif f141 == 0xda then set_m_r(3, iy.get() + dis(), d);  	 -- set 3, (IY + d), D  
				elseif f141 == 0xdb then set_m_r(3, iy.get() + dis(), e);  	 -- set 3, (IY + d), E  
				elseif f141 == 0xdc then set_m_r(3, iy.get() + dis(), h);  	 -- set 3, (IY + d), H  
				elseif f141 == 0xdd then set_m_r(3, iy.get() + dis(), l);  	 -- set 3, (IY + d), L  
				elseif f141 == 0xde then set_m(3, iy.get() + dis());       	 -- set 3, (IY + d)  
				elseif f141 == 0xdf then set_m_r(3, iy.get() + dis(), a);  	 -- set 3, (IY + d), A  

				elseif f141 == 0xe0 then set_m_r(4, iy.get() + dis(), b);  	 -- set 4, (IY + d), B  
				elseif f141 == 0xe1 then set_m_r(4, iy.get() + dis(), c);  	 -- set 4, (IY + d), C  
				elseif f141 == 0xe2 then set_m_r(4, iy.get() + dis(), d);  	 -- set 4, (IY + d), D  
				elseif f141 == 0xe3 then set_m_r(4, iy.get() + dis(), e);  	 -- set 4, (IY + d), E  
				elseif f141 == 0xe4 then set_m_r(4, iy.get() + dis(), h);  	 -- set 4, (IY + d), H  
				elseif f141 == 0xe5 then set_m_r(4, iy.get() + dis(), l);  	 -- set 4, (IY + d), L  
				elseif f141 == 0xe6 then set_m(4, iy.get() + dis());       	 -- set 4, (IY + d)  
				elseif f141 == 0xe7 then set_m_r(4, iy.get() + dis(), a);  	 -- set 4, (IY + d), A  

				elseif f141 == 0xe8 then set_m_r(5, iy.get() + dis(), b);  	 -- set 5, (IY + d), B  
				elseif f141 == 0xe9 then set_m_r(5, iy.get() + dis(), c);  	 -- set 5, (IY + d), C  
				elseif f141 == 0xea then set_m_r(5, iy.get() + dis(), d);  	 -- set 5, (IY + d), D  
				elseif f141 == 0xeb then set_m_r(5, iy.get() + dis(), e);  	 -- set 5, (IY + d), E  
				elseif f141 == 0xec then set_m_r(5, iy.get() + dis(), h);  	 -- set 5, (IY + d), H  
				elseif f141 == 0xed then set_m_r(5, iy.get() + dis(), l);  	 -- set 5, (IY + d), L  
				elseif f141 == 0xee then set_m(5, iy.get() + dis());       	 -- set 5, (IY + d)  
				elseif f141 == 0xef then set_m_r(5, iy.get() + dis(), a);  	 -- set 5, (IY + d), A  

				elseif f141 == 0xf0 then set_m_r(6, iy.get() + dis(), b);  	 -- set 6, (IY + d), B  
				elseif f141 == 0xf1 then set_m_r(6, iy.get() + dis(), c);  	 -- set 6, (IY + d), C  
				elseif f141 == 0xf2 then set_m_r(6, iy.get() + dis(), d);  	 -- set 6, (IY + d), D  
				elseif f141 == 0xf3 then set_m_r(6, iy.get() + dis(), e);  	 -- set 6, (IY + d), E  
				elseif f141 == 0xf4 then set_m_r(6, iy.get() + dis(), h);  	 -- set 6, (IY + d), H  
				elseif f141 == 0xf5 then set_m_r(6, iy.get() + dis(), l);  	 -- set 6, (IY + d), L  
				elseif f141 == 0xf6 then set_m(6, iy.get() + dis());       	 -- set 6, (IY + d)  
				elseif f141 == 0xf7 then set_m_r(6, iy.get() + dis(), a);  	 -- set 6, (IY + d), A  

				elseif f141 == 0xf8 then set_m_r(7, iy.get() + dis(), b);  	 -- set 7, (IY + d), B  
				elseif f141 == 0xf9 then set_m_r(7, iy.get() + dis(), c);  	 -- set 7, (IY + d), C  
				elseif f141 == 0xfa then set_m_r(7, iy.get() + dis(), d);  	 -- set 7, (IY + d), D  
				elseif f141 == 0xfb then set_m_r(7, iy.get() + dis(), e);  	 -- set 7, (IY + d), E  
				elseif f141 == 0xfc then set_m_r(7, iy.get() + dis(), h);  	 -- set 7, (IY + d), H  
				elseif f141 == 0xfd then set_m_r(7, iy.get() + dis(), l);  	 -- set 7, (IY + d), L  
				elseif f141 == 0xfe then set_m(7, iy.get() + dis());       	 -- set 7, (IY + d)  
				elseif f141 == 0xff then set_m_r(7, iy.get() + dis(), a);  	 -- set 7, (IY + d), A  
				
				end
			
			elseif f14 == 0xe1 then pop(iy);    	 -- pop IY  
			elseif f14 == 0xe3 then ex_sp(iy);  	 -- ex (SP), IY  
			elseif f14 == 0xe5 then push(iy);   	 -- push IY  
			elseif f14 == 0xe9 then jp(1, iy);  	 -- jp (IY)  
			elseif f14 == 0xf9 then ld16(sp, iy);  	 -- ld SP, IY  
	
		elseif f1 == 0xfe then cp(imm8());		-- cp n 
		elseif f1 == 0xff then rst(0x38);		-- rst 38H
		
		end
		
		restStates = restStates - states;

		--until (restStates <= 0)	
		end

		return 0

	end
end
return Z80
