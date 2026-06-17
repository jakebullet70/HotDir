@echo off
rem ===========================================================================
rem  Build HotDIR (release): compile with FreeBASIC, then shrink with UPX.
rem  Plain "fbc hd.bas" already produces a stripped ~100 KB exe; UPX packing
rem  brings it down to ~45 KB (~44%% of original).
rem ===========================================================================
setlocal
set "FBC=C:\dev\FreeBASIC\FreeBASIC\fbc64.exe"
set "PACKER=C:\dev\FreeBASIC\upx\upx.exe"
set "SRC=%~dp0hd.bas"
set "EXE=%~dp0hd.exe"

echo [1/2] Compiling %SRC% ...
"%FBC%" "%SRC%" -w all
if errorlevel 1 (
    echo Compile failed.
    exit /b 1
)

echo [2/2] Compressing %EXE% with UPX ...
"%PACKER%" --best --lzma "%EXE%"
if errorlevel 1 (
    echo UPX packing failed ^(exe is still usable, just uncompressed^).
    exit /b 1
)

echo Done: %EXE%
endlocal
