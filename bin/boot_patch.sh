#!/bin/sh

KEEPVERITY=false
KEEPFORCEENCRYPT=false
RECOVERYMODE=false

BOOTIMAGE=$1
IS64BIT=$2
KEEPVERITY=$3
KEEPFORCEENCRYPT=$4
# BOOTIMAGE=boot.img

export KEEPVERITY
export KEEPFORCEENCRYPT

./bin/magiskboot unpack "$BOOTIMAGE"

case $? in
  0 ) ;;
  1 )
    echo "! Unsupported/Unknown image format"
    ;;
  2 )
    echo "- ChromeOS boot image detected"
	echo "ChromeOS not support on windows"
    CHROMEOS=true
	exit 1
    ;;
  * )
    echo "! Unable to unpack boot image"
	exit 1
    ;;
esac

[ -f recovery_dtbo ] && RECOVERYMODE=true

echo "- Checking ramdisk status"
if [ -e ramdisk.cpio ]; then
  ./bin/magiskboot cpio ramdisk.cpio test
  STATUS=$?
else
  # Stock A only system-as-root
  STATUS=0
fi

case $((STATUS & 3)) in
  0 )  # Stock boot
    echo "- Stock boot image detected"
    SHA1=$(./bin/magiskboot sha1 "$BOOTIMAGE" 2>/dev/null)
    cat $BOOTIMAGE > stock_boot.img
    cp -af ramdisk.cpio ramdisk.cpio.orig 2>/dev/null
    ;;
  1 )  # Magisk patched
    echo "- Magisk patched boot image detected"
    # Find SHA1 of stock boot image
    [ -z $SHA1 ] && SHA1=$(./bin/magiskboot cpio ramdisk.cpio sha1 2>/dev/null)
    ./bin/magiskboot cpio ramdisk.cpio restore
    cp -af ramdisk.cpio ramdisk.cpio.orig
    rm -f stock_boot.img
    ;;
  2 )  # Unsupported
    echo "! Boot image patched by unsupported programs"
    echo "! Please restore back to stock boot image"
	exit 1
    ;;
esac

echo "- Patching ramdisk"

echo "KEEPVERITY=$KEEPVERITY" > config
echo "KEEPFORCEENCRYPT=$KEEPFORCEENCRYPT" >> config
echo "RECOVERYMODE=$RECOVERYMODE" >> config
[ ! -z $SHA1 ] && echo "SHA1=$SHA1" >> config

# Compress to save precious ramdisk space
./bin/magiskboot compress=xz magisk32 magisk32.xz
./bin/magiskboot compress=xz magisk64 magisk64.xz
$IS64BIT && SKIP64="" || SKIP64="#"

./bin/magiskboot cpio ramdisk.cpio \
"add 0750 init magiskinit" \
"mkdir 0750 overlay.d" \
"mkdir 0750 overlay.d/sbin" \
"add 0644 overlay.d/sbin/magisk32.xz magisk32.xz" \
"$SKIP64 add 0644 overlay.d/sbin/magisk64.xz magisk64.xz" \
"patch" \
"backup ramdisk.cpio.orig" \
"mkdir 000 .backup" \
"add 000 .backup/.magisk config"

rm -f ramdisk.cpio.orig config magisk*.xz

for dt in dtb kernel_dtb extra; do
  [ -f $dt ] && ./bin/magiskboot dtb $dt patch && echo "- Patch fstab in $dt"
done

if [ -f kernel ]; then
  # Remove Samsung RKP
  ./bin/magiskboot hexpatch kernel \
  49010054011440B93FA00F71E9000054010840B93FA00F7189000054001840B91FA00F7188010054 \
  A1020054011440B93FA00F7140020054010840B93FA00F71E0010054001840B91FA00F7181010054

  # Remove Samsung defex
  # Before: [mov w2, #-221]   (-__NR_execve)
  # After:  [mov w2, #-32768]
  ./bin/magiskboot hexpatch kernel 821B8012 E2FF8F12

  # Force kernel to load rootfs
  # skip_initramfs -> want_initramfs
  ./bin/magiskboot hexpatch kernel \
  736B69705F696E697472616D667300 \
  77616E745F696E697472616D667300
fi

#################
# Repack & Flash
#################

echo "- Repacking boot image"
./bin/magiskboot repack "$BOOTIMAGE" || echo "! Unable to repack boot image"

true

