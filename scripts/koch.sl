/koch {
    /level exch def
    /scale exch def

    { level 5 < }
    {
        save
        scale 3. div level 1 + koch
        scale 100 * 0 translate
        pi -3. div rotate
        scale 3. div level 1 + koch
        scale 100 * 0 translate
        pi 2. * 3. div rotate
        scale 3. div level 1 + koch
        scale 100 * 0 translate
        pi -3. div rotate
        scale 3. div level 1 + koch
        restore
    }
    {
        begin_path
        0 0 move_to
        scale 300 * 0 line_to
        stroke
    }
    if
} def
10 300 translate
2. 1 koch
