@echo off

rem jarƽ��Ŀ¼
set AppName=ruoyi-admin.jar

rem JVM����
set JVM_OPTS="-Dname=%AppName%  -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"


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
	set "pid="
	if exist ruoyi.pid (
		set /p pid=<ruoyi.pid
	)
	if defined pid (
		tasklist /fi "pid eq %pid%" | findstr "java" >nul
		if not errorlevel 1 (
			echo %AppName% is already running with PID %pid%
			PAUSE
			goto:eof
		) else (
			del ruoyi.pid
			set "pid="
		)
	)

	set APP_ID=%RANDOM%%RANDOM%
	start javaw %JVM_OPTS% -Dapp.id=%APP_ID% -jar %AppName%

	echo  starting
	
	set "pid="
	for /l %%i in (1, 1, 3) do (
		timeout /t 1 /nobreak >nul
		for /f "usebackq tokens=1" %%a in (`jps -v ^| findstr "%APP_ID%"`) do (
			set pid=%%a
		)
		if defined pid goto :save_pid
	)
:save_pid
	if defined pid (
		echo %pid%> ruoyi.pid
	)

	echo  Start %AppName% success...
goto:eof

rem stopͨjpspid
:stop
	set "pid="
	if exist ruoyi.pid (
		set /p pid=<ruoyi.pid
	)
	
	if defined pid (
		tasklist /fi "pid eq %pid%" | findstr "java" >nul
		if not errorlevel 1 (
			echo found ruoyi.pid, prepare to kill %pid%
			taskkill /f /pid %pid%
			del ruoyi.pid
			goto:eof
		) else (
			echo stale ruoyi.pid found, process %pid% is not java.
			del ruoyi.pid
			set "pid="
		)
	)
	
	rem fallback
	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if not defined pid (echo process %AppName% does not exists) else (
		echo prepare to kill %image_name%
		echo start kill %pid% ...
		rem ݽIDkill
		taskkill /f /pid %pid%
	)
goto:eof
:restart
	call :stop
    call :start
goto:eof
:status
	set "pid="
	if exist ruoyi.pid (
		set /p pid=<ruoyi.pid
	)
	if defined pid (
		tasklist /fi "pid eq %pid%" | findstr "java" >nul
		if not errorlevel 1 (
			echo %AppName% is running with PID %pid%
			goto:eof
		)
	)

	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if not defined pid (echo process %AppName% is dead ) else (
		echo %image_name% is running
	)
goto:eof
