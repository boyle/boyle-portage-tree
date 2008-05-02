# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit octave-forge eutils

DESCRIPTION="JHandles for Octave"
HOMEPAGE="http://octave.sourceforge.net/jhandles/index.html"
SRC_URI="mirror://sourceforge/octave/${OCT_PKG}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="${DEPEND}
		 >=sci-mathematics/octave-forge-java-1.2.3
		 dev-java/jogl"

src_compile() {
		# fix the configure script so that it can find the .jar files it needs
		epatch ${FILESDIR}/configure.base-1-0.3.2.patch || die

		# http://www.nabble.com/Trouble-installing-Java-and-Jhandles-td15653720.html
		# fix Makefile, linker line is wrong
		epatch ${FILESDIR}/Makefile-0.3.2.patch || die
		
		# bad characters in variable output
		epatch ${FILESDIR}/configure.base-2-0.3.2.patch || die
	
		# TODO note: need some way to add OCTAVE_EXEC_PATH=/usr/share/jogl/lib
		# permanently...
		# for now "OCTAVE_EXEC_PATH=/usr/share/jogl/lib octave -q"

		cd ${S}/src
		./autogen.sh

		# tell configure where java can be found
		JAVA_HOME=$(java-config --jre-home)
		JAVAC=$(java-config --javac)
		octave-forge_src_compile
}

src_install() {
		cp ${S}/src/jhandles.jar ${S}/inst/ || die

		octave-forge_src_install
		java-pkg_dojar src/jhandles.jar
}
