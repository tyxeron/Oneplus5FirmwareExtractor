#!/bin/bash

set -e

if [ $# -ne 1 ] ; then
    echo "Usage: $0 UPSTREAM_FLASHABLE.zip"
    exit 1
fi

SOURCE=`readlink -f "$1"`
TARGET="$PWD"/firmware-$(basename $SOURCE)
TEMPDIR=`mktemp -d`

cd "$TEMPDIR"
unzip "$SOURCE"
rm boot.img system.*
cd META-INF
rm -f CERT.*  MANIFEST.MF
cd com
rm -fR android
cd google/android

cat <<EOF  > updater-script
ui_print(" ");
ui_print("****************************************************");
ui_print("* OnePlus 5 OxygenOS 5.1.7 Stable Firmware + Radio *");
ui_print("****************************************************");
ui_print(" ");
ui_print("1. Updating radio image");
package_extract_file("RADIO/static_nvbk.bin", "/dev/block/bootdevice/by-name/oem_stanvbk");
ui_print("2. Updating firmware images");
package_extract_file("firmware-update/cmnlib64.mbn", "/dev/block/bootdevice/by-name/cmnlib64");
package_extract_file("firmware-update/cmnlib.mbn", "/dev/block/bootdevice/by-name/cmnlib");
package_extract_file("firmware-update/hyp.mbn", "/dev/block/bootdevice/by-name/hyp");
package_extract_file("firmware-update/pmic.elf", "/dev/block/bootdevice/by-name/pmic");
package_extract_file("firmware-update/tz.mbn", "/dev/block/bootdevice/by-name/tz");
package_extract_file("firmware-update/abl.elf", "/dev/block/bootdevice/by-name/abl");
package_extract_file("firmware-update/devcfg.mbn", "/dev/block/bootdevice/by-name/devcfg");
package_extract_file("firmware-update/keymaster.mbn", "/dev/block/bootdevice/by-name/keymaster");
package_extract_file("firmware-update/xbl.elf", "/dev/block/bootdevice/by-name/xbl");
package_extract_file("firmware-update/rpm.mbn", "/dev/block/bootdevice/by-name/rpm");
ui_print("3. Updating firmware backup images");
package_extract_file("firmware-update/cmnlib64.mbn", "/dev/block/bootdevice/by-name/cmnlib64bak");
package_extract_file("firmware-update/cmnlib.mbn", "/dev/block/bootdevice/by-name/cmnlibbak");
package_extract_file("firmware-update/hyp.mbn", "/dev/block/bootdevice/by-name/hypbak");
package_extract_file("firmware-update/tz.mbn", "/dev/block/bootdevice/by-name/tzbak");
package_extract_file("firmware-update/abl.elf", "/dev/block/bootdevice/by-name/ablbak");
package_extract_file("firmware-update/keymaster.mbn", "/dev/block/bootdevice/by-name/keymasterbak");
package_extract_file("firmware-update/xbl.elf", "/dev/block/bootdevice/by-name/xblbak");
package_extract_file("firmware-update/rpm.mbn", "/dev/block/bootdevice/by-name/rpmbak");
ui_print("4. Updating remaining firmware images");
package_extract_file("firmware-update/logo.bin", "/dev/block/bootdevice/by-name/LOGO");
package_extract_file("firmware-update/NON-HLOS.bin", "/dev/block/bootdevice/by-name/modem");
package_extract_file("firmware-update/adspso.bin", "/dev/block/bootdevice/by-name/dsp");
package_extract_file("firmware-update/BTFM.bin", "/dev/block/bootdevice/by-name/bluetooth");
ui_print(" ");
ui_print("****************************************************");
ui_print("*               Installation Complete              *");
ui_print("****************************************************");
ui_print(" ");
set_progress(1.000000);
EOF

cd "$TEMPDIR"
zip "$TARGET" -r .
rm -fR "$TEMPDIR"

echo "flashable zip successfully generated at $TARGET"
