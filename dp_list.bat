@echo off

rem ==============================================================================
rem   �@�\
rem     �f�B�X�N�E�p�[�e�B�V�����E�{�����[���̈ꗗ��\������
rem   �\��
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

rem **********************************************************************
rem * ���C�����[�`��
rem **********************************************************************

rem ��1�����̃`�F�b�N
if "%1"=="" (
	echo -E Missing 1st argument 1>&2
	call :USAGE & exit /b 1
) else (
	set oprtype=%1
	if "!oprtype!"=="disk" (
		rem �������Ȃ�
	) else if "!oprtype!"=="partition" (
		rem �������Ȃ�
	) else if "!oprtype!"=="volume" (
		rem �������Ȃ�
	) else (
		echo -E Invalid 1st argument -- "!oprtype!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem ��2�����̃`�F�b�N
rem oprtype=partition �̏ꍇ
if "%oprtype%"=="partition" (
	if "%2"=="" (
		echo -E Missing DISK_NUM argument 1>&2
		call :USAGE & exit /b 1
	) else (
		set DISK_NUM=%2
		rem �f�B�X�N�ԍ��̃`�F�b�N
		echo !DISK_NUM!| findstr /r /c:"^[0-9][0-9]*$">nul
		if errorlevel 1 (
			echo -E Invalid DISK_NUM argument -- "!DISK_NUM!" 1>&2
			call :USAGE & exit /b 1
		)
	)
)

rem ��ƊJ�n�O����
call :PRE_PROCESS

rem ��Ɨp DiskPart �X�N���v�g�̐���
if "%oprtype%"=="disk" (
	call :LIST_DISK > "%SCRIPT_FILE%"
) else if "%oprtype%"=="partition" (
	call :LIST_PARTITION %DISK_NUM% > "%SCRIPT_FILE%"
) else if "%oprtype%"=="volume" (
	call :LIST_VOLUME > "%SCRIPT_FILE%"
)

rem �����J�n���b�Z�[�W�̕\��
echo.
if "%oprtype%"=="disk" (
	echo -I Disk listing has started.
) else if "%oprtype%"=="partition" (
	echo -I Partition listing has started.
) else if "%oprtype%"=="volume" (
	echo -I Volume listing has started.
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
	echo Usage: dp_list.bat disk               1>&2
	echo        dp_list.bat partition DISK_NUM 1>&2
	echo        dp_list.bat volume             1>&2
goto :EOF

rem �f�B�X�N�̈ꗗ�\��
:LIST_DISK
	echo list disk
goto :EOF

rem �p�[�e�B�V�����̈ꗗ�\��
:LIST_PARTITION
	echo select disk %1
	echo list partition
goto :EOF

rem �{�����[���̈ꗗ�\��
:LIST_VOLUME
	echo list volume
goto :EOF

