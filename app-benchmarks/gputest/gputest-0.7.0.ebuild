# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="cross-platform GPU stress test and OpenGL benchmark"
HOMEPAGE="https://www.geeks3d.com/gputest/"
SRC_URI="http://www.ozone3d.net/gputest/dl/GpuTest_Linux_x64_${PV}.zip"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/unzip dev-lang/python:2.7[tk]"
RDEPEND="${DEPEND}"
BDEPEND=""

DOCS="README.txt EULA.txt"
RESTRICT="splitdebug"

src_unpack() {
	default
	mv ${WORKDIR}/GpuTest_Linux_x64_${PV} ${S}
}

src_prepare() {
	#sed -i '2icd /opt/gputest/' *.sh
	#sed -i 's#./GpuTest#/opt/gputest/GpuTest#' gputest_gui.py
	sed -i '/^  os.system/i\  os.chdir("/opt/gputest/")' gputest_gui.py
	sed -i '1s".*"#!/usr/bin/python2"' gputest_gui.py
	chmod +x gputest_gui.py
	rm data/.DS_Store
	for so in *.so; do
		patchelf --set-rpath '$ORIGIN' $so
	done
	default
}

src_install() {
	default
	dobin ${FILESDIR}/gputest
	newbin gputest_gui.py gputest-gui

	insinto /opt/gputest
	for so in *.so; do
		doins ${so}
	done
	doins -r data
	exeinto /opt/gputest
	doexe GpuTest
}
