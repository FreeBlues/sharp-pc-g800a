package jp.gr.java_conf.ver0.z80.g800;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;

import jp.gr.java_conf.ver0.tool.BinFile;
import jp.gr.java_conf.ver0.tool.HexFile;
import jp.gr.java_conf.ver0.z80.Z80Emulator;

/*
	SHARP Pocket Computer PC-E200/G815/G850 Emulator
*/
public class G800Emulator extends Z80Emulator
{
	/*
		領域クラス
	*/
	public class Area {
		/*
			コンストラクタ
		*/
		Area(int x, int y, int width, int height)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.text = "";
		}

		/*
			コンストラクタ
		*/
		Area(int x, int y, int width, int height, String text)
		{
			this(x, y, width, height);
			this.text = text;
		}

		/*
			コンストラクタ
		*/
		Area(int x, int y, int width, int height, String text, int fore_color)
		{
			this(x, y, width, height, text);
			this.foreColor = fore_color;
		}

		/*
			コンストラクタ
		*/
		Area(int x, int y, int width, int height, String text, int fore_color, int back_color)
		{
			this(x, y, width, height, text, fore_color);
			this.backColor = back_color;
		}

		/* X座標 */
		public int x;

		/* Y座標 */
		public int y;

		/* 幅 */
		public int width;

		/* 高さ */
		public int height;

		/* 文字 */
		public String text;

		/* 前景色 */
		public int foreColor;

