# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mono

DESCRIPTION="Gnome Do, quickly seach for many objects and perform commonly used
commands"
HOMEPAGE="http://do.davebsd.com/"
SRC_URI="http://do.davebsd.com/src/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="icons"


DEPEND=">=dev-lang/mono-1.2.2.1
        >=dev-dotnet/dbus-glib-sharp-0.3
		icons? ( x11-themes/tango-icon-theme )"
#RDEPEND=""
	

src_compile() {
	cd do-0.1 || die "unexpected packaging"
	econf || die "conf failed!"
	emake || die "make failed!"
}

src_install() {
	cd do-0.1 || die "bad dir!"
	make DESTDIR=${D} install || die "install failed!"
}

pkg_postinst() {
	einfo "additional add-in/plugin/extensions are available at"
	einfo "http://do.davebsd.com/addins copy these to ~/.do/addins"
	einfo " and restart Do"
}
