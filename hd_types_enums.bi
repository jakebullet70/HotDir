'' HotDIR (clone) - Public Domain
''
'' factored out of hd.bas.


Enum enumSortBy
    SORT_BY_NAME
    SORT_BY_EXTENSION
    SORT_BY_DATE
    SORT_BY_SIZE
End Enum

Type typeConsoleInfo
    ConsoleHandle  As HANDLE
    Colors         As UShort
    ColorsOriginal As UShort
    Width          As Integer
    Height         As Integer
End Type

Type typeSearchInfo
    SortBy            As enumSortBy
    Drive             As String        '' single character
    Path              As String
    Pattern           As String
    ShouldClearScreen As Integer
    Columns           As Integer       '' entries laid out per row (1 = single column)
    LeftToRight       As Integer       '' -1 = row-major (/L), 0 = column-major (top-to-bottom)
End Type

'' One enumerated directory entry, captured up-front so the whole listing can
'' be sorted before anything is printed.
Type typeFileEntry
    FileName  As String
    Ext       As String        '' lower-cased, leading dot ("" for folders)
    IsDir     As Integer
    IsHidden  As Integer
    Size      As Double
    WriteTime As ULongInt       '' FILETIME, packed hi:lo for comparison
End Type
