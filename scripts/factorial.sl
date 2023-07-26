/factorial_int {
    /acc exch def
    /n exch def

    { n 2 < }
    { acc }
    {
        n 1 -
        acc n *
        factorial_int
    }
    if
} def

/factorial { 1 factorial_int } def

10 factorial puts
