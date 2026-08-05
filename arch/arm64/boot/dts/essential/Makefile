# SPDX-License-Identifier: GPL-2.0
dtbo-$(CONFIG_ARCH_SDMMAGPIE) += \
	sdmmagpie-essential-gem-evt1-overlay.dtbo \
	sdmmagpie-essential-gem-evt2-overlay.dtbo

sdmmagpie-essential-gem-evt1-overlay.dtbo-base := ../qcom/sdmmagpie.dtb
sdmmagpie-essential-gem-evt2-overlay.dtbo-base := ../qcom/sdmmagpie.dtb

always		:= $(dtb-y)
subdir-y	:= $(dts-dirs)
clean-files	:= *.dtb *.dtbo
