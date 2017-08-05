package jp.gr.java_conf.ver0.g800a;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.Arrays;

import jp.gr.java_conf.ver0.tool.DataFormatException;
import jp.gr.java_conf.ver0.tool.FileDialog;
import jp.gr.java_conf.ver0.tool.HexFile;
import jp.gr.java_conf.ver0.tool.OnFileSelectedListener;
import jp.gr.java_conf.ver0.z80.g800.G800Emulator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.SubMenu;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnKeyListener;
import android.view.View.OnTouchListener;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.Toast;

/*
	g800a - SHARP POCKET COMPUTER PC-G850/G815/E200 Emulator for Android
*/
public class MainActivity extends Activity implements OnTouchListener
{
	/*
		実行クラス
	*/
	private class G800Run extends SurfaceView implements Runnable, SurfaceHolder.Callback
	{
		/* スレッド */
		private Thread thread = null;

		/* スレッドを実行するか? */
		private boolean exe = false;

		/* 進捗バー */
		ProgressDialog progressDialog;

		/* 幅 */
		private int width = 0;

		/* 高さ */
		private int height = 0;

		/*
			コンストラクタ
		*/
		public G800Run(Context context)
		{
			super(context);
			getHolder().addCallback(this);
		}

		/*
			開始する
		*/
		public void start()
		{
			if(thread != null)
				thread = null;

			exe = true;
			thread = new Thread(this);
			thread.start();
		}

		/*
			停止する
		*/
		public void stop()
		{
			exe = false;
			if(thread != null)
				try {
					thread.join();
				} catch(Exception e) {
				}
			thread = null;
		}

		/*
			スレッドが動いているか?
		*/
		public boolean isAlive()
		{
			return thread != null;
		}

		/*
			生成された
		*/
		@Override public void surfaceCreated(SurfaceHolder holder)
		{
			if(width == 0) {
				width = getWidth();
				height = getHeight();
			}

			g800.refreshLcd();
			if(!isAlive())
				start();
		}

		/*
			破棄された
		*/
		@Override public void surfaceDestroyed(SurfaceHolder holder)
		{
			stop();
		}

		/*
			変化した
		*/
		@Override public void surfaceChanged(SurfaceHolder holder, int format, int width, int height)
		{
			g800.refreshLcd();
		}

		/*
			実行スレッド
		*/
		@Override public void run()
		{
			if(g800 == null)
				return;
			if(g800.getLcdWidth() <= 0 || g800.getLcdHeight() <= 0)
				return;

			/* ドットの位置を求める */
			final int lcd_width = g800.getLcdWidth();
			final int lcd_height = g800.getLcdHeight();
			final int lcd_matrix_x = lcdMatrixRect.left - lcdRect.left;
			final int lcd_matrix_y = lcdMatrixRect.top - lcdRect.top;
			Rect dot_rect[][] = new Rect[64][g800.getLcdWidth() + 1];
			int x, y;

			for(y = 0; y < lcd_height; y++)
				for(x = 0; x < lcd_width; x++)
					dot_rect[y][x] = new Rect(lcd_matrix_x + x * g800.getZoomX(), lcd_matrix_y + y * g800.getZoomY(), lcd_matrix_x + (x + 1) * g800.getZoomX(), lcd_matrix_y + (y + 1) * g800.getZoomY());

			/* ステータス部の位置を求め, 画像を生成する */
			G800Emulator.Area area;
			Bitmap status_bitmap[][] = new Bitmap[64][g800.getLcdScales()];
			Canvas canvas;
			Paint paint;
			float widths[], status_text_width;
			int scale, i, bar_count = 0;

			for(y = 0; y < 64; y++) {
				if((area = g800.getLayout(G800Emulator.LAYOUT_LCD_STATUS_FIRST + y)) == null)
					continue;
				dot_rect[y][lcd_width] = new Rect(area.x - lcdRect.left, area.y - lcdRect.top, area.x - lcdRect.left + area.width, area.y - lcdRect.top + area.height);

				widths = new float[area.text.length()];

				for(scale = 0; scale < g800.getLcdScales(); scale++) {
					status_bitmap[y][scale] = Bitmap.createBitmap(area.width * 2, area.height * 2, Bitmap.Config.ARGB_4444);
					canvas = new Canvas(status_bitmap[y][scale]);
					canvas.drawRect(0, 0, status_bitmap[y][scale].getWidth(), status_bitmap[y][scale].getHeight(), lcdBackColor);
					paint = new Paint();
					paint.setTypeface(Typeface.MONOSPACE);
					paint.setColor(lcdColor[scale].getColor());
					paint.setTextSize(status_bitmap[y][scale].getHeight());
					paint.getTextWidths(area.text, widths);
					for(i = 0, status_text_width = 0.0f; i < widths.length; status_text_width += widths[i++])
						;
					paint.setTextScaleX(status_bitmap[y][scale].getWidth() / status_text_width);
					canvas.drawText(area.text, 0, status_bitmap[y][scale].getHeight() - 1, paint);
					status_bitmap[y][scale] = Bitmap.createScaledBitmap(status_bitmap[y][scale], area.width, area.height, true);
				}
			}

			/* バッファを確保する */
			Bitmap buffer_bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
			Rect update_rect = new Rect(0, 0, width, height);
			Canvas buffer_canvas = new Canvas(buffer_bitmap);
			buffer_canvas.drawRect(update_rect, lcdBackColor);


			/* メインループ */
			SurfaceHolder holder = getHolder();
			long start_time, sleep_time;
			int pin11, pin11prev = 0, pin11changed;
			boolean drawn;

			System.gc();

			startTime = System.currentTimeMillis();
			totalStates = 0;

			while(exe) {
				start_time = System.currentTimeMillis();

				/* 実行する */
				synchronized(g800) {
					g800.run();
				}

				/* 画面を更新する */
				drawn = false;
				for(y = 0; y < lcd_height; y++)
					for(x = 0; x < lcd_width; x++)
						if(g800.isLcdChanged(x, y)) {
							buffer_canvas.drawRect(dot_rect[y][x], lcdColor[g800.getLcdScale(x, y)]);
							drawn = true;
							if(update_rect.left > dot_rect[y][x].left)
								update_rect.left = dot_rect[y][x].left;
							if(update_rect.right < dot_rect[y][x].right)
								update_rect.right = dot_rect[y][x].right;
							if(update_rect.top > dot_rect[y][x].top)
								update_rect.top = dot_rect[y][x].top;
							if(update_rect.bottom < dot_rect[y][x].bottom)
								update_rect.bottom = dot_rect[y][x].bottom;
						}
				for(y = 0; y < 64; y++)
					if(g800.isLcdChanged(lcd_width, y)) {
						if(dot_rect[y][lcd_width] == null)
							continue;
						buffer_canvas.drawBitmap(status_bitmap[y][g800.getLcdScale(lcd_width, y)], dot_rect[y][lcd_width].left, dot_rect[y][lcd_width].top, null);
						drawn = true;
						if(update_rect.left > dot_rect[y][lcd_width].left)
							update_rect.left = dot_rect[y][lcd_width].left;
						if(update_rect.right < dot_rect[y][lcd_width].right)
							update_rect.right = dot_rect[y][lcd_width].right;
						if(update_rect.top > dot_rect[y][lcd_width].top)
							update_rect.top = dot_rect[y][lcd_width].top;
						if(update_rect.bottom < dot_rect[y][lcd_width].bottom)
							update_rect.bottom = dot_rect[y][lcd_width].bottom;
					}
				if(drawn) {
					canvas = holder.lockCanvas(update_rect);
					if(canvas != null) {
						canvas.drawBitmap(buffer_bitmap, update_rect, update_rect, null);
						holder.unlockCanvasAndPost(canvas);
					}
				}
				update_rect.left = Integer.MAX_VALUE;
				update_rect.top = Integer.MAX_VALUE;
				update_rect.right = Integer.MIN_VALUE;
				update_rect.bottom = Integer.MIN_VALUE;

				/* 電源OFFしたか? */
				if(g800.isOff()) {
					MainActivity.this.saveRam();
					thread = null;
					MainActivity.this.finish();
					return;
				}

				/* SIOの状態を得る */
				pin11 = g800.get11Pin();
				pin11changed = pin11 ^ pin11prev;
				pin11prev = pin11;

				/* BUSYが変化したか? */
				if((pin11changed & 0x008) != 0) {
					if((pin11 & 0x008) != 0) {
						/* BUSYになったら進捗バーを表示する */
						MainActivity.this.postRunnable(new Runnable()
						{
							@Override public void run()
							{
								progressDialog = new ProgressDialog(MainActivity.this);
								switch(g800.getSioMode()) {
								case G800Emulator.SIO_MODE_IN:
									progressDialog.setTitle(getString(R.string.reading));
									progressDialog.setMessage(g800.getSioInfile());
									break;
								case G800Emulator.SIO_MODE_OUT:
									progressDialog.setTitle(getString(R.string.writing));
									progressDialog.setMessage(g800.getSioOutfile());
									break;
								}
								progressDialog.setCancelable(true);
								progressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
								progressDialog.show();
							}
						});
						bar_count = 0;
					} else {
						/* BUSYでなくなったら進捗バーを消す */
						if (progressDialog != null) {
							progressDialog.cancel();
							progressDialog = null;
						}
					}
				}

				/* BUSYなら進捗を表示する */
				if((pin11 & 0x008) != 0)
					if(progressDialog != null && g800.getSioBuffer() != null)
						if(bar_count++ % g800.getFps() == 0) {
							progressDialog.setMax(g800.getSioBuffer().length);
							progressDialog.setProgress(g800.getSioPos());
						}

				/* 待つ */
				sleep_time = interval - (System.currentTimeMillis() - start_time);
				try {
					if(sleep_time > 0)
						Thread.sleep(sleep_time);
				} catch(Exception e) {
				}

				/* 累積時間を求める */
				totalStates += g800.getCpuClocks() / g800.getFps();
			}
		}
	}

	/* ボタンの状態: 通常 */
	static private final int BUTTONSTATUS_NORMAL = 0;

	/* ボタンの状態: 押されている */
	static private final int BUTTONSTATUS_PRESSED = 1;

	/* メニュー: SIO... */
	static private final int MENU_SIO = Menu.FIRST + 1;

	/* メニュー: 入出力なし */
	static private final int MENU_SIO_STOP = Menu.FIRST + 2;

	/* メニュー: ファイルから入力 */
	static private final int MENU_SIO_IN = Menu.FIRST + 3;

	/* メニュー: ファイルへ出力 */
	static private final int MENU_SIO_OUT = Menu.FIRST + 4;

	/* メニュー: 直接ロード */
	static private final int MENU_DIRECT_LOAD = Menu.FIRST + 5;

	/* メニュー: リセット */
	static private final int MENU_RESET = Menu.FIRST + 6;

	/* メニュー: 設定... */
	static private final int MENU_SETTINGS = Menu.FIRST + 7;

