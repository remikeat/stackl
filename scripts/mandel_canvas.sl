/for {
    /proc exch def
    /end exch def
    /start exch def

    { start end < }
    {
        proc
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

/printdensity {
    /res exch def
    /y exch def
    /x exch def
    /d exch def

    0 0.5 d * 0 set_fill_style
    x res * y res * res res rectangle
} def

/mandelconverge {
    /cimag exch def
    /creal exch def

    0 0 0
    0 500 {
        /iters exch def
        /imag exch def
        /real exch def
        /r2 real real * def
        /i2 imag imag * def
        { 4 r2 i2 + < }
        { }
        {
            /iters iters 1 + def
            /x r2 i2 - creal + def
            /y 2 real * imag * cimag + def
        } if
        x
        y
        iters
    } for
    /iters exch def
    /imag exch def
    /real exch def
    iters
} def

/mandel {
    /res exch def
    /y_nb_steps exch def
    /x_nb_steps exch def
    /y_step exch def
    /x_step exch def
    /y_start exch def
    /x_start exch def

    0
    0 y_nb_steps {
        /iy exch def
        /y iy y_step * y_start + def
        0
        0 x_nb_steps {
            /ix exch def
            /x ix x_step * x_start + def
            /d x y mandelconverge def
            d ix iy res printdensity
            ix 1 +
        } for
        /ix exch def
        iy 1 +
    } for
    /iy exch def
} def

-2.0 -2.0 0.01 0.01 400 400 2 mandel
