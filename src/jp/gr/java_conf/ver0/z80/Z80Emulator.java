package jp.gr.java_conf.ver0.z80;

/*
	Zilog Z80 emulator for Java
*/
public abstract class Z80Emulator
{
	/*
		8bitレジスタ
	*/
	public class Register8
	{
		/* レジスタの値 */
		private int x;

		/*
			コンストラクタ
		*/
		public Register8(int value)
		{
			x = value & 0xff;
		}
		public Register8()
		{
			this(0);
		}

		/*
			値を得る
		*/
		public int get()
		{
			return x;
		}

		/*
			値を設定する
		*/
		public int set(int value)
		{
			x = value & 0xff;
			return get();
		}

		/*
			値が0か?
		*/
		public boolean isZero()
		{
			return x == 0;
		}

		/*
			値を加算する
		*/
		public int add(int value)
		{
			return set(get() + value);
		}

		/*
			キャリーフラグを得る
		*/
		public int cy()
		{
			return x & Z80Emulator.MASK_CY;
		}
		public int ncy()
		{
			return cy() ^ Z80Emulator.MASK_CY;
		}

		/*
			減算フラグを得る
		*/
		public int n()
		{
			return x & Z80Emulator.MASK_N;
		}

		/*
			パリティ/オーバーフローフラグを得る
		*/
		public int pv()
		{
			return x & Z80Emulator.MASK_PV;
		}
		public int npv()
		{
			return pv() ^ Z80Emulator.MASK_PV;
		}

		/*
			ハーフキャリーフラグを得る
		*/
		public int hc()
		{
			return x & Z80Emulator.MASK_HC;
		}

		/*
			ゼロフラグを得る
		*/
		public int z()
		{
			return x & Z80Emulator.MASK_Z;
		}
		public int nz()
		{
			return z() ^ Z80Emulator.MASK_Z;
		}

		/*
			サインフラグを得る
		*/
		public int s()
		{
			return x & Z80Emulator.MASK_S;
		}
		public int ns()
		{
			return s() ^ Z80Emulator.MASK_S;
		}
	}

	/*
		16bitレジスタ
	*/
	public class Register16
	{
		/* レジスタ(下位) */
		public Register8 l;

		/* レジスタ(上位) */
		public Register8 h;

		/*
			コンストラクタ
		*/
		public Register16(Register8 low, Register8 high)
		{
			l = low;
			h = high;
		}

		/*
			値を得る
		*/
		public int get()
		{
			return (h.x << 8) | l.x;
		}

		/*
			値を設定する
		*/
		public int set(int value)
		{
			l.x  = value & 0xff;
			h.x = (value >>> 8) & 0xff;

			return get();
		}
		public int set(Register16 value)
		{
			l.x = value.l.x;
			h.x = value.h.x;

			return get();
		}

		/*
			値が0か?
		*/
		public boolean isZero()
		{
			return get() == 0;
		}

		/*
			値を加算する
		*/
		public int add(int value)
		{
			return set(get() + value);
		}
	}

	/* キャリーフラグ */
	public static final int MASK_CY = 0x01;

	/* 減算フラグ */
	public static final int MASK_N  = 0x02;

	/* パリティ/オーバーフローフラグ */
	public static final int MASK_PV = 0x04;

	/* ハーフキャリーフラグ */
	public static final int MASK_HC = 0x10;

	/* ゼロフラグ */
	public static final int MASK_Z  = 0x40;

	/* サインフラグ */
	public static final int MASK_S  = 0x80;

	/* ステート数(xx) */
	private static final int[] statesXX = {
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
	};

	/* ステート数(CB xx) */
	private static final int[] statesCBXX = {
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
	};

	/* ステート数(DD/FD xx) */
	private static final int[] statesDDXX = {
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
	};

	/* ステート数(DD/FD CB xx) */
	private static final int[] statesDDCBXX = {
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
	};

	/* ステート数(ED xx) */
	private static final int[] statesEDXX = {
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
	};

	/* 命令長(xx) */
	private static final int[] lengthXX = {
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
	};

	/* 命令長(CB xx) */
	private static final int[] lengthCBXX = {
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
	};

	/* 命令長(DD/FD xx) */
	private static final int[] lengthDDXX = {
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
	};

	/* 命令長(DD/FD CB xx) */
	private static final int[] lengthDDCBXX = {
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
	};

	/* 命令長(ED xx) */
	private static final int[] lengthEDXX = {
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
	};

	/* パリティ結果表 */
	private static final int[] parity = {
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
	};

	/* Rレジスタ用乱数 */
	private static int rnd = 0xffffffff;

	/* 命令長 */
	private int length;

	/* ステート数 */
	private int states;

	/* 作業用レジスタ(8bit) */
	private Register8 tmpreg8;

	/* 作業用レジスタ(16bit) */
	private Register16 tmpreg16;

	/* アキュムレータ */
	public Register8 a;

	/* フラグ */
	public Register8 f;

	/* 汎用レジスタB */
	public Register8 b;

	/* 汎用レジスタC */
	public Register8 c;

	/* 汎用レジスタD */
	public Register8 d;

	/* 汎用レジスタE */
	public Register8 e;

	/* 汎用レジスタH */
	public Register8 h;

	/* 汎用レジスタL */
	public Register8 l;

	/* インデックスレジスタIX(上位) */
	public Register8 ixh;

	/* インデックスレジスタIX(下位) */
	public Register8 ixl;

	/* インデックスレジスタIY(上位) */
	public Register8 iyh;

	/* インデックスレジスタIY(下位) */
	public Register8 iyl;

	/* アキュムレータ・フラグ */
	public Register16 af;

	/* 汎用レジスタBC */
	public Register16 bc;

	/* 汎用レジスタDE */
	public Register16 de;

	/* 汎用レジスタHL */
	public Register16 hl;

	/* インデックスポインタIX */
	public Register16 ix;

	/* インデックスポインタIY */
	public Register16 iy;

	/* 補助レジスタAF' */
	public Register16 af_d;

	/* 補助レジスタBC' */
	public Register16 bc_d;

	/* 補助レジスタDE' */
	public Register16 de_d;

	/* 補助レジスタHL' */
	public Register16 hl_d;

	/* スタックポインタ */
	public Register16 sp;

	/* インタラプトレジスタ */
	public Register8 i;

	/* プログラムカウンタ */
	public int pc;

	/* 割り込みモード */
	public int im;

	/* IFF */
	public int iff;

	/* HALTか? */
	public boolean hlt;

	/*  */
	public int executeStates;

	/* 残りステート数 */
	public int restStates;

	/* 逆アセンブルするか? */
	public boolean trace;

	/*
		コンストラクタ
	*/
	public Z80Emulator()
	{
		im = 0;
		iff = 0;
		hlt = false;
		a = new Register8(0xff);
		f = new Register8(0xff);
		b = new Register8(0xff);
		c = new Register8(0xff);
		d = new Register8(0xff);
		e = new Register8(0xff);
		h = new Register8(0xff);
		l = new Register8(0xff);
		ixh = new Register8(0xff);
		ixl = new Register8(0xff);
		iyh = new Register8(0xff);
		iyl = new Register8(0xff);
		af = new Register16(f, a);
		bc = new Register16(c, b);
		de = new Register16(e, d);
		hl = new Register16(l, h);
		ix = new Register16(ixl, ixh);
		iy = new Register16(iyl, iyh);
		sp = new Register16(new Register8(0xff), new Register8(0xff));
		af_d = new Register16(new Register8(0xff), new Register8(0xff));
		bc_d = new Register16(new Register8(0xff), new Register8(0xff));
		de_d = new Register16(new Register8(0xff), new Register8(0xff));
		hl_d = new Register16(new Register8(0xff), new Register8(0xff));
		i = new Register8(0xff);
		tmpreg8 = new Register8();
		tmpreg16 = new Register16(tmpreg8, new Register8());
		pc = 0x0000;
		restStates = 0;
		trace = false;
	}

	/*
		ログを出力する
	*/
	public abstract void log(String message);

	/*
		メモリを読み込む (8bit)
	*/
	public abstract byte read(int address);
	public int read8(int address)
	{
		return ((int )read(address)) & 0xff;
	}
	public int read8(Register16 address)
	{
		return ((int )read(address.get())) & 0xff;
	}

	/*
		メモリを読み込む (16bit)
	*/
	public int read16(int address)
	{
		return read8(address) | (read8((address + 1) & 0xffff) << 8);
	}
	public int read16(Register16 address)
	{
		return read8(address.get()) | ((read8(address.get() + 1) & 0xffff) << 8);
	}

	/*
		メモリに書き込む (8bit)
	*/
	public abstract void write(int address, byte value);
	public void write8(int address, int value)
	{
		write(address, (byte )value);
	}
	public void write8(Register16 address, int value)
	{
		write(address.get(), (byte )value);
	}
	public void write8(int address, Register8 value)
	{
		write(address, (byte )value.get());
	}
	public void write8(Register16 address, Register8 value)
	{
		write(address.get(), (byte )value.get());
	}

	/*
		メモリに書き込む (16bit)
	*/
	public void write16(int address, int value)
	{
		write8(address, value & 0xff);
		write8((address + 1) & 0xffff, value >>> 8);
	}
	public void write16(Register16 address, int value)
	{
		write16(address.get(), value);
	}
	public void write16(int address, Register16 value)
	{
		write16(address, value.get());
	}
	public void write16(Register16 address, Register16 value)
	{
		write16(address.get(), value.get());
	}

	/*
		I/Oからの入力を得る
	*/
	public abstract int inport(int address);
	public int inport(Register8 address)
	{
		return inport(address.get());
	}

	/*
		I/Oへ出力する
	*/
	public abstract void outport(int address, int value);
	public void outport(Register8 address, int value)
	{
		outport(address.get(), value);
	}
	public void outport(int address, Register8 value)
	{
		outport(address, value.get());
	}
	public void outport(Register8 address, Register8 value)
	{
		outport(address.get(), value.get());
	}

	/*
		サブルーチン
	*/
	public abstract int subroutine(int address);

	/*
		符号ありに変換する
	*/
	private int toSigned(int value)
	{
		return (int )((byte )(value & 0xff));
	}

	/*
		Rの値を得る
	*/
	private int getR()
	{
		rnd = rnd * 8197 + 1;
		return (rnd >>> 25) & 0xff;
	}

	/*
		キャリーフラグを変化させる (8bit加算)
	*/
	private int setCy8(int acc)
	{
		return (acc & 0x00000100) != 0 ? MASK_CY: 0;
	}

	/*
		キャリーフラグを変化させる (16bit加算)
	*/
	private int setCy16(int acc)
	{
		return (acc & 0x00010000) != 0 ? MASK_CY: 0;
	}

	/*
		キャリーフラグを変化させる (減算時)
	*/
	private int setCyS(int acc)
	{
		return (acc & 0x80000000) != 0 ? MASK_CY: 0;
	}

	/*
		パリティ/オーバーフローフラグを変化させる (パリティ)
	*/
	private int setP(int acc)
	{
		return parity[acc & 0xff];
	}
	private int setP(Register8 r)
	{
		return parity[r.get() & 0xff];
	}

	/*
		パリティ/オーバーフローフラグを変化させる (8bit加算)
	*/
	private int setV8(int acc, int x, int y)
	{
		return (((x ^ y) & 0x80) != 0 ? 0: (((x ^ acc) & 0x80) != 0 ? MASK_PV: 0));
	}
	private int setV8(int acc, Register8 x, int y)
	{
		int _x = x.get();

		return (((_x ^ y) & 0x80) != 0 ? 0: (((_x ^ acc) & 0x80) != 0 ? MASK_PV: 0));
	}

	/*
		パリティ/オーバーフローフラグを変化させる (16bit加算)
	*/
	private int setV16(int acc, Register16 x, Register16 y)
	{
		int _x = x.get();
		int _y = y.get();

		return (((_x ^ _y) & 0x8000) != 0 ? 0: (((_x ^ acc) & 0x8000) != 0 ? MASK_PV: 0));
	}

	/*
		パリティ/オーバーフローフラグを変化させる (8bit減算)
	*/
	private int setV8S(int acc, int x, int y)
	{
		return (((x ^ y) & 0x80) != 0 ? (((x ^ acc) & 0x80) != 0 ? MASK_PV: 0): 0);
	}
	private int setV8S(int acc, Register8 x, int y)
	{
		int _x = x.get();

		return (((_x ^ y) & 0x80) != 0 ? (((_x ^ acc) & 0x80) != 0 ? MASK_PV: 0): 0);
	}
	private int setV8S(int acc, int x, Register8 y)
	{
		return (((x ^ y.get()) & 0x80) != 0 ? (((x ^ acc) & 0x80) != 0 ? MASK_PV: 0): 0);
	}

	/*
		パリティ/オーバーフローフラグを変化させる (16bit減算)
	*/
	private int setV16S(int acc, Register16 x, Register16 y)
	{
		int _x = x.get();

		return (((_x ^ y.get()) & 0x80) != 0 ? (((_x ^ acc) & 0x80) != 0 ? MASK_PV: 0): 0); /* ??? */
	}

	/*
		ハーフキャリーフラグを変化させる (8bit加算)
	*/
	private int setHC8(Register8 x, int y, int cy)
	{
		return ((x.get() & 0x0f) + (y & 0x0f) + cy) & 0x10;
	}
	private int setHC8(int x, int y)
	{
		return ((x & 0x0f) + (y & 0x0f)) & 0x10;
	}
	private int setHC8(Register8 x, int y)
	{
		return ((x.get() & 0x0f) + (y & 0x0f)) & 0x10;
	}

	/*
		ハーフキャリーフラグを変化させる (8bit減算)
	*/
	private int setHC8S(Register8 x, int y, int cy)
	{
		return ((x.get() & 0x0f) - (y & 0x0f) - cy) & 0x10;
	}
	private int setHC8S(int x, int y)
	{
		return ((x & 0x0f) - (y & 0x0f)) & 0x10;
	}
	private int setHC8S(Register8 x, int y)
	{
		return ((x.get() & 0x0f) - (y & 0x0f)) & 0x10;
	}
	private int setHC8S(int x, Register8 y)
	{
		return ((x & 0x0f) - (y.get() & 0x0f)) & 0x10;
	}

	/*
		ハーフキャリーフラグを変化させる (16bit加算)
	*/
	private int setHC16(Register16 x, Register16 y, int cy)
	{
		return (((x.get() & 0x0fff) + (y.get() & 0x0fff) + cy) & 0x1000) != 0 ? MASK_HC: 0;
	}
	private int setHC16(Register16 x, Register16 y)
	{
		return (((x.get() & 0x0fff) + (y.get() & 0x0fff)) & 0x1000) != 0 ? MASK_HC: 0;
	}

	/*
		ハーフキャリーフラグを変化させる (16bit減算)
	*/
	private int setHC16S(Register16 x, Register16 y, int cy)
	{
		return (((x.get() & 0x0fff) - (y.get() & 0x0fff) - cy) & 0x1000) != 0 ? MASK_HC: 0;
	}

	/*
		ゼロフラグを変化させる (8bit)
	*/
	private int setZ8(int acc)
	{
		return (acc & 0xff) != 0 ? 0: MASK_Z;
	}
	private int setZ8(Register8 r)
	{
		return (r.get() & 0xff) != 0 ? 0: MASK_Z;
	}

	/*
		ゼロフラグを変化させる (16bit)
	*/
	private int setZ16(int acc)
	{
		return (acc & 0xffff) != 0 ? 0: MASK_Z;
	}

	/*
		サインフラグを変化させる (8bit)
	*/
	private int setS8(int acc)
	{
		return (acc & 0x80) != 0 ? MASK_S: 0;
	}
	private int setS8(Register8 r)
	{
		return (r.get() & 0x80) != 0 ? MASK_S: 0;
	}

	/*
		サインフラグを変化させる (16bit)
	*/
	private int setS16(int acc)
	{
		return (acc & 0x8000) != 0 ? MASK_S: 0;
	}

