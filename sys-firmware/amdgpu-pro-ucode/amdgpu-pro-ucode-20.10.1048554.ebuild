# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

#inherit linux-info unpacker
inherit unpacker

DESCRIPTION="Proprietary microcode for AMD GPUs"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Driver-for-Linux-Release-Notes.aspx"
PVA=${PV%\.*}  # package release number
PVB=${PV##*\.}  # package build number
ARC_NAME="amdgpu-pro-${PVA}-${PVB}-ubuntu-18.04.tar.xz"
SRC_URI="https://drivers.amd.com/drivers/linux/${ARC_NAME}"
# https://drivers.amd.com/drivers/linux/amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz
RESTRICT="fetch strip"

LICENSE="radeon-ucode"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${ARC_NAME}"
	einfo "from ${HOMEPAGE} and place them in your DISTDIR directory."
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*

	# Clean things up #458658.  No one seems to actually care about
	# these, so wait until someone requests to do something else ...
	#rm -f debian-binary {control,data}.tar*
}

src_unpack() {
	unpack ${A}
	# mv linux-firmware-* "${AMDGPU_UCODE_LINUX_FIRMWARE}" || die
}

src_prepare() {
	#linux-info_pkg_setup
	DEB=amdgpu-dkms-firmware_*-${PVB}_all.deb
	unpack_deb ${ARC_NAME%.tar.xz}/${DEB}
	default
}

src_install() {
	local chip files legacyfiles

	# usr/src/amdgpu-5.4.7.53-1048554/firmware/amdgpu/
	pushd usr/src/amdgpu-*-${PVB}/firmware || die

	#pushd radeon || die
	#radeonfiles+=( *.bin )
	#insinto /lib/firmware/amdgpu-pro-${BUILD_VER}/radeon
	#doins ${radeonfiles[@]}
	#popd

	pushd amdgpu || die
	insinto /lib/firmware/amdgpu-pro
	doins *.bin
	popd
}
