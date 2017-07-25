@echo off

rem ==============================================================================
rem   �@�\
rem     �{�����[������h���C�u�����܂��̓}�E���g�|�C���g�p�X���폜����
rem   �\��
rem     dp_remove.bat letter VOLUME LETTER
rem     dp_remove.bat mount VOLUME MOUNT
rem
rem   Copyright (c) 2004-2017 Yukio Shiiya
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

rem �V�X�e���� �ˑ��ϐ�

rem �v���O���������ϐ�
rem set DEBUG=TRUE
set TMP_DIR=%TEMP%
set SCRIPT_TMP_DIR=%TMP_DIR%\%SCRIPT_NAME%.%RAND%
set SCRIPT_FILE=%SCRIPT_TMP_DIR%\diskpart_script.tmp

set DP_LIST=%SCRIPT_ROOT%\dp_list.bat

rem **********************************************************************
rem * ���C�����[�`��
rem **********************************************************************

rem ��1�����̃`�F�b�N
if "%~1"=="" (
	echo -E Missing 1st argument 1>&2
	call :USAGE & exit /b 1
) else (
	set oprtype=%~1
	if "!oprtype!"=="letter" (
		rem �������Ȃ�
	) else if "!oprtype!"=="mount" (
		rem �������Ȃ�
	) else (
		echo -E Invalid 1st argument -- "!oprtype!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem ��2�����̃`�F�b�N
if "%~2"=="" (
	echo -E Missing VOLUME argument 1>&2
	call :USAGE & exit /b 1
) else (
	set VOLUME=%~2
	rem �{�����[�������̃`�F�b�N
	rem ��dp_select.bat�������call����H
)

rem ��3�����̃`�F�b�N
if "%~3"=="" (
	if "%oprtype%"=="letter" (
		echo -E Missing LETTER argument 1>&2
	) else if "%oprtype%"=="mount" (
		echo -E Missing MOUNT argument 1>&2
	)
	call :USAGE & exit /b 1
) else (
	rem oprtype=letter �̏ꍇ
	if "%oprtype%"=="letter" (
		set LETTER=%~3
		rem �h���C�u�����̃`�F�b�N
		echo !LETTER!| findstr /r "^[ABCDEFGHIJKLMNOPQRSTUVWXYZ]$" > nul 2>&1
		if errorlevel 1 (
			echo -E Invalid LETTER argument -- "!LETTER!" 1>&2
			call :USAGE & exit /b 1
		)
	rem oprtype=mount �̏ꍇ
	) else if "%oprtype%"=="mount" (
		set MOUNT=%~3
		rem �w�肳�ꂽ�f�B���N�g���̃`�F�b�N
		if not exist !MOUNT!\nul (
			echo -E MOUNT not a directory -- "!MOUNT!" 1>&2
			call :USAGE & exit /b 1
		)
	)
)

rem ��ƊJ�n�O����
call :PRE_PROCESS

rem ��Ɨp DiskPart �X�N���v�g�̐���
if "%oprtype%"=="letter" (
	call :REMOVE_LETTER "%VOLUME%" "%LETTER%" > "%SCRIPT_FILE%"
) else if "%oprtype%"=="mount" (
	call :REMOVE_MOUNT "%VOLUME%" "%MOUNT%" > "%SCRIPT_FILE%"
)

rem �����J�n���b�Z�[�W�̕\��
echo.
if "%oprtype%"=="letter" (
	echo -I Drive-letter removal has started.
) else if "%oprtype%"=="mount" (
	echo -I Mount-point-path removal has started.
)

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

rem �����I�����b�Z�[�W�̕\��
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
	rem ��ƏI���㏈��
	call :POST_PROCESS & exit /b 0
)
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
	echo Usage: dp_remove.bat letter VOLUME LETTER 1>&2
	echo        dp_remove.bat mount VOLUME MOUNT   1>&2
goto :EOF

rem �h���C�u�����̊��蓖��
:REMOVE_LETTER
	echo select volume %~1
	echo remove letter="%~2"
goto :EOF

rem �}�E���g�|�C���g�p�X�̊��蓖��
:REMOVE_MOUNT
	echo select volume %~1
	echo remove mount="%~2"
goto :EOF

