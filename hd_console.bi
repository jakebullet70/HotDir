

Function GetypeConsoleInfo(ByRef ci As typeConsoleInfo) As typeConsoleInfo
    Dim csbi as CONSOLE_SCREEN_BUFFER_INFO

    ci.ConsoleHandle = GetStdHandle(STD_OUTPUT_HANDLE)
    GetConsoleScreenBufferInfo(ci.ConsoleHandle, @csbi)

    '' Save console colours
    ci.Colors         = csbi.wAttributes
    ci.ColorsOriginal = csbi.wAttributes

    '' Console dimensions.  When stdout is redirected (no real console),
    '' GetConsoleScreenBufferInfo yields a degenerate window, so fall back to
    '' a conventional 80x25 so the listing still lays out sensibly.
    ci.Width  = csbi.srWindow.Right + 1
    ci.Height = csbi.srWindow.Bottom - csbi.srWindow.Top
    If ci.Width  < 20 Then ci.Width  = 80
    If ci.Height < 1  Then ci.Height = 25

    Return ci
End Function


Function GetConsoleWidth() As Integer
    Dim As HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE)
    Dim As CONSOLE_SCREEN_BUFFER_INFO csbi
    GetConsoleScreenBufferInfo(h, @csbi)
    Return csbi.srWindow.Right + 1
End Function