	/* メニュー: ROMイメージを読み込む */
	static private final int MENU_IMPORT_ROM = Menu.FIRST + 8;

	/* メニュー: (IS01のみ)右側のメニューを消す/表示する */
	static private final int MENU_HIDE_RIGHTMENU = Menu.FIRST + 10;

	/* メニュー: CPUクロック数を表示する */
	static private final int MENU_CLOCKS = Menu.FIRST + 11;

	/* メニュー: 機種... */
	static private final int MENU_MACHINE = Menu.FIRST + 12;

	/* メニュー: PC-E200 */
	static private final int MENU_MACHINE_E200 = Menu.FIRST + 13;

	/* メニュー: PC-G815 */
	static private final int MENU_MACHINE_G815 = Menu.FIRST + 14;

	/* メニュー: PC-G850 */
	static private final int MENU_MACHINE_G850 = Menu.FIRST + 15;

	/* メニュー: 実行 */
	static private final int MENU_GO = Menu.FIRST + 16;

	/* メニュー: 終了 */
	static private final int MENU_QUIT = Menu.FIRST + 99;

	/* メイン(全画面)のレイアウト */
	private RelativeLayout mainLayout;

	/* 設定 */
	private SharedPreferences preferences = null;

	/* IS01のスクリーンモード */
	private Method setFullScreenModeMethod = null;

	/* エミュレータ */
	private G800Emulator g800 = null;

	/* エミュレータ実行 */
	private G800Run g800run = null;

	/* ハンドラ */
	private Handler handler = new Handler();

	/* 更新周期 */
	private int interval;

	/* Androidのキーに割り当てられたPC-G800のキーコード */
	private int aKey[] = new int[256];

	/* レイアウト番号とPC-G800キーコードの対応 */
	private int lKey[] = new int[G800Emulator.LAYOUT_KEY_LAST + 1];

	/* LCD全体の位置 */
	private Rect lcdRect;

	/* LCDのマトリクス部の位置 */
	private Rect lcdMatrixRect;

	/* LCDの背景色 */
	private Paint lcdBackColor;

	/* LCDの色 */
	private Paint lcdColor[];

	/* ボタンの背景画像 */
	private Drawable buttonBackground[][];

	/* 開始時刻 */
	private long startTime;

	/* 累積時間 */
	private long totalStates;

	/*
		別スレッドからの実行
	*/
	private void postRunnable(Runnable run)
	{
		handler.post(run);
	}

	/*
		位置を得る
	*/
	private Rect getMargins(int index)
	{
		G800Emulator.Area area = g800.getLayout(index);
		if(area == null)
			return null;

		return new Rect(
		mainLayout.getLeft() + area.x,
		mainLayout.getTop() + area.y,
		mainLayout.getRight() - (area.x + area.width - 1),
		mainLayout.getBottom() - (area.y + area.height - 1)
		);
	}

	/*
		レイアウトのパラメータを得る
	*/
	private RelativeLayout.LayoutParams createLayoutParams(Rect margins)
	{
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		if(margins == null) {
			return params;
		}
		params.setMargins(margins.left, margins.top, margins.right, margins.bottom);
		return params;
	}

	/*
		レイアウトのパラメータを得る
	*/
	private RelativeLayout.LayoutParams createLayoutParams(int index)
	{
		return createLayoutParams(getMargins(index));
	}

	/*
		Rectを拡大する
	*/
	/*
	private Rect zoomRect(Rect rect, int zoom_x, int zoom_y)
	{
		if(rect == null)
			return null;

		return new Rect(rect.left * zoom_x, rect.top * zoom_y, rect.right * zoom_x, rect.bottom * zoom_y);
	}
	*/

	/*
		RectFを拡大する
	*/
	private RectF zoomRect(RectF rect, int zoom_x, int zoom_y)
	{
		if(rect == null)
			return null;

		return new RectF(rect.left * zoom_x, rect.top * zoom_y, rect.right * zoom_x, rect.bottom * zoom_y);
	}

	/*
		色を得る
	*/
	private int getColor(int color)
	{
		switch(color) {
		case G800Emulator.COLOR_DARKGRAY:
			return Color.rgb(0x18, 0x18, 0x18);
		case G800Emulator.COLOR_GRAY:
			return Color.rgb(0x33, 0x33, 0x33);
		case G800Emulator.COLOR_LIGHTGRAY:
			return Color.GRAY;
		case G800Emulator.COLOR_WHITE:
			return Color.LTGRAY;
		case G800Emulator.COLOR_RED:
			return Color.rgb(0x88, 0x44, 0x44);
		case G800Emulator.COLOR_LIGHTRED:
			return Color.rgb(0xff, 0x55, 0x55);
		case G800Emulator.COLOR_GREEN:
			return Color.rgb(0x44, 0x88, 0x44);
		case G800Emulator.COLOR_LIGHTGREEN:
			return Color.rgb(0x55, 0xff, 0x55);
		case G800Emulator.COLOR_YELLOW:
			return Color.rgb(0xaa, 0x88, 0x44);
		case G800Emulator.COLOR_LIGHTYELLOW:
			return Color.rgb(0xee, 0xcc, 0x44);
		case G800Emulator.COLOR_BLUE:
			return Color.rgb(0xaa, 0xaa, 0xee);
		default:
			return Color.BLACK;
		}
	}

	/*
		リターンキーの背景画像を生成する
	*/
	private Drawable createReturnButtonBackground(int index, int key_status)
	{
		/* 位置を得る */
		G800Emulator.Area area = g800.getLayout(index, 0, 0, 2, 2);
		if(area == null)
			return null;
		int h = g800.getLayout(G800Emulator.LAYOUT_KEY_A, 0, 0, 2, 2).height - 6 * 2;

		RectF frame1 = new RectF(
			3,
			(area.height - 1) - 5 - h,
			(area.width - 1) - 3,
			(area.height - 1) - 6
		);
		RectF frame2 = new RectF(
			(area.width - 1) - 3 - h,
			6,
			(area.width - 1) - 3,
			(area.height - 1) - 6
		);
		RectF highlight1 = new RectF(frame1.left + 1, frame1.top + 1, frame1.right - 2, frame1.bottom - 2);
		RectF highlight2 = new RectF(frame2.left + 1, frame2.top + 1, frame2.right - 2, frame2.bottom - 2);
		RectF keytop1 = new RectF(highlight1.left + 1, highlight1.top + 1, highlight1.right, highlight1.bottom);
		RectF keytop2 = new RectF(highlight2.left + 1, highlight2.top + 1, highlight2.right, highlight2.bottom);
		RectF keytop_pressed1 = new RectF(frame1.left + 1, frame1.top + 1, frame1.right - 1, frame1.bottom - 1);
		RectF keytop_pressed2 = new RectF(frame2.left + 1, frame2.top + 1, frame2.right - 1, frame2.bottom - 1);
		float r = g800.getZoomX() * 2;

		frame1 = zoomRect(frame1, g800.getZoomX(), g800.getZoomY());
		frame2 = zoomRect(frame2, g800.getZoomX(), g800.getZoomY());
		highlight1 = zoomRect(highlight1, g800.getZoomX(), g800.getZoomY());
		highlight2 = zoomRect(highlight2, g800.getZoomX(), g800.getZoomY());
		keytop1 = zoomRect(keytop1, g800.getZoomX(), g800.getZoomY());
		keytop2 = zoomRect(keytop2, g800.getZoomX(), g800.getZoomY());
		keytop_pressed1 = zoomRect(keytop_pressed1, g800.getZoomX(), g800.getZoomY());
		keytop_pressed2 = zoomRect(keytop_pressed2, g800.getZoomX(), g800.getZoomY());

		/* キーの枠を描く */
		Bitmap bmp = Bitmap.createBitmap(area.width * g800.getZoomX(), area.height * g800.getZoomY(), Bitmap.Config.ARGB_4444);
		Canvas canvas = new Canvas(bmp);
		Paint paint = new Paint();
		int back_color = getColor(area.backColor);

		paint.setColor(Color.BLACK);
		canvas.drawRoundRect(frame1, r, r, paint);
		canvas.drawRoundRect(frame2, r, r, paint);

		if(key_status == BUTTONSTATUS_PRESSED) {
			/* 押されたキーの表面を描く */
			paint.setColor(back_color);
			canvas.drawRoundRect(keytop_pressed1, r, r, paint);
			canvas.drawRoundRect(keytop_pressed2, r, r, paint);
		} else {
			/* キーのハイライトを描く */
			paint.setColor(Color.GRAY);
			canvas.drawRoundRect(highlight1, r, r, paint);
			canvas.drawRoundRect(highlight2, r, r, paint);

			/* キーの表面を描く */
			paint.setColor(back_color);
			canvas.drawRoundRect(keytop1, r, r, paint);
			canvas.drawRoundRect(keytop2, r, r, paint);
		}

		/* 実際のキーのサイズに縮小する */
		area = g800.getLayout(index);
		return new BitmapDrawable(Bitmap.createScaledBitmap(bmp, area.width, area.height, true));
	}

	/*
		キーの背景画像を生成する
	*/
	private Drawable createButtonBackground(int index, int key_status)
	{
		/* 位置を得る */
		G800Emulator.Area area = g800.getLayout(index, 0, 0, 2, 2);
		if(area == null)
			return null;

		RectF frame = new RectF(3, 6, (area.width - 1) - 3, (area.height - 1) - 6);
		RectF highlight = new RectF(frame.left + 1, frame.top + 1, frame.right - 2, frame.bottom - 2);
		RectF keytop = new RectF(highlight.left + 1, highlight.top + 1, highlight.right, highlight.bottom);
		RectF keytop_pressed = new RectF(frame.left + 1, frame.top + 1, frame.right - 1, frame.bottom - 1);
		float r = g800.getZoomX() * 2;

		frame = zoomRect(frame, g800.getZoomX(), g800.getZoomY());
		highlight = zoomRect(highlight, g800.getZoomX(), g800.getZoomY());
		keytop = zoomRect(keytop, g800.getZoomX(), g800.getZoomY());
		keytop_pressed = zoomRect(keytop_pressed, g800.getZoomX(), g800.getZoomY());

		/* キーの枠を描く */
		Bitmap bmp = Bitmap.createBitmap(area.width * g800.getZoomX(), area.height * g800.getZoomY(), Bitmap.Config.ARGB_4444);
		Canvas canvas = new Canvas(bmp);
		Paint paint = new Paint();
		int back_color = getColor(area.backColor);
		int fore_color = getColor(area.foreColor);
		int text_base_y;

		paint.setColor(Color.BLACK);
		canvas.drawRoundRect(frame, r, r, paint);

		if(key_status == BUTTONSTATUS_PRESSED) {
			/* 押されたキーの表面を描く */
			paint.setColor(back_color);
			canvas.drawRoundRect(keytop_pressed, r, r, paint);

			/* 文字の位置を設定する */
			text_base_y = (int )keytop_pressed.bottom;
		} else {
			/* キーのハイライトを描く */
			if(area.backColor == G800Emulator.COLOR_RED)
				paint.setColor(Color.rgb(0xcc, 0x88, 0x88));
			else if(area.backColor == G800Emulator.COLOR_GREEN)
				paint.setColor(Color.rgb(0x88, 0xcc, 0x88));
			else if(area.backColor == G800Emulator.COLOR_YELLOW)
				paint.setColor(Color.rgb(0xee, 0xcc, 0x88));
			else
				paint.setColor(Color.GRAY);
			canvas.drawRoundRect(highlight, r, r, paint);

			/* キーの表面を描く */
			paint.setColor(back_color);
			canvas.drawRoundRect(keytop, r, r, paint);

			/* 文字の位置を設定する */
			text_base_y = (int )keytop.bottom;
		}

		/* キーの文字を描く */
		String text = area.text;
		float text_width, widths[] = new float[text.length()];
		int i, text_x, text_y;

		paint.setTextSize((keytop.bottom - keytop.top + 1) * 7 / 10);
		text_y = (int )(text_base_y - (keytop.bottom - keytop.top + 1 - paint.getTextSize()) / 2);

		paint.getTextWidths(text, widths);
		for(i = 0, text_width = 0.0f; i < widths.length; text_width += widths[i++])
			;
		if(keytop.right - keytop.left + 1 < text_width) {
			paint.setTextScaleX((keytop.right - keytop.left + 1) / text_width);
			text_x = (int )keytop.left;
		} else {
			text_x = (int )(keytop.left + (keytop.right - keytop.left + 1 - text_width) / 2);
		}

		paint.setColor(fore_color);
		canvas.drawText(text, text_x, text_y, paint);

		/* 実際のキーのサイズに縮小する */
		area = g800.getLayout(index);
		return new BitmapDrawable(Bitmap.createScaledBitmap(bmp, area.width, area.height, true));
	}