	/*
		adc imm
		adc (HL)
		adc (IX+d)
		adc (IY+d)
	*/
	private void adc8(int n)
	{
		int acc = a.get() + n + f.cy();

		f.set(setCy8(acc) | setV8(acc, a, n) | setHC8(a, n, f.cy()) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
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
	*/
	private void adc8(Register8 r)
	{
		adc8(r.get());
	}

	/*
		adc HL,BC
		adc HL,DE
		adc HL,HL
		adc HL,SP
	*/
	private void adc16(Register16 r1, Register16 r2)
	{
		int acc = r1.get() + r2.get() + f.cy();

		f.set(setCy16(acc) | setV16(acc, r1, r2) | setHC16(r1, r2, f.cy()) | setZ16(acc) | setS16(acc));
		r1.set(acc);
		pc += length;
	}

	/*
		add imm
		add (HL)
		add (IX+d)
		add (IY+d)
	*/
	private void add8(int n)
	{
		int acc = a.get() + n;

		f.set(setCy8(acc) | setV8(acc, a, n) | setHC8(a, n) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		add B
		add C
		add D
		add E
		add H
		add L
		add A
		add IXH
		add IXL
		add IYH
		add IYL
	*/
	private void add8(Register8 r)
	{
		add8(r.get());
	}

	/*
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
	*/
	private void add16(Register16 r1, Register16 r2)
	{
		int acc = r1.get() + r2.get();

		f.set(setCy16(acc) | f.pv() | setHC16(r1, r2) | f.z() | f.s());
		r1.set(acc);
		pc += length;
	}

	/*
		and imm
		and (HL)
		and (IX+d)
		and (IY+d)
	*/
	private void and(int n)
	{
		int acc = a.get() & n;

		f.set(setP(acc) | MASK_HC | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
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
	*/
	private void and(Register8 r)
	{
		and(r.get());
	}

	/*
		bit n, (HL)
		bit n, (IX+d)
		bit n, (IY+d)
	*/
	private void bit(int b, int n)
	{
		f.set(f.cy() | ((n & (1 << b)) != 0 ? 0: MASK_PV) | MASK_HC | ((n & (1 << b)) != 0 ? 0: MASK_Z) | (n & 0x80 & (1 << b)));
		pc += length;
	}

	/*
		bit n, B
		bit n, C
		bit n, D
		bit n, E
		bit n, H
		bit n, L
		bit n, A
	*/
	private void bit(int b, Register8 r)
	{
		bit(b, r.get());
	}

	/*
		割り込みまたはcall
	*/
	private boolean interrupt(int address)
	{
		int s;

		states += 7;

		s = subroutine(address);
		sp.add(-2);
		write16(sp, pc);
		pc = address;

		if(s < 0) {
			/* 通常のcall */
			return false;
		} else {
			/* サブルーチンのエミュレート */
			pc = read16(sp);
			sp.add(2);
			states += s;
			return (s == 0);
		}
	}

	/*
		call mn
		call NZ, mn
		call Z, mn
		call NC, mn
		call C, mn
		call PO, mn
		call PE, mn
		call P, mn
		call M, mn
	*/
	private boolean call(int condition, int address)
	{
		pc += length;

		if(condition != 0)
			if(interrupt(address)) {
				pc -= length;
				return true;
			}

		return false;
	}

	/*
		ccf
	*/
	private void ccf()
	{
		f.set((f.cy() ^ MASK_CY) | f.pv() | (f.cy() != 0 ? MASK_HC: 0) | f.z() | f.s());
		pc += length;
	}

	/*
		cp imm
		cp (HL)
		cp (IX+d)
		cp (IY+d)
	*/
	private void cp(int n)
	{
		int acc = a.get() - n;

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		pc += length;
	}

	/*
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
	*/
	private void cp(Register8 r)
	{
		cp(r.get());
	}

	/*
		cpd
	*/
	private void cpd()
	{
		int n = read8(hl);
		int acc = a.get() - n;

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		bc.add(-1);
		hl.add(-1);
		pc += length;
	}

	/*
		cpdr
	*/
	private void cpdr()
	{
		int n;
		int acc;

		do {
			n = read8(hl);
			acc = a.get() - n;
			f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
			bc.add(-1);
			hl.add(-1);
			states += 21;
		} while(!bc.isZero() && acc != 0);
		states -= 5;
		pc += length;
	}

	/*
		cpi
	*/
	private void cpi()
	{
		int n = read8(hl);
		int acc = a.get() - n;

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		bc.add(-1);
		hl.add(1);
		pc += length;
	}

	/*
		cpir
	*/
	private void cpir()
	{
		int n;
		int acc;

		do {
			n = read8(hl);
			acc = a.get() - n;
			f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
			bc.add(-1);
			hl.add(1);
			states += 21;
		} while(!bc.isZero() && acc != 0);
		states -= 5;
		pc += length;
	}

	/*
		cpl
	*/
	private void cpl()
	{
		int acc = ~a.get();

		f.set(f.get() | MASK_N | MASK_HC);
		a.set(acc);
		pc += length;
	}

	/*
		daa
	*/
	private void daa()
	{
		int n;
		int cy;
		int acc;

		switch(f.get() & (MASK_CY | MASK_N | MASK_HC)) {
		case 0:
			if(a.get() < 0x9a) {
				if((a.get() & 0x0f) < 0x0a) {
					n  = 0x00;
					cy = 0;
				} else {
					n  = 0x06;
					cy = 0;
				}
			} else {
				if((a.get() & 0x0f) < 0x0a) {
					n = 0x60;
					cy = MASK_CY;
				} else {
					n  = 0x66;
					cy = MASK_CY;
				}
			}
			break;
		case MASK_CY:
			if((a.get() & 0x0f) < 0x0a) {
				n  = 0x60;
				cy = MASK_CY;
			} else {
				n  = 0x66;
				cy = MASK_CY;
			}
			break;
		case MASK_N:
			if(a.get() < 0x9a) {
				if((a.get() & 0x0f) < 0x0a) {
					n  = 0x00;
					cy = 0;
				} else {
					n  = 0xfa;
					cy = 0;
				}
			} else {
				if((a.get() & 0x0f) < 0x0a) {
					n  = 0xa0;
					cy = MASK_CY;
				} else {
					n  = 0x9a;
					cy = MASK_CY;
				}
			}
			break;
		case MASK_CY | MASK_N:
			if((a.get() & 0x0f) < 0x0a) {
				n  = 0xa0;
				cy = MASK_CY;
			} else {
				n  = 0x9a;
				cy = MASK_CY;
			}
			break;
		case MASK_HC:
			if(a.get() < 0x9a) {
				n  = 0x06;
				cy = 0;
			} else {
				n  = 0x66;
				cy = MASK_CY;
			}
			break;
		case MASK_CY | MASK_HC:
			n  = 0x66;
			cy = MASK_CY;
			break;
		case MASK_N | MASK_HC:
			if(a.get() < 0x9a) {
				n  = 0xfa;
				cy = 0;
			} else {
				n  = 0x9a;
				cy = MASK_CY;
			}
			break;
		case MASK_CY | MASK_N | MASK_HC:
			n  = 0x9a;
			cy = MASK_CY;
			break;
		default:
			n  = 0;
			cy = 0;
			break;
		}
		acc = a.get() + n;

		f.set(cy | f.n() | setP(acc) | setHC8(a, n) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
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
	*/
	private void dec8_r(Register8 r)
	{
		int acc = r.get() - 1;

		f.set(f.cy() | MASK_N | setV8S(acc, r, 1) | setHC8S(r, 1) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		dec (IX+d)
		dec (IY+d)
	*/
	private void dec8_m(int address)
	{
		int n = read8(address);
		int acc = n - 1;

		f.set(f.cy() | MASK_N | setV8S(acc, n, 1) | setHC8S(n, 1) | setZ8(acc) | setS8(acc));
		write8(address, acc);
		pc += length;
	}

	/*
		dec (HL)
	*/
	private void dec8_m(Register16 address)
	{
		dec8_m(address.get());
	}

	/*
		dec BC
		dec DE
		dec HL
		dec SP
		dec IX
		dec IY
	*/
	private void dec16(Register16 r)
	{
		r.add(-1);
		pc += length;
	}

	/*
		di
	*/
	private void di()
	{
		iff = 0;
		pc += length;
	}

	/*
		djnz d
	*/
	private void djnz(int d)
	{
		b.add(-1);
		if(!b.isZero()) {
			pc += d;
			states += 5;
		}
		pc += length;
	}

	/*
		ei
	*/
	private boolean ei()
	{
		pc += length;
		if(iff != 3) {
			iff = 3;
			restStates -= states;
			return true;
		} else
			return false;
	}

	/*
		ex AF, AF'
		ex DE, HL
	*/
	private void ex_r(Register16 r1, Register16 r2)
	{
		tmpreg16.set(r1); r1.set(r2); r2.set(tmpreg16);
		pc += length;
	}

	/*
		ex (SP), HL
		ex (SP), IX
		ex (SP), IY
	*/
	private void ex_sp(Register16 r)
	{
		int tmp;

		tmp = read16(sp); write16(sp, r); r.set(tmp);
		pc += length;
	}

	/*
		exx
	*/
	private void exx()
	{
		tmpreg16.set(bc); bc.set(bc_d); bc_d.set(tmpreg16);
		tmpreg16.set(de); de.set(de_d); de_d.set(tmpreg16);
		tmpreg16.set(hl); hl.set(hl_d); hl_d.set(tmpreg16);
		pc += length;
	}

	/*
		halt
	*/
	private void halt()
	{
		hlt = true;
		restStates = 0;
		pc += length;
	}

	/*
		im 0
		im 1
		im 2
	*/
	private void im(int mode)
	{
		im = mode;
		pc += length;
	}

	/*
		in A, (n)
	*/
	private void in_n(int n)
	{
		a.set(inport(n));
		pc += length;
	}

	/*
		in B, (C)
		in C, (C)
		in D, (C)
		in E, (C)
		in H, (C)
		in L, (C)
		in F, (C)
		in A, (C)
	*/
	private void in_c(Register8 r)
	{
		r.set(inport(c));
		f.set(f.cy() | setP(r) | setZ8(r) | setS8(r));
		pc += length;
	}

	/*
		ind
	*/
	private void ind()
	{
		int n;

		n = inport(c);
		write8(hl, n);
		b.add(-1);
		hl.add(-1);
		f.set(f.cy() | ((n & 0x80) != 0 ? MASK_N: 0) | f.pv() | f.hc() | (b.isZero() ? MASK_Z: 0) | f.s());
		pc += length;
	}

	/*
		indr
	*/
	private void indr()
	{
		int n;

		while(!b.isZero()) {
			n = inport(c);
			write8(hl, n);
			b.add(-1);
			hl.add(-1);
			states += 21;
		}
		states -= 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc += length;
	}

	/*
		ini
	*/
	private void ini()
	{
		int n;

		n = inport(c);
		write8(hl, n);
		b.add(-1);
		hl.add(1);
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() ? MASK_Z: 0) | f.s());
		pc += length;
	}

	/*
		inir
	*/
	private void inir()
	{
		int n;

		while(!b.isZero()) {
			n = inport(c);
			write8(hl, n);
			b.add(-1);
			hl.add(1);
			states += 21;
		}
		states -= 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc += length;
	}

	/*
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
	*/
	private void inc8_r(Register8 r)
	{
		int acc = r.get() + 1;

		f.set(f.cy() | setV8(acc, r, 1) | setHC8(r, 1) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		inc (IX+d)
		inc (IY+d)
	*/
	private void inc8_m(int address)
	{
		int n = read8(address);
		int acc = n + 1;

		f.set(f.cy() | setV8(acc, n, 1) | setHC8(n, 1) | setZ8(acc) | setS8(acc));
		write8(address, acc);
		pc += length;
	}

	/*
		inc (HL)
	*/
	private void inc8_m(Register16 address)
	{
		inc8_m(address.get());
	}

	/*
		inc BC
		inc DE
		inc HL
		inc SP
		inc IX
		inc IY
	*/
	private void inc16(Register16 r)
	{
		r.add(1);
		pc += length;
	}

	/*
		jp mn
		jp NZ, mn
		jp Z, mn
		jp NC, mn
		jp C, mn
		jp PO, mn
		jp PE, mn
		jp P, mn
		jp M, mn
	*/
	private boolean jp(int condition, int address)
	{
		if(condition != 0) {
			int s, old_pc;

			s = subroutine(address);
			old_pc = pc;
			pc = address;

			if(s < 0) {
				return false;
			} else if(s > 0) {
				pc = read16(sp);
				sp.add(2);
				states += s;
				return false;
			} else {
				pc = old_pc;
				return true;
			}
		} else {
			pc += length;
			return false;
		}
	}

	/*
		jp (HL)
		jp (IX)
		jp (IY)
	*/
	private boolean jp(int condition, Register16 address)
	{
		return jp(condition, address.get());
	}

	/*
		jr d
		jr NZ, d
		jr Z, d
		jr NC, d
		jr C, d
	*/
	private void jr(int condition, int d)
	{
		if(condition != 0) {
			states += 5;
			pc += d;
		}
		pc += length;
	}

	/*
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
	*/
	private void ld8(Register8 r, int n)
	{
		r.set(n);
		pc += length;
	}

	/*
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
	*/
	private void ld8(Register8 r1, Register8 r2)
	{
		ld8(r1, r2.get());
	}

	/*
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
	*/
	private void ld16(Register16 r, int n)
	{
		r.set(n);
		pc += length;
	}

	/*
		ld SP, HL
		ld SP, IX
		ld SP, IY
	*/
	private void ld16(Register16 r1, Register16 r2)
	{
		r1.set(r2.get());
		pc += length;
	}

	/*
		ld A, I
	*/
	private void ld_a_i()
	{
		int acc = i.get();

		f.set(f.cy() | ((iff & 0x02) != 0 ? 0: MASK_PV) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		ld A, R
	*/
	private void ld_a_r()
	{
		int acc = getR();

		f.set(f.cy() | ((iff & 0x02) != 0 ? 0: MASK_PV) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		ld (IX+d), n
		ld (IY+d), n
	*/
	private void st8(int address, int n)
	{
		write8(address, n);
		pc += length;
	}

	/*
		ld (HL), n
	*/
	private void st8(Register16 address, int n)
	{
		st8(address.get(), n);
	}

	/*
		ld (mn), A
		ld (IX+d), r
		ld (IY+d), r
	*/
	private void st8(int address, Register8 r)
	{
		st8(address, r.get());
	}

	/*
		ld (BC), A
		ld (DE), A
		ld (HL), r
	*/
	private void st8(Register16 address, Register8 r)
	{
		st8(address.get(), r.get());
	}

	/*
		ld (mn), BC
		ld (mn), DE
		ld (mn), HL
		ld (mn), IX
		ld (mn), IY
		ld (mn), SP
	*/
	private void st16(int address, Register16 r)
	{
		write16(address, r);
		pc += length;
	}

	/*
		ldd
	*/
	private void ldd()
	{
		write8(de, read8(hl));
		de.add(-1);
		hl.add(-1);
		bc.add(-1);
		f.set(f.cy() | (!bc.isZero() ? MASK_PV: 0) | f.z() | f.s());
		pc += length;
	}

	/*
		lddr
	*/
	private void lddr()
	{
		do {
			write8(de, read8(hl));
			de.add(-1);
			hl.add(-1);
			bc.add(-1);
			states += 21;
		} while(!bc.isZero());
		states -= 5;
		f.set(f.cy() | f.z() | f.s());
		pc += length;
	}

	/*
		ldi
	*/
	private void ldi()
	{
		write8(de, read8(hl));
		bc.add(-1);
		de.add(1);
		hl.add(1);
		f.set(f.cy() | (!bc.isZero() ? MASK_PV: 0) | f.z() | f.s());
		pc += length;
	}

	/*
		ldir
	*/
	private void ldir()
	{
		do {
			write8(de, read8(hl));
			bc.add(-1);
			de.add(1);
			hl.add(1);
			states += 21;
		} while(!bc.isZero());
		states -= 5;
		f.set(f.cy() | f.z() | f.s());
		pc += length;
	}

	/*
		neg
	*/
	private void neg()
	{
		int acc = -a.get();

		f.set(setCyS(acc) | MASK_N | setV8S(acc, 0, a) | setHC8S(0, a) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		nop
	*/
	private void nop()
	{
		pc += length;
	}

	/*
		or imm
		or (HL)
		or (IX+d)
		or (IY+d)
	*/
	private void or(int n)
	{
		int acc = a.get() | n;

		f.set(setP(acc) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
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
	*/
	private void or(Register8 r)
	{
		or(r.get());
	}

	/*
		out (n), A
	*/
	private void out_n(int n)
	{
		outport(n, a);
		pc += length;
	}

	/*
		out (C), B
		out (C), C
		out (C), D
		out (C), E
		out (C), H
		out (C), L
		out (C), A
	*/
	private void out_c(Register8 r)
	{
		outport(c, r);
		pc += length;
	}

	/*
		out (C), 0
	*/
	private void out_c_0()
	{
		outport(c, 0);
		pc += length;
	}

	/*
		outd
	*/
	private void outd()
	{
		outport(c, read8(hl));
		b.add(-1);
		hl.add(-1);
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() ? MASK_Z: 0) | f.s());
		pc += length;
	}

	/*
		otdr
	*/
	private void otdr()
	{
		while(!b.isZero()) {
			outport(c, read8(hl));
			b.add(-1);
			hl.add(-1);
			states += 21;
		}
		states -= 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc += length;
	}

	/*
		outi
	*/
	private void outi()
	{
		outport(c, read8(hl));
		b.add(-1);
		hl.add(1);
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | (b.isZero() ? MASK_Z: 0) | f.s());
		pc += length;
	}

	/*
		otir
	*/
	private void otir()
	{
		while(!b.isZero()) {
			outport(c, read8(hl));
			b.add(-1);
			hl.add(1);
			states += 21;
		}
		states -= 5;
		f.set(f.cy() | MASK_N | f.pv() | f.hc() | MASK_Z | f.s());
		pc += length;
	}

	/*
		pop AF
		pop BC
		pop DE
		pop HL
		pop IX
		pop IY
	*/
	private void pop(Register16 r)
	{
		r.l.set(read8(sp));
		sp.add(1);
		r.h.set(read8(sp));
		sp.add(1);
		pc += length;
	}

	/*
		push AF
		push BC
		push DE
		push HL
		push IX
		push IY
	*/
	private void push(Register16 r)
	{
		sp.add(-1);
		write8(sp, r.h.get());
		sp.add(-1);
		write8(sp, r.l.get());
		pc += length;
	}

	/*
		res n, B
		res n, C
		res n, D
		res n, E
		res n, H
		res n, L
		res n, A
	*/
	private void res_r(int b, Register8 r)
	{
		r.set(r.get() & ~(1 << b));
		pc += length;
	}

	/*
		res n, (IX+d), r
		res n, (IY+d), r
	*/
	private void res_m_r(int b, int address, Register8 r)
	{
		r.set(read8(address));
		res_r(b, r);
		write8(address, r);
	}

	/*
		res n, (IX+d)
		res n, (IY+d)
	*/
	private void res_m(int b, int address)
	{
		res_m_r(b, address, tmpreg8);
	}

	/*
		res n, (HL)
	*/
	private void res_m(int b, Register16 address)
	{
		res_m(b, address.get());
	}

	/*
		ret
		ret NZ
		ret Z
		ret NC
		ret C
		ret PO
		ret PE
		ret P
		ret M
	*/
	private void ret(int condition)
	{
		if(condition != 0) {
			pc = read16(sp);
			sp.add(2);
			states += 6;
		} else
			pc += length;
	}

	/*
		reti
	*/
	private void reti()
	{
		ret(1);
	}

	/*
		retn
	*/
	private void retn()
	{
		iff = (iff << 1) & 0x03;
		ret(1);
	}

	/*
		rl B
		rl C
		rl D
		rl E
		rl H
		rl L
		rl A
	*/
	private void rl_r(Register8 r)
	{
		int acc = (r.get() << 1) | f.cy();

		f.set(((r.get() & 0x80) != 0 ? MASK_CY: 0) | setP(acc) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		rl (IX+d), r
		rl (IY+d), r
	*/
	private void rl_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		rl_r(r);
		write8(address, r);
	}

	/*
		rl (IX+d)
		rl (IY+d)
	*/
	private void rl_m(int address)
	{
		rl_m_r(address, tmpreg8);
	}

	/*
		rl (HL)
	*/
	private void rl_m(Register16 address)
	{
		rl_m(address.get());
	}

	/*
		rla
	*/
	private void rla()
	{
		int acc = (a.get() << 1) | f.cy();

		f.set(((a.get() & 0x80) != 0 ? MASK_CY: 0) | f.pv() | f.z() | f.s());
		a.set(acc);
		pc += length;
	}

	/*
		rlc B
		rlc C
		rlc D
		rlc E
		rlc H
		rlc L
		rlc A
	*/
	private void rlc_r(Register8 r)
	{
		int acc = (r.get() << 1) | ((r.get() & 0x80) != 0 ? 0x01: 0);

		f.set(((r.get() & 0x80) != 0 ? MASK_CY: 0) | setP(acc) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		rlc (IX+d), r
		rlc (IY+d), r
	*/
	private void rlc_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		rlc_r(r);
		write8(address, r);
	}

	/*
		rlc (IX+d)
		rlc (IY+d)
	*/
	private void rlc_m(int address)
	{
		rlc_m_r(address, tmpreg8);
	}

	/*
		rlc (HL)
	*/
	private void rlc_m(Register16 address)
	{
		rlc_m(address.get());
	}

	/*
		rlca
	*/
	private void rlca()
	{
		int acc = (a.get() << 1) | ((a.get() & 0x80) != 0 ? 0x01: 0);

		f.set(((a.get() & 0x80) != 0 ? MASK_CY: 0) | f.pv() | f.z() | f.s());
		a.set(acc);
		pc += length;
	}

	/*
		rld
	*/
	private void rld()
	{
		int acc = (a.get() & 0xf0) | (read8(hl) >>> 4);

		write8(hl, (read8(hl) << 4) | (a.get() & 0x0f));
		f.set(f.cy() | setP(acc) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		rr B
		rr C
		rr D
		rr E
		rr H
		rr L
		rr A
	*/
	private void rr_r(Register8 r)
	{
		int acc = (r.get() >>> 1) | (f.cy() != 0 ? 0x80: 0);

		f.set((r.get() & 0x01) | setP(acc) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		rr (IX+d), r
		rr (IY+d), r
	*/
	private void rr_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		rr_r(r);
		write8(address, r);
	}

	/*
		rr (IX+d)
		rr (IY+d)
	*/
	private void rr_m(int address)
	{
		rr_m_r(address, tmpreg8);
	}

	/*
		rr (HL)
	*/
	private void rr_m(Register16 address)
	{
		rr_m(address.get());
	}

	/*
		rra
	*/
	private void rra()
	{
		int acc = (a.get() >>> 1) | (f.cy() != 0 ? 0x80: 0);

		f.set((a.get() & 0x01) | f.pv() | f.z() | f.s());
		a.set(acc);
		pc += length;
	}

	/*
		rrc B
		rrc C
		rrc D
		rrc E
		rrc H
		rrc L
		rrc A
	*/
	private void rrc_r(Register8 r)
	{
		int acc = (r.get() >>> 1) | ((r.get() & 0x01) != 0 ? 0x80: 0);

		f.set((r.get() & 0x01) | setP(acc) | setZ8(acc) | setS8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		rrc (IX+d), r
		rrc (IY+d), r
	*/
	private void rrc_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		rrc_r(r);
		write8(address, r);
	}

	/*
		rrc (IX+d)
		rrc (IY+d)
	*/
	private void rrc_m(int address)
	{
		rrc_m_r(address, tmpreg8);
	}

	/*
		rrc (HL)
	*/
	private void rrc_m(Register16 address)
	{
		rrc_m(address.get());
	}

	/*
		rrca
	*/
	private void rrca()
	{
		int acc = (a.get() >>> 1) | ((a.get() & 0x01) != 0 ? 0x80: 0);

		f.set((a.get() & 0x01) | f.pv() | f.z() | f.s());
		a.set(acc);
		pc += length;
	}

	/*
		rrd
	*/
	private void rrd()
	{
		int acc = (a.get() & 0xf0) | (read8(hl) & 0x0f);

		write8(hl, (read8(hl) >>> 4) | (a.get() << 4));
		f.set(f.cy() | setP(acc) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		rst 0x00
		rst 0x08
		rst 0x10
		rst 0x18
		rst 0x20
		rst 0x28
		rst 0x30
		rst 0x38
	*/
	private void rst(int address)
	{
		call(1, address);
	}

	/*
		sbc imm
		sbc (HL)
		sbc (IX+d)
		sbc (IY+d)
	*/
	private void sbc8(int n)
	{
		int acc = a.get() - n - f.cy();

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n, f.cy()) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
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
	*/
	private void sbc8(Register8 r)
	{
		sbc8(r.get());
	}

	/*
		sbc HL,BC
		sbc HL,DE
		sbc HL,HL
		sbc HL,SP
	*/
	private void sbc16(Register16 r1, Register16 r2)
	{
		int acc = r1.get() - r2.get() - f.cy();

		f.set(setCyS(acc) | MASK_N | setV16S(acc, r1, r2) | setHC16S(r1, r2, f.cy()) | setZ16(acc) | setS16(acc));
		r1.set(acc);
		pc += length;
	}

	/*
		scf
	*/
	private void scf()
	{
		f.set(f.get() | MASK_CY);
		pc += length;
	}

	/*
		set n, B
		set n, C
		set n, D
		set n, E
		set n, H
		set n, L
		set n, A
	*/
	private void set_r(int n, Register8 r)
	{
		r.set(r.get() | (1 << n));
		pc += length;
	}

	/*
		set n, (IX+d), r
		set n, (IY+d), r
	*/
	private void set_m_r(int n, int address, Register8 r)
	{
		r.set(read8(address));
		set_r(n, r);
		write8(address, r);
	}

	/*
		set n, (IX+d)
		set n, (IY+d)
	*/
	private void set_m(int n, int address)
	{
		set_m_r(n, address, tmpreg8);
	}

	/*
		set n, (HL)
	*/
	private void set_m(int n, Register16 address)
	{
		set_m(n, address.get());
	}

	/*
		sla B
		sla C
		sla D
		sla E
		sla H
		sla L
		sla A
	*/
	private void sla_r(Register8 r)
	{
		int acc = r.get() << 1;

		f.set(((r.get() & 0x80) != 0 ? MASK_CY: 0) | setP(acc) | setS8(acc) | setZ8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		sla (HL), r
		sla (IX+d), r
		sla (IY+d), r
	*/
	private void sla_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		sla_r(r);
		write8(address, r);
	}

	/*
		sla (HL)
		sla (IX+d)
		sla (IY+d)
	*/
	private void sla_m(int address)
	{
		sla_m_r(address, tmpreg8);
	}

	/*
		sla (HL)
	*/
	private void sla_m(Register16 address)
	{
		sla_m(address.get());
	}

	/*
		sll B
		sll C
		sll D
		sll E
		sll H
		sll L
		sll A
	*/
	private void sll_r(Register8 r)
	{
		int acc = (r.get() << 1) | 1;

		f.set(((r.get() & 0x80) != 0 ? MASK_CY: 0) | setP(acc) | setS8(acc) | setZ8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		sll (IX+d), r
		sll (IY+d), r
	*/
	private void sll_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		sll_r(r);
		write8(address, r);
	}

	/*
		sll (IX+d)
		sll (IY+d)
	*/
	private void sll_m(int address)
	{
		sll_m_r(address, tmpreg8);
	}

	/*
		sll (HL)
	*/
	private void sll_m(Register16 address)
	{
		sll_m(address.get());
	}

	/*
		sra B
		sra C
		sra D
		sra E
		sra H
		sra L
		sra A
	*/
	private void sra_r(Register8 r)
	{
		int acc = (r.get() >>> 1) | (r.get() & 0x80);

		f.set(((r.get() & 0x01) != 0 ? MASK_CY: 0) | setP(acc) | setS8(acc) | setZ8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		sra (IX+d), r
		sra (IY+d), r
	*/
	private void sra_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		sra_r(r);
		write8(address, r);
	}

	/*
		sra (IX+d)
		sra (IY+d)
	*/
	private void sra_m(int address)
	{
		sra_m_r(address, tmpreg8);
	}

	/*
		sra (HL)
	*/
	private void sra_m(Register16 address)
	{
		sra_m(address.get());
	}

	/*
		srl B
		srl C
		srl D
		srl E
		srl H
		srl L
		srl A
	*/
	private void srl_r(Register8 r)
	{
		int acc = r.get() >>> 1;

		f.set(((r.get() & 0x01) != 0 ? MASK_CY: 0) | setP(acc) | setS8(acc) | setZ8(acc));
		r.set(acc);
		pc += length;
	}

	/*
		srl (IX+d), r
		srl (IY+d), r
	*/
	private void srl_m_r(int address, Register8 r)
	{
		r.set(read8(address));
		srl_r(r);
		write8(address, r);
	}

	/*
		srl (IX+d)
		srl (IY+d)
	*/
	private void srl_m(int address)
	{
		srl_m_r(address, tmpreg8);
	}

	/*
		srl (HL)
	*/
	private void srl_m(Register16 address)
	{
		srl_m(address.get());
	}

	/*
		sub imm
		sub (HL)
		sub (IX+d)
		sub (IY+d)
	*/
	private void sub8(int n)
	{
		int acc = a.get() - n;

		f.set(setCyS(acc) | MASK_N | setV8S(acc, a, n) | setHC8S(a, n) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
		sub B
		sub C
		sub D
		sub E
		sub H
		sub L
		sub A
		sub IXH
		sub IXL
		sub IYH
		sub IYL
	*/
	private void sub8(Register8 r)
	{
		sub8(r.get());
	}

	/*
		xor imm
		xor (HL)
		xor (IX+d)
		xor (IY+d)
	*/
	private void xor(int n)
	{
		int acc = a.get() ^ n;

		f.set(setP(acc) | setZ8(acc) | setS8(acc));
		a.set(acc);
		pc += length;
	}

	/*
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
	*/
	private void xor(Register8 r)
	{
		xor(r.get());
	}

	/*
		フェッチする (xx)
	*/
	private int fetchXX()
	{
		int op = read8(pc);

		length = lengthXX[op];
		states = statesXX[op];
		return op;
	}

	/*
		フェッチする (CB xx)
	*/
	private int fetchCBXX()
	{
		int op = read8(pc);

		length = lengthCBXX[op];
		states = statesCBXX[op];
		return op;
	}

	/*
		フェッチする (DD xx)
	*/
	private int fetchDDXX()
	{
		int op = read8(pc);

		length = lengthDDXX[op];
		states = statesDDXX[op];
		return op;
	}

	/*
		フェッチする (DD CB xx)
	*/
	private int fetchDDCBXX()
	{
		int op = read8((pc + 2) & 0xffff);

		length = lengthDDCBXX[op];
		states = statesDDCBXX[op];
		return op;
	}

	/*
		フェッチする (ED xx)
	*/
	private int fetchEDXX()
	{
		int op = read8(pc);

		length = lengthEDXX[op];
		states = statesEDXX[op];
		return op;
	}

	/*
		フェッチする (FD xx)
	*/
	private int fetchFDXX()
	{
		return fetchDDXX();
	}

	/*
		フェッチする (FD CB xx)
	*/
	private int fetchFDCBXX()
	{
		return fetchDDCBXX();
	}

	/*
		メモリを得る (8bit)
	*/
	private int mem8(int address)
	{
		return read8(address);
	}
	private int mem8(Register16 address)
	{
		return read8(address.get());
	}

	/*
		メモリを得る (16bit)
	*/
	private int mem16(int address)
	{
		return read16(address);
	}

	/*
		即値を得る (8bit)
	*/
	private int imm8()
	{
		return read8(pc + 1);
	}

	/*
		即値を得る (16bit)
	*/
	private int imm16()
	{
		return read16(pc + 1);
	}

	/*
		相対アドレスを得る
	*/
	private int dis()
	{
		return toSigned(read8(pc + 1));
	}

	/*
		RESET信号を送る
	*/
	public boolean reset()
	{
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
	}

	/*
		INT信号を送る (IM1)
	*/
	public boolean int1()
	{
		if(!(im == 1 && iff == 3))
			return false;

		hlt = false;
		iff = 0;
		states -= 13;

		interrupt(0x38);
		return true;
	}

	/*
		トレースを出力する
	*/
	/*
	private void disassemble()
	{
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
		(hlt ? "HALT": ""),
		0
		));
	}
	*/

	/*
		実行する
	*/
	public int execute(int execute_states)
	{
		executeStates = restStates = execute_states;

		if(hlt) {
			/*
			if(trace)
				disassemble();
			*/
			restStates = 0;
			return 0;
		}

		do {
			/*
			if(trace)
				disassemble();
			*/

			switch(fetchXX()) {
			case 0x00: nop();             break;	/* nop */
			case 0x01: ld16(bc, imm16()); break;	/* ld BC, mn */
			case 0x02: st8(bc, a);        break;	/* ld (BC), A */
			case 0x03: inc16(bc);         break;	/* inc BC */
			case 0x04: inc8_r(b);         break;	/* inc B */
			case 0x05: dec8_r(b);         break;	/* dec B */
			case 0x06: ld8(b, imm8());    break;	/* ld B, n */
			case 0x07: rlca();            break;	/* rlca */

			case 0x08: ex_r(af, af_d);   break;	/* ex AF, AF' */
			case 0x09: add16(hl, bc);    break;	/* add HL, BC */
			case 0x0a: ld8(a, mem8(bc)); break;	/* ld A, (BC) */
			case 0x0b: dec16(bc);        break;	/* dec BC */
			case 0x0c: inc8_r(c);        break;	/* inc C */
			case 0x0d: dec8_r(c);        break;	/* dec C */
			case 0x0e: ld8(c, imm8());   break;	/* ld C, n */
			case 0x0f: rrca();           break;	/* rrca */

			case 0x10: djnz(dis());       break;	/* djnz e */
			case 0x11: ld16(de, imm16()); break;	/* ld DE, mn */
			case 0x12: st8(de, a);        break;	/* ld (DE), A */
			case 0x13: inc16(de);         break;	/* inc DE */
			case 0x14: inc8_r(d);         break;	/* inc D */
			case 0x15: dec8_r(d);         break;	/* dec D */
			case 0x16: ld8(d, imm8());    break;	/* ld D, n */
			case 0x17: rla();             break;	/* rla */

			case 0x18: jr(1, dis());     break;	/* jr e */
			case 0x19: add16(hl, de);    break;	/* add HL, DE */
			case 0x1a: ld8(a, mem8(de)); break;	/* ld A, (DE) */
			case 0x1b: dec16(de);        break;	/* dec DE */
			case 0x1c: inc8_r(e);        break;	/* inc E */
			case 0x1d: dec8_r(e);        break;	/* dec E */
			case 0x1e: ld8(e, imm8());   break;	/* ld E, n */
			case 0x1f: rra();            break;	/* rra */

			case 0x20: jr(f.nz(), dis()); break;	/* jr NZ, e */
			case 0x21: ld16(hl, imm16()); break;	/* ld HL, mn */
			case 0x22: st16(imm16(), hl); break;	/* ld (mn), HL */
			case 0x23: inc16(hl);         break;	/* inc HL */
			case 0x24: inc8_r(h);         break;	/* inc H */
			case 0x25: dec8_r(h);         break;	/* dec H */
			case 0x26: ld8(h, imm8());    break;	/* ld H, n */
			case 0x27: daa();             break;	/* daa */

			case 0x28: jr(f.z(), dis());         break;	/* jr Z, e */
			case 0x29: add16(hl, hl);            break;	/* add HL, HL */
			case 0x2a: ld16(hl, mem16(imm16())); break;	/* ld HL, (mn) */
			case 0x2b: dec16(hl);                break;	/* dec HL */
			case 0x2c: inc8_r(l);                break;	/* inc L */
			case 0x2d: dec8_r(l);                break;	/* dec L */
			case 0x2e: ld8(l, imm8());           break;	/* ld L, n */
			case 0x2f: cpl();                    break;	/* cpl */

			case 0x30: jr(f.ncy(), dis()); break;	/* jr NC, e */
			case 0x31: ld16(sp, imm16());  break;	/* ld SP, mn */
			case 0x32: st8(imm16(), a);    break;	/* ld (mn), A */
			case 0x33: inc16(sp);          break;	/* inc SP */
			case 0x34: inc8_m(hl);         break;	/* inc (HL) */
			case 0x35: dec8_m(hl);         break;	/* dec (HL) */
			case 0x36: st8(hl, imm8());    break;	/* ld (HL), n */
			case 0x37: scf();              break;	/* scf */

			case 0x38: jr(f.cy(), dis());     break;	/* jr C, e */
			case 0x39: add16(hl, sp);         break;	/* add HL, SP */
			case 0x3a: ld8(a, mem8(imm16())); break;	/* ld A, (mn) */
			case 0x3b: dec16(sp);             break;	/* dec SP */
			case 0x3c: inc8_r(a);             break;	/* inc A */
			case 0x3d: dec8_r(a);             break;	/* dec A */
			case 0x3e: ld8(a, imm8());        break;	/* ld A, n */
			case 0x3f: ccf();                 break;	/* ccf */

			case 0x40: ld8(b, b);        break;	/* ld B, B */
			case 0x41: ld8(b, c);        break;	/* ld B, C */
			case 0x42: ld8(b, d);        break;	/* ld B, D */
			case 0x43: ld8(b, e);        break;	/* ld B, E */
			case 0x44: ld8(b, h);        break;	/* ld B, H */
			case 0x45: ld8(b, l);        break;	/* ld B, L */
			case 0x46: ld8(b, mem8(hl)); break;	/* ld B, (HL) */
			case 0x47: ld8(b, a);        break;	/* ld B, A */

			case 0x48: ld8(c, b);        break;	/* ld C, B */
			case 0x49: ld8(c, c);        break;	/* ld C, C */
			case 0x4a: ld8(c, d);        break;	/* ld C, D */
			case 0x4b: ld8(c, e);        break;	/* ld C, E */
			case 0x4c: ld8(c, h);        break;	/* ld C, H */
			case 0x4d: ld8(c, l);        break;	/* ld C, L */
			case 0x4e: ld8(c, mem8(hl)); break;	/* ld C, (HL) */
			case 0x4f: ld8(c, a);        break;	/* ld C, A */

			case 0x50: ld8(d, b);        break;	/* ld D, B */
			case 0x51: ld8(d, c);        break;	/* ld D, C */
			case 0x52: ld8(d, d);        break;	/* ld D, D */
			case 0x53: ld8(d, e);        break;	/* ld D, E */
			case 0x54: ld8(d, h);        break;	/* ld D, H */
			case 0x55: ld8(d, l);        break;	/* ld D, L */
			case 0x56: ld8(d, mem8(hl)); break;	/* ld D, (HL) */
			case 0x57: ld8(d, a);        break;	/* ld D, A */

			case 0x58: ld8(e, b);        break;	/* ld E, B */
			case 0x59: ld8(e, c);        break;	/* ld E, C */
			case 0x5a: ld8(e, d);        break;	/* ld E, D */
			case 0x5b: ld8(e, e);        break;	/* ld E, E */
			case 0x5c: ld8(e, h);        break;	/* ld E, H */
			case 0x5d: ld8(e, l);        break;	/* ld E, L */
			case 0x5e: ld8(e, mem8(hl)); break;	/* ld E, (HL) */
			case 0x5f: ld8(e, a);        break;	/* ld E, A */

			case 0x60: ld8(h, b);        break;	/* ld H, B */
			case 0x61: ld8(h, c);        break;	/* ld H, C */
			case 0x62: ld8(h, d);        break;	/* ld H, D */
			case 0x63: ld8(h, e);        break;	/* ld H, E */
			case 0x64: ld8(h, h);        break;	/* ld H, H */
			case 0x65: ld8(h, l);        break;	/* ld H, L */
			case 0x66: ld8(h, mem8(hl)); break;	/* ld H, (HL) */
			case 0x67: ld8(h, a);        break;	/* ld H, A */

			case 0x68: ld8(l, b);        break;	/* ld L, B */
			case 0x69: ld8(l, c);        break;	/* ld L, C */
			case 0x6a: ld8(l, d);        break;	/* ld L, D */
			case 0x6b: ld8(l, e);        break;	/* ld L, E */
			case 0x6c: ld8(l, h);        break;	/* ld L, H */
			case 0x6d: ld8(l, l);        break;	/* ld L, L */
			case 0x6e: ld8(l, mem8(hl)); break;	/* ld L, (HL) */
			case 0x6f: ld8(l, a);        break;	/* ld L, A */

			case 0x70: st8(hl, b); break;	/* ld (HL), B */
			case 0x71: st8(hl, c); break;	/* ld (HL), C */
			case 0x72: st8(hl, d); break;	/* ld (HL), D */
			case 0x73: st8(hl, e); break;	/* ld (HL), E */
			case 0x74: st8(hl, h); break;	/* ld (HL), H */
			case 0x75: st8(hl, l); break;	/* ld (HL), L */
			case 0x76: halt(); return 1;	/* halt */
			case 0x77: st8(hl, a); break;	/* ld (HL), A */

			case 0x78: ld8(a, b);        break;	/* ld A, B */
			case 0x79: ld8(a, c);        break;	/* ld A, C */
			case 0x7a: ld8(a, d);        break;	/* ld A, D */
			case 0x7b: ld8(a, e);        break;	/* ld A, E */
			case 0x7c: ld8(a, h);        break;	/* ld A, H */
			case 0x7d: ld8(a, l);        break;	/* ld A, L */
			case 0x7e: ld8(a, mem8(hl)); break;	/* ld A, (HL) */
			case 0x7f: ld8(a, a);        break;	/* ld A, A */

			case 0x80: add8(b);        break;	/* add B */
			case 0x81: add8(c);        break;	/* add C */
			case 0x82: add8(d);        break;	/* add D */
			case 0x83: add8(e);        break;	/* add E */
			case 0x84: add8(h);        break;	/* add H */
			case 0x85: add8(l);        break;	/* add L */
			case 0x86: add8(mem8(hl)); break;	/* add (HL) */
			case 0x87: add8(a);        break;	/* add A */

			case 0x88: adc8(b);        break;	/* adc B */
			case 0x89: adc8(c);        break;	/* adc C */
			case 0x8a: adc8(d);        break;	/* adc D */
			case 0x8b: adc8(e);        break;	/* adc E */
			case 0x8c: adc8(h);        break;	/* adc H */
			case 0x8d: adc8(l);        break;	/* adc L */
			case 0x8e: adc8(mem8(hl)); break;	/* adc (HL) */
			case 0x8f: adc8(a);        break;	/* adc A */

			case 0x90: sub8(b);        break;	/* sub B */
			case 0x91: sub8(c);        break;	/* sub C */
			case 0x92: sub8(d);        break;	/* sub D */
			case 0x93: sub8(e);        break;	/* sub E */
			case 0x94: sub8(h);        break;	/* sub H */
			case 0x95: sub8(l);        break;	/* sub L */
			case 0x96: sub8(mem8(hl)); break;	/* sub (HL) */
			case 0x97: sub8(a);        break;	/* sub A */

			case 0x98: sbc8(b);        break;	/* sbc B */
			case 0x99: sbc8(c);        break;	/* sbc C */
			case 0x9a: sbc8(d);        break;	/* sbc D */
			case 0x9b: sbc8(e);        break;	/* sbc E */
			case 0x9c: sbc8(h);        break;	/* sbc H */
			case 0x9d: sbc8(l);        break;	/* sbc L */
			case 0x9e: sbc8(mem8(hl)); break;	/* sbc (HL) */
			case 0x9f: sbc8(a);        break;	/* sbc A */

			case 0xa0: and(b);        break;	/* and B */
			case 0xa1: and(c);        break;	/* and C */
			case 0xa2: and(d);        break;	/* and D */
			case 0xa3: and(e);        break;	/* and E */
			case 0xa4: and(h);        break;	/* and H */
			case 0xa5: and(l);        break;	/* and L */
			case 0xa6: and(mem8(hl)); break;	/* and (HL) */
			case 0xa7: and(a);        break;	/* and A */

			case 0xa8: xor(b);        break;	/* xor B */
			case 0xa9: xor(c);        break;	/* xor C */
			case 0xaa: xor(d);        break;	/* xor D */
			case 0xab: xor(e);        break;	/* xor E */
			case 0xac: xor(h);        break;	/* xor H */
			case 0xad: xor(l);        break;	/* xor L */
			case 0xae: xor(mem8(hl)); break;	/* xor (HL) */
			case 0xaf: xor(a);        break;	/* xor A */

			case 0xb0: or(b);        break;	/* or B */
			case 0xb1: or(c);        break;	/* or C */
			case 0xb2: or(d);        break;	/* or D */
			case 0xb3: or(e);        break;	/* or E */
			case 0xb4: or(h);        break;	/* or H */
			case 0xb5: or(l);        break;	/* or L */
			case 0xb6: or(mem8(hl)); break;	/* or (HL) */
			case 0xb7: or(a);        break;	/* or A */

			case 0xb8: cp(b);        break;	/* cp B */
			case 0xb9: cp(c);        break;	/* cp C */
			case 0xba: cp(d);        break;	/* cp D */
			case 0xbb: cp(e);        break;	/* cp E */
			case 0xbc: cp(h);        break;	/* cp H */
			case 0xbd: cp(l);        break;	/* cp L */
			case 0xbe: cp(mem8(hl)); break;	/* cp (HL) */
			case 0xbf: cp(a);        break;	/* cp A */

			case 0xc0: ret(f.nz());           break;	/* ret NZ */
			case 0xc1: pop(bc);               break;	/* pop BC */
			case 0xc2: jp(f.nz(), imm16());   break;	/* jp NZ, mn */
			case 0xc3: jp(1, imm16());        break;	/* jp mn */
			case 0xc4: call(f.nz(), imm16()); break;	/* call NZ, mn */
			case 0xc5: push(bc);              break;	/* push BC */
			case 0xc6: add8(imm8());          break;	/* add n */
			case 0xc7: rst(0x00);             break;	/* rst 00H */

			case 0xc8: ret(f.z());         break;	/* ret Z */
			case 0xc9: ret(1);             break;	/* ret */
			case 0xca: jp(f.z(), imm16()); break;	/* jp Z, mn */
			case 0xcb:
				pc++;
				switch(fetchCBXX()) {
				case 0x00: rlc_r(b);  break;	/* rlc B */
				case 0x01: rlc_r(c);  break;	/* rlc C */
				case 0x02: rlc_r(d);  break;	/* rlc D */
				case 0x03: rlc_r(e);  break;	/* rlc E */
				case 0x04: rlc_r(h);  break;	/* rlc H */
				case 0x05: rlc_r(l);  break;	/* rlc L */
				case 0x06: rlc_m(hl); break;	/* rlc (HL) */
				case 0x07: rlc_r(a);  break;	/* rlc A */

				case 0x08: rrc_r(b);  break;	/* rrc B */
				case 0x09: rrc_r(c);  break;	/* rrc C */
				case 0x0a: rrc_r(d);  break;	/* rrc D */
				case 0x0b: rrc_r(e);  break;	/* rrc E */
				case 0x0c: rrc_r(h);  break;	/* rrc H */
				case 0x0d: rrc_r(l);  break;	/* rrc L */
				case 0x0e: rrc_m(hl); break;	/* rrc (HL) */
				case 0x0f: rrc_r(a);  break;	/* rrc A */

				case 0x10: rl_r(b);  break;	/* rl B */
				case 0x11: rl_r(c);  break;	/* rl C */
				case 0x12: rl_r(d);  break;	/* rl D */
				case 0x13: rl_r(e);  break;	/* rl E */
				case 0x14: rl_r(h);  break;	/* rl H */
				case 0x15: rl_r(l);  break;	/* rl L */
				case 0x16: rl_m(hl); break;	/* rl (HL) */
				case 0x17: rl_r(a);  break;	/* rl A */

				case 0x18: rr_r(b);  break;	/* rr B */
				case 0x19: rr_r(c);  break;	/* rr C */
				case 0x1a: rr_r(d);  break;	/* rr D */
				case 0x1b: rr_r(e);  break;	/* rr E */
				case 0x1c: rr_r(h);  break;	/* rr H */
				case 0x1d: rr_r(l);  break;	/* rr L */
				case 0x1e: rr_m(hl); break;	/* rr (HL) */
				case 0x1f: rr_r(a);  break;	/* rr A */

				case 0x20: sla_r(b);  break;	/* sla B */
				case 0x21: sla_r(c);  break;	/* sla C */
				case 0x22: sla_r(d);  break;	/* sla D */
				case 0x23: sla_r(e);  break;	/* sla E */
				case 0x24: sla_r(h);  break;	/* sla H */
				case 0x25: sla_r(l);  break;	/* sla L */
				case 0x26: sla_m(hl); break;	/* sla (HL) */
				case 0x27: sla_r(a);  break;	/* sla A */

				case 0x28: sra_r(b);  break;	/* sra B */
				case 0x29: sra_r(c);  break;	/* sra C */
				case 0x2a: sra_r(d);  break;	/* sra D */
				case 0x2b: sra_r(e);  break;	/* sra E */
				case 0x2c: sra_r(h);  break;	/* sra H */
				case 0x2d: sra_r(l);  break;	/* sra L */
				case 0x2e: sra_m(hl); break;	/* sra (HL) */
				case 0x2f: sra_r(a);  break;	/* sra A */

				case 0x30: sll_r(b);  break;	/* sll B */
				case 0x31: sll_r(c);  break;	/* sll C */
				case 0x32: sll_r(d);  break;	/* sll D */
				case 0x33: sll_r(e);  break;	/* sll E */
				case 0x34: sll_r(h);  break;	/* sll H */
				case 0x35: sll_r(l);  break;	/* sll L */
				case 0x36: sll_m(hl); break;	/* sll (HL) */
				case 0x37: sll_r(a);  break;	/* sll A */

				case 0x38: srl_r(b);  break;	/* srl B */
				case 0x39: srl_r(c);  break;	/* srl C */
				case 0x3a: srl_r(d);  break;	/* srl D */
				case 0x3b: srl_r(e);  break;	/* srl E */
				case 0x3c: srl_r(h);  break;	/* srl H */
				case 0x3d: srl_r(l);  break;	/* srl L */
				case 0x3e: srl_m(hl); break;	/* srl (HL) */
				case 0x3f: srl_r(a);  break;	/* srl A */

				case 0x40: bit(0, b);        break;	/* bit 0, B */
				case 0x41: bit(0, c);        break;	/* bit 0, C */
				case 0x42: bit(0, d);        break;	/* bit 0, D */
				case 0x43: bit(0, e);        break;	/* bit 0, E */
				case 0x44: bit(0, h);        break;	/* bit 0, H */
				case 0x45: bit(0, l);        break;	/* bit 0, L */
				case 0x46: bit(0, mem8(hl)); break;	/* bit 0, (HL) */
				case 0x47: bit(0, a);        break;	/* bit 0, A */

				case 0x48: bit(1, b);        break;	/* bit 1, B */
				case 0x49: bit(1, c);        break;	/* bit 1, C */
				case 0x4a: bit(1, d);        break;	/* bit 1, D */
				case 0x4b: bit(1, e);        break;	/* bit 1, E */
				case 0x4c: bit(1, h);        break;	/* bit 1, H */
				case 0x4d: bit(1, l);        break;	/* bit 1, L */
				case 0x4e: bit(1, mem8(hl)); break;	/* bit 1, (HL) */
				case 0x4f: bit(1, a);        break;	/* bit 1, A */

				case 0x50: bit(2, b);        break;	/* bit 2, B */
				case 0x51: bit(2, c);        break;	/* bit 2, C */
				case 0x52: bit(2, d);        break;	/* bit 2, D */
				case 0x53: bit(2, e);        break;	/* bit 2, E */
				case 0x54: bit(2, h);        break;	/* bit 2, H */
				case 0x55: bit(2, l);        break;	/* bit 2, L */
				case 0x56: bit(2, mem8(hl)); break;	/* bit 2, (HL) */
				case 0x57: bit(2, a);        break;	/* bit 2, A */

				case 0x58: bit(3, b);        break;	/* bit 3, B */
				case 0x59: bit(3, c);        break;	/* bit 3, C */
				case 0x5a: bit(3, d);        break;	/* bit 3, D */
				case 0x5b: bit(3, e);        break;	/* bit 3, E */
				case 0x5c: bit(3, h);        break;	/* bit 3, H */
				case 0x5d: bit(3, l);        break;	/* bit 3, L */
				case 0x5e: bit(3, mem8(hl)); break;	/* bit 3, (HL) */
				case 0x5f: bit(3, a);        break;	/* bit 3, A */

				case 0x60: bit(4, b);        break;	/* bit 4, B */
				case 0x61: bit(4, c);        break;	/* bit 4, C */
				case 0x62: bit(4, d);        break;	/* bit 4, D */
				case 0x63: bit(4, e);        break;	/* bit 4, E */
				case 0x64: bit(4, h);        break;	/* bit 4, H */
				case 0x65: bit(4, l);        break;	/* bit 4, L */
				case 0x66: bit(4, mem8(hl)); break;	/* bit 4, (HL) */
				case 0x67: bit(4, a);        break;	/* bit 4, A */

				case 0x68: bit(5, b);        break;	/* bit 5, B */
				case 0x69: bit(5, c);        break;	/* bit 5, C */
				case 0x6a: bit(5, d);        break;	/* bit 5, D */
				case 0x6b: bit(5, e);        break;	/* bit 5, E */
				case 0x6c: bit(5, h);        break;	/* bit 5, H */
				case 0x6d: bit(5, l);        break;	/* bit 5, L */
				case 0x6e: bit(5, mem8(hl)); break;	/* bit 5, (HL) */
				case 0x6f: bit(5, a);        break;	/* bit 5, A */

				case 0x70: bit(6, b);        break;	/* bit 6, B */
				case 0x71: bit(6, c);        break;	/* bit 6, C */
				case 0x72: bit(6, d);        break;	/* bit 6, D */
				case 0x73: bit(6, e);        break;	/* bit 6, E */
				case 0x74: bit(6, h);        break;	/* bit 6, H */
				case 0x75: bit(6, l);        break;	/* bit 6, L */
				case 0x76: bit(6, mem8(hl)); break;	/* bit 6, (HL) */
				case 0x77: bit(6, a);        break;	/* bit 6, A */

				case 0x78: bit(7, b);        break;	/* bit 7, B */
				case 0x79: bit(7, c);        break;	/* bit 7, C */
				case 0x7a: bit(7, d);        break;	/* bit 7, D */
				case 0x7b: bit(7, e);        break;	/* bit 7, E */
				case 0x7c: bit(7, h);        break;	/* bit 7, H */
				case 0x7d: bit(7, l);        break;	/* bit 7, L */
				case 0x7e: bit(7, mem8(hl)); break;	/* bit 7, (HL) */
				case 0x7f: bit(7, a);        break;	/* bit 7, A */

				case 0x80: res_r(0, b);  break;	/* res 0, B */
				case 0x81: res_r(0, c);  break;	/* res 0, C */
				case 0x82: res_r(0, d);  break;	/* res 0, D */
				case 0x83: res_r(0, e);  break;	/* res 0, E */
				case 0x84: res_r(0, h);  break;	/* res 0, H */
				case 0x85: res_r(0, l);  break;	/* res 0, L */
				case 0x86: res_m(0, hl); break;	/* res 0, (HL) */
				case 0x87: res_r(0, a);  break;	/* res 0, A */

				case 0x88: res_r(1, b);  break;	/* res 1, B */
				case 0x89: res_r(1, c);  break;	/* res 1, C */
				case 0x8a: res_r(1, d);  break;	/* res 1, D */
				case 0x8b: res_r(1, e);  break;	/* res 1, E */
				case 0x8c: res_r(1, h);  break;	/* res 1, H */
				case 0x8d: res_r(1, l);  break;	/* res 1, L */
				case 0x8e: res_m(1, hl); break;	/* res 1, (HL) */
				case 0x8f: res_r(1, a);  break;	/* res 1, A */

				case 0x90: res_r(2, b);  break;	/* res 2, B */
				case 0x91: res_r(2, c);  break;	/* res 2, C */
				case 0x92: res_r(2, d);  break;	/* res 2, D */
				case 0x93: res_r(2, e);  break;	/* res 2, E */
				case 0x94: res_r(2, h);  break;	/* res 2, H */
				case 0x95: res_r(2, l);  break;	/* res 2, L */
				case 0x96: res_m(2, hl); break;	/* res 2, (HL) */
				case 0x97: res_r(2, a);  break;	/* res 2, A */

				case 0x98: res_r(3, b);  break;	/* res 3, B */
				case 0x99: res_r(3, c);  break;	/* res 3, C */
				case 0x9a: res_r(3, d);  break;	/* res 3, D */
				case 0x9b: res_r(3, e);  break;	/* res 3, E */
				case 0x9c: res_r(3, h);  break;	/* res 3, H */
				case 0x9d: res_r(3, l);  break;	/* res 3, L */
				case 0x9e: res_m(3, hl); break;	/* res 3, (HL) */
				case 0x9f: res_r(3, a);  break;	/* res 3, A */

				case 0xa0: res_r(4, b);  break;	/* res 4, B */
				case 0xa1: res_r(4, c);  break;	/* res 4, C */
				case 0xa2: res_r(4, d);  break;	/* res 4, D */
				case 0xa3: res_r(4, e);  break;	/* res 4, E */
				case 0xa4: res_r(4, h);  break;	/* res 4, H */
				case 0xa5: res_r(4, l);  break;	/* res 4, L */
				case 0xa6: res_m(4, hl); break;	/* res 4, (HL) */
				case 0xa7: res_r(4, a);  break;	/* res 4, A */

				case 0xa8: res_r(5, b);  break;	/* res 5, B */
				case 0xa9: res_r(5, c);  break;	/* res 5, C */
				case 0xaa: res_r(5, d);  break;	/* res 5, D */
				case 0xab: res_r(5, e);  break;	/* res 5, E */
				case 0xac: res_r(5, h);  break;	/* res 5, H */
				case 0xad: res_r(5, l);  break;	/* res 5, L */
				case 0xae: res_m(5, hl); break;	/* res 5, (HL) */
				case 0xaf: res_r(5, a);  break;	/* res 5, A */

				case 0xb0: res_r(6, b);  break;	/* res 6, B */
				case 0xb1: res_r(6, c);  break;	/* res 6, C */
				case 0xb2: res_r(6, d);  break;	/* res 6, D */
				case 0xb3: res_r(6, e);  break;	/* res 6, E */
				case 0xb4: res_r(6, h);  break;	/* res 6, H */
				case 0xb5: res_r(6, l);  break;	/* res 6, L */
				case 0xb6: res_m(6, hl); break;	/* res 6, (HL) */
				case 0xb7: res_r(6, a);  break;	/* res 6, A */

				case 0xb8: res_r(7, b);  break;	/* res 7, B */
				case 0xb9: res_r(7, c);  break;	/* res 7, C */
				case 0xba: res_r(7, d);  break;	/* res 7, D */
				case 0xbb: res_r(7, e);  break;	/* res 7, E */
				case 0xbc: res_r(7, h);  break;	/* res 7, H */
				case 0xbd: res_r(7, l);  break;	/* res 7, L */
				case 0xbe: res_m(7, hl); break;	/* res 7, (HL) */
				case 0xbf: res_r(7, a);  break;	/* res 7, A */

				case 0xc0: set_r(0, b);  break;	/* set 0, B */
				case 0xc1: set_r(0, c);  break;	/* set 0, C */
				case 0xc2: set_r(0, d);  break;	/* set 0, D */
				case 0xc3: set_r(0, e);  break;	/* set 0, E */
				case 0xc4: set_r(0, h);  break;	/* set 0, H */
				case 0xc5: set_r(0, l);  break;	/* set 0, L */
				case 0xc6: set_m(0, hl); break;	/* set 0, (HL) */
				case 0xc7: set_r(0, a);  break;	/* set 0, A */

				case 0xc8: set_r(1, b);  break;	/* set 1, B */
				case 0xc9: set_r(1, c);  break;	/* set 1, C */
				case 0xca: set_r(1, d);  break;	/* set 1, D */
				case 0xcb: set_r(1, e);  break;	/* set 1, E */
				case 0xcc: set_r(1, h);  break;	/* set 1, H */
				case 0xcd: set_r(1, l);  break;	/* set 1, L */
				case 0xce: set_m(1, hl); break;	/* set 1, (HL) */
				case 0xcf: set_r(1, a);  break;	/* set 1, A */

				case 0xd0: set_r(2, b);  break;	/* set 2, B */
				case 0xd1: set_r(2, c);  break;	/* set 2, C */
				case 0xd2: set_r(2, d);  break;	/* set 2, D */
				case 0xd3: set_r(2, e);  break;	/* set 2, E */
				case 0xd4: set_r(2, h);  break;	/* set 2, H */
				case 0xd5: set_r(2, l);  break;	/* set 2, L */
				case 0xd6: set_m(2, hl); break;	/* set 2, (HL) */
				case 0xd7: set_r(2, a);  break;	/* set 2, A */

				case 0xd8: set_r(3, b);  break;	/* set 3, B */
				case 0xd9: set_r(3, c);  break;	/* set 3, C */
				case 0xda: set_r(3, d);  break;	/* set 3, D */
				case 0xdb: set_r(3, e);  break;	/* set 3, E */
				case 0xdc: set_r(3, h);  break;	/* set 3, H */
				case 0xdd: set_r(3, l);  break;	/* set 3, L */
				case 0xde: set_m(3, hl); break;	/* set 3, (HL) */
				case 0xdf: set_r(3, a);  break;	/* set 3, A */

				case 0xe0: set_r(4, b);  break;	/* set 4, B */
				case 0xe1: set_r(4, c);  break;	/* set 4, C */
				case 0xe2: set_r(4, d);  break;	/* set 4, D */
				case 0xe3: set_r(4, e);  break;	/* set 4, E */
				case 0xe4: set_r(4, h);  break;	/* set 4, H */
				case 0xe5: set_r(4, l);  break;	/* set 4, L */
				case 0xe6: set_m(4, hl); break;	/* set 4, (HL) */
				case 0xe7: set_r(4, a);  break;	/* set 4, A */

				case 0xe8: set_r(5, b);  break;	/* set 5, B */
				case 0xe9: set_r(5, c);  break;	/* set 5, C */
				case 0xea: set_r(5, d);  break;	/* set 5, D */
				case 0xeb: set_r(5, e);  break;	/* set 5, E */
				case 0xec: set_r(5, h);  break;	/* set 5, H */
				case 0xed: set_r(5, l);  break;	/* set 5, L */
				case 0xee: set_m(5, hl); break;	/* set 5, (HL) */
				case 0xef: set_r(5, a);  break;	/* set 5, A */

				case 0xf0: set_r(6, b);  break;	/* set 6, B */
				case 0xf1: set_r(6, c);  break;	/* set 6, C */
				case 0xf2: set_r(6, d);  break;	/* set 6, D */
				case 0xf3: set_r(6, e);  break;	/* set 6, E */
				case 0xf4: set_r(6, h);  break;	/* set 6, H */
				case 0xf5: set_r(6, l);  break;	/* set 6, L */
				case 0xf6: set_m(6, hl); break;	/* set 6, (HL) */
				case 0xf7: set_r(6, a);  break;	/* set 6, A */

				case 0xf8: set_r(7, b);  break;	/* set 7, B */
				case 0xf9: set_r(7, c);  break;	/* set 7, C */
				case 0xfa: set_r(7, d);  break;	/* set 7, D */
				case 0xfb: set_r(7, e);  break;	/* set 7, E */
				case 0xfc: set_r(7, h);  break;	/* set 7, H */
				case 0xfd: set_r(7, l);  break;	/* set 7, L */
				case 0xfe: set_m(7, hl); break;	/* set 7, (HL) */
				case 0xff: set_r(7, a);  break;	/* set 7, A */
				}
				break;
			case 0xcc: call(f.z(), imm16()); break;	/* call Z, mn */
			case 0xcd: call(1, imm16());     break;	/* call mn */
			case 0xce: adc8(imm8());         break;	/* adc n */
			case 0xcf: rst(0x08);            break;	/* rst 08H */

			case 0xd0: ret(f.ncy());           break;	/* ret NC */
			case 0xd1: pop(de);                break;	/* pop DE */
			case 0xd2: jp(f.ncy(), imm16());   break;	/* jp NC, mn */
			case 0xd3: out_n(imm8());          break;	/* out (n), A */
			case 0xd4: call(f.ncy(), imm16()); break;	/* call NC, mn */
			case 0xd5: push(de);               break;	/* push DE */
			case 0xd6: sub8(imm8());           break;	/* sub n */
			case 0xd7: rst(0x10);              break;	/* rst 10H */

			case 0xd8: ret(f.cy());           break;	/* ret C */
			case 0xd9: exx();                 break;	/* exx */
			case 0xda: jp(f.cy(), imm16());   break;	/* jp C, mn */
			case 0xdb: in_n(imm8());          break;	/* in A, (n) */
			case 0xdc: call(f.cy(), imm16()); break;	/* call C, mn */
			case 0xdd:
				pc++;
				switch(fetchDDXX()) {
				default: pc += length; break;	/* nop */

				case 0x09: add16(ix, bc); break;	/* add IX, BC */

				case 0x19: add16(ix, de); break;	/* add IX, DE */

				case 0x21: ld16(ix, imm16()); break;	/* ld IX, mn */
				case 0x22: st16(imm16(), ix); break;	/* ld (mn), IX */
				case 0x23: inc16(ix);         break;	/* inc IX */
				case 0x24: inc8_r(ixh);       break;	/* inc IXh */
				case 0x25: dec8_r(ixh);       break;	/* dec IXh */
				case 0x26: ld8(ixh, imm8());  break;	/* ld IXh, n */

				case 0x29: add16(ix, ix);            break;	/* add IX, IX */
				case 0x2a: ld16(ix, mem16(imm16())); break;	/* ld IX, (mn) */
				case 0x2b: dec16(ix);                break;	/* dec IX */
				case 0x2c: inc8_r(ixl);              break;	/* inc IXl */
				case 0x2d: dec8_r(ixl);              break;	/* dec IXl */
				case 0x2e: ld8(ixl, imm8());         break;	/* ld IXl, n */

				case 0x34: inc8_m(ix.get() + dis());            break;	/* inc (IX + d) */
				case 0x35: dec8_m(ix.get() + dis());            break;	/* dec (IX + d) */
				case 0x36: st8(ix.get() + dis(), mem8(pc + 2)); break;	/* ld (IX + d), n */

				case 0x39: add16(ix, sp); break;	/* ADD IX, SP */

				case 0x44: ld8(b, ixh);                 break;	/* ld B, IXh */
				case 0x45: ld8(b, ixl);                 break;	/* ld B, IXl */
				case 0x46: ld8(b, mem8(ix.get() + dis())); break;	/* ld B, (IX + d) */

				case 0x4c: ld8(c, ixh);                 break;	/* ld C, IXh */
				case 0x4d: ld8(c, ixl);                 break;	/* ld C, IXl */
				case 0x4e: ld8(c, mem8(ix.get() + dis())); break;	/* ld C, (IX + d) */

				case 0x54: ld8(d, ixh);                 break;	/* ld D, IXh */
				case 0x55: ld8(d, ixl);                 break;	/* ld D, IXl */
				case 0x56: ld8(d, mem8(ix.get() + dis())); break;	/* ld D, (IX + d) */

				case 0x5c: ld8(e, ixh);                 break;	/* ld E, IXh */
				case 0x5d: ld8(e, ixl);                 break;	/* ld E, IXl */
				case 0x5e: ld8(e, mem8(ix.get() + dis())); break;	/* ld E, (IX + d) */

				case 0x60: ld8(ixh, b);                 break;	/* ld IXh, B */
				case 0x61: ld8(ixh, c);                 break;	/* ld IXh, C */
				case 0x62: ld8(ixh, d);                 break;	/* ld IXh, D */
				case 0x63: ld8(ixh, e);                 break;	/* ld IXh, E */
				case 0x64: ld8(ixh, h);                 break;	/* ld IXh, H */
				case 0x65: ld8(ixh, l);                 break;	/* ld IXh, L */
				case 0x66: ld8(h, mem8(ix.get() + dis())); break;	/* ld H, (IX + d) */
				case 0x67: ld8(ixh, a);                 break;	/* ld IXh, A */

				case 0x68: ld8(ixl, b);                 break;	/* ld IXl, B */
				case 0x69: ld8(ixl, c);                 break;	/* ld IXl, C */
				case 0x6a: ld8(ixl, d);                 break;	/* ld IXl, D */
				case 0x6b: ld8(ixl, e);                 break;	/* ld IXl, E */
				case 0x6c: ld8(ixl, h);                 break;	/* ld IXl, H */
				case 0x6d: ld8(ixl, l);                 break;	/* ld IXl, L */
				case 0x6e: ld8(l, mem8(ix.get() + dis())); break;	/* ld L, (IX + d) */
				case 0x6f: ld8(ixl, a);                 break;	/* ld IXl, A */

				case 0x70: st8(ix.get() + dis(), b); break;	/* ld (IX + d), B */
				case 0x71: st8(ix.get() + dis(), c); break;	/* ld (IX + d), C */
				case 0x72: st8(ix.get() + dis(), d); break;	/* ld (IX + d), D */
				case 0x73: st8(ix.get() + dis(), e); break;	/* ld (IX + d), E */
				case 0x74: st8(ix.get() + dis(), h); break;	/* ld (IX + d), H */
				case 0x75: st8(ix.get() + dis(), l); break;	/* ld (IX + d), L */
				case 0x77: st8(ix.get() + dis(), a); break;	/* ld (IX + d), A */

				case 0x7c: ld8(a, ixh);                 break;	/* ld A, IXh */
				case 0x7d: ld8(a, ixl);                 break;	/* ld A, IXl */
				case 0x7e: ld8(a, mem8(ix.get() + dis())); break;	/* ld A, (IX + d) */

				case 0x84: add8(ixh);                 break;	/* add IXh */
				case 0x85: add8(ixl);                 break;	/* add IXl */
				case 0x86: add8(mem8(ix.get() + dis())); break;	/* add (IX + d) */

				case 0x8c: adc8(ixh);                 break;	/* adc IXh */
				case 0x8d: adc8(ixl);                 break;	/* adc IXl */
				case 0x8e: adc8(mem8(ix.get() + dis())); break;	/* adc (IX + d) */

				case 0x94: sub8(ixh);                 break;	/* sub IXh */
				case 0x95: sub8(ixl);                 break;	/* sub IXl */
				case 0x96: sub8(mem8(ix.get() + dis())); break;	/* sub (IX + d) */

				case 0x9c: sbc8(ixh);                 break;	/* sbc IXh */
				case 0x9d: sbc8(ixl);                 break;	/* sbc IXl */
				case 0x9e: sbc8(mem8(ix.get() + dis())); break;	/* sbc (IX + d) */

				case 0xa4: and(ixh);                 break;	/* and IXh */
				case 0xa5: and(ixl);                 break;	/* and IXl */
				case 0xa6: and(mem8(ix.get() + dis())); break;	/* and (IX + d) */

				case 0xac: xor(ixh);                 break;	/* xor IXh */
				case 0xad: xor(ixl);                 break;	/* xor IXl */
				case 0xae: xor(mem8(ix.get() + dis())); break;	/* xor (IX + d) */

				case 0xb4: or(ixh);                 break;	/* or IXh */
				case 0xb5: or(ixl);                 break;	/* or IXl */
				case 0xb6: or(mem8(ix.get() + dis())); break;	/* or (IX + d) */

				case 0xbc: cp(ixh);                 break;	/* cp IXh */
				case 0xbd: cp(ixl);                 break;	/* cp IXl */
				case 0xbe: cp(mem8(ix.get() + dis())); break;	/* cp (IX + d) */

				case 0xcb:
					switch(fetchDDCBXX()) {
					case 0x00: rlc_m_r(ix.get() + dis(), b); break;	/* rlc (IX + d), B */
					case 0x01: rlc_m_r(ix.get() + dis(), c); break;	/* rlc (IX + d), C */
					case 0x02: rlc_m_r(ix.get() + dis(), d); break;	/* rlc (IX + d), D */
					case 0x03: rlc_m_r(ix.get() + dis(), e); break;	/* rlc (IX + d), E */
					case 0x04: rlc_m_r(ix.get() + dis(), h); break;	/* rlc (IX + d), H */
					case 0x05: rlc_m_r(ix.get() + dis(), l); break;	/* rlc (IX + d), L */
					case 0x06: rlc_m(ix.get() + dis());      break;	/* rlc (IX + d) */
					case 0x07: rlc_m_r(ix.get() + dis(), a); break;	/* rlc (IX + d), A */

					case 0x08: rrc_m_r(ix.get() + dis(), b); break;	/* rrc (IX + d), B */
					case 0x09: rrc_m_r(ix.get() + dis(), c); break;	/* rrc (IX + d), C */
					case 0x0a: rrc_m_r(ix.get() + dis(), d); break;	/* rrc (IX + d), D */
					case 0x0b: rrc_m_r(ix.get() + dis(), e); break;	/* rrc (IX + d), E */
					case 0x0c: rrc_m_r(ix.get() + dis(), h); break;	/* rrc (IX + d), H */
					case 0x0d: rrc_m_r(ix.get() + dis(), l); break;	/* rrc (IX + d), L */
					case 0x0e: rrc_m(ix.get() + dis());      break;	/* rrc (IX + d) */
					case 0x0f: rrc_m_r(ix.get() + dis(), a); break;	/* rrc (IX + d), A */

					case 0x10: rl_m_r(ix.get() + dis(), b); break;	/* rl (IX + d), B */
					case 0x11: rl_m_r(ix.get() + dis(), c); break;	/* rl (IX + d), C */
					case 0x12: rl_m_r(ix.get() + dis(), d); break;	/* rl (IX + d), D */
					case 0x13: rl_m_r(ix.get() + dis(), e); break;	/* rl (IX + d), E */
					case 0x14: rl_m_r(ix.get() + dis(), h); break;	/* rl (IX + d), H */
					case 0x15: rl_m_r(ix.get() + dis(), l); break;	/* rl (IX + d), L */
					case 0x16: rl_m(ix.get() + dis());      break;	/* rl (IX + d) */
					case 0x17: rl_m_r(ix.get() + dis(), a); break;	/* rl (IX + d), A */

					case 0x18: rr_m_r(ix.get() + dis(), b); break;	/* rr (IX + d), B */
					case 0x19: rr_m_r(ix.get() + dis(), c); break;	/* rr (IX + d), C */
					case 0x1a: rr_m_r(ix.get() + dis(), d); break;	/* rr (IX + d), D */
					case 0x1b: rr_m_r(ix.get() + dis(), e); break;	/* rr (IX + d), E */
					case 0x1c: rr_m_r(ix.get() + dis(), h); break;	/* rr (IX + d), H */
					case 0x1d: rr_m_r(ix.get() + dis(), l); break;	/* rr (IX + d), L */
					case 0x1e: rr_m(ix.get() + dis());      break;	/* rr (IX + d) */
					case 0x1f: rr_m_r(ix.get() + dis(), a); break;	/* rr (IX + d), A */

					case 0x20: sla_m_r(ix.get() + dis(), b); break;	/* sla (IX + d), B */
					case 0x21: sla_m_r(ix.get() + dis(), c); break;	/* sla (IX + d), C */
					case 0x22: sla_m_r(ix.get() + dis(), d); break;	/* sla (IX + d), D */
					case 0x23: sla_m_r(ix.get() + dis(), e); break;	/* sla (IX + d), E */
					case 0x24: sla_m_r(ix.get() + dis(), h); break;	/* sla (IX + d), H */
					case 0x25: sla_m_r(ix.get() + dis(), l); break;	/* sla (IX + d), L */
					case 0x26: sla_m(ix.get() + dis());      break;	/* sla (IX + d) */
					case 0x27: sla_m_r(ix.get() + dis(), a); break;	/* sla (IX + d), A */

					case 0x28: sra_m_r(ix.get() + dis(), b); break;	/* sra (IX + d), B */
					case 0x29: sra_m_r(ix.get() + dis(), c); break;	/* sra (IX + d), C */
					case 0x2a: sra_m_r(ix.get() + dis(), d); break;	/* sra (IX + d), D */
					case 0x2b: sra_m_r(ix.get() + dis(), e); break;	/* sra (IX + d), E */
					case 0x2c: sra_m_r(ix.get() + dis(), h); break;	/* sra (IX + d), H */
					case 0x2d: sra_m_r(ix.get() + dis(), l); break;	/* sra (IX + d), L */
					case 0x2e: sra_m(ix.get() + dis());      break;	/* sra (IX + d) */
					case 0x2f: sra_m_r(ix.get() + dis(), a); break;	/* sra (IX + d), A */

					case 0x30: sll_m_r(ix.get() + dis(), b); break;	/* sll (IX + d), B */
					case 0x31: sll_m_r(ix.get() + dis(), c); break;	/* sll (IX + d), C */
					case 0x32: sll_m_r(ix.get() + dis(), d); break;	/* sll (IX + d), D */
					case 0x33: sll_m_r(ix.get() + dis(), e); break;	/* sll (IX + d), E */
					case 0x34: sll_m_r(ix.get() + dis(), h); break;	/* sll (IX + d), H */
					case 0x35: sll_m_r(ix.get() + dis(), l); break;	/* sll (IX + d), L */
					case 0x36: sll_m(ix.get() + dis());      break;	/* sll (IX + d) */
					case 0x37: sll_m_r(ix.get() + dis(), a); break;	/* sll (IX + d), A */

					case 0x38: srl_m_r(ix.get() + dis(), b); break;	/* srl (IX + d), B */
					case 0x39: srl_m_r(ix.get() + dis(), c); break;	/* srl (IX + d), C */
					case 0x3a: srl_m_r(ix.get() + dis(), d); break;	/* srl (IX + d), D */
					case 0x3b: srl_m_r(ix.get() + dis(), e); break;	/* srl (IX + d), E */
					case 0x3c: srl_m_r(ix.get() + dis(), h); break;	/* srl (IX + d), H */
					case 0x3d: srl_m_r(ix.get() + dis(), l); break;	/* srl (IX + d), L */
					case 0x3e: srl_m(ix.get() + dis());      break;	/* srl (IX + d) */
					case 0x3f: srl_m_r(ix.get() + dis(), a); break;	/* srl (IX + d), A */

					case 0x40:
					case 0x41:
					case 0x42:
					case 0x43:
					case 0x44:
					case 0x45:
					case 0x46:
					case 0x47: bit(0, mem8(ix.get() + dis())); break;	/* bit 0, (IX + d) */

					case 0x48:
					case 0x49:
					case 0x4a:
					case 0x4b:
					case 0x4c:
					case 0x4d:
					case 0x4e:
					case 0x4f: bit(1, mem8(ix.get() + dis())); break;	/* bit 1, (IX + d) */

					case 0x50:
					case 0x51:
					case 0x52:
					case 0x53:
					case 0x54:
					case 0x55:
					case 0x56:
					case 0x57: bit(2, mem8(ix.get() + dis())); break;	/* bit 2, (IX + d) */

					case 0x58:
					case 0x59:
					case 0x5a:
					case 0x5b:
					case 0x5c:
					case 0x5d:
					case 0x5e:
					case 0x5f: bit(3, mem8(ix.get() + dis())); break;	/* bit 3, (IX + d) */

					case 0x60:
					case 0x61:
					case 0x62:
					case 0x63:
					case 0x64:
					case 0x65:
					case 0x66:
					case 0x67: bit(4, mem8(ix.get() + dis())); break;	/* bit 4, (IX + d) */

					case 0x68:
					case 0x69:
					case 0x6a:
					case 0x6b:
					case 0x6c:
					case 0x6d:
					case 0x6e:
					case 0x6f: bit(5, mem8(ix.get() + dis())); break;	/* bit 5, (IX + d) */

					case 0x70:
					case 0x71:
					case 0x72:
					case 0x73:
					case 0x74:
					case 0x75:
					case 0x76:
					case 0x77: bit(6, mem8(ix.get() + dis())); break;	/* bit 6, (IX + d) */

					case 0x78:
					case 0x79:
					case 0x7a:
					case 0x7b:
					case 0x7c:
					case 0x7d:
					case 0x7e:
					case 0x7f: bit(7, mem8(ix.get() + dis())); break;	/* bit 7, (IX + d) */

					case 0x80: res_m_r(0, ix.get() + dis(), b); break;	/* res 0, (IX + d), B */
					case 0x81: res_m_r(0, ix.get() + dis(), c); break;	/* res 0, (IX + d), C */
					case 0x82: res_m_r(0, ix.get() + dis(), d); break;	/* res 0, (IX + d), D */
					case 0x83: res_m_r(0, ix.get() + dis(), e); break;	/* res 0, (IX + d), E */
					case 0x84: res_m_r(0, ix.get() + dis(), h); break;	/* res 0, (IX + d), H */
					case 0x85: res_m_r(0, ix.get() + dis(), l); break;	/* res 0, (IX + d), L */
					case 0x86: res_m(0, ix.get() + dis());      break;	/* res 0, (IX + d) */
					case 0x87: res_m_r(0, ix.get() + dis(), a); break;	/* res 0, (IX + d), A */

					case 0x88: res_m_r(1, ix.get() + dis(), b); break;	/* res 1, (IX + d), B */
					case 0x89: res_m_r(1, ix.get() + dis(), c); break;	/* res 1, (IX + d), C */
					case 0x8a: res_m_r(1, ix.get() + dis(), d); break;	/* res 1, (IX + d), D */
					case 0x8b: res_m_r(1, ix.get() + dis(), e); break;	/* res 1, (IX + d), E */
					case 0x8c: res_m_r(1, ix.get() + dis(), h); break;	/* res 1, (IX + d), H */
					case 0x8d: res_m_r(1, ix.get() + dis(), l); break;	/* res 1, (IX + d), L */
					case 0x8e: res_m(1, ix.get() + dis());      break;	/* res 1, (IX + d) */
					case 0x8f: res_m_r(1, ix.get() + dis(), a); break;	/* res 1, (IX + d), A */

					case 0x90: res_m_r(2, ix.get() + dis(), b); break;	/* res 2, (IX + d), B */
					case 0x91: res_m_r(2, ix.get() + dis(), c); break;	/* res 2, (IX + d), C */
					case 0x92: res_m_r(2, ix.get() + dis(), d); break;	/* res 2, (IX + d), D */
					case 0x93: res_m_r(2, ix.get() + dis(), e); break;	/* res 2, (IX + d), E */
					case 0x94: res_m_r(2, ix.get() + dis(), h); break;	/* res 2, (IX + d), H */
					case 0x95: res_m_r(2, ix.get() + dis(), l); break;	/* res 2, (IX + d), L */
					case 0x96: res_m(2, ix.get() + dis());      break;	/* res 2, (IX + d) */
					case 0x97: res_m_r(2, ix.get() + dis(), a); break;	/* res 2, (IX + d), A */

					case 0x98: res_m_r(3, ix.get() + dis(), b); break;	/* res 3, (IX + d), B */
					case 0x99: res_m_r(3, ix.get() + dis(), c); break;	/* res 3, (IX + d), C */
					case 0x9a: res_m_r(3, ix.get() + dis(), d); break;	/* res 3, (IX + d), D */
					case 0x9b: res_m_r(3, ix.get() + dis(), e); break;	/* res 3, (IX + d), E */
					case 0x9c: res_m_r(3, ix.get() + dis(), h); break;	/* res 3, (IX + d), H */
					case 0x9d: res_m_r(3, ix.get() + dis(), l); break;	/* res 3, (IX + d), L */
					case 0x9e: res_m(3, ix.get() + dis());      break;	/* res 3, (IX + d) */
					case 0x9f: res_m_r(3, ix.get() + dis(), a); break;	/* res 3, (IX + d), A */

					case 0xa0: res_m_r(4, ix.get() + dis(), b); break;	/* res 4, (IX + d), B */
					case 0xa1: res_m_r(4, ix.get() + dis(), c); break;	/* res 4, (IX + d), C */
					case 0xa2: res_m_r(4, ix.get() + dis(), d); break;	/* res 4, (IX + d), D */
					case 0xa3: res_m_r(4, ix.get() + dis(), e); break;	/* res 4, (IX + d), E */
					case 0xa4: res_m_r(4, ix.get() + dis(), h); break;	/* res 4, (IX + d), H */
					case 0xa5: res_m_r(4, ix.get() + dis(), l); break;	/* res 4, (IX + d), L */
					case 0xa6: res_m(4, ix.get() + dis());      break;	/* res 4, (IX + d) */
					case 0xa7: res_m_r(4, ix.get() + dis(), a); break;	/* res 4, (IX + d), A */

					case 0xa8: res_m_r(5, ix.get() + dis(), b); break;	/* res 5, (IX + d), B */
					case 0xa9: res_m_r(5, ix.get() + dis(), c); break;	/* res 5, (IX + d), C */
					case 0xaa: res_m_r(5, ix.get() + dis(), d); break;	/* res 5, (IX + d), D */
					case 0xab: res_m_r(5, ix.get() + dis(), e); break;	/* res 5, (IX + d), E */
					case 0xac: res_m_r(5, ix.get() + dis(), h); break;	/* res 5, (IX + d), H */
					case 0xad: res_m_r(5, ix.get() + dis(), l); break;	/* res 5, (IX + d), L */
					case 0xae: res_m(5, ix.get() + dis());      break;	/* res 5, (IX + d) */
					case 0xaf: res_m_r(5, ix.get() + dis(), a); break;	/* res 5, (IX + d), A */

					case 0xb0: res_m_r(6, ix.get() + dis(), b); break;	/* res 6, (IX + d), B */
					case 0xb1: res_m_r(6, ix.get() + dis(), c); break;	/* res 6, (IX + d), C */
					case 0xb2: res_m_r(6, ix.get() + dis(), d); break;	/* res 6, (IX + d), D */
					case 0xb3: res_m_r(6, ix.get() + dis(), e); break;	/* res 6, (IX + d), E */
					case 0xb4: res_m_r(6, ix.get() + dis(), h); break;	/* res 6, (IX + d), H */
					case 0xb5: res_m_r(6, ix.get() + dis(), l); break;	/* res 6, (IX + d), L */
					case 0xb6: res_m(6, ix.get() + dis());      break;	/* res 6, (IX + d) */
					case 0xb7: res_m_r(6, ix.get() + dis(), a); break;	/* res 6, (IX + d), A */

					case 0xb8: res_m_r(7, ix.get() + dis(), b); break;	/* res 7, (IX + d), B */
					case 0xb9: res_m_r(7, ix.get() + dis(), c); break;	/* res 7, (IX + d), C */
					case 0xba: res_m_r(7, ix.get() + dis(), d); break;	/* res 7, (IX + d), D */
					case 0xbb: res_m_r(7, ix.get() + dis(), e); break;	/* res 7, (IX + d), E */
					case 0xbc: res_m_r(7, ix.get() + dis(), h); break;	/* res 7, (IX + d), H */
					case 0xbd: res_m_r(7, ix.get() + dis(), l); break;	/* res 7, (IX + d), L */
					case 0xbe: res_m(7, ix.get() + dis());      break;	/* res 7, (IX + d) */
					case 0xbf: res_m_r(7, ix.get() + dis(), a); break;	/* res 7, (IX + d), A */

					case 0xc0: set_m_r(0, ix.get() + dis(), b); break;	/* set 0, (IX + d), B */
					case 0xc1: set_m_r(0, ix.get() + dis(), c); break;	/* set 0, (IX + d), C */
					case 0xc2: set_m_r(0, ix.get() + dis(), d); break;	/* set 0, (IX + d), D */
					case 0xc3: set_m_r(0, ix.get() + dis(), e); break;	/* set 0, (IX + d), E */
					case 0xc4: set_m_r(0, ix.get() + dis(), h); break;	/* set 0, (IX + d), H */
					case 0xc5: set_m_r(0, ix.get() + dis(), l); break;	/* set 0, (IX + d), L */
					case 0xc6: set_m(0, ix.get() + dis());      break;	/* set 0, (IX + d) */
					case 0xc7: set_m_r(0, ix.get() + dis(), a); break;	/* set 0, (IX + d), A */

					case 0xc8: set_m_r(1, ix.get() + dis(), b); break;	/* set 1, (IX + d), B */
					case 0xc9: set_m_r(1, ix.get() + dis(), c); break;	/* set 1, (IX + d), C */
					case 0xca: set_m_r(1, ix.get() + dis(), d); break;	/* set 1, (IX + d), D */
					case 0xcb: set_m_r(1, ix.get() + dis(), e); break;	/* set 1, (IX + d), E */
					case 0xcc: set_m_r(1, ix.get() + dis(), h); break;	/* set 1, (IX + d), H */
					case 0xcd: set_m_r(1, ix.get() + dis(), l); break;	/* set 1, (IX + d), L */
					case 0xce: set_m(1, ix.get() + dis());      break;	/* set 1, (IX + d) */
					case 0xcf: set_m_r(1, ix.get() + dis(), a); break;	/* set 1, (IX + d), A */

					case 0xd0: set_m_r(2, ix.get() + dis(), b); break;	/* set 2, (IX + d), B */
					case 0xd1: set_m_r(2, ix.get() + dis(), c); break;	/* set 2, (IX + d), C */
					case 0xd2: set_m_r(2, ix.get() + dis(), d); break;	/* set 2, (IX + d), D */
					case 0xd3: set_m_r(2, ix.get() + dis(), e); break;	/* set 2, (IX + d), E */
					case 0xd4: set_m_r(2, ix.get() + dis(), h); break;	/* set 2, (IX + d), H */
					case 0xd5: set_m_r(2, ix.get() + dis(), l); break;	/* set 2, (IX + d), L */
					case 0xd6: set_m(2, ix.get() + dis());      break;	/* set 2, (IX + d) */
					case 0xd7: set_m_r(2, ix.get() + dis(), a); break;	/* set 2, (IX + d), A */

					case 0xd8: set_m_r(3, ix.get() + dis(), b); break;	/* set 3, (IX + d), B */
					case 0xd9: set_m_r(3, ix.get() + dis(), c); break;	/* set 3, (IX + d), C */
					case 0xda: set_m_r(3, ix.get() + dis(), d); break;	/* set 3, (IX + d), D */
					case 0xdb: set_m_r(3, ix.get() + dis(), e); break;	/* set 3, (IX + d), E */
					case 0xdc: set_m_r(3, ix.get() + dis(), h); break;	/* set 3, (IX + d), H */
					case 0xdd: set_m_r(3, ix.get() + dis(), l); break;	/* set 3, (IX + d), L */
					case 0xde: set_m(3, ix.get() + dis());      break;	/* set 3, (IX + d) */
					case 0xdf: set_m_r(3, ix.get() + dis(), a); break;	/* set 3, (IX + d), A */

					case 0xe0: set_m_r(4, ix.get() + dis(), b); break;	/* set 4, (IX + d), B */
					case 0xe1: set_m_r(4, ix.get() + dis(), c); break;	/* set 4, (IX + d), C */
					case 0xe2: set_m_r(4, ix.get() + dis(), d); break;	/* set 4, (IX + d), D */
					case 0xe3: set_m_r(4, ix.get() + dis(), e); break;	/* set 4, (IX + d), E */
					case 0xe4: set_m_r(4, ix.get() + dis(), h); break;	/* set 4, (IX + d), H */
					case 0xe5: set_m_r(4, ix.get() + dis(), l); break;	/* set 4, (IX + d), L */
					case 0xe6: set_m(4, ix.get() + dis());      break;	/* set 4, (IX + d) */
					case 0xe7: set_m_r(4, ix.get() + dis(), a); break;	/* set 4, (IX + d), A */

					case 0xe8: set_m_r(5, ix.get() + dis(), b); break;	/* set 5, (IX + d), B */
					case 0xe9: set_m_r(5, ix.get() + dis(), c); break;	/* set 5, (IX + d), C */
					case 0xea: set_m_r(5, ix.get() + dis(), d); break;	/* set 5, (IX + d), D */
					case 0xeb: set_m_r(5, ix.get() + dis(), e); break;	/* set 5, (IX + d), E */
					case 0xec: set_m_r(5, ix.get() + dis(), h); break;	/* set 5, (IX + d), H */
					case 0xed: set_m_r(5, ix.get() + dis(), l); break;	/* set 5, (IX + d), L */
					case 0xee: set_m(5, ix.get() + dis());      break;	/* set 5, (IX + d) */
					case 0xef: set_m_r(5, ix.get() + dis(), a); break;	/* set 5, (IX + d), A */

					case 0xf0: set_m_r(6, ix.get() + dis(), b); break;	/* set 6, (IX + d), B */
					case 0xf1: set_m_r(6, ix.get() + dis(), c); break;	/* set 6, (IX + d), C */
					case 0xf2: set_m_r(6, ix.get() + dis(), d); break;	/* set 6, (IX + d), D */
					case 0xf3: set_m_r(6, ix.get() + dis(), e); break;	/* set 6, (IX + d), E */
					case 0xf4: set_m_r(6, ix.get() + dis(), h); break;	/* set 6, (IX + d), H */
					case 0xf5: set_m_r(6, ix.get() + dis(), l); break;	/* set 6, (IX + d), L */
					case 0xf6: set_m(6, ix.get() + dis());      break;	/* set 6, (IX + d) */
					case 0xf7: set_m_r(6, ix.get() + dis(), a); break;	/* set 6, (IX + d), A */

					case 0xf8: set_m_r(7, ix.get() + dis(), b); break;	/* set 7, (IX + d), B */
					case 0xf9: set_m_r(7, ix.get() + dis(), c); break;	/* set 7, (IX + d), C */
					case 0xfa: set_m_r(7, ix.get() + dis(), d); break;	/* set 7, (IX + d), D */
					case 0xfb: set_m_r(7, ix.get() + dis(), e); break;	/* set 7, (IX + d), E */
					case 0xfc: set_m_r(7, ix.get() + dis(), h); break;	/* set 7, (IX + d), H */
					case 0xfd: set_m_r(7, ix.get() + dis(), l); break;	/* set 7, (IX + d), L */
					case 0xfe: set_m(7, ix.get() + dis());      break;	/* set 7, (IX + d) */
					case 0xff: set_m_r(7, ix.get() + dis(), a); break;	/* set 7, (IX + d), A */
					}
					break;
				case 0xe1: pop(ix);   break;	/* pop IX */
				case 0xe3: ex_sp(ix); break;	/* ex (SP), IX */
				case 0xe5: push(ix);  break;	/* push IX */

				case 0xe9: jp(1, ix); break;	/* jp (IX) */

				case 0xf9: ld16(sp, ix); break;	/* ld SP, IX */
				}
				break;
			case 0xde: sbc8(imm8()); break;	/* sbc n */
			case 0xdf: rst(0x18);    break;	/* rst 18H */

			case 0xe0: ret(f.npv());           break;	/* ret PO */
			case 0xe1: pop(hl);                break;	/* pop HL */
			case 0xe2: jp(f.npv(), imm16());   break;	/* jp PO, mn */
			case 0xe3: ex_sp(hl);              break;	/* ex (SP), HL */
			case 0xe4: call(f.npv(), imm16()); break;	/* call PO, mn */
			case 0xe5: push(hl);               break;	/* push HL */
			case 0xe6: and(imm8());            break;	/* and n */
			case 0xe7: rst(0x20);              break;	/* rst 20H */

			case 0xe8: ret(f.pv());           break;	/* ret PE */
			case 0xe9: jp(1, hl);             break;	/* jp (HL) */
			case 0xea: jp(f.pv(), imm16());   break;	/* jp PE, mn */
			case 0xeb: ex_r(de, hl);          break;	/* ex DE, HL */
			case 0xec: call(f.pv(), imm16()); break;	/* call PE, mn */
			case 0xed:
				pc++;
				switch(fetchEDXX()) {
				default: pc += length; break;	/* nop */

				case 0x40: in_c(b);           break;	/* in B, (C) */
				case 0x41: out_c(b);          break;	/* out (C), B */
				case 0x42: sbc16(hl, bc);     break;	/* sbc HL, BC */
				case 0x43: st16(imm16(), bc); break;	/* ld (mn), BC */
				case 0x44: neg();             break;	/* neg */
				case 0x45: retn();            break;	/* retn */
				case 0x46: im(0);             break;	/* im 0 */
				case 0x47: ld8(i, a);         break;	/* ld I, A */

				case 0x48: in_c(c);                  break;	/* in C, (C) */
				case 0x49: out_c(c);                 break;	/* out (C), C */
				case 0x4a: adc16(hl, bc);            break;	/* adc HL, BC */
				case 0x4b: ld16(bc, mem16(imm16())); break;	/* ld BC, (mn) */
				case 0x4c: neg();                    break;	/* neg */
				case 0x4d: reti();                   break;	/* reti */
				case 0x4e: im(0);                    break;	/* im 0 */
				case 0x4f: nop();                    break;	/* ld R, A */

				case 0x50: in_c(d);           break;	/* in D, (C) */
				case 0x51: out_c(d);          break;	/* out (C), D */
				case 0x52: sbc16(hl, de);     break;	/* sbc HL, DE */
				case 0x53: st16(imm16(), de); break;	/* ld (mn), DE */
				case 0x54: neg();             break;	/* neg */
				case 0x55: retn();            break;	/* retn */
				case 0x56: im(1);             break;	/* im 1 */
				case 0x57: ld_a_i();          break;	/* ld A, I */

				case 0x58: in_c(e);                  break;	/* in E, (C) */
				case 0x59: out_c(e);                 break;	/* out (C), E */
				case 0x5a: adc16(hl, de);            break;	/* adc HL, DE */
				case 0x5b: ld16(de, mem16(imm16())); break;	/* ld DE, (mn) */
				case 0x5c: neg();                    break;	/* neg */
				case 0x5d: retn();                   break;	/* retn */
				case 0x5e: im(2);                    break;	/* im 2 */
				case 0x5f: ld_a_r();                 break;	/* ld A, R */

				case 0x60: in_c(h);           break;	/* in H, (C) */
				case 0x61: out_c(h);          break;	/* out (C), H */
				case 0x62: sbc16(hl, hl);     break;	/* sbc HL, HL */
				case 0x63: st16(imm16(), hl); break;	/* ld (mn), HL */
				case 0x64: neg();             break;	/* neg */
				case 0x65: retn();            break;	/* retn */
				case 0x66: im(0);             break;	/* im 0 */
				case 0x67: rrd();             break;	/* rrd */

				case 0x68: in_c(l);                  break;	/* in L, (C) */
				case 0x69: out_c(l);                 break;	/* out (C), L */
				case 0x6a: adc16(hl, hl);            break;	/* adc HL, HL */
				case 0x6b: ld16(hl, mem16(imm16())); break;	/* ld HL, (mn) */
				case 0x6c: neg();                    break;	/* neg */
				case 0x6d: retn();                   break;	/* retn */
				case 0x6e: im(0);                    break;	/* im 0 */
				case 0x6f: rld();                    break;	/* rld */

				case 0x70: in_c(f);           break;	/* in F, (C) */
				case 0x71: out_c_0();         break;	/* out (C), 0 */
				case 0x72: sbc16(hl, sp);     break;	/* sbc HL, SP */
				case 0x73: st16(imm16(), sp); break;	/* ld (mn), SP */
				case 0x74: neg();             break;	/* neg */
				case 0x75: retn();            break;	/* retn */
				case 0x76: im(1);             break;	/* im 1 */

				case 0x78: in_c(a);                  break;	/* in A, (C) */
				case 0x79: out_c(a);                 break;	/* out (C), A */
				case 0x7a: adc16(hl, sp);            break;	/* adc HL, SP */
				case 0x7b: ld16(sp, mem16(imm16())); break;	/* ld SP, (mn) */
				case 0x7c: neg();                    break;	/* neg */
				case 0x7d: retn();                   break;	/* retn */
				case 0x7e: im(2);                    break;	/* im 2 */

				case 0xa0: ldi();  break;	/* ldi */
				case 0xa1: cpi();  break;	/* cpi */
				case 0xa2: ini();  break;	/* ini */
				case 0xa3: outi(); break;	/* outi */

				case 0xa8: ldd();  break;	/* ldd */
				case 0xa9: cpd();  break;	/* cpd */
				case 0xaa: ind();  break;	/* ind */
				case 0xab: outd(); break;	/* outd */

				case 0xb0: ldir(); break;	/* ldir */
				case 0xb1: cpir(); break;	/* cpir */
				case 0xb2: inir(); break;	/* inir */
				case 0xb3: otir(); break;	/* otir */

				case 0xb8: lddr(); break;	/* lddr */
				case 0xb9: cpdr(); break;	/* cpdr */
				case 0xba: indr(); break;	/* indr */
				case 0xbb: otdr(); break;	/* otdr */
				}
				break;
			case 0xee: xor(imm8()); break;	/* xor n */
			case 0xef: rst(0x28);   break;	/* rst 28H */

			case 0xf0: ret(f.ns());           break;	/* ret P */
			case 0xf1: pop(af);               break;	/* pop AF */
			case 0xf2: jp(f.ns(), imm16());   break;	/* jp P, mn */
			case 0xf3: di();                  break;	/* di */
			case 0xf4: call(f.ns(), imm16()); break;	/* call P, mn */
			case 0xf5: push(af);              break;	/* push AF */
			case 0xf6: or(imm8());            break;	/* or n */
			case 0xf7: rst(0x30);             break;	/* rst 30H */

			case 0xf8: ret(f.s());           break;	/* ret M */
			case 0xf9: ld16(sp, hl);         break;	/* ld SP, HL */
			case 0xfa: jp(f.s(), imm16());   break;	/* jp M, mn */
			case 0xfb: if(ei()) { continue; } else { break; }	/* ei */
			case 0xfc: call(f.s(), imm16()); break;	/* call M, mn */
			case 0xfd:
				pc++;
				switch(fetchFDXX()) {
				default: pc += length; break;	/* nop */

				case 0x09: add16(iy, bc); break;	/* add IY, BC */

				case 0x19: add16(iy, de); break;	/* add IY, DE */

				case 0x21: ld16(iy, imm16()); break;	/* ld IY, mn */
				case 0x22: st16(imm16(), iy); break;	/* ld (mn), IY */
				case 0x23: inc16(iy);         break;	/* inc IY */
				case 0x24: inc8_r(iyh);       break;	/* inc IYh */
				case 0x25: dec8_r(iyh);       break;	/* dec IYh */
				case 0x26: ld8(iyh, imm8());  break;	/* ld IYh, n */

				case 0x29: add16(iy, iy);            break;	/* add IY, IY */
				case 0x2a: ld16(iy, mem16(imm16())); break;	/* ld IY, (mn) */
				case 0x2b: dec16(iy);                break;	/* dec IY */
				case 0x2c: inc8_r(iyl);              break;	/* inc IYl */
				case 0x2d: dec8_r(iyl);              break;	/* dec IYl */
				case 0x2e: ld8(iyl, imm8());         break;	/* ld IYl, n */

				case 0x34: inc8_m(iy.get() + dis());            break;	/* inc (IY + d) */
				case 0x35: dec8_m(iy.get() + dis());            break;	/* dec (IY + d) */
				case 0x36: st8(iy.get() + dis(), mem8(pc + 2)); break;	/* ld (IY + d), n */

				case 0x39: add16(iy, sp); break;	/* ADD IY, SP */

				case 0x44: ld8(b, iyh);                 break;	/* ld B, IYh */
				case 0x45: ld8(b, iyl);                 break;	/* ld B, IYl */
				case 0x46: ld8(b, mem8(iy.get() + dis())); break;	/* ld B, (IY + d) */

				case 0x4c: ld8(c, iyh);                 break;	/* ld C, IYh */
				case 0x4d: ld8(c, iyl);                 break;	/* ld C, IYl */
				case 0x4e: ld8(c, mem8(iy.get() + dis())); break;	/* ld C, (IY + d) */

				case 0x54: ld8(d, iyh);                 break;	/* ld D, IYh */
				case 0x55: ld8(d, iyl);                 break;	/* ld D, IYl */
				case 0x56: ld8(d, mem8(iy.get() + dis())); break;	/* ld D, (IY + d) */

				case 0x5c: ld8(e, iyh);                 break;	/* ld E, IYh */
				case 0x5d: ld8(e, iyl);                 break;	/* ld E, IYl */
				case 0x5e: ld8(e, mem8(iy.get() + dis())); break;	/* ld E, (IY + d) */

				case 0x60: ld8(iyh, b);                 break;	/* ld IYh, B */
				case 0x61: ld8(iyh, c);                 break;	/* ld IYh, C */
				case 0x62: ld8(iyh, d);                 break;	/* ld IYh, D */
				case 0x63: ld8(iyh, e);                 break;	/* ld IYh, E */
				case 0x64: ld8(iyh, h);                 break;	/* ld IYh, H */
				case 0x65: ld8(iyh, l);                 break;	/* ld IYh, L */
				case 0x66: ld8(h, mem8(iy.get() + dis())); break;	/* ld H, (IY + d) */
				case 0x67: ld8(iyh, a);                 break;	/* ld IYh, A */

				case 0x68: ld8(iyl, b);                 break;	/* ld IYl, B */
				case 0x69: ld8(iyl, c);                 break;	/* ld IYl, C */
				case 0x6a: ld8(iyl, d);                 break;	/* ld IYl, D */
				case 0x6b: ld8(iyl, e);                 break;	/* ld IYl, E */
				case 0x6c: ld8(iyl, h);                 break;	/* ld IYl, H */
				case 0x6d: ld8(iyl, l);                 break;	/* ld IYl, L */
				case 0x6e: ld8(l, mem8(iy.get() + dis())); break;	/* ld L, (IY + d) */
				case 0x6f: ld8(iyl, a);                 break;	/* ld IYl, A */

				case 0x70: st8(iy.get() + dis(), b); break;	/* ld (IY + d), B */
				case 0x71: st8(iy.get() + dis(), c); break;	/* ld (IY + d), C */
				case 0x72: st8(iy.get() + dis(), d); break;	/* ld (IY + d), D */
				case 0x73: st8(iy.get() + dis(), e); break;	/* ld (IY + d), E */
				case 0x74: st8(iy.get() + dis(), h); break;	/* ld (IY + d), H */
				case 0x75: st8(iy.get() + dis(), l); break;	/* ld (IY + d), L */
				case 0x77: st8(iy.get() + dis(), a); break;	/* ld (IY + d), A */

				case 0x7c: ld8(a, iyh);                 break;	/* ld A, IYh */
				case 0x7d: ld8(a, iyl);                 break;	/* ld A, IYl */
				case 0x7e: ld8(a, mem8(iy.get() + dis())); break;	/* ld A, (IY + d) */

				case 0x84: add8(iyh);                 break;	/* add IYh */
				case 0x85: add8(iyl);                 break;	/* add IYl */
				case 0x86: add8(mem8(iy.get() + dis())); break;	/* add (IY + d) */

				case 0x8c: adc8(iyh);                 break;	/* adc IYh */
				case 0x8d: adc8(iyl);                 break;	/* adc IYl */
				case 0x8e: adc8(mem8(iy.get() + dis())); break;	/* adc (IY + d) */

				case 0x94: sub8(iyh);                 break;	/* sub IYh */
				case 0x95: sub8(iyl);                 break;	/* sub IYl */
				case 0x96: sub8(mem8(iy.get() + dis())); break;	/* sub (IY + d) */

				case 0x9c: sbc8(iyh);                 break;	/* sbc IYh */
				case 0x9d: sbc8(iyl);                 break;	/* sbc IYl */
				case 0x9e: sbc8(mem8(iy.get() + dis())); break;	/* sbc (IY + d) */

				case 0xa4: and(iyh);                 break;	/* and IYh */
				case 0xa5: and(iyl);                 break;	/* and IYl */
				case 0xa6: and(mem8(iy.get() + dis())); break;	/* and (IY + d) */

				case 0xac: xor(iyh);                 break;	/* xor IYh */
				case 0xad: xor(iyl);                 break;	/* xor IYl */
				case 0xae: xor(mem8(iy.get() + dis())); break;	/* xor (IY + d) */

				case 0xb4: or(iyh);                 break;	/* or IYh */
				case 0xb5: or(iyl);                 break;	/* or IYl */
				case 0xb6: or(mem8(iy.get() + dis())); break;	/* or (IY + d) */

				case 0xbc: cp(iyh);                 break;	/* cp IYh */
				case 0xbd: cp(iyl);                 break;	/* cp IYl */
				case 0xbe: cp(mem8(iy.get() + dis())); break;	/* cp (IY + d) */

				case 0xcb:
					switch(fetchFDCBXX()) {
					case 0x00: rlc_m_r(iy.get() + dis(), b); break;	/* rlc (IY + d), B */
					case 0x01: rlc_m_r(iy.get() + dis(), c); break;	/* rlc (IY + d), C */
					case 0x02: rlc_m_r(iy.get() + dis(), d); break;	/* rlc (IY + d), D */
					case 0x03: rlc_m_r(iy.get() + dis(), e); break;	/* rlc (IY + d), E */
					case 0x04: rlc_m_r(iy.get() + dis(), h); break;	/* rlc (IY + d), H */
					case 0x05: rlc_m_r(iy.get() + dis(), l); break;	/* rlc (IY + d), L */
					case 0x06: rlc_m(iy.get() + dis());      break;	/* rlc (IY + d) */
					case 0x07: rlc_m_r(iy.get() + dis(), a); break;	/* rlc (IY + d), A */

					case 0x08: rrc_m_r(iy.get() + dis(), b); break;	/* rrc (IY + d), B */
					case 0x09: rrc_m_r(iy.get() + dis(), c); break;	/* rrc (IY + d), C */
					case 0x0a: rrc_m_r(iy.get() + dis(), d); break;	/* rrc (IY + d), D */
					case 0x0b: rrc_m_r(iy.get() + dis(), e); break;	/* rrc (IY + d), E */
					case 0x0c: rrc_m_r(iy.get() + dis(), h); break;	/* rrc (IY + d), H */
					case 0x0d: rrc_m_r(iy.get() + dis(), l); break;	/* rrc (IY + d), L */
					case 0x0e: rrc_m(iy.get() + dis());      break;	/* rrc (IY + d) */
					case 0x0f: rrc_m_r(iy.get() + dis(), a); break;	/* rrc (IY + d), A */

					case 0x10: rl_m_r(iy.get() + dis(), b); break;	/* rl (IY + d), B */
					case 0x11: rl_m_r(iy.get() + dis(), c); break;	/* rl (IY + d), C */
					case 0x12: rl_m_r(iy.get() + dis(), d); break;	/* rl (IY + d), D */
					case 0x13: rl_m_r(iy.get() + dis(), e); break;	/* rl (IY + d), E */
					case 0x14: rl_m_r(iy.get() + dis(), h); break;	/* rl (IY + d), H */
					case 0x15: rl_m_r(iy.get() + dis(), l); break;	/* rl (IY + d), L */
					case 0x16: rl_m(iy.get() + dis());      break;	/* rl (IY + d) */
					case 0x17: rl_m_r(iy.get() + dis(), a); break;	/* rl (IY + d), A */

					case 0x18: rr_m_r(iy.get() + dis(), b); break;	/* rr (IY + d), B */
					case 0x19: rr_m_r(iy.get() + dis(), c); break;	/* rr (IY + d), C */
					case 0x1a: rr_m_r(iy.get() + dis(), d); break;	/* rr (IY + d), D */
					case 0x1b: rr_m_r(iy.get() + dis(), e); break;	/* rr (IY + d), E */
					case 0x1c: rr_m_r(iy.get() + dis(), h); break;	/* rr (IY + d), H */
					case 0x1d: rr_m_r(iy.get() + dis(), l); break;	/* rr (IY + d), L */
					case 0x1e: rr_m(iy.get() + dis());      break;	/* rr (IY + d) */
					case 0x1f: rr_m_r(iy.get() + dis(), a); break;	/* rr (IY + d), A */

					case 0x20: sla_m_r(iy.get() + dis(), b); break;	/* sla (IY + d), B */
					case 0x21: sla_m_r(iy.get() + dis(), c); break;	/* sla (IY + d), C */
					case 0x22: sla_m_r(iy.get() + dis(), d); break;	/* sla (IY + d), D */
					case 0x23: sla_m_r(iy.get() + dis(), e); break;	/* sla (IY + d), E */
					case 0x24: sla_m_r(iy.get() + dis(), h); break;	/* sla (IY + d), H */
					case 0x25: sla_m_r(iy.get() + dis(), l); break;	/* sla (IY + d), L */
					case 0x26: sla_m(iy.get() + dis());      break;	/* sla (IY + d) */
					case 0x27: sla_m_r(iy.get() + dis(), a); break;	/* sla (IY + d), A */

					case 0x28: sra_m_r(iy.get() + dis(), b); break;	/* sra (IY + d), B */
					case 0x29: sra_m_r(iy.get() + dis(), c); break;	/* sra (IY + d), C */
					case 0x2a: sra_m_r(iy.get() + dis(), d); break;	/* sra (IY + d), D */
					case 0x2b: sra_m_r(iy.get() + dis(), e); break;	/* sra (IY + d), E */
					case 0x2c: sra_m_r(iy.get() + dis(), h); break;	/* sra (IY + d), H */
					case 0x2d: sra_m_r(iy.get() + dis(), l); break;	/* sra (IY + d), L */
					case 0x2e: sra_m(iy.get() + dis());      break;	/* sra (IY + d) */
					case 0x2f: sra_m_r(iy.get() + dis(), a); break;	/* sra (IY + d), A */

					case 0x30: sll_m_r(iy.get() + dis(), b); break;	/* sll (IY + d), B */
					case 0x31: sll_m_r(iy.get() + dis(), c); break;	/* sll (IY + d), C */
					case 0x32: sll_m_r(iy.get() + dis(), d); break;	/* sll (IY + d), D */
					case 0x33: sll_m_r(iy.get() + dis(), e); break;	/* sll (IY + d), E */
					case 0x34: sll_m_r(iy.get() + dis(), h); break;	/* sll (IY + d), H */
					case 0x35: sll_m_r(iy.get() + dis(), l); break;	/* sll (IY + d), L */
					case 0x36: sll_m(iy.get() + dis());      break;	/* sll (IY + d) */
					case 0x37: sll_m_r(iy.get() + dis(), a); break;	/* sll (IY + d), A */

					case 0x38: srl_m_r(iy.get() + dis(), b); break;	/* srl (IY + d), B */
					case 0x39: srl_m_r(iy.get() + dis(), c); break;	/* srl (IY + d), C */
					case 0x3a: srl_m_r(iy.get() + dis(), d); break;	/* srl (IY + d), D */
					case 0x3b: srl_m_r(iy.get() + dis(), e); break;	/* srl (IY + d), E */
					case 0x3c: srl_m_r(iy.get() + dis(), h); break;	/* srl (IY + d), H */
					case 0x3d: srl_m_r(iy.get() + dis(), l); break;	/* srl (IY + d), L */
					case 0x3e: srl_m(iy.get() + dis());      break;	/* srl (IY + d) */
					case 0x3f: srl_m_r(iy.get() + dis(), a); break;	/* srl (IY + d), A */

					case 0x40:
					case 0x41:
					case 0x42:
					case 0x43:
					case 0x44:
					case 0x45:
					case 0x46:
					case 0x47: bit(0, mem8(iy.get() + dis())); break;	/* bit 0, (IY + d) */

					case 0x48:
					case 0x49:
					case 0x4a:
					case 0x4b:
					case 0x4c:
					case 0x4d:
					case 0x4e:
					case 0x4f: bit(1, mem8(iy.get() + dis())); break;	/* bit 1, (IY + d) */

					case 0x50:
					case 0x51:
					case 0x52:
					case 0x53:
					case 0x54:
					case 0x55:
					case 0x56:
					case 0x57: bit(2, mem8(iy.get() + dis())); break;	/* bit 2, (IY + d) */

					case 0x58:
					case 0x59:
					case 0x5a:
					case 0x5b:
					case 0x5c:
					case 0x5d:
					case 0x5e:
					case 0x5f: bit(3, mem8(iy.get() + dis())); break;	/* bit 3, (IY + d) */

					case 0x60:
					case 0x61:
					case 0x62:
					case 0x63:
					case 0x64:
					case 0x65:
					case 0x66:
					case 0x67: bit(4, mem8(iy.get() + dis())); break;	/* bit 4, (IY + d) */

					case 0x68:
					case 0x69:
					case 0x6a:
					case 0x6b:
					case 0x6c:
					case 0x6d:
					case 0x6e:
					case 0x6f: bit(5, mem8(iy.get() + dis())); break;	/* bit 5, (IY + d) */

					case 0x70:
					case 0x71:
					case 0x72:
					case 0x73:
					case 0x74:
					case 0x75:
					case 0x76:
					case 0x77: bit(6, mem8(iy.get() + dis())); break;	/* bit 6, (IY + d) */

					case 0x78:
					case 0x79:
					case 0x7a:
					case 0x7b:
					case 0x7c:
					case 0x7d:
					case 0x7e:
					case 0x7f: bit(7, mem8(iy.get() + dis())); break;	/* bit 7, (IY + d) */

					case 0x80: res_m_r(0, iy.get() + dis(), b); break;	/* res 0, (IY + d), B */
					case 0x81: res_m_r(0, iy.get() + dis(), c); break;	/* res 0, (IY + d), C */
					case 0x82: res_m_r(0, iy.get() + dis(), d); break;	/* res 0, (IY + d), D */
					case 0x83: res_m_r(0, iy.get() + dis(), e); break;	/* res 0, (IY + d), E */
					case 0x84: res_m_r(0, iy.get() + dis(), h); break;	/* res 0, (IY + d), H */
					case 0x85: res_m_r(0, iy.get() + dis(), l); break;	/* res 0, (IY + d), L */
					case 0x86: res_m(0, iy.get() + dis());      break;	/* res 0, (IY + d) */
					case 0x87: res_m_r(0, iy.get() + dis(), a); break;	/* res 0, (IY + d), A */

					case 0x88: res_m_r(1, iy.get() + dis(), b); break;	/* res 1, (IY + d), B */
					case 0x89: res_m_r(1, iy.get() + dis(), c); break;	/* res 1, (IY + d), C */
					case 0x8a: res_m_r(1, iy.get() + dis(), d); break;	/* res 1, (IY + d), D */
					case 0x8b: res_m_r(1, iy.get() + dis(), e); break;	/* res 1, (IY + d), E */
					case 0x8c: res_m_r(1, iy.get() + dis(), h); break;	/* res 1, (IY + d), H */
					case 0x8d: res_m_r(1, iy.get() + dis(), l); break;	/* res 1, (IY + d), L */
					case 0x8e: res_m(1, iy.get() + dis());      break;	/* res 1, (IY + d) */
					case 0x8f: res_m_r(1, iy.get() + dis(), a); break;	/* res 1, (IY + d), A */

					case 0x90: res_m_r(2, iy.get() + dis(), b); break;	/* res 2, (IY + d), B */
					case 0x91: res_m_r(2, iy.get() + dis(), c); break;	/* res 2, (IY + d), C */
					case 0x92: res_m_r(2, iy.get() + dis(), d); break;	/* res 2, (IY + d), D */
					case 0x93: res_m_r(2, iy.get() + dis(), e); break;	/* res 2, (IY + d), E */
					case 0x94: res_m_r(2, iy.get() + dis(), h); break;	/* res 2, (IY + d), H */
					case 0x95: res_m_r(2, iy.get() + dis(), l); break;	/* res 2, (IY + d), L */
					case 0x96: res_m(2, iy.get() + dis());      break;	/* res 2, (IY + d) */
					case 0x97: res_m_r(2, iy.get() + dis(), a); break;	/* res 2, (IY + d), A */

					case 0x98: res_m_r(3, iy.get() + dis(), b); break;	/* res 3, (IY + d), B */
					case 0x99: res_m_r(3, iy.get() + dis(), c); break;	/* res 3, (IY + d), C */
					case 0x9a: res_m_r(3, iy.get() + dis(), d); break;	/* res 3, (IY + d), D */
					case 0x9b: res_m_r(3, iy.get() + dis(), e); break;	/* res 3, (IY + d), E */
					case 0x9c: res_m_r(3, iy.get() + dis(), h); break;	/* res 3, (IY + d), H */
					case 0x9d: res_m_r(3, iy.get() + dis(), l); break;	/* res 3, (IY + d), L */
					case 0x9e: res_m(3, iy.get() + dis());      break;	/* res 3, (IY + d) */
					case 0x9f: res_m_r(3, iy.get() + dis(), a); break;	/* res 3, (IY + d), A */

					case 0xa0: res_m_r(4, iy.get() + dis(), b); break;	/* res 4, (IY + d), B */
					case 0xa1: res_m_r(4, iy.get() + dis(), c); break;	/* res 4, (IY + d), C */
					case 0xa2: res_m_r(4, iy.get() + dis(), d); break;	/* res 4, (IY + d), D */
					case 0xa3: res_m_r(4, iy.get() + dis(), e); break;	/* res 4, (IY + d), E */
					case 0xa4: res_m_r(4, iy.get() + dis(), h); break;	/* res 4, (IY + d), H */
					case 0xa5: res_m_r(4, iy.get() + dis(), l); break;	/* res 4, (IY + d), L */
					case 0xa6: res_m(4, iy.get() + dis());      break;	/* res 4, (IY + d) */
					case 0xa7: res_m_r(4, iy.get() + dis(), a); break;	/* res 4, (IY + d), A */

					case 0xa8: res_m_r(5, iy.get() + dis(), b); break;	/* res 5, (IY + d), B */
					case 0xa9: res_m_r(5, iy.get() + dis(), c); break;	/* res 5, (IY + d), C */
					case 0xaa: res_m_r(5, iy.get() + dis(), d); break;	/* res 5, (IY + d), D */
					case 0xab: res_m_r(5, iy.get() + dis(), e); break;	/* res 5, (IY + d), E */
					case 0xac: res_m_r(5, iy.get() + dis(), h); break;	/* res 5, (IY + d), H */
					case 0xad: res_m_r(5, iy.get() + dis(), l); break;	/* res 5, (IY + d), L */
					case 0xae: res_m(5, iy.get() + dis());      break;	/* res 5, (IY + d) */
					case 0xaf: res_m_r(5, iy.get() + dis(), a); break;	/* res 5, (IY + d), A */

					case 0xb0: res_m_r(6, iy.get() + dis(), b); break;	/* res 6, (IY + d), B */
					case 0xb1: res_m_r(6, iy.get() + dis(), c); break;	/* res 6, (IY + d), C */
					case 0xb2: res_m_r(6, iy.get() + dis(), d); break;	/* res 6, (IY + d), D */
					case 0xb3: res_m_r(6, iy.get() + dis(), e); break;	/* res 6, (IY + d), E */
					case 0xb4: res_m_r(6, iy.get() + dis(), h); break;	/* res 6, (IY + d), H */
					case 0xb5: res_m_r(6, iy.get() + dis(), l); break;	/* res 6, (IY + d), L */
					case 0xb6: res_m(6, iy.get() + dis());      break;	/* res 6, (IY + d) */
					case 0xb7: res_m_r(6, iy.get() + dis(), a); break;	/* res 6, (IY + d), A */

					case 0xb8: res_m_r(7, iy.get() + dis(), b); break;	/* res 7, (IY + d), B */
					case 0xb9: res_m_r(7, iy.get() + dis(), c); break;	/* res 7, (IY + d), C */
					case 0xba: res_m_r(7, iy.get() + dis(), d); break;	/* res 7, (IY + d), D */
					case 0xbb: res_m_r(7, iy.get() + dis(), e); break;	/* res 7, (IY + d), E */
					case 0xbc: res_m_r(7, iy.get() + dis(), h); break;	/* res 7, (IY + d), H */
					case 0xbd: res_m_r(7, iy.get() + dis(), l); break;	/* res 7, (IY + d), L */
					case 0xbe: res_m(7, iy.get() + dis());      break;	/* res 7, (IY + d) */
					case 0xbf: res_m_r(7, iy.get() + dis(), a); break;	/* res 7, (IY + d), A */

					case 0xc0: set_m_r(0, iy.get() + dis(), b); break;	/* set 0, (IY + d), B */
					case 0xc1: set_m_r(0, iy.get() + dis(), c); break;	/* set 0, (IY + d), C */
					case 0xc2: set_m_r(0, iy.get() + dis(), d); break;	/* set 0, (IY + d), D */
					case 0xc3: set_m_r(0, iy.get() + dis(), e); break;	/* set 0, (IY + d), E */
					case 0xc4: set_m_r(0, iy.get() + dis(), h); break;	/* set 0, (IY + d), H */
					case 0xc5: set_m_r(0, iy.get() + dis(), l); break;	/* set 0, (IY + d), L */
					case 0xc6: set_m(0, iy.get() + dis());      break;	/* set 0, (IY + d) */
					case 0xc7: set_m_r(0, iy.get() + dis(), a); break;	/* set 0, (IY + d), A */

					case 0xc8: set_m_r(1, iy.get() + dis(), b); break;	/* set 1, (IY + d), B */
					case 0xc9: set_m_r(1, iy.get() + dis(), c); break;	/* set 1, (IY + d), C */
					case 0xca: set_m_r(1, iy.get() + dis(), d); break;	/* set 1, (IY + d), D */
					case 0xcb: set_m_r(1, iy.get() + dis(), e); break;	/* set 1, (IY + d), E */
					case 0xcc: set_m_r(1, iy.get() + dis(), h); break;	/* set 1, (IY + d), H */
					case 0xcd: set_m_r(1, iy.get() + dis(), l); break;	/* set 1, (IY + d), L */
					case 0xce: set_m(1, iy.get() + dis());      break;	/* set 1, (IY + d) */
					case 0xcf: set_m_r(1, iy.get() + dis(), a); break;	/* set 1, (IY + d), A */

					case 0xd0: set_m_r(2, iy.get() + dis(), b); break;	/* set 2, (IY + d), B */
					case 0xd1: set_m_r(2, iy.get() + dis(), c); break;	/* set 2, (IY + d), C */
					case 0xd2: set_m_r(2, iy.get() + dis(), d); break;	/* set 2, (IY + d), D */
					case 0xd3: set_m_r(2, iy.get() + dis(), e); break;	/* set 2, (IY + d), E */
					case 0xd4: set_m_r(2, iy.get() + dis(), h); break;	/* set 2, (IY + d), H */
					case 0xd5: set_m_r(2, iy.get() + dis(), l); break;	/* set 2, (IY + d), L */
					case 0xd6: set_m(2, iy.get() + dis());      break;	/* set 2, (IY + d) */
					case 0xd7: set_m_r(2, iy.get() + dis(), a); break;	/* set 2, (IY + d), A */

					case 0xd8: set_m_r(3, iy.get() + dis(), b); break;	/* set 3, (IY + d), B */
					case 0xd9: set_m_r(3, iy.get() + dis(), c); break;	/* set 3, (IY + d), C */
					case 0xda: set_m_r(3, iy.get() + dis(), d); break;	/* set 3, (IY + d), D */
					case 0xdb: set_m_r(3, iy.get() + dis(), e); break;	/* set 3, (IY + d), E */
					case 0xdc: set_m_r(3, iy.get() + dis(), h); break;	/* set 3, (IY + d), H */
					case 0xdd: set_m_r(3, iy.get() + dis(), l); break;	/* set 3, (IY + d), L */
					case 0xde: set_m(3, iy.get() + dis());      break;	/* set 3, (IY + d) */
					case 0xdf: set_m_r(3, iy.get() + dis(), a); break;	/* set 3, (IY + d), A */

					case 0xe0: set_m_r(4, iy.get() + dis(), b); break;	/* set 4, (IY + d), B */
					case 0xe1: set_m_r(4, iy.get() + dis(), c); break;	/* set 4, (IY + d), C */
					case 0xe2: set_m_r(4, iy.get() + dis(), d); break;	/* set 4, (IY + d), D */
					case 0xe3: set_m_r(4, iy.get() + dis(), e); break;	/* set 4, (IY + d), E */
					case 0xe4: set_m_r(4, iy.get() + dis(), h); break;	/* set 4, (IY + d), H */
					case 0xe5: set_m_r(4, iy.get() + dis(), l); break;	/* set 4, (IY + d), L */
					case 0xe6: set_m(4, iy.get() + dis());      break;	/* set 4, (IY + d) */
					case 0xe7: set_m_r(4, iy.get() + dis(), a); break;	/* set 4, (IY + d), A */

					case 0xe8: set_m_r(5, iy.get() + dis(), b); break;	/* set 5, (IY + d), B */
					case 0xe9: set_m_r(5, iy.get() + dis(), c); break;	/* set 5, (IY + d), C */
					case 0xea: set_m_r(5, iy.get() + dis(), d); break;	/* set 5, (IY + d), D */
					case 0xeb: set_m_r(5, iy.get() + dis(), e); break;	/* set 5, (IY + d), E */
					case 0xec: set_m_r(5, iy.get() + dis(), h); break;	/* set 5, (IY + d), H */
					case 0xed: set_m_r(5, iy.get() + dis(), l); break;	/* set 5, (IY + d), L */
					case 0xee: set_m(5, iy.get() + dis());      break;	/* set 5, (IY + d) */
					case 0xef: set_m_r(5, iy.get() + dis(), a); break;	/* set 5, (IY + d), A */

					case 0xf0: set_m_r(6, iy.get() + dis(), b); break;	/* set 6, (IY + d), B */
					case 0xf1: set_m_r(6, iy.get() + dis(), c); break;	/* set 6, (IY + d), C */
					case 0xf2: set_m_r(6, iy.get() + dis(), d); break;	/* set 6, (IY + d), D */
					case 0xf3: set_m_r(6, iy.get() + dis(), e); break;	/* set 6, (IY + d), E */
					case 0xf4: set_m_r(6, iy.get() + dis(), h); break;	/* set 6, (IY + d), H */
					case 0xf5: set_m_r(6, iy.get() + dis(), l); break;	/* set 6, (IY + d), L */
					case 0xf6: set_m(6, iy.get() + dis());      break;	/* set 6, (IY + d) */
					case 0xf7: set_m_r(6, iy.get() + dis(), a); break;	/* set 6, (IY + d), A */

					case 0xf8: set_m_r(7, iy.get() + dis(), b); break;	/* set 7, (IY + d), B */
					case 0xf9: set_m_r(7, iy.get() + dis(), c); break;	/* set 7, (IY + d), C */
					case 0xfa: set_m_r(7, iy.get() + dis(), d); break;	/* set 7, (IY + d), D */
					case 0xfb: set_m_r(7, iy.get() + dis(), e); break;	/* set 7, (IY + d), E */
					case 0xfc: set_m_r(7, iy.get() + dis(), h); break;	/* set 7, (IY + d), H */
					case 0xfd: set_m_r(7, iy.get() + dis(), l); break;	/* set 7, (IY + d), L */
					case 0xfe: set_m(7, iy.get() + dis());      break;	/* set 7, (IY + d) */
					case 0xff: set_m_r(7, iy.get() + dis(), a); break;	/* set 7, (IY + d), A */
					}
					break;
				case 0xe1: pop(iy);   break;	/* pop IY */
				case 0xe3: ex_sp(iy); break;	/* ex (SP), IY */
				case 0xe5: push(iy);  break;	/* push IY */

				case 0xe9: jp(1, iy); break;	/* jp (IY) */

				case 0xf9: ld16(sp, iy); break;	/* ld SP, IY */
				}
				break;
			case 0xfe: cp(imm8()); break;	/* cp n */
			case 0xff: rst(0x38);  break;	/* rst 38H */
			}

			restStates -= states;
		} while(restStates > 0);

		return 0;
	}
}

/*
	Copyright 2011~2015 maruhiro
	All rights reserved.

	Redistribution and use in source and binary forms,
	with or without modification, are permitted provided that
	the following conditions are met:

	 1. Redistributions of source code must retain the above copyright notice,
	    this list of conditions and the following disclaimer.

	 2. Redistributions in binary form must reproduce the above copyright notice,
	    this list of conditions and the following disclaimer in the documentation
	    and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
	THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/* eof */