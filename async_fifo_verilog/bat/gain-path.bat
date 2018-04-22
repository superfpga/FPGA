@echo off & setlocal EnableDelayedExpansion
::删除上次路径文件
del rtl.f

::获取原始全路径列表
for /r .. %%a in (*.v,*.vhd) do (
    set var=%%~a
    echo !var! >> verilog.f
    )
)

::将全路径列表内的\斜杠修改为/斜杠，写入最终路径文件内
(For /f "delims=" %%i in (verilog.f) do (Set str=%%i
　　SetLocal EnableDelayedExpansion
　　Set str=!Str:\=/!
　　echo !str!
　　EndLocal
))>rtl.f

::删除原始路径列表
DEL verilog.f