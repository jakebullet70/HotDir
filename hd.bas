'' HotDIR (clone of DOS's HotDIR) - Public Domain 
''
''  Colorful file/folder listing at the command prompt.
''
''  FreeBASIC  port 
''
''  Usage:
''    HD                                    list the current directory
''    HD *.exe                           list the current directory, filtered
''    HD x:\some\path              list a specific path
''    HD x:\some\path\*.txt    list a path, filtered
''    HD /?                                show help
''
''  NO WARRANTY WHATSOEVER! But it just reads...

#include once "windows.bi"
#include once "hd_consts.bi"
#include once "hd_strings.bi"
#include once "hd_types_enums.bi"
#include once "hd_console.bi"

Const VERSION_STRING = "1.0.0" : Const COPY_WRITE =   "Public domain - 2026"


'#Region "Helpers"
'' --- forward declarations ---------------------------------------------------
Declare Sub RestoreConsole(ByRef ci As typeConsoleInfo)


'' Set the console foreground colour.
Sub ColorFG(ByRef ci As typeConsoleInfo, ByVal Clr As UShort)
    SetConsoleTextAttribute(ci.ConsoleHandle, Clr)
End Sub


'' True if Ext (already lower-cased) is in the given space-delimited list.
Function ExtIn(ByRef Ext As String, ByRef List As String) As Integer
    If Ext = "" Then Return 0
    Return Iif(InStr(List, " " & Ext & " ") > 0, -1, 0)
End Function


'' Lower-cased file extension, including the leading dot ("" if none).
Function ExtractFileExt(ByRef FileName As String) As String
    Dim As Integer dotPos = InStrRev(FileName, ".")
    Dim As Integer sepPos = InStrRev(FileName, "\")
    If dotPos = 0 OrElse dotPos < sepPos Then Return ""
    Return LCase(Mid(FileName, dotPos))
End Function


'' Shorten Name to fit Width characters, keeping the extension and marking the
'' cut with '~' (e.g. "hd_consts.bi" at width 10 -> "hd_con~.bi").  Falls back
'' to a plain truncation when there is no extension or no room to keep it.
Function FitName(ByRef FileName As String, ByVal MaxLen As Integer) As String
    If MaxLen < 1 Then Return ""
    If Len(FileName) <= MaxLen Then Return FileName

    Dim As Integer dotPos = InStrRev(FileName, ".")
    If dotPos > 1 Then                                  '' real extension (not a dotfile)
        Dim As String  ext  = Mid(FileName, dotPos)     '' includes the leading dot
        Dim As Integer keep = MaxLen - 1 - Len(ext)     '' room for base + '~'
        If keep >= 1 Then Return Left(FileName, keep) & "~" & ext
    End If

    Return Left(FileName, MaxLen)
End Function
'#End Region


'#Region "startup"

Sub BuildInitialSearchString(ByRef si As typeSearchInfo)
    si.Pattern = CurDir()
    If si.Pattern = "" Then
        Print "Error getting current directory."
        End 1
    End If
    si.Path = si.Pattern & "\*.*"
End Sub


'' Format a byte count with a B/KB/MB/GB/TB suffix (matches original).
Function CompactSizeWithSuffix(ByVal SizeBytes As Double) As String
    If SizeBytes >= 1024 Then
        SizeBytes = SizeBytes / 1024          '' KB
        If SizeBytes >= 1024 Then
            SizeBytes = SizeBytes / 1024       '' MB
            If SizeBytes >= 1024 Then
                SizeBytes = SizeBytes / 1024   '' GB
                If SizeBytes >= 1024 Then       '' TB
                    Return Str(Int(SizeBytes / 1024)) & " TB"
                Else
                    Return Str(Int(SizeBytes)) & " GB"
                End If
            Else
                Return Str(Int(SizeBytes)) & " MB"
            End If
        Else
            Return Str(Int(SizeBytes)) & " KB"
        End If
    Else
        Return Str(Int(SizeBytes)) & " B"
    End If
End Function


Function CreateHorizontalLine(ByRef ci As typeConsoleInfo) As String
    Return String(ci.Width, HLINE_CHAR)
End Function


'' Horizontal rule with a junction byte dropped in wherever a column separator
'' '|' lands, so the top/bottom borders connect to the inner vertical lines.
'' JunctionChar = TDOWN_CHAR for the top rule, TUP_CHAR for the bottom.
Function CreateGridRule(ByRef ci As typeConsoleInfo, ByVal Cols As Integer, ByVal JunctionChar As Integer) As String
    Dim As String  RuleLine = String(ci.Width, HLINE_CHAR)
    If Cols < 1 Then Cols = 1
    Dim As Integer CellWidth = (ci.Width - 1) \ Cols
    Dim As Integer NameWidth = CellWidth - 10
    If NameWidth < 1 Then NameWidth = 1

    '' Separators sit after the name + 8-char size field, for every column but
    '' the last (which has no trailing separator). Mid() is 1-based.
    Dim As Integer c, SepCol
    For c = 0 To Cols - 2
        SepCol = c * CellWidth + NameWidth + 8
        If SepCol >= 0 AndAlso SepCol < ci.Width Then Mid(RuleLine, SepCol + 1, 1) = Chr(JunctionChar)
    Next c
    Return RuleLine
End Function
'#End Region


'#Region "Header & help"
Sub DisplayHeader(ByRef ci As typeConsoleInfo, ByRef si As typeSearchInfo)
    ColorFG(ci, BRIGHT_WHITE)
    Print
    Print "HotDIR " & VERSION_STRING & " - " & COPY_WRITE
    ColorFG(ci, AQUA)
    Print "Path: "; si.Path

    '' Top border, with down-tee junctions where the column rules begin.
    Print CreateGridRule(ci, si.Columns, TDOWN_CHAR);
End Sub


Sub DisplayHelp(ByRef ci As typeConsoleInfo)
 
    ColorFG(ci, PURPLE) : Print : Print "Clone of ";
    ColorFG(ci, YELLOW) : Print "HotDIR ";
    ColorFG(ci, PURPLE) : Print "By Steve De George SR and Claude (Stupid AI!)  -> " & VERSION_STRING  & " - " & COPY_WRITE
    ColorFG(ci, PURPLE) : Print "Written in FreeBASIC, not C or RUST or GO"
    ColorFG(ci, AQUA)   : Print : Print "Usage:"
    ColorFG(ci, WHITE)  : Print Chr(9) & "HD [options] [drive:\][path][search-string]"
    ColorFG(ci, AQUA)   : Print : Print "Options:"
    ColorFG(ci, WHITE)  : Print Chr(9) & "/C ";
    ColorFG(ci, AQUA)   : Print "- Clear Screen"
    ColorFG(ci, WHITE)  : Print Chr(9) & "/# ";
    ColorFG(ci, AQUA)   : Print "- Number of Columns (1,2,4,6) (Default: 2)"
    ColorFG(ci, WHITE)  : Print Chr(9) & "/L ";
    ColorFG(ci, AQUA)   : Print "- Left to Right Ordering (Default: Top to Bottom)"
    ColorFG(ci, WHITE)  : Print Chr(9) & "/E ";
    ColorFG(ci, AQUA)   : Print "- Sort by Extension"
    ColorFG(ci, WHITE)  : Print Chr(9) & "/D ";
    ColorFG(ci, AQUA)   : Print "- Sort by Date"
    ColorFG(ci, WHITE)  : Print Chr(9) & "/S ";
    ColorFG(ci, AQUA)   : Print "- Sort by Size"
End Sub


'' Footer: a rule across the screen, then the listed drive's free / total space.
Sub DisplayFooter(ByRef ci As typeConsoleInfo, ByRef si As typeSearchInfo)
    Dim As String         root = Left(si.Path, 3)        '' "X:\"
    Dim As ULARGE_INTEGER FreeAvail, TotalBytes, TotalFree

    '' Bottom rule, then the dir/file tallies (always shown).
    ColorFG(ci, AQUA)         : Print CreateGridRule(ci, si.Columns, TUP_CHAR);
    ColorFG(ci, AQUA)         : Print "Total: ";
    ColorFG(ci, BRIGHT_WHITE) : Print Str(si.DirCount);
    ColorFG(ci, AQUA)         : Print " dir(s)   ";
    ColorFG(ci, BRIGHT_WHITE) : Print Str(si.FileCount);
    ColorFG(ci, AQUA)         : Print " file(s)";

    '' Free / total disk space, right-justified to the console edge on the same
    '' line as the Total tally (skipped if the drive can't be queried).
    If GetDiskFreeSpaceExA(StrPtr(root), @FreeAvail, @TotalBytes, @TotalFree) = 0 Then
        Print
        Exit Sub
    End If

    Dim As String FreeStr   = CompactSizeWithSuffix(CDbl(FreeAvail.QuadPart))
    Dim As String TotStr    = CompactSizeWithSuffix(CDbl(TotalBytes.QuadPart))
    Dim As String SpaceText = "Available Free Space " & FreeStr & " of " & TotStr

    '' Pad from the current cursor column so the text ends at the right edge.
    Dim As CONSOLE_SCREEN_BUFFER_INFO csbi
    GetConsoleScreenBufferInfo(ci.ConsoleHandle, @csbi)
    Dim As Integer Pad = (ci.Width - 1) - csbi.dwCursorPosition.X - Len(SpaceText)
    If Pad < 1 Then Pad = 1
    Print Space(Pad);

    ColorFG(ci, AQUA)         : Print "Available Free Space ";
    ColorFG(ci, BRIGHT_WHITE) : Print FreeStr;
    ColorFG(ci, AQUA)         : Print " of ";
    ColorFG(ci, BRIGHT_WHITE) : Print TotStr
End Sub
'#End Region


'#Region "Command-line parsing"
'' Build a search path from a drive/folder/file argument, mirroring the
'' original's process_command_line() path handling.
Sub ProcessPathArg(ByRef si As typeSearchInfo, ByVal Arg As String)
    Dim As Integer ColonPos = InStr(Arg, ":")
    Dim As String PatternNoDrive

    If ColonPos > 0 Then
        '' Drive indicator present: take the letter before ':' and drop "X:".
        si.Drive = UCase(Mid(Arg, ColonPos - 1, 1))
        Arg = Mid(Arg, ColonPos + 1)
    Else
        '' Fall back to the current drive letter (first char of the pattern).
        si.Drive = Left(si.Pattern, 1)
    End If

    '' Drop the drive letter from the (current-directory) pattern.
    PatternNoDrive = Mid(si.Pattern, 3)
    si.Pattern = PatternNoDrive

    If Len(Arg) > 0 Then
        If Left(Arg, 1) <> "\" Then
            si.Path = si.Drive & ":" & PatternNoDrive & "\" & Arg
        Else
            si.Path = si.Drive & ":" & Arg
        End If
    Else
        si.Path = si.Drive & ":\"
    End If

    If Right(si.Path, 1) = "\" Then si.Path = si.Path & "*.*"
End Sub


'' Fetch command-line arguments straight from Windows, bypassing the C runtime's
'' argv -- which globs wildcards ("*.exe" gets pre-expanded into the matching file
'' names before the program runs).  CommandLineToArgvW never expands wildcards, so
'' patterns reach us intact.  Returns the count; Args(0) is the program name.
Declare Function fbGetCommandLineW Lib "kernel32" Alias "GetCommandLineW" () As WString Ptr
Declare Function fbCommandLineToArgvW Lib "shell32" Alias "CommandLineToArgvW" _
    (ByVal lpCmdLine As WString Ptr, ByVal pNumArgs As Long Ptr) As WString Ptr Ptr
Declare Function fbLocalFree Lib "kernel32" Alias "LocalFree" (ByVal hMem As Any Ptr) As Any Ptr

Function GetRealArgs(Args() As String) As Integer
    Dim As Long argc = 0
    Dim As WString Ptr Ptr argv = fbCommandLineToArgvW(fbGetCommandLineW(), @argc)
    If argv = 0 Then Return 0

    ReDim Args(argc - 1)
    Dim As Integer i
    For i = 0 To argc - 1
        Args(i) = *argv[i]      '' WString -> String (ANSI) conversion
    Next
    fbLocalFree(argv)
    Return argc
End Function


Sub ProcessCommandLine(ByRef si As typeSearchInfo)
    Dim As String Arg, c
    Dim As String Args()
    Dim As Integer argc = GetRealArgs(Args())
    Dim As Integer i = 1

    Do
        If i >= argc Then Exit Do
        Arg = Args(i)
        i += 1

        If Len(Arg) > 0 AndAlso Left(Arg, 1) = "/" Then
            If Len(Arg) >= 2 Then
                c = UCase(Mid(Arg, 2, 1))
            Else
                c = ""
            End If

            Select Case c
                Case "H", "?"   : si.Pattern = "/h"
                Case "C"        : si.ShouldClearScreen = -1
                Case "N"        : si.SortBy = SORT_BY_NAME
                Case "E"        : si.SortBy = SORT_BY_EXTENSION
                Case "D"        : si.SortBy = SORT_BY_DATE
                Case "S"        : si.SortBy = SORT_BY_SIZE
                Case "L"        : si.LeftToRight = -1
                Case "1" To "9" : si.Columns = Val(c)
            End Select
        Else
            '' Process any drive, folder, and file argument.
            ProcessPathArg(si, Arg)
        End If
    Loop
End Sub


Sub FixupPath(ByRef si As typeSearchInfo)
    Dim As DWORD Attributes = GetFileAttributesA(StrPtr(si.Path))
    If (Attributes <> INVALID_FILE_ATTRIBUTES) AndAlso _
       ((Attributes And FILE_ATTRIBUTE_DIRECTORY) <> 0) Then
        si.Path = si.Path & "\*.*"
    End If
End Sub
'#End Region


'#Region "File listing, sorting & display"
'' Choose a foreground colour for a file based on its (lower-cased) extension.
Function ColorForExt(ByRef Ext As String) As UShort
    If Ext = "" Then
        Return GRAY
    ElseIf ExtIn(Ext, EXEC_EXTS) Then
        Return LIGHT_AQUA
    ElseIf ExtIn(Ext, DOC_EXTS) Then
        Return BRIGHT_WHITE
    ElseIf ExtIn(Ext, BATCH_EXTS) Then
        Return LIGHT_RED
    ElseIf ExtIn(Ext, COM_EXTS) Then
        Return LIGHT_GREEN
    ElseIf ExtIn(Ext, SCRIPT_EXTS) Then
        Return GREEN
    ElseIf ExtIn(Ext, MEDIA_EXTS) Then
        Return LIGHT_YELLOW
    ElseIf ExtIn(Ext, ARCHIVE_EXTS) Then
        Return YELLOW
    Else
        Return GRAY
    End If
End Function


'' True (-1) if entry A should sort before entry B for the chosen key.
'' Folders always sort ahead of files; ties fall back to name order.
Function FileEntryLess(ByRef a As typeFileEntry, ByRef b As typeFileEntry, _
                       ByVal SortBy As enumSortBy) As Integer
    If a.IsDir <> b.IsDir Then Return Iif(a.IsDir, -1, 0)

    Select Case SortBy
        Case SORT_BY_EXTENSION
            If a.Ext <> b.Ext Then Return Iif(a.Ext < b.Ext, -1, 0)
        Case SORT_BY_DATE
            If a.WriteTime <> b.WriteTime Then Return Iif(a.WriteTime < b.WriteTime, -1, 0)
        Case SORT_BY_SIZE
            If a.Size <> b.Size Then Return Iif(a.Size < b.Size, -1, 0)
    End Select

    '' SORT_BY_NAME, or tie-break for the other keys (case-insensitive).
    Return Iif(LCase(a.FileName) < LCase(b.FileName), -1, 0)
End Function


'' Stable insertion sort -- plenty fast for console-sized directory listings.
Sub SortFileEntries(Entries() As typeFileEntry, ByVal Count As Integer, _
                    ByVal SortBy As enumSortBy)
    Dim As Integer i, j
    Dim As typeFileEntry Pending
    For i = 1 To Count - 1
        Pending = Entries(i)
        j = i - 1
        While j >= 0 AndAlso FileEntryLess(Pending, Entries(j), SortBy)
            Entries(j + 1) = Entries(j)
            j -= 1
        Wend
        Entries(j + 1) = Pending
    Next
End Sub


'' Render a non-negative Double with exactly one decimal place ("15.2", "476.0").
'' Replaces vbcompat's Format(x, "0.0") so the runtime stays lean.
Function OneDecimal(ByVal value As Double) As String
    Dim As LongInt scaled = CLngInt(value * 10.0 + 0.5)   '' round half up (sizes are >= 0)
    Return Str(scaled \ 10) & "." & Str(scaled Mod 10)
End Function


'' Render a file size as a fixed 8-character field (e.g. " 15.1 KB").
Function SizeField(ByVal SizeBytes As Double) As String
    Dim As Double s = SizeBytes
    If s > 1023 Then
        s = s / 1024.0                  '' KB
        If s > 1023 Then
            s = s / 1024.0              '' MB
            If s > 1023 Then
                s = s / 1024.0          '' GB
                If s > 1023 Then
                    s = s / 1024.0      '' TB
                    Return PadLeft(OneDecimal(s), 5) & " TB"
                Else
                    Return PadLeft(OneDecimal(s), 5) & " GB"
                End If
            Else
                Return PadLeft(OneDecimal(s), 5) & " MB"
            End If
        Else
            Return PadLeft(OneDecimal(s), 5) & " KB"
        End If
    Else
        Return PadLeft(Str(Int(s)), 5) & " B "
    End If
End Function


Function ProcessFiles(ByRef ci As typeConsoleInfo, ByRef si As typeSearchInfo) As Integer
    Dim As WIN32_FIND_DATAA FindData
    Dim As HANDLE SearchHandle
    Dim As Integer FileCount = 0
    Dim As Short   LineCount = 3        '' Pre-load with number of lines in the header.
    Dim As Double  TotalSize = 0.0
    Dim As UShort  Attributes
    Dim As CONSOLE_SCREEN_BUFFER_INFO csbi

    SearchHandle = FindFirstFileA(StrPtr(si.Path), @FindData)

    If SearchHandle = INVALID_HANDLE_VALUE Then
        Print
        Print "No file or folder found."
        RestoreConsole(ci)
        Return -1
    End If

    '' --- Collect every matching entry before printing anything. ---
    Dim As typeFileEntry Entries()
    Dim As Integer Count = 0
    Do
        ReDim Preserve Entries(Count)
        With Entries(Count)
            .IsDir     = ((FindData.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY) <> 0)
            .IsHidden  = ((FindData.dwFileAttributes And FILE_ATTRIBUTE_HIDDEN) <> 0)
            .FileName  = FindData.cFileName
            .Ext       = Iif(.IsDir, "", ExtractFileExt(.FileName))
            .Size      = FindData.nFileSizeHigh * 4294967296.0 + FindData.nFileSizeLow
            .WriteTime = (CULngInt(FindData.ftLastWriteTime.dwHighDateTime) Shl 32) _
                         Or FindData.ftLastWriteTime.dwLowDateTime
        End With
        Count += 1
    Loop While FindNextFileA(SearchHandle, @FindData)
    FindClose(SearchHandle)

    '' --- Sort according to the requested key. ---
    SortFileEntries(Entries(), Count, si.SortBy)

    '' --- Work out the grid geometry. ---
    Dim As Integer Cols = si.Columns
    If Cols < 1 Then Cols = 1
    Dim As Integer CellWidth = (ci.Width - 1) \ Cols    '' -1 so a full row never hits the right edge (avoids auto-wrap + blank line)
    Dim As Integer NameWidth = CellWidth - 10       '' 8 size/<dir> field + 2 "|<space>" separator
    If NameWidth < 1 Then NameWidth = 1
    Dim As Integer Rows = (Count + Cols - 1) \ Cols

    '' Balanced column-major heights: the first FullCols columns hold Rows
    '' entries, the rest hold Rows-1, so every requested column is filled and
    '' no trailing column is left blank.
    Dim As Integer FullCols = Count - Cols * (Rows - 1)

    '' --- Display the sorted listing as a grid. ---
    Dim As Integer r, c, idx, ColStart, ColHeight
    Dim As String  NameCell
    For r = 0 To Rows - 1
        '' Pause if the console screen is full.
        LineCount += 1
        If LineCount = ci.Height Then
            LineCount = 0
            GetConsoleScreenBufferInfo(ci.ConsoleHandle, @csbi)
            Attributes = csbi.wAttributes
            ColorFG(ci, GRAY)
            Shell("pause")
            '' Restore colour
            SetConsoleTextAttribute(ci.ConsoleHandle, Attributes)
        End If

        For c = 0 To Cols - 1
            '' Column-major (top-to-bottom) by default; row-major with /L.
            Dim As Integer CellEmpty = 0
            If si.LeftToRight Then
                idx = r * Cols + c
                If idx >= Count Then CellEmpty = -1
            Else
                If c < FullCols Then
                    ColHeight = Rows     : ColStart = c * Rows
                Else
                    ColHeight = Rows - 1 : ColStart = FullCols * Rows + (c - FullCols) * (Rows - 1)
                End If
                If r >= ColHeight Then CellEmpty = -1 Else idx = ColStart + r
            End If

            If CellEmpty Then
                '' Empty cell: blank the body but keep the column rule going so
                '' the vertical lines in short columns don't get gaps.
                Print Space(NameWidth + 8);
            Else
                With Entries(idx)
                    If .IsDir Then
                        ColorFG(ci, LIGHT_PURPLE)
                    Else
                        FileCount += 1
                        ColorFG(ci, ColorForExt(.Ext))
                    End If

                    '' Dark red for hidden files.
                    If .IsHidden Then ColorFG(ci, RED)

                    '' File name, fitted (extension-preserving) and padded to the cell.
                    NameCell = FitName(.FileName, NameWidth)
                    Print PadRight(NameCell, NameWidth);

                    If .IsDir Then
                        Print "  <dir> ";
                    Else
                        TotalSize = TotalSize + .Size
                        ColorFG(ci, GRAY)
                        Print SizeField(.Size);
                    End If
                End With
            End If

            '' Column separator between cells, but not after the last column
            '' (no vertical line down the far-right edge).
            If c < Cols - 1 Then
                ColorFG(ci, AQUA)
                Print Chr(VBAR_CHAR) & " ";
            End If
        Next c

        Print                                  '' end of row
    Next r

    '' Hand the tallies to the footer (every entry is either a file or a dir).
    si.FileCount = FileCount
    si.DirCount  = Count - FileCount

    Return FileCount
End Function


Sub RestoreConsole(ByRef ci As typeConsoleInfo)
    SetConsoleTextAttribute(ci.ConsoleHandle, ci.ColorsOriginal)
End Sub
'#End Region


'#Region "Main program"
'' === main program ==========================================================
Dim ConsoleInfo As typeConsoleInfo
Dim SearchInfo  As typeSearchInfo

'' Initialise records to known defaults.
SearchInfo.SortBy                   = SORT_BY_NAME
SearchInfo.Drive                      = "C"
SearchInfo.Path                        = ""
SearchInfo.Pattern                   = ""
SearchInfo.ShouldClearScreen = 0
SearchInfo.Columns                  = 2
SearchInfo.LeftToRight           = 0

GetypeConsoleInfo(ConsoleInfo)
BuildInitialSearchString(SearchInfo)
ProcessCommandLine(SearchInfo)

If SearchInfo.ShouldClearScreen Then
    Shell("cls")
End If

If Left(SearchInfo.Pattern, 2) = "/h" Then
    DisplayHelp(ConsoleInfo)
    RestoreConsole(ConsoleInfo)
    End 0
End If

DisplayHeader(ConsoleInfo, SearchInfo)
FixupPath(SearchInfo)
ProcessFiles(ConsoleInfo, SearchInfo)
DisplayFooter(ConsoleInfo, SearchInfo)

RestoreConsole(ConsoleInfo)
End 0
'#End Region
