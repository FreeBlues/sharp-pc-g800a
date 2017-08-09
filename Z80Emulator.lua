--[[
--Zilog Z80 emulator for Java
--]]

Z80Emulator = {}

local Z80 = Z80Emulator

--
-- 8位寄存器
Z80.Register8  = { x = 0x00 }
local R8 = Z80.Register8

-- 构造函数
function R8:init(value)
	if value then 
		self.x = value & 0xff;
	elseif value == nil then
		self.x = 0 & 0xff;
	end
	return self.x
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

function R8:ncy() return R:cy() ~ Z80Emulator.MASK_CY; end

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
Z80.Register16 = {h = R8, l = R8}
local R16 = Z80.Register16

-- 构造函数 Register16(Register8 low, Register8 high)
function R16:init(low, high)
	self.l = low;
	self.h = high
end

-- 获取值 int get()
function R16:get()
	return (self.h.x << 8) | self.l.x;
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
Z80Emulator.MMASK_N  = 0x02

-- 奇偶/溢出标志 static final int MASK_PV
Z80Emulator.MMASK_PV = 0x04

-- 半进位标志 static final int MASK_HC
Z80Emulator.MMASK_HC = 0x10

-- 零标志 static final int MASK_Z
Z80Emulator.MMASK_Z  = 0x40

-- 注册标志 static final int MASK_S
Z80Emulator.MMASK_S  = 0x80

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
function Z80.Z80Emulator()
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

-- 输出日志 abstract void log(String message);
function Z80:log(message)

end

-- 读取内存（8位）abstract byte read(int address);
function Z80:read(address)

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
		Z80write8((address + 1) & 0xffff, value >>> 8);
	elseif typeAddress == "table" and typeValue == "number" then
		Z80:write16(address.get(), value);
	elseif typeAddress == "number" and typeValue == "table" then
		Z80:write16(address, value.get());
	elseif typeAddress == "table" and typeValue == "table" then
		Z80:write16(address.get(), value.get());
	end
end

-- 输入到 I/O abstract int inport(int address)
function Z80:inport(int address)

end

-- int inport(Register8 address)
function Z80:inport(address)
	return inport(address.get());
end

-- 输出到 I/O abstract void outport(int address, int value);
function Z80:outport(int address, int value)

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
	return (rnd >>> 25) & 0xff;
end

-- 改变进位标志（8位加法）int setCy8(int acc)
local function setCy8(acc)
	return ((acc & 0x00000100) != 0 and {MASK_CY} or {0})[1];
end

-- 改变进位标志（16位加法）int setCy16(int acc)
local function setCy16(acc) 
	return ((acc & 0x00010000) != 0 and {MASK_CY} or {0})[1];
end

-- 改变进位标志（减法）int setCyS(int acc)
local function setCyS(acc)
	return ((acc & 0x80000000) != 0 and {MASK_CY} or {0})[1];
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
		return (((x ~ y) & 0x80) != 0 and {0} or {(((x ~ acc) & 0x80) != 0 and {MASK_PV} or {0})[1]})[1];
	elseif typeX == "table" then
		local _x = x.get();
		return (((_x ~ y) & 0x80) != 0 and {0} or {(((_x ~ acc) & 0x80) != 0 and {MASK_PV} or {0})[1]})[1];
	end
end

-- 改变奇偶校验/溢出标志（16位加法）int setV16(int acc, Register16 x, Register16 y)
local function setV16(acc, x, y)
	local _x = x.get();
	local _y = y.get();
	return (((_x ~ _y) & 0x8000) != 0 and {0} or {(((_x ~ acc) & 0x8000) != 0 and {MASK_PV} or {0})[1]})[1];
end

-- 改变奇偶校验/溢出标志（8位减法）int setV8S(int acc, int x | Register8 x, int y | Register8 y)
local function setV8S(acc, x, y)
	local typeX, typeY = type(x), type(y)
	if typeX == "number" and typeY == "number" then
		return (((x ~ y) & 0x80) != 0 and {(((x ~ acc) & 0x80) != 0 and {MASK_PV} or {0})[1]} or {0})[1];
	elseif typeX == "table" and typeY == "number" then
		local _x = x.get();
		return (((_x ~ y) & 0x80) != 0 and {(((_x ~ acc) & 0x80) != 0 and {MASK_PV} or {0})[1]} or {0})[1];
	elseif typeX == "number" and typeY == "table" then
		return (((x ~ y.get()) & 0x80) != 0 and {(((x ~ acc) & 0x80) != 0 and {MASK_PV} or {0})[1]} or {0})[1];
	end	
end

-- 改变奇偶校验/溢出标志（16位减法）int setV16S(int acc, Register16 x, Register16 y)
local function setV16S(acc, x, y)
	local _x = x.get();
	return (((_x ~ y.get()) & 0x80) != 0 and {(((_x ~ acc) & 0x80) != 0 and {MASK_PV} or {0})[1]} or {0})[1];
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
		return ((((x.get() & 0x0fff) + (y.get() & 0x0fff) + cy) & 0x1000) != 0 and {MASK_HC} or {0})[1];
	elseif cy == nil then
		return ((((x.get() & 0x0fff) + (y.get() & 0x0fff)) & 0x1000) != 0 and {MASK_HC} or {0})[1];
	end
