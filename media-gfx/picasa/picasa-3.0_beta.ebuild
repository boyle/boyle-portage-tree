# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/picasa/picasa-2.7.3736.15.ebuild,v 1.2 2008/08/17 15:36:22 maekke Exp $

inherit eutils versionator rpm nsplugins

MY_P="${PN}-$(get_version_component_range 1-2)"
DESCRIPTION="Google's photo organizer"
HOMEPAGE="http://picasa.google.com"
SRC_URI="http://dl.google.com/linux/rpm/testing/i386/${MY_P}-current.i386.rpm"

IUSE="nsplugin"

LICENSE="google-picasa"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="mirror strip"
QA_TEXTRELS_x86="opt/google/picasa/3.0/wine/lib/wine/set_lang.exe.so
		opt/google/picasa/3.0/wine/lib/wine/browser_prompt.exe.so
		opt/google/picasa/3.0/wine/lib/wine/license.exe.so"
#QA_EXECSTACK_x86="opt/google/picasa/3.0/bin/xsu
#               opt/google/picasa/3.0/wine/bin/wine
#               opt/google/picasa/3.0/wine/bin/wineserver
#               opt/google/picasa/3.0/wine/bin/wine-pthread
#               opt/google/picasa/3.0/wine/bin/wine-kthread
#               opt/google/picasa/3.0/wine/lib/*
#               opt/google/picasa/3.0/wine/lib/wine/*"

RDEPEND="x86? (
		dev-libs/atk
		dev-libs/glib
		dev-libs/libxml2
		sys-libs/zlib
		x11-libs/gtk+
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXt
		x11-libs/pango )
	nsplugin? ( || (
		>=net-libs/xulrunner-1.9
		>=www-client/mozilla-firefox-3.0.0 ) )
	amd64? (
		app-emulation/emul-linux-x86-gtklibs )"

S="${WORKDIR}"

src_unpack() {
	rpm_src_unpack ${A}
}

src_install() {
	local libdir=$(get_libdir)

	cd opt/google/picasa/3.0
	dodir /opt/google/picasa/3.0
	mv bin ${libdir} wine "${D}/opt/google/picasa/3.0/"

	dodir /opt/google/picasa/3.0/desktop
	mv desktop/picasa32x32.xpm "${D}/opt/google/picasa/3.0/desktop/"

	dodir /usr/bin
	for i in picasa picasafontcfg mediadetector showpicasascreensaver; do
		dosym /opt/google/picasa/3.0/bin/${i} /usr/bin/${i}
	done

	dodoc README LICENSE.FOSS

	cd desktop

	mv picasa.desktop.template picasa.desktop
	mv picasa-fontcfg.desktop.template picasa-fontcfg.desktop

	sed -i -e "s:EXEC:picasa:" picasa.desktop
	sed -i -e "s:ICON:picasa.xpm:" picasa.desktop
	sed -i -e "s:EXEC:picasafontcfg:" picasa-fontcfg.desktop
	sed -i -e "s:ICON:picasa-fontcfg.xpm:" picasa-fontcfg.desktop

	doicon picasa{,-fontcfg}.xpm
	domenu {picasa{,-fontcfg,-kdehal},picasascr}.desktop

	if use nsplugin; then
		inst_plugin /opt/google/picasa/3.0/${libdir}/npPicasa3.so
	fi
}
