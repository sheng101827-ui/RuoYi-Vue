@echo off

rem jar包主目录
set AppName=ruoyi-admin.jar
set PidFile=%~dp0ruoyi.pid

rem JVM参数
set JVM_OPTS="-Dname=%AppName%  -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"


ECHO.
	ECHO.  [1] 启动%AppName%
	ECHO.  [2] 关闭%AppName%
	ECHO.  [3] 重启%AppName%
	ECHO.  [4] 查看状态 %AppName%
	ECHO.  [5] 退 出
ECHO.

ECHO.请输入选项编号:
set /p ID=
	IF "%id%"=="1" GOTO start
	IF "%id%"=="2" GOTO stop
	IF "%id%"=="3" GOTO restart
	IF "%id%"=="4" GOTO status
	IF "%id%"=="5" EXIT
PAUSE
:start
    for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if defined pid (
		echo %AppName% is running
		PAUSE
	)

start javaw %JVM_OPTS% -jar %AppName%

rem 等待启动后记录PID到文件
ping -n 3 127.0.0.1 >nul
for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
    echo %%a > "%PidFile%"
)
echo starting......
echo Start %AppName% success...
goto:eof

rem 停止stop优先使用PID文件，避免误杀
:stop
	setlocal enabledelayedexpansion
	set killed=0

	if exist "%PidFile%" (
		set /p pid=<"%PidFile%"
		if defined pid (
			tasklist /fi "PID eq %pid%" | findstr /i %pid% >nul
			if !errorlevel!==0 (
				echo prepare to kill PID %pid%
				taskkill /f /pid %pid%
				set killed=1
			) else (
				echo PID %pid% not found in tasklist, may have already exited
			)
		)
		del "%PidFile%" 2>nul
	)

	if %killed%==0 (
		for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
			set pid=%%a
			set image_name=%%b
		)
		if not defined pid (
			echo process %AppName% does not exists
		) else (
			echo prepare to kill %image_name%
			echo start kill %pid% ...
			taskkill /f /pid %pid%
			del "%PidFile%" 2>nul
		)
	)
	endlocal
goto:eof
:restart
	call :stop
    call :start
goto:eof
:status
	setlocal enabledelayedexpansion
	set status_pid=

	if exist "%PidFile%" (
		set /p status_pid=<"%PidFile%"
		if defined status_pid (
			tasklist /fi "PID eq %status_pid%" | findstr /i %status_pid% >nul
			if !errorlevel!==0 (
				echo %AppName% is running ^(PID: %status_pid%^)
				endlocal
				goto:eof
			)
		)
	)

	for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if not defined pid (
		echo process %AppName% is dead
		if exist "%PidFile%" del "%PidFile%" 2>nul
	) else (
		echo %image_name% is running ^(PID: %pid%^)
	)
	endlocal
goto:eof