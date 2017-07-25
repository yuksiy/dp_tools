@echo off

rem ==============================================================================
rem   機能
rem     ディスク・パーティション・ボリュームの一覧を表示する
rem   構文
rem     dp_list.bat disk
rem     dp_list.bat partition DISK_NUM
rem     dp_list.bat volume
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

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
if "%1"=="" (
	echo -E Missing 1st argument 1>&2
	call :USAGE & exit /b 1
) else (
	set oprtype=%1
	if "!oprtype!"=="disk" (
		rem 何もしない
	) else if "!oprtype!"=="partition" (
		rem 何もしない
	) else if "!oprtype!"=="volume" (
		rem 何もしない
	) else (
		echo -E Invalid 1st argument -- "!oprtype!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem 第2引数のチェック
rem oprtype=partition の場合
if "%oprtype%"=="partition" (
	if "%2"=="" (
		echo -E Missing DISK_NUM argument 1>&2
		call :USAGE & exit /b 1
	) else (
		set DISK_NUM=%2
		rem ディスク番号のチェック
		echo !DISK_NUM!| findstr /r /c:"^[0-9][0-9]*$">nul
		if errorlevel 1 (
			echo -E Invalid DISK_NUM argument -- "!DISK_NUM!" 1>&2
			call :USAGE & exit /b 1
		)
	)
)

rem 作業開始前処理
call :PRE_PROCESS

rem 作業用 DiskPart スクリプトの生成
if "%oprtype%"=="disk" (
	call :LIST_DISK > "%SCRIPT_FILE%"
) else if "%oprtype%"=="partition" (
	call :LIST_PARTITION %DISK_NUM% > "%SCRIPT_FILE%"
) else if "%oprtype%"=="volume" (
	call :LIST_VOLUME > "%SCRIPT_FILE%"
)

rem 処理開始メッセージの表示
echo.
if "%oprtype%"=="disk" (
	echo -I Disk listing has started.
) else if "%oprtype%"=="partition" (
	echo -I Partition listing has started.
) else if "%oprtype%"=="volume" (
	echo -I Volume listing has started.
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
	if "%oprtype%"=="disk" (
		echo -E Disk listing has ended unsuccessfully. 1>&2
	) else if "%oprtype%"=="partition" (
		echo -E Partition listing has ended unsuccessfully. 1>&2
	) else if "%oprtype%"=="volume" (
		echo -E Volume listing has ended unsuccessfully. 1>&2
	)
	call :POST_PROCESS & exit /b 1
) else (
	echo.
	if "%oprtype%"=="disk" (
		echo -I Disk listing has ended successfully.
	) else if "%oprtype%"=="partition" (
		echo -I Partition listing has ended successfully.
	) else if "%oprtype%"=="volume" (
		echo -I Volume listing has ended successfully.
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
	echo Usage: dp_list.bat disk               1>&2
	echo        dp_list.bat partition DISK_NUM 1>&2
	echo        dp_list.bat volume             1>&2
goto :EOF

rem ディスクの一覧表示
:LIST_DISK
	echo list disk
goto :EOF

rem パーティションの一覧表示
:LIST_PARTITION
	echo select disk %1
	echo list partition
goto :EOF

rem ボリュームの一覧表示
:LIST_VOLUME
	echo list volume
goto :EOF