	/*
		2つの状態のボタンの背景画像を生成する
	*/
	private Drawable[] createReturnButtonBackground(int index)
	{
		return new Drawable[] {
			createReturnButtonBackground(index, BUTTONSTATUS_NORMAL),
			createReturnButtonBackground(index, BUTTONSTATUS_PRESSED)
		};
	}

	/*
		2つの状態のボタンの背景画像を生成する
	*/
	private Drawable[] createButtonBackground(int index)
	{
		if(index == G800Emulator.LAYOUT_KEY_RETURN)
			return createReturnButtonBackground(index);

		return new Drawable[] {
			createButtonBackground(index, BUTTONSTATUS_NORMAL),
			createButtonBackground(index, BUTTONSTATUS_PRESSED)
		};
	}

	/*
		文字を表示する
	*/
	private void drawLabelText(Canvas canvas, int index)
	{
		G800Emulator.Area area = g800.getLayout(index);
		if(area == null)
			return;

		String text = area.text;
		Bitmap bmp = Bitmap.createBitmap(area.width * 2, area.height * 2, Bitmap.Config.ARGB_4444);
		Canvas c = new Canvas(bmp);
		Paint paint = new Paint();
		float text_width, widths[] = new float[text.length()];
		int color = getColor(area.foreColor);
		int i, y;

		y = bmp.getHeight() - g800.getZoomY() * 2;

		paint.setTextSize(bmp.getHeight());
		widths = new float[text.length()];
		paint.getTextWidths(text, widths);
		for(i = 0, text_width = 0.0f; i < widths.length; text_width += widths[i++])
			;

		paint.setColor(color);
		if(bmp.getWidth() < text_width) {
			paint.setTextScaleX(bmp.getWidth() / text_width);
			c.drawText(text, 0, y, paint);
		} else {
			c.drawText(text, (bmp.getWidth() - text_width) / 2, y, paint);
		}

		canvas.drawBitmap(Bitmap.createScaledBitmap(bmp, area.width, area.height, true), area.x, area.y, null);
	}

	/*
		ボタンを生成する
	*/
	private ImageButton createButton(int index)
	{
		G800Emulator.Area area = g800.getLayout(index);
		ImageButton button = new ImageButton(this);

		if(area == null) {
			button.setVisibility(View.INVISIBLE);
			return button;
		}

		button.setMaxWidth(area.width);
		button.setMinimumWidth(area.width);
		button.setMaxHeight(area.height);
		button.setMinimumHeight(area.height);
		button.setOnTouchListener(this);
		if(buttonBackground[index] != null)
			button.setBackgroundDrawable(buttonBackground[index][BUTTONSTATUS_NORMAL]);
		button.setTag(index);
		button.setFocusable(false);
		return button;
	}

	/*
		RAMを永続化する
	*/
	private void saveRam()
	{
		try {
			int i;

			for(i = 0; i < 10; i++) {
				if(g800.isOff()) {
					/* 電源OFFならRAMを永続化する */
					FileOutputStream out = openFileOutput("ram.bin", MODE_PRIVATE);
					g800.writeRam(out);
					out.close();
					break;
				} else if(g800run == null || !g800run.isAlive()) {
					/* 実行スレッドが停止しているならリトライしない */
					break;
				}
				Thread.sleep(100);
			}
		} catch(Exception e) {
		}
	}

	/*
		ROMイメージファイル名を得る
	*/
	private String getRomFileName(int machine)
	{
		switch(machine) {
		case G800Emulator.MACHINE_E200:
			return "e200rom.bin";
		case G800Emulator.MACHINE_G815:
			return "g815rom.bin";
		default:
			return "g850rom.bin";
		}
	}

	/*
		ROMイメージファイル名を得る
	*/
	private String getRomFileName()
	{
		return getRomFileName(g800.getMachine());
	}

	/*
		アプリケーションを再起動する
	*/
	private void restart()
	{
		g800.keyPress(G800Emulator.GKEY_OFF);
		saveRam();
		g800run.stop();
		finish();
		startActivity(new Intent(MainActivity.this, MainActivity.class));
	}

	/*
		生成されたとき初期化する
	*/
	@Override protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		String param;
		int machine, cpu_clocks, fps, lcd_scales, i;

		preferences = getSharedPreferences("g800a", MODE_PRIVATE);

		/* IS01のときフルスクリーンモードを得る */
		if(preferences.getBoolean("is01_fullscreen", false)) {
			try {
				setFullScreenModeMethod = Class.forName("jp.co.sharp.android.softguide.SoftGuideManager").getMethod("setFullScreenMode", boolean.class);
			} catch(Exception e) {
				setFullScreenModeMethod = null;
			}
		}

		/* AndroidのキーコードとPC-G800のキーコードの対応を初期化する */
		aKey[KeyEvent.KEYCODE_0] = preferences.getInt("0", G800Emulator.GKEY_0);
		aKey[KeyEvent.KEYCODE_1] = preferences.getInt("1", G800Emulator.GKEY_1);
		aKey[KeyEvent.KEYCODE_2] = preferences.getInt("2", G800Emulator.GKEY_2);
		aKey[KeyEvent.KEYCODE_3] = preferences.getInt("3", G800Emulator.GKEY_3);
		aKey[KeyEvent.KEYCODE_4] = preferences.getInt("4", G800Emulator.GKEY_4);
		aKey[KeyEvent.KEYCODE_5] = preferences.getInt("5", G800Emulator.GKEY_5);
		aKey[KeyEvent.KEYCODE_6] = preferences.getInt("6", G800Emulator.GKEY_6);
		aKey[KeyEvent.KEYCODE_7] = preferences.getInt("7", G800Emulator.GKEY_7);
		aKey[KeyEvent.KEYCODE_8] = preferences.getInt("8", G800Emulator.GKEY_8);
		aKey[KeyEvent.KEYCODE_9] = preferences.getInt("9", G800Emulator.GKEY_9);
		aKey[KeyEvent.KEYCODE_A] = preferences.getInt("A", G800Emulator.GKEY_A);
		aKey[KeyEvent.KEYCODE_ALT_LEFT] = preferences.getInt("ALT_LEFT", G800Emulator.GKEY_KANA);
		aKey[KeyEvent.KEYCODE_ALT_RIGHT] = preferences.getInt("ALT_RIGHT", G800Emulator.GKEY_KANA);
		aKey[KeyEvent.KEYCODE_APOSTROPHE] = preferences.getInt("APOSTROPHE", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_AT] = preferences.getInt("AT", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_B] = preferences.getInt("B", G800Emulator.GKEY_B);
		aKey[KeyEvent.KEYCODE_BACK] = preferences.getInt("BACK", G800Emulator.GKEY_OFF);
		aKey[KeyEvent.KEYCODE_BACKSLASH] = preferences.getInt("BACKSLASH", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_C] = preferences.getInt("C", G800Emulator.GKEY_C);
		aKey[KeyEvent.KEYCODE_COMMA] = preferences.getInt("COMMA", G800Emulator.GKEY_COMMA);
		aKey[KeyEvent.KEYCODE_D] = preferences.getInt("D", G800Emulator.GKEY_D);
		aKey[KeyEvent.KEYCODE_DEL] = preferences.getInt("DEL", G800Emulator.GKEY_BACKSPACE);
		aKey[KeyEvent.KEYCODE_DPAD_CENTER] = preferences.getInt("DPAD_CENTER", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_DPAD_DOWN] = preferences.getInt("DPAD_DOWN", G800Emulator.GKEY_DOWN);
		aKey[KeyEvent.KEYCODE_DPAD_LEFT] = preferences.getInt("DPAD_LWDR", G800Emulator.GKEY_LEFT);
		aKey[KeyEvent.KEYCODE_DPAD_RIGHT] = preferences.getInt("DPAD_RIGHT", G800Emulator.GKEY_RIGHT);
		aKey[KeyEvent.KEYCODE_DPAD_UP] = preferences.getInt("DPAD_UP", G800Emulator.GKEY_UP);
		aKey[KeyEvent.KEYCODE_E] = preferences.getInt("E", G800Emulator.GKEY_E);
		aKey[KeyEvent.KEYCODE_ENTER] = preferences.getInt("ENTER", G800Emulator.GKEY_RETURN);
		aKey[KeyEvent.KEYCODE_EQUALS] = preferences.getInt("EQUALS", G800Emulator.GKEY_EQUAL);
		aKey[KeyEvent.KEYCODE_F] = preferences.getInt("F", G800Emulator.GKEY_F);
		aKey[KeyEvent.KEYCODE_G] = preferences.getInt("G", G800Emulator.GKEY_G);
		aKey[KeyEvent.KEYCODE_GRAVE] = preferences.getInt("GRAVE", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_H] = preferences.getInt("H", G800Emulator.GKEY_H);
		aKey[KeyEvent.KEYCODE_HOME] = preferences.getInt("HOME", G800Emulator.GKEY_CLS);
		aKey[KeyEvent.KEYCODE_I] = preferences.getInt("I", G800Emulator.GKEY_I);
		aKey[KeyEvent.KEYCODE_J] = preferences.getInt("J", G800Emulator.GKEY_J);
		aKey[KeyEvent.KEYCODE_K] = preferences.getInt("K", G800Emulator.GKEY_K);
		aKey[KeyEvent.KEYCODE_L] = preferences.getInt("L", G800Emulator.GKEY_L);
		aKey[KeyEvent.KEYCODE_LEFT_BRACKET] = preferences.getInt("LEFT_BRACKET", G800Emulator.GKEY_LKAKKO);
		aKey[KeyEvent.KEYCODE_M] = preferences.getInt("M", G800Emulator.GKEY_M);
		aKey[KeyEvent.KEYCODE_MINUS] = preferences.getInt("MINUS", G800Emulator.GKEY_MINUS);
		aKey[KeyEvent.KEYCODE_N] = preferences.getInt("N", G800Emulator.GKEY_N);
		aKey[KeyEvent.KEYCODE_O] = preferences.getInt("O", G800Emulator.GKEY_O);
		aKey[KeyEvent.KEYCODE_P] = preferences.getInt("P", G800Emulator.GKEY_P);
		aKey[KeyEvent.KEYCODE_PERIOD] = preferences.getInt("PERIOD", G800Emulator.GKEY_PERIOD);
		aKey[KeyEvent.KEYCODE_PLUS] = preferences.getInt("PLUS", G800Emulator.GKEY_PLUS);
		aKey[KeyEvent.KEYCODE_POUND] = preferences.getInt("POUND", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_POWER] = preferences.getInt("POWER", G800Emulator.GKEY_NONE);
		aKey[KeyEvent.KEYCODE_Q] = preferences.getInt("Q", G800Emulator.GKEY_Q);
		aKey[KeyEvent.KEYCODE_R] = preferences.getInt("R", G800Emulator.GKEY_R);
		aKey[KeyEvent.KEYCODE_RIGHT_BRACKET] = preferences.getInt("RIGHT_BRACKET", G800Emulator.GKEY_RKAKKO);
		aKey[KeyEvent.KEYCODE_S] = preferences.getInt("S", G800Emulator.GKEY_S);
		aKey[KeyEvent.KEYCODE_SEMICOLON] = preferences.getInt("SEMICOLON", G800Emulator.GKEY_SEMICOLON);
		aKey[KeyEvent.KEYCODE_SHIFT_LEFT] = preferences.getInt("SHIFT_LEFT", G800Emulator.GKEY_SHIFT);
		aKey[KeyEvent.KEYCODE_SHIFT_RIGHT] = preferences.getInt("SHIFT_RIGHT", G800Emulator.GKEY_SHIFT);
		aKey[KeyEvent.KEYCODE_SLASH] = preferences.getInt("SLASH", G800Emulator.GKEY_SLASH);
		aKey[KeyEvent.KEYCODE_SPACE] = preferences.getInt("SPACE", G800Emulator.GKEY_SPACE);
		aKey[KeyEvent.KEYCODE_STAR] = preferences.getInt("STAR", G800Emulator.GKEY_ASTER);
		aKey[KeyEvent.KEYCODE_T] = preferences.getInt("T", G800Emulator.GKEY_T);
		aKey[KeyEvent.KEYCODE_TAB] = preferences.getInt("TAB", G800Emulator.GKEY_TAB);
		aKey[KeyEvent.KEYCODE_U] = preferences.getInt("U", G800Emulator.GKEY_U);
		aKey[KeyEvent.KEYCODE_V] = preferences.getInt("V", G800Emulator.GKEY_V);
		aKey[KeyEvent.KEYCODE_W] = preferences.getInt("W", G800Emulator.GKEY_W);
		aKey[KeyEvent.KEYCODE_X] = preferences.getInt("X", G800Emulator.GKEY_X);
		aKey[KeyEvent.KEYCODE_Y] = preferences.getInt("Y", G800Emulator.GKEY_Y);
		aKey[KeyEvent.KEYCODE_Z] = preferences.getInt("Z", G800Emulator.GKEY_Z);

