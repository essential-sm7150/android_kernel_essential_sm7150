#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

### Customisable variables
export TC_DIR="/media/samsung_ssd/los23/prebuilts/clang/host/linux-x86/clang-r563880c"
export GCC_DIR="/media/samsung_ssd/los23/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9"
export GCC32_DIR="/media/samsung_ssd/los23/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9"
export DEFCONFIG="vendor/sdmsteppe_defconfig"

export KBUILD_OUTPUT=.out
export KBUILD_BUILD_USER="$USER"
export KBUILD_BUILD_HOST=$(cat /etc/hostname)
### End

# Set up environment
function envsetup() {
    export ARCH=arm64
    export PATH="$TC_DIR/bin:$GCC_DIR/bin:$GCC32_DIR/bin:$PATH"
    export CROSS_COMPILE=aarch64-linux-gnu-
    export CROSS_COMPILE_ARM32=arm-linux-androideabi-
    export CROSS_COMPILE_COMPAT=arm-linux-androideabi-
}

# Wrapper to utilise all available cores
function m() {
    make -j$(nproc) ARCH="$ARCH" DTC_EXT="$(command -v dtc)" DTC_FLAGS="-q -@ -H both" LLVM=1 LLVM_IAS=1 CC="clang" HOSTCFLAGS="-DOPENSSL_NO_ENGINE -DOPENSSL_IS_BORINGSSL" "$@"
}

# Pack kernel
function pack() {
    OUT="$KBUILD_OUTPUT"/arch/"$ARCH"/boot
    KERNEL_DTB="$OUT/"

    mkbootimg \
        --header_version 0 \
        --os_version 10.0.0 \
        --os_patch_level 2024-09 \
        --kernel "$OUT"/Image.gz \
        --ramdisk prebuilt/ramdisk \
        --pagesize 0x00001000 \
        --base 0x00000000 \
        --kernel_offset 0x00008000 \
        --ramdisk_offset 0x01000000 \
        --second_offset 0x00f00000 \
        --tags_offset 0x00000100 \
        --board '' \
        --cmdline 'console=ttyMSM0,115200n8 androidboot.console=ttyMSM0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 service_locator.enable=1 cgroup.memory=nokmem lpm_levels.sleep_disabled=1 usbcore.autosuspend=7 androidboot.usbcontroller=a600000.dwc3 firmware_class.path=/vendor/firmware_mnt/image quiet loglevel=3 androidboot.selinux=permissive buildvariant=userdebug'

    mkdtboimg create dtbo.img --page_size=4096 "$OUT"/dts/vendor/moorechip/kona-retroid-pocket-5-overlay.dtbo
}

# Regenerate defconfig
function rd() {
    m "${DEFCONFIG}" savedefconfig || return
    cp "${KBUILD_OUTPUT}"/defconfig arch/"${ARCH}"/configs/"${DEFCONFIG}"
}

# Build kernel
function mka() {
    m "${DEFCONFIG}" vendor/gem.config dtbs Image.gz || return
}

envsetup
