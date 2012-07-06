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


SRPMS=/SRPMS

if [ -f $MYDIR/local.conf ]
then
    . $MYDIR/local.conf
fi

rpmi()
{
    rf=
    for r in $SRPMS/$1-*.src.rpm
    do
	case $r in
	    $SRPMS/$1-*-*-*) ;;
	    $SRPMS/$1-*-*.src.rpm) rf=$r ;;
	esac
    done
    if [ x"$rf" = x"" ]
    then
	echo $1: src RPM not found
	exit 1
    fi
    # HOME set by higher level script
    (set -x; rpm -i $rf)
}

rpmb()
{
    cd $HOME/rpmbuild/SPECS
    (set -x; rpmbuild --nodeps "$@".spec)
}

rpminst()
{
    cd $HOME/rpmbuild/RPMS

    for i in "$@"
    do
	rf=
	for r in */$i-*.rpm
	do
	    case $r in
		*/$i-*-*-*) ;;
		*/$i-*-*.rpm)
		    rf=$r
		    (set -x; rpm -i --nodeps $r)
		    ;;
	    esac
	done
	if [ x"$rf" = x"" ]
	then
	    echo $1: RPM not found
	    exit 1
	fi
        # HOME set by higher level script
    done
}

rpma()
{
    rpmi "$1"
    rpmb -bb "$1"
    rpminst "$1"
}