		/* ボタンとPC-G800のキーコードの対応を初期化する */
		lKey[G800Emulator.LAYOUT_KEY_OFF] = G800Emulator.GKEY_OFF;
		lKey[G800Emulator.LAYOUT_KEY_Q] = G800Emulator.GKEY_Q;
		lKey[G800Emulator.LAYOUT_KEY_W] = G800Emulator.GKEY_W;
		lKey[G800Emulator.LAYOUT_KEY_E] = G800Emulator.GKEY_E;
		lKey[G800Emulator.LAYOUT_KEY_R] = G800Emulator.GKEY_R;
		lKey[G800Emulator.LAYOUT_KEY_T] = G800Emulator.GKEY_T;
		lKey[G800Emulator.LAYOUT_KEY_Y] = G800Emulator.GKEY_Y;
		lKey[G800Emulator.LAYOUT_KEY_U] = G800Emulator.GKEY_U;
		lKey[G800Emulator.LAYOUT_KEY_A] = G800Emulator.GKEY_A;
		lKey[G800Emulator.LAYOUT_KEY_S] = G800Emulator.GKEY_S;
		lKey[G800Emulator.LAYOUT_KEY_D] = G800Emulator.GKEY_D;
		lKey[G800Emulator.LAYOUT_KEY_F] = G800Emulator.GKEY_F;
		lKey[G800Emulator.LAYOUT_KEY_G] = G800Emulator.GKEY_G;
		lKey[G800Emulator.LAYOUT_KEY_H] = G800Emulator.GKEY_H;
		lKey[G800Emulator.LAYOUT_KEY_J] = G800Emulator.GKEY_J;
		lKey[G800Emulator.LAYOUT_KEY_K] = G800Emulator.GKEY_K;
		lKey[G800Emulator.LAYOUT_KEY_Z] = G800Emulator.GKEY_Z;
		lKey[G800Emulator.LAYOUT_KEY_X] = G800Emulator.GKEY_X;
		lKey[G800Emulator.LAYOUT_KEY_C] = G800Emulator.GKEY_C;
		lKey[G800Emulator.LAYOUT_KEY_V] = G800Emulator.GKEY_V;
		lKey[G800Emulator.LAYOUT_KEY_B] = G800Emulator.GKEY_B;
		lKey[G800Emulator.LAYOUT_KEY_N] = G800Emulator.GKEY_N;
		lKey[G800Emulator.LAYOUT_KEY_M] = G800Emulator.GKEY_M;
		lKey[G800Emulator.LAYOUT_KEY_COMMA] = G800Emulator.GKEY_COMMA;
		lKey[G800Emulator.LAYOUT_KEY_BASIC] = G800Emulator.GKEY_BASIC;
		lKey[G800Emulator.LAYOUT_KEY_TEXT] = G800Emulator.GKEY_TEXT;
		lKey[G800Emulator.LAYOUT_KEY_CAPS] = G800Emulator.GKEY_CAPS;
		lKey[G800Emulator.LAYOUT_KEY_KANA] = G800Emulator.GKEY_KANA;
		lKey[G800Emulator.LAYOUT_KEY_TAB] = G800Emulator.GKEY_TAB;
		lKey[G800Emulator.LAYOUT_KEY_SPACE] = G800Emulator.GKEY_SPACE;
		lKey[G800Emulator.LAYOUT_KEY_DOWN] = G800Emulator.GKEY_DOWN;
		lKey[G800Emulator.LAYOUT_KEY_UP] = G800Emulator.GKEY_UP;
		lKey[G800Emulator.LAYOUT_KEY_LEFT] = G800Emulator.GKEY_LEFT;
		lKey[G800Emulator.LAYOUT_KEY_RIGHT] = G800Emulator.GKEY_RIGHT;
		lKey[G800Emulator.LAYOUT_KEY_ANS] = G800Emulator.GKEY_ANS;
		lKey[G800Emulator.LAYOUT_KEY_0] = G800Emulator.GKEY_0;
		lKey[G800Emulator.LAYOUT_KEY_PERIOD] = G800Emulator.GKEY_PERIOD;
		lKey[G800Emulator.LAYOUT_KEY_EQUAL] = G800Emulator.GKEY_EQUAL;
		lKey[G800Emulator.LAYOUT_KEY_PLUS] = G800Emulator.GKEY_PLUS;
		lKey[G800Emulator.LAYOUT_KEY_RETURN] = G800Emulator.GKEY_RETURN;
		lKey[G800Emulator.LAYOUT_KEY_L] = G800Emulator.GKEY_L;
		lKey[G800Emulator.LAYOUT_KEY_SEMICOLON] = G800Emulator.GKEY_SEMICOLON;
		lKey[G800Emulator.LAYOUT_KEY_CONST] = G800Emulator.GKEY_CONST;
		lKey[G800Emulator.LAYOUT_KEY_1] = G800Emulator.GKEY_1;
		lKey[G800Emulator.LAYOUT_KEY_2] = G800Emulator.GKEY_2;
		lKey[G800Emulator.LAYOUT_KEY_3] = G800Emulator.GKEY_3;
		lKey[G800Emulator.LAYOUT_KEY_MINUS] = G800Emulator.GKEY_MINUS;
		lKey[G800Emulator.LAYOUT_KEY_MPLUS] = G800Emulator.GKEY_MPLUS;
		lKey[G800Emulator.LAYOUT_KEY_I] = G800Emulator.GKEY_I;
		lKey[G800Emulator.LAYOUT_KEY_O] = G800Emulator.GKEY_O;
		lKey[G800Emulator.LAYOUT_KEY_INSERT] = G800Emulator.GKEY_INSERT;
		lKey[G800Emulator.LAYOUT_KEY_4] = G800Emulator.GKEY_4;
		lKey[G800Emulator.LAYOUT_KEY_5] = G800Emulator.GKEY_5;
		lKey[G800Emulator.LAYOUT_KEY_6] = G800Emulator.GKEY_6;
		lKey[G800Emulator.LAYOUT_KEY_ASTER] = G800Emulator.GKEY_ASTER;
		lKey[G800Emulator.LAYOUT_KEY_RCM] = G800Emulator.GKEY_RCM;
		lKey[G800Emulator.LAYOUT_KEY_P] = G800Emulator.GKEY_P;
		lKey[G800Emulator.LAYOUT_KEY_BACKSPACE] = G800Emulator.GKEY_BACKSPACE;
		lKey[G800Emulator.LAYOUT_KEY_PI] = G800Emulator.GKEY_PI;
		lKey[G800Emulator.LAYOUT_KEY_7] = G800Emulator.GKEY_7;
		lKey[G800Emulator.LAYOUT_KEY_8] = G800Emulator.GKEY_8;
		lKey[G800Emulator.LAYOUT_KEY_9] = G800Emulator.GKEY_9;
		lKey[G800Emulator.LAYOUT_KEY_SLASH] = G800Emulator.GKEY_SLASH;
		lKey[G800Emulator.LAYOUT_KEY_RKAKKO] = G800Emulator.GKEY_RKAKKO;
		lKey[G800Emulator.LAYOUT_KEY_NPR] = G800Emulator.GKEY_NPR;
		lKey[G800Emulator.LAYOUT_KEY_DEG] = G800Emulator.GKEY_DEG;
		lKey[G800Emulator.LAYOUT_KEY_SQR] = G800Emulator.GKEY_SQR;
		lKey[G800Emulator.LAYOUT_KEY_SQU] = G800Emulator.GKEY_SQU;
		lKey[G800Emulator.LAYOUT_KEY_HAT] = G800Emulator.GKEY_HAT;
		lKey[G800Emulator.LAYOUT_KEY_LKAKKO] = G800Emulator.GKEY_LKAKKO;
		lKey[G800Emulator.LAYOUT_KEY_RCP] = G800Emulator.GKEY_RCP;
		lKey[G800Emulator.LAYOUT_KEY_MDF] = G800Emulator.GKEY_MDF;
		lKey[G800Emulator.LAYOUT_KEY_2NDF] = G800Emulator.GKEY_2NDF;
		lKey[G800Emulator.LAYOUT_KEY_SIN] = G800Emulator.GKEY_SIN;
		lKey[G800Emulator.LAYOUT_KEY_COS] = G800Emulator.GKEY_COS;
		lKey[G800Emulator.LAYOUT_KEY_LN] = G800Emulator.GKEY_LN;
		lKey[G800Emulator.LAYOUT_KEY_LOG] = G800Emulator.GKEY_LOG;
		lKey[G800Emulator.LAYOUT_KEY_TAN] = G800Emulator.GKEY_TAN;
		lKey[G800Emulator.LAYOUT_KEY_FE] = G800Emulator.GKEY_FE;
		lKey[G800Emulator.LAYOUT_KEY_CLS] = G800Emulator.GKEY_CLS;
		lKey[G800Emulator.LAYOUT_KEY_BREAK] = G800Emulator.GKEY_BREAK;
		lKey[G800Emulator.LAYOUT_KEY_RETURN2] = G800Emulator.GKEY_RETURN;
		lKey[G800Emulator.LAYOUT_KEY_SHIFT] = G800Emulator.GKEY_SHIFT;

