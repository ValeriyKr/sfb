#!/bin/sh
#
# Made by Valeriy Kireev <valeriykireev@gmail.com>, 2016
#
# sfb is licensed under the terms of the MIT license.
# See LICENSE for details.
#
# sfb -- Flappy Bird clone written in sed.
#
# Implemented:
#  * Collisions;
#  * Level generation;
#  * Column's movement;
#  * User's input handling;
#  * Score counting;
#  * Colorized output;
#  * Bird's movement;
#  * Color scheme choosing.
#
# Not implemented:
#  * Level randomization;
#  * Background music (?)
#
# Move up with `k` button. No more movements implemented. It's original way,
#
# Problems:
#  * Colorized version lags on Solaris (network connection?)
#    Fixed with double buffering.
#

colorize="cat"
if [ $# -ne 1 ]
then
    printf  "\tUsage: %s <none|light|full>\n\n" "$0"
    printf  "\tArgument sets colorizing model. If game lags with full\n"
    printf  "\tcolorizing, try to set it lighter.\n"
    exit
fi

if [ "$1" = "light" ]
then
    colorize=colorize_light
elif [ "$1" = "full" ]
then
    colorize=colorize_full
fi

timeout=5

field="[======================================]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[......................................]
[......................................]
[......................................]
[...........0..........................]
[......................................]
[......................................]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[======================================]
Score: 0"

esc=$(printf '\033')
Default=$esc'[0m'           # Text Reset
Black=$esc'\[0;30m'         # Black
Red=$esc'\[0;31m'           # Red
Green=$esc'\[0;32m'         # Green
Yellow=$esc'\[0;33m'        # Yellow
Blue=$esc'[0;34m'           # Blue
Purple=$esc'[0;35m'         # Purple
Cyan=$esc'[0;36m'           # Cyan
White=$esc'[1;37m'          # White
BBlack=$esc'\[0;40m'        # Black
BRed=$esc'\[0;41m'          # Red
BGreen=$esc'\[0;42m'        # Green
BYellow=$esc'\[0;43m'       # Yellow
BBlue=$esc'[0;44m'          # Blue
BPurple=$esc'[0;45m'        # Purple
BCyan=$esc'[0;46m'          # Cyan
BWhite=$esc'[1;47m'         # White
BirdSkyB=$esc'[91;46m'
BirdSkyF=$esc'[1;93;46m'
BirdGrsB=$esc'[1;91;42m'
BirdGrsF=$esc'[93;42m'
Sun=$esc'[0;93;103m'

colorize_light() {
    # Read all lines for a double buffering.
    buffer="$buffer$(cat)"
    buffer=$(printf "%s\n" "$buffer" | sed \
    "
        2,19 {
            s/^\(\[.*\)\(.[0-9]\)\(.*\)/\1${Green}*>${Default}\3/

            t rst
            : rst
            s/^\(\[.*\)\(=\{8\}\)\(.*\)$/\1${Yellow}\2${Default}\3/
            tn

            s/\([^=]\)\(=\{7\}\)\(\]\)$/\1${Red}\2${Default}\3/
            tn
            s/\([^=]\)\(=\{6\}\)\(\]\)$/\1${Green}\2${Default}\3/
            tn
            s/\([^=]\)\(=\{5\}\)\(\]\)$/\1${White}\2${Default}\3/
            tn
            s/\([^=]\)\(=\{4\}\)\(\]\)$/\1${Purple}\2${Default}\3/
            tn
            s/\([^=]\)\(=\{3\}\)\(\]\)$/\1${Cyan}\2${Default}\3/
            tn
            s/\([^=]\)\(=\{2\}\)\(\]\)$/\1${Blue}\2${Default}\3/
            tn
            s/\([^=]\)\(=\{1\}\)\(\]\)$/\1${Black}\2${Default}\3/
            :n
            s/^\(\[\)\(=\{7\}\)\(.*\)$/\1${Red}\2${Default}\3/
            te
            s/^\(\[\)\(=\{6\}\)\(.*\)$/\1${Green}\2${Default}\3/
            te
            s/^\(\[\)\(=\{5\}\)\(.*\)$/\1${White}\2${Default}\3/
            te
            s/^\(\[\)\(=\{4\}\)\(.*\)$/\1${Purple}\2${Default}\3/
            te
            s/^\(\[\)\(=\{3\}\)\(.*\)$/\1${Cyan}\2${Default}\3/
            te
            s/^\(\[\)\(=\{2\}\)\(.*\)$/\1${Blue}\2${Default}\3/
            te
            s/^\(\[\)\(=\{1\}\)\(.*\)$/\1${Black}\2${Default}\3/
            :e
        }
        21 {
            s/^\(.* \)\([0-9]\)$/${White}\1${Green}\2${Default}/
            ty
            s/^\(.* \)\([12][0-9]\)$/${White}\1${Yellow}\2${Default}/
            s/^\(.* \)\([0-9]{2,}\)$/${White}\1${Red}\2${Default}/
            :y
        }
        y/./ /
    ")
    printf "%s\n" "$buffer"
}

colorize_full() {
    # Read all lines for a double buffering.
    buffer="$buffer$(cat)"
    buffer=$(printf "%s\n" "$buffer" | sed \
    "
        2,19 {
            3 {
                s/\.\(\...\]\)/${Sun}*${Default}\1/
            }
            4 {
                s/\...\(\..\]\)/${Sun}***${Default}\1/
            }
            5 {
                s/\.\(\...\]\)/${Sun}*${Default}\1/
            }

            2,9 {
                s/^\(\[.*\)\(.[.=][0-9]\)\(.*\)/\1${BirdSkyB}(*${BirdSkyF}>${Default}\3/
                s/\./${BCyan}.${Default}/g
            }
            10,19 {
                s/^\(\[.*\)\(..[0-9]\)\(.*\)/\1${BirdGrsB}(*${BirdGrsF}>${Default}\3/
                s/\./${BGreen}.${Default}/g
            }

            s/^\(\[.*\)\(=\{8\}\)\(.*\)$/\1${BYellow}\2${Default}\3/

            s/\([^=]\)\(=\{7\}\)\(\]\)$/\1${BRed}\2${Default}\3/
            s/\([^=]\)\(=\{6\}\)\(\]\)$/\1${BGreen}\2${Default}\3/
            s/\([^=]\)\(=\{5\}\)\(\]\)$/\1${BWhite}\2${Default}\3/
            s/\([^=]\)\(=\{4\}\)\(\]\)$/\1${BPurple}\2${Default}\3/
            s/\([^=]\)\(=\{3\}\)\(\]\)$/\1${BCyan}\2${Default}\3/
            s/\([^=]\)\(=\{2\}\)\(\]\)$/\1${BBlue}\2${Default}\3/
            s/\([^=]\)\(=\{1\}\)\(\]\)$/\1${BBlack}\2${Default}\3/
            s/^\(\[\)\(=\{7\}\)\(.*\)$/\1${BRed}\2${Default}\3/
            s/^\(\[\)\(=\{6\}\)\(.*\)$/\1${BGreen}\2${Default}\3/
            s/^\(\[\)\(=\{5\}\)\(.*\)$/\1${BWhite}\2${Default}\3/
            s/^\(\[\)\(=\{4\}\)\(.*\)$/\1${BPurple}\2${Default}\3/
            s/^\(\[\)\(=\{3\}\)\(.*\)$/\1${BCyan}\2${Default}\3/
            s/^\(\[\)\(=\{2\}\)\(.*\)$/\1${BBlue}\2${Default}\3/
            s/^\(\[\)\(=\{1\}\)\(.*\)$/\1${BBlack}\2${Default}\3/
            y/=/ /
        }
        21 {
            s/^\(.* \)\([0-9]\)$/${White}\1${Green}\2${Default}/
            s/^\(.* \)\([12][0-9]\)$/${White}\1${Yellow}\2${Default}/
            s/^\(.* \)\([0-9]\{2,\}\)$/${White}\1${Red}\2${Default}/
        }
        #s/\*\./${Sun}*.${Default}/
        y/./ /
    ")
    printf "%s\n" "$buffer"
}

clear
running=1
while [ 1 -eq $running ]
do
    tput clear
    printf "%s\n" "$field" | $colorize
    running=$(printf "%s\n" "$field" | sed -n \
    '
      # Collisions
      : begin
      /^\[.\{11\}[.=]=/ {
          N
          /\n\[[=.]\{11\}[1-9]/ b fail
          s/^.*\n\(.*\)$/\1/
          t begin
      }
      /^\[[=.]\{11\}[0-9]=/ b fail
      /^\[[=.]\{11\}0/ {
          N
          s/\n\[.\{12\}=/&/
          t fail
      }
      b not_fail
      : fail
      s/^.*$/0/p
      q
      : not_fail
      $ s/^.*$/1/p
    ')

    field=$(printf "%s\n" "$field" | sed \
    '
      # Bird flying
      /^\[.\{11\}0/ {
          : falling
          s/0/./
          N
          s/\(\n\[.\{11\}\)\./\10/
          :n
          N
          $ b
          bn
      }

      /^\[.\{12\}/ {
          : next
          N
          /\n\[[.=]\{12\}/ {
              h
              s/^\(.*\)\n.*$/\1/
              p
              x
              s/^.*\n\(.*\)/\1/
              b next
          }
          /\n\[[.=]\{11\}0/ {
              h
              s/^\(.*\)\n.*$/\1/
              p
              x
              s/^.*\n\(.*\)/\1/
              b falling
          }
          /\n\[[.=]\{11\}[1-9]/ {
              s/^\(\[[.=]\{11\}\).\(.*\)\([1-9]\)/\1\3\2./
          }
      }
    ')

    field=$(printf "%s\n" "$field" | sed \
    '
      # Columns
      /^\[/ {
          s/\.\(=\{1,7\}\]\)$/=\1/
          t border
          s/\.\(==*\)\([.0-9]\)/\1.\2/
          s/\.\(==*\)\]/\1.]/
          : border
          s/^\[=\./[../
          s/^\(\[=\{1,7\}\)=\([^=].*\)/\1.\2/
      }
      # Generation of new columns
      2,7 {
          /^\[=\{6\}.*\]/ s/\.\]/=]/
      }
      14,19 {
          /^\[=\{6\}.*\]/ s/\.\]/=]/
      }
      # Bird
      /^\[[.=]*[1-9].*/ {
          y/123456789/012345678/
      }
      # Score
      19{
          /^\[[.]\{3\}=/! b inc_end
          N
          N
          t inc_9
          : inc_9
          s/9\(x*\)$/x\1/
          t inc_9
          s/ \(x*\)$/ 1\1/; t inc_fin
          s/0\(x*\)$/1\1/; t inc_fin
          s/1\(x*\)$/2\1/; t inc_fin
          s/2\(x*\)$/3\1/; t inc_fin
          s/3\(x*\)$/4\1/; t inc_fin
          s/4\(x*\)$/5\1/; t inc_fin
          s/5\(x*\)$/6\1/; t inc_fin
          s/6\(x*\)$/7\1/; t inc_fin
          s/7\(x*\)$/8\1/; t inc_fin
          s/8\(x*\)$/9\1/; t inc_fin
          : inc_fin
          s/x/0/;
          t inc_fin
      }
      : inc_end
    ')

    old_stty="$(stty -g)"
    stty -icanon raw -echo min 0 time "$timeout" ignbrk -brkint -ixon isig

    read -r key

    # shellcheck disable=SC2086
    stty $old_stty

    field=$(printf "%s\n%s\n" "$key" "$field" | sed \
    '
      # Checks "k" is pressed and sets bird"s direction to top
      1 {
          /k/! b print_all
          h
          N
          s/^.*\n\(.*\)$/\1/
      }
      2,$ {
          x
          /k/! bn
          x
          s/^\(\[.\{11\}\)[0-9]/\15/
          b
          :n
          x
      }
      : print_all
      1 {
          N
          s/^.*\n\(.*\)$/\1/
      }
    ')
done
echo "Game Over"
