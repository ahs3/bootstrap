#!/bin/bash

mkdirp()
{
    test -d $1 || mkdir -p $1
}

go()
{
  "$0" "$@"
}

mcd()
{
    test -d $1 || mkdir -p $1
    cd $1
}

notparallel()
{
    echo .NOTPARALLEL: >> Makefile
}

if [ -f $MYDIR/local.conf ]
then
    . $MYDIR/local.conf
fi
