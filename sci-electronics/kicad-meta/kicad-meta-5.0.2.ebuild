# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Electronic Schematic and PCB design tools (meta package)"
HOMEPAGE="http://www.kicad-pcb.org"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc nls"

RDEPEND="
	>=sci-electronics/kicad-${PV}
	>=sci-electronics/kicad-symbols-${PV}
	>=sci-electronics/kicad-footprints-${PV}
	>=sci-electronics/kicad-packages3d-${PV}
	>=sci-electronics/kicad-templates-${PV}
	doc? (
		>=app-doc/kicad-doc-${PV}
	)
	nls? (
		>=sci-electronics/kicad-i18n-${PV}
	)
"
