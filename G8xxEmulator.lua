--[[	SHARP Pocket Computer PC-E200/G815/G850 Emulator
--]]

-- public class G800Emulator extends Z80Emulator
-- G8xxEmulator  以 Z80Emulator 为基类
G8xxEmulator = {}

local G8xx = G8xxEmulator

--  加载 Z80Emulator
local Z  = require("Z80Emulator")

setmetatable(G8xx, Z)
G8xx.__index = G8xx

function G8xx:init(x,y)
	local instance  = Z:init(x)
	instance.y = y
	setmetatable(instance, G8xx)
	return instance
end


--	布局区域类 public class Area
G8xx.Area = {}
local Area = G8xx.Area

--	コンストラクタ
--Area(int x, int y, int width, int height, String text, int fore_color, int back_color)		
function Area:init(x, y, width, height, text, fore_color, back_color)
	
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;

	if text == nil then 
		self.text = "";
	else
		self.text = text
	end

	if fore_color then
		self.foreColor = fore_color
	end

	if back_color then
		self.backColor = back_Color
	end

	local instance = {}
	instance.x = self.x
	instance.y = self.y
	instance.width = self.width
	instance.height = self.height
	instance.text = self.text
	instance.foreColor = self.foreColor 
	instance.backColor = self.backColor
	setmetatable(instance, {__index = self})

	return instance	
end

--  X座標 public int x;
local x = G8xx.x
--  Y座標 public int y;
local y = G8xx.y
--  幅 public int width;
local width = G8xx.width
--  高さ public int height;
local height = G8xx.height

local text = G8xx.text
--  文字 public String text;
local foreColor = G8xx.foreColor
--  前景色 public int foreColor;
local backColor = G8xx.backColor
--  背景色 public int backColor;