end

-- 更改半进位标志（16位减法）int setHC16S(Register16 x, Register16 y, int cy)
local function setHC16S(x, y, cy)
	return ((((x.get() & 0x0fff) - (y.get() & 0x0fff) - cy) & 0x1000) != 0 and {MASK_HC} or {0})[1];
end

-- 改变零标志位（8位）int setZ8(int acc | Register8 r)
local function setZ8(accr)
	local typeAccr == type(accr)
	if typeAccr == "number" then
		return ((acc & 0xff) != 0 and {0} or {MASK_Z})[1];
	elseif typeAccr == "table" then
		return ((r.get() & 0xff) != 0 and {0} or {MASK_Z})[1];
	end
end

-- 改变零标志位（16位）int setZ16(int acc)
local function setZ16(acc)
	return ((acc & 0xffff) != 0 and {0} or {MASK_Z})[1];
end

-- 更改符号标志（8位）int setS8(int acc | Register8 r)
local function setS8(accr)
	local typeAccr == type(accr)
	if typeAccr == "number" then
		return ((acc & 0x80) != 0 and {MASK_S} or {0})[1];
	elseif typeAccr == "table" then
		return (((r.get() & 0x80) != 0) and {MASK_S} or {0})[1];
	end
end

-- 更改符号标志（16位）int setS16(int acc)
local function setS16(acc)
	return ((acc & 0x8000) != 0 ? {MASK_S} or {0})[1];
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
local function and(nr)
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
	f.set(f.cy() | ((n & (1 << b)) != 0  and {0} or {MASK_PV})[1] | MASK_HC | ((n & (1 << b)) != 0 and {0} or {MASK_Z})[1] | (n & 0x80 & (1 << b)));
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
	f.set((f.cy() ~ MASK_CY) | f.pv() | (f.cy() != 0 ? MASK_HC: 0) | f.z() | f.s());
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
	while(!bc.isZero() && acc != 0) do
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
	until (!bc.isZero() && acc != 0)
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
	if(!b.isZero()) then
		pc = pc + d;
		states = states + 5;
	end
	pc = pc + length;
end

-- ei private boolean ei()
local function ei()
	pc = pc + length;
	if(iff != 3) then
		iff = 3;
		restStates -= states;
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
local function in_c(Register8 r)
	
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
		f.set(f.cy() | ((n & 0x80) != 0 and {MASK_N} or {0}[1]) | f.pv() | f.hc() | (b.isZero() and {MASK_Z} or {0})[1] | f.s());
		pc = pc + length;
end

	
-- indr private void indr()
local function indr()

		while(!b.isZero()) do
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
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() ? MASK_Z: 0) | f.s());
		pc = pc + length;
end

-- inir private void inir()
local function inir

	while(!b.isZero()) do
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
			int s, old_pc;

			s = subroutine(address);
			old_pc = pc;
			pc = address;

			if(s < 0) then
				return false;
			elseif(s > 0) then
				pc = Z80:read16(sp);
				sp.add(2);
				states += s;
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

	f.set(f.cy() | ((iff & 0x02) != 0 and {0} or {MASK_PV})[1] | setZ8(acc) | setS8(acc));
	a.set(acc);
	pc = pc + length;
end

-- ld A, R private void ld_a_r()
local function ld_a_r()
	local acc = getR();

	f.set(f.cy() | ((iff & 0x02) != 0 and {0} or {MASK_PV})[1] | setZ8(acc) | setS8(acc));
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
local function st8(int address, int n)
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
	f.set(f.cy() | (!bc.isZero() and {MASK_PV} or {0})[1] | f.z() | f.s());
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
		until(!bc.isZero());
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
	f.set(f.cy() | (!bc.isZero() and {MASK_PV} or {0})[1] | f.z() | f.s());
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
	until(!bc.isZero());
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
local function or(n)
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
		while(!b.isZero()) do
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
	while(!b.isZero()) do
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
local function res_m(int b, int address)
	
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
	
		if(condition != 0) then
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

	f.set(((r.get() & 0x80) != 0 and {MASK_CY} or {0})[1] | setP(acc) | setZ8(acc) | setS8(acc));
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

	f.set(((a.get() & 0x80) != 0 and {MASK_CY} or {0})[1] | f.pv() | f.z() | f.s());
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
	
	local acc = (r.get() << 1) | ((r.get() & 0x80) != 0 and {0x01} or {0})[1];

		f.set(((r.get() & 0x80) != 0 and {MASK_CY} or {0})[1] | setP(acc) | setZ8(acc) | setS8(acc));
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
	local acc = (a.get() << 1) | ((a.get() & 0x80) != 0 and {0x01} or {0})[1];

	f.set(((a.get() & 0x80) != 0 and {MASK_CY} or {0})[1] | f.pv() | f.z() | f.s());
	a.set(acc);
	pc = pc + length;