		/* エミュレートの対象機種を得る */
		param = preferences.getString("MACHINE", "g850");
		if(param.equalsIgnoreCase("e200")) {
			machine = G800Emulator.MACHINE_E200;
			cpu_clocks = 4000 * 1000;
		} else if(param.equalsIgnoreCase("g815")) {
			machine = G800Emulator.MACHINE_G815;
			cpu_clocks = 4000 * 1000;
		} else {
			machine = G800Emulator.MACHINE_G850;
			cpu_clocks = 8000 * 1000;
		}

		/* CPUのクロック周波数を得る */
		cpu_clocks = preferences.getInt("CPUCLOCKS", cpu_clocks);

		/* 更新周期を得る */
		fps = preferences.getInt("FPS", 60);
		interval = (1000 + fps / 2) / fps;
		fps = (1000 + interval / 2) / interval;

		/* LCD階調数を得る */
		lcd_scales = preferences.getInt("LCDSCALES", 2);

		/* エミュレータを初期化する */
		g800 = new G800Emulator(machine, cpu_clocks, fps, lcd_scales);

		/* LCDの色を初期化する */
		lcdColor = new Paint[g800.getLcdScales()];
		for(i = 0; i < lcdColor.length; i++) {
			int red   = 0xaa + (0x00 - 0xaa) / (lcdColor.length - 1) * i;
			int green = 0xdd + (0x22 - 0xdd) / (lcdColor.length - 1) * i;
			int blue  = 0xbb + (0x11 - 0xbb) / (lcdColor.length - 1) * i;

			lcdColor[i] = new Paint();
			lcdColor[i].setColor(Color.rgb(red, green, blue));
		}
		lcdBackColor = new Paint();
		lcdBackColor.setColor(Color.rgb(0xcc, 0xee, 0xbb));

		/* ROMイメージを読み込む */
		try {
			FileInputStream in = openFileInput(getRomFileName());
			g800.readRom(in);
			in.close();
		} catch(IOException e1) {
			/* 何もしない */
		} catch(Exception e) {
			Toast.makeText(MainActivity.this, "" + e, Toast.LENGTH_LONG).show();
		}

		/* RAMを読み込む */
		FileInputStream in;
		try {
			in = openFileInput("ram.bin");
			g800.readRam(in);
			in.close();
		} catch(FileNotFoundException e) {
			saveRam();
		} catch(Exception e) {
			Toast.makeText(MainActivity.this, "" + e, Toast.LENGTH_LONG).show();
		}

		/* ブートする */
		g800.boot();

