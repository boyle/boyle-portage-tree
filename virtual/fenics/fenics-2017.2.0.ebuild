# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Virtual package for FEniCS Finite Element Software"

SLOT="0"
KEYWORDS="~amd64"
IUSE="+mshr +paraview"

RDEPEND="
	mshr? ( =dev-python/mshr-${PV} )
	paraview ? =sci-visualization/paraview-5.3.0
	=sci-mathematics/dolfin-${PV}
"
