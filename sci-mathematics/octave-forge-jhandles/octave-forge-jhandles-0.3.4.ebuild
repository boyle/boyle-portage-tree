# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit octave-forge java-pkg-2 eutils

DESCRIPTION="JHandles for Octave"
HOMEPAGE="http://octave.sourceforge.net/jhandles/index.html"
SRC_URI="mirror://sourceforge/octave/${OCT_PKG}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="${DEPEND}
		 >=virtual/jdk-1.6"

RDEPEND="${DEPEND}
         >=sci-mathematics/octave-forge-java-1.2.5
		 dev-java/jogl
		 dev-java/gluegen"

PATCHES="paths-0.3.4.patch"


src_compile() {
		octave-forge_src_compile
}

src_install() {
		octave-forge_src_install
        einfo "Registering ${PN} .jar file with java-config..."
        java-pkg_regjar "${OCT_INSTALL_PATH}/${OCT_PKG}/jhandles.jar"
		java-pkg_register-dependency octave-forge-java,jogl,gluegen
}
