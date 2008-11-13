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

# Makefile: fix .lib -> .o in Makefile
# __java__.cc: fix client->server in libjvm call
PATCHES="Makefile-1.2.3.patch __java__.cc-1.2.3.patch"


# STUPID $PATCHES needs to not have quotes so we get to reimpliment the entire function
#################################################################
# since we use octave's package installed for compiling we need
# to provide the raw gzipped octave-forge source tarballs. 
# Hence, if there are no patches to apply, we simply copy the
# tarball to ${WORKDIR}. If there are patches we unpack
# the tarball in ${WORKDIR}, apply the patches, and repack it.
#################################################################
octave-forge_src_unpack() {
    cd "${WORKDIR}"

    if [[ -n "${PATCHES}" ]]; then
        unpack "${A}"
        pushd "${S}" >& /dev/null
        for patch in ${PATCHES}; do # <<<<<<<< BLOOPER HERE removed quotes
            epatch "${FILESDIR}/${patch}"
        done
        popd >& /dev/null
        tar czf "${OCT_PKG_TARBALL}" "${OCT_PKG}" \
            && rm -fr "${OCT_PKG}" \
            || die "Failed to recompress the source"
    else
        cp "${DISTDIR}/${OCT_PKG_TARBALL}" ./
    fi
}


src_compile() {
		# tell configure where java can be found
		JAVA_HOME=$(java-config --jre-home) 
		JAVAC=$(java-config --javac) 
		octave-forge_src_compile
}

src_install() {
# TODO __java__.oct seems to be incorrectly installed by
# octave-forge_src_install(), this is a work-around that gets it installed
		cp ${WORKDIR}/src/__java__.oct ${WORKDIR}/inst/ || die 
		cp ${WORKDIR}/src/__java__.h   ${WORKDIR}/inst/ || die 
		cp ${WORKDIR}/src/__java__.o   ${WORKDIR}/inst/ || die 
		cp ${WORKDIR}/src/octave.jar   ${WORKDIR}/inst/ || die 

		octave-forge_src_install
		java-pkg_dojar src/octave.jar
}
