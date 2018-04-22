@echo off & setlocal EnableDelayedExpansion
::删除上次路径文件
del package.f

::获取原始全路径列表
for /r ..\package %%a in (*.vhd) do (
    set var=%%~a
    echo !var! >> p.f
)
)

::将全路径列表内的\斜杠修改为/斜杠，写入最终路径文件内
(For /f "delims=" %%i in (p.f) do (Set str=%%i
　　SetLocal EnableDelayedExpansion
　　Set str=!Str:\=/!
　　echo !str!
　　EndLocal
))>package.f

::删除原始路径列表
DEL p.f

::删除上次路径文件
del rtl.f

::获取原始全路径列表
for /r ..\rtl %%a in (*.vhd) do (
    set var=%%~a
    echo !var! >> vhdl.f
)
)

::将全路径列表内的\斜杠修改为/斜杠，写入最终路径文件内
(For /f "delims=" %%i in (vhdl.f) do (Set str=%%i
　　SetLocal EnableDelayedExpansion
　　Set str=!Str:\=/!
　　echo !str!
　　EndLocal
))>rtl.f

::删除原始路径列表
DEL vhdl.f


::设置软件路径 
SET debussy=C:\Novas\Debussy\bin\Debussy.exe 
SET vsim=C:\modeltech_10.1c\win32\vsim.exe 
::ModelSim Command 
%vsim% -c -do sim.do 
::删除ModelSim生成的相关文件 
RD work /s /q 
DEL transcript vsim.wlf /q 
::Debussy Command 
%debussy% -f package.f -f rtl.f -ssf debussy.fsdb -2001 
::删除波形文件 
DEL debussy.fsdb /q 
::删除Debussy生成的相关文件 
RD Debussy.exeLog  /s /q 
DEL novas.rc /q 
::退出命令行 
EXIT