# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
PLOCALES="az bg ca cs da de el en_GB eo es eu fa fi fr fur gl he hi hr hu ia id ie is it ka kab nb ne nl oc pl pt pt_BR ro ru si sl sr sv tr uk vi zh_CN zh_TW"

inherit gnome2-utils meson plocale python-single-r1 xdg

DESCRIPTION="Distraction free Markdown editor"
HOMEPAGE="https://apps.gnome.org/Apostrophe/"
SRC_URI="https://gitlab.gnome.org/World/apostrophe/-/archive/v${PV}/apostrophe-v${PV}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/apostrophe-v${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	gui-libs/gtk:4
	gui-libs/libadwaita:1
	app-text/libspelling
	net-libs/webkit-gtk:6[introspection]
	dev-libs/gobject-introspection:=
	app-text/pandoc
	$(python_gen_cond_dep '
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/pypandoc[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/chardet[${PYTHON_USEDEP}]
		dev-python/levenshtein[${PYTHON_USEDEP}]
	')
	x11-themes/hicolor-icon-theme
"

BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default
	xdg_environment_reset

	plocale_find_changes "${S}"/po '' '.po'

	rm_po() {
		rm -f "po/${1}.po"
		sed -i -e "/^${1}/d" po/LINGUAS
	}

	plocale_for_each_disabled_locale rm_po
}

src_configure() {
	local emesonargs=(
		-Dprofile=default
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
