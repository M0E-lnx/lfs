#!/bin/bash
set -e
echo "Creating ramdisk.."

export LOOP=$(losetup -f)

LOOP_DIR=$(pwd)/$LOOP
RAMDISK=$(pwd)/ramdisk

# create ramdisk file of IMAGE_SIZE
dd if=/dev/zero of=$RAMDISK bs=1k count=$IMAGE_SIZE

# associate it with ${LOOP}
losetup $LOOP $RAMDISK

# make an ext2 filesystem
mke2fs -t ext2 -q -i 16384 -m 0 $LOOP $IMAGE_SIZE

# ensure loop2 directory
[ -d $LOOP_DIR ] || mkdir -pv $LOOP_DIR

# mount it
mount $LOOP $LOOP_DIR
rm -rf $LOOP_DIR/lost+found

# copy LFS system without build artifacts
pushd $INITRD_TREE
cp -dpR $(ls -A | grep -Ev "sources|tools") $LOOP_DIR
popd

# show statistics
df $LOOP_DIR

echo "Compressing system ramdisk image.."
bzip2 -c $RAMDISK > $IMAGE

# cleanup
umount $LOOP_DIR
losetup -d $LOOP
rm -rf $LOOP_DIR
rm -f $RAMDISK
