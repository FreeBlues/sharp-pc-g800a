package jp.gr.java_conf.ver0.tool;

import java.io.File;
import java.util.Arrays;
import java.util.Locale;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.DialogInterface.OnClickListener;
import android.content.SharedPreferences;
import android.os.Environment;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnKeyListener;
import android.view.WindowManager;
import android.widget.EditText;

/*
	ファイル選択ダイアログ
*/
public class FileDialog implements OnClickListener
{
	/*
		静的初期化子
	*/
	static
	{
		if(Locale.JAPAN.equals(Locale.getDefault())) {
			NEW_FILE = "<新しいファイルを作成>";
			NEW_FILE_NAME = "新しいファイル名";
			CANCEL = "キャンセル";
		} else {
			NEW_FILE = "<Create new file>";
			NEW_FILE_NAME = "New file name";
			CANCEL = "Cancel";
		}
	}
	
	/*
		ビルダークラス
	*/
	public static class Builder
	{
		/* ファイル選択ダイアログ */
		private FileDialog fileDialog;
		
		/* コンテキスト */
		private Context context;
		
		/* ファイル選択リスナー */
		private OnFileSelectedListener listener;
		
		/* 現在のディレクトリ */
		private String dirName;
		
		/* 新しいファイルを選択できるか? */
		private boolean existNewFile;

		/*
			コンストラクタ
		*/
		public Builder(Context context)
		{
			this.context = context;
		}
		
		/*
			リスナーを設定する
		*/
		public Builder setListener(OnFileSelectedListener listener)
		{
			this.listener = listener;
			return this;
		}
			
		/*
			初期ディレクトリを設定する
		*/
		public Builder setDirectory(String dirName)
		{
			if(dirName.endsWith("/"))
				this.dirName = dirName;
			else
				this.dirName = dirName + "/";
			return this;
		}

		/*
			新しいファイルを選択できるか?
		*/
		public Builder existNewFile(boolean exist_new_file)
		{
			this.existNewFile = exist_new_file;
			return this;
		}

		/*
			ダイアログを生成する
		*/
		public FileDialog create()
		{
			if(dirName == null)
				setDirectory(context.getSharedPreferences("jp.gr.java_conf.ver0.tool.FileDialog", 0).getString("dir_name", Environment.getExternalStorageDirectory().getAbsolutePath()));
			
			fileDialog = new FileDialog();
			fileDialog.context = context;
			fileDialog.listener = listener;
			fileDialog.dirName = dirName;
			fileDialog.existNewFile = existNewFile;
			return fileDialog;
		}
	}

	/*
		ファイル名比較クラス
	*/
	private class FileNameComparator implements java.util.Comparator<String>
	{
		@Override public int compare(String x, String y)
		{
			if(x.equals(UP_DIR))
				return -1;
			if(y.equals(UP_DIR))
				return 1;
			if(x.endsWith("/") && !y.endsWith("/"))
				return -1;
			if(!x.endsWith("/") && y.endsWith("/"))
				return 1;
			if(x == NEW_FILE && y != NEW_FILE)
				return -1;
			if(x != NEW_FILE && y == NEW_FILE)
				return 1;
			return x.compareToIgnoreCase(y);
		}
	}

	/* 「1つ上のディレクトリ」 */
	static private final String UP_DIR = "../";
	
	/* 「新しいファイルを作成する」 */
	static private String NEW_FILE;
	
	/* 「新しいファイル名」 */
	static private String NEW_FILE_NAME;
	
	/* OKボタンの文字 */
	static private final String OK = "OK";
	
	/* キャンセルボタンの文字 */
	static private String CANCEL;

	/* コンテキスト */
	private Context context;
	
	/* ファイル選択リスナー */
	private OnFileSelectedListener listener;

	/* 新しいファイル名の入力ボックス */
	private EditText editText;
	
	/* 現在のディレクトリ */
	private String dirName;
	
	/* ファイル・ディレクトリ一覧 */
	private String fileName[];

	/* 新しいファイルを選択できるか? */
	private boolean existNewFile;

	/*
		ファイルが選択された
	*/
	@Override public void onClick(DialogInterface dialog, int which)
	{
		if(fileName[which].endsWith("/")) {
			if(fileName[which].equals(UP_DIR)) {
				/* 上のディレクトリの名前を得る */
				int i;
				
				for(i = dirName.length() - 2; i > 0 && dirName.charAt(i) != '/'; i--)
					;
				if(i >= 0)
					dirName = dirName.substring(0, i);
			} else {
				/* 選択したディレクトリの名前を得る */
				dirName = dirName + fileName[which];
			}
			
			/* 新しいダイアログを開く */
			final FileDialog file_dialog = new FileDialog.Builder(context)
			.setListener(listener)
			.setDirectory(dirName)
			.existNewFile(existNewFile)
			.create();
			file_dialog.show();
		} else {
			SharedPreferences.Editor editor = context.getSharedPreferences("jp.gr.java_conf.ver0.tool.FileDialog", 0).edit();
			editor.putString("dir_name", dirName);
			editor.commit();

			if(fileName[which] != NEW_FILE) {
				/* ファイルを選択した */
				listener.onFileSelected(dirName, fileName[which]);
			} else {
				/* 新しいファイルを選択した */
				editText = new EditText(context);
				editText.setText("noname.txt");
				editText.setInputType(InputType.TYPE_CLASS_TEXT);
				editText.setOnFocusChangeListener(new OnFocusChangeListener()
				{
					@Override public void onFocusChange(View v, boolean hasFocus)
					{
						if(hasFocus) {
							((Activity )context).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
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

				final AlertDialog edit_dialog = new AlertDialog.Builder(context)
				.setTitle(NEW_FILE_NAME)
				.setView(editText)
				.setNegativeButton(CANCEL, new DialogInterface.OnClickListener()
				{
					@Override public void onClick(DialogInterface dialog, int which)
					{
						((Activity )context).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
					}
				})
				.setPositiveButton(OK, new DialogInterface.OnClickListener()
				{
					@Override public void onClick(DialogInterface dialog, int which)
					{
						((Activity )context).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
						listener.onFileSelected(dirName, editText.getText().toString());
					}
				})
				.setOnCancelListener(new OnCancelListener() {
					@Override public void onCancel(DialogInterface dialog)
					{
						((Activity )context).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
					}
				})
				.create();
				edit_dialog.show();
			}
		}
	}

	/*
		ダイアログを開く
	*/
	public void show()
	{
		AlertDialog dialog;
		int length, index = 0, i;

		/* ファイル・ディレクトリ一覧を得る */
		try {
			File file[] = new File(dirName).listFiles();
			
			length = file.length;
			if(!dirName.equals("/"))
				length++;
			if(existNewFile)
				length++;
			fileName = new String[length];

			if(!dirName.equals("/"))
				fileName[index++] = UP_DIR;
			if(existNewFile)
				fileName[index++] = NEW_FILE;
			for(i = 0; i < file.length; i++) {
				if(file[i].isDirectory())
					fileName[index++] = file[i].getName() + "/";
				else
					fileName[index++] = file[i].getName();
			}
			Arrays.sort(fileName, new FileNameComparator());
		} catch(Exception e) {
			fileName = new String[1];
			fileName[0] = UP_DIR;
		}

		/* ファイル・ディレクトリ一覧を表示する */
		dialog = new AlertDialog.Builder(context)
		.setTitle(dirName)
		.setItems(fileName, this)
		.create();
		dialog.show();
	}
}

/*
	Copyright 2013 maruhiro
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