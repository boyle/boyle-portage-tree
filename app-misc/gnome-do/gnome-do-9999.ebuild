# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit bzr
inherit autotools
inherit mono

DESCRIPTION="Gnome Do, quickly seach for many objects and perform commonly used
commands"
HOMEPAGE="http://do.davebsd.com/"
SRC_URI=""
BZR_BRANCH="http://bazaar.launchpad.net/~do-core/gc/trunk-md"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+icons +evo"


DEPEND="${DEPEND}
        >=dev-lang/mono-1.2.2.1
        >=dev-dotnet/dbus-glib-sharp-0.3
		icons? ( x11-themes/tango-icon-theme )
		>=app-misc/tomboy-0.8.1-r1
		evo? ( >=dev-dotnet/evolution-sharp-0.12.0 )"
#RDEPEND=""


src_unpack() {
	bzr_src_unpack
}

src_compile() {
	eautoreconf || die "autogen failed"
	econf || die "conf failed!"
	emake || die "make failed!"
}

src_install() {
	make DESTDIR=${D} install || die "install failed!"
}

pkg_postinst() {
	einfo "additional add-in/plugin/extensions are available at"
	einfo "http://do.davebsd.com/addins copy these to ~/.do/addins"
	einfo " and restart Do"
}
