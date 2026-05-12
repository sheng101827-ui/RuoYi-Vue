@echo off

rem jarƽĿ¼
set AppName=ruoyi-admin.jar
set PidFile=ruoyi.pid

rem JVM
set JVM_OPTS="-Dname=%AppName%  -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"


ECHO.
	ECHO.  [1] %AppName%
	ECHO.  [2] ر%AppName%
	ECHO.  [3] %AppName%
	ECHO.  [4] ״̬ %AppName%
	ECHO.  [5]  
ECHO.

ECHO.ѡĿ:
set /p ID=
	IF "%id%"=="1" GOTO start
	IF "%id%"=="2" GOTO stop
	IF "%id%"=="3" GOTO restart
	IF "%id%"=="4" GOTO status
	IF "%id%"=="5" EXIT
PAUSE

:start
	set pid=
	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if defined pid (
		echo %AppName% is already running, PID: %pid%
		PAUSE
		goto:eof
	)

	start javaw %JVM_OPTS% -jar %AppName%

	ping -n 3 127.0.0.1 >nul

	set pid=
	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)

	if defined pid (
		echo %pid% > %PidFile%
		echo Start %AppName% success, PID: %pid%, saved to %PidFile%
	) else (
		echo Start %AppName% may have failed, please check
	)
goto:eof

:stop
	set pid=
	if exist %PidFile% (
		for /f "usebackq" %%a in ("%PidFile%") do set pid=%%a
	)

	if defined pid (
		echo Read PID from %PidFile%: %pid%
		echo Prepare to kill PID %pid% ...
		taskkill /f /pid %pid% >nul 2>&1
		if errorlevel 1 (
			echo Kill PID %pid% failed, process may not exist
			del %PidFile% >nul 2>&1
			echo Fallback to jps findstr ...
			call :stop_fallback
		) else (
			echo Kill PID %pid% success
			del %PidFile% >nul 2>&1
		)
	) else (
		echo %PidFile% not found, fallback to jps findstr ...
		call :stop_fallback
	)
goto:eof

:stop_fallback
	set pid=
	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if not defined pid (echo process %AppName% does not exists) else (
		echo prepare to kill %image_name%
		echo start kill %pid% ...
		taskkill /f /pid %pid%
		if exist %PidFile% del %PidFile% >nul 2>&1
	)
goto:eof

:restart
	call :stop
    call :start
goto:eof

:status
	set file_pid=
	if exist %PidFile% (
		for /f "usebackq" %%a in ("%PidFile%") do set file_pid=%%a
		echo %PidFile% exists, recorded PID: %file_pid%
	) else (
		echo %PidFile% not found
	)

	set pid=
	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if not defined pid (echo process %AppName% is dead ) else (
		echo %image_name% is running, PID: %pid%
	)
goto:eof
