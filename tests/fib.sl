/fib {
    /n exch def

    { n 1 < }
    { 0 }
    {
        { n 2 < }
        { 1 }
        {
            n 1 -
            fib
            n 2 -
            fib
            +
        }
        if
    }
    if
} def

10 fib puts
