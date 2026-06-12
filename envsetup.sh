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
    make -j$(nproc) ARCH="$ARCH" DTC_EXT="$(command -v dtc)" DTC_FLAGS="-q -@ -H both" LLVM=1 LLVM_IAS=1 CC="clang" "$@"
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
