#!/bin/bash

# Date: April 2, 2014
# by Aldy Hernandez

# Attempt to fix any "-m elf64ppc" linker checks in configure and
# libtool.m4 files.
#
# This script is meant to run silently as part of rpm's %configure
# macro.  It either fixes the problem, or we silently ignore it, in
# which case it is up to the package maintainer to add support for
# ppc64le.

# Our two attempts at fixing the problem.
PATCH1=/tmp/$$.patch1
PATCH2=/tmp/$$.patch2

cleanup() {
    rm -f $PATCH1 $PATCH2
}

trap cleanup 0 1 2 3 4 5 6 7 8 9 11 13 14 15

# There are two variants in RHEL7 so far.  The first version, handled
# with $PATCH1, currently handles all but 3 packages.  The $PATCH2
# version handles the remnant.
#
cat > $PATCH1 <<EOF
--- configure.orig	2014-03-18 15:56:15.575070238 -0500
+++ configure	2014-03-18 16:05:50.877861163 -0500
@@ -7714,6 +7714,9 @@
 	  x86_64-*linux*)
 	    LD="\${LD-ld} -m elf_i386"
 	    ;;
+	  ppc64le-*linux*|powerpc64le-*linux*)
+	    LD="\${LD-ld} -m elf32lppclinux"
+	    ;;
 	  ppc64-*linux*|powerpc64-*linux*)
 	    LD="\${LD-ld} -m elf32ppclinux"
 	    ;;
@@ -7733,6 +7736,9 @@
 	  x86_64-*linux*)
 	    LD="\${LD-ld} -m elf_x86_64"
 	    ;;
+	  ppc*le-*linux*|powerpc*le-*linux*)
+	    LD="\${LD-ld} -m elf64lppc"
+	    ;;
 	  ppc*-*linux*|powerpc*-*linux*)
 	    LD="\${LD-ld} -m elf64ppc"
 	    ;;
EOF

cat > $PATCH2 <<EOF
--- configure.orig	2014-03-18 16:35:28.942799967 -0500
+++ configure	2014-03-18 16:34:35.608519090 -0500
@@ -3798,6 +3798,9 @@
         x86_64-*linux*)
           LD="\${LD-ld} -m elf_i386"
           ;;
+        ppc64le-*linux*)
+          LD="\${LD-ld} -m elf32lppclinux"
+          ;;
         ppc64-*linux*)
           LD="\${LD-ld} -m elf32ppclinux"
           ;;
@@ -3814,6 +3817,9 @@
         x86_64-*linux*)
           LD="\${LD-ld} -m elf_x86_64"
           ;;
+        ppc*le-*linux*|powerpc*le-*linux*)
+          LD="\${LD-ld} -m elf64lppc"
+          ;;
         ppc*-*linux*|powerpc*-*linux*)
           LD="\${LD-ld} -m elf64ppc"
           ;;
EOF


FILES=`find . -name configure -o -name libtool.m4`
for f in $FILES; do
    # Filter out candidates that already handle ppc64le.
    if grep -s -e '-m elf64lppc' $f >/dev/null; then
	continue
    fi

    # Filter out candidates that don't handle PPC.
    if ! grep -s -e '-m elf64ppc' $f >/dev/null; then
	continue
    fi

    echo "Broken -m elf64ppc use in $f should handle elf64lppc."
    echo "Attempting automatic fix."

    # Attempt to fix the offended file.
    basename=`basename $f`
    dirname=`dirname $f`
    for p in $PATCH1 $PATCH2; do
	# This is an all for nothing affair.  The patch either
	# applies entirely clean, or we don't even try.
	#
	# Tentatively try either patch cleanly, and if we succeed then
	# do it for real.
	pushd $dirname 2>&1 > /dev/null
	if [ $basename = libtool.m4 ]; then
	    sed s/configure/libtool.m4/ < $p | patch --dry-run -l -s 2>&1 >/dev/null
	else
	    patch --dry-run -l -s < $p 2>&1 > /dev/null
	fi
	if [ $? != 0 ]; then
	    # This approach didn't work, try the next one.
	    popd 2>&1 > /dev/null
	    continue
	fi

	# Seriously now...
	if [ $basename = libtool.m4 ]; then
	    sed s/configure/libtool.m4/ < $p | patch -l -s 2>&1 > /dev/null
	else
	    patch -l -s < $p 2>&1 > /dev/null
	fi
	echo "Fixed $f for ld -m ppc64le support."
	popd 2>&1 > /dev/null
	break
    done
done

rm -f $PATCH1 $PATCH2
