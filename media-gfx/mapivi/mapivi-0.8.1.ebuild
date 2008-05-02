# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils versionator

PV_wo_dots=`delete_all_version_separators`
S="${WORKDIR}/$PN$PV_wo_dots"

DESCRIPTION="Martin's Picture Viewer"
HOMEPAGE="http://mapivi.sourceforge.net"
# TODO: can't seem to get the download from sourceforge to work
#SRC_URI="mirror://sourceforge/$PN/$PN${PV_wo_dots}.tar.bz2"
RESTRICT="fetch"
SRC_URI="$PN${PV_wo_dots}.tar.bz2"

LICENSE="GPLv2+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="lossless-interpolation lossless-crop screenshot gcpan-extras"

# NOTE: g-cpan -g Image::MetaData::JPEG    to generate ebuild
#       ebuild xyz digest    to build the Manifest and digest
# then off we go.. need to do this for all perl-gcpan dependancies!

DEPEND="app-portage/g-cpan"
# jpeg contains jpegtran - lossless crop patch is available >= 6b-r6
RDEPEND=" lossless-crop? (>=media-libs/jpeg-6b-r6)
		 !lossless-crop? (media-libs/jpeg) 
		 media-gfx/imagemagick 
		 media-gfx/jhead 
		 >=dev-lang/perl-5.005 
		 >=dev-perl/perl-tk-804.025 
		 dev-perl/ImageInfo 
		 lossless-interpolation? ( media-gfx/jpegpixi )
		 screenshot? (x11-apps/xwd) 
		 >=perl-gcpan/Image-MetaData-JPEG-0.14
		 dev-perl/ImageInfo
		 
		 gcpan-extras? ( perl-gcpan/Tk-ResizeButton
				         perl-gcpan/Color-Rgb
 		                 perl-gcpan/Tk-Splash
		                 perl-gcpan/Tk-MatchEntry )
		 "

src_install() {
	dodoc FAQ ToDo README INSTALL License.txt COPYING Tips.txt Changes.txt

	exeinto /usr/bin
	doexe mapivi

	for i in PlugIns 
	do
		einfo "/usr/share/$P/$i"
		dodir  /usr/share/$P/$i
		insinto /usr/share/$P/$i
		doins $i/*
	done
}		

		
