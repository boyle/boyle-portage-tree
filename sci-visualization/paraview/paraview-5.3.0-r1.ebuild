# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit eutils cmake-utils python-single-r1 multilib toolchain-funcs versionator

MAIN_PV=$(get_major_version)
MAJOR_PV=$(get_version_component_range 1-2)
MY_P="ParaView-v${PV}"

DESCRIPTION="ParaView is a powerful scientific data visualization application"
HOMEPAGE="http://www.paraview.org"
SRC_URI="http://www.paraview.org/files/v${MAJOR_PV}/${MY_P}.tar.gz"
RESTRICT="mirror"

LICENSE="paraview GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="boost cg coprocessing development doc examples ffmpeg mpi mysql nvcontrol openmp plugins python +qt5 sqlite tcl test tk"
RESTRICT="test plugins python"

REQUIRED_USE="python? ( mpi ${PYTHON_REQUIRED_USE} )
	mysql? ( sqlite )
	mpi? ( !plugins )"
# mysql? ( sqlite ) <-- "vtksqlite, needed by vtkIOSQL" and "vtkIOSQL, needed by vtkIOMySQL"
#
# TODO mpi? ( !plugins ):
# In file included from /var/tmp/notmpfs-portage-tmp/portage/sci-visualization/paraview-5.3.0-r1/work/ParaView-v5.3.0/Plugins/H5PartReader/H5Part/src/H5Part.h:16:0,
#                 from /var/tmp/notmpfs-portage-tmp/portage/sci-visualization/paraview-5.3.0-r1/work/ParaView-v5.3.0/Plugins/H5PartReader/vtkH5PartReader.cxx:84:
#/var/tmp/notmpfs-portage-tmp/portage/sci-visualization/paraview-5.3.0-r1/work/ParaView-v5.3.0/Plugins/H5PartReader/H5Part/src/H5PartTypes.h:21:14: error: conflicting declaration ‘typedef int MPI_Comm’
# typedef int  MPI_Comm;
#              ^~~~~~~~
#In file included from /usr/include/mpi.h:10:0,
#                 from /usr/include/H5public.h:63,
#                 from /usr/include/hdf5.h:24,
#                 from /var/tmp/notmpfs-portage-tmp/portage/sci-visualization/paraview-5.3.0-r1/work/ParaView-v5.3.0/Plugins/H5PartReader/H5Part/src/H5Part.h:6,
#                 from /var/tmp/notmpfs-portage-tmp/portage/sci-visualization/paraview-5.3.0-r1/work/ParaView-v5.3.0/Plugins/H5PartReader/vtkH5PartReader.cxx:84:
#/usr/include/x86_64-pc-linux-gnu/mpi.h:329:37: note: previous declaration as ‘typedef struct ompi_communicator_t* MPI_Comm’
# typedef struct ompi_communicator_t *MPI_Comm;
#                                     ^~~~~~~~

RDEPEND="
	dev-libs/expat
	dev-libs/jsoncpp
	dev-libs/libxml2:2
	dev-libs/protobuf
	media-libs/freetype
	media-libs/libpng:0
	media-libs/libtheora
	media-libs/tiff:0=
	sci-libs/hdf5[mpi=]
	>=sci-libs/netcdf-4.2[hdf5]
	>=sci-libs/netcdf-cxx-4.2:3
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	virtual/glu
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXt
	coprocessing? (
		plugins? (
			dev-python/PyQt5
			dev-qt/qtgui:5[-gles2]
		)
	)
	ffmpeg? ( virtual/ffmpeg )
	mpi? ( virtual/mpi[cxx,romio] )
	mysql? ( virtual/mysql )
	python? (
		${PYTHON_DEPS}
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/sip[${PYTHON_USEDEP}]
		dev-python/twisted-core
		dev-python/zope-interface[${PYTHON_USEDEP}]
		mpi? ( dev-python/mpi4py )
		qt5? ( dev-python/PyQt5[opengl,webkit,${PYTHON_USEDEP}] )
	)
	qt5? (
		dev-qt/designer:5
		dev-qt/qtgui:5[-gles2]
		dev-qt/qthelp:5
		dev-qt/qtopengl:5[-gles2]
		dev-qt/qtsql:5
		dev-qt/qttest:5
		dev-qt/qtwebkit:5
		dev-qt/qtx11extras:5
	)
	sqlite? ( dev-db/sqlite:3 )
	tcl? ( dev-lang/tcl:0= )
	tk? ( dev-lang/tk:0= )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-util/cmake-3.4
	boost? ( >=dev-libs/boost-1.40.0[mpi?,${PYTHON_USEDEP}] )
	doc? ( app-doc/doxygen )"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PN}-4.0.1-xdmf-cstring.patch
	"${FILESDIR}"/${PN}-5.3.0-fix_buildsystem.patch
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]] && use openmp && [[ $(tc-getCC)$ == *gcc* ]] && ! tc-has-openmp; then
		eerror "For USE=openmp a gcc with openmp support is required"
		eerror
		return 1
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
	PVLIBDIR=$(get_libdir)/${PN}-${MAJOR_PV}
}

