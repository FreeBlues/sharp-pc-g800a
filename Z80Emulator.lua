--[[
--Zilog Z80 emulator for Java
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
	return self.x
end


-- 获取值
function R8:get() return self.x end

-- 设置值
function R8:set(value)  self.x = value & 0xff; return R8:get(); end

-- 若该值为零
function R8:isZero() return self.x == 0; end

-- 增加值
function R8:add(value)  return R8:set(R8:get() + value) end

-- 获得进位标志
function R8:cy()  return self.x & Z80Emulator.MASK_CY; end

function R8:ncy() return R:cy() ^ Z80Emulator.MASK_CY; end

-- 获得减标志
function R8:n()  return self.x & Z80Emulator.MASK_N end

-- 获得奇偶校验/溢出标志
function R8:pv() return self.x & Z80Emulator.MASK_PV end

function R8:npv()  return R8:pv() ^ Z80Emulator.MASK_PV end

-- 获得半进位标志
function R8:hc() return self.x & Z80Emulator.MASK_HC; end

-- 获取零标志
function R8:z()  return self.x & Z80Emulator.MASK_Z; end
function R8:nz() return R8:z() ^ Z80Emulator.MASK_Z; end

-- 获取签署标志 
function R8:s()  return self.x & Z80Emulator.MASK_S; end
function R8:ns() return R8:s() ^ Z80Emulator.MASK_S; end

-- 16位寄存器
Z80.Register16 = {h = R8, l = R8}
local R16 = Z80.Register16

-- 构造函数
function R16:init(low, high)
	self.l = low;
	self.h = high
end

-- 获取值
function R16:get()
	return (self.h.x << 8) | self.l.x;
end

-- 设置值
-- int value/init value
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

-- 若该值为零
function R16:isZero() 
	return R16:get() == 0;
end 

-- 增加值
function R16:add(value)
	return R16:set(R16:get() + value);
end

-- 进位标志
Z80Emulator.MASK_CY = 0x01

-- 减标记
Z80Emulator.MMASK_N  = 0x02

-- 奇偶/溢出标志
Z80Emulator.MMASK_PV = 0x04

-- 半进位标志
Z80Emulator.MMASK_HC = 0x10

-- 零标志
Z80Emulator.MMASK_Z  = 0x40

-- 注册标志
Z80Emulator.MMASK_S  = 0x80

local MASK_CY = Z80Emulator.MASK_CY 
local MASK_N  = Z80Emulator.MASK_N
local MASK_PV = Z80Emulator.MASK_PV
local MASK_HC = Z80Emulator.MASK_HC
local MASK_Z  = Z80Emulator.MASK_Z
local MASK_S  = Z80Emulator.MASK_S

-- 状态的（XX）的数量
Z80.statesXX = { 
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

-- 状态的数目（CB XX）
Z80.statesCBXX = {
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

-- 状态（DD/ FD XX）的数量
Z80.statesDDXX = {
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

-- 状态（DD/ FD XX）的数量
Z80.statesDDCBXX = {
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

-- 状态数(ED xx)
Z80.statesEDXX = {
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

-- 命令長(xx)
Z80.lengthXX = {
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

-- 命令長(CB xx)
Z80.lengthCBXX = {
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

-- 命令長(DD/FD xx)
Z80.lengthDDXX = {
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

-- 命令長(DD/FD CB xx)
Z80.lengthDDCBXX = {
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

-- 命令長(ED xx)
Z80.lengthEDXX = {
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

-- 奇偶校验结果表
Z80.parity = {
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


local statesXX = Z80.statesXX
local statesCBXX = Z80.statesCBXX
local statesDDXX = Z80.statesDDXX
local statesDDCBXX = Z80.statesDDCBXX
local statesEDXX = Z80.statesEDXX
local lengthXX = Z80.lengthXX
local lengthCBXX = Z80.lengthCBXX
local lengthDDXX = Z80.lengthDDXX
local lengthDDCBXX = Z80.lengthDDCBXX
local lengthEDXX = Z80.lengthEDXX
local parity = Z80.parity

-- 对R寄存器的随机数
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

-- 输出日志
function Z80:log(message)

end

-- 读取内存（8位）
function Z80:read(address)

end

function Z80:read8(address)
	local typeAddress = type(address)
	if typeAddress == "number" then
		return (Z80:read(address)) & 0xff;
	elseif typeAddress == "table" then
		return (Z80:read(address.get())) & 0xff;
	end
end

-- 读取内存（16位）
function Z80:read16(address)
	local typeAddress = type(address)
	if typeAddress == "number" then
		return Z80:read8(address) | (Z80:read8((address + 1) & 0xffff) << 8);
	elseif typeAddress == "table" then
		return Z80:read8(address.get()) | ((Z80:read8(address.get() + 1) & 0xffff) << 8);
	end
end

-- 写入内存（8位）
function Z80:write(address, value)

end

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

-- 写入内存（16位）
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

-- 输入到 I/O
function Z80:inport(int address)

end


-- 输出到 I/O
function Z80:outport(int address, int value)

end





return Z80
