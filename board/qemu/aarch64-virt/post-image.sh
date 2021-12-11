#!/usr/bin/env bash

set -e

${HOST_DIR}/bin/aarch64-none-linux-gnu-objcopy \
    -O binary \
    -R .note \
    -R .comment \
    ${BINARIES_DIR}/vmlinux \
    ${BINARIES_DIR}/linux.bin

${HOST_DIR}/bin/mkimage \
    -A arm64 \
    -O linux \
    -T kernel \
    -C none \
    -a 0x40400000 \
    -e 0x40400000 \
    -n "Linux kernel" \
    -d ${BINARIES_DIR}/linux.bin \
    ${BINARIES_DIR}/uImage

${HOST_DIR}/bin/mkimage \
    -A arm64 \
    -T ramdisk \
    -C gzip \
    -a 0x44000000 \
    -e 0x44000000 \
    -n "Root file system" \
    -d ${BINARIES_DIR}/rootfs.cpio.gz \
    ${BINARIES_DIR}/rootfs.cpio.uboot

(cd ${BINARIES_DIR};
 ln -sf tee-header_v2.bin bl32.bin;
 ln -sf tee-pager_v2.bin bl32_extra1.bin;
 ln -sf tee-pageable_v2.bin bl32_extra2.bin;
 ln -sf u-boot.bin bl33.bin;
)
