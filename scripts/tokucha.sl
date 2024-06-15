/color { 0 0 0 } def
/scale 10 def

/min {
    /a exch def
    /b exch def
    { a b < } { a } { b } if
} def

/max {
    /a exch def
    /b exch def
    { a b < } { b } { a } if
} def

/rect {
    /x1 exch def
    /y1 exch def
    /x2 exch def
    /y2 exch def
    /mx { x1 x2 min } def
    /Mx { x1 x2 max } def
    /my { y1 y2 min } def
    /My { y1 y2 max } def

    begin_path
    my mx move_to
    my Mx line_to
    My Mx line_to
    My mx line_to
    my mx line_to
    stroke
} def

/fx1 { -1 scale * } def
/fx2 { -4 scale * } def
/fy1 { /n exch def 1.5 3. div 17.5 + n - scale * } def
/fy2 { /n exch def -1.5 3. div 17.5 + n - scale * } def

/gx1 { -2 scale * } def
/gx2 { -4 scale * } def
/gy1 { /n exch def 1. 4. div n + scale * } def
/gy2 { /n exch def -1. 4. div n + scale * } def

/px1 { /m exch def 0.5 m 2. div + scale * } def
/px2 { /m exch def -0.5 m 2. div + scale * } def
/py1 { /n exch def 0.5 n 2. div + scale * } def
/py2 { /n exch def -0.5 n 2. div + scale * } def

/qx1 { /m exch def 4. m 2. div + scale * } def
/qx2 { /m exch def -4. m 2. div + scale * } def
/qy1 { /n exch def 4. 8. div n 2. div + scale * } def
/qy2 { /n exch def -4. 8. div n 2. div + scale * } def

/white {
    /level exch def
    { level 29 < }
    {
        fx1 level fy1 fx2 level fy2 rect
        level 1 + white
    }
    { }
    if
} def

/black {
    /nb_elem exch def
    /n exch def
    color set_fill_style
    gx1 n gy1 gx2 n gy2 rect
    { 1 nb_elem < }
    {
        nb_elem 1 - black
    }
    { }
    if
} def

/notes {
    /nb_elem exch def
    /n exch def
    /m exch def
    color set_fill_style
    m px1 n py1 m px2 n py2 rect
    { 1 nb_elem < }
    {
        n nb_elem 1 - notes
    }
    { }
    if
} def

300 300 translate
1 white
16 15 13 12 11 9 8 6 5 4 2 1 -1 -2 -3 -5 -6 -8 -9 -10 20 black
5 9 13 5 3 notes
37 41 45 3 3 notes
/m 24 def
/n 1 def
color set_fill_style
m qx1 n qy1 m qx2 n qy2 rect
/m 56 def
/n -1 def
color set_fill_style
m qx1 n qy1 m qx2 n qy2 rect
