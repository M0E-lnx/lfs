#!/bin/bash
set -e
echo "Running build.."

# prepartion
sh /tools/6.2-prepare-vkfs.sh
# we are already root.
#XX:  hack the uname tool if necessary
BTGT="${LFS_TGT%%-*}"
case $BTGT in
    i?86)
	echo 'First move'
	sleep 5
	mv $LFS/tools/bin/uname $LFS/tools/bin/uname.bin  || exit 1
	cp /tmp/uname $LFS/tools/bin/uname || exit 1
	;;
esac
# enter and continue in chroot environment with tools
chroot "$LFS" /tools/bin/env -i                 \
  HOME=/root TERM="$TERM" PS1='\u:\w\$ '        \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
  LFS="$LFS" LC_ALL="$LC_ALL"                   \
  LFS_TGT="$LFS_TGT" MAKEFLAGS="$MAKEFLAGS"     \
  LFS_TEST="$LFS_TEST" LFS_DOCS="$LFS_DOCS"     \
  JOB_COUNT="$JOB_COUNT"                        \
  /tools/bin/bash --login +h                    \
  -c "sh /tools/as-chroot-with-tools.sh"

case $BTGT in
    i?86)
	echo 'Second uname hack'
	sleep 5
	mv $LFS/bin/uname $LFS/bin/uname.bin  || exit 1
	cp /tmp/uname $LFS/bin/uname || exit 1
	;;
esac

# enter and continue in chroot environment with usr
chroot "$LFS" /usr/bin/env -i                   \
  HOME=/root TERM="$TERM" PS1='\u:\w\$ '        \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin            \
  LFS="$LFS" LC_ALL="$LC_ALL"                   \
  LFS_TGT="$LFS_TGT" MAKEFLAGS="$MAKEFLAGS"     \
  LFS_TEST="$LFS_TEST" LFS_DOCS="$LFS_DOCS"     \
  JOB_COUNT="$JOB_COUNT"                        \
  /bin/bash --login                             \
  -c "sh /tools/as-chroot-with-usr.sh"

# Cleanup the uname hacks if necessary
case $BTGT in
    i?86)
	echo 'reverting uname hack'
	sleep 5
	mv $LFS/bin/uname.bin $LFS/bin/uname || exit 1
	;;
esac

# cleanup
sh /tools/9.x-cleanup.sh
