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
    /scale exch def
    /res exch def
    /y exch def
    /x exch def
    /d exch def

    0 scale d * 0 set_fill_style
    x res * y res * res res rectangle
} def

/mandelconverge {
    /max_iter exch def
    /cy exch def
    /cx exch def

    /mandeliter {
        /y exch def
        /x exch def
        /i exch def
        /x2 x x * def
        /y2 y y * def
        { i max_iter < }
        {
            { 4 x2 y2 + < }
            {
                i
            }
            {
                /new_x x2 y2 - cx + def
                /new_y 2 x * y * cy + def
                i 1 + new_x new_y mandeliter
            } if
        }
        {
            i
        } if
    } def
    0 0 0 mandeliter
} def

/mandel {
    /max_iter exch def
    /res exch def
    /y_nb_steps exch def
    /x_nb_steps exch def
    /y_step exch def
    /x_step exch def
    /y_start exch def
    /x_start exch def

    /loop_y {
        /iy exch def
        { iy y_nb_steps < }
        {
            /y iy y_step * y_start + def
            /loop_x {
                /ix exch def
                { ix x_nb_steps < }
                {
                    /x ix x_step * x_start + def
                    /d x y max_iter mandelconverge def
                    { d max_iter < }
                    { 0 ix iy res 1 printdensity }
                    { 255 ix iy res 1 printdensity }
                    if
                    ix 1 + loop_x
                }
                {

                } if
            } def
            0 loop_x
            iy 1 + loop_y
        }
        {

        } if
    } def
    0 loop_y
} def

-1.5 -1.0 0.01 0.01 200 200 3 100 mandel
