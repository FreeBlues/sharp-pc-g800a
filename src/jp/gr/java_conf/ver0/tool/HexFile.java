package jp.gr.java_conf.ver0.tool;

import java.io.*;
import java.net.*;
import java.util.zip.*;

/*
	Intel HEX ファイル読み込み
*/
public class HexFile
{
	/* 読み込んだファイルの先頭のアドレス */
	static private int topAddress;

	/* 読み込んだファイルの末尾のアドレス */
	static private int bottomAddress;

	/*
		1行読み込む (下請け)
	*/
	static private int decode(byte[] buf, String line, int start, boolean check) throws Exception
	{
		int len, off_l, off_h, off, sum, val, r, w;

		try {
			/* レコード先頭文字をチェックする */
			if(!line.substring(0, 1).equals(":"))
				throw new DataFormatException();

			/* データ長を得る */
			sum = len = Integer.parseInt(line.substring(1, 3), 16);
			if(len == 0)
				return 0;

			/* オフセットアドレスを得る */
			off_h = Integer.parseInt(line.substring(3, 5), 16);
			sum += off_h;
			off_l = Integer.parseInt(line.substring(5, 7), 16);
			sum += off_l;
			off = (off_h << 8) | off_l;

			/* レコードタイプを得る */
			switch(Integer.parseInt(line.substring(7, 9), 16)) {
			case 0x00: /* データレコード */
				break;
			case 0x01: /* エンドレコード */
				return 0;
			default: /* その他(未対応) */
				throw new DataFormatException();
			}

			/* データを得る */
			for(w = start + off, r = 9; w < start + off + len; w++, r += 2) {
				val = Integer.parseInt(line.substring(r, r + 2), 16);
				sum += val;

				if(buf != null)
					buf[w] = (byte )val;
			}

			/* サムをチェックする */
			sum = (~sum + 1) & 0xff;
			if(check && sum != Integer.parseInt(line.substring(r, r + 2), 16))
				throw new DataFormatException();

			/* データ長を戻す */
			if(topAddress > off)
				topAddress = off;
			if(bottomAddress < off + len)
				bottomAddress = off + len;
			return len;
		} catch(StringIndexOutOfBoundsException e) {
			throw new DataFormatException();
		} catch(Exception e) {
			throw e;
		}
	}

	/*
		IntelHexファイルを読み込む (下請け)
	*/
	static public int read(byte[] buf, Reader in, int start, boolean check) throws Exception
	{
		BufferedReader reader = null;
		String line;
		int l, len = 0;

		bottomAddress = 0;
		topAddress = 0xffff;

		try {
			reader = new BufferedReader(in);

			while((line = reader.readLine()) != null) {
				if((l = decode(buf, line, start, check)) == 0)
					break;
				len += l;
			}
			return len;
		} finally {
			if(topAddress > bottomAddress)
				topAddress = bottomAddress;
		}
	}

	/*
		IntelHexファイルを読み込む (下請け)
	*/
	static public int read(byte[] buf, InputStream in, int start, boolean check) throws Exception
	{
		return read(buf, new InputStreamReader(in), start, check);
	}

	/*
		IntelHexファイルを読み込んだ後ストリームを閉じる (下請け)
	*/
	static public int readAndClose(byte[] buf, Reader in, int start, boolean check) throws Exception
	{
		try {
			return read(buf, in, start, check);
		} finally {
			if(in != null)
				in.close();
		}
	}

	/*
		IntelHexファイルを読み込んだ後ストリームを閉じる (下請け)
	*/
	static public int readAndClose(byte[] buf, InputStream in, int start, boolean check) throws Exception
	{
		return readAndClose(buf, new InputStreamReader(in), start, check);
	}

	/*
		パス名を指定してIntelHexファイルを読み込む
	*/
	static public int readFile(byte[] buf, String pathname, int offset, boolean check) throws Exception
	{
		return readAndClose(buf, new FileReader(pathname), offset,check);
	}