end

-- rld private void rld()
local function rld()	
	local acc = (a.get() & 0xf0) | (Z80:read8(hl) >>> 4);

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
	
	local acc = (r.get() >>> 1) | (f.cy() != 0 and {0x80} or {0})[1];

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
	local acc = (a.get() >>> 1) | (f.cy() != 0 and {0x80} or {0})[1];

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
	
	local acc = (r.get() >>> 1) | ((r.get() & 0x01) != 0 and {0x80} or {0})[1];

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
	local acc = (a.get() >>> 1) | ((a.get() & 0x01) != 0 and {0x80} or {0})[1];

	f.set((a.get() & 0x01) | f.pv() | f.z() | f.s());
	a.set(acc);
	pc = pc + length;
end

-- rrd private void rrd()
local function rrd()
	local acc = (a.get() & 0xf0) | (Z80:read8(hl) & 0x0f);

	Z80:write8(hl, (Z80:read8(hl) >>> 4) | (a.get() << 4));
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

	f.set(((r.get() & 0x80) != 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
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

	f.set(((r.get() & 0x80) != 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
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
	local acc = (r.get() >>> 1) | (r.get() & 0x80);

	f.set(((r.get() & 0x01) != 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
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
	local acc = r.get() >>> 1;

		f.set(((r.get() & 0x01) != 0 and {MASK_CY} or {0})[1] | setP(acc) | setS8(acc) | setZ8(acc));
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
		int acc = a.get() - n;

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
local function xor(nr)
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
	if(!(im == 1 && iff == 3)) then
		return false;
	end

	hlt = false;
	iff = 0;
	states -= 13;

	interrupt(0x38);
	return true;
end

-- 输出跟踪 private void disassemble()
local function disassemble()
		log(String.format(
		"%c%c%c%c%c%c(%02x) A=%02x BC=%04x DE=%04x HL=%04x SP=%04x PC=%04x %s" + System.getProperty("line.separator") +
		"%c%c%c%c%c%c(%02x) A'%02x BC'%04x DE'%04x HL'%04x IX=%04x IY=%04x %s" + System.getProperty("line.separator") +
		"%dclocks" + System.getProperty("line.separator"),
		((f.get() & 0x80) != 0 ? 'S': '-'),
		((f.get() & 0x40) != 0 ? 'Z': '-'),
		((f.get() & 0x10) != 0 ? 'H': '-'),
		((f.get() & 0x04) != 0 ? 'P': '-'),
		((f.get() & 0x02) != 0 ? 'N': '-'),
		((f.get() & 0x01) != 0 ? 'C': '-'),
		f.get(),
		a.get(),
		bc.get(),
		de.get(),
		hl.get(),
		sp.get(),
		pc,
		Z80Disassembler.disassemble(new byte[] { (byte )read8(pc + 0), (byte )read8(pc + 1), (byte )read8(pc + 2), (byte )read8(pc + 3), (byte )read8(pc + 4) }),
		((af_d.l.get() & 0x80) != 0 ? 'S': '-'),
		((af_d.l.get() & 0x40) != 0 ? 'Z': '-'),
		((af_d.l.get() & 0x10) != 0 ? 'H': '-'),
		((af_d.l.get() & 0x04) != 0 ? 'P': '-'),
		((af_d.l.get() & 0x02) != 0 ? 'N': '-'),
		((af_d.l.get() & 0x01) != 0 ? 'C': '-'),
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
	Z80.restStates = execute_states;
	executeStates = Z80.restStates

	if (Z80.hlt) then 
		if (Z80.trace) then
			Z80:disassemble();
		end
		Z80.restStates = 0;
		return 0
	end

	while (Z80.restStates > 0) do
		if (Z80.trace) then
			Z80:disassemble();
		end

		local f1 == Z80:fetchXX()

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

		
		elseif f1 == 0xc8 then ret(f.z());		-- ret Z
		elseif f1 == 0xc9 then ret(1);		-- ret
		elseif f1 == 0xca then jp(f.z(), imm16());		-- jp Z, mn		
		elseif f1 == 0xcb then
			Z80.pc = Z80.pc + 1
			local f2 = fetchCBXX()
			if     f2 == 0x00 then rlc_r(b);		-- rlc B
			elseif f2 == 0x01 then rlc_r(c);		-- rlc C
			elseif f2 == 0x02 then rlc_r(d);		-- rlc D
			
			
			end
		elseif f1 == 0xcc then call(f.z(), imm16());		-- call Z, mn
		elseif f1 == 0xcd then call(1, imm16());		-- call mn
		elseif f1 == 0xce then adc8(imm8());		-- adc n
		elseif f1 == 0xcf then rst(0x08);		-- rst 08H
		

		elseif f1 == 0xfe then cp(imm8());		-- cp n 
		elseif f1 == 0xff then rst(0x38);		-- rst 38H
		end
		
		Z80.restStates = Z80.restStates - Z80.states;

	end	

	return 0

end 



return Z80