-- 字体图案 static private final byte[][] font
local font = {
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x00, 0x00 },
		{ 0x55, 0x2a, 0x55, 0x2a, 0x55, 0x00, 0x00 },
		{ 0x2a, 0x55, 0x2a, 0x55, 0x2a, 0x00, 0x00 },
		{ 0x1c, 0x1c, 0x3e, 0x1c, 0x08, 0x00, 0x00 },
		{ 0x10, 0x38, 0x54, 0x10, 0x1f, 0x00, 0x00 },
		{ 0x12, 0x19, 0x15, 0x12, 0x00, 0x00, 0x00 },
		{ 0x15, 0x15, 0x15, 0x0a, 0x00, 0x00, 0x00 },
		{ 0x45, 0x29, 0x11, 0x29, 0x45, 0x00, 0x00 },
		{ 0x0d, 0x51, 0x51, 0x51, 0x3d, 0x00, 0x00 },
		{ 0x41, 0x63, 0x55, 0x49, 0x41, 0x00, 0x00 },
		{ 0x30, 0x48, 0x44, 0x3c, 0x04, 0x00, 0x00 },
		{ 0x00, 0x04, 0x03, 0x00, 0x00, 0x00, 0x00 },
		{ 0x08, 0x08, 0x2a, 0x1c, 0x08, 0x00, 0x00 },
		{ 0x08, 0x1c, 0x2a, 0x08, 0x08, 0x00, 0x00 },
		{ 0x04, 0x02, 0x7f, 0x02, 0x04, 0x00, 0x00 },
		{ 0x10, 0x20, 0x7f, 0x20, 0x10, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x5f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x05, 0x03, 0x05, 0x03, 0x00, 0x00, 0x00 },
		{ 0x22, 0x7f, 0x22, 0x7f, 0x22, 0x00, 0x00 },
		{ 0x24, 0x2a, 0x7f, 0x2a, 0x12, 0x00, 0x00 },
		{ 0x23, 0x13, 0x08, 0x64, 0x62, 0x00, 0x00 },
		{ 0x30, 0x4e, 0x59, 0x26, 0x50, 0x00, 0x00 },
		{ 0x00, 0x01, 0x05, 0x03, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x1c, 0x22, 0x41, 0x00, 0x00 },
		{ 0x41, 0x22, 0x1c, 0x00, 0x00, 0x00, 0x00 },
		{ 0x14, 0x08, 0x3e, 0x08, 0x14, 0x00, 0x00 },
		{ 0x08, 0x08, 0x3e, 0x08, 0x08, 0x00, 0x00 },
		{ 0x50, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00 },
		{ 0x60, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x20, 0x10, 0x08, 0x04, 0x02, 0x00, 0x00 },
		{ 0x3e, 0x51, 0x49, 0x45, 0x3e, 0x00, 0x00 },
		{ 0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x00 },
		{ 0x62, 0x51, 0x49, 0x49, 0x46, 0x00, 0x00 },
		{ 0x22, 0x49, 0x49, 0x49, 0x36, 0x00, 0x00 },
		{ 0x18, 0x14, 0x12, 0x7f, 0x10, 0x00, 0x00 },
		{ 0x2f, 0x45, 0x45, 0x45, 0x39, 0x00, 0x00 },
		{ 0x3e, 0x49, 0x49, 0x49, 0x32, 0x00, 0x00 },
		{ 0x01, 0x61, 0x19, 0x05, 0x03, 0x00, 0x00 },
		{ 0x36, 0x49, 0x49, 0x49, 0x36, 0x00, 0x00 },
		{ 0x26, 0x49, 0x49, 0x49, 0x3e, 0x00, 0x00 },
		{ 0x00, 0x36, 0x36, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x56, 0x36, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x08, 0x14, 0x22, 0x41, 0x00, 0x00 },
		{ 0x14, 0x14, 0x14, 0x14, 0x14, 0x00, 0x00 },
		{ 0x00, 0x41, 0x22, 0x14, 0x08, 0x00, 0x00 },
		{ 0x02, 0x01, 0x59, 0x09, 0x06, 0x00, 0x00 },
		{ 0x3e, 0x41, 0x5d, 0x55, 0x2e, 0x00, 0x00 },
		{ 0x60, 0x1c, 0x13, 0x1c, 0x60, 0x00, 0x00 },
		{ 0x7f, 0x49, 0x49, 0x49, 0x36, 0x00, 0x00 },
		{ 0x1c, 0x22, 0x41, 0x41, 0x22, 0x00, 0x00 },
		{ 0x7f, 0x41, 0x41, 0x22, 0x1c, 0x00, 0x00 },
		{ 0x7f, 0x49, 0x49, 0x49, 0x41, 0x00, 0x00 },
		{ 0x7f, 0x09, 0x09, 0x09, 0x01, 0x00, 0x00 },
		{ 0x1c, 0x22, 0x41, 0x49, 0x3a, 0x00, 0x00 },
		{ 0x7f, 0x08, 0x08, 0x08, 0x7f, 0x00, 0x00 },
		{ 0x00, 0x41, 0x7f, 0x41, 0x00, 0x00, 0x00 },
		{ 0x20, 0x40, 0x40, 0x40, 0x3f, 0x00, 0x00 },
		{ 0x7f, 0x08, 0x14, 0x22, 0x41, 0x00, 0x00 },
		{ 0x7f, 0x40, 0x40, 0x40, 0x40, 0x00, 0x00 },
		{ 0x7f, 0x04, 0x18, 0x04, 0x7f, 0x00, 0x00 },
		{ 0x7f, 0x04, 0x08, 0x10, 0x7f, 0x00, 0x00 },
		{ 0x3e, 0x41, 0x41, 0x41, 0x3e, 0x00, 0x00 },
		{ 0x7f, 0x09, 0x09, 0x09, 0x06, 0x00, 0x00 },
		{ 0x3e, 0x41, 0x51, 0x21, 0x5e, 0x00, 0x00 },
		{ 0x7f, 0x09, 0x19, 0x29, 0x46, 0x00, 0x00 },
		{ 0x26, 0x49, 0x49, 0x49, 0x32, 0x00, 0x00 },
		{ 0x01, 0x01, 0x7f, 0x01, 0x01, 0x00, 0x00 },
		{ 0x3f, 0x40, 0x40, 0x40, 0x3f, 0x00, 0x00 },
		{ 0x03, 0x1c, 0x60, 0x1c, 0x03, 0x00, 0x00 },
		{ 0x0f, 0x70, 0x0f, 0x70, 0x0f, 0x00, 0x00 },
		{ 0x41, 0x36, 0x08, 0x36, 0x41, 0x00, 0x00 },
		{ 0x01, 0x06, 0x78, 0x06, 0x01, 0x00, 0x00 },
		{ 0x61, 0x51, 0x49, 0x45, 0x43, 0x00, 0x00 },
		{ 0x00, 0x00, 0x7f, 0x41, 0x41, 0x00, 0x00 },
		{ 0x15, 0x16, 0x7c, 0x16, 0x15, 0x00, 0x00 },
		{ 0x41, 0x41, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x02, 0x01, 0x02, 0x00, 0x00, 0x00 },
		{ 0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x20, 0x54, 0x54, 0x78, 0x00, 0x00 },
		{ 0x00, 0x7f, 0x44, 0x44, 0x38, 0x00, 0x00 },
		{ 0x00, 0x38, 0x44, 0x44, 0x28, 0x00, 0x00 },
		{ 0x00, 0x38, 0x44, 0x44, 0x7f, 0x00, 0x00 },
		{ 0x00, 0x38, 0x54, 0x54, 0x18, 0x00, 0x00 },
		{ 0x00, 0x04, 0x7e, 0x05, 0x01, 0x00, 0x00 },
		{ 0x00, 0x08, 0x54, 0x54, 0x3c, 0x00, 0x00 },
		{ 0x00, 0x7f, 0x04, 0x04, 0x78, 0x00, 0x00 },
		{ 0x00, 0x00, 0x7d, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x40, 0x40, 0x3d, 0x00, 0x00, 0x00 },
		{ 0x00, 0x7f, 0x10, 0x28, 0x44, 0x00, 0x00 },
		{ 0x00, 0x01, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x7c, 0x04, 0x78, 0x04, 0x78, 0x00, 0x00 },
		{ 0x00, 0x7c, 0x04, 0x04, 0x78, 0x00, 0x00 },
		{ 0x00, 0x38, 0x44, 0x44, 0x38, 0x00, 0x00 },
		{ 0x00, 0x7c, 0x14, 0x14, 0x08, 0x00, 0x00 },
		{ 0x00, 0x08, 0x14, 0x14, 0x7c, 0x00, 0x00 },
		{ 0x00, 0x7c, 0x08, 0x04, 0x04, 0x00, 0x00 },
		{ 0x00, 0x48, 0x54, 0x54, 0x24, 0x00, 0x00 },
		{ 0x00, 0x04, 0x3f, 0x44, 0x44, 0x00, 0x00 },
		{ 0x00, 0x3c, 0x40, 0x40, 0x7c, 0x00, 0x00 },
		{ 0x00, 0x3c, 0x40, 0x20, 0x1c, 0x00, 0x00 },
		{ 0x1c, 0x60, 0x1c, 0x60, 0x1c, 0x00, 0x00 },
		{ 0x00, 0x6c, 0x10, 0x10, 0x6c, 0x00, 0x00 },
		{ 0x00, 0x4c, 0x50, 0x20, 0x1c, 0x00, 0x00 },
		{ 0x00, 0x44, 0x64, 0x54, 0x4c, 0x00, 0x00 },
		{ 0x00, 0x08, 0x36, 0x41, 0x41, 0x00, 0x00 },
		{ 0x00, 0x00, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x41, 0x41, 0x36, 0x08, 0x00, 0x00, 0x00 },
		{ 0x08, 0x04, 0x08, 0x10, 0x08, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x00 },
		{ 0x60, 0x60, 0x60, 0x60, 0x60, 0x00, 0x00 },
		{ 0x70, 0x70, 0x70, 0x70, 0x70, 0x00, 0x00 },
		{ 0x78, 0x78, 0x78, 0x78, 0x78, 0x00, 0x00 },
		{ 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x00, 0x00 },
		{ 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x00, 0x00 },
		{ 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x7f, 0x00, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x00, 0x00 },
		{ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x00, 0x00 },
		{ 0x08, 0x08, 0x7f, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x0f, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x78, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x7f, 0x08, 0x08, 0x00, 0x00 },
		{ 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00 },
		{ 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00 },
		{ 0x00, 0x00, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x7f, 0x00, 0x00 },
		{ 0x00, 0x00, 0x78, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x78, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x0f, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x0f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x70, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x70, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x07, 0x08, 0x08, 0x00, 0x00 },
		{ 0x08, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x20, 0x50, 0x20, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x1e, 0x02, 0x02, 0x00, 0x00 },
		{ 0x40, 0x40, 0x78, 0x00, 0x00, 0x00, 0x00 },
		{ 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x18, 0x18, 0x00, 0x00, 0x00, 0x00 },
		{ 0x02, 0x4a, 0x4a, 0x2a, 0x1e, 0x00, 0x00 },
		{ 0x04, 0x44, 0x3c, 0x14, 0x0c, 0x00, 0x00 },
		{ 0x20, 0x20, 0x10, 0x78, 0x04, 0x00, 0x00 },
		{ 0x18, 0x48, 0x4c, 0x28, 0x18, 0x00, 0x00 },
		{ 0x40, 0x48, 0x78, 0x48, 0x40, 0x00, 0x00 },
		{ 0x28, 0x28, 0x58, 0x7c, 0x08, 0x00, 0x00 },
		{ 0x08, 0x1c, 0x68, 0x08, 0x18, 0x00, 0x00 },
		{ 0x40, 0x48, 0x48, 0x78, 0x40, 0x00, 0x00 },
		{ 0x00, 0x44, 0x54, 0x54, 0x7c, 0x00, 0x00 },
		{ 0x18, 0x40, 0x58, 0x20, 0x18, 0x00, 0x00 },
		{ 0x04, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00 },
		{ 0x01, 0x41, 0x3d, 0x09, 0x07, 0x00, 0x00 },
		{ 0x10, 0x10, 0x08, 0x7c, 0x03, 0x00, 0x00 },
		{ 0x06, 0x42, 0x43, 0x22, 0x1e, 0x00, 0x00 },
		{ 0x20, 0x22, 0x3e, 0x22, 0x20, 0x00, 0x00 },
		{ 0x22, 0x12, 0x4a, 0x7f, 0x02, 0x00, 0x00 },
		{ 0x42, 0x32, 0x0f, 0x42, 0x7e, 0x00, 0x00 },
		{ 0x12, 0x12, 0x7f, 0x12, 0x12, 0x00, 0x00 },
		{ 0x44, 0x43, 0x22, 0x12, 0x0e, 0x00, 0x00 },
		{ 0x04, 0x03, 0x42, 0x3e, 0x02, 0x00, 0x00 },
		{ 0x42, 0x42, 0x42, 0x42, 0x7e, 0x00, 0x00 },
		{ 0x02, 0x4f, 0x22, 0x1f, 0x02, 0x00, 0x00 },
		{ 0x45, 0x4a, 0x20, 0x10, 0x0c, 0x00, 0x00 },
		{ 0x42, 0x22, 0x12, 0x2a, 0x46, 0x00, 0x00 },
		{ 0x04, 0x3f, 0x44, 0x54, 0x4c, 0x00, 0x00 },
		{ 0x01, 0x46, 0x20, 0x18, 0x06, 0x00, 0x00 },
		{ 0x48, 0x44, 0x2b, 0x12, 0x0e, 0x00, 0x00 },
		{ 0x08, 0x4a, 0x3e, 0x09, 0x08, 0x00, 0x00 },
		{ 0x0e, 0x40, 0x4e, 0x20, 0x1e, 0x00, 0x00 },
		{ 0x04, 0x45, 0x3d, 0x05, 0x04, 0x00, 0x00 },
		{ 0x00, 0x7f, 0x08, 0x10, 0x00, 0x00, 0x00 },
		{ 0x04, 0x44, 0x3f, 0x04, 0x04, 0x00, 0x00 },
		{ 0x20, 0x22, 0x22, 0x22, 0x20, 0x00, 0x00 },
		{ 0x42, 0x4a, 0x2a, 0x1a, 0x26, 0x00, 0x00 },
		{ 0x22, 0x12, 0x7b, 0x16, 0x22, 0x00, 0x00 },
		{ 0x40, 0x20, 0x18, 0x07, 0x00, 0x00, 0x00 },
		{ 0x60, 0x1c, 0x00, 0x0e, 0x70, 0x00, 0x00 },
		{ 0x3f, 0x48, 0x48, 0x44, 0x44, 0x00, 0x00 },
		{ 0x02, 0x42, 0x22, 0x12, 0x0e, 0x00, 0x00 },
		{ 0x08, 0x04, 0x08, 0x10, 0x20, 0x00, 0x00 },
		{ 0x34, 0x04, 0x7f, 0x04, 0x34, 0x00, 0x00 },
		{ 0x02, 0x12, 0x32, 0x4a, 0x06, 0x00, 0x00 },
		{ 0x00, 0x21, 0x25, 0x4a, 0x42, 0x00, 0x00 },
		{ 0x60, 0x58, 0x47, 0x20, 0x40, 0x00, 0x00 },
		{ 0x40, 0x44, 0x24, 0x18, 0x27, 0x00, 0x00 },
		{ 0x08, 0x09, 0x3f, 0x49, 0x48, 0x00, 0x00 },
		{ 0x02, 0x0f, 0x72, 0x0a, 0x06, 0x00, 0x00 },
		{ 0x20, 0x22, 0x22, 0x3e, 0x20, 0x00, 0x00 },
		{ 0x42, 0x4a, 0x4a, 0x4a, 0x7e, 0x00, 0x00 },
		{ 0x04, 0x45, 0x45, 0x25, 0x1c, 0x00, 0x00 },
		{ 0x0f, 0x00, 0x40, 0x20, 0x1f, 0x00, 0x00 },
		{ 0x40, 0x3c, 0x00, 0x7e, 0x20, 0x00, 0x00 },
		{ 0x00, 0x7e, 0x40, 0x20, 0x10, 0x00, 0x00 },
		{ 0x7e, 0x42, 0x42, 0x42, 0x7e, 0x00, 0x00 },
		{ 0x06, 0x42, 0x42, 0x22, 0x1e, 0x00, 0x00 },
		{ 0x41, 0x42, 0x20, 0x10, 0x0c, 0x00, 0x00 },
		{ 0x01, 0x02, 0x01, 0x02, 0x00, 0x00, 0x00 },
		{ 0x02, 0x05, 0x02, 0x00, 0x00, 0x00, 0x00 },
		{ 0x14, 0x14, 0x14, 0x14, 0x14, 0x00, 0x00 },
		{ 0x00, 0x00, 0x7f, 0x14, 0x14, 0x00, 0x00 },
		{ 0x14, 0x14, 0x7f, 0x14, 0x14, 0x00, 0x00 },
		{ 0x14, 0x14, 0x7f, 0x00, 0x00, 0x00, 0x00 },
		{ 0x60, 0x70, 0x78, 0x7c, 0x7e, 0x00, 0x00 },
		{ 0x7e, 0x7c, 0x78, 0x70, 0x60, 0x00, 0x00 },
		{ 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x00, 0x00 },
		{ 0x3f, 0x1f, 0x0f, 0x07, 0x03, 0x00, 0x00 },
		{ 0x1c, 0x5e, 0x7f, 0x5e, 0x1c, 0x00, 0x00 },
		{ 0x1e, 0x3f, 0x7c, 0x3f, 0x1e, 0x00, 0x00 },
		{ 0x1c, 0x3e, 0x7f, 0x3e, 0x1c, 0x00, 0x00 },
		{ 0x1c, 0x4b, 0x7f, 0x4b, 0x1c, 0x00, 0x00 },
		{ 0x3e, 0x7f, 0x7f, 0x7f, 0x3e, 0x00, 0x00 },
		{ 0x3e, 0x41, 0x41, 0x41, 0x3e, 0x00, 0x00 },
		{ 0x20, 0x10, 0x08, 0x04, 0x02, 0x00, 0x00 },
		{ 0x02, 0x04, 0x08, 0x10, 0x20, 0x00, 0x00 },
		{ 0x22, 0x14, 0x08, 0x14, 0x22, 0x00, 0x00 },
		{ 0x7f, 0x09, 0x0f, 0x49, 0x7f, 0x00, 0x00 },
		{ 0x24, 0x3b, 0x2a, 0x7e, 0x2a, 0x00, 0x00 },
		{ 0x40, 0x3f, 0x15, 0x55, 0x7f, 0x00, 0x00 },
		{ 0x7f, 0x49, 0x49, 0x49, 0x7f, 0x00, 0x00 },
		{ 0x3e, 0x3e, 0x2a, 0x4f, 0x7a, 0x00, 0x00 },
		{ 0x44, 0x3b, 0x48, 0x7b, 0x04, 0x00, 0x00 },
		{ 0x35, 0x7f, 0x46, 0x2f, 0x14, 0x00, 0x00 },
		{ 0x04, 0x03, 0x04, 0x03, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
		{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
	}

-- 键码 ->> ASCII 码转换表 (大写) private final int[] keyToAsciiUpper 
local keyToAsciiUpper = {
		0x00, 0x06, 0x51, 0x57, 0x45, 0x52, 0x54, 0x59,
		0x55, 0x41, 0x53, 0x44, 0x46, 0x47, 0x48, 0x4a,
		0x4b, 0x5a, 0x58, 0x43, 0x56, 0x42, 0x4e, 0x4d,
		0x2c, 0x01, 0x02, 0x14, 0x11, 0x0a, 0x20, 0x1f,
		0x1e, 0x1d, 0x1c, 0x15, 0x30, 0x2e, 0x3d, 0x2b,
		0x0d, 0x4c, 0x3b, 0x17, 0x31, 0x32, 0x33, 0x2d,
		0x1a, 0x49, 0x4f, 0x12, 0x34, 0x35, 0x36, 0x2a,
		0x19, 0x50, 0x08, 0xfe, 0x37, 0x38, 0x39, 0x2f,
		0x29, 0xfe, 0xfe, 0xfe, 0xfe, 0x3e, 0x28, 0xfe,
		0xfe, 0x10, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0x0f,
		0x0c, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x06, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26,
		0x27, 0x5b, 0x5d, 0x7b, 0x7d, 0x5c, 0x7c, 0x7e,
		0x5f, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe,
		0x3f, 0xf0, 0x03, 0x14, 0x11, 0x0a, 0x20, 0x1f,
		0x1e, 0x1d, 0x1c, 0xf2, 0x30, 0x13, 0x45, 0x2b,
		0x07, 0x3d, 0x3a, 0x18, 0x31, 0x32, 0x33, 0x16,
		0x1b, 0x3c, 0x3e, 0x09, 0x34, 0x35, 0x36, 0x2a,
		0x19, 0x40, 0x08, 0xfe, 0xdf, 0x27, 0xf8, 0x2f,
		0xf1, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe,
		0x04, 0x10, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0x0e,
		0x0b, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	}

--  键码 ->> ASCII 码转换表 (小写) private final int[] keyToAsciiLower 
local keyToAsciiLower = {
		0x00, 0x06, 0x71, 0x77, 0x65, 0x72, 0x74, 0x79,
		0x75, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68, 0x6a,
		0x6b, 0x7a, 0x78, 0x63, 0x76, 0x62, 0x6e, 0x6d,
		0x2c, 0x01, 0x02, 0x14, 0x11, 0x0a, 0x20, 0x1f,
		0x1e, 0x1d, 0x1c, 0x15, 0x30, 0x2e, 0x3d, 0x2b,
		0x0d, 0x6c, 0x3b, 0x17, 0x31, 0x32, 0x33, 0x2d,
		0x1a, 0x69, 0x6f, 0x12, 0x34, 0x35, 0x36, 0x2a,
		0x19, 0x70, 0x08, 0xfe, 0x37, 0x38, 0x39, 0x2f,
		0x29, 0xfe, 0xfe, 0xfe, 0xfe, 0x5e, 0x28, 0xfe
	}

--   按键布局 private final Area[][] layout 
local layout = {
	{ Area:init(  2,  81,  17, 16, "ON",    COLOR_WHITE, COLOR_GRAY),     Area:init(  2,  81,  17, 16, "ON",    COLOR_WHITE,  COLOR_GRAY),     Area:init(294,   7,  17, 16, "ON",    COLOR_WHITE,  COLOR_GRAY)     }, -- BREAK按键 */
	{ Area:init(  2,  97,  17, 16, "OFF",   COLOR_WHITE, COLOR_GRAY),     Area:init(  2,  97,  17, 16, "OFF",   COLOR_WHITE,  COLOR_GRAY),     Area:init(277,   7,  17, 16, "OFF",   COLOR_WHITE,  COLOR_GRAY)     }, -- OFF按键 */
	{ Area:init(189, 129,  22, 16, "ANS",   COLOR_WHITE, COLOR_GRAY),     Area:init(189, 129,  22, 16, "ANS",   COLOR_WHITE,  COLOR_GRAY),     Area:init(260,   7,  17, 16, "ANS",   COLOR_WHITE,  COLOR_GRAY)     }, -- ANS按键 */
	{ Area:init(189, 113,  22, 16, "CONST", COLOR_WHITE, COLOR_GRAY),     Area:init(189, 113,  22, 16, "CONST", COLOR_WHITE,  COLOR_GRAY),     Area:init(243,   7,  17, 16, "CONST", COLOR_WHITE,  COLOR_GRAY)     }, -- CONST按键 */
	{ Area:init( 19, 113,  17, 16, "TEXT",  COLOR_WHITE, COLOR_GREEN),    Area:init( 19, 113,  17, 16, "TEXT",  COLOR_LIGHTGREEN,  COLOR_GRAY),Area:init(226,   7,  17, 16, "TEXT",  COLOR_WHITE,  COLOR_GREEN)    }, -- TEXT按键 */
	{ Area:init(  2, 113,  17, 16, "BASIC", COLOR_WHITE, COLOR_GREEN),    Area:init(  2, 113,  17, 16, "BASIC", COLOR_LIGHTGREEN,  COLOR_GRAY),Area:init(209,   7,  17, 16, "BASIC", COLOR_WHITE,  COLOR_GREEN)    }, -- BASIC按键 */
	{ Area:init(297,  24,  17, 16, "CLS",   COLOR_WHITE, COLOR_RED),      Area:init(297,  24,  17, 16, "CLS",   COLOR_LIGHTRED,    COLOR_GRAY),Area:init(294,  24,  17, 16, "CLS",   COLOR_WHITE,  COLOR_RED)      }, -- CLS按键 */
	{ Area:init(280,  24,  17, 16, "F-E",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(280,  24,  17, 16, "F-E",   COLOR_WHITE,  COLOR_GRAY),     Area:init(277,  24,  17, 16, "F-E",   COLOR_WHITE,  COLOR_GRAY)     }, -- F←→E按键 */
	{ Area:init(263,  24,  17, 16, "tan",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(263,  24,  17, 16, "tan",   COLOR_WHITE,  COLOR_GRAY),     Area:init(260,  24,  17, 16, "tan",   COLOR_WHITE,  COLOR_GRAY)     }, -- tan按键 */
	{ Area:init(246,  24,  17, 16, "cos",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(246,  24,  17, 16, "cos",   COLOR_WHITE,  COLOR_GRAY),     Area:init(243,  24,  17, 16, "cos",   COLOR_WHITE,  COLOR_GRAY)     }, -- cos按键 */
	{ Area:init(229,  24,  17, 16, "sin",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(229,  24,  17, 16, "sin",   COLOR_WHITE,  COLOR_GRAY),     Area:init(226,  24,  17, 16, "sin",   COLOR_WHITE,  COLOR_GRAY)     }, -- sin按键 */
	{ Area:init(212,  24,  17, 16, "2ndF",  COLOR_BLACK, COLOR_YELLOW),   Area:init(212,  24,  17, 16, "2ndF",  COLOR_LIGHTYELLOW, COLOR_GRAY),Area:init(209,  24,  17, 16, "2ndF",  COLOR_WHITE,  COLOR_YELLOW)   }, -- 2ndF按键 */
	{ Area:init(297,  40,  17, 16, "MDF",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(297,  40,  17, 16, "MDF",   COLOR_WHITE,  COLOR_GRAY),     Area:init(294,  40,  17, 16, "MDF",   COLOR_WHITE,  COLOR_GRAY)     }, -- MDF按键 */
	{ Area:init(280,  40,  17, 16, "1/x",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(280,  40,  17, 16, "1/x",   COLOR_WHITE,  COLOR_GRAY),     Area:init(277,  40,  17, 16, "1/x",   COLOR_WHITE,  COLOR_GRAY)     }, -- 1/x按键 */
	{ Area:init(263,  40,  17, 16, "log",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(263,  40,  17, 16, "log",   COLOR_WHITE,  COLOR_GRAY),     Area:init(260,  40,  17, 16, "log",   COLOR_WHITE,  COLOR_GRAY)     }, -- log按键 */
	{ Area:init(246,  40,  17, 16, "ln",    COLOR_WHITE, COLOR_DARKGRAY), Area:init(246,  40,  17, 16, "ln",    COLOR_WHITE,  COLOR_GRAY),     Area:init(243,  40,  17, 16, "ln",    COLOR_WHITE,  COLOR_GRAY)     }, -- ln按键 */
	{ Area:init(229,  40,  17, 16, "→DEG", COLOR_WHITE, COLOR_DARKGRAY), Area:init(229,  40,  17, 16, "→DEG", COLOR_WHITE,  COLOR_GRAY),     Area:init(226,  40,  17, 16, "→DEG", COLOR_WHITE,  COLOR_GRAY)     }, -- →DEG按键 */
	{ Area:init(212,  40,  17, 16, "nPr",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(212,  40,  17, 16, "nPr",   COLOR_WHITE,  COLOR_GRAY),     Area:init(209,  40,  17, 16, "nPr",   COLOR_WHITE,  COLOR_GRAY)     }, -- nPr按键 */
	{ Area:init(297,  56,  17, 16, ")",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(297,  56,  17, 16, ")",     COLOR_WHITE,  COLOR_GRAY),     Area:init(294,  56,  17, 16, ")",     COLOR_WHITE,  COLOR_GRAY)     }, -- )按键 */
	{ Area:init(280,  56,  17, 16, "(",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(280,  56,  17, 16, "(",     COLOR_WHITE,  COLOR_GRAY),     Area:init(277,  56,  17, 16, "(",     COLOR_WHITE,  COLOR_GRAY)     }, -- (按键 */
	{ Area:init(263,  56,  17, 16, "^",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(263,  56,  17, 16, "^",     COLOR_WHITE,  COLOR_GRAY),     Area:init(260,  56,  17, 16, "^",     COLOR_WHITE,  COLOR_GRAY)     }, -- ^按键 */
	{ Area:init(246,  56,  17, 16, "x^2",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(246,  56,  17, 16, "x^2",   COLOR_WHITE,  COLOR_GRAY),     Area:init(243,  56,  17, 16, "x^2",   COLOR_WHITE,  COLOR_GRAY)     }, -- x^2按键 */
	{ Area:init(229,  56,  17, 16, "√",    COLOR_WHITE, COLOR_DARKGRAY), Area:init(229,  56,  17, 16, "√",    COLOR_WHITE,  COLOR_GRAY),     Area:init(226,  56,  17, 16, "√",    COLOR_WHITE,  COLOR_GRAY)     }, -- √按键 */
	{ Area:init(212,  56,  17, 16, "π",    COLOR_WHITE, COLOR_DARKGRAY), Area:init(212,  56,  17, 16, "π",    COLOR_WHITE,  COLOR_GRAY),     Area:init(209,  56,  17, 16, "π",    COLOR_WHITE,  COLOR_GRAY)     }, -- π按键 */
	{ Area:init(295,  73,  21, 18, "R・CM", COLOR_BLUE,  COLOR_DARKGRAY), Area:init(295,  73,  21, 18, "R・CM", COLOR_WHITE,  COLOR_DARKGRAY), Area:init(292,  73,  21, 18, "R・CM", COLOR_WHITE,  COLOR_DARKGRAY) }, -- R・CM按键 */
	{ Area:init(274,  73,  21, 18, "/",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(274,  73,  21, 18, "/",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(271,  73,  21, 18, "/",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- /按键 */
	{ Area:init(253,  73,  21, 18, "9",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(253,  73,  21, 18, "9",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(250,  73,  21, 18, "9",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 9按键 */
	{ Area:init(232,  73,  21, 18, "8",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(232,  73,  21, 18, "8",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(229,  73,  21, 18, "8",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 8按键 */
	{ Area:init(211,  73,  21, 18, "7",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(211,  73,  21, 18, "7",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(208,  73,  21, 18, "7",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 7按键 */
	{ Area:init(295,  91,  21, 18, "M+",    COLOR_BLUE,  COLOR_DARKGRAY), Area:init(295,  91,  21, 18, "M+",    COLOR_WHITE,  COLOR_DARKGRAY), Area:init(292,  91,  21, 18, "M+",    COLOR_WHITE,  COLOR_DARKGRAY) }, -- M+按键 */
	{ Area:init(274,  91,  21, 18, "*",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(274,  91,  21, 18, "*",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(271,  91,  21, 18, "*",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- *按键 */
	{ Area:init(253,  91,  21, 18, "6",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(253,  91,  21, 18, "6",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(250,  91,  21, 18, "6",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 6按键 */
	{ Area:init(232,  91,  21, 18, "5",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(232,  91,  21, 18, "5",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(229,  91,  21, 18, "5",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 5按键 */
	{ Area:init(211,  91,  21, 18, "4",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(211,  91,  21, 18, "4",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(208,  91,  21, 18, "4",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 4按键 */
	{ Area:init(295, 109,  21, 36, "",      COLOR_WHITE, COLOR_DARKGRAY), Area:init(295, 109,  21, 36, "",      COLOR_WHITE,  COLOR_DARKGRAY), Area:init(292, 109,  21, 36, "",      COLOR_WHITE,  COLOR_DARKGRAY) }, -- RETURN按键(テン按键側) */
	{ Area:init(274, 109,  21, 18, "-",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(274, 109,  21, 18, "-",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(271, 109,  21, 18, "-",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- -按键 */
	{ Area:init(253, 109,  21, 18, "3",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(253, 109,  21, 18, "3",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(250, 109,  21, 18, "3",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 3按键 */
	{ Area:init(232, 109,  21, 18, "2",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(232, 109,  21, 18, "2",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(229, 109,  21, 18, "2",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 2按键 */
	{ Area:init(211, 109,  21, 18, "1",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(211, 109,  21, 18, "1",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(208, 109,  21, 18, "1",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 1按键 */
	{ Area:init(274, 127,  21, 18, "+",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(274, 127,  21, 18, "+",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(271, 127,  21, 18, "+",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- +按键 */
	{ Area:init(253, 127,  21, 18, "Exp",   COLOR_WHITE, COLOR_DARKGRAY), Area:init(253, 127,  21, 18, "=",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(250, 127,  21, 18, "=",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- =按键 */
	{ Area:init(232, 127,  21, 18, ".",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(232, 127,  21, 18, ".",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(229, 127,  21, 18, ".",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- .按键 */
	{ Area:init(211, 127,  21, 18, "0",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(211, 127,  21, 18, "0",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(208, 127,  21, 18, "0",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- 0按键 */
	{ Area:init(192,  81,  19, 16, "BS",    COLOR_WHITE, COLOR_GRAY),     Area:init(192,  81,  19, 16, "BS",    COLOR_WHITE,  COLOR_GRAY),     Area:init(189,  81,  19, 16, "BS",    COLOR_WHITE,  COLOR_GRAY)     }, -- BS按键 */
	{ Area:init(175,  81,  17, 16, "P",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(175,  81,  17, 16, "P",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(172,  81,  17, 16, "P",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- P按键 */
	{ Area:init(158,  81,  17, 16, "O",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(158,  81,  17, 16, "O",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(155,  81,  17, 16, "O",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- O按键 */
	{ Area:init(141,  81,  17, 16, "I",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(141,  81,  17, 16, "I",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(138,  81,  17, 16, "I",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- I按键 */
	{ Area:init(124,  81,  17, 16, "U",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(124,  81,  17, 16, "U",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(121,  81,  17, 16, "U",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- U按键 */
	{ Area:init(107,  81,  17, 16, "Y",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(107,  81,  17, 16, "Y",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(104,  81,  17, 16, "Y",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- Y按键 */
	{ Area:init( 90,  81,  17, 16, "T",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 90,  81,  17, 16, "T",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 87,  81,  17, 16, "T",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- T按键 */
	{ Area:init( 73,  81,  17, 16, "R",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 73,  81,  17, 16, "R",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 70,  81,  17, 16, "R",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- R按键 */
	{ Area:init( 56,  81,  17, 16, "E",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 56,  81,  17, 16, "E",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 53,  81,  17, 16, "E",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- E按键 */
	{ Area:init( 39,  81,  17, 16, "W",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 39,  81,  17, 16, "W",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 36,  81,  17, 16, "W",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- W按键 */
	{ Area:init( 22,  81,  17, 16, "Q",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 22,  81,  17, 16, "Q",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 19,  81,  17, 16, "Q",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- Q按键 */
	{ Area:init( 67, 129,  20, 16, "TAB",   COLOR_WHITE, COLOR_GRAY),     Area:init( 67, 129,  20, 16, "TAB",   COLOR_WHITE,  COLOR_GRAY),     Area:init(  2,  81,  17, 16, "TAB",   COLOR_WHITE,  COLOR_GRAY)     }, -- TAB按键 */
	{ nil,                                                 nil,                                                                            Area:init(186,  97,  22, 32, "",      COLOR_WHITE,  COLOR_GRAY)     }, -- RETURN按键(アルファベット按键側) */
	{ Area:init(172, 113,  17, 16, ";",     COLOR_WHITE, COLOR_GRAY),     Area:init(172, 113,  17, 16, ";",     COLOR_WHITE,  COLOR_GRAY),     Area:init(176,  97,  17, 16, ";",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- ;按键 */
	{ Area:init(162,  97,  17, 16, "L",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(162,  97,  17, 16, "L",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(159,  97,  17, 16, "L",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- L按键 */
	{ Area:init(145,  97,  17, 16, "K",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(145,  97,  17, 16, "K",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(142,  97,  17, 16, "K",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- K按键 */
	{ Area:init(128,  97,  17, 16, "J",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(128,  97,  17, 16, "J",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(125,  97,  17, 16, "J",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- J按键 */
	{ Area:init(111,  97,  17, 16, "H",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(111,  97,  17, 16, "H",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(108,  97,  17, 16, "H",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- H按键 */
	{ Area:init( 94,  97,  17, 16, "G",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 94,  97,  17, 16, "G",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 91,  97,  17, 16, "G",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- G按键 */
	{ Area:init( 77,  97,  17, 16, "F",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 77,  97,  17, 16, "F",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 74,  97,  17, 16, "F",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- F按键 */
	{ Area:init( 60,  97,  17, 16, "D",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 60,  97,  17, 16, "D",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 57,  97,  17, 16, "D",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- D按键 */
	{ Area:init( 43,  97,  17, 16, "S",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 43,  97,  17, 16, "S",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 40,  97,  17, 16, "S",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- S按键 */
	{ Area:init( 26,  97,  17, 16, "A",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 26,  97,  17, 16, "A",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 23,  97,  17, 16, "A",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- A按键 */
	{ Area:init( 33, 129,  17, 16, "CAPS",  COLOR_WHITE, COLOR_GRAY),     Area:init( 33, 129,  17, 16, "CAPS",  COLOR_WHITE,  COLOR_GRAY),     Area:init(  2,  97,  21, 16, "CAPS",  COLOR_WHITE,  COLOR_GRAY)     }, -- CAPS按键 */
	{ Area:init(138, 129,  17, 16, "↑",    COLOR_WHITE, COLOR_GRAY),     Area:init(138, 129,  17, 16, "↑",    COLOR_WHITE,  COLOR_GRAY),     Area:init(169, 113,  17, 16, "↑",    COLOR_WHITE,  COLOR_GRAY)     }, -- ↑按键 */
	{ Area:init(155, 113,  17, 16, ",",     COLOR_WHITE, COLOR_GRAY),     Area:init(155, 113,  17, 16, ",",     COLOR_WHITE,  COLOR_GRAY),     Area:init(152, 113,  17, 16, ",",     COLOR_WHITE,  COLOR_GRAY)     }, -- ,按键 */
	{ Area:init(138, 113,  17, 16, "M",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(138, 113,  17, 16, "M",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(135, 113,  17, 16, "M",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- M按键 */
	{ Area:init(121, 113,  17, 16, "N",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(121, 113,  17, 16, "N",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(118, 113,  17, 16, "N",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- N按键 */
	{ Area:init(104, 113,  17, 16, "B",     COLOR_WHITE, COLOR_DARKGRAY), Area:init(104, 113,  17, 16, "B",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init(101, 113,  17, 16, "B",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- B按键 */
	{ Area:init( 87, 113,  17, 16, "V",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 87, 113,  17, 16, "V",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 84, 113,  17, 16, "V",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- V按键 */
	{ Area:init( 70, 113,  17, 16, "C",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 70, 113,  17, 16, "C",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 67, 113,  17, 16, "C",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- C按键 */
	{ Area:init( 53, 113,  17, 16, "X",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 53, 113,  17, 16, "X",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 50, 113,  17, 16, "X",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- X按键 */
	{ Area:init( 36, 113,  17, 16, "Z",     COLOR_WHITE, COLOR_DARKGRAY), Area:init( 36, 113,  17, 16, "Z",     COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 33, 113,  17, 16, "Z",     COLOR_WHITE,  COLOR_DARKGRAY) }, -- Z按键 */
	{ Area:init(  2, 129,  31, 16, "SHIFT", COLOR_BLACK, COLOR_YELLOW)  , Area:init(  2, 129,  31, 16, "SHIFT", COLOR_LIGHTYELLOW, COLOR_GRAY),Area:init(  2, 113,  31, 16, "SHIFT", COLOR_WHITE,  COLOR_YELLOW)   }, -- SHIFT按键 */
	{ Area:init(172, 129,  17, 16, "→",    COLOR_WHITE, COLOR_GRAY),     Area:init(172, 129,  17, 16, "→",    COLOR_WHITE,  COLOR_GRAY),     Area:init(186, 129,  17, 16, "→",    COLOR_WHITE,  COLOR_GRAY)     }, -- →按键 */
	{ Area:init(121, 129,  17, 16, "↓",    COLOR_WHITE, COLOR_GRAY),     Area:init(121, 129,  17, 16, "↓",    COLOR_WHITE,  COLOR_GRAY),     Area:init(169, 129,  17, 16, "↓",    COLOR_WHITE,  COLOR_GRAY)     }, -- ↓按键 */
	{ Area:init(155, 129,  17, 16, "←",    COLOR_WHITE, COLOR_GRAY),     Area:init(155, 129,  17, 16, "←",    COLOR_WHITE,  COLOR_GRAY),     Area:init(152, 129,  17, 16, "←",    COLOR_WHITE,  COLOR_GRAY)     }, -- ←按键 */
	{ Area:init(189,  97,  22, 16, "INS",   COLOR_WHITE, COLOR_GRAY),     Area:init(189,  97,  22, 16, "INS",   COLOR_WHITE,  COLOR_GRAY),     Area:init(135, 129,  17, 16, "INS",   COLOR_WHITE,  COLOR_GRAY)     }, -- INS按键 */
	{ Area:init( 87, 129,  34, 16, "SPACE", COLOR_WHITE, COLOR_DARKGRAY), Area:init( 87, 129,  34, 16, "SPACE", COLOR_WHITE,  COLOR_DARKGRAY), Area:init( 50, 129,  85, 16, "",      COLOR_WHITE,  COLOR_DARKGRAY) }, -- SPACE按键 */
	{ Area:init( 50, 129,  17, 16, "カナ",  COLOR_WHITE, COLOR_GRAY),     Area:init( 50, 129,  17, 16, "カナ",  COLOR_WHITE,  COLOR_GRAY),     Area:init( 28, 129,  21, 16, "カナ",  COLOR_WHITE,  COLOR_GRAY)     }, -- カナ按键 */
	{ Area:init( 19,  97,   7, 16, ""),                      Area:init( 19,  97,   7, 16, ""),                      Area:init( 14, 129,  12, 16, "")                      }, -- RESETボタン */
	{ Area:init( 33,  31, 144, 32),                          Area:init( 33,  31, 144, 32),                          Area:init( 27,  20, 144, 48)                          }, -- LCDドットマトリクス部 */
	{ Area:init( 33,  25,  12,  5, "BUSY"),                  Area:init( 33,  25,  12,  5, "BUSY"),                  null                                                 }, -- LCDステータス部0 */
	{ Area:init( 50,  25,  12,  5, "CAPS"),                  Area:init( 45,  63,   9,  5, "RUN"),                   Area:init(172,  19,   9,  5, "RUN")                   }, -- LCDステータス部1 */
	{ Area:init( 65,  25,   9,  5, "カナ"),                  Area:init( 57,  63,   9,  5, "PRO"),                   null                                                 }, -- LCDステータス部2 */
	{ Area:init( 78,  25,   6,  5, "小"),                    Area:init( 75,  63,  12,  5, "CASL"),                  Area:init(181,  19,   9,  5, "PRO")                   }, -- LCDステータス部3 */
	{ Area:init( 98,  25,  12,  5, "2ndF"),                  nil,                                                 null                                                 }, -- LCDステータス部4 */
	{ nil,                                                 Area:init(138,  63,  12,  5, "STAT"),                  null                                                 }, -- LCDステータス部5 */
	{ nil,                                                 Area:init( 88,  63,  12,  5, "TEXT"),                  Area:init(172,  24,  12,  5, "TEXT")                  }, -- LCDステータス部6 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部7 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部8 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部9 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部10 */
	{ nil,                                                 nil,                                                 Area:init(172,  29,  12,  5, "CASL")                  }, -- LCDステータス部11 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部12 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部13 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部14 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部15 */
	{ nil,                                                 nil,                                                 Area:init(172,  34,  12,  5, "STAT")                  }, -- LCDステータス部16 */
	{ nil,                                                 Area:init(161,  25,   3,  5, "E"),                     null                                                 }, -- LCDステータス部17 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部18 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部19 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部20 */
	{ nil,                                                 nil,                                                 Area:init(172,  39,  12,  5, "2ndF")                  }, -- LCDステータス部21 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部22 */
	{ nil,                                                 nil,                                                 Area:init(186,  39,   3,  5, "M")                     }, -- LCDステータス部23 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部24 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部25 */
	{ nil,                                                 nil,                                                 Area:init(172,  44,  12,  5, "CAPS")                  }, -- LCDステータス部26 */
	{ Area:init( 88,  63,  12,  5, "TEXT"),                  nil,                                                 null                                                 }, -- LCDステータス部27 */
	{ Area:init( 75,  63,  12,  5, "CASL"),                  nil,                                                 null                                                 }, -- LCDステータス部28 */
	{ Area:init( 57,  63,   9,  5, "PRO"),                   nil,                                                 null                                                 }, -- LCDステータス部29 */
	{ Area:init( 45,  63,   9,  5, "RUN"),                   nil,                                                 null                                                 }, -- LCDステータス部30 */
	{ nil,                                                 nil,                                                 Area:init(172,  49,   9,  5, "カナ")                  }, -- LCDステータス部31 */
	{ Area:init(165,  25,  12,  5, "BATT"),                  Area:init( 78,  25,   6,  5, "小"),                    null                                                 }, -- LCDステータス部32 */
	{ Area:init(161,  25,   3,  5, "E"),                     Area:init( 65,  25,   9,  5, "カナ"),                  Area:init(182,  49,   6,  5, "小")                    }, -- LCDステータス部33 */
	{ Area:init(147,  25,   3,  5, "M"),                     Area:init(130,  25,  15,  5, "CONST"),                 null                                                 }, -- LCDステータス部34 */
	{ Area:init(130,  25,  15,  5, "CONST"),                 Area:init( 50,  25,  12,  5, "CAPS"),                  null                                                 }, -- LCDステータス部35 */
	{ Area:init(120,  25,   9,  5, "RAD"),                   Area:init( 98,  25,  12,  5, "2ndF"),                  Area:init(172,  54,   6,  5, "DE")                    }, -- LCDステータス部36 */
	{ Area:init(117,  25,   3,  5, "G"),                     nil,                                                 null                                                 }, -- LCDステータス部37 */
	{ Area:init(111,  25,   6,  5, "DE"),                    nil,                                                 Area:init(178,  54,   3,  5, "G")                     }, -- LCDステータス部38 */
	{ nil,                                                 Area:init(156,  63,  15,  5, "PRINT"),                 null                                                 }, -- LCDステータス部39 */
	{ nil,                                                 Area:init(147,  25,   3,  5, "M"),                     Area:init(181,  54,   9,  5, "RAD")                   }, -- LCDステータス部40 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部41 */
	{ nil,                                                 Area:init(120,  25,   9,  5, "RAD"),                   Area:init(172,  59,  15,  5, "CONST")                 }, -- LCDステータス部42 */
	{ nil,                                                 Area:init(117,  25,   3,  5, "G"),                     null                                                 }, -- LCDステータス部43 */
	{ nil,                                                 Area:init(111,  25,   6,  5, "DE"),                    Area:init(172,  64,  15,  5, "PRINT")                 }, -- LCDステータス部44 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部45 */
	{ nil,                                                 nil,                                                 Area:init( 14,  59,  12,  5, "BUSY")                  }, -- LCDステータス部46 */
	{ nil,                                                 nil,                                                 Area:init( 14,  64,  12,  5, "BATT")                  }, -- LCDステータス部47 */
	{ nil,                                                 Area:init(165,  25,  12,  5, "BATT"),                  null                                                 }, -- LCDステータス部48 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部49 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部50 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部51 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部52 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部53 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部54 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部55 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部56 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部57 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部58 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部59 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部60 */
	{ Area:init(138,  63,  12,  5, "STAT"),                  nil,                                                 null                                                 }, -- LCDステータス部61 */
	{ Area:init(156,  63,  15,  5, "PRINT"),                 nil,                                                 null                                                 }, -- LCDステータス部62 */
	{ nil,                                                 nil,                                                 null                                                 }, -- LCDステータス部63 */
	{ Area:init( 31,  24, 148, 46),                          Area:init( 31,  24, 148, 46),                          Area:init( 13,  17, 179, 54)                          }, -- LCD全体 */
	{ Area:init(  2,  17, 206, 60),                          Area:init(  2,  17, 206, 60),                          Area:init(  0,   4, 205, 74)                          }, -- 画面枠 */
	{ Area:init( 33,  18,   6,  5, "0",     COLOR_WHITE),    Area:init( 33,  18,   6,  5, "0",     COLOR_WHITE),    Area:init( 27,  71,   6,  5, "0",     COLOR_WHITE)    }, -- 0列目 */
	{ Area:init( 39,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 39,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 33,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 1列目 */
	{ Area:init( 45,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 45,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 39,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 2列目 */
	{ Area:init( 51,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 51,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 45,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 3列目 */
	{ Area:init( 57,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 57,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 51,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 4列目 */
	{ Area:init( 63,  18,   6,  5, "5",     COLOR_WHITE),    Area:init( 63,  18,   6,  5, "5",     COLOR_WHITE),    Area:init( 57,  71,   6,  5, "5",     COLOR_WHITE)    }, -- 5列目 */
	{ Area:init( 69,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 69,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 63,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 6列目 */
	{ Area:init( 75,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 75,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 69,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 7列目 */
	{ Area:init( 81,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 81,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 75,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 8列目 */
	{ Area:init( 87,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 87,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 81,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 9列目 */
	{ Area:init( 93,  18,   6,  5, "10",    COLOR_WHITE),    Area:init( 93,  18,   6,  5, "10",    COLOR_WHITE),    Area:init( 87,  71,   6,  5, "10",    COLOR_WHITE)    }, -- 10列目 */
	{ Area:init( 99,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 99,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 93,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 11列目 */
	{ Area:init(105,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(105,  18,   6,  5, "・",    COLOR_WHITE),    Area:init( 99,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 12列目 */
	{ Area:init(111,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(111,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(105,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 13列目 */
	{ Area:init(117,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(117,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(111,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 14列目 */
	{ Area:init(123,  18,   6,  5, "15",    COLOR_WHITE),    Area:init(123,  18,   6,  5, "15",    COLOR_WHITE),    Area:init(117,  71,   6,  5, "15",    COLOR_WHITE)    }, -- 15列目 */
	{ Area:init(129,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(129,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(123,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 16列目 */
	{ Area:init(135,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(135,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(129,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 17列目 */
	{ Area:init(141,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(141,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(135,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 18列目 */
	{ Area:init(147,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(147,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(141,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 19列目 */
	{ Area:init(153,  18,   6,  5, "20",    COLOR_WHITE),    Area:init(153,  18,   6,  5, "20",    COLOR_WHITE),    Area:init(147,  71,   6,  5, "20",    COLOR_WHITE)    }, -- 20列目 */
	{ Area:init(159,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(159,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(153,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 21列目 */
	{ Area:init(165,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(165,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(159,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 22列目 */
	{ Area:init(171,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(171,  18,   6,  5, "・",    COLOR_WHITE),    Area:init(165,  71,   6,  5, "・",    COLOR_WHITE)    }, -- 23列目 */
	{ Area:init( 33,  71,   6,  5, "・",    COLOR_WHITE),    Area:init( 33,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, -- 0列目 */
	{ Area:init( 63,  71,   6,  5, "・",    COLOR_WHITE),    Area:init( 63,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, -- 5列目 */
	{ Area:init( 93,  71,   6,  5, "・",    COLOR_WHITE),    Area:init( 93,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, -- 10列目 */
	{ Area:init(123,  71,   6,  5, "・",    COLOR_WHITE),    Area:init(123,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, -- 15列目 */
	{ Area:init(153,  71,   6,  5, "・",    COLOR_WHITE),    Area:init(153,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, -- 20列目 */
	{ Area:init(179,  31,   8,  8, "－",    COLOR_WHITE),    Area:init(179,  31,   8,  8, "－",    COLOR_WHITE),    Area:init(191,  20,   8,  8, "－",    COLOR_WHITE)    }, -- 0行目(右) */
	{ Area:init(179,  39,   8,  8, "－",    COLOR_WHITE),    Area:init(179,  39,   8,  8, "－",    COLOR_WHITE),    Area:init(191,  28,   8,  8, "－",    COLOR_WHITE)    }, -- 1行目(右) */
	{ Area:init(179,  47,   8,  8, "－",    COLOR_WHITE),    Area:init(179,  47,   8,  8, "－",    COLOR_WHITE),    Area:init(191,  36,   8,  8, "－",    COLOR_WHITE)    }, -- 2行目(右) */
	{ Area:init(179,  55,   8,  8, "－",    COLOR_WHITE),    Area:init(179,  55,   8,  8, "－",    COLOR_WHITE),    Area:init(191,  44,   8,  8, "－",    COLOR_WHITE)    }, -- 3行目(右) */
	{ nil,                                                 nil,                                                 Area:init(191,  52,   8,  8, "－",    COLOR_WHITE)    }, -- 4行目(右) */
	{ nil,                                                 nil,                                                 Area:init(191,  60,   8,  8, "－",    COLOR_WHITE)    }, -- 5行目(右) */
	{ Area:init( 23,  31,   8,  8, "－",    COLOR_WHITE),    Area:init( 23,  31,   8,  8, "－",    COLOR_WHITE),    Area:init(  5,  20,   8,  8, "－",    COLOR_WHITE)    }, -- 0行目(左) */
	{ Area:init( 23,  39,   8,  8, "－",    COLOR_WHITE),    Area:init( 23,  39,   8,  8, "－",    COLOR_WHITE),    Area:init(  5,  28,   8,  8, "－",    COLOR_WHITE)    }, -- 1行目(左) */
	{ Area:init( 23,  47,   8,  8, "－",    COLOR_WHITE),    Area:init( 23,  47,   8,  8, "－",    COLOR_WHITE),    Area:init(  5,  36,   8,  8, "－",    COLOR_WHITE)    }, -- 2行目(左) */
	{ Area:init( 23,  55,   8,  8, "－",    COLOR_WHITE),    Area:init( 23,  55,   8,  8, "－",    COLOR_WHITE),    Area:init(  5,  44,   8,  8, "－",    COLOR_WHITE)    }, -- 3行目(左) */
	{ nil,                                                 nil,                                                 Area:init(  5,  52,   8,  8, "－",    COLOR_WHITE)    }, -- 4行目(左) */
	{ nil,                                                 nil,                                                 Area:init(  5,  60,   8,  8, "－",    COLOR_WHITE)    }, -- 5行目(左) */
	{ Area:init(312,  64,   4,  5, "」",    COLOR_WHITE),    Area:init(312,  64,   4,  5, "」",    COLOR_WHITE),    Area:init(309,  67,   4,  5, "」",    COLOR_WHITE)    }, -- 右カギカッコ */
	{ Area:init(295,  64,   4,  5, "「",    COLOR_WHITE),    Area:init(295,  64,   4,  5, "「",    COLOR_WHITE),    Area:init(292,  67,   4,  5, "「",    COLOR_WHITE)    }, -- 左カギカッコ */
	{ Area:init(293, 137,   4,  5, "・",    COLOR_WHITE),    Area:init(293, 137,   4,  5, "・",    COLOR_WHITE),    Area:init(290, 141,   4,  5, "・",    COLOR_WHITE)    }, -- 中点 */
	{ Area:init(251, 137,   4,  5, "。",    COLOR_WHITE),    Area:init(251, 137,   4,  5, "。",    COLOR_WHITE),    Area:init(248, 141,   4,  5, "。",    COLOR_WHITE)    }, -- 読点 */
	{ Area:init(170, 121,   4,  5, "、",    COLOR_WHITE),    Area:init(170, 121,   4,  5, "、",    COLOR_WHITE),    Area:init(167, 125,   4,  5, "、",    COLOR_WHITE)    }, -- 句点 */
	{ Area:init(  2,  79,  17,  5, "BREAK", COLOR_WHITE),    Area:init(  2,  79,  17,  5, "BREAK", COLOR_WHITE),    Area:init(294,   5,  17,  5, "BREAK", COLOR_WHITE)    }, -- BREAK */
	{ nil,                                                 nil,                                                 Area:init(260,   5,  17,  5, "コントラスト", COLOR_YELLOW) }, -- コントラスト */
	{ Area:init( 19, 111,  17,  5, "CASL",  COLOR_YELLOW),   Area:init( 19, 111,  17,  5, "C",     COLOR_YELLOW),   Area:init(226,   5,  17,  5, "C",     COLOR_YELLOW)   }, -- CASL/C */
	{ nil,                                                 Area:init(  2, 111,  17,  5, "ASMBL", COLOR_YELLOW),   Area:init(209,   5,  17,  5, "ASMBL", COLOR_YELLOW)   }, -- ASMBL */
	{ Area:init(297,  22,  16,  5, "CA",    COLOR_YELLOW),   Area:init(297,  22,  16,  5, "CA",    COLOR_YELLOW),   Area:init(294,  22,  17,  5, "CA",    COLOR_YELLOW)   }, -- CA */
	{ Area:init(280,  22,  16,  5, "DIGIT", COLOR_YELLOW),   Area:init(280,  22,  16,  5, "DIGIT", COLOR_YELLOW),   Area:init(277,  22,  17,  5, "DIGIT", COLOR_YELLOW)   }, -- DIGIT */
	{ Area:init(263,  22,  16,  5, "atan",  COLOR_YELLOW),   Area:init(263,  22,  16,  5, "atan",  COLOR_YELLOW),   Area:init(260,  22,  17,  5, "atan",  COLOR_YELLOW)   }, -- atan */
	{ Area:init(246,  22,  16,  5, "acos",  COLOR_YELLOW),   Area:init(246,  22,  16,  5, "acos",  COLOR_YELLOW),   Area:init(243,  22,  17,  5, "acos",  COLOR_YELLOW)   }, -- acos */
	{ Area:init(229,  22,  16,  5, "asin",  COLOR_YELLOW),   Area:init(229,  22,  16,  5, "asin",  COLOR_YELLOW),   Area:init(226,  22,  17,  5, "asin",  COLOR_YELLOW)   }, -- asin */
	{ Area:init(297,  38,  16,  5, "STAT",  COLOR_YELLOW),   Area:init(297,  38,  16,  5, "STAT",  COLOR_YELLOW),   Area:init(294,  38,  17,  5, "STAT",  COLOR_YELLOW)   }, -- STAT */
	{ Area:init(280,  38,  16,  5, "n!",    COLOR_YELLOW),   Area:init(280,  38,  16,  5, "n!",    COLOR_YELLOW),   Area:init(277,  38,  17,  5, "n!",    COLOR_YELLOW)   }, -- n! */
	{ Area:init(263,  38,  16,  5, "10^x",  COLOR_YELLOW),   Area:init(263,  38,  16,  5, "10^x",  COLOR_YELLOW),   Area:init(260,  38,  17,  5, "10^x",  COLOR_YELLOW)   }, -- 10^x */
	{ Area:init(246,  38,  16,  5, "e^x",   COLOR_YELLOW),   Area:init(246,  38,  16,  5, "e^x",   COLOR_YELLOW),   Area:init(243,  38,  17,  5, "e^x",   COLOR_YELLOW)   }, -- e^x */
	{ Area:init(229,  38,  16,  5, "DMS",   COLOR_YELLOW),   Area:init(229,  38,  16,  5, "DMS",   COLOR_YELLOW),   Area:init(226,  38,  17,  5, "DMS",   COLOR_YELLOW)   }, -- DMS */
	{ Area:init(212,  38,  16,  5, "nCr",   COLOR_YELLOW),   Area:init(212,  38,  16,  5, "nCr",   COLOR_YELLOW),   Area:init(209,  38,  17,  5, "nCr",   COLOR_YELLOW)   }, -- nCr */
	{ nil,                                                 Area:init(297,  54,  17,  5, "BASE-n",COLOR_YELLOW),   Area:init(294,  54,  17,  5, "BASE-n",COLOR_YELLOW)   }, -- BASE-n */
	{ Area:init(280,  54,  16,  5, "→xy",  COLOR_YELLOW),   Area:init(280,  54,  16,  5, "→xy",  COLOR_YELLOW),   Area:init(277,  54,  17,  5, "→xy",  COLOR_YELLOW)   }, -- →xy */
	{ Area:init(263,  54,  16,  5, "→rθ", COLOR_YELLOW),   Area:init(263,  54,  16,  5, "→rθ", COLOR_YELLOW),   Area:init(260,  54,  17,  5, "→rθ", COLOR_YELLOW)   }, -- →rθ */
	{ Area:init(246,  54,  16,  5, "x^3",   COLOR_YELLOW),   Area:init(246,  54,  16,  5, "x^3",   COLOR_YELLOW),   Area:init(243,  54,  17,  5, "x^3",   COLOR_YELLOW)   }, -- x^3 */
	{ Area:init(229,  54,  16,  5, "3√",   COLOR_YELLOW),   Area:init(229,  54,  16,  5, "3√",   COLOR_YELLOW),   Area:init(226,  54,  17,  5, "3√",   COLOR_YELLOW)   }, -- 3√ */
	{ Area:init(212,  54,  16,  5, "RND",   COLOR_YELLOW),   Area:init(212,  54,  16,  5, "RND",   COLOR_YELLOW),   Area:init(209,  54,  17,  5, "RND",   COLOR_YELLOW)   }, -- RND */
	{ nil,                                                 nil,                                                 Area:init(250,  71,  21,  5, "″",    COLOR_YELLOW)   }, -- ″ */
	{ nil,                                                 nil,                                                 Area:init(229,  71,  21,  5, "′",    COLOR_YELLOW)   }, -- ′ */
	{ nil,                                                 nil,                                                 Area:init(208,  71,  21,  5, "°",    COLOR_YELLOW)   }, -- ° */
	{ Area:init(295,  89,  19,  5, "M-",    COLOR_YELLOW),   Area:init(295,  89,  19,  5, "M-",    COLOR_YELLOW),   Area:init(292,  89,  21,  5, "M-",    COLOR_YELLOW)   }, -- M- */
	{ Area:init(295, 107,  19,  5, "P-NP",  COLOR_YELLOW),   Area:init(295, 107,  19,  5, "P-NP",  COLOR_YELLOW),   Area:init(292, 107,  21,  5, "P-NP",  COLOR_YELLOW)   }, -- P-NP */
	{ Area:init(274, 107,  19,  5, "(-)",   COLOR_YELLOW),   Area:init(274, 107,  19,  5, "(-)",   COLOR_YELLOW),   Area:init(272, 107,  21,  5, "(-)",   COLOR_YELLOW)   }, -- (-) */
	{ nil,                                                 Area:init(253, 125,  19,  5, "Exp",   COLOR_YELLOW),   Area:init(250, 125,  21,  5, "Exp",   COLOR_YELLOW)   }, -- Exp */
	{ Area:init(232, 125,  19,  5, "DRG",   COLOR_YELLOW),   Area:init(232, 125,  19,  5, "DRG",   COLOR_YELLOW),   Area:init(229, 125,  21,  5, "DRG",   COLOR_YELLOW)   }, -- DRG */
	{ Area:init(175,  79,  15,  5, "@",     COLOR_YELLOW),   Area:init(175,  79,  15,  5, "@",     COLOR_YELLOW),   Area:init(172,  79,  17,  5, "@",     COLOR_YELLOW)   }, -- @ */
	{ Area:init(158,  79,  15,  5, ">",     COLOR_YELLOW),   Area:init(158,  79,  15,  5, ">",     COLOR_YELLOW),   Area:init(155,  79,  17,  5, ">",     COLOR_YELLOW)   }, -- > */
	{ Area:init(141,  79,  15,  5, "<",     COLOR_YELLOW),   Area:init(141,  79,  15,  5, "<",     COLOR_YELLOW),   Area:init(138,  79,  17,  5, "<",     COLOR_YELLOW)   }, -- < */
	{ Area:init(124,  79,  15,  5, "'",     COLOR_YELLOW),   Area:init(124,  79,  15,  5, "'",     COLOR_YELLOW),   Area:init(121,  79,  17,  5, "'",     COLOR_YELLOW)   }, -- ' */
	{ Area:init(107,  79,  15,  5, "&",     COLOR_YELLOW),   Area:init(107,  79,  15,  5, "&",     COLOR_YELLOW),   Area:init(104,  79,  17,  5, "&",     COLOR_YELLOW)   }, -- & */
	{ Area:init( 90,  79,  15,  5, "%",     COLOR_YELLOW),   Area:init( 90,  79,  15,  5, "%",     COLOR_YELLOW),   Area:init( 87,  79,  17,  5, "%",     COLOR_YELLOW)   }, -- % */
	{ Area:init( 73,  79,  15,  5, "$",     COLOR_YELLOW),   Area:init( 73,  79,  15,  5, "$",     COLOR_YELLOW),   Area:init( 70,  79,  17,  5, "$",     COLOR_YELLOW)   }, -- $ */
	{ Area:init( 56,  79,  15,  5, "#",     COLOR_YELLOW),   Area:init( 56,  79,  15,  5, "#",     COLOR_YELLOW),   Area:init( 53,  79,  17,  5, "#",     COLOR_YELLOW)   }, -- # */
	{ Area:init( 39,  79,  15,  5, "\"",    COLOR_YELLOW),   Area:init( 39,  79,  15,  5, "\"",    COLOR_YELLOW),   Area:init( 36,  79,  17,  5, "\"",    COLOR_YELLOW)   }, -- " */
	{ Area:init( 22,  79,  15,  5, "!",     COLOR_YELLOW),   Area:init( 22,  79,  15,  5, "!",     COLOR_YELLOW),   Area:init( 19,  79,  17,  5, "!",     COLOR_YELLOW)   }, -- ! */
	{ nil,                                                 nil,                                                 Area:init(194,  95,  14,  5, "P-NP",  COLOR_YELLOW)   }, -- P-NP(アルファベット按键側) */
	{ Area:init(172, 111,  15,  5, ":",     COLOR_YELLOW),   Area:init(172, 111,  15,  5, ":",     COLOR_YELLOW),   Area:init(176,  95,  17,  5, ":",     COLOR_YELLOW)   }, -- : */
	{ Area:init(162,  95,  15,  5, "=",     COLOR_YELLOW),   Area:init(162,  95,  15,  5, "=",     COLOR_YELLOW),   Area:init(159,  95,  17,  5, "=",     COLOR_YELLOW)   }, -- = */
	{ Area:init(145,  95,  15,  5, "_",     COLOR_YELLOW),   Area:init(145,  95,  15,  5, "_",     COLOR_YELLOW),   Area:init(142,  95,  17,  5, "_",     COLOR_YELLOW)   }, -- _ */
	{ Area:init(128,  95,  15,  5, "~",     COLOR_YELLOW),   Area:init(128,  95,  15,  5, "~",     COLOR_YELLOW),   Area:init(125,  95,  17,  5, "~",     COLOR_YELLOW)   }, -- ~ */
	{ Area:init(111,  95,  15,  5, "|",     COLOR_YELLOW),   Area:init(111,  95,  15,  5, "|",     COLOR_YELLOW),   Area:init(108,  95,  17,  5, "|",     COLOR_YELLOW)   }, -- | */
	{ Area:init( 94,  95,  15,  5, "\\",    COLOR_YELLOW),   Area:init( 94,  95,  15,  5, "\\",    COLOR_YELLOW),   Area:init( 91,  95,  17,  5, "\\",    COLOR_YELLOW)   }, -- \ */
	{ Area:init( 77,  95,  15,  5, "}",     COLOR_YELLOW),   Area:init( 77,  95,  15,  5, "}",     COLOR_YELLOW),   Area:init( 74,  95,  17,  5, "}",     COLOR_YELLOW)   }, -- } */
	{ Area:init( 60,  95,  15,  5, "{",     COLOR_YELLOW),   Area:init( 60,  95,  15,  5, "{",     COLOR_YELLOW),   Area:init( 57,  95,  17,  5, "{",     COLOR_YELLOW)   }, -- { */
	{ Area:init( 43,  95,  15,  5, "]",     COLOR_YELLOW),   Area:init( 43,  95,  15,  5, "]",     COLOR_YELLOW),   Area:init( 40,  95,  17,  5, "]",     COLOR_YELLOW)   }, -- ] */
	{ Area:init( 26,  95,  15,  5, "[",     COLOR_YELLOW),   Area:init( 26,  95,  15,  5, "[",     COLOR_YELLOW),   Area:init( 23,  95,  17,  5, "[",     COLOR_YELLOW)   }, -- [ */
	{ Area:init( 33, 127,  15,  5, "小文字",COLOR_WHITE),    Area:init( 33, 127,  15,  5, "小文字",COLOR_WHITE),    Area:init(  2,  95,  21,  5, "小文字",COLOR_WHITE)    }, -- 小文字 */
	{ Area:init(155, 111,  15,  5, "?",     COLOR_YELLOW),   Area:init(155, 111,  15,  5, "?",     COLOR_YELLOW),   Area:init(152, 111,  17,  5, "?",     COLOR_YELLOW)   }, -- ? */
	{ Area:init(138, 111,  15,  5, "LOAD",  COLOR_YELLOW),   Area:init(138, 111,  15,  5, "LOAD",  COLOR_YELLOW),   Area:init(135, 111,  17,  5, "LOAD",  COLOR_YELLOW)   }, -- LOAD */
	{ Area:init(121, 111,  15,  5, "SAVE",  COLOR_YELLOW),   Area:init(121, 111,  15,  5, "SAVE",  COLOR_YELLOW),   Area:init(118, 111,  17,  5, "SAVE",  COLOR_YELLOW)   }, -- SAVE */
	{ Area:init(104, 111,  15,  5, "LIST",  COLOR_YELLOW),   Area:init(104, 111,  15,  5, "LIST",  COLOR_YELLOW),   Area:init(101, 111,  17,  5, "LIST",  COLOR_YELLOW)   }, -- LIST */
	{ Area:init( 87, 111,  15,  5, "RUN",   COLOR_YELLOW),   Area:init( 87, 111,  15,  5, "RUN",   COLOR_YELLOW),   Area:init( 84, 111,  17,  5, "RUN",   COLOR_YELLOW)   }, -- RUN */
	{ Area:init( 70, 111,  15,  5, "CONT",  COLOR_YELLOW),   Area:init( 70, 111,  15,  5, "CONT",  COLOR_YELLOW),   Area:init( 67, 111,  17,  5, "CONT",  COLOR_YELLOW)   }, -- CONT */
	{ Area:init( 53, 111,  15,  5, "PRINT", COLOR_YELLOW),   Area:init( 53, 111,  15,  5, "PRINT", COLOR_YELLOW),   Area:init( 50, 111,  17,  5, "PRINT", COLOR_YELLOW)   }, -- PRINT */
	{ Area:init( 36, 111,  15,  5, "INPUT", COLOR_YELLOW),   Area:init( 36, 111,  15,  5, "INPUT", COLOR_YELLOW),   Area:init( 33, 111,  17,  5, "INPUT", COLOR_YELLOW)   }, -- INPUT */
	{ Area:init(189,  95,  20,  5, "DEL",   COLOR_YELLOW),   Area:init(189,  95,  20,  5, "DEL",   COLOR_YELLOW),   Area:init(135, 127,  17,  5, "DEL",   COLOR_YELLOW)   }, -- DEL */
	{ Area:init( 50, 127,  15,  5, "ー",    COLOR_YELLOW),   Area:init( 50, 127,  15,  5, "ー",    COLOR_YELLOW),   Area:init( 28, 127,  21,  5, "ー",    COLOR_YELLOW)   }, -- ー */
	{ Area:init( 19,  95,   7,  5, "RESET", COLOR_WHITE),    Area:init( 19,  95,   7,  5, "RESET", COLOR_WHITE),    Area:init( 14, 127,  12,  5, "RESET", COLOR_WHITE)    }, -- RESET */
	{ nil,                                                 nil,                                                 null                                                 }, --  */
	{ nil,                                                 nil,                                                 null                                                 }, --  */
	{ nil,                                                 nil,                                                 null                                                 }, --  */
	{ nil,                                                 nil,                                                 null                                                 }, --  */
	{ Area:init( -4,   0, 328,148),                          Area:init( -4,   0, 328,148),                          Area:init(  0,   0, 320,148)                          }   -- 本体 */
}


---[===[

--  按键布局 BREAK按键 static public final int 
G8xx.LAYOUT_KEY_BREAK = 0;
-- 按键布局 OFF按键 static public final int 
G8xx.LAYOUT_KEY_OFF = 1;
-- 按键布局 ANS按键 static public final int 
G8xx.LAYOUT_KEY_ANS = 2;
-- 按键布局 CONST按键 static public final int 
G8xx.LAYOUT_KEY_CONST = 3;
-- 按键布局 TEXT按键 static public final int 
G8xx.LAYOUT_KEY_TEXT = 4;
-- 按键布局 BASIC按键 static public final int 
G8xx.LAYOUT_KEY_BASIC = 5;
-- 按键布局 CLS按键 static public final int 
G8xx.LAYOUT_KEY_CLS = 6;
-- 按键布局 F←→E按键 	static public final int 
G8xx.LAYOUT_KEY_FE = 7;
-- 按键布局 tan按键 	static public final int 
G8xx.LAYOUT_KEY_TAN = 8;
-- 按键布局 cos按键 	static public final int 
G8xx.LAYOUT_KEY_COS = 9;
-- 按键布局 sin按键 	static public final int 
G8xx.LAYOUT_KEY_SIN = 10;
-- 按键布局 2ndF按键 	static public final int 
G8xx.LAYOUT_KEY_2NDF = 11;
-- 按键布局 MDF按键 	static public final int 
G8xx.LAYOUT_KEY_MDF = 12;
-- 按键布局 1/x按键 	static public final int 
G8xx.LAYOUT_KEY_RCP = 13;

-- 按键布局 log按键 	static public final int 
G8xx.LAYOUT_KEY_LOG = 14;

-- 按键布局 ln按键 	static public final int 
G8xx.LAYOUT_KEY_LN = 15;

-- 按键布局 →DEG按键 	static public final int 
G8xx.LAYOUT_KEY_DEG = 16;

-- 按键布局 nPr按键 	static public final int 
G8xx.LAYOUT_KEY_NPR = 17;

-- 按键布局 )按键 	static public final int 
G8xx.LAYOUT_KEY_RKAKKO = 18;

-- 按键布局 (按键 	static public final int 
G8xx.LAYOUT_KEY_LKAKKO = 19;

-- 按键布局 ^按键 	static public final int 
G8xx.LAYOUT_KEY_HAT = 20;

-- 按键布局 x^2按键 	static public final int 
G8xx.LAYOUT_KEY_SQU = 21;

-- 按键布局 √按键 	static public final int 
G8xx.LAYOUT_KEY_SQR = 22;

-- 按键布局 π按键 	static public final int 
G8xx.LAYOUT_KEY_PI = 23;

-- 按键布局 R・CM按键 	static public final int 
G8xx.LAYOUT_KEY_RCM = 24;

-- 按键布局 /按键 	static public final int 
G8xx.LAYOUT_KEY_SLASH = 25;

-- 按键布局 9按键 	static public final int 
G8xx.LAYOUT_KEY_9 = 26;

-- 按键布局 8按键 	static public final int 
G8xx.LAYOUT_KEY_8 = 27;

-- 按键布局 7按键 	static public final int 
G8xx.LAYOUT_KEY_7 = 28;

-- 按键布局 M+按键 	static public final int 
G8xx.LAYOUT_KEY_MPLUS = 29;

-- 按键布局 *按键 	static public final int 
G8xx.LAYOUT_KEY_ASTER = 30;

-- 按键布局 6按键 	static public final int 
G8xx.LAYOUT_KEY_6 = 31;

-- 按键布局 5按键 	static public final int 
G8xx.LAYOUT_KEY_5 = 32;

-- 按键布局 4按键 	static public final int 
G8xx.LAYOUT_KEY_4 = 33;

-- 按键布局 RETURN按键(テン按键側) 	static public final int 
G8xx.LAYOUT_KEY_RETURN2 = 34;

-- 按键布局 -按键 	static public final int 
G8xx.LAYOUT_KEY_MINUS = 35;

-- 按键布局 3按键 	static public final int 
G8xx.LAYOUT_KEY_3 = 36;

-- 按键布局 2按键 	static public final int 
G8xx.LAYOUT_KEY_2 = 37;

-- 按键布局 1按键 	static public final int 
G8xx.LAYOUT_KEY_1 = 38;

-- 按键布局 +按键 	static public final int 
G8xx.LAYOUT_KEY_PLUS = 39;

-- 按键布局 =按键 	static public final int 
G8xx.LAYOUT_KEY_EQUAL = 40;

-- 按键布局 .按键 	static public final int 
G8xx.LAYOUT_KEY_PERIOD = 41;

-- 按键布局 0按键 	static public final int 
G8xx.LAYOUT_KEY_0 = 42;

-- 按键布局 BS 	static public final int 
G8xx.LAYOUT_KEY_BACKSPACE = 43;

-- 按键布局 P按键 	static public final int 
G8xx.LAYOUT_KEY_P = 44;

-- 按键布局 O按键 	static public final int 
G8xx.LAYOUT_KEY_O = 45;

-- 按键布局 I按键 	static public final int 
G8xx.LAYOUT_KEY_I = 46;

-- 按键布局 U按键 	static public final int 
G8xx.LAYOUT_KEY_U = 47;

-- 按键布局 Y按键 	static public final int 
G8xx.LAYOUT_KEY_Y = 48;

-- 按键布局 T按键 	static public final int 
G8xx.LAYOUT_KEY_T = 49;

-- 按键布局 R按键 	static public final int 
G8xx.LAYOUT_KEY_R = 50;

-- 按键布局 E按键 	static public final int 
G8xx.LAYOUT_KEY_E = 51;

-- 按键布局 W按键 	static public final int 
G8xx.LAYOUT_KEY_W = 52;

-- 按键布局 Q按键 	static public final int 
G8xx.LAYOUT_KEY_Q = 53;

-- 按键布局 TAB按键 	static public final int 
G8xx.LAYOUT_KEY_TAB = 54;

-- 按键布局 RETURN按键 	static public final int 
G8xx.LAYOUT_KEY_RETURN = 55;

-- 按键布局 ;按键 	static public final int 
G8xx.LAYOUT_KEY_SEMICOLON = 56;

-- 按键布局 L按键 	static public final int 
G8xx.LAYOUT_KEY_L = 57;

-- 按键布局 K按键 	static public final int 
G8xx.LAYOUT_KEY_K = 58;

-- 按键布局 J按键 	static public final int 
G8xx.LAYOUT_KEY_J = 59;

-- 按键布局 H按键 	static public final int 
G8xx.LAYOUT_KEY_H = 60;

-- 按键布局 G按键 	static public final int 
G8xx.LAYOUT_KEY_G = 61;

-- 按键布局 F按键 	static public final int 
G8xx.LAYOUT_KEY_F = 62;

-- 按键布局 D按键 	static public final int 
G8xx.LAYOUT_KEY_D = 63;

-- 按键布局 S按键 	static public final int 
G8xx.LAYOUT_KEY_S = 64;

-- 按键布局 A按键 	static public final int 
G8xx.LAYOUT_KEY_A = 65;

-- 按键布局 CAPS按键 	static public final int 
G8xx.LAYOUT_KEY_CAPS = 66;

-- 按键布局 ↑按键 	static public final int 
G8xx.LAYOUT_KEY_UP = 67;

-- 按键布局 ,按键 	static public final int 
G8xx.LAYOUT_KEY_COMMA = 68;

-- 按键布局 M按键 	static public final int 
G8xx.LAYOUT_KEY_M = 69;

-- 按键布局 N按键 	static public final int 
G8xx.LAYOUT_KEY_N = 70;

-- 按键布局 B按键 	static public final int 
G8xx.LAYOUT_KEY_B = 71;

-- 按键布局 V按键 	static public final int 
G8xx.LAYOUT_KEY_V = 72;

-- 按键布局 C按键 	static public final int 
G8xx.LAYOUT_KEY_C = 73;

-- 按键布局 X按键 	static public final int 
G8xx.LAYOUT_KEY_X = 74;

-- 按键布局 Z按键 	static public final int 
G8xx.LAYOUT_KEY_Z = 75;

-- 按键布局 SHIFT按键 	static public final int 
G8xx.LAYOUT_KEY_SHIFT = 76;

-- 按键布局 →按键 	static public final int 
G8xx.LAYOUT_KEY_RIGHT = 77;

-- 按键布局 ↓按键 	static public final int 
G8xx.LAYOUT_KEY_DOWN = 78;

-- 按键布局 ←按键 	static public final int 
G8xx.LAYOUT_KEY_LEFT = 79;

-- 按键布局 INS按键 	static public final int 
G8xx.LAYOUT_KEY_INSERT = 80;

-- 按键布局 SPACE按键 	static public final int 
G8xx.LAYOUT_KEY_SPACE = 81;

-- 按键布局 カナ按键 	static public final int 
G8xx.LAYOUT_KEY_KANA = 82;

-- 按键布局 RESETボタン 	static public final int 
G8xx.LAYOUT_KEY_RESET = 83;

-- 按键布局 按键の最後のレイアウト番号 	static public final int 
G8xx.LAYOUT_KEY_LAST = 83;

-- 按键布局 LCDドットマトリクス部 	static public final int 
G8xx.LAYOUT_LCD_MATRIX = 84;

-- 按键布局 LCDステータス部の最初のレイアウト番号 	static public final int 
G8xx.LAYOUT_LCD_STATUS_FIRST = 85;

-- 按键布局 LCDステータス部の最後のレイアウト番号 	static public final int 
G8xx.LAYOUT_LCD_STATUS_LAST = 148;

-- 按键布局 LCD全体 	static public final int 
G8xx.LAYOUT_LCD = 149;

-- 按键布局 LCD画面枠 	static public final int 
G8xx.LAYOUT_FRAME = 150;

-- 按键布局 0列目 	static public final int 
G8xx.LAYOUT_LABEL_COL0 = 151;

-- 按键布局 1列目 	static public final int 
G8xx.LAYOUT_LABEL_COL1 = 152;

-- 按键布局 2列目 	static public final int 
G8xx.LAYOUT_LABEL_COL2 = 153;

-- 按键布局 3列目 	static public final int 
G8xx.LAYOUT_LABEL_COL3 = 154;

-- 按键布局 4列目 	static public final int 
G8xx.LAYOUT_LABEL_COL4 = 155;

-- 按键布局 5列目 	static public final int 
G8xx.LAYOUT_LABEL_COL5 = 156;

-- 按键布局 6列目 	static public final int 
G8xx.LAYOUT_LABEL_COL6 = 157;

-- 按键布局 7列目 	static public final int 
G8xx.LAYOUT_LABEL_COL7 = 158;

-- 按键布局 8列目 	static public final int 
G8xx.LAYOUT_LABEL_COL8 = 159;

-- 按键布局 9列目 	static public final int 
G8xx.LAYOUT_LABEL_COL9 = 160;

-- 按键布局 10列目 	static public final int 
G8xx.LAYOUT_LABEL_COL10 = 161;

-- 按键布局 11列目 	static public final int 
G8xx.LAYOUT_LABEL_COL11 = 162;

-- 按键布局 12列目 	static public final int 
G8xx.LAYOUT_LABEL_COL12 = 163;

-- 按键布局 13列目 	static public final int 
G8xx.LAYOUT_LABEL_COL13 = 164;

-- 按键布局 14列目 	static public final int 
G8xx.LAYOUT_LABEL_COL14 = 165;

-- 按键布局 15列目 	static public final int 
G8xx.LAYOUT_LABEL_COL15 = 166;

-- 按键布局 16列目 	static public final int 
G8xx.LAYOUT_LABEL_COL16 = 167;

-- 按键布局 17列目 	static public final int 
G8xx.LAYOUT_LABEL_COL17 = 168;

-- 按键布局 18列目 	static public final int 
G8xx.LAYOUT_LABEL_COL18 = 169;

-- 按键布局 19列目 	static public final int 
G8xx.LAYOUT_LABEL_COL19 = 170;

-- 按键布局 20列目 	static public final int 
G8xx.LAYOUT_LABEL_COL20 = 171;

-- 按键布局 21列目 	static public final int 
G8xx.LAYOUT_LABEL_COL21 = 172;

-- 按键布局 22列目 	static public final int 
G8xx.LAYOUT_LABEL_COL22 = 173;

-- 按键布局 23列目 	static public final int 
G8xx.LAYOUT_LABEL_COL23 = 174;

-- 按键布局 0列目(下) 	static public final int 
G8xx.LAYOUT_LABEL_BOTTOM_COL0 = 175;

-- 按键布局 5列目(下) 	static public final int 
G8xx.LAYOUT_LABEL_BOTTOM_COL5 = 176;

-- 按键布局 10列目(下) 	static public final int 
G8xx.LAYOUT_LABEL_BOTTOM_COL10 = 177;

-- 按键布局 15列目(下) 	static public final int 
G8xx.LAYOUT_LABEL_BOTTOM_COL15 = 178;

-- 按键布局 20列目(下) 	static public final int 
G8xx.LAYOUT_LABEL_BOTTOM_COL20 = 179;

-- 按键布局 0行目(右) 	static public final int 
G8xx.LAYOUT_LABEL_RROW0 = 180;

-- 按键布局 1行目(右) 	static public final int 
G8xx.LAYOUT_LABEL_RROW1 = 181;

-- 按键布局 2行目(右) 	static public final int 
G8xx.LAYOUT_LABEL_RROW2 = 182;

-- 按键布局 3行目(右) 	static public final int 
G8xx.LAYOUT_LABEL_RROW3 = 183;

-- 按键布局 4行目(右) 	static public final int 
G8xx.LAYOUT_LABEL_RROW4 = 184;

-- 按键布局 5行目(右) 	static public final int 
G8xx.LAYOUT_LABEL_RROW5 = 185;

-- 按键布局 0行目(左) 	static public final int 
G8xx.LAYOUT_LABEL_LROW0 = 186;

-- 按键布局 1行目(左) 	static public final int 
G8xx.LAYOUT_LABEL_LROW1 = 187;

-- 按键布局 2行目(左) 	static public final int 
G8xx.LAYOUT_LABEL_LROW2 = 188;

-- 按键布局 3行目(左) 	static public final int 
G8xx.LAYOUT_LABEL_LROW3 = 189;

-- 按键布局 4行目(左) 	static public final int 
G8xx.LAYOUT_LABEL_LROW4 = 190;

-- 按键布局 5行目(左) 	static public final int 
G8xx.LAYOUT_LABEL_LROW5 = 191;

-- 按键布局 右カギカッコ 	static public final int 
G8xx.LAYOUT_LABEL_RKAGIKAKKO = 192;

-- 按键布局 左カギカッコ 	static public final int 
G8xx.LAYOUT_LABEL_LKAGIKAKKO = 193;

-- 按键布局 中点 	static public final int 
G8xx.LAYOUT_LABEL_NAKATEN = 194;

-- 按键布局 句点 	static public final int 
G8xx.LAYOUT_LABEL_KUTEN = 195;

-- 按键布局 読点 	static public final int 
G8xx.LAYOUT_LABEL_TOUTEN = 196;

-- 按键布局 BREAK 	static public final int 
G8xx.LAYOUT_LABEL_BREAK = 197;

-- 按键布局 コントラスト 	static public final int 
G8xx.LAYOUT_LABEL_CONTRAST = 198;

-- 按键布局 C 	static public final int 
G8xx.LAYOUT_LABEL_C = 199;

-- 按键布局 ASMBL 	static public final int 
G8xx.LAYOUT_LABEL_ASMBL = 200;

-- 按键布局 CA 	static public final int 
G8xx.LAYOUT_LABEL_CA = 201;

-- 按键布局 DIGIT 	static public final int 
G8xx.LAYOUT_LABEL_DIGIT = 202;

-- 按键布局 atan 	static public final int 
G8xx.LAYOUT_LABEL_ATAN = 203;

-- 按键布局 acos 	static public final int 
G8xx.LAYOUT_LABEL_ACOS = 204;

-- 按键布局 asin 	static public final int 
G8xx.LAYOUT_LABEL_ASIN = 205;

-- 按键布局 STAT 	static public final int 
G8xx.LAYOUT_LABEL_STAT = 206;

-- 按键布局 n! 	static public final int 
G8xx.LAYOUT_LABEL_FACT = 207;

-- 按键布局 10^x 	static public final int 
G8xx.LAYOUT_LABEL_TEN = 208;

-- 按键布局 e^x 	static public final int 
G8xx.LAYOUT_LABEL_EXP = 209;

-- 按键布局 →DMS 	static public final int 
G8xx.LAYOUT_LABEL_DMS = 210;

-- 按键布局 nCr 	static public final int 
G8xx.LAYOUT_LABEL_NCR = 211;

-- 按键布局 BASE-n 	static public final int 
G8xx.LAYOUT_LABEL_BASEN = 212;

-- 按键布局 →xy 	static public final int 
G8xx.LAYOUT_LABEL_XY = 213;

-- 按键布局 →rθ 	static public final int 
G8xx.LAYOUT_LABEL_POL = 214;

-- 按键布局 x^3 	static public final int 
G8xx.LAYOUT_LABEL_CUB = 215;

-- 按键布局 3√ 	static public final int 
G8xx.LAYOUT_LABEL_CUR = 216;

-- 按键布局 RND 	static public final int 
G8xx.LAYOUT_LABEL_RND = 217;

-- 按键布局 ″ 	static public final int 
G8xx.LAYOUT_LABEL_SECOND = 218;

-- 按键布局 ′ 	static public final int 
G8xx.LAYOUT_LABEL_MINUTE = 219;

-- 按键布局 ° 	static public final int 
G8xx.LAYOUT_LABEL_DEGREE = 220;

-- 按键布局 M- 	static public final int 
G8xx.LAYOUT_LABEL_MMINUS = 221;

-- 按键布局 P-NP 	static public final int 
G8xx.LAYOUT_LABEL_PNP2 = 222;

-- 按键布局 (-) 	static public final int 
G8xx.LAYOUT_LABEL_NEG = 223;

-- 按键布局 Exp 	static public final int 
G8xx.LAYOUT_LABEL_E = 224;

-- 按键布局 DRG 	static public final int 
G8xx.LAYOUT_LABEL_DRG = 225;

-- 按键布局 @ 	static public final int 
G8xx.LAYOUT_LABEL_AT = 226;

-- 按键布局 > 	static public final int 
G8xx.LAYOUT_LABEL_GREATER = 227;

-- 按键布局 < 	static public final int 
G8xx.LAYOUT_LABEL_LESS = 228;

-- 按键布局 ' 	static public final int 
G8xx.LAYOUT_LABEL_APOSTROPHE = 229;

-- 按键布局 & 	static public final int 
G8xx.LAYOUT_LABEL_AMPERSAND = 230;

-- 按键布局 % 	static public final int 
G8xx.LAYOUT_LABEL_PERCENT = 231;

-- 按键布局 $ 	static public final int 
G8xx.LAYOUT_LABEL_DOLLAR = 232;

-- 按键布局 # 	static public final int 
G8xx.LAYOUT_LABEL_HASH = 233;

-- 按键布局 " 	static public final int 
G8xx.LAYOUT_LABEL_DQUARTATION = 234;

-- 按键布局 ! 	static public final int 
G8xx.LAYOUT_LABEL_EXCLAMATION = 235;

-- 按键布局 P-NP(アルファベット按键側) 	static public final int 
G8xx.LAYOUT_LABEL_PNP = 236;

-- 按键布局 : 	static public final int 
G8xx.LAYOUT_LABEL_COLON = 237;

-- 按键布局 = 	static public final int 
G8xx.LAYOUT_LABEL_EQUAL = 238;

-- 按键布局 _ 	static public final int 
G8xx.LAYOUT_LABEL_UNDERBAR = 239;

-- 按键布局 	static public final int 
G8xx.LAYOUT_LABEL_TILDE = 240;

-- 按键布局 | 	static public final int 
G8xx.LAYOUT_LABEL_PIPE = 241;

-- 按键布局 \ 	static public final int 
G8xx.LAYOUT_LABEL_YEN = 242;

-- 按键布局 } 	static public final int 
G8xx.LAYOUT_LABEL_RBRACE = 243;

-- 按键布局 { 	static public final int 
G8xx.LAYOUT_LABEL_LBRACE = 244;

-- 按键布局 ] 	static public final int 
G8xx.LAYOUT_LABEL_RBRACKET = 245;

-- 按键布局 [ 	static public final int 
G8xx.LAYOUT_LABEL_LBRACKET = 246;

-- 按键布局 小文字 	static public final int 
G8xx.LAYOUT_LABEL_KOMOZI = 247;

-- 按键布局 ? 	static public final int 
G8xx.LAYOUT_LABEL_QUESTION = 248;

-- 按键布局 LOAD 	static public final int 
G8xx.LAYOUT_LABEL_LOAD = 249;

-- 按键布局 SAVE 	static public final int 
G8xx.LAYOUT_LABEL_SAVE = 250;

-- 按键布局 LIST 	static public final int 
G8xx.LAYOUT_LABEL_LIST = 251;

-- 按键布局 RUN 	static public final int 
G8xx.LAYOUT_LABEL_RUN = 252;

-- 按键布局 CONT 	static public final int 
G8xx.LAYOUT_LABEL_CONT = 253;

-- 按键布局 PRINT 	static public final int 
G8xx.LAYOUT_LABEL_PRINT = 254;

-- 按键布局 INPUT 	static public final int 
G8xx.LAYOUT_LABEL_INPUT = 255;

-- 按键布局 DEL 	static public final int 
G8xx.LAYOUT_LABEL_DELETE = 256;

-- 按键布局 ー 	static public final int 
G8xx.LAYOUT_LABEL_CHOON = 257;

-- 按键布局 RESET 	static public final int 
G8xx.LAYOUT_LABEL_RESET = 258;

-- 按键布局 GRAPHIC 	static public final int 
G8xx.LAYOUT_LABEL_LOGO1 = 259;

-- 按键布局 C-LANGUAGE 	static public final int 
G8xx.LAYOUT_LABEL_LOGO2 = 260;

-- 按键布局 POCKET COMPUTER PC-G850/S/V/VS 	static public final int 
G8xx.LAYOUT_LABEL_LOGO3 = 261;

-- 按键布局 SHARP 	static public final int 
G8xx.LAYOUT_LABEL_LOGO4 = 262;

-- 按键布局 本体 	static public final int 
G8xx.LAYOUT_BODY = 263;

-- 按键布局 最後の番号 	static public final int 
G8xx.LAYOUT_LAST = 263;

-- 色: 黒 	static public final int 
G8xx.COLOR_BLACK = 0;

-- 色: 暗い灰色 	static public final int 
G8xx.COLOR_DARKGRAY = 1;

-- 色: 灰色 	static public final int 
G8xx.COLOR_GRAY = 2;

-- 色: 明るい灰色 	static public final int 
G8xx.COLOR_LIGHTGRAY = 3;

-- 色: 白 	static public final int 
G8xx.COLOR_WHITE = 4;

-- 色: 赤 	static public final int 
G8xx.COLOR_RED = 5;

-- 色: 明るい赤 	static public final int 
G8xx.COLOR_LIGHTRED = 6;

-- 色: 緑 	static public final int 
G8xx.COLOR_GREEN = 7;

-- 色: 明るい緑 	static public final int 
G8xx.COLOR_LIGHTGREEN = 8;

-- 色: 黄 	static public final int 
G8xx.COLOR_YELLOW = 9;

-- 色: 明るい黄 	static public final int 
G8xx.COLOR_LIGHTYELLOW = 10;

-- 色: 青 	static public final int 
G8xx.COLOR_BLUE = 11;

-- 動作モード: エミュレート 	static public final int 
G8xx.MODE_EMULATOR = 0;
-- 動作モード: メニュー 	static public final int 
G8xx.MODE_MENU = 1;
-- エミュレートの対象: PC-G801/PC-G802/PC-G803/PC-G805/PC-G811/PC-G813/PC-G820/PC-G830/PC-E200/PC-E220 	static public final int 
G8xx.MACHINE_E200 = 0;
local MACHINE_E200 = G8xx.MACHINE_E200
-- エミュレートの対象: PC-G815 	static public final int 
G8xx.MACHINE_G815 = 1;
local MACHINE_G815 = G8xx.MACHINE_G815
-- エミュレートの対象: PC-G850/PC-G850S/PC-G850V/PC-G850VS 	static public final int 
G8xx.MACHINE_G850 = 2;
local MACHINE_G850 = G8xx.MACHINE_G850

-- 1文字横ドット数 (PC-E200) 	static private final int 
G8xx.E200_CELL_WIDTH = 5;

-- 1文字縦ドット数 (PC-E200) 	static private final int 
G8xx.E200_CELL_HEIGHT = 7;

-- 表示横文字数 (PC-E200) 	static private final int 
G8xx.E200_LCD_COLS = 24;

-- 表示縦文字数 (PC-E200) 	static private final int 
G8xx.E200_LCD_ROWS = 4;

-- VRAM横文字数 (PC-E200) 	static private final int 
G8xx.E200_VRAM_COLS = 24;

-- VRAM縦文字数 (PC-E200) 	static private final int 
G8xx.E200_VRAM_ROWS = 4;

-- VRAM横ドット数 (PC-E200) 	static private final int 
G8xx.E200_VRAM_WIDTH = G8xx.E200_VRAM_COLS * G8xx.E200_CELL_WIDTH + 1;

-- VRAM縦ドット数 (PC-E200) 	static private final int 
G8xx.E200_VRAM_HEIGHT = G8xx.E200_VRAM_ROWS * 8;

-- 1文字横ドット数 (PC-G815) 	static private final int 
G8xx.G815_CELL_WIDTH = 6;

-- 1文字縦ドット数 (PC-G815) 	static private final int 
G8xx.G815_CELL_HEIGHT = 8;

-- 表示横文字数 (PC-G815) 	static private final int 
G8xx.G815_LCD_COLS = 24;

-- 表示縦文字数 (PC-G815) 	static private final int 
G8xx.G815_LCD_ROWS = 4;

-- VRAM横文字数 (PC-G815) 	static private final int 
G8xx.G815_VRAM_COLS = 24;

-- VRAM縦文字数 (PC-G815) 	static private final int 
G8xx.G815_VRAM_ROWS = 4;

-- VRAM横ドット数 (PC-G815) 	static private final int 
G8xx.G815_VRAM_WIDTH = G8xx.G815_VRAM_COLS * G8xx.G815_CELL_WIDTH + 1;

-- VRAM縦ドット数 (PC-G815) 	static private final int 
G8xx.G815_VRAM_HEIGHT = G8xx.G815_VRAM_ROWS * 8;

-- 1文字横ドット数 (PC-G850) 	static private final int 
G8xx.G850_CELL_WIDTH = 6;

-- 1文字縦ドット数 (PC-G850) 	static private final int 
G8xx.G850_CELL_HEIGHT = 8;

-- 画面横文字数 (PC-G850) 	static private final int 
G8xx.G850_LCD_COLS = 24;

-- 画面縦文字数 (PC-G850) 	static private final int 
G8xx.G850_LCD_ROWS = 6;

-- VRAM横文字数 (PC-G850) 	static private final int 
G8xx.G850_VRAM_COLS = 24;

-- VRAM縦文字数 (PC-G850) 	static private final int 
G8xx.G850_VRAM_ROWS = 8;

-- VRAM横ドット数 (PC-G850) 	static private final int 
G8xx.G850_VRAM_WIDTH = G8xx.G850_VRAM_COLS * G8xx.G850_CELL_WIDTH + 1;

-- VRAM縦ドット数 (PC-G850) 	static private final int 
G8xx.G850_VRAM_HEIGHT = G8xx.G850_VRAM_ROWS * 8;

-- SIOモード: 入出力なし 	static public final int 
G8xx.SIO_MODE_STOP = 0;
local SIO_MODE_STOP = G8xx.SIO_MODE_STOP 
-- SIOモード: 入力 	static public final int 
G8xx.SIO_MODE_IN = 1;
local SIO_MODE_IN = G8xx.SIO_MODE_IN
-- SIOモード: 出力 	static public final int 
G8xx.SIO_MODE_OUT = 2;
local SIO_MODE_OUT = G8xx.SIO_MODE_OUT 

-- 按键割り込み 	static private final int
local INTERRUPT_IA = 0x01;

-- 按键割り込み 	static private final int
local INTERRUPT_KON = 0x02;

-- タイマ割り込み 	static private final int
local INTERRUPT_1S = 0x04;

-- 11ピン割り込み 	static private final int 
local INTERRUPT_INT1 = 0x08;


-- 按键コード: なし 	static public final int 
G8xx.GKEY_NONE = 0x00;
-- 按键コード: OFF按键 	static public final int 
G8xx.GKEY_OFF = 0x01;

-- 按键コード: Q按键 	static public final int 
G8xx.GKEY_Q = 0x02;

-- 按键コード: W按键 	static public final int 
G8xx.GKEY_W = 0x03;

-- 按键コード: E按键 	static public final int 
G8xx.GKEY_E = 0x04;

-- 按键コード: R按键 	static public final int 
G8xx.GKEY_R = 0x05;

-- 按键コード: T按键 	static public final int 
G8xx.GKEY_T = 0x06;

-- 按键コード: Y按键 	static public final int 
G8xx.GKEY_Y = 0x07;

-- 按键コード: U按键 	static public final int 
G8xx.GKEY_U = 0x08;

-- 按键コード: A按键 	static public final int 
G8xx.GKEY_A = 0x09;

-- 按键コード: S按键 	static public final int 
G8xx.GKEY_S = 0x0a;

-- 按键コード: D按键 	static public final int 
G8xx.GKEY_D = 0x0b;

-- 按键コード: F按键 	static public final int 
G8xx.GKEY_F = 0x0c;

-- 按键コード: G按键 	static public final int 
G8xx.GKEY_G = 0x0d;

-- 按键コード: H按键 	static public final int 
G8xx.GKEY_H = 0x0e;

-- 按键コード: J按键 	static public final int 
G8xx.GKEY_J = 0x0f;

-- 按键コード: K按键 	static public final int 
G8xx.GKEY_K = 0x10;

-- 按键コード: Z按键 	static public final int 
G8xx.GKEY_Z = 0x11;

-- 按键コード: X按键 	static public final int 
G8xx.GKEY_X = 0x12;

-- 按键コード: C按键 	static public final int 
G8xx.GKEY_C = 0x13;

-- 按键コード: V按键 	static public final int 
G8xx.GKEY_V = 0x14;

-- 按键コード: B按键 	static public final int 
G8xx.GKEY_B = 0x15;

-- 按键コード: N按键 	static public final int 
G8xx.GKEY_N = 0x16;

-- 按键コード: M按键 	static public final int 
G8xx.GKEY_M = 0x17;

-- 按键コード: ,按键 	static public final int 
G8xx.GKEY_COMMA = 0x18;

-- 按键コード: BASIC按键 	static public final int 
G8xx.GKEY_BASIC = 0x19;

-- 按键コード: TEXT按键 	static public final int 
G8xx.GKEY_TEXT = 0x1a;

-- 按键コード: CAPS按键 	static public final int 
G8xx.GKEY_CAPS = 0x1b;

-- 按键コード: カナ按键 	static public final int 
G8xx.GKEY_KANA = 0x1c;

-- 按键コード: TAB按键 	static public final int 
G8xx.GKEY_TAB = 0x1d;

-- 按键コード: SPACE按键 	static public final int 
G8xx.GKEY_SPACE = 0x1e;

-- 按键コード: ↓按键 	static public final int 
G8xx.GKEY_DOWN = 0x1f;

-- 按键コード: ↑按键 	static public final int 
G8xx.GKEY_UP = 0x20;

-- 按键コード: ←按键 	static public final int 
G8xx.GKEY_LEFT = 0x21;

-- 按键コード: →按键 	static public final int 
G8xx.GKEY_RIGHT = 0x22;

-- 按键コード: ANS按键 	static public final int 
G8xx.GKEY_ANS = 0x23;

-- 按键コード: 0按键 	static public final int 
G8xx.GKEY_0 = 0x24;

-- 按键コード: .按键 	static public final int 
G8xx.GKEY_PERIOD = 0x25;

-- 按键コード: =按键 	static public final int 
G8xx.GKEY_EQUAL = 0x26;

-- 按键コード: +按键 	static public final int 
G8xx.GKEY_PLUS = 0x27;

-- 按键コード: RETURN按键 	static public final int 
G8xx.GKEY_RETURN = 0x28;

-- 按键コード: L按键 	static public final int 
G8xx.GKEY_L = 0x29;

-- 按键コード: ;按键 	static public final int 
G8xx.GKEY_SEMICOLON = 0x2a;

-- 按键コード: CONST按键 	static public final int 
G8xx.GKEY_CONST = 0x2b;

-- 按键コード: 1按键 	static public final int 
G8xx.GKEY_1 = 0x2c;

-- 按键コード: 2按键 	static public final int 
G8xx.GKEY_2 = 0x2d;

-- 按键コード: 3按键 	static public final int 
G8xx.GKEY_3 = 0x2e;

-- 按键コード: -按键 	static public final int 
G8xx.GKEY_MINUS = 0x2f;

-- 按键コード: M+按键 	static public final int 
G8xx.GKEY_MPLUS = 0x30;

-- 按键コード: I按键 	static public final int 
G8xx.GKEY_I = 0x31;

-- 按键コード: O按键 	static public final int 
G8xx.GKEY_O = 0x32;

-- 按键コード: INS按键 	static public final int 
G8xx.GKEY_INSERT = 0x33;

-- 按键コード: 4按键 	static public final int 
G8xx.GKEY_4 = 0x34;

-- 按键コード: 5按键 	static public final int 
G8xx.GKEY_5 = 0x35;

-- 按键コード: 6按键 	static public final int 
G8xx.GKEY_6 = 0x36;

-- 按键コード: *按键 	static public final int 
G8xx.GKEY_ASTER = 0x37;

-- 按键コード: R・CM按键 	static public final int 
G8xx.GKEY_RCM = 0x38;

-- 按键コード: P按键 	static public final int 
G8xx.GKEY_P = 0x39;

-- 按键コード: BS按键 	static public final int 
G8xx.GKEY_BACKSPACE = 0x3a;

-- 按键コード: π按键 	static public final int 
G8xx.GKEY_PI = 0x3b;

-- 按键コード: 7按键 	static public final int 
G8xx.GKEY_7 = 0x3c;

-- 按键コード: 8按键 	static public final int 
G8xx.GKEY_8 = 0x3d;

-- 按键コード: 9按键 	static public final int 
G8xx.GKEY_9 = 0x3e;

-- 按键コード: /按键 	static public final int 
G8xx.GKEY_SLASH = 0x3f;

-- 按键コード: )按键 	static public final int 
G8xx.GKEY_RKAKKO = 0x40;

-- 按键コード: nPr按键 	static public final int 
G8xx.GKEY_NPR = 0x41;

-- 按键コード: →DEG按键 	static public final int 
G8xx.GKEY_DEG = 0x42;

-- 按键コード: √按键 	static public final int 
G8xx.GKEY_SQR = 0x43;

-- 按键コード: x^2按键 	static public final int 
G8xx.GKEY_SQU = 0x44;

-- 按键コード: ^按键 	static public final int 
G8xx.GKEY_HAT = 0x45;

-- 按键コード: (按键 	static public final int 
G8xx.GKEY_LKAKKO = 0x46;

-- 按键コード: 1/x按键 	static public final int 
G8xx.GKEY_RCP = 0x47;

-- 按键コード: MDF按键 	static public final int 
G8xx.GKEY_MDF = 0x48;

-- 按键コード: 2ndF按键 	static public final int 
G8xx.GKEY_2NDF = 0x49;

-- 按键コード: sin按键 	static public final int 
G8xx.GKEY_SIN = 0x4a;

-- 按键コード: cos按键 	static public final int 
G8xx.GKEY_COS = 0x4b;

-- 按键コード: ln按键 	static public final int 
G8xx.GKEY_LN = 0x4c;

-- 按键コード: log按键 	static public final int 
G8xx.GKEY_LOG = 0x4d;

-- 按键コード: tan按键 	static public final int 
G8xx.GKEY_TAN = 0x4e;

-- 按键コード: F←→E按键 	static public final int 
G8xx.GKEY_FE = 0x4f;

-- 按键コード: CLS按键 	static public final int 
G8xx.GKEY_CLS = 0x50;

-- 按键コード: ON按键 	static public final int 
G8xx.GKEY_BREAK = 0x51;

-- 按键コード: 同時押し 	static public final int 
G8xx.GKEY_DOUBLE = 0x52;

-- 仮想按键コード: SHIFT按键 	static public final int 
G8xx.GKEY_SHIFT = 0x1000;

-- 仮想按键コード: RESET按键 	static public final int 
G8xx.GKEY_RESET = 0x2000;
-- 11ピン出力: Fo1 	static private final int 
G8xx.PIN11_OUT_FO1 = 0x01;

-- 11ピン出力: Fo2 	static private final int 
G8xx.PIN11_OUT_FO2 = 0x02;

-- 11ピン出力: BEEP 	static private final int 
G8xx.PIN11_OUT_BEEP = 0x40;

-- 11ピン出力: Xout 	static private final int 
G8xx.PIN11_OUT_XOUT = 0x80;

-- 11ピン入力: IB1 	static private final int 
G8xx.PIN11_IN_IB1 = 0x01;

-- 11ピン入力: IB2 	static private final int 
G8xx.PIN11_IN_IB2 = 0x02;

-- 11ピン入力: Xin 	static private final int 
G8xx.PIN11_IN_XIN = 0x04;

-- 最初の実行か? 	private boolean 
local first = true;

-- 動作モード 	private int 
local mode = 0;

-- エミュレートするマシン 	private int machine;

-- VRAM横ドット数 	private int vramWidth;

-- VRAM縦文字数 	private int vramRows;

-- VRAM横文字数 	private int vramCols;

-- 1文字横ドット数 	private int cellWidth;

-- 1文字縦ドット数 	private int cellHeight;

-- LCD横ドット数 	private int lcdWidth;

-- LCD縦ドット数 	private int lcdHeight;

-- LCD横文字数 	private int lcdCols;

-- LCD縦文字数 	private int lcdRows;

-- メモリ (0x0000~0xffff) 	private byte[] memory;
local memory = {}
-- RAMの初期値 (0x0000~0x003f) private byte[] base = new byte[] {i}
local base = {
		0xc3, 0xf4, 0xbf, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x03, 0xbd, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	};

-- ROM (0x8000~0xffff) private byte[][] rom;
local rom = {{}}

-- 現在のRAMページ番号 private int ramBank;
local ramBank

-- ROMの総ページ数 	private int romBanks;

-- 現在のROMページ番号 	private int romBank;

-- 現在のEXROMページ番号 	private int exBank;

-- 周辺機器用リセット信号 	private int ioReset;

-- 割り込み要因 	private int interruptType;

-- 割り込みマスク 	private int interruptMask;

-- タイマ 	private int timer;

-- タイマカウンタ 	private int timerCount;

-- タイマ周期 	private int timerInterval;

-- 按键ストローブ 	private int keyStrobe;

-- 最後に設定した按键ストローブ 	private int keyStrobeLast;

-- 按键状態 	private int[] keyMatrix;
local keyMatrix = {}

-- ON按键状態 	private int keyBreak;

-- シフト按键状態 	private int keyShift;

-- リセットボタン状態 	private boolean keyReset;

-- 按键割り込みを発生させるか? 	private boolean intIA;

-- 按键割り込みを発生させるか? 	private boolean intKON;

-- 按键ストローブを設定したときの累積ステート数 	private int keyStrobeLastStates;

-- 按键ストローブがクリアされるステート数 	private int keyStrobeClearStates;

-- LCD 横アドレス 	private int lcdX;

-- LCD 縦アドレス 	private int lcdY;

-- LCD 横アドレス2 (PC-G815) 	private int lcdX2;

-- 縦アドレス2 (PC-G815) 	private int lcdY2;

-- 表示開始アドレス(PC-E200/PC-G815) 	private int lcdBegin;

-- LCD OFF(PC-G850) 	private boolean lcdDisabled;

-- 表示開始位置(PC-G850) 	private int lcdTop;

-- コントラスト(PC-G850) 	private int lcdContrast;

-- ミラーモード(PC-G850) 	private boolean lcdEffectMirror;

-- 黒塗りつぶし(PC-G850) 	private boolean lcdEffectBlack;

-- 反転(PC-G850) 	private boolean lcdEffectReverse;

-- LCD電圧増加(PC-G850) 	private boolean lcdEffectDark;

-- 白塗りつぶし(PC-G850) 	private boolean lcdEffectWhite;

-- トリム(PC-G850) 	private int lcdTrim;

-- VRAM 	private byte[] vram;
local vram = {}

-- 作業領域 	private byte[] tmpVram;
local tmpVram = {}

-- レジスタ破壊用乱数 private int random 
local random  = 0xffffffff;

-- 文字表示列 	private int curCol;

-- 文字表示行 	private int curRow;

-- 押されている按键 	private int pressedKey;

-- LCDパターン 	private boolean[][][] lcdPattern;
local lcdPattern = {{{}}}

-- LCDが変化したか? 	private boolean[][] lcdChanged;
local lcdChanged = {{}}

-- LCDの点灯数 	private int[][] lcdCount;
local lcdCount = {{}}

-- LCD階調 	private int[][] lcdScale;
local lcdScale = {{}}

-- 前のフレームのLCD階調 	private int[][] lcdScalePrev;
local lcdScalePrev = {{}}

-- LCDページ数 	private int lcdPages;

-- SIO入出力モード 	private int sioMode = SIO_MODE_STOP;
local sioMode = SIO_MODE_STOP;
-- SIO入力ファイル名 	private String sioInPathname = "";
local sioInPathname = "";
-- SIO出力ファイル名 	private String sioOutPathname = "";
local sioOutPathname = "";
-- SIOバッファ 	private byte sioBuffer[];
local sioBuffer = {}
-- SIO入出力カウンタ 	private int sioCount;

-- SIOへの出力 	private int pin11Out;

-- SIOからの入力(仮想の通信相手の送信データ) 	private int pin11In;

-- CPUクロック周波数(Hz) 	private int cpuClocks;

-- I/O更新周期(Hz) 	private int fps;

-- LCD階調数 	private int lcdScales;

-- ブザー出力 	private byte[] wave0;
local wave0 = {}

-- ブザー出力 	private byte[] wave;
local wave = {}

-- レイアウトのX方向の倍率 private int zoomX = 1;
local zoomX = 1

-- レイアウトのY方向の倍率 private int zoomY = 1;
local zoomY = 1

-- レイアウトの原点のX座標 private int offsetX = 0;
local offsetX = 0

-- レイアウトの原点のY座標 private int offsetY = 0;
local offsetY = 0

-- コンストラクタ public G800Emulator(int m, int cpu_clocks, int freq, int lcd_scales)
function G8xx:G800Emulator(m, cpu_clocks, freq, lcd_scales)
	super();
	machine = m;
	keyMatrix = {} --new int[10];
	memory = {} --new byte[0x10000];
	rom = {{}}  --new byte[0x100][];
	vram = {} --new byte[166 * 9];
	tmpVram = {} --new byte[166 * 9];
	fps = freq;
	lcdPages = fps / 8;
	lcdScales = (lcd_scales >= 2 and {lcd_scales} or {lcdPages})[1];

	--switch(m) {
	if m == MACHINE_E200 then 
		-- case MACHINE_E200:
		vramWidth = E200_VRAM_WIDTH;
		vramCols = E200_VRAM_COLS;
		vramRows = E200_VRAM_ROWS;
		cellWidth = E200_CELL_WIDTH;
		cellHeight = E200_CELL_HEIGHT;
		lcdWidth = E200_LCD_COLS * E200_CELL_WIDTH;
		lcdHeight = E200_LCD_ROWS * E200_CELL_HEIGHT;
		lcdCols = E200_LCD_COLS;
		lcdRows = E200_LCD_ROWS;
		keyStrobeClearStates = 26;
		if(cpu_clocks > 0) then
			cpuClocks = cpu_clocks;
		else
			cpuClocks = 4000 * 1000;
		end
		--break;
	elseif m == MACHINE_G815 then
		--case MACHINE_G815:
		vramWidth = G815_VRAM_WIDTH;
		vramCols = G815_VRAM_COLS;
		vramRows = G815_VRAM_ROWS;
		cellWidth = G815_CELL_WIDTH;
		cellHeight = G815_CELL_HEIGHT;
		lcdWidth = G815_LCD_COLS * G815_CELL_WIDTH;
		lcdHeight = G815_LCD_ROWS * G815_CELL_HEIGHT;
		lcdCols = G815_LCD_COLS;
		lcdRows = G815_LCD_ROWS;
		keyStrobeClearStates = 26;
		if(cpu_clocks > 0) then
			cpuClocks = cpu_clocks;
		else
			cpuClocks = 4000 * 1000;
		end
		--break;
	elseif m == MACHINE_G850 then
		--case MACHINE_G850:
		vramWidth = G850_VRAM_WIDTH;
		vramCols = G850_VRAM_COLS;
		vramRows = G850_VRAM_ROWS;
		cellWidth = G850_CELL_WIDTH;
		cellHeight = G850_CELL_HEIGHT;
		lcdWidth = G850_LCD_COLS * G850_CELL_WIDTH;
		lcdHeight = G850_LCD_ROWS * G850_CELL_HEIGHT;
		lcdCols = G850_LCD_COLS;
		lcdRows = G850_LCD_ROWS;
		keyStrobeClearStates = 130;
		if (cpu_clocks > 0) then
			cpuClocks = cpu_clocks;
		else
			cpuClocks = 9000 * 1000;
		end
		base[0x0038] = 0xc3;
		base[0x0039] = 0x37;
		base[0x003a] = 0xbc;
		--break;
	end
	--}

	lcdPattern = {{{}}}  --new boolean[lcdPages][64][6 * lcdCols + 1];
	lcdChanged ={{}}   --new boolean[64][6 * lcdCols + 1];
	lcdCount = {{}}  --new int[64][6 * lcdCols + 1];
	lcdScale = {{}}  --new int[64][6 * lcdCols + 1];
	lcdScalePrev = {{}}  --new int[64][6 * lcdCols + 1];

	wave0 = {}  --new byte[(44100 + fps / 2) / fps];
	wave = {}  --new byte[wave0.length];
end

--输出日志 (覆盖)
--@Override public void log(String message)
function log(message)

end

--メモリを読み込む (オーバーライド)
--@Override public byte read(int address)
function read(adress)	return memory[address];	end

--メモリに書き込む (オーバーライド)
--@Override public void write(int address, byte value)
function write(adress, value)
	if(address < 0x8000) then
		memory[address] = value;
	end
end

--按键の状態 (inportの下請け)
--private int in10()
local function int10()
	--int key;

	if(keyStrobeLastStates - restStates > keyStrobeClearStates) then
		keyStrobe = keyStrobeLast;
	end

	key =
	((keyStrobe & 0x001) ~= 0 and {keyMatrix[0]} or { 0})[1] |
	((keyStrobe & 0x002) ~= 0 and {keyMatrix[1]} or { 0})[1] |
	((keyStrobe & 0x004) ~= 0 and {keyMatrix[2]} or { 0})[1] |
	((keyStrobe & 0x008) ~= 0 and {keyMatrix[3]} or { 0})[1] |
	((keyStrobe & 0x010) ~= 0 and {keyMatrix[4]} or { 0})[1] |
	((keyStrobe & 0x020) ~= 0 and {keyMatrix[5]} or { 0})[1] |
	((keyStrobe & 0x040) ~= 0 and {keyMatrix[6]} or { 0})[1] |
	((keyStrobe & 0x080) ~= 0 and {keyMatrix[7]} or { 0})[1] |
	((keyStrobe & 0x100) ~= 0 and {keyMatrix[8]} or { 0})[1] |
	((keyStrobe & 0x200) ~= 0 and {keyMatrix[9]} or { 0})[1];

	keyStrobe = keyStrobeLast;
	return key;
end	

--按键の状態 (outportの下請け)
--private void out10(int x)
local function out10()

end


--按键ストローブ(下位) (inportの下請け)
--private int in11()
local function in11()	
	return 0;
end

--按键ストローブ(下位) (outportの下請け)
--private void out11(int x)
local function out11(x)	
	if(keyStrobeLastStates - restStates > keyStrobeClearStates) then
		keyStrobe = 0;
	end

	keyStrobeLast = x;
	keyStrobe = keyStrobe | keyStrobeLast;
	keyStrobeLastStates = restStates;

	if((x & 0x10) ~= 0) then
		interruptType = interruptType | INTERRUPT_IA;
	end
end

--按键ストローブ(上位) (inportの下請け)
--private int in12()
local function in12()
	return 0;
end

--按键ストローブ(上位) (outportの下請け)
--private void out12(int x)
local function out12(x)
	if(keyStrobeLastStates - restStates > keyStrobeClearStates) then
		keyStrobe = 0;
	end

	keyStrobeLast = x << 8;
	keyStrobe = keyStrobe | keyStrobeLast;
	keyStrobeLastStates = restStates;
end

--シフト按键の状態 (inportの下請け)
--private int in13()
local function in13()
	return ((keyStrobe & 0x08) ~= 0 and {keyShift} or {0})[1];
end

--シフト按键の状態 (outportの下請け)
--private void out13(int x)
local function out13(x) end
	

--タイマ (inportの下請け)
--private int in14()
local function in14()
	return timer;
end

--タイマ (outportの下請け)
--private void out14(int x)
local function out14(x)
	timer = 0;
end

--Xin入力端子の入力可否状態 (inportの下請け)
--private int in15()
local function in15()
		-- 未対応 		return 0;
end

--Xin入力端子の入力可否状態 (outportの下請け)
--private void out15(int x)
local function out15()	
		-- 未対応 	
end

--割り込み要因 (inportの下請け)
--private int in16()
local function in16()
	return interruptType;
end

--割り込み要因 (outportの下請け)
--private void out16(int x)
local function out16(x)
	interruptType = interruptType & (~x & 0x0f);
end

--割り込みマスク (inportの下請け)
--private int in17()
local function in17()
	return interruptMask;
end

--割り込みマスク (outportの下請け)
--private void out17(int x)
local function out17(x)
	interruptMask = x;
end

--11pinI/Fの出力制御 (inportの下請け)
--private int in18()
local function in18()
	return pin11Out;
end

--Lua 版的 try...catch...finally
function tryCatch(fun1,fun2)
	if fun2 == nil then 
		local ret,errMessage = pcall(fun1);
	elseif func2 ~= nil then
		local ret,errMessage = xpcall(fun1,fun2);
	end
end

--SIOバッファに書き込む (out18の下請け)
--private void out18Write(int pin11_out)
local function out18Write(pin11_out)
	if((pin11In & PIN11_IN_IB2) ~= 0) then

		local pos = sioCount / 10;

		if((pin11_out & PIN11_OUT_FO2) ~= 0 and sioBuffer ~= nil and pos < sioBuffer.length) then 

			local n = sioCount % 10;
		
			-- 送信中 switch(n) {
			if n ==  0 then --break;   -- スタートビット
			elseif n == 1 then 
			elseif n == 2 then
			elseif n == 3 then 
			elseif n == 4 then
			elseif n == 5 then
			elseif n == 6 then
			elseif n == 7 then
			elseif n == 8 then -- データビット 					
				bit = 1 << (n - 1);

				if((pin11_out & PIN11_OUT_XOUT) == 0) then
					sioBuffer[pos] = sioBuffer[pos] | bit;
				else
					sioBuffer[pos] = sioBuffer[pos] &  ~bit;
				end
				--break;
			elseif n == 9 then -- ストップビット 					
				--break;
			end

			sioCount = sioCount + 1
		else 
			-- 送信終了 				
			pin11In = 0;
			if(sioCount > 3 and sioBuffer ~= nil and sioOutPathname ~= nil) then
				--FileOutputStream out = nil;
				out = nil
				--  用 Lua 模仿 try...catch...finally 结构
				local fun1=function ( ... )
					
						out = new FileOutputStream(sioOutPathname);
						if (sioBuffer[pos - 1] == 0x1a) then
							out.write(sioBuffer, 0, pos - 1);
						else
							out.write(sioBuffer, 0, pos);
						end
					
						if(out ~= nil) then
							out.close();
						end
				end

				--local tryCatch=function(fun) local ret,errMessage = pcall(fun); end

				tryCatch(fun1);
			end
		end
	else 
		if((pin11_out & PIN11_OUT_FO2) ~= 0) then
			-- 送信開始 				
			pin11In = PIN11_IN_IB2;
			sioCount = 0;
		end
	end
end

--ブザーから音を出力する (out18の下請け)
--private void out18Buzzer(int pin11_out)
local function out18Buzzer(pin11_out)

	pos = (executeStates - restStates) * (44100 / fps) / executeStates;
	if(pos < 0) then
		pos = 0;
	elseif(pos > wave.length - 1) then
		return;
	end

	if((pin11_out & (PIN11_OUT_BEEP | PIN11_OUT_XOUT)) ~= 0) then
		if(pos >= wave0.length) then return; end
		if(wave0[pos] ~=  0) then return; end
		--Arrays.fill(wave0, pos, wave0.length - 1, (byte) 0x3f);
		Arrays.fill(wave0, pos, wave0.length - 1, 0x3f);
	else 
		if(pos >= wave0.length) then return; end
		if(wave0[pos] ==  0) then return; end
		Arrays.fill(wave0, pos, wave0.length - 1,  0);
	end
end

--11pinI/Fの出力制御 (outportの下請け)
--private void out18(int x)
local function out18(x)
	pin11Out = x & (PIN11_OUT_FO1 | PIN11_OUT_FO2 | PIN11_OUT_BEEP | PIN11_OUT_XOUT);

	if(executeStates == 0) then return; end

	if(sioMode == SIO_MODE_OUT) then
		out18Write(x);
	else
		out18Buzzer(x);
	end
end

--ROMバンク切り替え (inportの下請け)
--private int in19()
local function in19()
	return ((exBank & 0x07) << 4) | (romBank & 0x0f);
end

--ROMバンク切り替え (outportの下請け)
--private void out19(int x)
local function out19(x)
	if(romBanks > 0) then
		romBank = (x & 0x0f) % romBanks;
		if(rom[romBank] ~= nil) then
			System.arraycopy(rom[romBank], 0, memory, 0xc000, 0x4000);
		else
			Arrays.fill(memory, 0xc000, 0x4000, 0xff);
		end
	end
	exBank = (x & 0x70) >> 4;
end

--BOOT ROM ON/OFF (inportの下請け)
--private int in1a()
local function in1a()
	return 0;
end

--BOOT ROM ON/OFF (outportの下請け)
--private void out1a(int x)
local function out1a(x)
	-- 未対応 	
end

--RAMバンク切り替え (inportの下請け)
--private int in1b()
local function in1b()
	return ramBank;
end

--RAMバンク切り替え (outportの下請け)
--private void out1b(int x)
local function out1b(x)
	ramBank = x & 0x04;
end

--I/Oリセット (inportの下請け)
--private int in1c()
local function in1c()
	return 0;
end

--I/Oリセット (outportの下請け)
--private void out1c(int x)
local function out1c(x)
	ioReset = x;
end

--バッテリー状態 (inportの下請け)
--private int in1d()
local function in1d()
	return 0x08;
end

--バッテリー状態 (outportの下請け)
--private void out1d(int x)
local function out1d(x)

end

--? (inportの下請け)
--private int in1e()
local function in1e()
	return 0;
end

--? (outportの下請け)
--private void out1e(int x)
local function out1e(x)

end

--SIOバッファから読み込む (in1fの下請け)
--private int in1fRead()
local function in1fRead()
	bit_count = { 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4 };
	local pos = sioCount / 14;
	--int pin11_in;

	if((pin11Out & PIN11_OUT_FO1) ~= 0) then  -- 送信要求 			
		if(sioCount == 0) then
			-- 初回ならバッファに書き込む 				
			inFile = nil;
			--int size;

			func2 = function()
				file = File(sioInPathname);

				if(0 < file.length() and file.length() < 0x100000) then
					--sioBuffer = new byte[(int )file.length() + 1];
					sioBuffer = {}

					func1 = function()
						inFile = FileInputStream(sioInPathname);
						size = inFile.read(sioBuffer, 0, sioBuffer.length);
						sioBuffer[size] = 0x1a;
					
						if(inFile ~= nil) then
							inFile.close();
						end
					end
					tryCatch(func1)
				else
					sioBuffer = nil;
				end
			end

			tryCatch(func1, function() sioBuffer = nil end)
		end	
		

		if(sioBuffer == nil or  pos >= sioBuffer.length) then
			pin11_in = 0;
		else 
			n = sioCount % 14;

			--switch(n) {
			if n == 0 then
			elseif n == 1  then
			elseif n == 2  then  -- スタートビット 					
				pin11_in = PIN11_IN_XIN | PIN11_IN_IB2;
				--break;
			elseif n ==  3  then 
			elseif n ==  4  then 
			elseif n ==  5  then 
			elseif n ==  6  then 
			elseif n ==  7  then 
			elseif n ==  8  then 
			elseif n ==  9  then 
			elseif n ==  10 then -- データビット 					
				if((sioBuffer[pos] & (1 << (n - 3))) == 0) then
					pin11_in = PIN11_IN_XIN;
				else
					pin11_in = 0;
				end
				--break;
			elseif n ==  11 then-- パリティビット 					
				--if(((bit_count[sioBuffer[pos] & 0x0f] + bit_count[(sioBuffer[pos] >>> 4) & 0x0f]) & 1) == 0) then
				if(((bit_count[sioBuffer[pos] & 0x0f] + bit_count[(sioBuffer[pos] >> 4) & 0x0f]) & 1) == 0) then
					pin11_in = 0;
				else
					pin11_in = PIN11_IN_XIN;
				end
				--break;
			elseif n == 12 then  
			elseif n == 13 then -- エンドビット 					
				pin11_in = PIN11_IN_IB2;
				--break;
			else
				pin11_in = 0;
				--break;
			end
		end

		sioCount = sioCount + 1;

	elseif((pin11Out & PIN11_OUT_FO2) ~= 0)  then -- 送信一時停止 			
		pin11_in = 0;
	else  -- 送信停止 			
		pin11_in = 0;
		sioCount = 0;
	end

	return pin11_in;

end

--11pinI/Fの入力 (inportの下請け)
--private int in1f()
local function in1f()	
	if(sioMode == SIO_MODE_IN) then
		pin11In = in1fRead();
	end
	return keyBreak | pin11In;
end

--11pinI/Fの入力 (outportの下請け)
--private void out1f(int x)
local function out1f(x)	

end

--VRAMのオフセットを得る (PC-E200)
--private int e200VramOffset(int x, int row, int begin)
local function e200VramOffset(x, row, begin)
	row = (row - begin + 8) % 8;

	if(x == 0x3c) then
		return row * E200_VRAM_WIDTH + (E200_VRAM_WIDTH - 1);
	end

	if(row < 4) then
		return (row - 0) * E200_VRAM_WIDTH + x;
	else
		return (row - 4) * E200_VRAM_WIDTH + (E200_VRAM_WIDTH - x - 2);
	end
end

--ディスプレイコントロール (PC-E200) (outportの下請け)
--private void out58_e200(int val)
local function out58_e200(val)
	--switch(val & 0xc0) 
	local valc = val & 0xc0
	if valc ==  0x00 then
		--break;
	elseif valc == 0x40 then
		lcdX = val & 0x3f;
		--break;
	elseif valc == 0x80 then
		lcdY = val & 0x07;
		--break;
	elseif valc == 0xc0 then
		--int row, x, begin_prev;

		System.arraycopy(vram, 0, tmpVram, 0, vram.length);

		begin_prev = lcdBegin;
		lcdBegin = (val >> 3) & 0x07;

		for row = 0, 8, 1 do
			for x = 0, 0x3d, 1 do
				vram[e200VramOffset(x, row, lcdBegin)] = tmpVram[e200VramOffset(x, row, begin_prev)];
			end
		end	
	--break;
	end
end

--ディスプレイコントロール (PC-E200) (inportの下請け)
--private int in59_e200()
local function in59_e200()	
	return 0;
end

--ディスプレイ WRITE (PC-E200) (outportの下請け)
--private void out5a_e200(int val)
local function ou55a_e200(val)
	if(lcdX < 0x3d and lcdY < 8) then
		lcdX = lcdX + 1
		vram[e200VramOffset(lcdX, lcdY, lcdBegin)] =  val;
	end
end

--ディスプレイ READ (PC-E200) (inportの下請け)
--private int in5b_e200()
	local function in5b_e200()
		if(lcdX > 0 and lcdX < 0x3d and lcdY < 8) then
			lcdX = LcdX + 1
			return vram[e200VramOffset(lcdX - 1, lcdY, lcdBegin)];
		end	
		return 0;
	end

--VRAMのオフセット(PC-G815)
--private int g815VramOffset(int x, int row, int begin)
local function g815VramOffset(x, row, begin)
		row = (row - begin + 8) % 8;

		if(x == 0x7b) then
			return row * G815_VRAM_WIDTH + (G815_VRAM_WIDTH - 1); end

		if(row < 4) then
			return (row - 0) * G815_VRAM_WIDTH + x;
		else
			return (row - 4) * G815_VRAM_WIDTH + (G815_VRAM_WIDTH - x - 2);
		end
end

--ディスプレイコントロール (PC-G815) (outportの下請け)
--private void out50_g815(int val)
local function out50_g815(val)
		--switch(val & 0xc0) {
		local valc = val & 0xc0
		if valc ==  0x00 then
			--break;
		elseif valc == 0x40 then
			lcdX = val & 0x3f;
			lcdX2 = lcdX
			--break;
		elseif valc == 0x80 then
			lcdY = val & 0x07;
			lcdY2 = lcdY
			--break;
		elseif valc == 0xc0 then
			--int row, x, begin_prev;

			local begin_prev = lcdBegin;
			local lcdBegin = (val >> 3) & 0x07;

			System.arraycopy(vram, 0, tmpVram, 0, vram.length);
			for row = 0, 8, 1 do
				for x = 0, 0x49, 1 do
					vram[g815VramOffset(x, row, lcdBegin)] = tmpVram[g815VramOffset(x, row, begin_prev)];
				end
			end			
			--break;
		end
	end

--ディスプレイコントロール (PC-G815) (inportの下請け)
--private int in51_g815()
local function in51_g815()
	return 0;
end

--ディスプレイコントロール (PC-G815) (outportの下請け)
--private void out54_g815(int val)
local function out54_g815(val)
	--switch(val & 0xc0) {
	local valc = val & 0xc0
	if valc == 0x00 then
		--break;
	elseif valc == 0x40 then
		lcdX2 = val & 0x3f;
		--break;
	elseif valc == 0x80 then
		lcdY2 = val & 0x07;
		--break;
	elseif valc == 0xc0 then
		out50_g815(val);
		--break;
	end
end

--ディスプレイコントロール (PC-G815) (inportの下請け)
--private int in55_g815()
local function in55_g815()
	return 0;
end

--ディスプレイコントロール (PC-G815) (outportの下請け)
--private void out58_g815(int val)
	local function out58_g815(val)
		--		switch(val & 0xc0) {
		local valc = val & 0xc0
		if valc == 0x00 then
			--break;
		elseif valc == 0x40 then
			lcdX = val & 0x3f;
			--break;
		elseif valc == 0x80 then
			lcdY = val & 0x07;
			--break;
		elseif valc == 0xc0 then
			out50_g815(val);
			--break;
	end
end

--ディスプレイコントロール (PC-G815) (inportの下請け)
--private int in59_g815()
local function in59_g815()
		return 0;
end

--ディスプレイ WRITE (PC-G815) (outportの下請け)
--private void out56_g815(int x)
local function out56_g815(x)
	if(lcdX2 < 0x3c and lcdY2 < 8) then
		lcdX2 = lcdX2 + 1
		vram[g815VramOffset(lcdX2, lcdY2, lcdBegin)] = x;
	end
end

--ディスプレイ READ (PC-G815) (inportの下請け)
--private int in57_g815()
local function in57_g815()
		if(lcdX2 - 1 < 0x3c and lcdX2 > 0 and lcdY2 < 8) then
			lcdX2 = lcdX2 + 1
			return vram[g815VramOffset(lcdX2 - 1, lcdY2, lcdBegin)];
		end
		return 0;
	end

--ディスプレイ WRITE (PC-G815) (outportの下請け)
--private void out5a_g815(int x)
	local function out5a_g815(x)
		if((0x3c + lcdX < 0x49 or  0x3c + lcdX == 0x7b) and lcdY < 8) then
			lcdX = lcdX + 1
			vram[g815VramOffset(0x3c + lcdX, lcdY, lcdBegin)] = x;
end
end	

--ディスプレイ READ (PC-G815) (inportの下請け)
--private int in5b_g815()
local function in5b_g815()
	if(0x3c + lcdX - 1 < 0x49 and lcdY < 8) then
		lcdX = lcdX + 1
		return vram[g815VramOffset(0x3c + lcdX - 1, lcdY, lcdBegin)];
	end
	return 0;
end

--ディスプレイ WRITE (PC-G815) (outportの下請け)
--private void out52_g815(int x)
local function out52_g815(x)
		out56_g815(x);
		out5a_g815(x);
end

--VRAMのオフセット(PC-G850)
--private int g850VramOffset(int x, int row)
local function g850VramOffset(x, row)
		return row * G850_VRAM_WIDTH + x;
end

--ディスプレイコントロール (PC-G850) (inportの下請け)
--private int in40_g850()
local function in40_g850()
		return 0;
end

--ディスプレイコントロール (PC-G850) (outportの下請け)
--private void out40_g850(int x)
local function out40_g850(x)
	--switch(x & 0xf0) {
	local xf = x & 0xf0
		if xf == 0x00 then
			lcdX = (lcdX & 0xf0) | (x & 0x0f);
			--break;
		elseif xf == 0x10 then
			lcdX = ((x << 4) & 0xf0) | (lcdX & 0x0f);
			--break;
		elseif xf == 0x20 then
			if(x == 0x24) then
				lcdDisabled = true;
			elseif(x == 0x25) then
				lcdDisabled = false;
			end
			--break;
		elseif xf == 0x30 then
			timerInterval = 16192 * ((x & 0x0f) + 1);
			--break;
		elseif xf == 0x40 then
		elseif xf == 0x50 then
		elseif xf == 0x60 then
		elseif xf == 0x70 then
			lcdTop = x - 0x40;
			--break;
		elseif xf == 0x80 then
		elseif xf == 0x90 then
			lcdContrast = x - 0x80;
			--break;
		elseif xf == 0xa0 then
			--switch(x) {
			if x ==  0xa0 then
				lcdEffectMirror = false;
				--break;
			elseif x == 0xa1 then
				lcdEffectMirror = true;
				--break;
			elseif x == 0xa4 then
				lcdEffectBlack = false;
				--break;
			elseif x == 0xa5 then
				lcdEffectBlack = true;
				lcdEffectWhite = false;
				--break;
			elseif x == 0xa6 then
				lcdEffectReverse = false;
				--break;
			elseif x == 0xa7 then
				lcdEffectReverse = true;
				--break;
			elseif x == 0xa8 then
				lcdEffectDark = true;
				--break;
			elseif x == 0xa9 then
				lcdEffectDark = false;
				--break;
			elseif x == 0xae then
				lcdEffectWhite = true;
				lcdEffectBlack = false;
				--break;
			elseif x == 0xaf then
				lcdEffectWhite = false;
				--break;
			end
			--break;
		elseif xf == 0xb0 then
			lcdY = x & 0x0f;
			--break;
		elseif xf == 0xc0 then
			lcdTrim = x & 0x0f;
			--break;
		elseif xf == 0xd0 then
			--break;
		elseif xf == 0xe0 then
			if(x == 0xe2) then
				lcdContrast = 0;
			end
			--break;
		elseif xf == 0xf0 then
			--break;
		end
	end

--ディスプレイ READ (PC-G850) (inportの下請け)
--private int in41_g850()
local function in41_g850()
	if(lcdX == 0) then
		lcdX = lcdX + 1
		return 0x10;
	elseif(lcdY >= 8) then
		return 0xff;
	elseif(lcdX < 166 - 1) then
		lcdX = lcdX + 1
		return vram[g850VramOffset(lcdX - 1, lcdY)];
	else
		return 0xff;
	end
end

--ディスプレイ WRITE (PC-G850) (outportの下請け)
--private void out41_g850(int x)
local function out41_g850(x)
	if(lcdX < 166 and lcdY < 8) then
		lcdX = lcdX + 1	
		vram[g850VramOffset(lcdX, lcdY)] = x;
	end
end

--11pin I/Fの動作 (inportの下請け)
--private int in60_g850()
	local function in60_g850()
		-- 未対応 		
	return 0;
end

--11pin I/Fの動作 (outportの下請け)
--private void out60_g850(int x)
	local function out60_g850(x)
		-- 未対応 	
end

--パラレルI/Oの入出力方向 (inportの下請け)
--private int in61_g850()
	local function in61_g850()
		return 0;
	end

--パラレルI/Oの入出力方向 (outportの下請け)
--private void out61_g850(int x)
	local function out61_g850(x)
		-- 未対応 	
end

--パラレルI/Oのデータレジスタ (inportの下請け)
--private int in62_g850()
local function in62_g850()
		-- 未対応 		
return 0;
end

--パラレルI/Oのデータレジスタ (outportの下請け)
--private void out62_g850(int x)
local function out62_g850(x)
		-- 未対応 	
end

--UARTフロー制御 (inportの下請け)
--private int in63_g850()
local function in63_g850()
		-- 未対応 		
return 0;
end

--UARTフロー制御 (outportの下請け)
--private void out63_g850(int x)
local function out63_g850(x)
		-- 未対応 	
end

--CD信号によるON制御 (inportの下請け)
--private int in64_g850()
	local function in64_g850()
		-- 未対応 		
return 0;
end

--CD信号によるON制御 (outportの下請け)
--private void out64_g850(int x)
local function out64_g850(x)
		-- 未対応 	
end

--M1信号後wait制御 (inportの下請け)
--private int in65_g850()
	local function in65_g850()
		return 0;
	end

--M1信号後wait制御 (outportの下請け)
--private void out65_g850(int x)
local function out65_g850(x)
		-- 未対応 	
end

--I/O wait (inportの下請け)
--private int in66_g850()
	local function in66_g850()
		-- 未対応 		
return 0;
end

--I/O wait (outportの下請け)
--private void out66_g850(int x)
	local function out66_g850(x)
		-- 未対応 	
end

--CPUクロック高速/低速切り替え (PC-G850) (inportの下請け)
--private int in67_g850()
	local function in67_g850()
		-- 未対応 		
return 0;
end

--CPUクロック高速/低速切り替え (PC-G850) (outportの下請け)
--private void out67_g850(int x)
	local function out67_g850(x)
		-- 未対応 	
end

--タイマ信号/LCDドライバ周期 (inportの下請け)
--private int in68_g850()
	local function in68_g850()
		-- 未対応 		
return 0;
	end

--タイマ信号/LCDドライバ周期 (outportの下請け)
--private void out68_g850(int x)
local function out68_g850(x)
		-- 未対応 	
end

--ROMバンク切り替え (PC-G850) (inportの下請け)
		--private int in69_g850()
	local function in69_g850()
		return romBank;
	end

	--		ROMバンク切り替え (PC-G850) (outportの下請け)
	--	private void out69_g850(int x)
	local function out69_g850(x)
		romBank = x;
		if(rom[romBank] ~= nil) then
			System.arraycopy(rom[romBank], 0, memory, 0xc000, 0x4000);
		else
			Arrays.fill(memory, 0xc000, 0x4000, 0xff);
	end
end

--? (inportの下請け)
--private int in6a_g850()
	local function in6a_g850()
		return 0;
	end

	--		? (outportの下請け)
	--	private void out6a_g850(int x)
	local function out6a_g850(x)
	end

	--		UARTの入力選択 (inportの下請け)
	--	private int in6b_g850()
	local function in6b_g850()
		-- 未対応 		
		return 0;
	end

	--		UARTの入力選択 (outportの下請け)
	--	private void out6b_g850(int x)
	local function out6b_g850(x)
		-- 未対応 	
end

	--		UARTモードレジスタ (inportの下請け)
	--	private int in6c_g850()
	local function in6c_g850()
		-- 未対応 		
return 0;
	end

	--		UARTモードレジスタ (outportの下請け)
	--	private void out6c_g850(int x)
	local function out6c_g850(x)
		-- 未対応 
end

	--	UARTコマンドレジスタ (inportの下請け)
	--	private int in6d_g850()
	local function in6d_g850()
		-- 未対応 		
return 0;
	end

	--		UARTコマンドレジスタ (outportの下請け)
	--	private void out6d_g850(int x)
	local function out6d_g850(x)
		-- 未対応 	
end

	--		UARTステータスレジスタ (inportの下請け)
	--	private int in6e_g850()
	local function in6e_g850()
		-- 未対応 		
	return 0;
end

	--		UARTステータスレジスタ (outportの下請け)
	--	private void out6e_g850(int x)
	local function out6e_g850(x)
		-- 未対応 	
end

	--		UART送受信レジスタ (inportの下請け)
	--	private int in6f_g850()
	local function in6f_g850()
		-- 未対応 		
return 0;
	end

	--UART送受信レジスタ (outportの下請け)
--private void out6f_g850(int x)
	local function out6f_g850(x)
		-- 未対応 	
end

--I/Oから入力を得る (オーバーライド)
--@Override public int inport(int address)
function inport(address)
	-- ディスプレイ用・その他(機種依存) 		
	--switch(machine) {
	if machine ==  MACHINE_E200 then
		--switch(address) {
		if address == 0x51 then
		elseif address == 0x59 then
			return in59_e200();
		elseif address == 0x57 then
		elseif address == 0x5b then
			return in5b_e200();
		end
		--break;
	elseif machine == MACHINE_G815 then
		--switch(address) {
		if address == 0x51 then
			return in51_g815();
		elseif address == 0x55 then
			return in55_g815();
		elseif address == 0x57 then
			return in57_g815();
		elseif address == 0x59 then
			return in59_g815();
		elseif address == 0x5b then
			return in5b_g815();
		end
		--break;
	elseif machine == MACHINE_G850 then
		--switch(address) {
		if address == 0x40 then
		elseif address == 0x42 then
		elseif address == 0x44 then
		elseif address == 0x46 then
		elseif address == 0x48 then
		elseif address == 0x4a then
		elseif address == 0x4c then
		elseif address == 0x4e then
		elseif address == 0x50 then
		elseif address == 0x52 then
		elseif address == 0x54 then
		elseif address == 0x56 then
		elseif address == 0x58 then
		elseif address == 0x5a then
		elseif address == 0x5c then
		elseif address == 0x5e then
			return in40_g850();
		elseif address == 0x41 then
		elseif address == 0x43 then
		elseif address == 0x45 then
		elseif address == 0x47 then
		elseif address == 0x49 then
		elseif address == 0x4b then
		elseif address == 0x4d then
		elseif address == 0x4f then
		elseif address == 0x51 then
		elseif address == 0x53 then
		elseif address == 0x55 then
		elseif address == 0x57 then
		elseif address == 0x59 then
		elseif address == 0x5b then
		elseif address == 0x5d then
		elseif address == 0x5f then
			return in41_g850();
		elseif address == 0x60 then
			return in60_g850();
		elseif address == 0x61 then
			return in61_g850();
		elseif address == 0x62 then
			return in62_g850();
		elseif address == 0x63 then
			return in63_g850();
		elseif address == 0x64 then
			return in64_g850();
		elseif address == 0x65 then
			return in65_g850();
		elseif address == 0x66 then
			return in66_g850();
		elseif address == 0x67 then
			return in67_g850();
		elseif address == 0x68 then
			return in68_g850();
		elseif address == 0x69 then
			return in69_g850();
		elseif address == 0x6a then
			return in6a_g850();
		elseif address == 0x6b then
			return in6b_g850();
		elseif address == 0x6c then
			return in6c_g850();
		elseif address == 0x6d then
			return in6d_g850();
		elseif address == 0x6e then
			return in6e_g850();
		elseif address == 0x6f then
			return in6f_g850();
		end
		--break;
	end

	-- システムポート(共通) 		
	--switch(address) {
	if address == 0x10 then
		return in10();
	elseif address == 0x11 then
		return in11();
	elseif address == 0x12 then
		return in12();
	elseif address == 0x13 then
		return in13();
	elseif address == 0x14 then
		return in14();
	elseif address == 0x15 then
		return in15();
	elseif address == 0x16 then
		return in16();
	elseif address == 0x17 then
		return in17();
	elseif address == 0x18 then
		return in18();
	elseif address == 0x19 then
		return in19();
	elseif address == 0x1a then
		return in1a();
	elseif address == 0x1b then
		return in1b();
	elseif address == 0x1c then
		return in1c();
	elseif address == 0x1d then
		return in1d();
	elseif address == 0x1e then
		return in1e();
	elseif address == 0x1f then
		return in1f();
	end

	return 0x78;
end

--		I/Oに出力する (オーバーライド)
--	@Override public void outport(int address, int value)
function outport(address, value)
	-- ディスプレイ用・その他(機種依存) 		
	--switch(machine) {
	if machine == MACHINE_E200 then
		--switch(address) {
		if address == 0x50 then
		elseif address == 0x58 then
			out58_e200(value); --break;
		elseif address == 0x56 then
		elseif address == 0x5a then
			out5a_e200(value); --break;
		end
		--break;
	elseif machine == MACHINE_G815  then
		--switch(address) {
		if address == 0x50 then
			out50_g815(value); --break;
		elseif address == 0x52 then
			out52_g815(value); --break;
		elseif address == 0x54 then
			out54_g815(value); --break;
		elseif address == 0x56 then
			out56_g815(value); --break;
		elseif address == 0x58 then
			out58_g815(value); --break;
		elseif address == 0x5a then
			out5a_g815(value); --break;
		end
		--break;
	elseif machine == MACHINE_G850 then
		--switch(address) {
		if address == 0x40 then
		elseif address == 0x42 then
		elseif address == 0x44 then
		elseif address == 0x46 then
		elseif address == 0x48 then
		elseif address == 0x4a then
		elseif address == 0x4c then
		elseif address == 0x4e then
		elseif address == 0x50 then
		elseif address == 0x52 then
		elseif address == 0x54 then
		elseif address == 0x56 then
		elseif address == 0x58 then
		elseif address == 0x5a then
		elseif address == 0x5c then
		elseif address == 0x5e then
			out40_g850(value); --break;
		elseif address == 0x41 then
		elseif address == 0x43 then
		elseif address == 0x45 then
		elseif address == 0x47 then
		elseif address == 0x49 then
		elseif address == 0x4b then
		elseif address == 0x4d then
		elseif address == 0x4f then
		elseif address == 0x51 then
		elseif address == 0x53 then
		elseif address == 0x55 then
		elseif address == 0x57 then
		elseif address == 0x59 then
		elseif address == 0x5b then
		elseif address == 0x5d then
		elseif address == 0x5f then
			out41_g850(value); --break;
		elseif address == 0x60 then
			out60_g850(value); --break;
		elseif address == 0x61 then
			out61_g850(value); --break;
		elseif address == 0x62 then
			out62_g850(value); --break;
		elseif address == 0x63 then
			out63_g850(value); --break;
		elseif address == 0x64 then
			out64_g850(value); --break;
		elseif address == 0x65 then
			out65_g850(value); --break;
		elseif address == 0x66 then
			out66_g850(value); --break;
		elseif address == 0x67 then
			out67_g850(value); --break;
		elseif address == 0x68 then
			out68_g850(value); --break;
		elseif address == 0x69 then
			out69_g850(value); --break;
		elseif address == 0x6a then
			out6a_g850(value); --break;
		elseif address == 0x6b then
			out6b_g850(value); --break;
		elseif address == 0x6c then
			out6c_g850(value); --break;
		elseif address == 0x6d then
			out6d_g850(value); --break;
		elseif address == 0x6e then
			out6e_g850(value); --break;
		elseif address ==0x6f then
			out6f_g850(value); --break;
		end
		--break;
	end

	-- システムポート(共通) 		
	--switch(address) {
	if address == 0x10 then
		out10(value); --break;
	elseif address == 0x11 then
		out11(value); --break;
	elseif address == 0x12 then
		out12(value); --break;
	elseif address == 0x13 then
		out13(value); --break;
	elseif address ==	0x14 then
		out14(value); --break;
	elseif address == 0x15 then
		out15(value); --break;
	elseif address == 0x16 then
		out16(value); --break;
	elseif address == 0x17 then
		out17(value); --break;
	elseif address == 0x18 then
		out18(value); --break;
	elseif address == 0x19 then
		out19(value); --break;
	elseif address == 0x1a then
		out1a(value); --break;
	elseif address == 0x1b then
		out1b(value); --break;
	elseif address == 0x1c then
		out1c(value); --break;
	elseif address == 0x1e then
		out1e(value); --break;
	elseif address == 0x1f then
		out1f(value); --break;
	end
end

--破壊された16bitレジスタの値を得る (下請け)
--private int destroy16()
	local function destroy16()
		random = random * 65541 + 1;
		--return random >>> 16;
	return random >> 16;
	end

--破壊された8bitレジスタの値を得る (下請け)
--private int destroy8()
	local function destroy8()
	--return destroy16() >>> 8;
	return destroy16() >>8
	end

--VRAMのオフセットを得る (下請け)
--private int vramOffset(int x, int row)
	local function vramOffset(x, row)
		return (row % 8) * vramWidth + x;
	end

	--VRAMのオフセットを得る (下請け)
	--private int lcdOffset(int x, int row)
	local function lcdOffset(x, row)
		if(machine == MACHINE_G850) then
			return vramOffset(x, row + read8(0x790d));
		else
			return vramOffset(x, row);
		end
	end

	--パターンを表示する (下請け)
	--private void putPattern(int col, int row, byte[] pattern, int length)
local function putPattern(col, row, pattern, length)
		local typePattern = type(pattern)
		
		local offset = lcdOffset(col * cellWidth, row)
		local p = 0;
	if typePattern == "table" then
		while (length > 0) do
			length = length - 1 
			vram[offset] = pattern[p];
			offset = offset + 1
			p = p + 1
		end
	elseif typePattern == "number" then
		while (length > 0) do 
             length = length - 1 
             vram[offset] = read(pattern);
			offset = offset + 1
			address = address +1 
		end
	end
end

--[[
			パターンを表示する (下請け)
		private void putPattern(int col, int row, int address, int length)
	{
		int offset = lcdOffset(col * cellWidth, row);

		while (length-- > 0)
			vram[offset++] = read(address++);
	}
--]]
			
--行を消去する (下請け)
--private void clearLine(int row)
local function clearLine(row)
		local offset = lcdOffset(0, row)

		for x = 0, vramWidth - 1, 1 do
			offset = offset + 1
			vram[offset] = 0;
		end
end

--画面全体を消去する (下請け)
--private void clearAll()
	local function clearAll()

		for row = 0, vramRows, 1 do
			clearLine(row);
	end
end

--上にスクロールする
--private void scrollUp()
local function scrollUp()
	

	local tmp = vram[vramOffset(lcdWidth, 7)];
	vram[vramOffset(lcdWidth, 7)] = vram[vramOffset(lcdWidth, 6)];
	vram[vramOffset(lcdWidth, 6)] = vram[vramOffset(lcdWidth, 5)];
	vram[vramOffset(lcdWidth, 5)] = vram[vramOffset(lcdWidth, 4)];
	vram[vramOffset(lcdWidth, 4)] = vram[vramOffset(lcdWidth, 3)];
	vram[vramOffset(lcdWidth, 3)] = vram[vramOffset(lcdWidth, 2)];
	vram[vramOffset(lcdWidth, 2)] = vram[vramOffset(lcdWidth, 1)];
	vram[vramOffset(lcdWidth, 1)] = vram[vramOffset(lcdWidth, 0)];
	vram[vramOffset(lcdWidth, 0)] = tmp;

	clearLine(0);
	--switch(machine) {
	if machine == MACHINE_E200 then
		write8(0x790d, (read8(0x790d) + 1) % 8);
		outport(0x58, (read8(0x790d) << 3) | 0xc0);
		--break;
	elseif machine == MACHINE_G815 then
		write8(0x790d, (read8(0x790d) + 1) % 8);
		outport(0x50, (read8(0x790d) << 3) | 0xc0);
		--break;
	elseif machine == MACHINE_G850 then
		clearLine(6);
		clearLine(7);
		write8(0x790d, (read8(0x790d) + 1) % vramRows);
		outport(0x40, (read8(0x790d) * 8) % (vramRows * 8) | 0x40);
		--break;
	end
end

--下にスクロールする
--private void scrollDown(int row, int col)
local function scroolDown(row, col)
		--int length, r, x;

		local length = lcdWidth - row * cellWidth;
-----
		--for r = vramRows - 1,  r != row; -1 do
		for r = vramRows - 1, 0, -1 do
			for x = col * cellWidth, lcdWidth * cellWidth,1 do
				vram[lcdOffset(x, r)] = vram[lcdOffset(x, r - 1)];
			end
		end
		clearLine(r);
	end

--文字を表示する (下請け)
--private void putChar(int col, int row, int chr)
	local function putChar(col, row, chr)
		putPattern(col, row, font[chr], cellWidth);
	end

	--		最初の文字を表示する (下請け)
	--	private void putCharFirst(int col, int row, int chr)
	local function putCharFirst(col, row, chr)
		curCol = col;
		curRow = row;

		putChar(curCol, curRow, chr);
	end

	--		次の文字を表示する (下請け)
	--	private boolean putCharNext(int chr)
	local function putCharNext(chr)
		if(curCol < lcdCols - 1)  then
			curCol = curCol +1;

			putChar(curCol, curRow, chr);
			return false;
		elseif(curRow < lcdRows - 1) then
			curCol = 0;
			curRow = curRow + 1;

			putChar(curCol, curRow, chr);
			return false;
		else 
			curCol = 0;
			curRow = lcdRows - 1;

			scrollUp();
			putChar(curCol, curRow, chr);
			return true;
		end
	end

	--		文字列を表示する (下請け)
	--	private void putString(int col, int row, String text)
	local function putString(col, row, text)
		--int i;

		putCharFirst(col, row, text.charAt(0));
		for i = 1,  text.length(), 1 do
			putCharNext(text.charAt(i));
		end
end

--			LCD上にドットがあるか調べる
--		private int point(int x, int y)
	local function point(x, y)
		if(x < 0 or y < 0 or x >= lcdWidth or y >= lcdHeight) then
			return 0;
	end

		return vram[lcdOffset(x, y / 8)];
	end

	--		LCD上に点を描く
	--	private void pset(int x, int y, int mode)
	local function pset(x, y, mode)
		--int mask;

		if(x < 0 or y < 0 or x >= lcdWidth or y >= lcdHeight) then
			return;
		end

	-- ??
		local mask = 1 << (y % 8);

		--switch(mode) {
		if mode == 0 then
			vram[lcdOffset(x, y / 8)] = vram[lcdOffset(x, y / 8)] & ~mask;
			--break;
		elseif mode == 1 then
			vram[lcdOffset(x, y / 8)] = vram[lcdOffset(x, y / 8)] | mask;
			--break;
		else
			vram[lcdOffset(x, y / 8)] = vram[lcdOffset(x, y / 8)] ~  mask;
			--break;
		end
	end

--LCD上に線を描く
--private void line(int x1, int y1, int x2, int y2, int mode)
	local function line(x1, y1, x2, y2, mode)
		--int dx, dx0, dy, dy0, e, x, y, tmp;

		local dx0 = x2 - x1;
		local dx = (dx0 > 0 and {dx0} or {-dx0})[1];
		local dy0 = y2 - y1;
		local dy = (dy0 > 0 and {dy0} or {-dy0})[1];

		if(dx > dy)  then
			if(dx0 < 0) then
				tmp = x1; x1 = x2; x2 = tmp;
				tmp = y1; y1 = y2; y2 = tmp;
				dy0 = -dy0;
			end
			--for(x = x1, y = y1, e = 0; x <= x2; x++) {
			for x = x1, x2, 1 do
				y, e = y1, 0
				e = e + dy;
				if(e > dx) then
					e = e - dx;
					y = y + (dy0 > 0 and {1} or {-1})[1];
				end
				pset(x, y, mode);
			end
		else 
			if(dy0 < 0) then
				tmp = x1; x1 = x2; x2 = tmp;
				tmp = y1; y1 = y2; y2 = tmp;
				dx0 = -dx0;
			end
			--for(y = y1, x = x1, e = 0; y <= y2; y++) {
			for y = y1, y2, 1 do
				x = x1
				e = 0
				e = e + dx;
				if(e > dy) then
					e = e - dy;
					x = x + (dx0 > 0 and {1} or {-1})[1];
				end
				pset(x, y, mode);
			end
		end
	end

	--		LCD上に四角を描く
	--	private void box(int x1, int y1, int x2, int y2, int mode)
	local function box(x1, y1, x2, y2, mode)
		--int i, tmp;

		if(x1 > x2) then
			tmp = x1; x1 = x2; x2 = tmp;
		end
		if(y1 > y2) then
			tmp = y1; y1 = y2; y2 = tmp;
		end

		for i = x1, x2+1, 1 do
			pset(i, y1, mode);
		end
		for i = y1 + 1, y2 - 1, 1 do
			pset(x1, i, mode);
		end
		if(x1 ~= x2) then
			for i = y1 + 1, y2 - 1, 1 do
				pset(x2, i, mode);
			end
		end
		if(y1 ~= y2) then
			for i = x1, x2, 1 do
				pset(i, y2, mode);
			end
		end
end

		--	LCD上に塗りつぶした四角を描く
		--private void boxfill(int x1, int y1, int x2, int y2, int mode)
	local function boxfill(x1, y1, x2, y2, mode)
		--int i, j;

		for j = y1, y2, 1 do
			for i = x1, x2,  1 do
				pset(i, j, mode);
			end
		end
	end
	

	--		LCD上にパターンを描く
	--	private void gprint(int x, int y, int pat)
	local function gprint(x, y, pat)
		pset(x, y - 7, ((pat & 0x01) ~= 0 and {1} or {0})[1]);
		pset(x, y - 6, ((pat & 0x02) ~= 0 and {1} or {0})[1]);
		pset(x, y - 5, ((pat & 0x04) ~= 0 and {1} or {0})[1]);
		pset(x, y - 4, ((pat & 0x08) ~= 0 and {1} or {0})[1]);
		pset(x, y - 3, ((pat & 0x10) ~= 0 and {1} or {0})[1]);
		pset(x, y - 2, ((pat & 0x20) ~= 0 and {1} or {0})[1]);
		pset(x, y - 1, ((pat & 0x40) ~= 0 and {1} or {0})[1]);
		pset(x, y - 0, ((pat & 0x80) ~= 0 and {1} or {0})[1]);
	end

	--		押されている按键を得る(waitなし) (下請け)
	--	private int getKey()
	local function getKey()
		--int key, i;

		if(keyBreak ~= 0) then
			return GKEY_BREAK;
		end
		for key = GKEY_OFF - 1, GKEY_CLS - 1, 1 do
			if((keyMatrix[key / 8] & (1 << (key % 8))) ~= 0) then
				for i = key + 1, GKEY_CLS - 1, 1 do
					if((keyMatrix[i / 8] & (1 << (i % 8))) ~= 0) then
						return GKEY_DOUBLE;
					end 
				end

				return (key + 1) | (keyShift ~= 0 and {0x80} or {0})[1];
			end
		end
		return GKEY_NONE;
	end

	--		押されている按键を得る(waitあり) (下請け)
	--	private int getKeyWait()
	local function getKeyWit()
		if(pressedKey ~= GKEY_NONE) then
			if(getKey() == GKEY_NONE) then
				pressedKey = GKEY_NONE;
			end	
			return GKEY_NONE;
		end
		pressedKey = getKey()
		if(pressedKey  == GKEY_NONE) then
			return GKEY_NONE;
		end
		return pressedKey;
	end

	--		按键コードをASCIIコードに変換する (下請け)
	--	private int keyToAscii(int key, boolean upper)
	local function keyToAscii(key, upper)
		if(upper and key < 0x49) then
			return keyToAsciiUpper[key];
		else
			return keyToAsciiLower[key];
		end
	end

	--		全レジスタを表示する (subroutineの下請け)
	--	private int iocs_bd03()
	local function iocs_bd03()
		clearAll();
		putString(0, 0, String.format("PC=%04X  AF=%02X %02X", pc, a.get(), f.get()));
		putString(0, 1, String.format("SP=%04X  BC=%02X %02X", sp.get(), b.get(), c.get()));
		putString(0, 2, String.format("IX=%04X  DE=%02X %02X", ix.get(), d.get(), e.get()));
		putString(0, 3, String.format("IY=%04X  HL=%02X %02X", iy.get(), h.get(), l.get()));

		if(getKeyWait() == GKEY_NONE) then
			return 0;
		end
		return 1000;
	end

	--		少し待つ (PC-G850専用) (subroutineの下請け)
	--	private int iocs_8aad()
	local function iocs_8aad()
		return 1500;
	end

	--		ドットの状態を得る (PC-G815専用) (subroutineの下請け)
	--	private int iocs_02_f9f8()
	local function iocs_02_f9f8()
		a.set(point(hl.get(), de.get()));
		c.set(1 << (de.get() % 8));
		return 1000;
	end

--ドットを描く (PC-G815専用) (subroutineの下請け)
--private int iocs_0d_c76e()
local function iocs_0d_c76e()
	pset(hl.get(), de.get(), read8(0x7f0f));
	return 1000;
end

--線分を描く (PC-G815専用) (subroutineの下請け)
--private int iocs_0d_c5fc()
local function iocs_0d_c5fc()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7968);
	local y2 = read16(0x796a);

	line(x1, y1, x2, y2, read8(0x7f0f));
	return 6000;
end

--四角を描く (PC-G815専用) (subroutineの下請け)
--private int iocs_0d_c4a9()
local function iocs_0d_c4a9()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7968);
	local y2 = read16(0x796a);

	de.set(y2);
	box(x1, y1, x2, y2, read8(0x7f0f));
	return 8000;
end

--四角を描く (PC-G815専用) (subroutineの下請け)
--private int iocs_0d_c442()
function iocs_0d_c442()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7968);
	local y2 = read16(0x796a);

	de.set(y2);
	box(x1, y1, x2, y2, read8(0x777f));
	return 10000;
end

--塗りつぶした四角を描く (PC-G815専用) (subroutineの下請け)
--private int iocs_0d_c532()
function iocs_0d_c532()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7968);
	local y2 = read16(0x796a);

	de.set(y2);
	boxfill(x1, y1, x2, y2, read8(0x7f0f));
	return 10000;
end

--線分を描く (PC-G815専用) (subroutineの下請け)
--private int iocs_0d_c595()
function iocs_0d_c595()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7968);
	local y2 = read16(0x796a);

	line(x1, y1, x2, y2, read8(0x777f));
	return 6000;
end	

--文字を描く (PC-G815専用) (subroutineの下請け)
--private int iocs_02_f892()
local function iocs_02_f892()
	local x = read16(0x79dc);
	local y = read16(0x79de);

	write8(0x79db, read8(0x79db) + 1);
	if(read8(0x79db) == 0) then
		write8(0x79dc, read8(0x79dc) + 1);
	end
	hl.set(x);
	de.set(y & 0xff80);
	gprint(x, y, a.get());
	return 4000;
end

--グラフィック処理 (PC-G815専用) (subroutineの下請け)
--private int iocs_9490()
local function iocs_9490()
	--int address, page;

	page = read8(pc);
	address = read16(pc + 1);

	pc = read16(sp);
	sp.add(2);

	--switch(page) {
	if page ==  0x02 then
		--switch(address) {
		if address ==  0xf892 then
			return iocs_02_f892();
		elseif address ==  0xf9f8 then
			return iocs_02_f9f8();
		end
		--break;
	elseif page == 0x0d then
		--switch(address) {
		if address == 0xc76e then
			return iocs_0d_c76e();
		elseif address == 0xc5fc then
			return iocs_0d_c5fc();
		elseif address == 0xc4a9 then
			return iocs_0d_c4a9();
		elseif address == 0xc442 then
			return iocs_0d_c442();
		elseif address == 0xc532 then
			return iocs_0d_c532();
		elseif address == 0xc595 then
			return iocs_0d_c595();
		end
		--break;
	end

	return 1000;
end

--ドットの状態を得る (PC-G850専用) (subroutineの下請け)
--private int iocs_0e_ffca()
local function iocs_0e_ffca()
	a.set(point(hl.get(), de.get()));
	c.set(1 << (de.get() % 8));
	return 1000;
end

--ドットを描く (PC-G850専用) (subroutineの下請け)
--private int iocs_0d_ffd0()
local function iocs_0d_ffd0()
	pset(hl.get(), de.get(), read8(0x777f));
	return 1000;
end

--線分を描く (PC-G850専用) (subroutineの下請け)
--private int iocs_0d_ffd3()
local function iocs_0d_ffd3()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7967);
	local y2 = read16(0x7969);

	line(x1, y1, x2, y2, read8(0x777f));
	return 5000;
end

--四角を描く (PC-G850専用) (subroutineの下請け)
--private int iocs_0d_ffd6()
local function iocs_0d_ffd6()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7967);
	local y2 = read16(0x7969);

	de.set(y2);
	box(x1, y1, x2, y2, read8(0x777f));
	return 6000;
end

--塗りつぶした四角を描く (PC-G850専用) (subroutineの下請け)
--private int iocs_0d_ffd9()
local function iocs_0d_ffd9()
	local x1 = hl.get();
	local y1 = de.get();
	local x2 = read16(0x7967);
	local y2 = read16(0x7969);

	de.set(y2);
	boxfill(x1, y1, x2, y2, read8(0x777f));
	return 10000;
end

--文字を描く (PC-G850専用) (subroutineの下請け)
--private int iocs_0e_ffa3()
local function iocs_0e_ffa3()
	local x = read16(0x79db);
	local y = read16(0x79dd);

	write8(0x79db, read8(0x79db) + 1);
	if(read8(0x79db) == 0) then
		write8(0x79dc, read8(0x79dc) + 1);
	end
	hl.set(x);
	de.set(y & 0xff80);
	gprint(x, y, a.get());
	return 3000;
end

--グラフィック処理 (PC-G850専用) (subroutineの下請け)
--private int iocs_bb6b()
local function iocs_bb6b()
	--int address, page;

	page = read8(pc);
	address = read16(pc + 1);

	pc = read16(sp);
	sp.add(2);

	--switch(page) {

	if page ==  0x0d then
		--switch(address) {

		if     address ==  0xc76e then
		elseif address ==  0xffd0 then
			return iocs_0d_ffd0();
		elseif address ==  0xc595 then
		elseif address ==  0xffd3 then
			return iocs_0d_ffd3();
		elseif address ==  0xc442 then
		elseif address ==  0xffd6 then
			return iocs_0d_ffd6();
		elseif address ==  0xc4cb then
		elseif address ==  0xffd9 then
			return iocs_0d_ffd9();
		end
		--break;
	elseif page == 0x0e then
		--switch(address) {
		if 	   address ==  0xca08 then
		elseif address ==  0xffca then
			return iocs_0e_ffca();
		elseif address ==  0xc92e then
		elseif address ==  0xffa3 then
			return iocs_0e_ffa3();
		end
		--break;
	end

	return 1000;
end

--割り込み先 (PC-G850専用) (subroutineの下請け)
--private int iocs_bc37()
local function iocs_bc37()
	hlt = false;
	iff = 0x03;
	interruptMask = 0x0f;

	return 1000;
end

--押されている按键のASCIIコードを得る(waitあり) (PC-G850専用) (subroutineの下請け)
--private int iocs_bcc4()
local function iocs_bcc4()
	--int key;
	key = keyToAscii(getKeyWait(), true)
	if(key  == GKEY_NONE) then
		return 0;
	end
	a.set(key);
	f.set(0x01 | destroy8());
	b.set(0);
	c.set(destroy8());
	hl.set(destroy16());
	bc_d.set(destroy16());
	de_d.set(destroy16());
	hl_d.set(destroy16());
	return 100000;
end

--押されている按键を得る(waitなし) (subroutineの下請け)
--private int iocs_be53()
local function iocs_be53()
	local key = getKey();

	a.set(key);
	if(key ~= 0) then
		f.set(destroy8() | 0x01);
		b.set(destroy8());
	else
		f.set(destroy8() & ~0x01);
	end

	bc_d.set(destroy16());
	de_d.set(destroy16());
	hl_d.set(destroy16());

	--switch(machine) {
	
	if machine ==  MACHINE_E200 then
	elseif machine == MACHINE_G815 then
		return 18000;
	elseif machine ==  MACHINE_G850 then
	else
		return 30000;
	end
end

--按键コードをASCIIコードに変換する (subroutineの下請け)
--private int iocs_be56()
local function iocs_be56()
	if((read8(0x78f0) & 0x08) ~= 0) then
		b.set(a.get());
		f.set(0x10);
	else
		a.set(keyToAscii(a.get(), (read8(0x7901) & 0x02) ~= 0));
		f.set(0x44);
	end

	return 500;
end

--1文字表示する(記号を含む) (subroutineの下請け)
--private int iocs_be5f()
local function iocs_be5f()
	if(e.get() >= vramCols or d.get() >= vramRows) then
		return 100;
	end
	putChar(e.get(), d.get(), a.get());

	af.set(destroy16());
	b.set(0);
	c.set(destroy8());
	hl.set(destroy16());
	return 1800;
end

--1文字表示する(記号を含まない) (subroutineの下請け)
--private int iocs_be62()
local function iocs_be62()
	if(e.get() >= vramCols or d.get() >= vramRows) then
		return 100;
	end

	putChar(e.get(), d.get(), (a.get() > 0x20 and {a.get()} or {0x20})[1]);

	af.set(destroy16());
	b.set(0);
	c.set(destroy8());
	hl.set(destroy16());
	return 1800;
end

--下にスクロールする (subroutineの下請け)
--private int iocs_be65()
local function iocs_be65()
	if(e.get() >= vramCols or d.get() >= vramRows) then
		return 100;
	end

	scrollDown(e.get(), d.get());

	af.set(destroy16());
	bc.set(0);
	de.set(destroy16());
	hl.set(destroy16());
	return 5000;
end

--押されている按键を得る(waitあり) (subroutineの下請け)
--private int iocs_bcfd()
local function iocs_bcfd()
	--int key;
	local key = getKeyWait()
	if(key  == GKEY_NONE) then
		return 0;
	end

	a.set(key);
	f.set(destroy8() | 0x01);
	bc_d.set(destroy16());
	de_d.set(destroy16());
	hl_d.set(destroy16());
	return 20000;
end

--16進数2桁の按键入力を得る (subroutineの下請け)
--private int iocs_bd09()
local function iocs_bd09() 
	return 100000;
end

--16進数4桁の按键入力を得る (subroutineの下請け)
--private int iocs_bd0f()
local function iocs_bd0f()
	return 100000;
end

--パターンを表示する (subroutineの下請け)
--private int iocs_bfd0()
local function iocs_bfd0()
	--int n, state;

	if(e.get() >= vramCols or d.get() >= vramRows or b.get() == 0) then
		return 100;
	end

	n = e.get() + b.get() / cellWidth;
	n = (n < vramCols and {n} or {vramCols})[1];
	putPattern(e.get(), d.get(), hl.get(), b.get());

	state = 100 + 170 * b.get();
	a.set(read8(hl.get()));
	e.set(e.get() + b.get());
	hl.set(hl.get() + b.get() - 1);
	b.set(0);
	f.set(destroy8());
	return state;
end

--上にスクロールする (subroutineの下請け)
--private int iocs_bfeb()
local function iocs_bfeb()
	scrollUp();

	af.set(0x0044);
	b.set(0);
	hl.set(destroy16());
	return 5000;
end

--n個の文字を表示する (subroutineの下請け)
--private int iocs_bfee()
local function iocs_bfee()
	--int state;

	if(e.get() >= vramCols or d.get() >= vramRows or b.get() == 0) then
		return 100;
	end

	state = 100 + 1800 * b.get();

	putCharFirst(e.get(), d.get(), a.get());
	while (b.add(-1) ~= 0) do
		putCharNext(a.get());
	end
	a.set(0);
	f.set(destroy8());
	hl.set(destroy16());
	return state;
end

--文字列を表示する (subroutineの下請け)
--private int iocs_bff1()
local function iocs_bff1()
--	int state;

	if(e.get() >= vramCols or d.get() >= vramRows or b.get() == 0) then
		return 100;
	end

	state = 100 + 1800 * b.get();

	c.set(0);
	putCharFirst(e.get(), d.get(), read8(hl.get()));
	while (b.add(-1) ~= 0) do
		if(putCharNext(read8(hl.add(1)))) then
			c.add(1);
		end
	end

	af.set(destroy16());
	return state;
end

--起動する (subroutineの下請け)
--private int iocs_bff4()
local function iocs_bff4()
	setMode(G8xx.MODE_MENU);
	return 0;
end

--電源を切る (subroutineの下請け)
--private int iocs_c110()
local function iocs_c110()
	off();
	return 0;
end

--IOCSをエミュレートする (オーバーライド)
--@Override public int subroutine(int address)
function subroutine(address)
	if(romBanks > 0) then
		return -1;
	end
	if(address < 0x8000) then
		return -1;
	end

	--switch(address) {
	if address == 0x0030 then
		return iocs_bd03();
	elseif address == 0xbcfd then
		return iocs_bcfd();
	elseif address == 0xbe53 then
		return iocs_be53();
	elseif address == 0xbe56 then
		return iocs_be56();
	elseif address == 0xbe5f then
		return iocs_be5f();
	elseif address == 0xbe62 then
		return iocs_be62();
	elseif address == 0xbe65 then
		return iocs_be65();
	elseif address == 0xbd03 then
		return iocs_bd03();
	elseif address == 0xbd09 then
		return iocs_bd09();
	elseif address == 0xbd0f then
		return iocs_bd0f();
	elseif address == 0xbfd0 then
		return iocs_bfd0();
	elseif address == 0xbfeb then
		return iocs_bfeb();
	elseif address == 0xbfee then
		return iocs_bfee();
	elseif address == 0xbff1 then
		return iocs_bff1();
	elseif address == 0xbff4 then
		return iocs_bff4();
	elseif address == 0xc110 then
		return iocs_c110();
	end

	--switch(machine) {
	if machine == MACHINE_E200 then
		--break;
	elseif machine == MACHINE_G815 then
		--switch(address) {
		if address == 0x93cd then
		elseif address == 0x9490 then
			return iocs_9490();
		end
		--break;
	elseif machine == MACHINE_G850 then
		--switch(address) {
		if  address == 0x8aad then
			return iocs_8aad();
		elseif address == 0x93cb then
		elseif address == 0x93cd then
		elseif address == 0xbb6b then
			return iocs_bb6b();
		elseif address == 0xbc37 then
			return iocs_bc37();
		elseif address == 0xbcc4 then
			return iocs_bcc4();
		end
		--break;
	end

	return 1000;
end

--1周期分実行する
--public void run()
function run()
	--int x, y, i, col, row, mask, screenx, screeny;
	--boolean dot;

	if(mode == G8xx.MODE_EMULATOR) then
	-- コードを実行する 		
		execute(cpuClocks / fps);
	
		-- 按键割り込み 		
		if(intIA) then
			if((interruptMask & INTERRUPT_IA) ~= 0) then
				--interruptType |= INTERRUPT_IA;
				interruptType = interruptType | INTERRUPT_IA;
				int1();
			end
			intIA = false;
		end

		-- 按键割り込み(BREAK按键) 			
		if(intKON)  then
			if((interruptMask & INTERRUPT_KON) ~= 0) then
				--interruptType |= INTERRUPT_KON;
				interruptType = interruptType | INTERRUPT_KON;
				int1();
			end
			intKON = false;
		end

		-- タイマ割り込み
		timerCount = timerCount - 1 		
		if(timerCount <= 0) then
			timerCount = fps * timerInterval / 1000 / 1000;

			if((interruptMask & INTERRUPT_1S) ~= 0) then
				timer = time ~ 0x01;
				--interruptType |= INTERRUPT_1S;
				interruptType = interruptType | INTERRUPT_1S;
				int1();
			end
		end

		-- リセット 			
		if(keyReset) then
			boot()
		end
	end

	-- LCDを更新する 		
	--switch(machine) {
	if machine == MACHINE_E200 then

	elseif machine == MACHINE_G815 then
		screenx = 0;
		x = screenx
		for row = 0, lcdRows, 1 do
			for col = 0, lcdCols, 1 do
				--for(y = row * cellHeight, screeny = row * 8, mask = 0x01; y < row * cellHeight + cellHeight; y++, screeny++, mask <<= 1) {
				screeny = row * 8
				mask = 0x01
				for y = row * cellHeight, row * cellHeight + cellHeight-1, 1  do
					screeny = screeny + 1
					mask = mask << 1
					--for(x = col * cellWidth, screenx = col * 6; x < col * cellWidth + cellWidth; x++, screenx++) {
					screenx = col * 6
					for x = col * cellWidth, col * cellWidth + cellWidth-1, 1  do						
						--screenx = col * 6
						screenx = screenx + 1	
						dot = (vram[vramOffset(x, row)] & mask) ~= 0;
						lcdChanged[screeny][screenx] = (dot & ~lcdPattern[0][screeny][screenx])
						if (lcdChanged[screeny][screenx] or (~dot and lcdPattern[0][screeny][screenx]) or first) then
							lcdPattern[0][screeny][screenx] = dot;
							lcdScale[screeny][screenx] = (dot and {1} or {0})[1];
						end
					end
				end
			end
		end

		for y = 0, 64-1, 1 do
			row = (y + lcdTop) / 8;
			mask = 1 << ((y + lcdTop) % 8);
			x = vramWidth - 1;
			screenx = lcdCols * 6;

			dot = (vram[vramOffset(x, row)] & mask) ~= 0;
			lcdChanged[y][screenx] = (dot & ~lcdPattern[0][y][screenx])
			if(lcdChanged[y][screenx] or (~dot and lcdPattern[0][y][screenx]) or first) then
				lcdPattern[0][y][screenx] = dot;
				lcdScale[y][screenx] = (dot and {1} or {0})[1];
			end
		end
		--break;
	elseif machine == MACHINE_G850 then
		if(lcdEffectBlack) then
			for y = 0, lcdHeight-1, 1 do
				for x = 0, vramWidth-1, 1 do
					lcdChanged[y][x] = ~lcdPattern[0][y][x]
					if(lcdChanged[y][x]) then
						lcdPattern[0][y][x] = true;
						lcdScale[y][x] = 1;
					end
				end
			end
		elseif(lcdEffectWhite) then
			for y = 0, lcdHeight-1, 1 do
				for x = 0, vramWidth-1, 1 do
					lcdChanged[y][x] = lcdPattern[0][y][x]
					if (lcdChanged[y][x]) then
						lcdPattern[0][y][x] = false;
						lcdScale[y][x] = 0;
					end
				end
			end
		else
			for y = 0, lcdHeight-1, 1 do
				row = (y + lcdTop) / 8;
				mask = 1 << ((y + lcdTop) % 8);

				for x = 0, vramWidth-1, 1  do
					dot = ((vram[vramOffset(x, row)] & mask) == 0 and {lcdEffectReverse} or {~lcdEffectReverse})[1];
					lcdChanged[y][x] = (dot and ~lcdPattern[0][y][x]) or (~dot and lcdPattern[0][y][x]) or first
					if (lcdChanged[y][x]) then
						lcdPattern[0][y][x] = dot;
						lcdScale[y][x] = (dot and {1} or {0})[1];
					end
				end
			end
		--break;
		end
	end

	-- ブザー出力を更新する 				
	System.arraycopy(wave0, 0, wave, 0, wave0.length); Arrays.fill(wave0, 0, wave0.length - 1, wave0[wave0.length - 1]);
	
	-- LCDの残像をエミュレートする 		
	if(lcdScales <= 2) then
		first = false;
		return;
	end

	for y = 0, lcdHeight-1, 1 do
		for x = 0, vramWidth-1, 1 do
			if(lcdPattern[0][y][x]) then
				lcdCount[y][x] = lcdCount[y][x] + 1;
			end
			if(lcdPattern[lcdPages - 1][y][x]) then
				lcdCount[y][x] = lcdCount[y][x] - 1
			end
			lcdScale[y][x] = (lcdCount[y][x] * (lcdScales - 1) + lcdPages / 2) / lcdPages;
			lcdChanged[y][x] = (lcdScale[y][x] ~= lcdScalePrev[y][x]) or first;

			lcdScalePrev[y][x] = lcdScale[y][x];
		end
	end
	
	for i = lcdPages - 1,  0-1, -1 do
		for y = 0, lcdHeight-1, 1 do
			for x = 0, vramWidth-1, 1 do
				lcdPattern[i][y][x] = lcdPattern[i - 1][y][x];
			end
		end
	end
	first = false;
end

--ブートをエミュレートする
--public void boot()
function boot()
	if(rom[0] ~= nil) then
		mode = G8xx.MODE_EMULATOR;
		System.arraycopy(rom[0], 0, memory, 0x8000, rom[0].length);
		System.arraycopy(rom[0], 0, memory, 0xc000, rom[0].length);
	else 
		mode = G8xx.MODE_MENU;
		Arrays.fill(memory, 0x8000, 0x8000, 0xff);
	end

	System.arraycopy(base, 0, memory, 0, base.length);

	reset();

	sp.set(0x7ff6);

	outport(0x11, 0);
	outport(0x12, 0);
	outport(0x14, 0);
	outport(0x15, 1);
	outport(0x16, 0xff);
	outport(0x17, 0xf);
	outport(0x18, 0);
	outport(0x19, 0);
	outport(0x1b, 0);
	outport(0x1c, 1);
	timerInterval = 388643;
	im = 1;
	write8(0x790d, 0);

	--switch(machine) {
	if machine == MACHINE_E200 then
		outport(0x58, 0xc0);
		--break;
	elseif machine ==  MACHINE_G815 then
		outport(0x50, 0xc0);
		--break;
	elseif machine == MACHINE_G850 then
		if(read8(0x779c) < 0x07 or read8(0x779c) > 0x1f) then
			write8(0x779c, 0x1f);
		end
		outport(0x40, 0x24);
		outport(0x40, read(0x790d) + 0x40);
		outport(0x40, read(0x779c) + 0x80);
		outport(0x40, 0xa0);
		outport(0x40, 0xa4);
		outport(0x40, 0xa6);
		outport(0x40, 0xa9);
		outport(0x40, 0xaf);
		outport(0x40, 0xc0);
		outport(0x40, 0x25);
		outport(0x60, 0);
		outport(0x61, 0xff);
		outport(0x62, 0);
		outport(0x64, 0);
		outport(0x65, 1);
		outport(0x66, 1);
		outport(0x67, 0);
		outport(0x6b, 4);
		outport(0x6c, 0);
		outport(0x6d, 0);
		outport(0x6e, 4);
		--break;
	end

	refreshLcd();
end

--電源をOFFにする
--public void off()
function off()
	hlt = true;
	iff = 0;
	ioReset = 0;
end

--電源OFFされたか?
--public boolean isOff()
function isOff()
	return hlt and iff == 0;
end

--按键を押した
--public void keyPress(int key)
function keyPress(key)
	if(GKEY_OFF <= key and key <= GKEY_CLS) then
		key = key - 1 ;
		if((keyMatrix[key / 8] & (1 << (key % 8))) ~= 0) then
			return;
		end
		intIA = true;
		keyMatrix[key / 8] = keyMatrix[key / 8] |  (1 << (key % 8));
	elseif(key == GKEY_BREAK) then
		if (keyBreak ~= 0) then
			return;
		end
		intKON = true;
		keyBreak = keyBreak | 0x80;
	elseif(key == GKEY_SHIFT) then
		keyShift = keyShift | 0x01;
	elseif(key == GKEY_RESET) then
		keyReset = true;
	end
end

--按键を離した
--public void keyRelease(int key)
function keyRelease(key)
	if(GKEY_OFF <= key and key <= GKEY_CLS) then
		key = key - 1;
		keyMatrix[key / 8] = keyMatrix[key / 8] & ~(1 << (key % 8));
	elseif(key == GKEY_BREAK) then
		keyBreak = keyBreak &  ~0x80;
	elseif(key == GKEY_SHIFT) then
		keyShift = keyShift  & ~0x01;
	elseif(key == GKEY_RESET) then
		keyReset = false;
	end
end

--LCDの横ドット数を得る
--public int getLcdWidth()
function getLcdWidth()
	if(machine == MACHINE_E200) then
		return lcdWidth + lcdCols;
	else
		return lcdWidth;
	end
end

--LCDの縦ドット数を得る
--public int getLcdHeight()
function getLcdHeight() 
	if(machine == MACHINE_E200) then
		return lcdHeight + lcdRows;
	else
		return lcdHeight;
	end
end

--LCDの階調数を得る
--public int getLcdScales()
function getLcdScales()
	return lcdScales;
end

--LCDの状態を得る
--public int getLcdScale(int x, int y)
function getLcdScale(x, y)						
	return lcdScale[y][x];
end

--LCDの状態が変わったか?
--public boolean isLcdChanged(int x, int y)
function  isLcdChanged(x, y)
	return lcdChanged[y][x];
end

--LCDが全て変わったことにする
--public void refreshLcd()
function refreshLcd()
	first = true;
end

--11ピン端子の状態を得る
--public int get11Pin()
function get11Pin()
	return
	((pin11Out & PIN11_OUT_FO2)  == 0 and {0} or {0x008})[1] | -- BUSY 		
	((pin11Out & PIN11_OUT_FO1)  == 0 and {0} or {0x010})[1] | -- Dout 		
	((pin11In  & PIN11_IN_XIN)   == 0 and {0} or {0x020})[1] | -- Xin 		
	((pin11Out & PIN11_OUT_XOUT) == 0 and {0} or {0x040})[1] | -- Xout 		
	((pin11In  & PIN11_IN_IB1)   == 0 and {0} or {0x080})[1] | -- Din 		
	((pin11In  & PIN11_IN_IB2)   == 0 and {0} or {0x100})[1];  -- ACK 	}
end

--波形を得る
--public final byte[] getWave()
function getWave()
	return wave;
end

--SIOモードを得る
--public int getSioMode()
function getSioMode()
	return sioMode;
end

--SIOモードを設定する
--public void setSioMode(int sio_mode)
function  setSioMode(sio_mode)
	sioMode = sio_mode;
	sioCount = 0;
end


--SIOから入力するファイルを得る
--public String getSioInfile()
function getSioInfile() 
	return sioInPathname;
end

		--SIOから入力するファイルを設定する
-- public void setSioInfile(String pathname)
function setSioInfile(pathname)
	sioInPathname = pathname;
end

--SIOへ出力するファイルを得る
--public String getSioOutfile()
function  getSioOutfile()
	return sioOutPathname;
end

--SIOへ出力するファイルを設定する
--public void setSioOutfile(String pathname)
function  setSioOutfile(pathname)
	sioBuffer = {}  --new byte[0x8000 * 10];
	sioOutPathname = pathname;
end

--SIOバッファを得る
--public byte[] getSioBuffer()
function getSioBuffer()
	return sioBuffer;
end

--SIOバッファの読み込み/書き込み位置を得る
--public int getSioPos()
function getSioPos() 
	if(sioMode == SIO_MODE_IN) then
		return sioCount / 14;
	elseif(sioMode == SIO_MODE_OUT) then
		return sioCount / 10;
	else
		return 0;
	end

end

--I/O更新周期を得る
--public int getFps()
function getFps()
	return fps;
end

--RAMのアドレスを得る
--public byte[] getRam()
function getRam() 
	return memory;
end

--ROMのアドレスを得る
--public byte[] getRom(int page)
function getRom(page)
	return rom[page];
end

--モードを得る
--public int getMode()
function getMode()
	return mode;
end

--モードを設定する
--public void setMode(int mode)
function setMode(mode)
	this.mode = mode;
end

--エミュレート対象の機種を得る
--public int getMachine()
function getMachine()
	return machine;
end

--CPUのクロック周波数を得る
--public int getCpuClocks()
function getCpuClocks()
	return cpuClocks;
end

--原点座標を設定する
--public void setOffset(int offset_x, int offset_y)
function setOffset(offset_x, offset_y)
	offsetX = offset_x;
	offsetY = offset_y;
end

--原点のX座標を得る
--public int getOffsetX()
function getOffsetX()
	return offsetX;
end

--原点のY座標を得る
--public int getOffsetY()
function getOffsetY()
	return offsetY;
end

--倍率を設定する
--public void setZoom(int zoom_x, int zoom_y)
function setZoom(zoom_x, zoom_y)
	zoomX = zoom_x;
	zoomY = zoom_y;
end

--X方向の倍率を得る
--public int getZoomX()
function getZoomX()
	return zoomX;
end

--Y方向の倍率を得る
--public int getZoomY()
function getZoomY()
	return zoomY;
end

--レイアウトを得る
--public Area getLayout(int index, int offset_x, int offset_y, int zoom_x, int zoom_y)
function Area:getLayout( index,  offset_x,  offset_y,  zoom_x,  zoom_y)
	-- Area area;
	local area = Area:init()
	area = layout[index][machine]
	if (area == nil) then
		return nil;
	end
	return Area:init(offset_x + area.x * zoom_x, offset_y + area.y * zoom_y, area.width * zoom_x, area.height * zoom_y, area.text, area.foreColor, area.backColor);
end

--レイアウトを得る
--public Area getLayout(int index)
function getLayout(index) 
	return getLayout(index, offsetX, offsetY, zoomX, zoomY);
end

--バイナリのROMイメージを読み込む
--public int readRom(InputStream in) throws IOException
function  readRom(inFile)
	--int page;

	if(inFile.read(base, 0, base.length) ~= base.length) then
		System.arraycopy(base, 0, memory, 0, base.length);
		return 0;
	end

	--for(page = 0;; page++) {
	for page = 0, 30, 1 do
		rom[page] = {}  --new byte[0x4000];
		
		--[[
		try {
			if(inFile.read(rom[page], 0, rom[page].length) != rom[page].length)
				break;
		} catch (IOException e) {
			break;
		}
		--]]
		func1 = function() if(inFile.read(rom[page], 0, rom[page].length) ~= rom[page].length) then  end end
	    func2 = function() end	
		tryCatch(func1, func2)
	end
	rom[page] = nil;
	romBanks = page;
	return romBanks;
end

--ROMイメージをバイナリで書き込む
--public void writeRom(OutputStream out) throws IOException
function writeRom(out)
	--int page;

	if(rom[0] == nil) then
		return;
	end

	out.write(base, 0, base.length);

	--for(page = 0; rom[page] != null; page++) {
	if rom[page] ~= nil then
		for page = 0, 30, 1 do
			out.write(rom[page], 0, rom[page].length);
		end
	end
end

--バイナリのRAMを読み込む
--public void readRam(InputStream in) throws IOException
function readRam(inFile)
	inFile.read(memory, 0, memory.length);
end

--RAMをバイナリで読み込む
--public void writeRam(OutputStream out) throws IOException
function writeRam(out)
	out.write(memory, 0, memory.length);
end


--ROMイメージファイルを1ページ読み込む (下請け)
--private int readRom1page(byte[] buf, String basename) throws Exception
function readRom1page(buf, base_name)
	--String file_name;

	file_name = base_name + ".txt";
	--if((new File(file_name)).exists()) then
	if (File(file_name)).exists() then
		return HexFile.readFileAbs(buf, file_name, 0x0000);
	else
		return BinFile.readFile(buf, base_name + ".bin");
	end
end

	--IntelHex形式のROMイメージファイルを読み込む (ファイル名)
--public int loadHexFileIntoRom(String dir_name) throws Exception
function loadHexFileIntoRom(dir_name)
	--int page;

	readRom1page(memory, dir_name + "/base");
	System.arraycopy(memory, 0, base, 0, 0x40);

	--for(page = 0;; page++) {
	--	rom[page] = new byte[0x4000];
	for page = 0, 40, 1  do
		rom[page] = {}
		--[[
		try {
			readRom1page(rom[page], dir_name + "/rom" + String.format("%02x", page));
		} catch (IOException e) {
			rom[page] = null;
			romBanks = page;
			return romBanks;
		}
		--]]
		func1 = function() readRom1page(rom[page], dir_name + "/rom" + String.format("%02x", page)); end
		func2 = function() rom[page] = nil; romBanks = page; return romBanks; end
		tryCatch(func1, func2)
	end
end

--IntelHex形式のファイルを読み込む (ファイル名) 
--public int loadHexFileIntoRam(String pathname) throws Exception
function loadHexFileIntoRam(pathname)
	return HexFile.readFile(memory, pathname);
end

--IntelHex形式のファイルを読み込む (URL) 
--public int loadHexURLIntoRam(String url) throws Exception
function loadHexURLIntoRam(url)
	return HexFile.readURL(memory, url);
end

--Zip圧縮されたIntelHex形式のファイルを読み込む (ファイル名) 
--public int loadZippedHexFileIntoRam(String zipname, String entryname) throws Exception
function loadZippedHexFileIntoRam(zipname, entryname)
	return HexFile.readZipFile(memory, zipname, entryname);
end

--Zip圧縮されたIntelHex形式のファイルを読み込む (URL) 
--public int loadZippedHexURLIntoRam(String url, String entryname) throws Exception
function loadZippedHexURLIntoRam(url, entryname)
	return HexFile.readZipURL(memory, url, entryname);

end

--]===]

--[[
	--- k6x8のライセンス ----------------------------------------------------------------------------------------------------------------	These fonts are free softwares.
	Unlimited permission is granted to use, copy, and distribute it, with or without modification, either commercially and noncommercially.
	THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.
	これらのフォントはフリー（自由な）ソフトウエアです。
	あらゆる改変の有無に関わらず、また商業的な利用であっても、自由にご利用、複製、再配布することができますが、全て無保証とさせていただきます。
	Copyright(C) 2000-2007 Num Kadoma
	-------------------------------------------------------------------------------------------------------------------------------------
	Copyright 2011~2017 maruhiro All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	1. Redistributions of source code must retain the above copyright notice,
	   this list of conditions and the following disclaimer.
	2. Redistributions in binary form must reproduce the above copyright notice,
	   this list of conditions and the following disclaimer in the documentation
	   and/or other materials provided with the distribution.
	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
-- eof -- 
--]]
