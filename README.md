# Stackl

This is a stack machine based language

It is the ocaml version of https://github.com/msakuta/rustack

You can try it online at https://stackl.remikeat.com/

# Results

![koch](https://github.com/remikeat/stackl/blob/master/misc/koch.png?raw=true)

The image above was produced by below script

```
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
```

# How to build

```
dune build stackl.exe
```

or

```
make
```

# How to run

```
cat scripts/koch.sl | ./_build/default/stackl.exe
```

# How to quit

Press q