		/* 背景色 */
		public int backColor;
	}

	/* フォントパターン */
	static private final byte[][] font = {
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
	};

	/* キーコード -> ASCIIコード変換テーブル (大文字) */
	private final int[] keyToAsciiUpper = {
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
	};

	/* キーコード -> ASCIIコード変換テーブル (小文字) */
	private final int[] keyToAsciiLower = {
		0x00, 0x06, 0x71, 0x77, 0x65, 0x72, 0x74, 0x79,
		0x75, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68, 0x6a,
		0x6b, 0x7a, 0x78, 0x63, 0x76, 0x62, 0x6e, 0x6d,
		0x2c, 0x01, 0x02, 0x14, 0x11, 0x0a, 0x20, 0x1f,
		0x1e, 0x1d, 0x1c, 0x15, 0x30, 0x2e, 0x3d, 0x2b,
		0x0d, 0x6c, 0x3b, 0x17, 0x31, 0x32, 0x33, 0x2d,
		0x1a, 0x69, 0x6f, 0x12, 0x34, 0x35, 0x36, 0x2a,
		0x19, 0x70, 0x08, 0xfe, 0x37, 0x38, 0x39, 0x2f,
		0x29, 0xfe, 0xfe, 0xfe, 0xfe, 0x5e, 0x28, 0xfe
	};

	/* レイアウト */
	private final Area[][] layout = {
		{ new Area(  2,  81,  17, 16, "ON",    COLOR_WHITE, COLOR_GRAY),     new Area(  2,  81,  17, 16, "ON",    COLOR_WHITE,  COLOR_GRAY),     new Area(294,   7,  17, 16, "ON",    COLOR_WHITE,  COLOR_GRAY)     }, /* BREAKキー */
		{ new Area(  2,  97,  17, 16, "OFF",   COLOR_WHITE, COLOR_GRAY),     new Area(  2,  97,  17, 16, "OFF",   COLOR_WHITE,  COLOR_GRAY),     new Area(277,   7,  17, 16, "OFF",   COLOR_WHITE,  COLOR_GRAY)     }, /* OFFキー */
		{ new Area(189, 129,  22, 16, "ANS",   COLOR_WHITE, COLOR_GRAY),     new Area(189, 129,  22, 16, "ANS",   COLOR_WHITE,  COLOR_GRAY),     new Area(260,   7,  17, 16, "ANS",   COLOR_WHITE,  COLOR_GRAY)     }, /* ANSキー */
		{ new Area(189, 113,  22, 16, "CONST", COLOR_WHITE, COLOR_GRAY),     new Area(189, 113,  22, 16, "CONST", COLOR_WHITE,  COLOR_GRAY),     new Area(243,   7,  17, 16, "CONST", COLOR_WHITE,  COLOR_GRAY)     }, /* CONSTキー */
		{ new Area( 19, 113,  17, 16, "TEXT",  COLOR_WHITE, COLOR_GREEN),    new Area( 19, 113,  17, 16, "TEXT",  COLOR_LIGHTGREEN,  COLOR_GRAY),new Area(226,   7,  17, 16, "TEXT",  COLOR_WHITE,  COLOR_GREEN)    }, /* TEXTキー */
		{ new Area(  2, 113,  17, 16, "BASIC", COLOR_WHITE, COLOR_GREEN),    new Area(  2, 113,  17, 16, "BASIC", COLOR_LIGHTGREEN,  COLOR_GRAY),new Area(209,   7,  17, 16, "BASIC", COLOR_WHITE,  COLOR_GREEN)    }, /* BASICキー */
		{ new Area(297,  24,  17, 16, "CLS",   COLOR_WHITE, COLOR_RED),      new Area(297,  24,  17, 16, "CLS",   COLOR_LIGHTRED,    COLOR_GRAY),new Area(294,  24,  17, 16, "CLS",   COLOR_WHITE,  COLOR_RED)      }, /* CLSキー */
		{ new Area(280,  24,  17, 16, "F-E",   COLOR_WHITE, COLOR_DARKGRAY), new Area(280,  24,  17, 16, "F-E",   COLOR_WHITE,  COLOR_GRAY),     new Area(277,  24,  17, 16, "F-E",   COLOR_WHITE,  COLOR_GRAY)     }, /* F←→Eキー */
		{ new Area(263,  24,  17, 16, "tan",   COLOR_WHITE, COLOR_DARKGRAY), new Area(263,  24,  17, 16, "tan",   COLOR_WHITE,  COLOR_GRAY),     new Area(260,  24,  17, 16, "tan",   COLOR_WHITE,  COLOR_GRAY)     }, /* tanキー */
		{ new Area(246,  24,  17, 16, "cos",   COLOR_WHITE, COLOR_DARKGRAY), new Area(246,  24,  17, 16, "cos",   COLOR_WHITE,  COLOR_GRAY),     new Area(243,  24,  17, 16, "cos",   COLOR_WHITE,  COLOR_GRAY)     }, /* cosキー */
		{ new Area(229,  24,  17, 16, "sin",   COLOR_WHITE, COLOR_DARKGRAY), new Area(229,  24,  17, 16, "sin",   COLOR_WHITE,  COLOR_GRAY),     new Area(226,  24,  17, 16, "sin",   COLOR_WHITE,  COLOR_GRAY)     }, /* sinキー */
		{ new Area(212,  24,  17, 16, "2ndF",  COLOR_BLACK, COLOR_YELLOW),   new Area(212,  24,  17, 16, "2ndF",  COLOR_LIGHTYELLOW, COLOR_GRAY),new Area(209,  24,  17, 16, "2ndF",  COLOR_WHITE,  COLOR_YELLOW)   }, /* 2ndFキー */
		{ new Area(297,  40,  17, 16, "MDF",   COLOR_WHITE, COLOR_DARKGRAY), new Area(297,  40,  17, 16, "MDF",   COLOR_WHITE,  COLOR_GRAY),     new Area(294,  40,  17, 16, "MDF",   COLOR_WHITE,  COLOR_GRAY)     }, /* MDFキー */
		{ new Area(280,  40,  17, 16, "1/x",   COLOR_WHITE, COLOR_DARKGRAY), new Area(280,  40,  17, 16, "1/x",   COLOR_WHITE,  COLOR_GRAY),     new Area(277,  40,  17, 16, "1/x",   COLOR_WHITE,  COLOR_GRAY)     }, /* 1/xキー */
		{ new Area(263,  40,  17, 16, "log",   COLOR_WHITE, COLOR_DARKGRAY), new Area(263,  40,  17, 16, "log",   COLOR_WHITE,  COLOR_GRAY),     new Area(260,  40,  17, 16, "log",   COLOR_WHITE,  COLOR_GRAY)     }, /* logキー */
		{ new Area(246,  40,  17, 16, "ln",    COLOR_WHITE, COLOR_DARKGRAY), new Area(246,  40,  17, 16, "ln",    COLOR_WHITE,  COLOR_GRAY),     new Area(243,  40,  17, 16, "ln",    COLOR_WHITE,  COLOR_GRAY)     }, /* lnキー */
		{ new Area(229,  40,  17, 16, "→DEG", COLOR_WHITE, COLOR_DARKGRAY), new Area(229,  40,  17, 16, "→DEG", COLOR_WHITE,  COLOR_GRAY),     new Area(226,  40,  17, 16, "→DEG", COLOR_WHITE,  COLOR_GRAY)     }, /* →DEGキー */
		{ new Area(212,  40,  17, 16, "nPr",   COLOR_WHITE, COLOR_DARKGRAY), new Area(212,  40,  17, 16, "nPr",   COLOR_WHITE,  COLOR_GRAY),     new Area(209,  40,  17, 16, "nPr",   COLOR_WHITE,  COLOR_GRAY)     }, /* nPrキー */
		{ new Area(297,  56,  17, 16, ")",     COLOR_WHITE, COLOR_DARKGRAY), new Area(297,  56,  17, 16, ")",     COLOR_WHITE,  COLOR_GRAY),     new Area(294,  56,  17, 16, ")",     COLOR_WHITE,  COLOR_GRAY)     }, /* )キー */
		{ new Area(280,  56,  17, 16, "(",     COLOR_WHITE, COLOR_DARKGRAY), new Area(280,  56,  17, 16, "(",     COLOR_WHITE,  COLOR_GRAY),     new Area(277,  56,  17, 16, "(",     COLOR_WHITE,  COLOR_GRAY)     }, /* (キー */
		{ new Area(263,  56,  17, 16, "^",     COLOR_WHITE, COLOR_DARKGRAY), new Area(263,  56,  17, 16, "^",     COLOR_WHITE,  COLOR_GRAY),     new Area(260,  56,  17, 16, "^",     COLOR_WHITE,  COLOR_GRAY)     }, /* ^キー */
		{ new Area(246,  56,  17, 16, "x^2",   COLOR_WHITE, COLOR_DARKGRAY), new Area(246,  56,  17, 16, "x^2",   COLOR_WHITE,  COLOR_GRAY),     new Area(243,  56,  17, 16, "x^2",   COLOR_WHITE,  COLOR_GRAY)     }, /* x^2キー */
		{ new Area(229,  56,  17, 16, "√",    COLOR_WHITE, COLOR_DARKGRAY), new Area(229,  56,  17, 16, "√",    COLOR_WHITE,  COLOR_GRAY),     new Area(226,  56,  17, 16, "√",    COLOR_WHITE,  COLOR_GRAY)     }, /* √キー */
		{ new Area(212,  56,  17, 16, "π",    COLOR_WHITE, COLOR_DARKGRAY), new Area(212,  56,  17, 16, "π",    COLOR_WHITE,  COLOR_GRAY),     new Area(209,  56,  17, 16, "π",    COLOR_WHITE,  COLOR_GRAY)     }, /* πキー */
		{ new Area(295,  73,  21, 18, "R・CM", COLOR_BLUE,  COLOR_DARKGRAY), new Area(295,  73,  21, 18, "R・CM", COLOR_WHITE,  COLOR_DARKGRAY), new Area(292,  73,  21, 18, "R・CM", COLOR_WHITE,  COLOR_DARKGRAY) }, /* R・CMキー */
		{ new Area(274,  73,  21, 18, "/",     COLOR_WHITE, COLOR_DARKGRAY), new Area(274,  73,  21, 18, "/",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(271,  73,  21, 18, "/",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* /キー */
		{ new Area(253,  73,  21, 18, "9",     COLOR_WHITE, COLOR_DARKGRAY), new Area(253,  73,  21, 18, "9",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(250,  73,  21, 18, "9",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 9キー */
		{ new Area(232,  73,  21, 18, "8",     COLOR_WHITE, COLOR_DARKGRAY), new Area(232,  73,  21, 18, "8",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(229,  73,  21, 18, "8",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 8キー */
		{ new Area(211,  73,  21, 18, "7",     COLOR_WHITE, COLOR_DARKGRAY), new Area(211,  73,  21, 18, "7",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(208,  73,  21, 18, "7",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 7キー */
		{ new Area(295,  91,  21, 18, "M+",    COLOR_BLUE,  COLOR_DARKGRAY), new Area(295,  91,  21, 18, "M+",    COLOR_WHITE,  COLOR_DARKGRAY), new Area(292,  91,  21, 18, "M+",    COLOR_WHITE,  COLOR_DARKGRAY) }, /* M+キー */
		{ new Area(274,  91,  21, 18, "*",     COLOR_WHITE, COLOR_DARKGRAY), new Area(274,  91,  21, 18, "*",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(271,  91,  21, 18, "*",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* *キー */
		{ new Area(253,  91,  21, 18, "6",     COLOR_WHITE, COLOR_DARKGRAY), new Area(253,  91,  21, 18, "6",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(250,  91,  21, 18, "6",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 6キー */
		{ new Area(232,  91,  21, 18, "5",     COLOR_WHITE, COLOR_DARKGRAY), new Area(232,  91,  21, 18, "5",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(229,  91,  21, 18, "5",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 5キー */
		{ new Area(211,  91,  21, 18, "4",     COLOR_WHITE, COLOR_DARKGRAY), new Area(211,  91,  21, 18, "4",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(208,  91,  21, 18, "4",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 4キー */
		{ new Area(295, 109,  21, 36, "",      COLOR_WHITE, COLOR_DARKGRAY), new Area(295, 109,  21, 36, "",      COLOR_WHITE,  COLOR_DARKGRAY), new Area(292, 109,  21, 36, "",      COLOR_WHITE,  COLOR_DARKGRAY) }, /* RETURNキー(テンキー側) */
		{ new Area(274, 109,  21, 18, "-",     COLOR_WHITE, COLOR_DARKGRAY), new Area(274, 109,  21, 18, "-",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(271, 109,  21, 18, "-",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* -キー */
		{ new Area(253, 109,  21, 18, "3",     COLOR_WHITE, COLOR_DARKGRAY), new Area(253, 109,  21, 18, "3",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(250, 109,  21, 18, "3",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 3キー */
		{ new Area(232, 109,  21, 18, "2",     COLOR_WHITE, COLOR_DARKGRAY), new Area(232, 109,  21, 18, "2",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(229, 109,  21, 18, "2",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 2キー */
		{ new Area(211, 109,  21, 18, "1",     COLOR_WHITE, COLOR_DARKGRAY), new Area(211, 109,  21, 18, "1",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(208, 109,  21, 18, "1",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 1キー */
		{ new Area(274, 127,  21, 18, "+",     COLOR_WHITE, COLOR_DARKGRAY), new Area(274, 127,  21, 18, "+",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(271, 127,  21, 18, "+",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* +キー */
		{ new Area(253, 127,  21, 18, "Exp",   COLOR_WHITE, COLOR_DARKGRAY), new Area(253, 127,  21, 18, "=",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(250, 127,  21, 18, "=",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* =キー */
		{ new Area(232, 127,  21, 18, ".",     COLOR_WHITE, COLOR_DARKGRAY), new Area(232, 127,  21, 18, ".",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(229, 127,  21, 18, ".",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* .キー */
		{ new Area(211, 127,  21, 18, "0",     COLOR_WHITE, COLOR_DARKGRAY), new Area(211, 127,  21, 18, "0",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(208, 127,  21, 18, "0",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* 0キー */
		{ new Area(192,  81,  19, 16, "BS",    COLOR_WHITE, COLOR_GRAY),     new Area(192,  81,  19, 16, "BS",    COLOR_WHITE,  COLOR_GRAY),     new Area(189,  81,  19, 16, "BS",    COLOR_WHITE,  COLOR_GRAY)     }, /* BSキー */
		{ new Area(175,  81,  17, 16, "P",     COLOR_WHITE, COLOR_DARKGRAY), new Area(175,  81,  17, 16, "P",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(172,  81,  17, 16, "P",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Pキー */
		{ new Area(158,  81,  17, 16, "O",     COLOR_WHITE, COLOR_DARKGRAY), new Area(158,  81,  17, 16, "O",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(155,  81,  17, 16, "O",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Oキー */
		{ new Area(141,  81,  17, 16, "I",     COLOR_WHITE, COLOR_DARKGRAY), new Area(141,  81,  17, 16, "I",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(138,  81,  17, 16, "I",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Iキー */
		{ new Area(124,  81,  17, 16, "U",     COLOR_WHITE, COLOR_DARKGRAY), new Area(124,  81,  17, 16, "U",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(121,  81,  17, 16, "U",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Uキー */
		{ new Area(107,  81,  17, 16, "Y",     COLOR_WHITE, COLOR_DARKGRAY), new Area(107,  81,  17, 16, "Y",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(104,  81,  17, 16, "Y",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Yキー */
		{ new Area( 90,  81,  17, 16, "T",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 90,  81,  17, 16, "T",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 87,  81,  17, 16, "T",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Tキー */
		{ new Area( 73,  81,  17, 16, "R",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 73,  81,  17, 16, "R",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 70,  81,  17, 16, "R",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Rキー */
		{ new Area( 56,  81,  17, 16, "E",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 56,  81,  17, 16, "E",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 53,  81,  17, 16, "E",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Eキー */
		{ new Area( 39,  81,  17, 16, "W",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 39,  81,  17, 16, "W",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 36,  81,  17, 16, "W",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Wキー */
		{ new Area( 22,  81,  17, 16, "Q",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 22,  81,  17, 16, "Q",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 19,  81,  17, 16, "Q",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Qキー */
		{ new Area( 67, 129,  20, 16, "TAB",   COLOR_WHITE, COLOR_GRAY),     new Area( 67, 129,  20, 16, "TAB",   COLOR_WHITE,  COLOR_GRAY),     new Area(  2,  81,  17, 16, "TAB",   COLOR_WHITE,  COLOR_GRAY)     }, /* TABキー */
		{ null,                                                 null,                                                                            new Area(186,  97,  22, 32, "",      COLOR_WHITE,  COLOR_GRAY)     }, /* RETURNキー(アルファベットキー側) */
		{ new Area(172, 113,  17, 16, ";",     COLOR_WHITE, COLOR_GRAY),     new Area(172, 113,  17, 16, ";",     COLOR_WHITE,  COLOR_GRAY),     new Area(176,  97,  17, 16, ";",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* ;キー */
		{ new Area(162,  97,  17, 16, "L",     COLOR_WHITE, COLOR_DARKGRAY), new Area(162,  97,  17, 16, "L",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(159,  97,  17, 16, "L",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Lキー */
		{ new Area(145,  97,  17, 16, "K",     COLOR_WHITE, COLOR_DARKGRAY), new Area(145,  97,  17, 16, "K",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(142,  97,  17, 16, "K",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Kキー */
		{ new Area(128,  97,  17, 16, "J",     COLOR_WHITE, COLOR_DARKGRAY), new Area(128,  97,  17, 16, "J",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(125,  97,  17, 16, "J",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Jキー */
		{ new Area(111,  97,  17, 16, "H",     COLOR_WHITE, COLOR_DARKGRAY), new Area(111,  97,  17, 16, "H",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(108,  97,  17, 16, "H",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Hキー */
		{ new Area( 94,  97,  17, 16, "G",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 94,  97,  17, 16, "G",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 91,  97,  17, 16, "G",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Gキー */
		{ new Area( 77,  97,  17, 16, "F",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 77,  97,  17, 16, "F",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 74,  97,  17, 16, "F",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Fキー */
		{ new Area( 60,  97,  17, 16, "D",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 60,  97,  17, 16, "D",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 57,  97,  17, 16, "D",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Dキー */
		{ new Area( 43,  97,  17, 16, "S",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 43,  97,  17, 16, "S",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 40,  97,  17, 16, "S",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Sキー */
		{ new Area( 26,  97,  17, 16, "A",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 26,  97,  17, 16, "A",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 23,  97,  17, 16, "A",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Aキー */
		{ new Area( 33, 129,  17, 16, "CAPS",  COLOR_WHITE, COLOR_GRAY),     new Area( 33, 129,  17, 16, "CAPS",  COLOR_WHITE,  COLOR_GRAY),     new Area(  2,  97,  21, 16, "CAPS",  COLOR_WHITE,  COLOR_GRAY)     }, /* CAPSキー */
		{ new Area(138, 129,  17, 16, "↑",    COLOR_WHITE, COLOR_GRAY),     new Area(138, 129,  17, 16, "↑",    COLOR_WHITE,  COLOR_GRAY),     new Area(169, 113,  17, 16, "↑",    COLOR_WHITE,  COLOR_GRAY)     }, /* ↑キー */
		{ new Area(155, 113,  17, 16, ",",     COLOR_WHITE, COLOR_GRAY),     new Area(155, 113,  17, 16, ",",     COLOR_WHITE,  COLOR_GRAY),     new Area(152, 113,  17, 16, ",",     COLOR_WHITE,  COLOR_GRAY)     }, /* ,キー */
		{ new Area(138, 113,  17, 16, "M",     COLOR_WHITE, COLOR_DARKGRAY), new Area(138, 113,  17, 16, "M",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(135, 113,  17, 16, "M",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Mキー */
		{ new Area(121, 113,  17, 16, "N",     COLOR_WHITE, COLOR_DARKGRAY), new Area(121, 113,  17, 16, "N",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(118, 113,  17, 16, "N",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Nキー */
		{ new Area(104, 113,  17, 16, "B",     COLOR_WHITE, COLOR_DARKGRAY), new Area(104, 113,  17, 16, "B",     COLOR_WHITE,  COLOR_DARKGRAY), new Area(101, 113,  17, 16, "B",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Bキー */
		{ new Area( 87, 113,  17, 16, "V",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 87, 113,  17, 16, "V",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 84, 113,  17, 16, "V",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Vキー */
		{ new Area( 70, 113,  17, 16, "C",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 70, 113,  17, 16, "C",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 67, 113,  17, 16, "C",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Cキー */
		{ new Area( 53, 113,  17, 16, "X",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 53, 113,  17, 16, "X",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 50, 113,  17, 16, "X",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Xキー */
		{ new Area( 36, 113,  17, 16, "Z",     COLOR_WHITE, COLOR_DARKGRAY), new Area( 36, 113,  17, 16, "Z",     COLOR_WHITE,  COLOR_DARKGRAY), new Area( 33, 113,  17, 16, "Z",     COLOR_WHITE,  COLOR_DARKGRAY) }, /* Zキー */
		{ new Area(  2, 129,  31, 16, "SHIFT", COLOR_BLACK, COLOR_YELLOW)  , new Area(  2, 129,  31, 16, "SHIFT", COLOR_LIGHTYELLOW, COLOR_GRAY),new Area(  2, 113,  31, 16, "SHIFT", COLOR_WHITE,  COLOR_YELLOW)   }, /* SHIFTキー */
		{ new Area(172, 129,  17, 16, "→",    COLOR_WHITE, COLOR_GRAY),     new Area(172, 129,  17, 16, "→",    COLOR_WHITE,  COLOR_GRAY),     new Area(186, 129,  17, 16, "→",    COLOR_WHITE,  COLOR_GRAY)     }, /* →キー */
		{ new Area(121, 129,  17, 16, "↓",    COLOR_WHITE, COLOR_GRAY),     new Area(121, 129,  17, 16, "↓",    COLOR_WHITE,  COLOR_GRAY),     new Area(169, 129,  17, 16, "↓",    COLOR_WHITE,  COLOR_GRAY)     }, /* ↓キー */
		{ new Area(155, 129,  17, 16, "←",    COLOR_WHITE, COLOR_GRAY),     new Area(155, 129,  17, 16, "←",    COLOR_WHITE,  COLOR_GRAY),     new Area(152, 129,  17, 16, "←",    COLOR_WHITE,  COLOR_GRAY)     }, /* ←キー */
		{ new Area(189,  97,  22, 16, "INS",   COLOR_WHITE, COLOR_GRAY),     new Area(189,  97,  22, 16, "INS",   COLOR_WHITE,  COLOR_GRAY),     new Area(135, 129,  17, 16, "INS",   COLOR_WHITE,  COLOR_GRAY)     }, /* INSキー */
		{ new Area( 87, 129,  34, 16, "SPACE", COLOR_WHITE, COLOR_DARKGRAY), new Area( 87, 129,  34, 16, "SPACE", COLOR_WHITE,  COLOR_DARKGRAY), new Area( 50, 129,  85, 16, "",      COLOR_WHITE,  COLOR_DARKGRAY) }, /* SPACEキー */
		{ new Area( 50, 129,  17, 16, "カナ",  COLOR_WHITE, COLOR_GRAY),     new Area( 50, 129,  17, 16, "カナ",  COLOR_WHITE,  COLOR_GRAY),     new Area( 28, 129,  21, 16, "カナ",  COLOR_WHITE,  COLOR_GRAY)     }, /* カナキー */
		{ new Area( 19,  97,   7, 16, ""),                      new Area( 19,  97,   7, 16, ""),                      new Area( 14, 129,  12, 16, "")                      }, /* RESETボタン */
		{ new Area( 33,  31, 144, 32),                          new Area( 33,  31, 144, 32),                          new Area( 27,  20, 144, 48)                          }, /* LCDドットマトリクス部 */
		{ new Area( 33,  25,  12,  5, "BUSY"),                  new Area( 33,  25,  12,  5, "BUSY"),                  null                                                 }, /* LCDステータス部0 */
		{ new Area( 50,  25,  12,  5, "CAPS"),                  new Area( 45,  63,   9,  5, "RUN"),                   new Area(172,  19,   9,  5, "RUN")                   }, /* LCDステータス部1 */
		{ new Area( 65,  25,   9,  5, "カナ"),                  new Area( 57,  63,   9,  5, "PRO"),                   null                                                 }, /* LCDステータス部2 */
		{ new Area( 78,  25,   6,  5, "小"),                    new Area( 75,  63,  12,  5, "CASL"),                  new Area(181,  19,   9,  5, "PRO")                   }, /* LCDステータス部3 */
		{ new Area( 98,  25,  12,  5, "2ndF"),                  null,                                                 null                                                 }, /* LCDステータス部4 */
		{ null,                                                 new Area(138,  63,  12,  5, "STAT"),                  null                                                 }, /* LCDステータス部5 */
		{ null,                                                 new Area( 88,  63,  12,  5, "TEXT"),                  new Area(172,  24,  12,  5, "TEXT")                  }, /* LCDステータス部6 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部7 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部8 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部9 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部10 */
		{ null,                                                 null,                                                 new Area(172,  29,  12,  5, "CASL")                  }, /* LCDステータス部11 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部12 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部13 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部14 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部15 */
		{ null,                                                 null,                                                 new Area(172,  34,  12,  5, "STAT")                  }, /* LCDステータス部16 */
		{ null,                                                 new Area(161,  25,   3,  5, "E"),                     null                                                 }, /* LCDステータス部17 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部18 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部19 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部20 */
		{ null,                                                 null,                                                 new Area(172,  39,  12,  5, "2ndF")                  }, /* LCDステータス部21 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部22 */
		{ null,                                                 null,                                                 new Area(186,  39,   3,  5, "M")                     }, /* LCDステータス部23 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部24 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部25 */
		{ null,                                                 null,                                                 new Area(172,  44,  12,  5, "CAPS")                  }, /* LCDステータス部26 */
		{ new Area( 88,  63,  12,  5, "TEXT"),                  null,                                                 null                                                 }, /* LCDステータス部27 */
		{ new Area( 75,  63,  12,  5, "CASL"),                  null,                                                 null                                                 }, /* LCDステータス部28 */
		{ new Area( 57,  63,   9,  5, "PRO"),                   null,                                                 null                                                 }, /* LCDステータス部29 */
		{ new Area( 45,  63,   9,  5, "RUN"),                   null,                                                 null                                                 }, /* LCDステータス部30 */
		{ null,                                                 null,                                                 new Area(172,  49,   9,  5, "カナ")                  }, /* LCDステータス部31 */
		{ new Area(165,  25,  12,  5, "BATT"),                  new Area( 78,  25,   6,  5, "小"),                    null                                                 }, /* LCDステータス部32 */
		{ new Area(161,  25,   3,  5, "E"),                     new Area( 65,  25,   9,  5, "カナ"),                  new Area(182,  49,   6,  5, "小")                    }, /* LCDステータス部33 */
		{ new Area(147,  25,   3,  5, "M"),                     new Area(130,  25,  15,  5, "CONST"),                 null                                                 }, /* LCDステータス部34 */
		{ new Area(130,  25,  15,  5, "CONST"),                 new Area( 50,  25,  12,  5, "CAPS"),                  null                                                 }, /* LCDステータス部35 */
		{ new Area(120,  25,   9,  5, "RAD"),                   new Area( 98,  25,  12,  5, "2ndF"),                  new Area(172,  54,   6,  5, "DE")                    }, /* LCDステータス部36 */
		{ new Area(117,  25,   3,  5, "G"),                     null,                                                 null                                                 }, /* LCDステータス部37 */
		{ new Area(111,  25,   6,  5, "DE"),                    null,                                                 new Area(178,  54,   3,  5, "G")                     }, /* LCDステータス部38 */
		{ null,                                                 new Area(156,  63,  15,  5, "PRINT"),                 null                                                 }, /* LCDステータス部39 */
		{ null,                                                 new Area(147,  25,   3,  5, "M"),                     new Area(181,  54,   9,  5, "RAD")                   }, /* LCDステータス部40 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部41 */
		{ null,                                                 new Area(120,  25,   9,  5, "RAD"),                   new Area(172,  59,  15,  5, "CONST")                 }, /* LCDステータス部42 */
		{ null,                                                 new Area(117,  25,   3,  5, "G"),                     null                                                 }, /* LCDステータス部43 */
		{ null,                                                 new Area(111,  25,   6,  5, "DE"),                    new Area(172,  64,  15,  5, "PRINT")                 }, /* LCDステータス部44 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部45 */
		{ null,                                                 null,                                                 new Area( 14,  59,  12,  5, "BUSY")                  }, /* LCDステータス部46 */
		{ null,                                                 null,                                                 new Area( 14,  64,  12,  5, "BATT")                  }, /* LCDステータス部47 */
		{ null,                                                 new Area(165,  25,  12,  5, "BATT"),                  null                                                 }, /* LCDステータス部48 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部49 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部50 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部51 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部52 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部53 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部54 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部55 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部56 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部57 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部58 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部59 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部60 */
		{ new Area(138,  63,  12,  5, "STAT"),                  null,                                                 null                                                 }, /* LCDステータス部61 */
		{ new Area(156,  63,  15,  5, "PRINT"),                 null,                                                 null                                                 }, /* LCDステータス部62 */
		{ null,                                                 null,                                                 null                                                 }, /* LCDステータス部63 */
		{ new Area( 31,  24, 148, 46),                          new Area( 31,  24, 148, 46),                          new Area( 13,  17, 179, 54)                          }, /* LCD全体 */
		{ new Area(  2,  17, 206, 60),                          new Area(  2,  17, 206, 60),                          new Area(  0,   4, 205, 74)                          }, /* 画面枠 */
		{ new Area( 33,  18,   6,  5, "0",     COLOR_WHITE),    new Area( 33,  18,   6,  5, "0",     COLOR_WHITE),    new Area( 27,  71,   6,  5, "0",     COLOR_WHITE)    }, /* 0列目 */
		{ new Area( 39,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 39,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 33,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 1列目 */
		{ new Area( 45,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 45,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 39,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 2列目 */
		{ new Area( 51,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 51,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 45,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 3列目 */
		{ new Area( 57,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 57,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 51,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 4列目 */
		{ new Area( 63,  18,   6,  5, "5",     COLOR_WHITE),    new Area( 63,  18,   6,  5, "5",     COLOR_WHITE),    new Area( 57,  71,   6,  5, "5",     COLOR_WHITE)    }, /* 5列目 */
		{ new Area( 69,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 69,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 63,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 6列目 */
		{ new Area( 75,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 75,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 69,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 7列目 */
		{ new Area( 81,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 81,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 75,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 8列目 */
		{ new Area( 87,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 87,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 81,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 9列目 */
		{ new Area( 93,  18,   6,  5, "10",    COLOR_WHITE),    new Area( 93,  18,   6,  5, "10",    COLOR_WHITE),    new Area( 87,  71,   6,  5, "10",    COLOR_WHITE)    }, /* 10列目 */
		{ new Area( 99,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 99,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 93,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 11列目 */
		{ new Area(105,  18,   6,  5, "・",    COLOR_WHITE),    new Area(105,  18,   6,  5, "・",    COLOR_WHITE),    new Area( 99,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 12列目 */
		{ new Area(111,  18,   6,  5, "・",    COLOR_WHITE),    new Area(111,  18,   6,  5, "・",    COLOR_WHITE),    new Area(105,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 13列目 */
		{ new Area(117,  18,   6,  5, "・",    COLOR_WHITE),    new Area(117,  18,   6,  5, "・",    COLOR_WHITE),    new Area(111,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 14列目 */
		{ new Area(123,  18,   6,  5, "15",    COLOR_WHITE),    new Area(123,  18,   6,  5, "15",    COLOR_WHITE),    new Area(117,  71,   6,  5, "15",    COLOR_WHITE)    }, /* 15列目 */
		{ new Area(129,  18,   6,  5, "・",    COLOR_WHITE),    new Area(129,  18,   6,  5, "・",    COLOR_WHITE),    new Area(123,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 16列目 */
		{ new Area(135,  18,   6,  5, "・",    COLOR_WHITE),    new Area(135,  18,   6,  5, "・",    COLOR_WHITE),    new Area(129,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 17列目 */
		{ new Area(141,  18,   6,  5, "・",    COLOR_WHITE),    new Area(141,  18,   6,  5, "・",    COLOR_WHITE),    new Area(135,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 18列目 */
		{ new Area(147,  18,   6,  5, "・",    COLOR_WHITE),    new Area(147,  18,   6,  5, "・",    COLOR_WHITE),    new Area(141,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 19列目 */
		{ new Area(153,  18,   6,  5, "20",    COLOR_WHITE),    new Area(153,  18,   6,  5, "20",    COLOR_WHITE),    new Area(147,  71,   6,  5, "20",    COLOR_WHITE)    }, /* 20列目 */
		{ new Area(159,  18,   6,  5, "・",    COLOR_WHITE),    new Area(159,  18,   6,  5, "・",    COLOR_WHITE),    new Area(153,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 21列目 */
		{ new Area(165,  18,   6,  5, "・",    COLOR_WHITE),    new Area(165,  18,   6,  5, "・",    COLOR_WHITE),    new Area(159,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 22列目 */
		{ new Area(171,  18,   6,  5, "・",    COLOR_WHITE),    new Area(171,  18,   6,  5, "・",    COLOR_WHITE),    new Area(165,  71,   6,  5, "・",    COLOR_WHITE)    }, /* 23列目 */
		{ new Area( 33,  71,   6,  5, "・",    COLOR_WHITE),    new Area( 33,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, /* 0列目 */
		{ new Area( 63,  71,   6,  5, "・",    COLOR_WHITE),    new Area( 63,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, /* 5列目 */
		{ new Area( 93,  71,   6,  5, "・",    COLOR_WHITE),    new Area( 93,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, /* 10列目 */
		{ new Area(123,  71,   6,  5, "・",    COLOR_WHITE),    new Area(123,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, /* 15列目 */
		{ new Area(153,  71,   6,  5, "・",    COLOR_WHITE),    new Area(153,  71,   6,  5, "・",    COLOR_WHITE),    null                                                 }, /* 20列目 */
		{ new Area(179,  31,   8,  8, "－",    COLOR_WHITE),    new Area(179,  31,   8,  8, "－",    COLOR_WHITE),    new Area(191,  20,   8,  8, "－",    COLOR_WHITE)    }, /* 0行目(右) */
		{ new Area(179,  39,   8,  8, "－",    COLOR_WHITE),    new Area(179,  39,   8,  8, "－",    COLOR_WHITE),    new Area(191,  28,   8,  8, "－",    COLOR_WHITE)    }, /* 1行目(右) */
		{ new Area(179,  47,   8,  8, "－",    COLOR_WHITE),    new Area(179,  47,   8,  8, "－",    COLOR_WHITE),    new Area(191,  36,   8,  8, "－",    COLOR_WHITE)    }, /* 2行目(右) */
		{ new Area(179,  55,   8,  8, "－",    COLOR_WHITE),    new Area(179,  55,   8,  8, "－",    COLOR_WHITE),    new Area(191,  44,   8,  8, "－",    COLOR_WHITE)    }, /* 3行目(右) */
		{ null,                                                 null,                                                 new Area(191,  52,   8,  8, "－",    COLOR_WHITE)    }, /* 4行目(右) */
		{ null,                                                 null,                                                 new Area(191,  60,   8,  8, "－",    COLOR_WHITE)    }, /* 5行目(右) */
		{ new Area( 23,  31,   8,  8, "－",    COLOR_WHITE),    new Area( 23,  31,   8,  8, "－",    COLOR_WHITE),    new Area(  5,  20,   8,  8, "－",    COLOR_WHITE)    }, /* 0行目(左) */
		{ new Area( 23,  39,   8,  8, "－",    COLOR_WHITE),    new Area( 23,  39,   8,  8, "－",    COLOR_WHITE),    new Area(  5,  28,   8,  8, "－",    COLOR_WHITE)    }, /* 1行目(左) */
		{ new Area( 23,  47,   8,  8, "－",    COLOR_WHITE),    new Area( 23,  47,   8,  8, "－",    COLOR_WHITE),    new Area(  5,  36,   8,  8, "－",    COLOR_WHITE)    }, /* 2行目(左) */
		{ new Area( 23,  55,   8,  8, "－",    COLOR_WHITE),    new Area( 23,  55,   8,  8, "－",    COLOR_WHITE),    new Area(  5,  44,   8,  8, "－",    COLOR_WHITE)    }, /* 3行目(左) */
		{ null,                                                 null,                                                 new Area(  5,  52,   8,  8, "－",    COLOR_WHITE)    }, /* 4行目(左) */
		{ null,                                                 null,                                                 new Area(  5,  60,   8,  8, "－",    COLOR_WHITE)    }, /* 5行目(左) */
		{ new Area(312,  64,   4,  5, "」",    COLOR_WHITE),    new Area(312,  64,   4,  5, "」",    COLOR_WHITE),    new Area(309,  67,   4,  5, "」",    COLOR_WHITE)    }, /* 右カギカッコ */
		{ new Area(295,  64,   4,  5, "「",    COLOR_WHITE),    new Area(295,  64,   4,  5, "「",    COLOR_WHITE),    new Area(292,  67,   4,  5, "「",    COLOR_WHITE)    }, /* 左カギカッコ */
		{ new Area(293, 137,   4,  5, "・",    COLOR_WHITE),    new Area(293, 137,   4,  5, "・",    COLOR_WHITE),    new Area(290, 141,   4,  5, "・",    COLOR_WHITE)    }, /* 中点 */
		{ new Area(251, 137,   4,  5, "。",    COLOR_WHITE),    new Area(251, 137,   4,  5, "。",    COLOR_WHITE),    new Area(248, 141,   4,  5, "。",    COLOR_WHITE)    }, /* 読点 */
		{ new Area(170, 121,   4,  5, "、",    COLOR_WHITE),    new Area(170, 121,   4,  5, "、",    COLOR_WHITE),    new Area(167, 125,   4,  5, "、",    COLOR_WHITE)    }, /* 句点 */
		{ new Area(  2,  79,  17,  5, "BREAK", COLOR_WHITE),    new Area(  2,  79,  17,  5, "BREAK", COLOR_WHITE),    new Area(294,   5,  17,  5, "BREAK", COLOR_WHITE)    }, /* BREAK */
		{ null,                                                 null,                                                 new Area(260,   5,  17,  5, "コントラスト", COLOR_YELLOW) }, /* コントラスト */
		{ new Area( 19, 111,  17,  5, "CASL",  COLOR_YELLOW),   new Area( 19, 111,  17,  5, "C",     COLOR_YELLOW),   new Area(226,   5,  17,  5, "C",     COLOR_YELLOW)   }, /* CASL/C */
		{ null,                                                 new Area(  2, 111,  17,  5, "ASMBL", COLOR_YELLOW),   new Area(209,   5,  17,  5, "ASMBL", COLOR_YELLOW)   }, /* ASMBL */
		{ new Area(297,  22,  16,  5, "CA",    COLOR_YELLOW),   new Area(297,  22,  16,  5, "CA",    COLOR_YELLOW),   new Area(294,  22,  17,  5, "CA",    COLOR_YELLOW)   }, /* CA */
		{ new Area(280,  22,  16,  5, "DIGIT", COLOR_YELLOW),   new Area(280,  22,  16,  5, "DIGIT", COLOR_YELLOW),   new Area(277,  22,  17,  5, "DIGIT", COLOR_YELLOW)   }, /* DIGIT */
		{ new Area(263,  22,  16,  5, "atan",  COLOR_YELLOW),   new Area(263,  22,  16,  5, "atan",  COLOR_YELLOW),   new Area(260,  22,  17,  5, "atan",  COLOR_YELLOW)   }, /* atan */
		{ new Area(246,  22,  16,  5, "acos",  COLOR_YELLOW),   new Area(246,  22,  16,  5, "acos",  COLOR_YELLOW),   new Area(243,  22,  17,  5, "acos",  COLOR_YELLOW)   }, /* acos */
		{ new Area(229,  22,  16,  5, "asin",  COLOR_YELLOW),   new Area(229,  22,  16,  5, "asin",  COLOR_YELLOW),   new Area(226,  22,  17,  5, "asin",  COLOR_YELLOW)   }, /* asin */
		{ new Area(297,  38,  16,  5, "STAT",  COLOR_YELLOW),   new Area(297,  38,  16,  5, "STAT",  COLOR_YELLOW),   new Area(294,  38,  17,  5, "STAT",  COLOR_YELLOW)   }, /* STAT */
		{ new Area(280,  38,  16,  5, "n!",    COLOR_YELLOW),   new Area(280,  38,  16,  5, "n!",    COLOR_YELLOW),   new Area(277,  38,  17,  5, "n!",    COLOR_YELLOW)   }, /* n! */
		{ new Area(263,  38,  16,  5, "10^x",  COLOR_YELLOW),   new Area(263,  38,  16,  5, "10^x",  COLOR_YELLOW),   new Area(260,  38,  17,  5, "10^x",  COLOR_YELLOW)   }, /* 10^x */
		{ new Area(246,  38,  16,  5, "e^x",   COLOR_YELLOW),   new Area(246,  38,  16,  5, "e^x",   COLOR_YELLOW),   new Area(243,  38,  17,  5, "e^x",   COLOR_YELLOW)   }, /* e^x */
		{ new Area(229,  38,  16,  5, "DMS",   COLOR_YELLOW),   new Area(229,  38,  16,  5, "DMS",   COLOR_YELLOW),   new Area(226,  38,  17,  5, "DMS",   COLOR_YELLOW)   }, /* DMS */
		{ new Area(212,  38,  16,  5, "nCr",   COLOR_YELLOW),   new Area(212,  38,  16,  5, "nCr",   COLOR_YELLOW),   new Area(209,  38,  17,  5, "nCr",   COLOR_YELLOW)   }, /* nCr */
		{ null,                                                 new Area(297,  54,  17,  5, "BASE-n",COLOR_YELLOW),   new Area(294,  54,  17,  5, "BASE-n",COLOR_YELLOW)   }, /* BASE-n */
		{ new Area(280,  54,  16,  5, "→xy",  COLOR_YELLOW),   new Area(280,  54,  16,  5, "→xy",  COLOR_YELLOW),   new Area(277,  54,  17,  5, "→xy",  COLOR_YELLOW)   }, /* →xy */
		{ new Area(263,  54,  16,  5, "→rθ", COLOR_YELLOW),   new Area(263,  54,  16,  5, "→rθ", COLOR_YELLOW),   new Area(260,  54,  17,  5, "→rθ", COLOR_YELLOW)   }, /* →rθ */
		{ new Area(246,  54,  16,  5, "x^3",   COLOR_YELLOW),   new Area(246,  54,  16,  5, "x^3",   COLOR_YELLOW),   new Area(243,  54,  17,  5, "x^3",   COLOR_YELLOW)   }, /* x^3 */
		{ new Area(229,  54,  16,  5, "3√",   COLOR_YELLOW),   new Area(229,  54,  16,  5, "3√",   COLOR_YELLOW),   new Area(226,  54,  17,  5, "3√",   COLOR_YELLOW)   }, /* 3√ */
		{ new Area(212,  54,  16,  5, "RND",   COLOR_YELLOW),   new Area(212,  54,  16,  5, "RND",   COLOR_YELLOW),   new Area(209,  54,  17,  5, "RND",   COLOR_YELLOW)   }, /* RND */
		{ null,                                                 null,                                                 new Area(250,  71,  21,  5, "″",    COLOR_YELLOW)   }, /* ″ */
		{ null,                                                 null,                                                 new Area(229,  71,  21,  5, "′",    COLOR_YELLOW)   }, /* ′ */
		{ null,                                                 null,                                                 new Area(208,  71,  21,  5, "°",    COLOR_YELLOW)   }, /* ° */
		{ new Area(295,  89,  19,  5, "M-",    COLOR_YELLOW),   new Area(295,  89,  19,  5, "M-",    COLOR_YELLOW),   new Area(292,  89,  21,  5, "M-",    COLOR_YELLOW)   }, /* M- */
		{ new Area(295, 107,  19,  5, "P-NP",  COLOR_YELLOW),   new Area(295, 107,  19,  5, "P-NP",  COLOR_YELLOW),   new Area(292, 107,  21,  5, "P-NP",  COLOR_YELLOW)   }, /* P-NP */
		{ new Area(274, 107,  19,  5, "(-)",   COLOR_YELLOW),   new Area(274, 107,  19,  5, "(-)",   COLOR_YELLOW),   new Area(272, 107,  21,  5, "(-)",   COLOR_YELLOW)   }, /* (-) */
		{ null,                                                 new Area(253, 125,  19,  5, "Exp",   COLOR_YELLOW),   new Area(250, 125,  21,  5, "Exp",   COLOR_YELLOW)   }, /* Exp */
		{ new Area(232, 125,  19,  5, "DRG",   COLOR_YELLOW),   new Area(232, 125,  19,  5, "DRG",   COLOR_YELLOW),   new Area(229, 125,  21,  5, "DRG",   COLOR_YELLOW)   }, /* DRG */
		{ new Area(175,  79,  15,  5, "@",     COLOR_YELLOW),   new Area(175,  79,  15,  5, "@",     COLOR_YELLOW),   new Area(172,  79,  17,  5, "@",     COLOR_YELLOW)   }, /* @ */
		{ new Area(158,  79,  15,  5, ">",     COLOR_YELLOW),   new Area(158,  79,  15,  5, ">",     COLOR_YELLOW),   new Area(155,  79,  17,  5, ">",     COLOR_YELLOW)   }, /* > */
		{ new Area(141,  79,  15,  5, "<",     COLOR_YELLOW),   new Area(141,  79,  15,  5, "<",     COLOR_YELLOW),   new Area(138,  79,  17,  5, "<",     COLOR_YELLOW)   }, /* < */
		{ new Area(124,  79,  15,  5, "'",     COLOR_YELLOW),   new Area(124,  79,  15,  5, "'",     COLOR_YELLOW),   new Area(121,  79,  17,  5, "'",     COLOR_YELLOW)   }, /* ' */
		{ new Area(107,  79,  15,  5, "&",     COLOR_YELLOW),   new Area(107,  79,  15,  5, "&",     COLOR_YELLOW),   new Area(104,  79,  17,  5, "&",     COLOR_YELLOW)   }, /* & */
		{ new Area( 90,  79,  15,  5, "%",     COLOR_YELLOW),   new Area( 90,  79,  15,  5, "%",     COLOR_YELLOW),   new Area( 87,  79,  17,  5, "%",     COLOR_YELLOW)   }, /* % */
		{ new Area( 73,  79,  15,  5, "$",     COLOR_YELLOW),   new Area( 73,  79,  15,  5, "$",     COLOR_YELLOW),   new Area( 70,  79,  17,  5, "$",     COLOR_YELLOW)   }, /* $ */
		{ new Area( 56,  79,  15,  5, "#",     COLOR_YELLOW),   new Area( 56,  79,  15,  5, "#",     COLOR_YELLOW),   new Area( 53,  79,  17,  5, "#",     COLOR_YELLOW)   }, /* # */
		{ new Area( 39,  79,  15,  5, "\"",    COLOR_YELLOW),   new Area( 39,  79,  15,  5, "\"",    COLOR_YELLOW),   new Area( 36,  79,  17,  5, "\"",    COLOR_YELLOW)   }, /* " */
		{ new Area( 22,  79,  15,  5, "!",     COLOR_YELLOW),   new Area( 22,  79,  15,  5, "!",     COLOR_YELLOW),   new Area( 19,  79,  17,  5, "!",     COLOR_YELLOW)   }, /* ! */
		{ null,                                                 null,                                                 new Area(194,  95,  14,  5, "P-NP",  COLOR_YELLOW)   }, /* P-NP(アルファベットキー側) */
		{ new Area(172, 111,  15,  5, ":",     COLOR_YELLOW),   new Area(172, 111,  15,  5, ":",     COLOR_YELLOW),   new Area(176,  95,  17,  5, ":",     COLOR_YELLOW)   }, /* : */
		{ new Area(162,  95,  15,  5, "=",     COLOR_YELLOW),   new Area(162,  95,  15,  5, "=",     COLOR_YELLOW),   new Area(159,  95,  17,  5, "=",     COLOR_YELLOW)   }, /* = */
		{ new Area(145,  95,  15,  5, "_",     COLOR_YELLOW),   new Area(145,  95,  15,  5, "_",     COLOR_YELLOW),   new Area(142,  95,  17,  5, "_",     COLOR_YELLOW)   }, /* _ */
		{ new Area(128,  95,  15,  5, "~",     COLOR_YELLOW),   new Area(128,  95,  15,  5, "~",     COLOR_YELLOW),   new Area(125,  95,  17,  5, "~",     COLOR_YELLOW)   }, /* ~ */
		{ new Area(111,  95,  15,  5, "|",     COLOR_YELLOW),   new Area(111,  95,  15,  5, "|",     COLOR_YELLOW),   new Area(108,  95,  17,  5, "|",     COLOR_YELLOW)   }, /* | */
		{ new Area( 94,  95,  15,  5, "\\",    COLOR_YELLOW),   new Area( 94,  95,  15,  5, "\\",    COLOR_YELLOW),   new Area( 91,  95,  17,  5, "\\",    COLOR_YELLOW)   }, /* \ */
		{ new Area( 77,  95,  15,  5, "}",     COLOR_YELLOW),   new Area( 77,  95,  15,  5, "}",     COLOR_YELLOW),   new Area( 74,  95,  17,  5, "}",     COLOR_YELLOW)   }, /* } */
		{ new Area( 60,  95,  15,  5, "{",     COLOR_YELLOW),   new Area( 60,  95,  15,  5, "{",     COLOR_YELLOW),   new Area( 57,  95,  17,  5, "{",     COLOR_YELLOW)   }, /* { */
		{ new Area( 43,  95,  15,  5, "]",     COLOR_YELLOW),   new Area( 43,  95,  15,  5, "]",     COLOR_YELLOW),   new Area( 40,  95,  17,  5, "]",     COLOR_YELLOW)   }, /* ] */
		{ new Area( 26,  95,  15,  5, "[",     COLOR_YELLOW),   new Area( 26,  95,  15,  5, "[",     COLOR_YELLOW),   new Area( 23,  95,  17,  5, "[",     COLOR_YELLOW)   }, /* [ */
		{ new Area( 33, 127,  15,  5, "小文字",COLOR_WHITE),    new Area( 33, 127,  15,  5, "小文字",COLOR_WHITE),    new Area(  2,  95,  21,  5, "小文字",COLOR_WHITE)    }, /* 小文字 */
		{ new Area(155, 111,  15,  5, "?",     COLOR_YELLOW),   new Area(155, 111,  15,  5, "?",     COLOR_YELLOW),   new Area(152, 111,  17,  5, "?",     COLOR_YELLOW)   }, /* ? */
		{ new Area(138, 111,  15,  5, "LOAD",  COLOR_YELLOW),   new Area(138, 111,  15,  5, "LOAD",  COLOR_YELLOW),   new Area(135, 111,  17,  5, "LOAD",  COLOR_YELLOW)   }, /* LOAD */
		{ new Area(121, 111,  15,  5, "SAVE",  COLOR_YELLOW),   new Area(121, 111,  15,  5, "SAVE",  COLOR_YELLOW),   new Area(118, 111,  17,  5, "SAVE",  COLOR_YELLOW)   }, /* SAVE */
		{ new Area(104, 111,  15,  5, "LIST",  COLOR_YELLOW),   new Area(104, 111,  15,  5, "LIST",  COLOR_YELLOW),   new Area(101, 111,  17,  5, "LIST",  COLOR_YELLOW)   }, /* LIST */
		{ new Area( 87, 111,  15,  5, "RUN",   COLOR_YELLOW),   new Area( 87, 111,  15,  5, "RUN",   COLOR_YELLOW),   new Area( 84, 111,  17,  5, "RUN",   COLOR_YELLOW)   }, /* RUN */
		{ new Area( 70, 111,  15,  5, "CONT",  COLOR_YELLOW),   new Area( 70, 111,  15,  5, "CONT",  COLOR_YELLOW),   new Area( 67, 111,  17,  5, "CONT",  COLOR_YELLOW)   }, /* CONT */
		{ new Area( 53, 111,  15,  5, "PRINT", COLOR_YELLOW),   new Area( 53, 111,  15,  5, "PRINT", COLOR_YELLOW),   new Area( 50, 111,  17,  5, "PRINT", COLOR_YELLOW)   }, /* PRINT */
		{ new Area( 36, 111,  15,  5, "INPUT", COLOR_YELLOW),   new Area( 36, 111,  15,  5, "INPUT", COLOR_YELLOW),   new Area( 33, 111,  17,  5, "INPUT", COLOR_YELLOW)   }, /* INPUT */
		{ new Area(189,  95,  20,  5, "DEL",   COLOR_YELLOW),   new Area(189,  95,  20,  5, "DEL",   COLOR_YELLOW),   new Area(135, 127,  17,  5, "DEL",   COLOR_YELLOW)   }, /* DEL */
		{ new Area( 50, 127,  15,  5, "ー",    COLOR_YELLOW),   new Area( 50, 127,  15,  5, "ー",    COLOR_YELLOW),   new Area( 28, 127,  21,  5, "ー",    COLOR_YELLOW)   }, /* ー */
		{ new Area( 19,  95,   7,  5, "RESET", COLOR_WHITE),    new Area( 19,  95,   7,  5, "RESET", COLOR_WHITE),    new Area( 14, 127,  12,  5, "RESET", COLOR_WHITE)    }, /* RESET */
		{ null,                                                 null,                                                 null                                                 }, /*  */
		{ null,                                                 null,                                                 null                                                 }, /*  */
		{ null,                                                 null,                                                 null                                                 }, /*  */
		{ null,                                                 null,                                                 null                                                 }, /*  */
		{ new Area( -4,   0, 328,148),                          new Area( -4,   0, 328,148),                          new Area(  0,   0, 320,148)                          }  /* 本体 */
	};

	/* レイアウト: BREAKキー */
	static public final int LAYOUT_KEY_BREAK = 0;

	/* レイアウト: OFFキー */
	static public final int LAYOUT_KEY_OFF = 1;

	/* レイアウト: ANSキー */
	static public final int LAYOUT_KEY_ANS = 2;

	/* レイアウト: CONSTキー */
	static public final int LAYOUT_KEY_CONST = 3;

	/* レイアウト: TEXTキー */
	static public final int LAYOUT_KEY_TEXT = 4;

	/* レイアウト: BASICキー */
	static public final int LAYOUT_KEY_BASIC = 5;

	/* レイアウト: CLSキー */
	static public final int LAYOUT_KEY_CLS = 6;

	/* レイアウト: F←→Eキー */
	static public final int LAYOUT_KEY_FE = 7;

	/* レイアウト: tanキー */
	static public final int LAYOUT_KEY_TAN = 8;

	/* レイアウト: cosキー */
	static public final int LAYOUT_KEY_COS = 9;

	/* レイアウト: sinキー */
	static public final int LAYOUT_KEY_SIN = 10;

	/* レイアウト: 2ndFキー */
	static public final int LAYOUT_KEY_2NDF = 11;

	/* レイアウト: MDFキー */
	static public final int LAYOUT_KEY_MDF = 12;

	/* レイアウト: 1/xキー */
	static public final int LAYOUT_KEY_RCP = 13;

	/* レイアウト: logキー */
	static public final int LAYOUT_KEY_LOG = 14;

	/* レイアウト: lnキー */
	static public final int LAYOUT_KEY_LN = 15;

	/* レイアウト: →DEGキー */
	static public final int LAYOUT_KEY_DEG = 16;

	/* レイアウト: nPrキー */
	static public final int LAYOUT_KEY_NPR = 17;

	/* レイアウト: )キー */
	static public final int LAYOUT_KEY_RKAKKO = 18;

	/* レイアウト: (キー */
	static public final int LAYOUT_KEY_LKAKKO = 19;

	/* レイアウト: ^キー */
	static public final int LAYOUT_KEY_HAT = 20;

	/* レイアウト: x^2キー */
	static public final int LAYOUT_KEY_SQU = 21;

	/* レイアウト: √キー */
	static public final int LAYOUT_KEY_SQR = 22;

	/* レイアウト: πキー */
	static public final int LAYOUT_KEY_PI = 23;

	/* レイアウト: R・CMキー */
	static public final int LAYOUT_KEY_RCM = 24;

	/* レイアウト: /キー */
	static public final int LAYOUT_KEY_SLASH = 25;

	/* レイアウト: 9キー */
	static public final int LAYOUT_KEY_9 = 26;

	/* レイアウト: 8キー */
	static public final int LAYOUT_KEY_8 = 27;

	/* レイアウト: 7キー */
	static public final int LAYOUT_KEY_7 = 28;

	/* レイアウト: M+キー */
	static public final int LAYOUT_KEY_MPLUS = 29;

	/* レイアウト: *キー */
	static public final int LAYOUT_KEY_ASTER = 30;

	/* レイアウト: 6キー */
	static public final int LAYOUT_KEY_6 = 31;

	/* レイアウト: 5キー */
	static public final int LAYOUT_KEY_5 = 32;

	/* レイアウト: 4キー */
	static public final int LAYOUT_KEY_4 = 33;

	/* レイアウト: RETURNキー(テンキー側) */
	static public final int LAYOUT_KEY_RETURN2 = 34;

	/* レイアウト: -キー */
	static public final int LAYOUT_KEY_MINUS = 35;

	/* レイアウト: 3キー */
	static public final int LAYOUT_KEY_3 = 36;

	/* レイアウト: 2キー */
	static public final int LAYOUT_KEY_2 = 37;

	/* レイアウト: 1キー */
	static public final int LAYOUT_KEY_1 = 38;

	/* レイアウト: +キー */
	static public final int LAYOUT_KEY_PLUS = 39;

	/* レイアウト: =キー */
	static public final int LAYOUT_KEY_EQUAL = 40;

	/* レイアウト: .キー */
	static public final int LAYOUT_KEY_PERIOD = 41;

	/* レイアウト: 0キー */
	static public final int LAYOUT_KEY_0 = 42;

	/* レイアウト: BS */
	static public final int LAYOUT_KEY_BACKSPACE = 43;

	/* レイアウト: Pキー */
	static public final int LAYOUT_KEY_P = 44;

	/* レイアウト: Oキー */
	static public final int LAYOUT_KEY_O = 45;

	/* レイアウト: Iキー */
	static public final int LAYOUT_KEY_I = 46;

	/* レイアウト: Uキー */
	static public final int LAYOUT_KEY_U = 47;

	/* レイアウト: Yキー */
	static public final int LAYOUT_KEY_Y = 48;

	/* レイアウト: Tキー */
	static public final int LAYOUT_KEY_T = 49;

	/* レイアウト: Rキー */
	static public final int LAYOUT_KEY_R = 50;

	/* レイアウト: Eキー */
	static public final int LAYOUT_KEY_E = 51;

	/* レイアウト: Wキー */
	static public final int LAYOUT_KEY_W = 52;

	/* レイアウト: Qキー */
	static public final int LAYOUT_KEY_Q = 53;

	/* レイアウト: TABキー */
	static public final int LAYOUT_KEY_TAB = 54;

	/* レイアウト: RETURNキー */
	static public final int LAYOUT_KEY_RETURN = 55;

	/* レイアウト: ;キー */
	static public final int LAYOUT_KEY_SEMICOLON = 56;

	/* レイアウト: Lキー */
	static public final int LAYOUT_KEY_L = 57;

	/* レイアウト: Kキー */
	static public final int LAYOUT_KEY_K = 58;

	/* レイアウト: Jキー */
	static public final int LAYOUT_KEY_J = 59;

	/* レイアウト: Hキー */
	static public final int LAYOUT_KEY_H = 60;

	/* レイアウト: Gキー */
	static public final int LAYOUT_KEY_G = 61;

	/* レイアウト: Fキー */
	static public final int LAYOUT_KEY_F = 62;

	/* レイアウト: Dキー */
	static public final int LAYOUT_KEY_D = 63;

	/* レイアウト: Sキー */
	static public final int LAYOUT_KEY_S = 64;

	/* レイアウト: Aキー */
	static public final int LAYOUT_KEY_A = 65;

	/* レイアウト: CAPSキー */
	static public final int LAYOUT_KEY_CAPS = 66;

	/* レイアウト: ↑キー */
	static public final int LAYOUT_KEY_UP = 67;

	/* レイアウト: ,キー */
	static public final int LAYOUT_KEY_COMMA = 68;

	/* レイアウト: Mキー */
	static public final int LAYOUT_KEY_M = 69;

	/* レイアウト: Nキー */
	static public final int LAYOUT_KEY_N = 70;

	/* レイアウト: Bキー */
	static public final int LAYOUT_KEY_B = 71;

	/* レイアウト: Vキー */
	static public final int LAYOUT_KEY_V = 72;

	/* レイアウト: Cキー */
	static public final int LAYOUT_KEY_C = 73;

	/* レイアウト: Xキー */
	static public final int LAYOUT_KEY_X = 74;

	/* レイアウト: Zキー */
	static public final int LAYOUT_KEY_Z = 75;

	/* レイアウト: SHIFTキー */
	static public final int LAYOUT_KEY_SHIFT = 76;

	/* レイアウト: →キー */
	static public final int LAYOUT_KEY_RIGHT = 77;

	/* レイアウト: ↓キー */
	static public final int LAYOUT_KEY_DOWN = 78;

	/* レイアウト: ←キー */
	static public final int LAYOUT_KEY_LEFT = 79;

	/* レイアウト: INSキー */
	static public final int LAYOUT_KEY_INSERT = 80;

	/* レイアウト: SPACEキー */
	static public final int LAYOUT_KEY_SPACE = 81;

	/* レイアウト: カナキー */
	static public final int LAYOUT_KEY_KANA = 82;

	/* レイアウト: RESETボタン */
	static public final int LAYOUT_KEY_RESET = 83;

	/* レイアウト: キーの最後のレイアウト番号 */
	static public final int LAYOUT_KEY_LAST = 83;

	/* レイアウト: LCDドットマトリクス部 */
	static public final int LAYOUT_LCD_MATRIX = 84;

	/* レイアウト: LCDステータス部の最初のレイアウト番号 */
	static public final int LAYOUT_LCD_STATUS_FIRST = 85;

	/* レイアウト: LCDステータス部の最後のレイアウト番号 */
	static public final int LAYOUT_LCD_STATUS_LAST = 148;

	/* レイアウト: LCD全体 */
	static public final int LAYOUT_LCD = 149;

	/* レイアウト: LCD画面枠 */
	static public final int LAYOUT_FRAME = 150;

	/* レイアウト: 0列目 */
	static public final int LAYOUT_LABEL_COL0 = 151;

	/* レイアウト: 1列目 */
	static public final int LAYOUT_LABEL_COL1 = 152;

	/* レイアウト: 2列目 */
	static public final int LAYOUT_LABEL_COL2 = 153;

	/* レイアウト: 3列目 */
	static public final int LAYOUT_LABEL_COL3 = 154;

	/* レイアウト: 4列目 */
	static public final int LAYOUT_LABEL_COL4 = 155;

	/* レイアウト: 5列目 */
	static public final int LAYOUT_LABEL_COL5 = 156;

	/* レイアウト: 6列目 */
	static public final int LAYOUT_LABEL_COL6 = 157;

	/* レイアウト: 7列目 */
	static public final int LAYOUT_LABEL_COL7 = 158;

	/* レイアウト: 8列目 */
	static public final int LAYOUT_LABEL_COL8 = 159;

	/* レイアウト: 9列目 */
	static public final int LAYOUT_LABEL_COL9 = 160;

	/* レイアウト: 10列目 */
	static public final int LAYOUT_LABEL_COL10 = 161;

	/* レイアウト: 11列目 */
	static public final int LAYOUT_LABEL_COL11 = 162;

	/* レイアウト: 12列目 */
	static public final int LAYOUT_LABEL_COL12 = 163;

	/* レイアウト: 13列目 */
	static public final int LAYOUT_LABEL_COL13 = 164;

	/* レイアウト: 14列目 */
	static public final int LAYOUT_LABEL_COL14 = 165;

	/* レイアウト: 15列目 */
	static public final int LAYOUT_LABEL_COL15 = 166;

	/* レイアウト: 16列目 */
	static public final int LAYOUT_LABEL_COL16 = 167;

	/* レイアウト: 17列目 */
	static public final int LAYOUT_LABEL_COL17 = 168;

	/* レイアウト: 18列目 */
	static public final int LAYOUT_LABEL_COL18 = 169;

	/* レイアウト: 19列目 */
	static public final int LAYOUT_LABEL_COL19 = 170;

	/* レイアウト: 20列目 */
	static public final int LAYOUT_LABEL_COL20 = 171;

	/* レイアウト: 21列目 */
	static public final int LAYOUT_LABEL_COL21 = 172;

	/* レイアウト: 22列目 */
	static public final int LAYOUT_LABEL_COL22 = 173;

	/* レイアウト: 23列目 */
	static public final int LAYOUT_LABEL_COL23 = 174;

	/* レイアウト: 0列目(下) */
	static public final int LAYOUT_LABEL_BOTTOM_COL0 = 175;

	/* レイアウト: 5列目(下) */
	static public final int LAYOUT_LABEL_BOTTOM_COL5 = 176;

	/* レイアウト: 10列目(下) */
	static public final int LAYOUT_LABEL_BOTTOM_COL10 = 177;

	/* レイアウト: 15列目(下) */
	static public final int LAYOUT_LABEL_BOTTOM_COL15 = 178;

	/* レイアウト: 20列目(下) */
	static public final int LAYOUT_LABEL_BOTTOM_COL20 = 179;

	/* レイアウト: 0行目(右) */
	static public final int LAYOUT_LABEL_RROW0 = 180;

	/* レイアウト: 1行目(右) */
	static public final int LAYOUT_LABEL_RROW1 = 181;

	/* レイアウト: 2行目(右) */
	static public final int LAYOUT_LABEL_RROW2 = 182;

	/* レイアウト: 3行目(右) */
	static public final int LAYOUT_LABEL_RROW3 = 183;

	/* レイアウト: 4行目(右) */
	static public final int LAYOUT_LABEL_RROW4 = 184;

	/* レイアウト: 5行目(右) */
	static public final int LAYOUT_LABEL_RROW5 = 185;

	/* レイアウト: 0行目(左) */
	static public final int LAYOUT_LABEL_LROW0 = 186;

	/* レイアウト: 1行目(左) */
	static public final int LAYOUT_LABEL_LROW1 = 187;

	/* レイアウト: 2行目(左) */
	static public final int LAYOUT_LABEL_LROW2 = 188;

	/* レイアウト: 3行目(左) */
	static public final int LAYOUT_LABEL_LROW3 = 189;

	/* レイアウト: 4行目(左) */
	static public final int LAYOUT_LABEL_LROW4 = 190;

	/* レイアウト: 5行目(左) */
	static public final int LAYOUT_LABEL_LROW5 = 191;

	/* レイアウト: 右カギカッコ */
	static public final int LAYOUT_LABEL_RKAGIKAKKO = 192;

	/* レイアウト: 左カギカッコ */
	static public final int LAYOUT_LABEL_LKAGIKAKKO = 193;

	/* レイアウト: 中点 */
	static public final int LAYOUT_LABEL_NAKATEN = 194;

	/* レイアウト: 句点 */
	static public final int LAYOUT_LABEL_KUTEN = 195;

	/* レイアウト: 読点 */
	static public final int LAYOUT_LABEL_TOUTEN = 196;

	/* レイアウト: BREAK */
	static public final int LAYOUT_LABEL_BREAK = 197;

	/* レイアウト: コントラスト */
	static public final int LAYOUT_LABEL_CONTRAST = 198;

	/* レイアウト: C */
	static public final int LAYOUT_LABEL_C = 199;

	/* レイアウト: ASMBL */
	static public final int LAYOUT_LABEL_ASMBL = 200;

	/* レイアウト: CA */
	static public final int LAYOUT_LABEL_CA = 201;

	/* レイアウト: DIGIT */
	static public final int LAYOUT_LABEL_DIGIT = 202;

	/* レイアウト: atan */
	static public final int LAYOUT_LABEL_ATAN = 203;

	/* レイアウト: acos */
	static public final int LAYOUT_LABEL_ACOS = 204;

	/* レイアウト: asin */
	static public final int LAYOUT_LABEL_ASIN = 205;

	/* レイアウト: STAT */
	static public final int LAYOUT_LABEL_STAT = 206;

	/* レイアウト: n! */
	static public final int LAYOUT_LABEL_FACT = 207;

	/* レイアウト: 10^x */
	static public final int LAYOUT_LABEL_TEN = 208;

	/* レイアウト: e^x */
	static public final int LAYOUT_LABEL_EXP = 209;

	/* レイアウト: →DMS */
	static public final int LAYOUT_LABEL_DMS = 210;

	/* レイアウト: nCr */
	static public final int LAYOUT_LABEL_NCR = 211;

	/* レイアウト: BASE-n */
	static public final int LAYOUT_LABEL_BASEN = 212;

	/* レイアウト: →xy */
	static public final int LAYOUT_LABEL_XY = 213;

	/* レイアウト: →rθ */
	static public final int LAYOUT_LABEL_POL = 214;

	/* レイアウト: x^3 */
	static public final int LAYOUT_LABEL_CUB = 215;

	/* レイアウト: 3√ */
	static public final int LAYOUT_LABEL_CUR = 216;

	/* レイアウト: RND */
	static public final int LAYOUT_LABEL_RND = 217;

	/* レイアウト: ″ */
	static public final int LAYOUT_LABEL_SECOND = 218;

	/* レイアウト: ′ */
	static public final int LAYOUT_LABEL_MINUTE = 219;

	/* レイアウト: ° */
	static public final int LAYOUT_LABEL_DEGREE = 220;

	/* レイアウト: M- */
	static public final int LAYOUT_LABEL_MMINUS = 221;

	/* レイアウト: P-NP */
	static public final int LAYOUT_LABEL_PNP2 = 222;

	/* レイアウト: (-) */
	static public final int LAYOUT_LABEL_NEG = 223;

	/* レイアウト: Exp */
	static public final int LAYOUT_LABEL_E = 224;

	/* レイアウト: DRG */
	static public final int LAYOUT_LABEL_DRG = 225;

	/* レイアウト: @ */
	static public final int LAYOUT_LABEL_AT = 226;

	/* レイアウト: > */
	static public final int LAYOUT_LABEL_GREATER = 227;

	/* レイアウト: < */
	static public final int LAYOUT_LABEL_LESS = 228;

	/* レイアウト: ' */
	static public final int LAYOUT_LABEL_APOSTROPHE = 229;

	/* レイアウト: & */
	static public final int LAYOUT_LABEL_AMPERSAND = 230;

	/* レイアウト: % */
	static public final int LAYOUT_LABEL_PERCENT = 231;

	/* レイアウト: $ */
	static public final int LAYOUT_LABEL_DOLLAR = 232;

	/* レイアウト: # */
	static public final int LAYOUT_LABEL_HASH = 233;

	/* レイアウト: " */
	static public final int LAYOUT_LABEL_DQUARTATION = 234;

	/* レイアウト: ! */
	static public final int LAYOUT_LABEL_EXCLAMATION = 235;

	/* レイアウト: P-NP(アルファベットキー側) */
	static public final int LAYOUT_LABEL_PNP = 236;

	/* レイアウト: : */
	static public final int LAYOUT_LABEL_COLON = 237;

	/* レイアウト: = */
	static public final int LAYOUT_LABEL_EQUAL = 238;

	/* レイアウト: _ */
	static public final int LAYOUT_LABEL_UNDERBAR = 239;

	/* レイアウト: */
	static public final int LAYOUT_LABEL_TILDE = 240;

	/* レイアウト: | */
	static public final int LAYOUT_LABEL_PIPE = 241;

	/* レイアウト: \ */
	static public final int LAYOUT_LABEL_YEN = 242;

	/* レイアウト: } */
	static public final int LAYOUT_LABEL_RBRACE = 243;

	/* レイアウト: { */
	static public final int LAYOUT_LABEL_LBRACE = 244;

	/* レイアウト: ] */
	static public final int LAYOUT_LABEL_RBRACKET = 245;

	/* レイアウト: [ */
	static public final int LAYOUT_LABEL_LBRACKET = 246;

	/* レイアウト: 小文字 */
	static public final int LAYOUT_LABEL_KOMOZI = 247;

	/* レイアウト: ? */
	static public final int LAYOUT_LABEL_QUESTION = 248;

	/* レイアウト: LOAD */
	static public final int LAYOUT_LABEL_LOAD = 249;

	/* レイアウト: SAVE */
	static public final int LAYOUT_LABEL_SAVE = 250;

	/* レイアウト: LIST */
	static public final int LAYOUT_LABEL_LIST = 251;

	/* レイアウト: RUN */
	static public final int LAYOUT_LABEL_RUN = 252;

	/* レイアウト: CONT */
	static public final int LAYOUT_LABEL_CONT = 253;

	/* レイアウト: PRINT */
	static public final int LAYOUT_LABEL_PRINT = 254;

	/* レイアウト: INPUT */
	static public final int LAYOUT_LABEL_INPUT = 255;

	/* レイアウト: DEL */
	static public final int LAYOUT_LABEL_DELETE = 256;

	/* レイアウト: ー */
	static public final int LAYOUT_LABEL_CHOON = 257;

	/* レイアウト: RESET */
	static public final int LAYOUT_LABEL_RESET = 258;

	/* レイアウト: GRAPHIC */
	static public final int LAYOUT_LABEL_LOGO1 = 259;

	/* レイアウト: C-LANGUAGE */
	static public final int LAYOUT_LABEL_LOGO2 = 260;

	/* レイアウト: POCKET COMPUTER PC-G850/S/V/VS */
	static public final int LAYOUT_LABEL_LOGO3 = 261;

	/* レイアウト: SHARP */
	static public final int LAYOUT_LABEL_LOGO4 = 262;

	/* レイアウト: 本体 */
	static public final int LAYOUT_BODY = 263;

	/* レイアウト: 最後の番号 */
	static public final int LAYOUT_LAST = 263;

	/* 色: 黒 */
	static public final int COLOR_BLACK = 0;

	/* 色: 暗い灰色 */
	static public final int COLOR_DARKGRAY = 1;

	/* 色: 灰色 */
	static public final int COLOR_GRAY = 2;

	/* 色: 明るい灰色 */
	static public final int COLOR_LIGHTGRAY = 3;

	/* 色: 白 */
	static public final int COLOR_WHITE = 4;

	/* 色: 赤 */
	static public final int COLOR_RED = 5;

	/* 色: 明るい赤 */
	static public final int COLOR_LIGHTRED = 6;

	/* 色: 緑 */
	static public final int COLOR_GREEN = 7;

	/* 色: 明るい緑 */
	static public final int COLOR_LIGHTGREEN = 8;

	/* 色: 黄 */
	static public final int COLOR_YELLOW = 9;

	/* 色: 明るい黄 */
	static public final int COLOR_LIGHTYELLOW = 10;

	/* 色: 青 */
	static public final int COLOR_BLUE = 11;

	/* 動作モード: エミュレート */
	static public final int MODE_EMULATOR = 0;

	/* 動作モード: メニュー */
	static public final int MODE_MENU = 1;

	/* エミュレートの対象: PC-G801/PC-G802/PC-G803/PC-G805/PC-G811/PC-G813/PC-G820/PC-G830/PC-E200/PC-E220 */
	static public final int MACHINE_E200 = 0;

	/* エミュレートの対象: PC-G815 */
	static public final int MACHINE_G815 = 1;

	/* エミュレートの対象: PC-G850/PC-G850S/PC-G850V/PC-G850VS */
	static public final int MACHINE_G850 = 2;

	/* 1文字横ドット数 (PC-E200) */
	static private final int E200_CELL_WIDTH = 5;

	/* 1文字縦ドット数 (PC-E200) */
	static private final int E200_CELL_HEIGHT = 7;

	/* 表示横文字数 (PC-E200) */
	static private final int E200_LCD_COLS = 24;

	/* 表示縦文字数 (PC-E200) */
	static private final int E200_LCD_ROWS = 4;

	/* VRAM横文字数 (PC-E200) */
	static private final int E200_VRAM_COLS = 24;

	/* VRAM縦文字数 (PC-E200) */
	static private final int E200_VRAM_ROWS = 4;

	/* VRAM横ドット数 (PC-E200) */
	static private final int E200_VRAM_WIDTH = E200_VRAM_COLS * E200_CELL_WIDTH + 1;

	/* VRAM縦ドット数 (PC-E200) */
	static private final int E200_VRAM_HEIGHT = E200_VRAM_ROWS * 8;

	/* 1文字横ドット数 (PC-G815) */
	static private final int G815_CELL_WIDTH = 6;

	/* 1文字縦ドット数 (PC-G815) */
	static private final int G815_CELL_HEIGHT = 8;

	/* 表示横文字数 (PC-G815) */
	static private final int G815_LCD_COLS = 24;

	/* 表示縦文字数 (PC-G815) */
	static private final int G815_LCD_ROWS = 4;

	/* VRAM横文字数 (PC-G815) */
	static private final int G815_VRAM_COLS = 24;

	/* VRAM縦文字数 (PC-G815) */
	static private final int G815_VRAM_ROWS = 4;

	/* VRAM横ドット数 (PC-G815) */
	static private final int G815_VRAM_WIDTH = G815_VRAM_COLS * G815_CELL_WIDTH + 1;

	/* VRAM縦ドット数 (PC-G815) */
	static private final int G815_VRAM_HEIGHT = G815_VRAM_ROWS * 8;

	/* 1文字横ドット数 (PC-G850) */
	static private final int G850_CELL_WIDTH = 6;

	/* 1文字縦ドット数 (PC-G850) */
	static private final int G850_CELL_HEIGHT = 8;

	/* 画面横文字数 (PC-G850) */
	static private final int G850_LCD_COLS = 24;

	/* 画面縦文字数 (PC-G850) */
	static private final int G850_LCD_ROWS = 6;

	/* VRAM横文字数 (PC-G850) */
	static private final int G850_VRAM_COLS = 24;

	/* VRAM縦文字数 (PC-G850) */
	static private final int G850_VRAM_ROWS = 8;

	/* VRAM横ドット数 (PC-G850) */
	static private final int G850_VRAM_WIDTH = G850_VRAM_COLS * G850_CELL_WIDTH + 1;

	/* VRAM縦ドット数 (PC-G850) */
	static private final int G850_VRAM_HEIGHT = G850_VRAM_ROWS * 8;

	/* SIOモード: 入出力なし */
	static public final int SIO_MODE_STOP = 0;

	/* SIOモード: 入力 */
	static public final int SIO_MODE_IN = 1;

	/* SIOモード: 出力 */
	static public final int SIO_MODE_OUT = 2;

	/* キー割り込み */
	static private final int INTERRUPT_IA = 0x01;

	/* キー割り込み */
	static private final int INTERRUPT_KON = 0x02;

	/* タイマ割り込み */
	static private final int INTERRUPT_1S = 0x04;

	/* 11ピン割り込み */
	static private final int INTERRUPT_INT1 = 0x08;

	/* キーコード: なし */
	static public final int GKEY_NONE = 0x00;

	/* キーコード: OFFキー */
	static public final int GKEY_OFF = 0x01;

	/* キーコード: Qキー */
	static public final int GKEY_Q = 0x02;

	/* キーコード: Wキー */
	static public final int GKEY_W = 0x03;

	/* キーコード: Eキー */
	static public final int GKEY_E = 0x04;

	/* キーコード: Rキー */
	static public final int GKEY_R = 0x05;

	/* キーコード: Tキー */
	static public final int GKEY_T = 0x06;

	/* キーコード: Yキー */
	static public final int GKEY_Y = 0x07;

	/* キーコード: Uキー */
	static public final int GKEY_U = 0x08;

	/* キーコード: Aキー */
	static public final int GKEY_A = 0x09;

	/* キーコード: Sキー */
	static public final int GKEY_S = 0x0a;

	/* キーコード: Dキー */
	static public final int GKEY_D = 0x0b;

	/* キーコード: Fキー */
	static public final int GKEY_F = 0x0c;

	/* キーコード: Gキー */
	static public final int GKEY_G = 0x0d;

	/* キーコード: Hキー */
	static public final int GKEY_H = 0x0e;

	/* キーコード: Jキー */
	static public final int GKEY_J = 0x0f;

	/* キーコード: Kキー */
	static public final int GKEY_K = 0x10;

	/* キーコード: Zキー */
	static public final int GKEY_Z = 0x11;

	/* キーコード: Xキー */
	static public final int GKEY_X = 0x12;

	/* キーコード: Cキー */
	static public final int GKEY_C = 0x13;

	/* キーコード: Vキー */
	static public final int GKEY_V = 0x14;

	/* キーコード: Bキー */
	static public final int GKEY_B = 0x15;

	/* キーコード: Nキー */
	static public final int GKEY_N = 0x16;

	/* キーコード: Mキー */
	static public final int GKEY_M = 0x17;

	/* キーコード: ,キー */
	static public final int GKEY_COMMA = 0x18;

	/* キーコード: BASICキー */
	static public final int GKEY_BASIC = 0x19;

	/* キーコード: TEXTキー */
	static public final int GKEY_TEXT = 0x1a;

	/* キーコード: CAPSキー */
	static public final int GKEY_CAPS = 0x1b;

	/* キーコード: カナキー */
	static public final int GKEY_KANA = 0x1c;

	/* キーコード: TABキー */
	static public final int GKEY_TAB = 0x1d;

	/* キーコード: SPACEキー */
	static public final int GKEY_SPACE = 0x1e;

	/* キーコード: ↓キー */
	static public final int GKEY_DOWN = 0x1f;

	/* キーコード: ↑キー */
	static public final int GKEY_UP = 0x20;

	/* キーコード: ←キー */
	static public final int GKEY_LEFT = 0x21;

	/* キーコード: →キー */
	static public final int GKEY_RIGHT = 0x22;

	/* キーコード: ANSキー */
	static public final int GKEY_ANS = 0x23;

	/* キーコード: 0キー */
	static public final int GKEY_0 = 0x24;

	/* キーコード: .キー */
	static public final int GKEY_PERIOD = 0x25;

	/* キーコード: =キー */
	static public final int GKEY_EQUAL = 0x26;

	/* キーコード: +キー */
	static public final int GKEY_PLUS = 0x27;

	/* キーコード: RETURNキー */
	static public final int GKEY_RETURN = 0x28;

	/* キーコード: Lキー */
	static public final int GKEY_L = 0x29;

	/* キーコード: ;キー */
	static public final int GKEY_SEMICOLON = 0x2a;

	/* キーコード: CONSTキー */
	static public final int GKEY_CONST = 0x2b;

	/* キーコード: 1キー */
	static public final int GKEY_1 = 0x2c;

	/* キーコード: 2キー */
	static public final int GKEY_2 = 0x2d;

	/* キーコード: 3キー */
	static public final int GKEY_3 = 0x2e;

	/* キーコード: -キー */
	static public final int GKEY_MINUS = 0x2f;

	/* キーコード: M+キー */
	static public final int GKEY_MPLUS = 0x30;

	/* キーコード: Iキー */
	static public final int GKEY_I = 0x31;

	/* キーコード: Oキー */
	static public final int GKEY_O = 0x32;

	/* キーコード: INSキー */
	static public final int GKEY_INSERT = 0x33;

	/* キーコード: 4キー */
	static public final int GKEY_4 = 0x34;

	/* キーコード: 5キー */
	static public final int GKEY_5 = 0x35;

	/* キーコード: 6キー */
	static public final int GKEY_6 = 0x36;

	/* キーコード: *キー */
	static public final int GKEY_ASTER = 0x37;

	/* キーコード: R・CMキー */
	static public final int GKEY_RCM = 0x38;

	/* キーコード: Pキー */
	static public final int GKEY_P = 0x39;

	/* キーコード: BSキー */
	static public final int GKEY_BACKSPACE = 0x3a;

	/* キーコード: πキー */
	static public final int GKEY_PI = 0x3b;

	/* キーコード: 7キー */
	static public final int GKEY_7 = 0x3c;

	/* キーコード: 8キー */
	static public final int GKEY_8 = 0x3d;

	/* キーコード: 9キー */
	static public final int GKEY_9 = 0x3e;

	/* キーコード: /キー */
	static public final int GKEY_SLASH = 0x3f;

	/* キーコード: )キー */
	static public final int GKEY_RKAKKO = 0x40;

	/* キーコード: nPrキー */
	static public final int GKEY_NPR = 0x41;

	/* キーコード: →DEGキー */
	static public final int GKEY_DEG = 0x42;

	/* キーコード: √キー */
	static public final int GKEY_SQR = 0x43;

	/* キーコード: x^2キー */
	static public final int GKEY_SQU = 0x44;

	/* キーコード: ^キー */
	static public final int GKEY_HAT = 0x45;

	/* キーコード: (キー */
	static public final int GKEY_LKAKKO = 0x46;

	/* キーコード: 1/xキー */
	static public final int GKEY_RCP = 0x47;

	/* キーコード: MDFキー */
	static public final int GKEY_MDF = 0x48;

	/* キーコード: 2ndFキー */
	static public final int GKEY_2NDF = 0x49;

	/* キーコード: sinキー */
	static public final int GKEY_SIN = 0x4a;

	/* キーコード: cosキー */
	static public final int GKEY_COS = 0x4b;

	/* キーコード: lnキー */
	static public final int GKEY_LN = 0x4c;

	/* キーコード: logキー */
	static public final int GKEY_LOG = 0x4d;

	/* キーコード: tanキー */
	static public final int GKEY_TAN = 0x4e;

	/* キーコード: F←→Eキー */
	static public final int GKEY_FE = 0x4f;

	/* キーコード: CLSキー */
	static public final int GKEY_CLS = 0x50;

	/* キーコード: ONキー */
	static public final int GKEY_BREAK = 0x51;

	/* キーコード: 同時押し */
	static public final int GKEY_DOUBLE = 0x52;

	/* 仮想キーコード: SHIFTキー */
	static public final int GKEY_SHIFT = 0x1000;

	/* 仮想キーコード: RESETキー */
	static public final int GKEY_RESET = 0x2000;

	/* 11ピン出力: Fo1 */
	static private final int PIN11_OUT_FO1 = 0x01;

	/* 11ピン出力: Fo2 */
	static private final int PIN11_OUT_FO2 = 0x02;

	/* 11ピン出力: BEEP */
	static private final int PIN11_OUT_BEEP = 0x40;

	/* 11ピン出力: Xout */
	static private final int PIN11_OUT_XOUT = 0x80;

	/* 11ピン入力: IB1 */
	static private final int PIN11_IN_IB1 = 0x01;

	/* 11ピン入力: IB2 */
	static private final int PIN11_IN_IB2 = 0x02;

	/* 11ピン入力: Xin */
	static private final int PIN11_IN_XIN = 0x04;

	/* 最初の実行か? */
	private boolean first = true;

	/* 動作モード */
	private int mode = 0;

	/* エミュレートするマシン */
	private int machine;

	/* VRAM横ドット数 */
	private int vramWidth;

	/* VRAM縦文字数 */
	private int vramRows;

	/* VRAM横文字数 */
	private int vramCols;

	/* 1文字横ドット数 */
	private int cellWidth;

	/* 1文字縦ドット数 */
	private int cellHeight;

	/* LCD横ドット数 */
	private int lcdWidth;

	/* LCD縦ドット数 */
	private int lcdHeight;

	/* LCD横文字数 */
	private int lcdCols;

	/* LCD縦文字数 */
	private int lcdRows;

	/* メモリ (0x0000~0xffff) */
	private byte[] memory;

	/* RAMの初期値 (0x0000~0x003f) */
	private byte[] base = new byte[] {
		(byte )0xc3, (byte )0xf4, (byte )0xbf, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x03, (byte )0xbd, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00,
		(byte )0xc9, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00, (byte )0x00
	};

	/* ROM (0x8000~0xffff) */
	private byte[][] rom;

	/* 現在のRAMページ番号 */
	private int ramBank;

	/* ROMの総ページ数 */
	private int romBanks;

	/* 現在のROMページ番号 */
	private int romBank;

	/* 現在のEXROMページ番号 */
	private int exBank;

	/* 周辺機器用リセット信号 */
	private int ioReset;

	/* 割り込み要因 */
	private int interruptType;

	/* 割り込みマスク */
	private int interruptMask;

	/* タイマ */
	private int timer;

	/* タイマカウンタ */
	private int timerCount;

	/* タイマ周期 */
	private int timerInterval;

	/* キーストローブ */
	private int keyStrobe;

	/* 最後に設定したキーストローブ */
	private int keyStrobeLast;

	/* キー状態 */
	private int[] keyMatrix;

	/* ONキー状態 */
	private int keyBreak;

	/* シフトキー状態 */
	private int keyShift;

	/* リセットボタン状態 */
	private boolean keyReset;

	/* キー割り込みを発生させるか? */
	private boolean intIA;

	/* キー割り込みを発生させるか? */
	private boolean intKON;

	/* キーストローブを設定したときの累積ステート数 */
	private int keyStrobeLastStates;

	/* キーストローブがクリアされるステート数 */
	private int keyStrobeClearStates;

	/* LCD 横アドレス */
	private int lcdX;

	/* LCD 縦アドレス */
	private int lcdY;

	/* LCD 横アドレス2 (PC-G815) */
	private int lcdX2;

	/* 縦アドレス2 (PC-G815) */
	private int lcdY2;

	/* 表示開始アドレス(PC-E200/PC-G815) */
	private int lcdBegin;

	/* LCD OFF(PC-G850) */
	private boolean lcdDisabled;

	/* 表示開始位置(PC-G850) */
	private int lcdTop;

	/* コントラスト(PC-G850) */
	private int lcdContrast;

	/* ミラーモード(PC-G850) */
	private boolean lcdEffectMirror;

	/* 黒塗りつぶし(PC-G850) */
	private boolean lcdEffectBlack;

	/* 反転(PC-G850) */
	private boolean lcdEffectReverse;

	/* LCD電圧増加(PC-G850) */
	private boolean lcdEffectDark;

	/* 白塗りつぶし(PC-G850) */
	private boolean lcdEffectWhite;

	/* トリム(PC-G850) */
	private int lcdTrim;

	/* VRAM */
	private byte[] vram;

	/* 作業領域 */
	private byte[] tmpVram;

	/* レジスタ破壊用乱数 */
	private int random = 0xffffffff;

	/* 文字表示列 */
	private int curCol;

	/* 文字表示行 */
	private int curRow;

	/* 押されているキー */
	private int pressedKey;

	/* LCDパターン */
	private boolean[][][] lcdPattern;

	/* LCDが変化したか? */
	private boolean[][] lcdChanged;

	/* LCDの点灯数 */
	private int[][] lcdCount;

	/* LCD階調 */
	private int[][] lcdScale;

	/* 前のフレームのLCD階調 */
	private int[][] lcdScalePrev;

	/* LCDページ数 */
	private int lcdPages;

	/* SIO入出力モード */
	private int sioMode = SIO_MODE_STOP;

	/* SIO入力ファイル名 */
	private String sioInPathname = "";

	/* SIO出力ファイル名 */
	private String sioOutPathname = "";

	/* SIOバッファ */
	private byte sioBuffer[];

	/* SIO入出力カウンタ */
	private int sioCount;

	/* SIOへの出力 */
	private int pin11Out;

	/* SIOからの入力(仮想の通信相手の送信データ) */
	private int pin11In;

	/* CPUクロック周波数(Hz) */
	private int cpuClocks;

	/* I/O更新周期(Hz) */
	private int fps;

	/* LCD階調数 */
	private int lcdScales;

	/* ブザー出力 */
	private byte[] wave0;

	/* ブザー出力 */
	private byte[] wave;

	/* レイアウトのX方向の倍率 */
	private int zoomX = 1;

	/* レイアウトのY方向の倍率 */
	private int zoomY = 1;

	/* レイアウトの原点のX座標 */
	private int offsetX = 0;

	/* レイアウトの原点のY座標 */
	private int offsetY = 0;

	/*
		コンストラクタ
	*/
	public G800Emulator(int m, int cpu_clocks, int freq, int lcd_scales)
	{
		super();
		machine = m;
		keyMatrix = new int[10];
		memory = new byte[0x10000];
		rom = new byte[0x100][];
		vram = new byte[166 * 9];
		tmpVram = new byte[166 * 9];
		fps = freq;
		lcdPages = fps / 8;
		lcdScales = (lcd_scales >= 2 ? lcd_scales : lcdPages);

		switch(m) {
		case MACHINE_E200:
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
			if(cpu_clocks > 0)
				cpuClocks = cpu_clocks;
			else
				cpuClocks = 4000 * 1000;
			break;
		case MACHINE_G815:
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
			if(cpu_clocks > 0)
				cpuClocks = cpu_clocks;
			else
				cpuClocks = 4000 * 1000;
			break;
		case MACHINE_G850:
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
			if(cpu_clocks > 0)
				cpuClocks = cpu_clocks;
			else
				cpuClocks = 9000 * 1000;
			base[0x0038] = (byte )0xc3;
			base[0x0039] = (byte )0x37;
			base[0x003a] = (byte )0xbc;
			break;
		}

		lcdPattern = new boolean[lcdPages][64][6 * lcdCols + 1];
		lcdChanged = new boolean[64][6 * lcdCols + 1];
		lcdCount = new int[64][6 * lcdCols + 1];
		lcdScale = new int[64][6 * lcdCols + 1];
		lcdScalePrev = new int[64][6 * lcdCols + 1];

		wave0 = new byte[(44100 + fps / 2) / fps];
		wave = new byte[wave0.length];
	}

	/*
		ログを出力する (オーバーライド)
	*/
	@Override public void log(String message)
	{
	}

	/*
		メモリを読み込む (オーバーライド)
	*/
	@Override public byte read(int address)
	{
		return memory[address];
	}

	/*
		メモリに書き込む (オーバーライド)
	*/
	@Override public void write(int address, byte value)
	{
		if(address < 0x8000)
			memory[address] = value;
	}

	/*
		キーの状態 (inportの下請け)
	*/
	private int in10()
	{
		int key;

		if(keyStrobeLastStates - restStates > keyStrobeClearStates)
			keyStrobe = keyStrobeLast;

		key =
		((keyStrobe & 0x001) != 0 ? keyMatrix[0] : 0) |
		((keyStrobe & 0x002) != 0 ? keyMatrix[1] : 0) |
		((keyStrobe & 0x004) != 0 ? keyMatrix[2] : 0) |
		((keyStrobe & 0x008) != 0 ? keyMatrix[3] : 0) |
		((keyStrobe & 0x010) != 0 ? keyMatrix[4] : 0) |
		((keyStrobe & 0x020) != 0 ? keyMatrix[5] : 0) |
		((keyStrobe & 0x040) != 0 ? keyMatrix[6] : 0) |
		((keyStrobe & 0x080) != 0 ? keyMatrix[7] : 0) |
		((keyStrobe & 0x100) != 0 ? keyMatrix[8] : 0) |
		((keyStrobe & 0x200) != 0 ? keyMatrix[9] : 0);

		keyStrobe = keyStrobeLast;
		return key;
	}

	/*
		キーの状態 (outportの下請け)
	*/
	private void out10(int x)
	{
	}

	/*
		キーストローブ(下位) (inportの下請け)
	*/
	private int in11()
	{
		return 0;
	}

	/*
		キーストローブ(下位) (outportの下請け)
	*/
	private void out11(int x)
	{
		if(keyStrobeLastStates - restStates > keyStrobeClearStates)
			keyStrobe = 0;

		keyStrobeLast = x;
		keyStrobe |= keyStrobeLast;
		keyStrobeLastStates = restStates;

		if((x & 0x10) != 0)
			interruptType |= INTERRUPT_IA;
	}

	/*
		キーストローブ(上位) (inportの下請け)
	*/
	private int in12()
	{
		return 0;
	}

	/*
		キーストローブ(上位) (outportの下請け)
	*/
	private void out12(int x)
	{
		if(keyStrobeLastStates - restStates > keyStrobeClearStates)
			keyStrobe = 0;

		keyStrobeLast = x << 8;
		keyStrobe |= keyStrobeLast;
		keyStrobeLastStates = restStates;
	}

	/*
		シフトキーの状態 (inportの下請け)
	*/
	private int in13()
	{
		return ((keyStrobe & 0x08) != 0 ? keyShift : 0);
	}

	/*
		シフトキーの状態 (outportの下請け)
	*/
	private void out13(int x)
	{
	}

	/*
		タイマ (inportの下請け)
	*/
	private int in14()
	{
		return timer;
	}

	/*
		タイマ (outportの下請け)
	*/
	private void out14(int x)
	{
		timer = 0;
	}

	/*
		Xin入力端子の入力可否状態 (inportの下請け)
	*/
	private int in15()
	{
		/* 未対応 */
		return 0;
	}

	/*
		Xin入力端子の入力可否状態 (outportの下請け)
	*/
	private void out15(int x)
	{
		/* 未対応 */
	}

	/*
		割り込み要因 (inportの下請け)
	*/
	private int in16()
	{
		return interruptType;
	}

	/*
		割り込み要因 (outportの下請け)
	*/
	private void out16(int x)
	{
		interruptType &= ~x & 0x0f;
	}

	/*
		割り込みマスク (inportの下請け)
	*/
	private int in17()
	{
		return interruptMask;
	}

	/*
		割り込みマスク (outportの下請け)
	*/
	private void out17(int x)
	{
		interruptMask = x;
	}

	/*
		11pinI/Fの出力制御 (inportの下請け)
	*/
	private int in18()
	{
		return pin11Out;
	}

	/*
		SIOバッファに書き込む (out18の下請け)
	*/
	private void out18Write(int pin11_out)
	{
		if((pin11In & PIN11_IN_IB2) != 0) {
			int pos = sioCount / 10;

			if((pin11_out & PIN11_OUT_FO2) != 0 && sioBuffer != null && pos < sioBuffer.length) {
				int n = sioCount % 10;

				/* 送信中 */
				switch(n) {
				case 0: /* スタートビット */
					break;
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8: /* データビット */
					int bit = 1 << (n - 1);

					if((pin11_out & PIN11_OUT_XOUT) == 0)
						sioBuffer[pos] |= bit;
					else
						sioBuffer[pos] &= ~bit;
					break;
				case 9: /* ストップビット */
					break;
				}

				sioCount++;
			} else {
				/* 送信終了 */
				pin11In = 0;
				if(sioCount > 3 && sioBuffer != null && sioOutPathname != null) {
					FileOutputStream out = null;

					try {
						try {
							out = new FileOutputStream(sioOutPathname);
							if(sioBuffer[pos - 1] == 0x1a)
								out.write(sioBuffer, 0, pos - 1);
							else
								out.write(sioBuffer, 0, pos);
						} finally {
							if(out != null)
								out.close();
						}
					} catch(Exception e) {
					}
				}
			}
		} else {
			if((pin11_out & PIN11_OUT_FO2) != 0) {
				/* 送信開始 */
				pin11In = PIN11_IN_IB2;
				sioCount = 0;
			}
		}
	}

	/*
		ブザーから音を出力する (out18の下請け)
	*/
	private void out18Buzzer(int pin11_out)
	{
		int pos;

		pos = (executeStates - restStates) * (44100 / fps) / executeStates;
		if(pos < 0)
			pos = 0;
		else if(pos > wave.length - 1)
			return;

		if((pin11_out & (PIN11_OUT_BEEP | PIN11_OUT_XOUT)) != 0) {
			if(pos >= wave0.length)
				return;
			if(wave0[pos] != (byte) 0)
				return;
			Arrays.fill(wave0, pos, wave0.length - 1, (byte) 0x3f);
		} else {
			if(pos >= wave0.length)
				return;
			if(wave0[pos] == (byte) 0)
				return;
			Arrays.fill(wave0, pos, wave0.length - 1, (byte) 0);
		}
	}

	/*
		11pinI/Fの出力制御 (outportの下請け)
	*/
	private void out18(int x)
	{
		pin11Out = x & (PIN11_OUT_FO1 | PIN11_OUT_FO2 | PIN11_OUT_BEEP | PIN11_OUT_XOUT);

		if(executeStates == 0)
			return;

		if(sioMode == SIO_MODE_OUT)
			out18Write(x);
		else
			out18Buzzer(x);
	}

	/*
		ROMバンク切り替え (inportの下請け)
	*/
	private int in19()
	{
		return ((exBank & 0x07) << 4) | (romBank & 0x0f);
	}

	/*
		ROMバンク切り替え (outportの下請け)
	*/
	private void out19(int x)
	{
		if(romBanks > 0) {
			romBank = (x & 0x0f) % romBanks;
			if(rom[romBank] != null)
				System.arraycopy(rom[romBank], 0, memory, 0xc000, 0x4000);
			else
				Arrays.fill(memory, 0xc000, 0x4000, (byte) 0xff);
		}
		exBank = (x & 0x70) >> 4;
	}

	/*
		BOOT ROM ON/OFF (inportの下請け)
	*/
	private int in1a()
	{
		return 0;
	}

	/*
		BOOT ROM ON/OFF (outportの下請け)
	*/
	private void out1a(int x)
	{
		/* 未対応 */
	}

	/*
		RAMバンク切り替え (inportの下請け)
	*/
	private int in1b()
	{
		return ramBank;
	}

	/*
		RAMバンク切り替え (outportの下請け)
	*/
	private void out1b(int x)
	{
		ramBank = x & 0x04;
	}

	/*
		I/Oリセット (inportの下請け)
	*/
	private int in1c()
	{
		return 0;
	}

	/*
		I/Oリセット (outportの下請け)
	*/
	private void out1c(int x)
	{
		ioReset = x;
	}

	/*
		バッテリー状態 (inportの下請け)
	*/
	private int in1d()
	{
		return 0x08;
	}

	/*
		バッテリー状態 (outportの下請け)
	*/
	private void out1d(int x)
	{
	}

	/*
		? (inportの下請け)
	*/
	private int in1e()
	{
		return 0;
	}

	/*
		? (outportの下請け)
	*/
	private void out1e(int x)
	{
	}

	/*
		SIOバッファから読み込む (in1fの下請け)
	*/
	private int in1fRead()
	{
		final int bit_count[] = new int[] {
			0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4
		};
		int pos = sioCount / 14;
		int pin11_in;

		if((pin11Out & PIN11_OUT_FO1) != 0) { /* 送信要求 */
			if(sioCount == 0) {
				/* 初回ならバッファに書き込む */
				FileInputStream in = null;
				int size;

				try {
					File file = new File(sioInPathname);

					if(0 < file.length() && file.length() < 0x100000) {
						sioBuffer = new byte[(int )file.length() + 1];

						try {
							in = new FileInputStream(sioInPathname);
							size = in.read(sioBuffer, 0, sioBuffer.length);
							sioBuffer[size] = 0x1a;
						} finally {
							if(in != null)
								in.close();
						}
					} else
						sioBuffer = null;
				} catch(Exception e) {
					sioBuffer = null;
				}
			}

			if(sioBuffer == null || pos >= sioBuffer.length)
				pin11_in = 0;
			else {
				int n = sioCount % 14;

				switch(n) {
				case 0:
				case 1:
				case 2: /* スタートビット */
					pin11_in = PIN11_IN_XIN | PIN11_IN_IB2;
					break;
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
				case 10: /* データビット */
					if((sioBuffer[pos] & (1 << (n - 3))) == 0)
						pin11_in = PIN11_IN_XIN;
					else
						pin11_in = 0;
					break;
				case 11: /* パリティビット */
					if(((bit_count[sioBuffer[pos] & 0x0f] + bit_count[(sioBuffer[pos] >>> 4) & 0x0f]) & 1) == 0)
						pin11_in = 0;
					else
						pin11_in = PIN11_IN_XIN;
					break;
				case 12:
				case 13: /* エンドビット */
					pin11_in = PIN11_IN_IB2;
					break;
				default:
					pin11_in = 0;
					break;
				}
			}

			sioCount++;
		} else if((pin11Out & PIN11_OUT_FO2) != 0) { /* 送信一時停止 */
			pin11_in = 0;
		} else { /* 送信停止 */
			pin11_in = 0;
			sioCount = 0;
		}

		return pin11_in;
	}

	/*
		11pinI/Fの入力 (inportの下請け)
	*/
	private int in1f()
	{
		if(sioMode == SIO_MODE_IN)
			pin11In = in1fRead();

		return keyBreak | pin11In;
	}

	/*
		11pinI/Fの入力 (outportの下請け)
	*/
	private void out1f(int x)
	{
	}

	/*
		VRAMのオフセットを得る (PC-E200)
	*/
	private int e200VramOffset(int x, int row, int begin)
	{
		row = (row - begin + 8) % 8;

		if(x == 0x3c)
			return row * E200_VRAM_WIDTH + (E200_VRAM_WIDTH - 1);

		if(row < 4)
			return (row - 0) * E200_VRAM_WIDTH + x;
		else
			return (row - 4) * E200_VRAM_WIDTH + (E200_VRAM_WIDTH - x - 2);
	}

	/*
		ディスプレイコントロール (PC-E200) (outportの下請け)
	*/
	private void out58_e200(int val)
	{
		switch(val & 0xc0) {
		case 0x00:
			break;
		case 0x40:
			lcdX = val & 0x3f;
			break;
		case 0x80:
			lcdY = val & 0x07;
			break;
		case 0xc0:
			int row, x, begin_prev;

			System.arraycopy(vram, 0, tmpVram, 0, vram.length);

			begin_prev = lcdBegin;
			lcdBegin = (val >> 3) & 0x07;

			for(row = 0; row < 8; row++)
				for(x = 0; x < 0x3d; x++)
					vram[e200VramOffset(x, row, lcdBegin)] = tmpVram[e200VramOffset(x, row, begin_prev)];
			break;
		}
	}

	/*
		ディスプレイコントロール (PC-E200) (inportの下請け)
	*/
	private int in59_e200()
	{
		return 0;
	}

	/*
		ディスプレイ WRITE (PC-E200) (outportの下請け)
	*/
	private void out5a_e200(int val)
	{
		if(lcdX < 0x3d && lcdY < 8)
			vram[e200VramOffset(lcdX++, lcdY, lcdBegin)] = (byte) val;
	}

	/*
		ディスプレイ READ (PC-E200) (inportの下請け)
	*/
	private int in5b_e200()
	{
		if(lcdX > 0 && lcdX < 0x3d && lcdY < 8)
			return vram[e200VramOffset(lcdX++ - 1, lcdY, lcdBegin)];
		return 0;
	}

	/*
		VRAMのオフセット(PC-G815)
	*/
	private int g815VramOffset(int x, int row, int begin)
	{
		row = (row - begin + 8) % 8;

		if(x == 0x7b)
			return row * G815_VRAM_WIDTH + (G815_VRAM_WIDTH - 1);
		if(row < 4)
			return (row - 0) * G815_VRAM_WIDTH + x;
		else
			return (row - 4) * G815_VRAM_WIDTH + (G815_VRAM_WIDTH - x - 2);
	}

	/*
		ディスプレイコントロール (PC-G815) (outportの下請け)
	*/
	private void out50_g815(int val)
	{
		switch(val & 0xc0) {
		case 0x00:
			break;
		case 0x40:
			lcdX2 = lcdX = val & 0x3f;
			break;
		case 0x80:
			lcdY2 = lcdY = val & 0x07;
			break;
		case 0xc0:
			int row, x, begin_prev;

			begin_prev = lcdBegin;
			lcdBegin = (val >> 3) & 0x07;

			System.arraycopy(vram, 0, tmpVram, 0, vram.length);
			for(row = 0; row < 8; row++)
				for(x = 0; x < 0x49; x++)
					vram[g815VramOffset(x, row, lcdBegin)] = tmpVram[g815VramOffset(x, row, begin_prev)];
			break;
		}
	}

	/*
		ディスプレイコントロール (PC-G815) (inportの下請け)
	*/
	private int in51_g815()
	{
		return 0;
	}

	/*
		ディスプレイコントロール (PC-G815) (outportの下請け)
	*/
	private void out54_g815(int val)
	{
		switch(val & 0xc0) {
		case 0x00:
			break;
		case 0x40:
			lcdX2 = val & 0x3f;
			break;
		case 0x80:
			lcdY2 = val & 0x07;
			break;
		case 0xc0:
			out50_g815(val);
			break;
		}
	}

	/*
		ディスプレイコントロール (PC-G815) (inportの下請け)
	*/
	private int in55_g815()
	{
		return 0;
	}

	/*
		ディスプレイコントロール (PC-G815) (outportの下請け)
	*/
	private void out58_g815(int val)
	{
		switch(val & 0xc0) {
		case 0x00:
			break;
		case 0x40:
			lcdX = val & 0x3f;
			break;
		case 0x80:
			lcdY = val & 0x07;
			break;
		case 0xc0:
			out50_g815(val);
			break;
		}
	}

	/*
		ディスプレイコントロール (PC-G815) (inportの下請け)
	*/
	private int in59_g815()
	{
		return 0;
	}

	/*
		ディスプレイ WRITE (PC-G815) (outportの下請け)
	*/
	private void out56_g815(int x)
	{
		if(lcdX2 < 0x3c && lcdY2 < 8)
			vram[g815VramOffset(lcdX2++, lcdY2, lcdBegin)] = (byte )x;
	}

	/*
		ディスプレイ READ (PC-G815) (inportの下請け)
	*/
	private int in57_g815()
	{
		if(lcdX2 - 1 < 0x3c && lcdX2 > 0 && lcdY2 < 8)
			return vram[g815VramOffset(lcdX2++ - 1, lcdY2, lcdBegin)];
		return 0;
	}

	/*
		ディスプレイ WRITE (PC-G815) (outportの下請け)
	*/
	private void out5a_g815(int x)
	{
		if((0x3c + lcdX < 0x49 || 0x3c + lcdX == 0x7b) && lcdY < 8)
			vram[g815VramOffset(0x3c + lcdX++, lcdY, lcdBegin)] = (byte )x;
	}

	/*
		ディスプレイ READ (PC-G815) (inportの下請け)
	*/
	private int in5b_g815()
	{
		if(0x3c + lcdX - 1 < 0x49 && lcdY < 8)
			return vram[g815VramOffset(0x3c + lcdX++ - 1, lcdY, lcdBegin)];
		return 0;
	}

	/*
		ディスプレイ WRITE (PC-G815) (outportの下請け)
	*/
	private void out52_g815(int x)
	{
		out56_g815(x);
		out5a_g815(x);
	}

	/*
		VRAMのオフセット(PC-G850)
	*/
	private int g850VramOffset(int x, int row)
	{
		return row * G850_VRAM_WIDTH + x;
	}

	/*
		ディスプレイコントロール (PC-G850) (inportの下請け)
	*/
	private int in40_g850()
	{
		return 0;
	}

	/*
		ディスプレイコントロール (PC-G850) (outportの下請け)
	*/
	private void out40_g850(int x)
	{
		switch(x & 0xf0) {
		case 0x00:
			lcdX = (lcdX & 0xf0) | (x & 0x0f);
			break;
		case 0x10:
			lcdX = ((x << 4) & 0xf0) | (lcdX & 0x0f);
			break;
		case 0x20:
			if(x == 0x24)
				lcdDisabled = true;
			else if(x == 0x25)
				lcdDisabled = false;
			break;
		case 0x30:
			timerInterval = 16192 * ((x & 0x0f) + 1);
			break;
		case 0x40:
		case 0x50:
		case 0x60:
		case 0x70:
			lcdTop = x - 0x40;
			break;
		case 0x80:
		case 0x90:
			lcdContrast = x - 0x80;
			break;
		case 0xa0:
			switch(x) {
			case 0xa0:
				lcdEffectMirror = false;
				break;
			case 0xa1:
				lcdEffectMirror = true;
				break;
			case 0xa4:
				lcdEffectBlack = false;
				break;
			case 0xa5:
				lcdEffectBlack = true;
				lcdEffectWhite = false;
				break;
			case 0xa6:
				lcdEffectReverse = false;
				break;
			case 0xa7:
				lcdEffectReverse = true;
				break;
			case 0xa8:
				lcdEffectDark = true;
				break;
			case 0xa9:
				lcdEffectDark = false;
				break;
			case 0xae:
				lcdEffectWhite = true;
				lcdEffectBlack = false;
				break;
			case 0xaf:
				lcdEffectWhite = false;
				break;
			}
			break;
		case 0xb0:
			lcdY = x & 0x0f;
			break;
		case 0xc0:
			lcdTrim = x & 0x0f;
			break;
		case 0xd0:
			break;
		case 0xe0:
			if(x == 0xe2)
				lcdContrast = 0;
			break;
		case 0xf0:
			break;
		}
	}

	/*
		ディスプレイ READ (PC-G850) (inportの下請け)
	*/
	private int in41_g850()
	{
		if(lcdX == 0) {
			lcdX++;
			return 0x10;
		} else if(lcdY >= 8)
			return 0xff;
		else if(lcdX < 166 - 1)
			return vram[g850VramOffset(lcdX++ - 1, lcdY)];
		else
			return 0xff;
	}

	/*
		ディスプレイ WRITE (PC-G850) (outportの下請け)
	*/
	private void out41_g850(int x)
	{
		if(lcdX < 166 && lcdY < 8)
			vram[g850VramOffset(lcdX++, lcdY)] = (byte) x;
	}

	/*
		11pin I/Fの動作 (inportの下請け)
	*/
	private int in60_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		11pin I/Fの動作 (outportの下請け)
	*/
	private void out60_g850(int x)
	{
		/* 未対応 */
	}

	/*
		パラレルI/Oの入出力方向 (inportの下請け)
	*/
	private int in61_g850()
	{
		return 0;
	}

	/*
		パラレルI/Oの入出力方向 (outportの下請け)
	*/
	private void out61_g850(int x)
	{
		/* 未対応 */
	}

	/*
		パラレルI/Oのデータレジスタ (inportの下請け)
	*/
	private int in62_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		パラレルI/Oのデータレジスタ (outportの下請け)
	*/
	private void out62_g850(int x)
	{
		/* 未対応 */
	}

	/*
		UARTフロー制御 (inportの下請け)
	*/
	private int in63_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		UARTフロー制御 (outportの下請け)
	*/
	private void out63_g850(int x)
	{
		/* 未対応 */
	}

	/*
		CD信号によるON制御 (inportの下請け)
	*/
	private int in64_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		CD信号によるON制御 (outportの下請け)
	*/
	private void out64_g850(int x)
	{
		/* 未対応 */
	}

	/*
		M1信号後wait制御 (inportの下請け)
	*/
	private int in65_g850()
	{
		return 0;
	}

	/*
		M1信号後wait制御 (outportの下請け)
	*/
	private void out65_g850(int x)
	{
		/* 未対応 */
	}

	/*
		I/O wait (inportの下請け)
	*/
	private int in66_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		I/O wait (outportの下請け)
	*/
	private void out66_g850(int x)
	{
		/* 未対応 */
	}

	/*
		CPUクロック高速/低速切り替え (PC-G850) (inportの下請け)
	*/
	private int in67_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		CPUクロック高速/低速切り替え (PC-G850) (outportの下請け)
	*/
	private void out67_g850(int x)
	{
		/* 未対応 */
	}

	/*
		タイマ信号/LCDドライバ周期 (inportの下請け)
	*/
	private int in68_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		タイマ信号/LCDドライバ周期 (outportの下請け)
	*/
	private void out68_g850(int x)
	{
		/* 未対応 */
	}

	/*
		ROMバンク切り替え (PC-G850) (inportの下請け)
	*/
	private int in69_g850()
	{
		return romBank;
	}

	/*
		ROMバンク切り替え (PC-G850) (outportの下請け)
	*/
	private void out69_g850(int x)
	{
		romBank = x;
		if(rom[romBank] != null)
			System.arraycopy(rom[romBank], 0, memory, 0xc000, 0x4000);
		else
			Arrays.fill(memory, 0xc000, 0x4000, (byte) 0xff);
	}

	/*
		? (inportの下請け)
	*/
	private int in6a_g850()
	{
		return 0;
	}

	/*
		? (outportの下請け)
	*/
	private void out6a_g850(int x)
	{
	}

	/*
		UARTの入力選択 (inportの下請け)
	*/
	private int in6b_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		UARTの入力選択 (outportの下請け)
	*/
	private void out6b_g850(int x)
	{
		/* 未対応 */
	}

	/*
		UARTモードレジスタ (inportの下請け)
	*/
	private int in6c_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		UARTモードレジスタ (outportの下請け)
	*/
	private void out6c_g850(int x)
	{
		/* 未対応 */
	}

	/*
		UARTコマンドレジスタ (inportの下請け)
	*/
	private int in6d_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		UARTコマンドレジスタ (outportの下請け)
	*/
	private void out6d_g850(int x)
	{
		/* 未対応 */
	}

	/*
		UARTステータスレジスタ (inportの下請け)
	*/
	private int in6e_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		UARTステータスレジスタ (outportの下請け)
	*/
	private void out6e_g850(int x)
	{
		/* 未対応 */
	}

	/*
		UART送受信レジスタ (inportの下請け)
	*/
	private int in6f_g850()
	{
		/* 未対応 */
		return 0;
	}

	/*
		UART送受信レジスタ (outportの下請け)
	*/
	private void out6f_g850(int x)
	{
		/* 未対応 */
	}

	/*
		I/Oから入力を得る (オーバーライド)
	*/
	@Override public int inport(int address)
	{
		/* ディスプレイ用・その他(機種依存) */
		switch(machine) {
		case MACHINE_E200:
			switch(address) {
			case 0x51:
			case 0x59:
				return in59_e200();
			case 0x57:
			case 0x5b:
				return in5b_e200();
			}
			break;
		case MACHINE_G815:
			switch(address) {
			case 0x51:
				return in51_g815();
			case 0x55:
				return in55_g815();
			case 0x57:
				return in57_g815();
			case 0x59:
				return in59_g815();
			case 0x5b:
				return in5b_g815();
			}
			break;
		case MACHINE_G850:
			switch(address) {
			case 0x40:
			case 0x42:
			case 0x44:
			case 0x46:
			case 0x48:
			case 0x4a:
			case 0x4c:
			case 0x4e:
			case 0x50:
			case 0x52:
			case 0x54:
			case 0x56:
			case 0x58:
			case 0x5a:
			case 0x5c:
			case 0x5e:
				return in40_g850();
			case 0x41:
			case 0x43:
			case 0x45:
			case 0x47:
			case 0x49:
			case 0x4b:
			case 0x4d:
			case 0x4f:
			case 0x51:
			case 0x53:
			case 0x55:
			case 0x57:
			case 0x59:
			case 0x5b:
			case 0x5d:
			case 0x5f:
				return in41_g850();
			case 0x60:
				return in60_g850();
			case 0x61:
				return in61_g850();
			case 0x62:
				return in62_g850();
			case 0x63:
				return in63_g850();
			case 0x64:
				return in64_g850();
			case 0x65:
				return in65_g850();
			case 0x66:
				return in66_g850();
			case 0x67:
				return in67_g850();
			case 0x68:
				return in68_g850();
			case 0x69:
				return in69_g850();
			case 0x6a:
				return in6a_g850();
			case 0x6b:
				return in6b_g850();
			case 0x6c:
				return in6c_g850();
			case 0x6d:
				return in6d_g850();
			case 0x6e:
				return in6e_g850();
			case 0x6f:
				return in6f_g850();
			}
			break;
		}

		/* システムポート(共通) */
		switch(address) {
		case 0x10:
			return in10();
		case 0x11:
			return in11();
		case 0x12:
			return in12();
		case 0x13:
			return in13();
		case 0x14:
			return in14();
		case 0x15:
			return in15();
		case 0x16:
			return in16();
		case 0x17:
			return in17();
		case 0x18:
			return in18();
		case 0x19:
			return in19();
		case 0x1a:
			return in1a();
		case 0x1b:
			return in1b();
		case 0x1c:
			return in1c();
		case 0x1d:
			return in1d();
		case 0x1e:
			return in1e();
		case 0x1f:
			return in1f();
		}

		return 0x78;
	}

	/*
		I/Oに出力する (オーバーライド)
	*/
	@Override public void outport(int address, int value)
	{
		/* ディスプレイ用・その他(機種依存) */
		switch(machine) {
		case MACHINE_E200:
			switch(address) {
			case 0x50:
			case 0x58:
				out58_e200(value); break;
			case 0x56:
			case 0x5a:
				out5a_e200(value); break;
			}
			break;
		case MACHINE_G815:
			switch(address) {
			case 0x50:
				out50_g815(value); break;
			case 0x52:
				out52_g815(value); break;
			case 0x54:
				out54_g815(value); break;
			case 0x56:
				out56_g815(value); break;
			case 0x58:
				out58_g815(value); break;
			case 0x5a:
				out5a_g815(value); break;
			}
			break;
		case MACHINE_G850:
			switch(address) {
			case 0x40:
			case 0x42:
			case 0x44:
			case 0x46:
			case 0x48:
			case 0x4a:
			case 0x4c:
			case 0x4e:
			case 0x50:
			case 0x52:
			case 0x54:
			case 0x56:
			case 0x58:
			case 0x5a:
			case 0x5c:
			case 0x5e:
				out40_g850(value); break;
			case 0x41:
			case 0x43:
			case 0x45:
			case 0x47:
			case 0x49:
			case 0x4b:
			case 0x4d:
			case 0x4f:
			case 0x51:
			case 0x53:
			case 0x55:
			case 0x57:
			case 0x59:
			case 0x5b:
			case 0x5d:
			case 0x5f:
				out41_g850(value); break;
			case 0x60:
				out60_g850(value); break;
			case 0x61:
				out61_g850(value); break;
			case 0x62:
				out62_g850(value); break;
			case 0x63:
				out63_g850(value); break;
			case 0x64:
				out64_g850(value); break;
			case 0x65:
				out65_g850(value); break;
			case 0x66:
				out66_g850(value); break;
			case 0x67:
				out67_g850(value); break;
			case 0x68:
				out68_g850(value); break;
			case 0x69:
				out69_g850(value); break;
			case 0x6a:
				out6a_g850(value); break;
			case 0x6b:
				out6b_g850(value); break;
			case 0x6c:
				out6c_g850(value); break;
			case 0x6d:
				out6d_g850(value); break;
			case 0x6e:
				out6e_g850(value); break;
			case 0x6f:
				out6f_g850(value); break;
			}
			break;
		}

		/* システムポート(共通) */
		switch(address) {
		case 0x10:
			out10(value); break;
		case 0x11:
			out11(value); break;
		case 0x12:
			out12(value); break;
		case 0x13:
			out13(value); break;
		case 0x14:
			out14(value); break;
		case 0x15:
			out15(value); break;
		case 0x16:
			out16(value); break;
		case 0x17:
			out17(value); break;
		case 0x18:
			out18(value); break;
		case 0x19:
			out19(value); break;
		case 0x1a:
			out1a(value); break;
		case 0x1b:
			out1b(value); break;
		case 0x1c:
			out1c(value); break;
		case 0x1e:
			out1e(value); break;
		case 0x1f:
			out1f(value); break;
		}
	}

	/*
		破壊された16bitレジスタの値を得る (下請け)
	*/
	private int destroy16()
	{
		random = random * 65541 + 1;
		return random >>> 16;
	}

	/*
		破壊された8bitレジスタの値を得る (下請け)
	*/
	private int destroy8()
	{
		return destroy16() >>> 8;
	}

	/*
		VRAMのオフセットを得る (下請け)
	*/
	private int vramOffset(int x, int row)
	{
		return (row % 8) * vramWidth + x;
	}

	/*
		VRAMのオフセットを得る (下請け)
	*/
	private int lcdOffset(int x, int row)
	{
		if(machine == MACHINE_G850)
			return vramOffset(x, row + read8(0x790d));
		else
			return vramOffset(x, row);
	}

	/*
		パターンを表示する (下請け)
	*/
	private void putPattern(int col, int row, byte[] pattern, int length)
	{
		int offset = lcdOffset(col * cellWidth, row), p = 0;

		while (length-- > 0)
			vram[offset++] = pattern[p++];
	}

	/*
		パターンを表示する (下請け)
	*/
	private void putPattern(int col, int row, int address, int length)
	{
		int offset = lcdOffset(col * cellWidth, row);

		while (length-- > 0)
			vram[offset++] = read(address++);
	}

	/*
		行を消去する (下請け)
	*/
	private void clearLine(int row)
	{
		int offset = lcdOffset(0, row), x;

		for(x = 0; x < vramWidth - 1; x++)
			vram[offset++] = 0;
	}

	/*
		画面全体を消去する (下請け)
	*/
	private void clearAll()
	{
		int row;

		for(row = 0; row < vramRows; row++)
			clearLine(row);
	}

	/*
		上にスクロールする
	*/
	private void scrollUp()
	{
		byte tmp;

		tmp = vram[vramOffset(lcdWidth, 7)];
		vram[vramOffset(lcdWidth, 7)] = vram[vramOffset(lcdWidth, 6)];
		vram[vramOffset(lcdWidth, 6)] = vram[vramOffset(lcdWidth, 5)];
		vram[vramOffset(lcdWidth, 5)] = vram[vramOffset(lcdWidth, 4)];
		vram[vramOffset(lcdWidth, 4)] = vram[vramOffset(lcdWidth, 3)];
		vram[vramOffset(lcdWidth, 3)] = vram[vramOffset(lcdWidth, 2)];
		vram[vramOffset(lcdWidth, 2)] = vram[vramOffset(lcdWidth, 1)];
		vram[vramOffset(lcdWidth, 1)] = vram[vramOffset(lcdWidth, 0)];
		vram[vramOffset(lcdWidth, 0)] = tmp;

		clearLine(0);
		switch(machine) {
		case MACHINE_E200:
			write8(0x790d, (read8(0x790d) + 1) % 8);
			outport(0x58, (read8(0x790d) << 3) | 0xc0);
			break;
		case MACHINE_G815:
			write8(0x790d, (read8(0x790d) + 1) % 8);
			outport(0x50, (read8(0x790d) << 3) | 0xc0);
			break;
		case MACHINE_G850:
			clearLine(6);
			clearLine(7);
			write8(0x790d, (read8(0x790d) + 1) % vramRows);
			outport(0x40, (read8(0x790d) * 8) % (vramRows * 8) | 0x40);
			break;
		}
	}

	/*
		下にスクロールする
	*/
	private void scrollDown(int row, int col)
	{
		int length, r, x;

		length = lcdWidth - row * cellWidth;

		for(r = vramRows - 1; r != row; r--)
			for(x = col * cellWidth; x < lcdWidth * cellWidth; x++)
				vram[lcdOffset(x, r)] = vram[lcdOffset(x, r - 1)];

		clearLine(r);
	}

	/*
		文字を表示する (下請け)
	*/
	private void putChar(int col, int row, int chr)
	{
		putPattern(col, row, font[chr], cellWidth);
	}

	/*
		最初の文字を表示する (下請け)
	*/
	private void putCharFirst(int col, int row, int chr)
	{
		curCol = col;
		curRow = row;

		putChar(curCol, curRow, chr);
	}

	/*
		次の文字を表示する (下請け)
	*/
	private boolean putCharNext(int chr)
	{
		if(curCol < lcdCols - 1) {
			curCol++;

			putChar(curCol, curRow, chr);
			return false;
		} else if(curRow < lcdRows - 1) {
			curCol = 0;
			curRow++;

			putChar(curCol, curRow, chr);
			return false;
		} else {
			curCol = 0;
			curRow = lcdRows - 1;

			scrollUp();
			putChar(curCol, curRow, chr);
			return true;
		}
	}

	/*
		文字列を表示する (下請け)
	*/
	private void putString(int col, int row, String text)
	{
		int i;

		putCharFirst(col, row, (int) text.charAt(0));
		for(i = 1; i < text.length(); i++)
			putCharNext((int) text.charAt(i));
	}

	/*
		LCD上にドットがあるか調べる
	*/
	private int point(int x, int y)
	{
		if(x < 0 || y < 0 || x >= lcdWidth || y >= lcdHeight)
			return 0;

		return vram[lcdOffset(x, y / 8)];
	}

	/*
		LCD上に点を描く
	*/
	private void pset(int x, int y, int mode)
	{
		int mask;

		if(x < 0 || y < 0 || x >= lcdWidth || y >= lcdHeight)
			return;

		mask = 1 << (y % 8);

		switch(mode) {
		case 0:
			vram[lcdOffset(x, y / 8)] &= ~mask;
			break;
		case 1:
			vram[lcdOffset(x, y / 8)] |= mask;
			break;
		default:
			vram[lcdOffset(x, y / 8)] ^= mask;
			break;
		}
	}

	/*
		LCD上に線を描く
	*/
	private void line(int x1, int y1, int x2, int y2, int mode)
	{
		int dx, dx0, dy, dy0, e, x, y, tmp;

		dx0 = x2 - x1;
		dx = (dx0 > 0 ? dx0 : -dx0);
		dy0 = y2 - y1;
		dy = (dy0 > 0 ? dy0 : -dy0);

		if(dx > dy) {
			if(dx0 < 0) {
				tmp = x1; x1 = x2; x2 = tmp;
				tmp = y1; y1 = y2; y2 = tmp;
				dy0 = -dy0;
			}
			for(x = x1, y = y1, e = 0; x <= x2; x++) {
				e += dy;
				if(e > dx) {
					e -= dx;
					y += (dy0 > 0 ? 1 : -1);
				}
				pset(x, y, mode);
			}
		} else {
			if(dy0 < 0) {
				tmp = x1; x1 = x2; x2 = tmp;
				tmp = y1; y1 = y2; y2 = tmp;
				dx0 = -dx0;
			}
			for(y = y1, x = x1, e = 0; y <= y2; y++) {
				e += dx;
				if(e > dy) {
					e -= dy;
					x += (dx0 > 0 ? 1 : -1);
				}
				pset(x, y, mode);
			}
		}
	}

	/*
		LCD上に四角を描く
	*/
	private void box(int x1, int y1, int x2, int y2, int mode)
	{
		int i, tmp;

		if(x1 > x2) {
			tmp = x1; x1 = x2; x2 = tmp;
		}
		if(y1 > y2) {
			tmp = y1; y1 = y2; y2 = tmp;
		}

		for(i = x1; i <= x2; i++)
			pset(i, y1, mode);
		for(i = y1 + 1; i <= y2 - 1; i++)
			pset(x1, i, mode);
		if(x1 != x2)
			for(i = y1 + 1; i <= y2 - 1; i++)
				pset(x2, i, mode);
		if(y1 != y2)
			for(i = x1; i <= x2; i++)
				pset(i, y2, mode);
	}

	/*
		LCD上に塗りつぶした四角を描く
	*/
	private void boxfill(int x1, int y1, int x2, int y2, int mode)
	{
		int i, j;

		for(j = y1; j <= y2; j++)
			for(i = x1; i <= x2; i++)
				pset(i, j, mode);
	}

	/*
		LCD上にパターンを描く
	*/
	private void gprint(int x, int y, int pat)
	{
		pset(x, y - 7, ((pat & 0x01) != 0 ? 1 : 0));
		pset(x, y - 6, ((pat & 0x02) != 0 ? 1 : 0));
		pset(x, y - 5, ((pat & 0x04) != 0 ? 1 : 0));
		pset(x, y - 4, ((pat & 0x08) != 0 ? 1 : 0));
		pset(x, y - 3, ((pat & 0x10) != 0 ? 1 : 0));
		pset(x, y - 2, ((pat & 0x20) != 0 ? 1 : 0));
		pset(x, y - 1, ((pat & 0x40) != 0 ? 1 : 0));
		pset(x, y - 0, ((pat & 0x80) != 0 ? 1 : 0));
	}

	/*
		押されているキーを得る(waitなし) (下請け)
	*/
	private int getKey()
	{
		int key, i;

		if(keyBreak != 0)
			return GKEY_BREAK;
		for(key = GKEY_OFF - 1; key <= GKEY_CLS - 1; key++)
			if((keyMatrix[key / 8] & (1 << (key % 8))) != 0) {
				for(i = key + 1; i <= GKEY_CLS - 1; i++)
					if((keyMatrix[i / 8] & (1 << (i % 8))) != 0)
						return GKEY_DOUBLE;

				return (key + 1) | (keyShift != 0 ? 0x80 : 0);
			}

		return GKEY_NONE;
	}

	/*
		押されているキーを得る(waitあり) (下請け)
	*/
	private int getKeyWait()
	{
		if(pressedKey != GKEY_NONE) {
			if(getKey() == GKEY_NONE)
				pressedKey = GKEY_NONE;
			return GKEY_NONE;
		}
		if((pressedKey = getKey()) == GKEY_NONE)
			return GKEY_NONE;

		return pressedKey;
	}

	/*
		キーコードをASCIIコードに変換する (下請け)
	*/
	private int keyToAscii(int key, boolean upper)
	{
		if(upper && key < 0x49)
			return keyToAsciiUpper[key];
		else
			return keyToAsciiLower[key];
	}

	/*
		全レジスタを表示する (subroutineの下請け)
	*/
	private int iocs_bd03()
	{
		clearAll();
		putString(0, 0, String.format("PC=%04X  AF=%02X %02X", pc, a.get(), f.get()));
		putString(0, 1, String.format("SP=%04X  BC=%02X %02X", sp.get(), b.get(), c.get()));
		putString(0, 2, String.format("IX=%04X  DE=%02X %02X", ix.get(), d.get(), e.get()));
		putString(0, 3, String.format("IY=%04X  HL=%02X %02X", iy.get(), h.get(), l.get()));

		if(getKeyWait() == GKEY_NONE)
			return 0;
		return 1000;
	}

	/*
		少し待つ (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_8aad()
	{
		return 1500;
	}

	/*
		ドットの状態を得る (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_02_f9f8()
	{
		a.set(point(hl.get(), de.get()));
		c.set(1 << (de.get() % 8));
		return 1000;
	}

	/*
		ドットを描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_0d_c76e()
	{
		pset(hl.get(), de.get(), read8(0x7f0f));
		return 1000;
	}

	/*
		線分を描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_0d_c5fc()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7968);
		int y2 = read16(0x796a);

		line(x1, y1, x2, y2, read8(0x7f0f));
		return 6000;
	}

	/*
		四角を描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_0d_c4a9()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7968);
		int y2 = read16(0x796a);

		de.set(y2);
		box(x1, y1, x2, y2, read8(0x7f0f));
		return 8000;
	}

	/*
		四角を描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_0d_c442()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7968);
		int y2 = read16(0x796a);

		de.set(y2);
		box(x1, y1, x2, y2, read8(0x777f));
		return 10000;
	}

	/*
		塗りつぶした四角を描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_0d_c532()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7968);
		int y2 = read16(0x796a);

		de.set(y2);
		boxfill(x1, y1, x2, y2, read8(0x7f0f));
		return 10000;
	}

	/*
		線分を描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_0d_c595()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7968);
		int y2 = read16(0x796a);

		line(x1, y1, x2, y2, read8(0x777f));
		return 6000;
	}

	/*
		文字を描く (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_02_f892()
	{
		int x = read16(0x79dc);
		int y = read16(0x79de);

		write8(0x79db, read8(0x79db) + 1);
		if(read8(0x79db) == 0)
			write8(0x79dc, read8(0x79dc) + 1);

		hl.set(x);
		de.set(y & 0xff80);
		gprint(x, y, a.get());
		return 4000;
	}

	/*
		グラフィック処理 (PC-G815専用) (subroutineの下請け)
	*/
	private int iocs_9490()
	{
		int address, page;

		page = read8(pc);
		address = read16(pc + 1);

		pc = read16(sp);
		sp.add(2);

		switch(page) {
		case 0x02:
			switch(address) {
			case 0xf892:
				return iocs_02_f892();
			case 0xf9f8:
				return iocs_02_f9f8();
			}
			break;
		case 0x0d:
			switch(address) {
			case 0xc76e:
				return iocs_0d_c76e();
			case 0xc5fc:
				return iocs_0d_c5fc();
			case 0xc4a9:
				return iocs_0d_c4a9();
			case 0xc442:
				return iocs_0d_c442();
			case 0xc532:
				return iocs_0d_c532();
			case 0xc595:
				return iocs_0d_c595();
			}
			break;
		}

		return 1000;
	}

	/*
		ドットの状態を得る (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_0e_ffca()
	{
		a.set(point(hl.get(), de.get()));
		c.set(1 << (de.get() % 8));
		return 1000;
	}

	/*
		ドットを描く (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_0d_ffd0()
	{
		pset(hl.get(), de.get(), read8(0x777f));
		return 1000;
	}

	/*
		線分を描く (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_0d_ffd3()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7967);
		int y2 = read16(0x7969);

		line(x1, y1, x2, y2, read8(0x777f));
		return 5000;
	}

	/*
		四角を描く (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_0d_ffd6()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7967);
		int y2 = read16(0x7969);

		de.set(y2);
		box(x1, y1, x2, y2, read8(0x777f));
		return 6000;
	}

	/*
		塗りつぶした四角を描く (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_0d_ffd9()
	{
		int x1 = hl.get();
		int y1 = de.get();
		int x2 = read16(0x7967);
		int y2 = read16(0x7969);

		de.set(y2);
		boxfill(x1, y1, x2, y2, read8(0x777f));
		return 10000;
	}

	/*
		文字を描く (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_0e_ffa3()
	{
		int x = read16(0x79db);
		int y = read16(0x79dd);

		write8(0x79db, read8(0x79db) + 1);
		if(read8(0x79db) == 0)
			write8(0x79dc, read8(0x79dc) + 1);

		hl.set(x);
		de.set(y & 0xff80);
		gprint(x, y, a.get());
		return 3000;
	}

	/*
		グラフィック処理 (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_bb6b()
	{
		int address, page;

		page = read8(pc);
		address = read16(pc + 1);

		pc = read16(sp);
		sp.add(2);

		switch(page) {
		case 0x0d:
			switch(address) {
			case 0xc76e:
			case 0xffd0:
				return iocs_0d_ffd0();
			case 0xc595:
			case 0xffd3:
				return iocs_0d_ffd3();
			case 0xc442:
			case 0xffd6:
				return iocs_0d_ffd6();
			case 0xc4cb:
			case 0xffd9:
				return iocs_0d_ffd9();
			}
			break;
		case 0x0e:
			switch(address) {
			case 0xca08:
			case 0xffca:
				return iocs_0e_ffca();
			case 0xc92e:
			case 0xffa3:
				return iocs_0e_ffa3();
			}
			break;
		}

		return 1000;
	}

	/*
		割り込み先 (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_bc37()
	{
		hlt = false;
		iff = 0x03;
		interruptMask = 0x0f;

		return 1000;
	}

	/*
		押されているキーのASCIIコードを得る(waitあり) (PC-G850専用) (subroutineの下請け)
	*/
	private int iocs_bcc4()
	{
		int key;

		if((key = keyToAscii(getKeyWait(), true)) == GKEY_NONE)
			return 0;

		a.set(key);
		f.set(0x01 | destroy8());
		b.set(0);
		c.set(destroy8());
		hl.set(destroy16());
		bc_d.set(destroy16());
		de_d.set(destroy16());
		hl_d.set(destroy16());
		return 100000;
	}

	/*
		押されているキーを得る(waitなし) (subroutineの下請け)
	*/
	private int iocs_be53()
	{
		int key = getKey();

		a.set(key);
		if(key != 0) {
			f.set(destroy8() | 0x01);
			b.set(destroy8());
		} else
			f.set(destroy8() & ~0x01);
		bc_d.set(destroy16());
		de_d.set(destroy16());
		hl_d.set(destroy16());

		switch(machine) {
		case MACHINE_E200:
		case MACHINE_G815:
			return 18000;
		case MACHINE_G850:
		default:
			return 30000;
		}
	}

	/*
		キーコードをASCIIコードに変換する (subroutineの下請け)
	*/
	private int iocs_be56()
	{
		if((read8(0x78f0) & 0x08) != 0) {
			b.set(a.get());
			f.set(0x10);
		} else {
			a.set(keyToAscii(a.get(), (read8(0x7901) & 0x02) != 0));
			f.set(0x44);
		}

		return 500;
	}

	/*
		1文字表示する(記号を含む) (subroutineの下請け)
	*/
	private int iocs_be5f()
	{
		if(e.get() >= vramCols || d.get() >= vramRows)
			return 100;

		putChar(e.get(), d.get(), a.get());

		af.set(destroy16());
		b.set(0);
		c.set(destroy8());
		hl.set(destroy16());
		return 1800;
	}

	/*
		1文字表示する(記号を含まない) (subroutineの下請け)
	*/
	private int iocs_be62()
	{
		if(e.get() >= vramCols || d.get() >= vramRows)
			return 100;

		putChar(e.get(), d.get(), (a.get() > 0x20 ? a.get() : 0x20));

		af.set(destroy16());
		b.set(0);
		c.set(destroy8());
		hl.set(destroy16());
		return 1800;
	}

	/*
		下にスクロールする (subroutineの下請け)
	*/
	private int iocs_be65()
	{
		if(e.get() >= vramCols || d.get() >= vramRows)
			return 100;

		scrollDown(e.get(), d.get());

		af.set(destroy16());
		bc.set(0);
		de.set(destroy16());
		hl.set(destroy16());
		return 5000;
	}

	/*
		押されているキーを得る(waitあり) (subroutineの下請け)
	*/
	private int iocs_bcfd()
	{
		int key;

		if((key = getKeyWait()) == GKEY_NONE)
			return 0;

		a.set(key);
		f.set(destroy8() | 0x01);
		bc_d.set(destroy16());
		de_d.set(destroy16());
		hl_d.set(destroy16());
		return 20000;
	}

	/*
		16進数2桁のキー入力を得る (subroutineの下請け)
	*/
	private int iocs_bd09()
	{
		return 100000;
	}

	/*
		16進数4桁のキー入力を得る (subroutineの下請け)
	*/
	private int iocs_bd0f()
	{
		return 100000;
	}

	/*
		パターンを表示する (subroutineの下請け)
	*/
	private int iocs_bfd0()
	{
		int n, state;

		if(e.get() >= vramCols || d.get() >= vramRows || b.get() == 0)
			return 100;

		n = e.get() + b.get() / cellWidth;
		n = (n < vramCols ? n : vramCols);
		putPattern(e.get(), d.get(), hl.get(), b.get());

		state = 100 + 170 * b.get();
		a.set(read8(hl.get()));
		e.set(e.get() + b.get());
		hl.set(hl.get() + b.get() - 1);
		b.set(0);
		f.set(destroy8());
		return state;
	}

	/*
		上にスクロールする (subroutineの下請け)
	*/
	private int iocs_bfeb()
	{
		scrollUp();

		af.set(0x0044);
		b.set(0);
		hl.set(destroy16());
		return 5000;
	}

	/*
		n個の文字を表示する (subroutineの下請け)
	*/
	private int iocs_bfee()
	{
		int state;

		if(e.get() >= vramCols || d.get() >= vramRows || b.get() == 0)
			return 100;

		state = 100 + 1800 * b.get();

		putCharFirst(e.get(), d.get(), a.get());
		while (b.add(-1) != 0)
			putCharNext(a.get());

		a.set(0);
		f.set(destroy8());
		hl.set(destroy16());
		return state;
	}

	/*
		文字列を表示する (subroutineの下請け)
	*/
	private int iocs_bff1()
	{
		int state;

		if(e.get() >= vramCols || d.get() >= vramRows || b.get() == 0)
			return 100;

		state = 100 + 1800 * b.get();

		c.set(0);
		putCharFirst(e.get(), d.get(), read8(hl.get()));
		while (b.add(-1) != 0)
			if(putCharNext(read8(hl.add(1))))
				c.add(1);

		af.set(destroy16());
		return state;
	}

	/*
		起動する (subroutineの下請け)
	*/
	private int iocs_bff4()
	{
		setMode(MODE_MENU);
		return 0;
	}

	/*
		電源を切る (subroutineの下請け)
	*/
	private int iocs_c110()
	{
		off();
		return 0;
	}

	/*
		IOCSをエミュレートする (オーバーライド)
	*/
	@Override public int subroutine(int address)
	{
		if(romBanks > 0)
			return -1;
		if(address < 0x8000)
			return -1;

		switch(address) {
		case 0x0030:
			return iocs_bd03();
		case 0xbcfd:
			return iocs_bcfd();
		case 0xbe53:
			return iocs_be53();
		case 0xbe56:
			return iocs_be56();
		case 0xbe5f:
			return iocs_be5f();
		case 0xbe62:
			return iocs_be62();
		case 0xbe65:
			return iocs_be65();
		case 0xbd03:
			return iocs_bd03();
		case 0xbd09:
			return iocs_bd09();
		case 0xbd0f:
			return iocs_bd0f();
		case 0xbfd0:
			return iocs_bfd0();
		case 0xbfeb:
			return iocs_bfeb();
		case 0xbfee:
			return iocs_bfee();
		case 0xbff1:
			return iocs_bff1();
		case 0xbff4:
			return iocs_bff4();
		case 0xc110:
			return iocs_c110();
		}

		switch(machine) {
		case MACHINE_E200:
			break;
		case MACHINE_G815:
			switch(address) {
			case 0x93cd:
			case 0x9490:
				return iocs_9490();
			}
			break;
		case MACHINE_G850:
			switch(address) {
			case 0x8aad:
				return iocs_8aad();
			case 0x93cb:
			case 0x93cd:
			case 0xbb6b:
				return iocs_bb6b();
			case 0xbc37:
				return iocs_bc37();
			case 0xbcc4:
				return iocs_bcc4();
			}
			break;
		}

		return 1000;
	}

	/*
		1周期分実行する
	*/
	public void run()
	{
		int x, y, i, col, row, mask, screenx, screeny;
		boolean dot;

		if(mode == MODE_EMULATOR) {
			/* コードを実行する */
			execute(cpuClocks / fps);

			/* キー割り込み */
			if(intIA) {
				if((interruptMask & INTERRUPT_IA) != 0) {
					interruptType |= INTERRUPT_IA;
					int1();
				}
				intIA = false;
			}

			/* キー割り込み(BREAKキー) */
			if(intKON) {
				if((interruptMask & INTERRUPT_KON) != 0) {
					interruptType |= INTERRUPT_KON;
					int1();
				}
				intKON = false;
			}

			/* タイマ割り込み */
			if(timerCount-- <= 0) {
				timerCount = fps * timerInterval / 1000 / 1000;

				if((interruptMask & INTERRUPT_1S) != 0) {
					timer ^= 0x01;
					interruptType |= INTERRUPT_1S;
					int1();
				}
			}

			/* リセット */
			if(keyReset)
				boot();
		}

		/* LCDを更新する */
		switch(machine) {
		case MACHINE_E200:
		case MACHINE_G815:
			x = screenx = 0;

			for(row = 0; row < lcdRows; row++) {
				for(col = 0; col < lcdCols; col++) {
					for(y = row * cellHeight, screeny = row * 8, mask = 0x01; y < row * cellHeight + cellHeight; y++, screeny++, mask <<= 1) {
						for(x = col * cellWidth, screenx = col * 6; x < col * cellWidth + cellWidth; x++, screenx++) {
							dot = (vram[vramOffset(x, row)] & mask) != 0;
							if(lcdChanged[screeny][screenx] = (dot & !lcdPattern[0][screeny][screenx]) || (!dot && lcdPattern[0][screeny][screenx]) || first) {
								lcdPattern[0][screeny][screenx] = dot;
								lcdScale[screeny][screenx] = (dot ? 1 : 0);
							}
						}
					}
				}
			}

			for(y = 0; y < 64; y++) {
				row = (y + lcdTop) / 8;
				mask = 1 << ((y + lcdTop) % 8);
				x = vramWidth - 1;
				screenx = lcdCols * 6;

				dot = (vram[vramOffset(x, row)] & mask) != 0;
				if(lcdChanged[y][screenx] = (dot & !lcdPattern[0][y][screenx]) || (!dot && lcdPattern[0][y][screenx]) || first) {
					lcdPattern[0][y][screenx] = dot;
					lcdScale[y][screenx] = (dot ? 1 : 0);
				}
			}
			break;
		case MACHINE_G850:
			if(lcdEffectBlack)
				for(y = 0; y < lcdHeight; y++)
					for(x = 0; x < vramWidth; x++) {
						if((lcdChanged[y][x] = !lcdPattern[0][y][x])) {
							lcdPattern[0][y][x] = true;
							lcdScale[y][x] = 1;
						}
					}
			else if(lcdEffectWhite)
				for(y = 0; y < lcdHeight; y++)
					for(x = 0; x < vramWidth; x++) {
						if((lcdChanged[y][x] = lcdPattern[0][y][x])) {
							lcdPattern[0][y][x] = false;
							lcdScale[y][x] = 0;
						}
					}
			else
				for(y = 0; y < lcdHeight; y++) {
					row = (y + lcdTop) / 8;
					mask = 1 << ((y + lcdTop) % 8);

					for(x = 0; x < vramWidth; x++) {
						dot = (vram[vramOffset(x, row)] & mask) == 0 ? lcdEffectReverse: !lcdEffectReverse;
						if(lcdChanged[y][x] = (dot && !lcdPattern[0][y][x]) || (!dot && lcdPattern[0][y][x]) || first) {
							lcdPattern[0][y][x] = dot;
							lcdScale[y][x] = (dot ? 1 : 0);
						}
					}
				}
			break;
		}

		/* ブザー出力を更新する */
		/*
		System.arraycopy(wave0, 0, wave, 0, wave0.length); Arrays.fill(wave0, 0, wave0.length - 1, wave0[wave0.length - 1]);
		*/

		/* LCDの残像をエミュレートする */
		if(lcdScales <= 2) {
			first = false;
			return;
		}
		for(y = 0; y < lcdHeight; y++)
			for(x = 0; x < vramWidth; x++) {
				if(lcdPattern[0][y][x])
					lcdCount[y][x]++;
				if(lcdPattern[lcdPages - 1][y][x])
					lcdCount[y][x]--;

				lcdScale[y][x] = (lcdCount[y][x] * (lcdScales - 1) + lcdPages / 2) / lcdPages;
				lcdChanged[y][x] = (lcdScale[y][x] != lcdScalePrev[y][x]) || first;

				lcdScalePrev[y][x] = lcdScale[y][x];
			}
		for(i = lcdPages - 1; i > 0; i--)
			for(y = 0; y < lcdHeight; y++)
				for(x = 0; x < vramWidth; x++)
					lcdPattern[i][y][x] = lcdPattern[i - 1][y][x];

		first = false;
	}

	/*
		ブートをエミュレートする
	*/
	public void boot()
	{
		if(rom[0] != null) {
			mode = MODE_EMULATOR;
			System.arraycopy(rom[0], 0, memory, 0x8000, rom[0].length);
			System.arraycopy(rom[0], 0, memory, 0xc000, rom[0].length);
		} else {
			mode = MODE_MENU;
			Arrays.fill(memory, 0x8000, 0x8000, (byte) 0xff);
		}
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

		switch(machine) {
		case MACHINE_E200:
			outport(0x58, 0xc0);
			break;
		case MACHINE_G815:
			outport(0x50, 0xc0);
			break;
		case MACHINE_G850:
			if(read8(0x779c) < 0x07 || read8(0x779c) > 0x1f)
				write8(0x779c, 0x1f);
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
			break;
		}

		refreshLcd();
	}

	/*
		電源をOFFにする
	*/
	public void off()
	{
		hlt = true;
		iff = 0;
		ioReset = 0;
	}

	/*
		電源OFFされたか?
	*/
	public boolean isOff()
	{
		return hlt && iff == 0;
	}

	/*
		キーを押した
	*/
	public void keyPress(int key)
	{
		if(GKEY_OFF <= key && key <= GKEY_CLS) {
			key--;
			if((keyMatrix[key / 8] & (1 << (key % 8))) != 0)
				return;

			intIA = true;
			keyMatrix[key / 8] |= (1 << (key % 8));
		} else if(key == GKEY_BREAK) {
			if(keyBreak != 0)
				return;

			intKON = true;
			keyBreak |= 0x80;
		} else if(key == GKEY_SHIFT) {
			keyShift |= 0x01;
		} else if(key == GKEY_RESET) {
			keyReset = true;
		}
	}

	/*
		キーを離した
	*/
	public void keyRelease(int key)
	{
		if(GKEY_OFF <= key && key <= GKEY_CLS) {
			key--;
			keyMatrix[key / 8] &= ~(1 << (key % 8));
		} else if(key == GKEY_BREAK) {
			keyBreak &= ~0x80;
		} else if(key == GKEY_SHIFT) {
			keyShift &= ~0x01;
		} else if(key == GKEY_RESET) {
			keyReset = false;
		}
	}

	/*
		LCDの横ドット数を得る
	*/
	public int getLcdWidth()
	{
		if(machine == MACHINE_E200)
			return lcdWidth + lcdCols;
		else
			return lcdWidth;
	}

	/*
		LCDの縦ドット数を得る
	*/
	public int getLcdHeight()
	{
		if(machine == MACHINE_E200)
			return lcdHeight + lcdRows;
		else
			return lcdHeight;
	}

	/*
		LCDの階調数を得る
	*/
	public int getLcdScales()
	{
		return lcdScales;
	}

	/*
		LCDの状態を得る
	*/
	public int getLcdScale(int x, int y)
	{
		return lcdScale[y][x];
	}

	/*
		LCDの状態が変わったか?
	*/
	public boolean isLcdChanged(int x, int y)
	{
		return lcdChanged[y][x];
	}

	/*
		LCDが全て変わったことにする
	*/
	public void refreshLcd()
	{
		first = true;
	}

	/*
		11ピン端子の状態を得る
	*/
	public int get11Pin()
	{
		return
		((pin11Out & PIN11_OUT_FO2)  == 0 ? 0: 0x008) | /* BUSY */
		((pin11Out & PIN11_OUT_FO1)  == 0 ? 0: 0x010) | /* Dout */
		((pin11In  & PIN11_IN_XIN)   == 0 ? 0: 0x020) | /* Xin */
		((pin11Out & PIN11_OUT_XOUT) == 0 ? 0: 0x040) | /* Xout */
		((pin11In  & PIN11_IN_IB1)   == 0 ? 0: 0x080) | /* Din */
		((pin11In  & PIN11_IN_IB2)   == 0 ? 0: 0x100);  /* ACK */
	}

	/*
		波形を得る
	*/
	public final byte[] getWave()
	{
		return wave;
	}

	/*
		SIOモードを得る
	*/
	public int getSioMode()
	{
		return sioMode;
	}

	/*
		SIOモードを設定する
	*/
	public void setSioMode(int sio_mode)
	{
		sioMode = sio_mode;
		sioCount = 0;
	}

	/*
		SIOから入力するファイルを得る
	*/
	public String getSioInfile()
	{
		return sioInPathname;
	}

	/*
		SIOから入力するファイルを設定する
	*/
	public void setSioInfile(String pathname)
	{
		sioInPathname = pathname;
	}

	/*
		SIOへ出力するファイルを得る
	*/
	public String getSioOutfile()
	{
		return sioOutPathname;
	}

	/*
		SIOへ出力するファイルを設定する
	*/
	public void setSioOutfile(String pathname)
	{
		sioBuffer = new byte[0x8000 * 10];
		sioOutPathname = pathname;
	}

	/*
		SIOバッファを得る
	*/
	public byte[] getSioBuffer()
	{
		return sioBuffer;
	}

	/*
		SIOバッファの読み込み/書き込み位置を得る
	*/
	public int getSioPos()
	{
		if(sioMode == SIO_MODE_IN)
			return sioCount / 14;
		else if(sioMode == SIO_MODE_OUT)
			return sioCount / 10;
		else
			return 0;
	}

	/*
		I/O更新周期を得る
	*/
	public int getFps()
	{
		return fps;
	}

	/*
		RAMのアドレスを得る
	*/
	public byte[] getRam()
	{
		return memory;
	}

	/*
		ROMのアドレスを得る
	*/
	public byte[] getRom(int page)
	{
		return rom[page];
	}

	/*
		モードを得る
	*/
	public int getMode()
	{
		return mode;
	}

	/*
		モードを設定する
	*/
	public void setMode(int mode)
	{
		this.mode = mode;
	}

	/*
		エミュレート対象の機種を得る
	*/
	public int getMachine()
	{
		return machine;
	}

	/*
		CPUのクロック周波数を得る
	*/
	public int getCpuClocks()
	{
		return cpuClocks;
	}

	/*
		原点座標を設定する
	*/
	public void setOffset(int offset_x, int offset_y)
	{
		offsetX = offset_x;
		offsetY = offset_y;
	}

	/*
		原点のX座標を得る
	*/
	public int getOffsetX()
	{
		return offsetX;
	}

	/*
		原点のY座標を得る
	*/
	public int getOffsetY()
	{
		return offsetY;
	}

	/*
		倍率を設定する
	*/
	public void setZoom(int zoom_x, int zoom_y)
	{
		zoomX = zoom_x;
		zoomY = zoom_y;
	}

	/*
		X方向の倍率を得る
	*/
	public int getZoomX()
	{
		return zoomX;
	}

	/*
		Y方向の倍率を得る
	*/
	public int getZoomY()
	{
		return zoomY;
	}

	/*
		レイアウトを得る
	*/
	public Area getLayout(int index, int offset_x, int offset_y, int zoom_x, int zoom_y)
	{
		Area area;

		if((area = layout[index][machine]) == null)
			return null;
		return new Area(offset_x + area.x * zoom_x, offset_y + area.y * zoom_y, area.width * zoom_x, area.height * zoom_y, area.text, area.foreColor, area.backColor);
	}

	/*
		レイアウトを得る
	*/
	public Area getLayout(int index)
	{
		return getLayout(index, offsetX, offsetY, zoomX, zoomY);
	}

	/*
		バイナリのROMイメージを読み込む
	*/
	public int readRom(InputStream in) throws IOException
	{
		int page;

		if(in.read(base, 0, base.length) != base.length) {
			System.arraycopy(base, 0, memory, 0, base.length);
			return 0;
		}

		for(page = 0;; page++) {
			rom[page] = new byte[0x4000];

			try {
				if(in.read(rom[page], 0, rom[page].length) != rom[page].length)
					break;
			} catch (IOException e) {
				break;
			}
		}
		rom[page] = null;
		romBanks = page;
		return romBanks;
	}

	/*
		ROMイメージをバイナリで書き込む
	*/
	public void writeRom(OutputStream out) throws IOException
	{
		int page;

		if(rom[0] == null)
			return;

		out.write(base, 0, base.length);

		for(page = 0; rom[page] != null; page++) {
			out.write(rom[page], 0, rom[page].length);
		}
	}

	/*
		バイナリのRAMを読み込む
	*/
	public void readRam(InputStream in) throws IOException
	{
		in.read(memory, 0, memory.length);
	}

	/*
		RAMをバイナリで読み込む
	*/
	public void writeRam(OutputStream out) throws IOException
	{
		out.write(memory, 0, memory.length);
	}

	/*
		ROMイメージファイルを1ページ読み込む (下請け)
	*/
	private int readRom1page(byte[] buf, String base_name) throws Exception
	{
		String file_name;

		file_name = base_name + ".txt";
		if((new File(file_name)).exists())
			return HexFile.readFileAbs(buf, file_name, 0x0000);
		else
			return BinFile.readFile(buf, base_name + ".bin");
	}

	/*
		IntelHex形式のROMイメージファイルを読み込む (ファイル名)
	*/
	public int loadHexFileIntoRom(String dir_name) throws Exception
	{
		int page;

		readRom1page(memory, dir_name + "/base");
		System.arraycopy(memory, 0, base, 0, 0x40);

		for(page = 0;; page++) {
			rom[page] = new byte[0x4000];
			try {
				readRom1page(rom[page], dir_name + "/rom" + String.format("%02x", page));
			} catch (IOException e) {
				rom[page] = null;
				romBanks = page;
				return romBanks;
			}
		}
	}

	/*
		IntelHex形式のファイルを読み込む (ファイル名)
	*/
	public int loadHexFileIntoRam(String pathname) throws Exception
	{
		return HexFile.readFile(memory, pathname);
	}

	/*
		IntelHex形式のファイルを読み込む (URL)
	*/
	public int loadHexURLIntoRam(String url) throws Exception
	{
		return HexFile.readURL(memory, url);
	}

	/*
		Zip圧縮されたIntelHex形式のファイルを読み込む (ファイル名)
	*/
	public int loadZippedHexFileIntoRam(String zipname, String entryname) throws Exception
	{
		return HexFile.readZipFile(memory, zipname, entryname);
	}

	/*
		Zip圧縮されたIntelHex形式のファイルを読み込む (URL)
	*/
	public int loadZippedHexURLIntoRam(String url, String entryname) throws Exception
	{
		return HexFile.readZipURL(memory, url, entryname);
	}
}

/*
	--- k6x8のライセンス ------------------------------------------------------------------------------------------------------------------
	These fonts are free softwares.
	Unlimited permission is granted to use, copy, and distribute it, with or without modification, either commercially and noncommercially.
	THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.

	これらのフォントはフリー（自由な）ソフトウエアです。
	あらゆる改変の有無に関わらず、また商業的な利用であっても、自由にご利用、複製、再配布することができますが、全て無保証とさせていただきます。

	Copyright(C) 2000-2007 Num Kadoma
	---------------------------------------------------------------------------------------------------------------------------------------
*/

/*
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
 */

/* eof */
