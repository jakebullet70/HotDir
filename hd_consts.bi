'' HotDIR (clone) - Public Domain
''
''  Compile-time constants for HotDIR, factored out of hd.bas.

#pragma once


'' Console colour attribute values (foreground), matching the original.
Const BLACK        = 0
Const BLUE         = 1
Const GREEN        = 2
Const AQUA         = 3
Const RED          = 4
Const PURPLE       = 5
Const YELLOW       = 6
Const WHITE        = 7
Const GRAY         = 8
Const LIGHT_BLUE   = 9
Const LIGHT_GREEN  = 10
Const LIGHT_AQUA   = 11
Const LIGHT_RED    = 12
Const LIGHT_PURPLE = 13
Const LIGHT_YELLOW = 14
Const BRIGHT_WHITE = 15

'' CP437 box-drawing bytes.
Const HLINE_CHAR = 196   '' horizontal line
Const VBAR_CHAR  = 179   '' vertical line
Const TDOWN_CHAR = 194   '' top junction (down tee) where a column rule begins
Const TUP_CHAR   = 193   '' bottom junction (up tee) where a column rule ends

'' File-extension -> colour categories (taken verbatim from the original).
'' Stored as space-delimited lists (leading + trailing space) so membership is
'' a simple InStr(" .ext ") test -- FB can't initialise var-len string arrays.
Const EXEC_EXTS    = " .exe .msi "
Const BATCH_EXTS   = " .bat .cmd .btm "
Const COM_EXTS     = " .com .msc "

Const SCRIPT_EXTS  = _
    " .bas .pas .js .jse .vbs .vbe .wsf" _
    & " .php .py .pl .rb .xsl .tcl .wsh "

Const DOC_EXTS     = _
    " .txt .doc .c .rtf .cc .asm .docx .xml .odt" _
    & " .fodt .ods .fods .odp .fodp .odg .fodg .odf .pub" _
    & " .ppt .ott .sxw .stw .docm .dotx .dotm .dot .wps" _
    & " .wpd .lwp .htm .html .xhtml .css .abw .zabw .cwk" _
    & " .pdb .mw .mcw .ots .sxc .stc .xls .xlsx .xlsm" _
    & " .xlt .xltx .xltm .pdf .ps .wdb .xlc .xlm .xlw" _
    & " .dif .dbf .wb2 .wk1 .wks .123 .pps .ouf .uop" _
    & " .sxi .sti .sxd .potm .potx .pptx .pptm .ppsx .key" _
    & " .wpg .dxf .blend .eps .pm .pm6 .pm65 .pmd .log" _
    & " .tex .pages .msg .csv .srt .3ds .3dm .max .indd" _
    & " .pct .xlr .chm .hlp .jsp .asp .aspx .csr .rss" _
    & " .h .a .cxx .hxx .xps .oxps .wb1 .wq1 .gnumeric" _
    & " .numbers .lotus .wk3 .wk4 .wk5 .wri .602 .hwp" _
    & " .lwp2 .mwd .sdw .vor .uot .text .md "

Const MEDIA_EXTS   = _
    " .mp3 .mpg .mpeg .jpg .jpeg .gif .png .tif .tiff" _
    & " .psd .xcf .svg .mp4 .mkv .avi .mov .pcx .wav" _
    & " .aif .aiff .emf .ico .xpm .jpe .wmf .lmb .bmp" _
    & " .tga .xbm .pnm .pbm .pgm .ff .ppm .mng .cur" _
    & " .ani .svgz .ai .flac .ogg .ogv .oga .asx .wm" _
    & " .wma .wmx .m3u .aac .asf .wmv .m2ts .m2t .qt" _
    & " .wtv .dvr-ms .m4v .mpe .m1v .mp2 .mpv2 .mod .vob" _
    & " .voc .wdp .raw .hdp .flv .mid .mpa .m4a .iff" _
    & " .3gp .3g2 .rm .ram .swf .pspimge .thm .yuv .divx" _
    & " .m4p .mts .pam .webp .webm .opus .heic .heif" _
    & " .dng .cr2 .nef .arw .orf .rw2 .jfif .apng .avif" _
    & " .mxf .ts .f4v .rmvb .mpg2 .amr "

Const ARCHIVE_EXTS = _
    " .7z .zip .gz .tar .bz2 .rar .arc .devpak .xz" _
    & " .lzma .iso .lz .lzo .rz .sz .z .arj .b1 .cab" _
    & " .cfs .dmg .ear .jar .lzh .lha .kgb .lzx .pea" _
    & " .partimg .pim .sda .sea .sfx .shk .sit .sitx .sqx" _
    & " .tgz .tbz2 .tlz .war .har .wim .xp3 .yz1 .zipx" _
    & " .zoo .zpaq .zz .ecc .par .par2 .img .hqx .hcx" _
    & " .hex .deb .rpm .mdf .cue .bin .apk .zst .lz4" _
    & " .br .cpio .rpa .alz .egg .uha .paq .s7z .ace" _
    & " .afa .apz .ba .bh .cdx .cpt .dar .dd .dgc" _
    & " .gca .ha .ice .kz .lzip .nupkg .pak .pkg .pup" _
    & " .tbz .txz .uue .vsix .whl .xapk "
