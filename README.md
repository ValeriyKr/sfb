# sfb
`sfb` -- Flappy Bird clone written in GNU sed.

Implemented:
 * Collisions;
 * Level generation;
 * Column's movement;
 * User's input handling;
 * Score counting;
 * Colorized output;
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
Move up with `k` button. No more movements implemented. It's original way,

---
Problems:
 * `read` on Solaris can't take floating-point timeout (-t) argument.
   Setting it to 1 second makes game slowly.
 * On Linux you have to put `gsed` binary (or link to GNU sed) in $PATH.

   Fixed.
 * Colorized version lags on Solaris (network connection?)

   Fixed with double buffering.