		/* 表示を開始する */
		mainLayout = new RelativeLayout(this);
		setContentView(mainLayout);
	}

	/*
		最初にフォーカスを得たとき初期化する
	*/
	@Override public void onWindowFocusChanged(boolean hasFocus)
	{
		super.onWindowFocusChanged(hasFocus);
		if(g800run != null)
			return;

		G800Emulator.Area area, round;
		int width, zoom_x, zoom_y, z;

		/* 拡大率を求める */
		width = (g800.getLayout(G800Emulator.LAYOUT_BODY).width) * 95 / 100;
		zoom_x = zoom_y = mainLayout.getWidth() / width;

		/* PC-E200またはPC-G815のとき横に伸ばす(可能なら) */
		if(g800.getMachine() == G800Emulator.MACHINE_E200 || g800.getMachine() == G800Emulator.MACHINE_G815) {
			z = zoom_x * 6 / 5;
			if(z == zoom_x)
				;
			else if(width * z <= mainLayout.getWidth())
				zoom_x = z;
			else {
				z = (zoom_x - 1) * 6 / 5;
				if(z != (zoom_x - 1)) {
					zoom_x = z;
					zoom_y--;
				}
			}
		}

		/* 本体を描く */
		g800.setZoom(zoom_x, zoom_y);
		g800.setOffset(
		(mainLayout.getWidth() - g800.getLayout(G800Emulator.LAYOUT_BODY).width) / 2,
		(mainLayout.getHeight() - g800.getLayout(G800Emulator.LAYOUT_BODY).height) / 2
		);
		Bitmap bmp = Bitmap.createBitmap(mainLayout.getWidth(), mainLayout.getHeight(), Bitmap.Config.RGB_565);
		Paint paint = new Paint();
		Canvas canvas = new Canvas(bmp);

		if(g800.getMachine() == G800Emulator.MACHINE_G850)
			paint.setColor(Color.rgb(0x22, 0x22, 0x22));
		else
			paint.setColor(Color.rgb(0x33, 0x33, 0x33));
		area = g800.getLayout(G800Emulator.LAYOUT_BODY);
		round = g800.getLayout(G800Emulator.LAYOUT_KEY_A);
		canvas.drawRoundRect(new RectF(area.x, area.y, area.x + area.width - 1, area.y + area.height - 1), round.width / 2, round.height / 2, paint);

		/* キーの上の文字を表示する */
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BREAK);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_CONTRAST);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_C);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_ASMBL);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_CA);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DIGIT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_ATAN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_ACOS);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_ASIN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_STAT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_FACT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_TEN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_EXP);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DMS);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_NCR);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BASEN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_XY);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_POL);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_CUB);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_CUR);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RND);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_SECOND);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_MINUTE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DEGREE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_MMINUS);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_PNP2);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_NEG);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_E);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DRG);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_AT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_GREATER);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LESS);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_APOSTROPHE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_AMPERSAND);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_PERCENT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DOLLAR);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_HASH);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DQUARTATION);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_EXCLAMATION);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_PNP);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COLON);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_EQUAL);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_UNDERBAR);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_TILDE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_PIPE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_YEN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RBRACE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LBRACE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RBRACKET);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LBRACKET);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_KOMOZI);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_QUESTION);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LOAD);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_SAVE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LIST);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RUN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_CONT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_PRINT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_INPUT);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_DELETE);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_CHOON);

		/* キーの右下の文字を表示する */
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RKAGIKAKKO);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LKAGIKAKKO);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_NAKATEN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_KUTEN);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_TOUTEN);

		/* LCDの枠を表示する */
		area = g800.getLayout(G800Emulator.LAYOUT_FRAME);
		paint.setColor(Color.BLACK);
		if(g800.getMachine() == G800Emulator.MACHINE_G850)
			canvas.drawRect(area.x, area.y, area.x + round.width - 1, area.y + area.height - 1, paint);
		canvas.drawRoundRect(new RectF(area.x, area.y, area.x + area.width - 1, area.y + area.height - 1), round.width / 6, round.height / 6, paint);

		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL0);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL1);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL2);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL3);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL4);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL5);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL6);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL7);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL8);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL9);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL10);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL11);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL12);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL13);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL14);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL15);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL16);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL17);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL18);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL19);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL20);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL21);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL22);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_COL23);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RROW0);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RROW1);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RROW2);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RROW3);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RROW4);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_RROW5);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LROW0);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LROW1);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LROW2);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LROW3);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LROW4);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LROW5);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BOTTOM_COL0);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BOTTOM_COL5);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BOTTOM_COL10);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BOTTOM_COL15);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_BOTTOM_COL20);
		drawLabelText(canvas, G800Emulator.LAYOUT_LABEL_LOGO1);

		/* 背景に設定する */
		mainLayout.setBackgroundDrawable(new BitmapDrawable(bmp));
		canvas = null;

		/* LCDのレイアウトを得る */
		g800.setOffset((mainLayout.getWidth() - g800.getLayout(G800Emulator.LAYOUT_BODY).width) / 2, (mainLayout.getHeight() - g800.getLayout(G800Emulator.LAYOUT_BODY).height) / 2);
		lcdRect = getMargins(G800Emulator.LAYOUT_LCD);
		lcdMatrixRect = getMargins(G800Emulator.LAYOUT_LCD_MATRIX);

		/* キーの背景画像を生成する */
		buttonBackground = new Drawable[G800Emulator.LAYOUT_KEY_LAST + 1][];
		buttonBackground[G800Emulator.LAYOUT_KEY_OFF] = createButtonBackground(G800Emulator.LAYOUT_KEY_OFF);
		buttonBackground[G800Emulator.LAYOUT_KEY_Q] = createButtonBackground(G800Emulator.LAYOUT_KEY_Q);
		buttonBackground[G800Emulator.LAYOUT_KEY_W] = createButtonBackground(G800Emulator.LAYOUT_KEY_W);
		buttonBackground[G800Emulator.LAYOUT_KEY_E] = createButtonBackground(G800Emulator.LAYOUT_KEY_E);
		buttonBackground[G800Emulator.LAYOUT_KEY_R] = createButtonBackground(G800Emulator.LAYOUT_KEY_R);
		buttonBackground[G800Emulator.LAYOUT_KEY_T] = createButtonBackground(G800Emulator.LAYOUT_KEY_T);
		buttonBackground[G800Emulator.LAYOUT_KEY_Y] = createButtonBackground(G800Emulator.LAYOUT_KEY_Y);
		buttonBackground[G800Emulator.LAYOUT_KEY_U] = createButtonBackground(G800Emulator.LAYOUT_KEY_U);
		buttonBackground[G800Emulator.LAYOUT_KEY_A] = createButtonBackground(G800Emulator.LAYOUT_KEY_A);
		buttonBackground[G800Emulator.LAYOUT_KEY_S] = createButtonBackground(G800Emulator.LAYOUT_KEY_S);
		buttonBackground[G800Emulator.LAYOUT_KEY_D] = createButtonBackground(G800Emulator.LAYOUT_KEY_D);
		buttonBackground[G800Emulator.LAYOUT_KEY_F] = createButtonBackground(G800Emulator.LAYOUT_KEY_F);
		buttonBackground[G800Emulator.LAYOUT_KEY_G] = createButtonBackground(G800Emulator.LAYOUT_KEY_G);
		buttonBackground[G800Emulator.LAYOUT_KEY_H] = createButtonBackground(G800Emulator.LAYOUT_KEY_H);
		buttonBackground[G800Emulator.LAYOUT_KEY_J] = createButtonBackground(G800Emulator.LAYOUT_KEY_J);
		buttonBackground[G800Emulator.LAYOUT_KEY_K] = createButtonBackground(G800Emulator.LAYOUT_KEY_K);
		buttonBackground[G800Emulator.LAYOUT_KEY_Z] = createButtonBackground(G800Emulator.LAYOUT_KEY_Z);
		buttonBackground[G800Emulator.LAYOUT_KEY_X] = createButtonBackground(G800Emulator.LAYOUT_KEY_X);
		buttonBackground[G800Emulator.LAYOUT_KEY_C] = createButtonBackground(G800Emulator.LAYOUT_KEY_C);
		buttonBackground[G800Emulator.LAYOUT_KEY_V] = createButtonBackground(G800Emulator.LAYOUT_KEY_V);
		buttonBackground[G800Emulator.LAYOUT_KEY_B] = createButtonBackground(G800Emulator.LAYOUT_KEY_B);
		buttonBackground[G800Emulator.LAYOUT_KEY_N] = createButtonBackground(G800Emulator.LAYOUT_KEY_N);
		buttonBackground[G800Emulator.LAYOUT_KEY_M] = createButtonBackground(G800Emulator.LAYOUT_KEY_M);
		buttonBackground[G800Emulator.LAYOUT_KEY_COMMA] = createButtonBackground(G800Emulator.LAYOUT_KEY_COMMA);
		buttonBackground[G800Emulator.LAYOUT_KEY_BASIC] = createButtonBackground(G800Emulator.LAYOUT_KEY_BASIC);
		buttonBackground[G800Emulator.LAYOUT_KEY_TEXT] = createButtonBackground(G800Emulator.LAYOUT_KEY_TEXT);
		buttonBackground[G800Emulator.LAYOUT_KEY_CAPS] = createButtonBackground(G800Emulator.LAYOUT_KEY_CAPS);
		buttonBackground[G800Emulator.LAYOUT_KEY_KANA] = createButtonBackground(G800Emulator.LAYOUT_KEY_KANA);
		buttonBackground[G800Emulator.LAYOUT_KEY_TAB] = createButtonBackground(G800Emulator.LAYOUT_KEY_TAB);
		buttonBackground[G800Emulator.LAYOUT_KEY_SPACE] = createButtonBackground(G800Emulator.LAYOUT_KEY_SPACE);
		buttonBackground[G800Emulator.LAYOUT_KEY_DOWN] = createButtonBackground(G800Emulator.LAYOUT_KEY_DOWN);
		buttonBackground[G800Emulator.LAYOUT_KEY_UP] = createButtonBackground(G800Emulator.LAYOUT_KEY_UP);
		buttonBackground[G800Emulator.LAYOUT_KEY_LEFT] = createButtonBackground(G800Emulator.LAYOUT_KEY_LEFT);
		buttonBackground[G800Emulator.LAYOUT_KEY_RIGHT] = createButtonBackground(G800Emulator.LAYOUT_KEY_RIGHT);
		buttonBackground[G800Emulator.LAYOUT_KEY_ANS] = createButtonBackground(G800Emulator.LAYOUT_KEY_ANS);
		buttonBackground[G800Emulator.LAYOUT_KEY_0] = createButtonBackground(G800Emulator.LAYOUT_KEY_0);
		buttonBackground[G800Emulator.LAYOUT_KEY_PERIOD] = createButtonBackground(G800Emulator.LAYOUT_KEY_PERIOD);
		buttonBackground[G800Emulator.LAYOUT_KEY_EQUAL] = createButtonBackground(G800Emulator.LAYOUT_KEY_EQUAL);
		buttonBackground[G800Emulator.LAYOUT_KEY_PLUS] = createButtonBackground(G800Emulator.LAYOUT_KEY_PLUS);
		buttonBackground[G800Emulator.LAYOUT_KEY_RETURN] = createButtonBackground(G800Emulator.LAYOUT_KEY_RETURN);
		buttonBackground[G800Emulator.LAYOUT_KEY_RETURN2] = createButtonBackground(G800Emulator.LAYOUT_KEY_RETURN2);
		buttonBackground[G800Emulator.LAYOUT_KEY_L] = createButtonBackground(G800Emulator.LAYOUT_KEY_L);
		buttonBackground[G800Emulator.LAYOUT_KEY_SEMICOLON] = createButtonBackground(G800Emulator.LAYOUT_KEY_SEMICOLON);
		buttonBackground[G800Emulator.LAYOUT_KEY_CONST] = createButtonBackground(G800Emulator.LAYOUT_KEY_CONST);
		buttonBackground[G800Emulator.LAYOUT_KEY_1] = createButtonBackground(G800Emulator.LAYOUT_KEY_1);
		buttonBackground[G800Emulator.LAYOUT_KEY_2] = createButtonBackground(G800Emulator.LAYOUT_KEY_2);
		buttonBackground[G800Emulator.LAYOUT_KEY_3] = createButtonBackground(G800Emulator.LAYOUT_KEY_3);
		buttonBackground[G800Emulator.LAYOUT_KEY_MINUS] = createButtonBackground(G800Emulator.LAYOUT_KEY_MINUS);
		buttonBackground[G800Emulator.LAYOUT_KEY_MPLUS] = createButtonBackground(G800Emulator.LAYOUT_KEY_MPLUS);
		buttonBackground[G800Emulator.LAYOUT_KEY_I] = createButtonBackground(G800Emulator.LAYOUT_KEY_I);
		buttonBackground[G800Emulator.LAYOUT_KEY_O] = createButtonBackground(G800Emulator.LAYOUT_KEY_O);
		buttonBackground[G800Emulator.LAYOUT_KEY_INSERT] = createButtonBackground(G800Emulator.LAYOUT_KEY_INSERT);
		buttonBackground[G800Emulator.LAYOUT_KEY_4] = createButtonBackground(G800Emulator.LAYOUT_KEY_4);
		buttonBackground[G800Emulator.LAYOUT_KEY_5] = createButtonBackground(G800Emulator.LAYOUT_KEY_5);
		buttonBackground[G800Emulator.LAYOUT_KEY_6] = createButtonBackground(G800Emulator.LAYOUT_KEY_6);
		buttonBackground[G800Emulator.LAYOUT_KEY_ASTER] = createButtonBackground(G800Emulator.LAYOUT_KEY_ASTER);
		buttonBackground[G800Emulator.LAYOUT_KEY_RCM] = createButtonBackground(G800Emulator.LAYOUT_KEY_RCM);
		buttonBackground[G800Emulator.LAYOUT_KEY_P] = createButtonBackground(G800Emulator.LAYOUT_KEY_P);
		buttonBackground[G800Emulator.LAYOUT_KEY_BACKSPACE] = createButtonBackground(G800Emulator.LAYOUT_KEY_BACKSPACE);
		buttonBackground[G800Emulator.LAYOUT_KEY_PI] = createButtonBackground(G800Emulator.LAYOUT_KEY_PI);
		buttonBackground[G800Emulator.LAYOUT_KEY_7] = createButtonBackground(G800Emulator.LAYOUT_KEY_7);
		buttonBackground[G800Emulator.LAYOUT_KEY_8] = createButtonBackground(G800Emulator.LAYOUT_KEY_8);
		buttonBackground[G800Emulator.LAYOUT_KEY_9] = createButtonBackground(G800Emulator.LAYOUT_KEY_9);
		buttonBackground[G800Emulator.LAYOUT_KEY_SLASH] = createButtonBackground(G800Emulator.LAYOUT_KEY_SLASH);
		buttonBackground[G800Emulator.LAYOUT_KEY_RKAKKO] = createButtonBackground(G800Emulator.LAYOUT_KEY_RKAKKO);
		buttonBackground[G800Emulator.LAYOUT_KEY_NPR] = createButtonBackground(G800Emulator.LAYOUT_KEY_NPR);
		buttonBackground[G800Emulator.LAYOUT_KEY_DEG] = createButtonBackground(G800Emulator.LAYOUT_KEY_DEG);
		buttonBackground[G800Emulator.LAYOUT_KEY_SQR] = createButtonBackground(G800Emulator.LAYOUT_KEY_SQR);
		buttonBackground[G800Emulator.LAYOUT_KEY_SQU] = createButtonBackground(G800Emulator.LAYOUT_KEY_SQU);
		buttonBackground[G800Emulator.LAYOUT_KEY_HAT] = createButtonBackground(G800Emulator.LAYOUT_KEY_HAT);
		buttonBackground[G800Emulator.LAYOUT_KEY_LKAKKO] = createButtonBackground(G800Emulator.LAYOUT_KEY_LKAKKO);
		buttonBackground[G800Emulator.LAYOUT_KEY_RCP] = createButtonBackground(G800Emulator.LAYOUT_KEY_RCP);
		buttonBackground[G800Emulator.LAYOUT_KEY_MDF] = createButtonBackground(G800Emulator.LAYOUT_KEY_MDF);
		buttonBackground[G800Emulator.LAYOUT_KEY_2NDF] = createButtonBackground(G800Emulator.LAYOUT_KEY_2NDF);
		buttonBackground[G800Emulator.LAYOUT_KEY_SIN] = createButtonBackground(G800Emulator.LAYOUT_KEY_SIN);
		buttonBackground[G800Emulator.LAYOUT_KEY_COS] = createButtonBackground(G800Emulator.LAYOUT_KEY_COS);
		buttonBackground[G800Emulator.LAYOUT_KEY_LN] = createButtonBackground(G800Emulator.LAYOUT_KEY_LN);
		buttonBackground[G800Emulator.LAYOUT_KEY_LOG] = createButtonBackground(G800Emulator.LAYOUT_KEY_LOG);
		buttonBackground[G800Emulator.LAYOUT_KEY_TAN] = createButtonBackground(G800Emulator.LAYOUT_KEY_TAN);
		buttonBackground[G800Emulator.LAYOUT_KEY_FE] = createButtonBackground(G800Emulator.LAYOUT_KEY_FE);
		buttonBackground[G800Emulator.LAYOUT_KEY_CLS] = createButtonBackground(G800Emulator.LAYOUT_KEY_CLS);
		buttonBackground[G800Emulator.LAYOUT_KEY_BREAK] = createButtonBackground(G800Emulator.LAYOUT_KEY_BREAK);
		buttonBackground[G800Emulator.LAYOUT_KEY_SHIFT] = createButtonBackground(G800Emulator.LAYOUT_KEY_SHIFT);

		/* 表示を開始する */
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_BREAK), createLayoutParams(G800Emulator.LAYOUT_KEY_BREAK));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_OFF), createLayoutParams(G800Emulator.LAYOUT_KEY_OFF));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_ANS), createLayoutParams(G800Emulator.LAYOUT_KEY_ANS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_CONST), createLayoutParams(G800Emulator.LAYOUT_KEY_CONST));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_TEXT), createLayoutParams(G800Emulator.LAYOUT_KEY_TEXT));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_BASIC), createLayoutParams(G800Emulator.LAYOUT_KEY_BASIC));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_CLS), createLayoutParams(G800Emulator.LAYOUT_KEY_CLS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_FE), createLayoutParams(G800Emulator.LAYOUT_KEY_FE));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_TAN), createLayoutParams(G800Emulator.LAYOUT_KEY_TAN));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_COS), createLayoutParams(G800Emulator.LAYOUT_KEY_COS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SIN), createLayoutParams(G800Emulator.LAYOUT_KEY_SIN));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_2NDF), createLayoutParams(G800Emulator.LAYOUT_KEY_2NDF));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_MDF), createLayoutParams(G800Emulator.LAYOUT_KEY_MDF));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_RCP), createLayoutParams(G800Emulator.LAYOUT_KEY_RCP));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_LOG), createLayoutParams(G800Emulator.LAYOUT_KEY_LOG));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_LN), createLayoutParams(G800Emulator.LAYOUT_KEY_LN));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_DEG), createLayoutParams(G800Emulator.LAYOUT_KEY_DEG));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_NPR), createLayoutParams(G800Emulator.LAYOUT_KEY_NPR));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_RKAKKO), createLayoutParams(G800Emulator.LAYOUT_KEY_RKAKKO));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_LKAKKO), createLayoutParams(G800Emulator.LAYOUT_KEY_LKAKKO));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_HAT), createLayoutParams(G800Emulator.LAYOUT_KEY_HAT));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SQU), createLayoutParams(G800Emulator.LAYOUT_KEY_SQU));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SQR), createLayoutParams(G800Emulator.LAYOUT_KEY_SQR));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_PI), createLayoutParams(G800Emulator.LAYOUT_KEY_PI));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_RCM), createLayoutParams(G800Emulator.LAYOUT_KEY_RCM));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SLASH), createLayoutParams(G800Emulator.LAYOUT_KEY_SLASH));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_9), createLayoutParams(G800Emulator.LAYOUT_KEY_9));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_8), createLayoutParams(G800Emulator.LAYOUT_KEY_8));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_7), createLayoutParams(G800Emulator.LAYOUT_KEY_7));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_MPLUS), createLayoutParams(G800Emulator.LAYOUT_KEY_MPLUS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_ASTER), createLayoutParams(G800Emulator.LAYOUT_KEY_ASTER));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_6), createLayoutParams(G800Emulator.LAYOUT_KEY_6));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_5), createLayoutParams(G800Emulator.LAYOUT_KEY_5));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_4), createLayoutParams(G800Emulator.LAYOUT_KEY_4));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_RETURN2), createLayoutParams(G800Emulator.LAYOUT_KEY_RETURN2));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_MINUS), createLayoutParams(G800Emulator.LAYOUT_KEY_MINUS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_3), createLayoutParams(G800Emulator.LAYOUT_KEY_3));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_2), createLayoutParams(G800Emulator.LAYOUT_KEY_2));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_1), createLayoutParams(G800Emulator.LAYOUT_KEY_1));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_PLUS), createLayoutParams(G800Emulator.LAYOUT_KEY_PLUS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_EQUAL), createLayoutParams(G800Emulator.LAYOUT_KEY_EQUAL));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_PERIOD), createLayoutParams(G800Emulator.LAYOUT_KEY_PERIOD));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_0), createLayoutParams(G800Emulator.LAYOUT_KEY_0));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_BACKSPACE), createLayoutParams(G800Emulator.LAYOUT_KEY_BACKSPACE));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_P), createLayoutParams(G800Emulator.LAYOUT_KEY_P));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_O), createLayoutParams(G800Emulator.LAYOUT_KEY_O));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_I), createLayoutParams(G800Emulator.LAYOUT_KEY_I));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_U), createLayoutParams(G800Emulator.LAYOUT_KEY_U));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_Y), createLayoutParams(G800Emulator.LAYOUT_KEY_Y));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_T), createLayoutParams(G800Emulator.LAYOUT_KEY_T));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_R), createLayoutParams(G800Emulator.LAYOUT_KEY_R));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_E), createLayoutParams(G800Emulator.LAYOUT_KEY_E));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_W), createLayoutParams(G800Emulator.LAYOUT_KEY_W));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_Q), createLayoutParams(G800Emulator.LAYOUT_KEY_Q));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_TAB), createLayoutParams(G800Emulator.LAYOUT_KEY_TAB));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_RETURN), createLayoutParams(G800Emulator.LAYOUT_KEY_RETURN));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SEMICOLON), createLayoutParams(G800Emulator.LAYOUT_KEY_SEMICOLON));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_L), createLayoutParams(G800Emulator.LAYOUT_KEY_L));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_K), createLayoutParams(G800Emulator.LAYOUT_KEY_K));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_J), createLayoutParams(G800Emulator.LAYOUT_KEY_J));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_H), createLayoutParams(G800Emulator.LAYOUT_KEY_H));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_G), createLayoutParams(G800Emulator.LAYOUT_KEY_G));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_F), createLayoutParams(G800Emulator.LAYOUT_KEY_F));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_D), createLayoutParams(G800Emulator.LAYOUT_KEY_D));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_S), createLayoutParams(G800Emulator.LAYOUT_KEY_S));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_A), createLayoutParams(G800Emulator.LAYOUT_KEY_A));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_CAPS), createLayoutParams(G800Emulator.LAYOUT_KEY_CAPS));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_UP), createLayoutParams(G800Emulator.LAYOUT_KEY_UP));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_COMMA), createLayoutParams(G800Emulator.LAYOUT_KEY_COMMA));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_M), createLayoutParams(G800Emulator.LAYOUT_KEY_M));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_N), createLayoutParams(G800Emulator.LAYOUT_KEY_N));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_B), createLayoutParams(G800Emulator.LAYOUT_KEY_B));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_V), createLayoutParams(G800Emulator.LAYOUT_KEY_V));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_C), createLayoutParams(G800Emulator.LAYOUT_KEY_C));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_X), createLayoutParams(G800Emulator.LAYOUT_KEY_X));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_Z), createLayoutParams(G800Emulator.LAYOUT_KEY_Z));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SHIFT), createLayoutParams(G800Emulator.LAYOUT_KEY_SHIFT));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_RIGHT), createLayoutParams(G800Emulator.LAYOUT_KEY_RIGHT));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_DOWN), createLayoutParams(G800Emulator.LAYOUT_KEY_DOWN));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_LEFT), createLayoutParams(G800Emulator.LAYOUT_KEY_LEFT));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_INSERT), createLayoutParams(G800Emulator.LAYOUT_KEY_INSERT));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_SPACE), createLayoutParams(G800Emulator.LAYOUT_KEY_SPACE));
		mainLayout.addView(createButton(G800Emulator.LAYOUT_KEY_KANA), createLayoutParams(G800Emulator.LAYOUT_KEY_KANA));
		g800run = new G800Run(this);
		mainLayout.addView(g800run, createLayoutParams(G800Emulator.LAYOUT_LCD));
	}

	/*
		(再)表示された
	*/
	@Override public void onResume()
	{
		super.onResume();

		if(setFullScreenModeMethod != null) {
			try {
				setFullScreenModeMethod.invoke(null, true);
			} catch (Exception e) {
			}
		}
	}

	/*
		キーを押した
	*/
	@Override public boolean onKeyDown(int key_code, KeyEvent e)
	{
		g800.keyPress(aKey[key_code]);

		if(key_code == KeyEvent.KEYCODE_BACK) {
			saveRam();
			g800run.stop();
		}
		return super.onKeyDown(key_code, e);
	}

	/*
		キーを離した
	*/
	@Override public boolean onKeyUp(int key_code, KeyEvent e)
	{
		g800.keyRelease(aKey[key_code]);

		return super.onKeyUp(key_code, e);
	}

	/*
		ボタンを押した・離した
	*/
	@SuppressLint("ClickableViewAccessibility")
	@Override public boolean onTouch(View button, MotionEvent e) {
		int index = (Integer )button.getTag();
		int gkey = lKey[index];

		switch(e.getAction()) {
		case MotionEvent.ACTION_DOWN:
			((ImageButton )button).setBackgroundDrawable(buttonBackground[index][BUTTONSTATUS_PRESSED]);
			g800.keyPress(gkey);
			break;
		case MotionEvent.ACTION_MOVE:
			if(0 <= e.getX() && e.getX() <= button.getRight() - button.getLeft() && 0 <= e.getY() && e.getY() <= button.getBottom() - button.getTop())
				break;
			button.setEnabled(false);
			button.setEnabled(true);
		case MotionEvent.ACTION_UP:
			((ImageButton )button).setBackgroundDrawable(buttonBackground[index][BUTTONSTATUS_NORMAL]);
			g800.keyRelease(gkey);
			break;
		}
		return false;
	}

	/*
		メニューから実行: SIO 入出力なし
	*/
	private void sioStop()
	{
		g800.setSioMode(G800Emulator.SIO_MODE_STOP);
	}

	/*
		メニューから実行: SIO ファイルから入力
	*/
	private void sioIn()
	{
		new FileDialog.Builder(this)
		.setListener(new OnFileSelectedListener()
		{
			@Override public void onFileSelected(String dir_name, String file_name)
			{
				try {
					g800.setSioInfile(dir_name + file_name);
					g800.setSioMode(G800Emulator.SIO_MODE_IN);
				} catch(Exception e) {
					Toast.makeText(MainActivity.this, "" + e, Toast.LENGTH_LONG).show();
				}
			}
		}
		)
		.create()
		.show();
	}

	/*
		メニューから実行: SIO ファイルへ出力
	*/
	private void sioOut()
	{
		new FileDialog.Builder(this)
		.existNewFile(true)
		.setListener(new OnFileSelectedListener()
		{
			@Override public void onFileSelected(String dir_name, String file_name)
			{
				g800.setSioOutfile(dir_name + file_name);
				g800.setSioMode(G800Emulator.SIO_MODE_OUT);
			}
		}
		)
		.create()
		.show();
	}

	/*
		メニューから実行: 直接メモリにロードする
	*/
	private void directLoad()
	{
		new FileDialog.Builder(this)
		.setListener(new OnFileSelectedListener()
		{
			@Override public void onFileSelected(String dir_name, String file_name)
			{
				final String path_name = dir_name + file_name;

				synchronized(g800) {
					/* プログラムを読み込む */
					try {
						if(g800.getRom(0) == null)
							g800.setMode(G800Emulator.MODE_MENU);

						HexFile.readFile(g800.getRam(), path_name);
						Toast.makeText(MainActivity.this, String.format("INFO:%04X-%04X", HexFile.offset(), HexFile.offset() + HexFile.length() - 1), Toast.LENGTH_LONG).show();

						if(g800.getRom(0) == null)
							go();
					} catch(DataFormatException e) {
						Toast.makeText(MainActivity.this, R.string.wrong_hex_file, Toast.LENGTH_LONG).show();
						return;
					} catch(IOException e) {
						Toast.makeText(MainActivity.this, R.string.cannot_open, Toast.LENGTH_LONG).show();
						return;
					} catch(Exception e) {
						Toast.makeText(MainActivity.this, "" + e, Toast.LENGTH_LONG).show();
						return;
					}
				}
			}
		}
		)
		.create()
		.show();
	}

	/*
		メニューから実行: 実行する
	*/
	private void go()
	{
		final EditText editText = new EditText(MainActivity.this);
		editText.setText("100");
		editText.setInputType(InputType.TYPE_CLASS_TEXT);
		editText.setOnFocusChangeListener(new OnFocusChangeListener()
		{
			@Override public void onFocusChange(View v, boolean hasFocus)
			{
				if(hasFocus) {
					MainActivity.this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
					editText.selectAll();
				}
			}
		});
		editText.setOnKeyListener(new OnKeyListener()
		{
			@Override public boolean onKey(View v, int key_code, KeyEvent event)
			{
				if(key_code != KeyEvent.KEYCODE_ENTER)
					return false;
				return true;
			}
		});

		new AlertDialog.Builder(MainActivity.this)
		.setTitle(R.string.address)
		.setView(editText)
		.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener()
		{
			@Override public void onClick(DialogInterface dialog, int which)
			{
				int address;

				MainActivity.this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

				try {
					address = Integer.parseInt(editText.getText().toString(), 16) & 0xffff;
				} catch(Exception e) {
					Toast.makeText(MainActivity.this, "Wrong address", Toast.LENGTH_LONG).show();
					return;
				}

				g800.boot();
				g800.af.set(0x0044);
				g800.bc.set(0x0000);
				g800.de.set(0x0000);
				g800.hl.set(0x0100);
				g800.ix.set(0x7c05);
				g800.iy.set(0x7c03);
				g800.pc = address;
				g800.setMode(G800Emulator.MODE_EMULATOR);
			}
		})
		.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener()
		{
			@Override public void onClick(DialogInterface dialog, int which)
			{
				MainActivity.this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
			}
		})
		.setOnCancelListener(new OnCancelListener()
		{
			@Override public void onCancel(DialogInterface dialog)
			{
				MainActivity.this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
			}
		})
		.create()
		.show();
	}

	/*
		メニューから実行: リセットする
	*/
	void reset()
	{
		synchronized(g800) {
			if(g800.getRom(0) == null)
				Arrays.fill(g800.getRam(), 0x0000, 0x7fff, (byte )0x00);
			g800.boot();
		}
	}

	/*
		メニューから実行: ROMイメージを取り込む
	*/
	private void importRom()
	{
		new FileDialog.Builder(this)
		.setListener(new OnFileSelectedListener()
		{
			@Override public void onFileSelected(String dir_name, String file_name)
			{
				try {
					synchronized(g800) {
						if(g800.loadHexFileIntoRom(dir_name) > 0) {
							FileOutputStream out = openFileOutput(getRomFileName(), MODE_PRIVATE);
							g800.writeRom(out);
							out.close();
						}
						g800.boot();
					}
				} catch(FileNotFoundException e2) {
					Toast.makeText(MainActivity.this, R.string.rom_file_not_found, Toast.LENGTH_LONG).show();
				} catch(DataFormatException e2) {
					Toast.makeText(MainActivity.this, R.string.wrong_hex_file, Toast.LENGTH_LONG).show();
				} catch(IOException e) {
					Toast.makeText(MainActivity.this, R.string.cannot_open, Toast.LENGTH_LONG).show();
				} catch(Exception e2) {
					Toast.makeText(MainActivity.this, "" + e2, Toast.LENGTH_LONG).show();
				}
			}
		}
		).create()
		.show();
	}

	/*
		メニューから実行: 右側のメニューを消す/表示する
	*/
	void setRightMenu(boolean fullscreen)
	{
		SharedPreferences.Editor editor = preferences.edit();
		editor.putBoolean("is01_fullscreen", fullscreen);
		editor.commit();
		restart();
	}

	/*
		メニューから実行: 機種を設定する
	*/
	void setMachine(String machine)
	{
		SharedPreferences.Editor editor = preferences.edit();
		editor.putString("MACHINE", machine);
		editor.commit();
		restart();
	}

	/*
		メニューを作成する
	*/
	@Override public boolean onCreateOptionsMenu(Menu menu)
	{
		menu.add(Menu.NONE, MENU_DIRECT_LOAD, Menu.NONE, R.string.menu_direct_load);

		menu.add(Menu.NONE, MENU_GO, Menu.NONE, R.string.menu_go);

		SubMenu sio = menu.addSubMenu(Menu.NONE, MENU_SIO, Menu.NONE, R.string.menu_sio);
		sio.add(MENU_SIO, MENU_SIO_STOP, Menu.NONE, R.string.menu_sio_stop);
		sio.add(MENU_SIO, MENU_SIO_IN, Menu.NONE, R.string.menu_sio_in);
		sio.add(MENU_SIO, MENU_SIO_OUT, Menu.NONE, R.string.menu_sio_out);
		sio.setGroupCheckable(MENU_SIO, true, true);

		SubMenu machine = menu.addSubMenu(Menu.NONE, MENU_MACHINE, Menu.NONE, R.string.menu_machine);
		machine.add(MENU_MACHINE, MENU_MACHINE_E200, Menu.NONE, R.string.menu_machine_e200);
		machine.add(MENU_MACHINE, MENU_MACHINE_G815, Menu.NONE, R.string.menu_machine_g815);
		machine.add(MENU_MACHINE, MENU_MACHINE_G850, Menu.NONE, R.string.menu_machine_g850);
		machine.setGroupCheckable(MENU_MACHINE, true, true);

		SubMenu settings = menu.addSubMenu(Menu.NONE, MENU_SETTINGS, Menu.NONE, R.string.menu_settings);
		settings.add(MENU_SETTINGS, MENU_IMPORT_ROM, Menu.NONE, "");
		settings.add(MENU_SETTINGS, MENU_HIDE_RIGHTMENU, Menu.NONE, "");

		/*menu.add(Menu.NONE, MENU_CLOCKS, Menu.NONE, R.string.menu_clocks);*/

		menu.add(Menu.NONE, MENU_RESET, Menu.NONE, R.string.menu_reset);
		return super.onCreateOptionsMenu(menu);
	}

	/*
		メニューが表示される直前
	*/
	@Override public boolean onPrepareOptionsMenu(Menu menu)
	{
		menu.findItem(MENU_GO).setVisible(g800.getRom(0) == null);
		menu.findItem(MENU_SIO).setVisible(g800.getRom(0) != null);

		switch(g800.getSioMode()) {
		case G800Emulator.SIO_MODE_STOP:
			menu.findItem(MENU_SIO_STOP).setChecked(true);
			break;
		case G800Emulator.SIO_MODE_IN:
			menu.findItem(MENU_SIO_IN).setChecked(true);
			break;
		case G800Emulator.SIO_MODE_OUT:
			menu.findItem(MENU_SIO_OUT).setChecked(true);
			break;
		}
		menu.findItem(MENU_SIO_IN).setTitle(getString(R.string.menu_sio_in) + " [" + g800.getSioInfile() + "]");
		menu.findItem(MENU_SIO_OUT).setTitle(getString(R.string.menu_sio_out) + " [" + g800.getSioOutfile() + "]");

		switch(g800.getMachine()) {
		case G800Emulator.MACHINE_E200:
			menu.findItem(MENU_IMPORT_ROM).setTitle(R.string.menu_import_e200_rom);
			menu.findItem(MENU_MACHINE_E200).setChecked(true);
			break;
		case G800Emulator.MACHINE_G815:
			menu.findItem(MENU_IMPORT_ROM).setTitle(R.string.menu_import_g815_rom);
			menu.findItem(MENU_MACHINE_G815).setChecked(true);
			break;
		default:
			menu.findItem(MENU_IMPORT_ROM).setTitle(R.string.menu_import_g850_rom);
			menu.findItem(MENU_MACHINE_G850).setChecked(true);
			break;
		}

		if(setFullScreenModeMethod == null)
			menu.findItem(MENU_HIDE_RIGHTMENU).setTitle(R.string.menu_hide_rightside_menu);
		else
			menu.findItem(MENU_HIDE_RIGHTMENU).setTitle(R.string.menu_show_rightside_menu);

		return super.onPrepareOptionsMenu(menu);
	}

	/*
		メニューが選択された
	*/
	@Override public boolean onOptionsItemSelected(MenuItem item)
	{
		switch(item.getItemId()) {
		case MENU_SIO_STOP:
			sioStop();
			return true;
		case MENU_SIO_IN:
			sioIn();
			return true;
		case MENU_SIO_OUT:
			sioOut();
			return true;
		case MENU_DIRECT_LOAD:
			directLoad();
			return true;
		case MENU_GO:
			go();
			return true;
		case MENU_RESET:
			reset();
			return true;
		case MENU_IMPORT_ROM:
			importRom();
			return true;
		case MENU_HIDE_RIGHTMENU:
			setRightMenu(setFullScreenModeMethod == null);
			return true;
		case MENU_CLOCKS:
			Toast.makeText(MainActivity.this, "" + (totalStates * 1000.0f / (System.currentTimeMillis() - startTime) / 1000000.0f) + "MHz", Toast.LENGTH_LONG).show();
			return true;
		case MENU_MACHINE_E200:
			setMachine("e200");
			return true;
		case MENU_MACHINE_G815:
			setMachine("g815");
			return true;
		case MENU_MACHINE_G850:
			setMachine("g850");
			return true;
		case MENU_QUIT:
			finish();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}
}

/*
	Copyright 2013~2015 maruhiro
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