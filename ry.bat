@echo off

rem jarƽ��Ŀ¼
set AppName=ruoyi-admin.jar

rem JVM����
set JVM_OPTS="-Dname=%AppName%  -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"
setlocal enabledelayedexpansion
set "AppHome=%~dp0"
set "PID_FILE=%AppHome%ruoyi.pid"
cd /d "%AppHome%"

ECHO.
	ECHO.  [1] ����%AppName%
	ECHO.  [2] �ر�%AppName%
	ECHO.  [3] ����%AppName%
	ECHO.  [4] ����״̬ %AppName%
	ECHO.  [5] �� ��
ECHO.

ECHO.������ѡ����Ŀ�����:
set /p ID=
	IF "%id%"=="1" GOTO start
	IF "%id%"=="2" GOTO stop
	IF "%id%"=="3" GOTO restart
	IF "%id%"=="4" GOTO status
	IF "%id%"=="5" EXIT
PAUSE
:start
	call :findPidFromFile
	if not defined pid call :findPidFromJps
	if defined multi_match (
		echo found multiple java processes matching %AppName%, skip start
		PAUSE
		goto:eof
	)
	if defined pid (
		echo !image_name! is running
		PAUSE
		goto:eof
	)

	set "pid="
	for /f %%i in ('powershell -NoProfile -Command "$p = Start-Process -FilePath 'javaw' -ArgumentList '%JVM_OPTS% -jar %AppName%' -WorkingDirectory '%AppHome%' -PassThru; $p.Id"') do set "pid=%%i"
	if not defined pid (
		echo Start %AppName% failed...
		goto:eof
	)

	>"%PID_FILE%" echo !pid!
	echo  starting����
	echo  Start %AppName% success, pid=!pid! ...
goto:eof

:stop
	call :findPidFromFile
	if defined pid (
		echo prepare to kill !image_name!
		echo start kill !pid! ...
		taskkill /f /pid !pid!
		if !errorlevel! equ 0 if exist "%PID_FILE%" del /f /q "%PID_FILE%"
		goto:eof
	)

	if exist "%PID_FILE%" del /f /q "%PID_FILE%"
	call :findPidFromJps
	if defined multi_match (
		echo found multiple java processes matching %AppName%, skip stop
		goto:eof
	)
	if not defined pid (
		echo process %AppName% does not exists
	) else (
		echo prepare to kill !image_name!
		echo start kill !pid! ...
		taskkill /f /pid !pid!
	)
goto:eof
:restart
	call :stop
    call :start
goto:eof
:status
	call :findPidFromFile
	if not defined pid call :findPidFromJps
	if defined multi_match (
		echo found multiple java processes matching %AppName%
	) else if not defined pid (
		echo process %AppName% is dead
	) else (
		echo !image_name! is running, pid=!pid!
	)
goto:eof

:findPidFromFile
	set "pid="
	set "image_name="
	set "multi_match="
	if exist "%PID_FILE%" (
		set /p pid=<"%PID_FILE%"
		if defined pid (
			for /f "usebackq tokens=1,*" %%a in (`jps -l ^| findstr /b /c:"!pid! " ^| findstr /i /c:"%AppName%"`) do (
				set "pid=%%a"
				set "image_name=%%b"
			)
		)
	)
	if not defined image_name set "pid="
	goto:eof

:findPidFromJps
	set "pid="
	set "image_name="
	set "multi_match="
	set /a match_count=0
	for /f "usebackq tokens=1,*" %%a in (`jps -l ^| findstr /i /c:"%AppName%"`) do (
		set /a match_count+=1
		if !match_count! equ 1 (
			set "pid=%%a"
			set "image_name=%%b"
		)
	)
	if !match_count! gtr 1 (
		set "pid="
		set "image_name="
		set "multi_match=1"
	)
	goto:eof
