@echo off

rem ==============================================================================
rem   �@�\
rem     DiskPart �̃w���v��\������
rem   �\��
rem     dp_help.bat [COMMAND]
rem
rem   Copyright (c) 2010-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * ��{�ݒ�
rem **********************************************************************
rem ���ϐ��̃��[�J���C�Y�J�n
setlocal

rem �x�����ϐ��W�J�̗L����
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem �E�B���h�E�^�C�g���̐ݒ�
title %~nx0 %*

for /f "tokens=1" %%i in ('echo %~f0') do set SCRIPT_FULL_NAME=%%i
for /f "tokens=1" %%i in ('echo %~dp0') do set SCRIPT_ROOT=%%i
for /f "tokens=1" %%i in ('echo %~nx0') do set SCRIPT_NAME=%%i
set RAND=%RANDOM%

rem **********************************************************************
rem * �ϐ���`
rem **********************************************************************
rem ���[�U�ϐ�

rem �v���O���������ϐ�
rem set DEBUG=TRUE
set TMP_DIR=%TEMP%
set SCRIPT_TMP_DIR=%TMP_DIR%\%SCRIPT_NAME%.%RAND%
set SCRIPT_FILE=%SCRIPT_TMP_DIR%\diskpart_script.tmp

rem **********************************************************************
rem * ���C�����[�`��
rem **********************************************************************

rem ��1�����̃`�F�b�N
set COMMAND=%*

rem ��ƊJ�n�O����
call :PRE_PROCESS

rem ��Ɨp DiskPart �X�N���v�g�̐���
call :HELP %COMMAND% > "%SCRIPT_FILE%"

rem *********************
rem * ���C�����[�v �J�n *
rem *********************

if "%DEBUG%"=="TRUE" (
	type "%SCRIPT_FILE%"
	echo.
)
diskpart /s "%SCRIPT_FILE%"

rem *********************
rem * ���C�����[�v �I�� *
rem *********************

rem ��ƏI���㏈��
call :POST_PROCESS & exit /b 0
goto :EOF


rem **********************************************************************
rem * �T�u���[�`����`
rem **********************************************************************
:PRE_PROCESS
	rem �ꎞ�f�B���N�g���̍쐬
	mkdir "%SCRIPT_TMP_DIR%"
goto :EOF

:POST_PROCESS
	rem �ꎞ�f�B���N�g���̍폜
	if not "%DEBUG%"=="TRUE" (
		del /f /q "%SCRIPT_TMP_DIR%"
		for /d %%d in ("%SCRIPT_TMP_DIR%") do rmdir /s /q "%%d"
	)
goto :EOF

:USAGE
	echo Usage: dp_help.bat COMMAND 1>&2
goto :EOF

rem DiskPart �̃w���v�\��
:HELP
	echo help %*
goto :EOF

