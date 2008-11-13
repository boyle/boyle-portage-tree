# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit octave-forge java-pkg-2 eutils

DESCRIPTION="Java for Octave"
HOMEPAGE="http://octave.sourceforge.net/java/index.html"
SRC_URI="mirror://sourceforge/octave/${OCT_PKG}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="${DEPEND}
         >=virtual/jdk-1.6"

PATCHES="server-1.2.5.patch"

src_compile() {
		octave-forge_src_compile
}

# have to register the jar file with java in addition to installing it in octave
src_install() {
		octave-forge_src_install
		einfo "Registering ${PN} .jar file with java-config..."
		java-pkg_regjar "${OCT_INSTALL_PATH}/${OCT_PKG}/octave.jar"
}

# can't have a test section since it won't run until its installed but this should run in octave:
# #! /usr/bin/octave -q
# f = java_new('java.awt.Frame');
# f.setSize(300,300);
# f.show(); % this shows the window
# sleep(10);
# f.dispose(); % this closes the window 