src_prepare() {
	cmake-utils_src_prepare

	# lib64 fixes
	sed -i \
		-e "s:/usr/lib:${EPREFIX}/usr/$(get_libdir):g" \
		 VTK/ThirdParty/xdmf2/vtkxdmf2/libsrc/CMakeLists.txt || die
	sed -i \
		-e "s:\/lib\/python:\/$(get_libdir)\/python:g" \
		 VTK/ThirdParty/xdmf2/vtkxdmf2/CMake/setup_install_paths.py || die
	sed -i \
		-e "s:lib/paraview-:$(get_libdir)/paraview-:g" \
		CMakeLists.txt \
		ParaViewConfig.cmake.in \
		CoProcessing/PythonCatalyst/vtkCPPythonScriptPipeline.cxx \
		ParaViewCore/ClientServerCore/Core/vtkProcessModuleInitializePython.h \
		ParaViewCore/ClientServerCore/Core/vtkPVPluginTracker.cxx || die

	# no proper switch
	if ! use nvcontrol; then
		sed -i \
			-e '/VTK_USE_NVCONTROL/s#1#0#' \
			VTK/Rendering/OpenGL/CMakeLists.txt || die
	fi
}



src_configure() {
	if use qt5; then
		export QT_SELECT=qt5
	fi

	# VTK_USE_SYSTEM_QTTESTING
	# PARAVIEW_USE_SYSTEM_AUTOBAHN
	local mycmakeargs=(
		-DPV_INSTALL_LIB_DIR="${PVLIBDIR}"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}"/usr
		-DEXPAT_INCLUDE_DIR="${EPREFIX}"/usr/include
		-DEXPAT_LIBRARY="${EPREFIX}"/usr/$(get_libdir)/libexpat.so
		-DOPENGL_gl_LIBRARY="${EPREFIX}"/usr/$(get_libdir)/libGL.so
		-DOPENGL_glu_LIBRARY="${EPREFIX}"/usr/$(get_libdir)/libGLU.so
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_COLOR_MAKEFILE=TRUE
		-DCMAKE_USE_PTHREADS=ON
		-DCMAKE_VERBOSE_MAKEFILE=ON
		-DPARAVIEW_USE_SYSTEM_MPI4PY=ON
		-DPROTOC_LOCATION=$(type -P protoc)
		-DVTK_Group_StandAlone=ON
		-DVTK_RENDERING_BACKEND=OpenGL2
		-DVTK_USE_FFMPEG_ENCODER=OFF
		-DVTK_USE_OFFSCREEN=TRUE
		-DVTK_USE_SYSTEM_EXPAT=ON
		-DVTK_USE_SYSTEM_FREETYPE=ON
		-DVTK_USE_SYSTEM_GL2PS=OFF
		-DVTK_USE_SYSTEM_HDF5=ON
		-DVTK_USE_SYSTEM_JPEG=ON
		-DVTK_USE_SYSTEM_JSONCPP=ON
		-DVTK_USE_SYSTEM_LIBXML2=ON
		-DVTK_USE_SYSTEM_NETCDF=ON
		-DVTK_USE_SYSTEM_OGGTHEORA=ON
		-DVTK_USE_SYSTEM_PNG=ON
		-DVTK_USE_SYSTEM_PROTOBUF=ON
		-DVTK_USE_SYSTEM_TIFF=ON
		-DVTK_USE_SYSTEM_TWISTED=ON
		-DVTK_USE_SYSTEM_XDMF2=OFF
		-DVTK_USE_SYSTEM_ZLIB=ON
		-DVTK_USE_SYSTEM_ZOPE=ON
		# force this module due to incorrect build system deps
		# wrt bug 460528
		-DModule_vtkUtilitiesProcessXML=ON
		)

	# TODO: XDMF_USE_MYSQL?
	# VTK_WRAP_JAVA
	mycmakeargs+=(
		-DPARAVIEW_INSTALL_DEVELOPMENT_FILES=$(usex development)
		-DPARAVIEW_BUILD_QT_GUI=$(usex qt5)
		-DModule_vtkGUISupportQtOpenGL=$(usex qt5)
		-DModule_vtkGUISupportQtSQL=$(usex qt5)
		-DModule_vtkGUISupportQtWebkit=$(usex qt5)
		-DModule_vtkRenderingQt=$(usex qt5)
		-DModule_vtkViewsQt=$(usex qt5)
		-DVTK_Group_ParaViewQt=$(usex qt5)
		-DVTK_Group_Qt=$(usex qt5)
		-DPQWIDGETS_DISABLE_QTWEBKIT=$(usex !qt5)
		-DModule_vtkInfovisBoost=$(usex boost)
		-DModule_vtkInfovisBoostGraphAlg=$(usex boost)
		-DPARAVIEW_USE_MPI=$(usex mpi)
		-DPARAVIEW_USE_MPI_SSEND=$(usex mpi)
		-DPARAVIEW_USE_ICE_T=$(usex mpi)
		-DVTK_Group_MPI=$(usex mpi)
		-DVTK_XDMF_USE_MPI=$(usex mpi)
		-DXDMF_BUILD_MPI=$(usex mpi)
		-DPARAVIEW_ENABLE_PYTHON=$(usex python)
		-DVTK_Group_ParaViewPython=$(usex python)
		-DXDMF_WRAP_PYTHON=$(usex python)
		-DModule_vtkPython=$(usex python)
		-DModule_pqPython=$(usex python)
		-DModule_vtkWrappingPythonCore=$(usex python)
		-DModule_vtkPVPythonSupport=$(usex python)
		-DModule_AutobahnPython=$(usex python)
		-DModule_Twisted=$(usex python)
		-DModule_ZopeInterface=$(usex python)
		-DModule_vtkmpi4py=$(usex python)
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DPARAVIEW_BUILD_WEB_DOCUMENTATION=$(usex doc)
		-DBUILD_EXAMPLES=$(usex examples)
		-DVTK_USE_CG_SHADERS=$(usex cg)
		-DModule_vtkIOMySQL=$(usex mysql)
		-DModule_vtksqlite=$(usex sqlite)
		-DPARAVIEW_ENABLE_CATALYST=$(usex coprocessing)
		-DPARAVIEW_ENABLE_FFMPEG=$(usex ffmpeg)
		-DVTK_USE_FFMPEG_ENCODER=$(usex ffmpeg)
		-DModule_vtkIOFFMPEG=$(usex ffmpeg)
		-DVTK_Group_Tk=$(usex tk)
		-DVTK_USE_TK=$(usex tk)
		-DModule_vtkRenderingTk=$(usex tk)
		-DModule_vtkTclTk=$(usex tcl)
		-DModule_vtkWrappingTcl=$(usex tcl)
		-DBUILD_TESTING=$(usex test)
		)

	if use openmp; then
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE=OpenMP )
	fi

	if use qt5 ; then
		mycmakeargs+=(
		    -DVTK_INSTALL_QT_DIR=/${PVLIBDIR}/plugins/designer
            -DPARAVIEW_QT_VERSION=5
		    -DModule_pqPython=$(usex python)
	        )
		if use python ; then
			# paraview cannot guess sip directory properly
			mycmakeargs+=( -DSIP_INCLUDE_DIR="${EPREFIX}$(python_get_includedir)" )
		fi
	else
		mycmakeargs+=( -DModule_pqPython=OFF )
	fi

	# TODO: MantaView VaporPlugin VRPlugin
	mycmakeargs+=(
		-DPARAVIEW_BUILD_PLUGIN_AdiosReader=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_AnalyzeNIfTIIO=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_ArrowGlyph=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_EyeDomeLighting=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_ForceTime=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_GMVReader=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_H5PartReader=$(usex plugins)
		-DRAVIEW_BUILD_PLUGIN_MobileRemoteControl=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_Moments=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_NonOrthogonalSource=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_PacMan=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_PointSprite=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_PrismPlugin=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_QuadView=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_SLACTools=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_SciberQuestToolKit=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_SierraPlotTools=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_StreamingParticles=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_SurfaceLIC=$(usex plugins)
		-DPARAVIEW_BUILD_PLUGIN_UncertaintyRendering=$(usex plugins)
		# these are always needed for plugins
		-DModule_vtkFiltersFlowPaths=$(usex plugins)
		-DModule_vtkPVServerManagerApplication=$(usex plugins)
		)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install

	# set up the environment
	echo "LDPATH=${EPREFIX}/usr/${PVLIBDIR}" > "${T}"/40${PN} || die

	newicon "${S}"/Applications/ParaView/pvIcon-32x32.png paraview.png
	make_desktop_entry paraview "Paraview" paraview

	use python && python_optimize "${D}"/usr/$(get_libdir)/${PN}-${MAJOR_PV}
}
