/min {
    /a exch def
    /b exch def
    { a b < } {a} {b} if
} def

/max {
    /a exch def
    /b exch def
    { a b < } {b} {a} if
} def

/line {
    /x1 exch def
    /y1 exch def
    /x2 exch def
    /y2 exch def

    begin_path
    x1 y1 move_to
    x2 y2 line_to
    stroke
} def

/rect {
    /x1 exch def
    /y1 exch def
    /x2 exch def
    /y2 exch def
    /mx {x1 x2 min} def
    /Mx {x1 x2 max} def
    /my {y1 y2 min} def
    /My {y1 y2 max} def

    mx my mx My line
    mx My Mx My line
    Mx My Mx my line
    Mx my mx my line
} def

/fx1 -10 def
/fx2 -40 def
/fy1 {/n exch def 15 3 div 175 + 10 n * -} def
/fy2 {/n exch def -15 3 div 175 + 10 n * -} def

/gx1 -20 def
/gx2 -40 def
/gy1 {/n exch def 10 4 div 10 n * +} def
/gy2 {/n exch def -10 4 div 10 n * +} def

/px1 {/m exch def 5 10 m * 2 div +} def
/px2 {/m exch def -5 10 m * 2 div +} def
/py1 {/n exch def 5 10 n * 2 div +} def
/py2 {/n exch def -5 10 n * 2 div +} def

/qx1 {/m exch def 40 10 m * 2 div +} def
/qx2 {/m exch def -40 10 m * 2 div +} def
/qy1 {/n exch def 40 8 div 10 n * 2 div +} def
/qy2 {/n exch def -40 8 div 10 n * 2 div +} def

/white {
    /level exch def
    { level 29 < }
    {
        fx1 level fy1 fx2 level fy2 rect
        level 1 + white
    }
    {}
    if
} def

/black {
    /nb_elem exch def
    /n exch def
    gx1 n gy1 gx2 n gy2 rect
    { 1 nb_elem < }
    {
        nb_elem 1 - black
    }
    {}
    if
} def

/notes {
    /nb_elem exch def
    /n exch def
    /m exch def
    m px1 n py1 m px2 n py2 rect
    { 1 nb_elem < }
    {
        n nb_elem 1 - notes
    }
    {}
    if
} def

300 300 translate
1 white
16 15 13 12 11 9 8 6 5 4 2 1 -1 -2 -3 -5 -6 -8 -9 -10 20 black
5 9 13 5 3 notes
37 41 45 3 3 notes
/m 24 def
/n 1 def
m qx1 n qy1 m qx2 n qy2 rect
/m 56 def
/n -1 def
m qx1 n qy1 m qx2 n qy2 rect
