/for {
    /proc exch def
    /end exch def
    /start exch def

    { start end < }
    {
        start proc
        start 1 + end /proc load for
    }
    { }
    if
} def

/rectangle {
    /h exch def
    /w exch def
    /y exch def
    /x exch def

    begin_path
    x y move_to
    x y h + line_to
    x w + y h + line_to
    x w + y line_to
    x y line_to
    stroke
} def

0 10 {
    dup
    25 * 127 0 set_fill_style
    30 * 10 +
    10
    20
    30
    rectangle
} for
