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

src_compile() {
		# fix .lib -> .o in Makefile
		epatch ${FILESDIR}/Makefile-1.2.3.patch || die

		# fix client->server in libjvm call
		epatch ${FILESDIR}/__java__.cc-1.2.3.patch || die

		# tell configure where java can be found
		JAVA_HOME=$(java-config --jre-home) 
		JAVAC=$(java-config --javac) 
		octave-forge_src_compile
}

src_install() {
# TODO __java__.oct seems to be incorrectly installed by
# octave-forge_src_install(), this is a work-around that gets it installed
		cp ${S}/src/__java__.oct ${S}/inst/ || die 
		cp ${S}/src/__java__.h ${S}/inst/ || die 
		cp ${S}/src/__java__.o ${S}/inst/ || die 
		cp ${S}/src/octave.jar ${S}/inst/ || die 

		octave-forge_src_install
		java-pkg_dojar src/octave.jar
}
