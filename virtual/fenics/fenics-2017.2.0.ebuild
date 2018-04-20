# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual package for FEniCS Finite Element Software"

PYTHON_COMPAT=( python3_{4,5,6} )
inherit eutils cmake-utils python-single-r1

SLOT="0"
KEYWORDS="~amd64"
IUSE="+mshr +paraview"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
    ${PYTHON_DEPS}
	=sci-mathematics/dolfin-${PV}
	mshr? ( =dev-python/mshr-${PV}[${PYTHON_USEDEP}] )
	paraview? ( sci-visualization/paraview )
"
DEPEND="${PYTHON_DEPS}"

pkg_setup() {
    python-single-r1_pkg_setup
}
