@echo off

rem jar应用目录
set AppName=ruoyi-admin.jar

rem PID文件
set PidFile=ruoyi.pid

rem JVM参数
set JVM_OPTS="-Dname=%AppName%  -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"


ECHO.
	ECHO.  [1] 启动%AppName%
	ECHO.  [2] 关闭%AppName%
	ECHO.  [3] 重启%AppName%
	ECHO.  [4] 查看状态 %AppName%
	ECHO.  [5] 退出
ECHO.

ECHO.请输入选择的项目编号:
set /p ID=
	IF "%id%"=="1" GOTO start
	IF "%id%"=="2" GOTO stop
	IF "%id%"=="3" GOTO restart
	IF "%id%"=="4" GOTO status
	IF "%id%"=="5" EXIT
PAUSE
:start
    set pid=
    if exist "%PidFile%" (
        set /p pid=<"%PidFile%"
    )
    if defined pid (
        tasklist /FI "PID eq %pid%" | findstr /I "%pid%" >nul
        if not errorlevel 1 (
            echo %AppName% is already running with PID %pid%
            PAUSE
            goto:eof
        ) else (
            echo PID file exists but process not found, deleting old PID file
            del "%PidFile%"
        )
    )

    for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
		set pid=%%a
		set image_name=%%b
	)
	if  defined pid (
		echo %AppName% is already running with PID %pid%
		PAUSE
        goto:eof
	)

    start /B javaw %JVM_OPTS% -jar %AppName%

    timeout /t 2 /nobreak >nul

    set new_pid=
    for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
        set new_pid=%%a
        set image_name=%%b
    )
    if defined new_pid (
        echo %new_pid% > "%PidFile%"
        echo starting...
        echo Start %AppName% success, PID: %new_pid%
    ) else (
        echo Failed to start %AppName% or get PID
    )
goto:eof

rem 通过PID文件优先停止进程
:stop
    set pid=
    set found=0

    if exist "%PidFile%" (
        set /p pid=<"%PidFile%"
        if defined pid (
            echo Found PID file, trying to kill process with PID %pid%
            tasklist /FI "PID eq %pid%" | findstr /I "%pid%" >nul
            if not errorlevel 1 (
                taskkill /f /pid %pid% >nul 2>&1
                if not errorlevel 1 (
                    echo Successfully killed process with PID %pid%
                    del "%PidFile%"
                    set found=1
                ) else (
                    echo Failed to kill process with PID %pid%
                )
            ) else (
                echo Process with PID %pid% not found, deleting stale PID file
                del "%PidFile%"
            )
        )
    )

    if "%found%"=="0" (
        echo PID file not found or failed, trying to find process via jps...
        for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
            set pid=%%a
            set image_name=%%b
        )
        if defined pid (
            echo prepare to kill %image_name%
            echo start kill %pid% ...
            taskkill /f /pid %pid%
            if exist "%PidFile%" del "%PidFile%"
        ) else (
            echo process %AppName% does not exist
        )
    )
goto:eof
:restart
	call :stop
    call :start
goto:eof
:status
    set pid=
    set running=0

    if exist "%PidFile%" (
        set /p pid=<"%PidFile%"
        if defined pid (
            tasklist /FI "PID eq %pid%" | findstr /I "%pid%" >nul
            if not errorlevel 1 (
                echo %AppName% is running with PID %pid%
                set running=1
            )
        )
    )

    if "%running%"=="0" (
        for /f "usebackq tokens=1-2" %%a in (`jps -l ^| findstr %AppName%`) do (
            set pid=%%a
            set image_name=%%b
        )
        if not defined pid (
            echo process %AppName% is dead
        ) else (
            echo %image_name% is running with PID %pid% (PID file not found or stale)
        )
    )
goto:eof
