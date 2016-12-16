# sfb
`sfb` -- Flappy Bird clone written in GNU sed.

![screenshot](https://raw.githubusercontent.com/ValeriyKr/sfb/master/screenshot.png)

Implemented:
 * Collisions;
 * Level generation;
 * Columns' movement;
 * User's input handling;
 * Score count;
 * Colorful output;
 * Choice of the color scheme;
 * Bird's movement.

Not implemented:
 * Level randomization;
 * Background music (?)

---
### How to play
```
$ git clone https://github.com/ValeriyKr/sfb.git
$ cd sfb
$ ./sfb.sh
```
Move up with `k` button. No more movements implemented. It's the original way,

There are three color schemes, `none`, `light` and `full`.
You should choose one when you start playing by passing it as a command-line argument.
 * `none` is internal representation of field. It's ugly.
 * `light` can be used if `full` is too bright for you or if it lags.
   I was experiencing delays in remote system and used this.
 * `full` is the prettiest.
   It is recommended for default playing.

---
Problems:
 * `read` on Solaris can't take floating-point timeout (-t) argument.
   Setting it to 1 second makes game slowly.
 * On Linux you have to put `gsed` binary (or link to GNU sed) in $PATH.

   Fixed.
 * Colorized version lags on Solaris (network connection?)

   Fixed with double buffering.
