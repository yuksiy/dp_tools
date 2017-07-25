@echo off

rem ==============================================================================
rem   機能
rem     DiskPart のヘルプを表示する
rem   構文
rem     dp_help.bat [COMMAND]
rem
rem   Copyright (c) 2010-2017 Yukio Shiiya
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

rem プログラム内部変数
rem set DEBUG=TRUE
set TMP_DIR=%TEMP%
set SCRIPT_TMP_DIR=%TMP_DIR%\%SCRIPT_NAME%.%RAND%
set SCRIPT_FILE=%SCRIPT_TMP_DIR%\diskpart_script.tmp

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
set COMMAND=%*

rem 作業開始前処理
call :PRE_PROCESS

rem 作業用 DiskPart スクリプトの生成
call :HELP %COMMAND% > "%SCRIPT_FILE%"

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

rem 作業終了後処理
call :POST_PROCESS & exit /b 0
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
	echo Usage: dp_help.bat COMMAND 1>&2
goto :EOF

rem DiskPart のヘルプ表示
:HELP
	echo help %*
goto :EOF

