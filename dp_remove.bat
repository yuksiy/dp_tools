@echo off

rem ==============================================================================
rem   機能
rem     ボリュームからドライブ文字またはマウントポイントパスを削除する
rem   構文
rem     dp_remove.bat letter VOLUME LETTER
rem     dp_remove.bat mount VOLUME MOUNT
rem
rem   Copyright (c) 2004-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * 基本設定
rem **********************************************************************
rem 環境変数のローカライズ開始
setlocal

rem 遅延環境変数展開の有効化
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem ウィンドウタイトルの設定
title %~nx0 %*

for /f "tokens=1" %%i in ('echo %~f0') do set SCRIPT_FULL_NAME=%%i
for /f "tokens=1" %%i in ('echo %~dp0') do set SCRIPT_ROOT=%%i
for /f "tokens=1" %%i in ('echo %~nx0') do set SCRIPT_NAME=%%i
set RAND=%RANDOM%

rem **********************************************************************
rem * 変数定義
rem **********************************************************************
rem ユーザ変数

rem システム環境 依存変数

rem プログラム内部変数
rem set DEBUG=TRUE
set TMP_DIR=%TEMP%
set SCRIPT_TMP_DIR=%TMP_DIR%\%SCRIPT_NAME%.%RAND%
set SCRIPT_FILE=%SCRIPT_TMP_DIR%\diskpart_script.tmp

set DP_LIST=%SCRIPT_ROOT%\dp_list.bat

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
if "%~1"=="" (
	echo -E Missing 1st argument 1>&2
	call :USAGE & exit /b 1
) else (
	set oprtype=%~1
	if "!oprtype!"=="letter" (
		rem 何もしない
	) else if "!oprtype!"=="mount" (
		rem 何もしない
	) else (
		echo -E Invalid 1st argument -- "!oprtype!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem 第2引数のチェック
if "%~2"=="" (
	echo -E Missing VOLUME argument 1>&2
	call :USAGE & exit /b 1
) else (
	set VOLUME=%~2
	rem ボリューム引数のチェック
	rem →dp_select.batを作ってcallする？
)

rem 第3引数のチェック
if "%~3"=="" (
	if "%oprtype%"=="letter" (
		echo -E Missing LETTER argument 1>&2
	) else if "%oprtype%"=="mount" (
		echo -E Missing MOUNT argument 1>&2
	)
	call :USAGE & exit /b 1
) else (
	rem oprtype=letter の場合
	if "%oprtype%"=="letter" (
		set LETTER=%~3
		rem ドライブ文字のチェック
		echo !LETTER!| findstr /r "^[ABCDEFGHIJKLMNOPQRSTUVWXYZ]$" > nul 2>&1
		if errorlevel 1 (
			echo -E Invalid LETTER argument -- "!LETTER!" 1>&2
			call :USAGE & exit /b 1
		)
	rem oprtype=mount の場合
	) else if "%oprtype%"=="mount" (
		set MOUNT=%~3
		rem 指定されたディレクトリのチェック
		if not exist !MOUNT!\nul (
			echo -E MOUNT not a directory -- "!MOUNT!" 1>&2
			call :USAGE & exit /b 1
		)
	)
)

rem 作業開始前処理
call :PRE_PROCESS

rem 作業用 DiskPart スクリプトの生成
if "%oprtype%"=="letter" (
	call :REMOVE_LETTER "%VOLUME%" "%LETTER%" > "%SCRIPT_FILE%"
) else if "%oprtype%"=="mount" (
	call :REMOVE_MOUNT "%VOLUME%" "%MOUNT%" > "%SCRIPT_FILE%"
)

rem 処理開始メッセージの表示
echo.
if "%oprtype%"=="letter" (
	echo -I Drive-letter removal has started.
) else if "%oprtype%"=="mount" (
	echo -I Mount-point-path removal has started.
)

rem *********************
rem * メインループ 開始 *
rem *********************

if "%DEBUG%"=="TRUE" (
	type "%SCRIPT_FILE%"
	echo.
)
diskpart /s "%SCRIPT_FILE%"

rem *********************
rem * メインループ 終了 *
rem *********************

rem 処理終了メッセージの表示
if errorlevel 1 (
	echo.
	if "%oprtype%"=="letter" (
		echo -E Drive-letter removal has ended unsuccessfully. 1>&2
	) else if "%oprtype%"=="mount" (
		echo -E Mount-point-path removal has ended unsuccessfully. 1>&2
	)
	call :POST_PROCESS & exit /b 1
) else (
	echo.
	if "%oprtype%"=="letter" (
		echo -I Drive-letter removal has ended successfully.
	) else if "%oprtype%"=="mount" (
		echo -I Mount-point-path removal has ended successfully.
	)
	rem 作業終了後処理
	call :POST_PROCESS & exit /b 0
)
goto :EOF


rem **********************************************************************
rem * サブルーチン定義
rem **********************************************************************
:PRE_PROCESS
	rem 一時ディレクトリの作成
	mkdir "%SCRIPT_TMP_DIR%"
goto :EOF

:POST_PROCESS
	rem 一時ディレクトリの削除
	if not "%DEBUG%"=="TRUE" (
		del /f /q "%SCRIPT_TMP_DIR%"
		for /d %%d in ("%SCRIPT_TMP_DIR%") do rmdir /s /q "%%d"
	)
goto :EOF

:USAGE
	echo Usage: dp_remove.bat letter VOLUME LETTER 1>&2
	echo        dp_remove.bat mount VOLUME MOUNT   1>&2
goto :EOF

rem ドライブ文字の割り当て
:REMOVE_LETTER
	echo select volume %~1
	echo remove letter="%~2"
goto :EOF

rem マウントポイントパスの割り当て
:REMOVE_MOUNT
	echo select volume %~1
	echo remove mount="%~2"
goto :EOF

