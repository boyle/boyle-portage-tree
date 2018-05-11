# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font

DESCRIPTION="Computer Modern Bakoma fonts"
HOMEPAGE="https://ctan.org/tex-archive/fonts/cm/ps-type1/bakoma"
SRC_URI="http://mirrors.ctan.org/fonts/cm/ps-type1/${PN}.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

S="${WORKDIR}/${PN}"
FONT_SUFFIX="ttf"
FONT_S="${S}/${FONT_SUFFIX}"
#DOCS="LICENSE BaKoMa-CM.Fonts README.news"