	/*
		パス名を指定してIntelHexファイルを読み込む
	*/
	static public int readFile(byte[] buf, String pathname) throws Exception
	{
		return readFile(buf, pathname, 0, false);
	}

	/*
		パス名を指定してIntelHexファイルを読み込む (アドレス指定)
	*/
	static public int readFileAbs(byte[] buf, String pathname, int start) throws Exception
	{
		readFile(null, pathname, 0, false);
		return readFile(buf, pathname, start - topAddress, false);
	}

	/*
		URLを指定してIntelHexファイルを読み込む
	*/
	static public int readURL(byte[] buf, String url, int offset, boolean check) throws Exception
	{
		return readAndClose(buf, new InputStreamReader((new URL(url)).openStream()), offset, check);
	}

	/*
		URLを指定してIntelHexファイルを読み込む
	*/
	static public int readURL(byte[] buf, String url) throws Exception
	{
		return readURL(buf, url, 0, false);
	}

	/*
		URLを指定してIntelHexファイルを読み込む (アドレス指定)
	*/
	static public int readURLAbs(byte[] buf, String url, int start) throws Exception
	{
		readURL(null, url, 0, false);
		return readURL(buf, url, start - topAddress, false);
	}

	/*
		パス名を指定してZip圧縮されたIntelHexファイルを読み込む
	*/
	static public int readZipFile(byte[] buf, String zipname, String entryname, int offset, boolean check) throws Exception
	{
		File file;
		ZipFile zip = null;
		ZipEntry entry;

		try {
			file = new File(zipname);
			zip = new ZipFile(file, ZipFile.OPEN_READ);
			if((entry = zip.getEntry(entryname)) == null)
				throw new FileNotFoundException(zipname + ": " + entryname);
			return readAndClose(buf, new InputStreamReader(zip.getInputStream(entry)), offset, check);
		} finally {
			if(zip != null)
				zip.close();
		}
	}

	/*
		パス名を指定してZip圧縮されたIntelHexファイルを読み込む
	*/
	static public int readZipFile(byte buf[], String zipname, String entryname) throws Exception
	{
		return readZipFile(buf, zipname, entryname, 0, false);
	}

	/*
		パス名を指定してZip圧縮されたIntelHexファイルを読み込む (アドレス指定)
	*/
	static public int readZipFileAbs(byte buf[], String zipname, String entryname, int start) throws Exception
	{
		readZipFile(null, zipname, entryname, 0, false);
		return readZipFile(null, zipname, entryname, start - topAddress, false);
	}

	/*
		URLを指定してZip圧縮されたIntelHexファイルを読み込む
	*/
	static public int readZipURL(byte[] buf, String url, String entryname, int offset, boolean check) throws Exception
	{
		ZipInputStream zip = null;
		ZipEntry entry;

		try {
			zip = new ZipInputStream((new URL(url)).openConnection().getInputStream());

			while((entry = zip.getNextEntry()) != null)
				if(entry.getName().equals(entryname))
					return readAndClose(buf, new InputStreamReader(zip), offset, check);
			throw new FileNotFoundException(url + ": " + entryname);
		} finally {
			if(zip != null)
				zip.close();
		}
	}

	/*
		Zip圧縮されたIntelHexファイルを読み込む (URL)
	*/
	static public int readZipURL(byte[] buf, String url, String entryname) throws Exception
	{
		return readZipURL(buf, url, entryname, 0, false);
	}

	/*
		Zip圧縮されたIntelHexファイルを読み込む (URL) (アドレス指定)
	*/
	static public int readZipURLAbs(byte[] buf, String url, String entryname, int start) throws Exception
	{
		readZipURL(null, url, entryname, 0, false);
		return readZipURL(null, url, entryname, start - topAddress, false);
	}

	/*
		読み込んだファイルのオフセットアドレス
	*/
	static public int offset()
	{
		return topAddress;
	}

	/*
		読み込んだファイルのサイズ
	*/
	static public int length()
	{
		return bottomAddress - topAddress;
	}
}

/*
	Copyright 2011~2013 maruhiro
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
