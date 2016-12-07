#!/usr/bin/env bash
#
# Made by Valeriy Kireev <valeriykireev@gmail.com>, 2016
#
# Use and modify code freely.
# Leave my name here, please.
#
# sfb -- Flappy Bird clone written in GNU sed.
# 
# Implemented:
#  * Collisions;
#  * Level generation;
#  * Column's movement;
#  * User's input handling;
#  * Score counting;
#  * Colorized output;
#  * Bird's movement.
#
# Not implemented:
#  * Level randomization;
#  * Background music (?)
# 
# Move up with `k` button. No more movements implemented. It's original way,
#
# Problems:
#  * `read` on Solaris can't take floating-point timeout (-t) argument. 
#    Setting it to 1 second makes game slowly.
#  * On Linux you have to put `gsed` binary (or link to GNU sed) in $PATH.
#    Fixed.
#  * Colorized version lags on Solaris (network connection?)
#    Fixed with double buffering.
#

export PATH=.:"$PATH"
which gsed 2>&- 1>/dev/null
status=$?
if [ $status -ne 0 ]
then
    ln -s `which sed` ./gsed
fi

gsed -r '' /dev/null
status=$?
if [ $status -ne 0 ]
then
    echo "Your 'sed' implementation isn't compatible with GNU sed well."
    exit 1
fi

timeout=0.5
status=`read -s -t 0.1 -n1 key 2>&1`
if [ "$status" != '' ]
then
    timeout=1
    echo "Your 'read' doesn't support floating-point timeout."
    echo "It will be set to '1'"
    echo "Game will be slowly"
    sleep 3
fi

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

colorize() {
    esc=$(printf '\033')
    Default=$esc'[0m'          # Text Reset
    Black=$esc'\[0;30m'        # Black
    Red=$esc'\[0;31m'          # Red
    Green=$esc'\[0;32m'        # Green
    Yellow=$esc'\[0;33m'       # Yellow
    Blue=$esc'[0;34m'          # Blue
    Purple=$esc'[0;35m'        # Purple
    Cyan=$esc'[0;36m'          # Cyan
    White=$esc'[1;37m'         # White
    while read line
    do
        buffer="$buffer$line
"
    done
    buffer=`echo "$buffer" | gsed -r \
    "
        2,19 {
            s/^(\[.*)([0-9])(.*)/\1${Green}\2${Default}\3/

            s/^(\[.*)(={8})(.*)$/\1${Yellow}\2${Default}\3/

            s/(\.)(={7})(\])$/\1${Red}\2${Default}\3/
            s/(\.)(={6})(\])$/\1${Green}\2${Default}\3/
            s/(\.)(={5})(\])$/\1${White}\2${Default}\3/
            s/(\.)(={4})(\])$/\1${Purple}\2${Default}\3/
            s/(\.)(={3})(\])$/\1${Cyan}\2${Default}\3/
            s/(\.)(={2})(\])$/\1${Blue}\2${Default}\3/
            s/(\.)(={1})(\])$/\1${Black}\2${Default}\3/
            s/^(\[)(={7})(.*)$/\1${Red}\2${Default}\3/
            s/^(\[)(={6})(.*)$/\1${Green}\2${Default}\3/
            s/^(\[)(={5})(.*)$/\1${White}\2${Default}\3/
            s/^(\[)(={4})(.*)$/\1${Purple}\2${Default}\3/
            s/^(\[)(={3})(.*)$/\1${Cyan}\2${Default}\3/
            s/^(\[)(={2})(.*)$/\1${Blue}\2${Default}\3/
            s/^(\[)(={1})(.*)$/\1${Black}\2${Default}\3/
        }
        21 {
            s/^(.* )([0-9])$/${White}\1${Green}\2${Default}/
            s/^(.* )([12][0-9])$/${White}\1${Yellow}\2${Default}/
            s/^(.* )([0-9]{2,})$/${White}\1${Red}\2${Default}/
        }
        :s
        s/\./ /
        ts
    "`
    echo "$buffer"
}

running=1
while [ 1 -eq $running ]
do
    clear
    echo "${field}" | colorize
    #echo "$field"
    running=`echo "$field" | gsed -nr \
    '
        # Collisions
        : begin
        /^\[.{11}[.=]=/ {
            N
            /\n\[[=.]{11}[1-9]/ b fail
            s/^.*\n(.*)$/\1/
            t begin
        }
        /^\[[=.]{11}[0-9]=/ b fail
        /^\[[=.]{11}0/ {
            N
            s/\n.{12}=/&/
            t fail
        }
        b not_fail
        : fail
        s/^.*$/0/p
        q
        : not_fail
        $ s/^.*$/1/p
    '`

    field=`echo "$field" | gsed -r \
    '
        # Bird flying
        /^\[.{11}0/ {
            : falling
            s/0/./
            N
            s/(\n\[.{11})\./\10/
            :n
            N
            $ b
            bn
            b
        }

        /^\[.{12}/ {
            : next
            N
            /\n\[[.=]{12}/ {
                h
                s/^(.*)\n.*$/\1/
                p
                x
                s/^.*\n(.*)/\1/
                b next
            }
            /\n\[[.=]{11}0/ {
                h
                s/^(.*)\n.*$/\1/
                p
                x
                s/^.*\n(.*)/\1/
                b falling
            }
            /\n\[[.=]{11}[1-9]/ {
                s/^(\[[.=]{11})(.)(.*)([1-9])/\1\4\3\2/
            }
        }
    '`

    field=`echo "$field" | gsed -r \
    '
        /^\[/{
            s/\.(={1,7}\])$/=\1/
            t border
            s/\.(=+)([.1-9])/\1.\2/
            s/\.(=+)\]/\1.]/
            : border
            s/^\[=\./[../
            s/^(\[={1,7})=([^=].*)/\1.\2/
        }
        2,7 {
            /^\[={6}.*\]/ s/\.\]/=]/
        }
        14,19 {
            /^\[={6}.*\]/ s/\.\]/=]/
        }
        # Bird
        /^\[[.=]*[1-9].*/{
            y/123456789/012345678/
        }
        # Score
        19{
            /^\[[.]{3}=/! b inc_end
            N
            N
            t inc_9
            : inc_9
            s/9(x*)$/x\1/
            t inc_9
            s/ (x*)$/ 1\1/; t inc_fin
            s/0(x*)$/1\1/; t inc_fin
            s/1(x*)$/2\1/; t inc_fin
            s/2(x*)$/3\1/; t inc_fin
            s/3(x*)$/4\1/; t inc_fin
            s/4(x*)$/5\1/; t inc_fin
            s/5(x*)$/6\1/; t inc_fin
            s/6(x*)$/7\1/; t inc_fin
            s/7(x*)$/8\1/; t inc_fin
            s/8(x*)$/9\1/; t inc_fin
            : inc_fin
            s/x/0/;
            t inc_fin
        }
        : inc_end
    '`
    key=''
    # Timeout = 0.5 for Linux. s/0\.5/1/ for Solaris.
    read -s -t $timeout -n1 key
    field=`echo -e "${key}\n${field}" | gsed -r \
    '
        1 {
            /k/! b print_all
            h
            N
            s/^.*\n(.*)$/\1/
        }
        2,$ {
            x
            /k/! bn
            x
            s/^(\[.{11})[0-9]/\15/
            b
            :n
            x
        }
        : print_all
        1 {
            N
            s/^.*\n(.*)$/\1/
        }
    '`
done
echo "Game Over"
