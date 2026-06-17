'' HotDIR (clone) - Public Domain
''
''  String padding helpers, factored out of hd.bas.

#pragma once

'' Right-pad S with spaces to at least L characters.
Function PadRight(ByRef S As String, ByVal L As Integer) As String
    If L < 0 Then L = 0
    If Len(S) >= L Then Return S
    Return S & Space(L - Len(S))
End Function


'' Left-pad S with spaces to at least L characters.
Function PadLeft(ByRef S As String, ByVal L As Integer) As String
    If L < 0 Then L = 0
    If Len(S) >= L Then Return S
    Return Space(L - Len(S)) & S
End Function
