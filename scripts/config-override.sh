#!/bin/bash

MYDIR=${0%/*}

# Replacing all config.sub and config.guess files with our up-to-date versions
FILES=`find . -name config.sub -o -name config.guess`
for f in $FILES; do
  basename=`basename $f`
  dirname=`dirname $f`

  cp -af $MYDIR/${basename} $f
done
