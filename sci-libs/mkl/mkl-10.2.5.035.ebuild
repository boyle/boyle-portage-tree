# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/mkl/mkl-10.0.5.025.ebuild,v 1.4 2010/06/17 01:54:40 jsbronder Exp $

inherit eutils toolchain-funcs fortran check-reqs #flag-o-matic

PID=1753
PB=${PN}
DESCRIPTION="Intel(R) Math Kernel Library: linear algebra, fft, math functions"
HOMEPAGE="http://developer.intel.com/software/products/mkl/"
SRC_URI="http://registrationcenter-download.intel.com/irc_nas/${PID}/l_${PN}_p_${PV}.tar.gz"

KEYWORDS="-* ~amd64 ~ia64 ~x86"
SLOT="0"
LICENSE="Intel-SDP"
IUSE="doc fftw fortran95 int64 mpi"
RESTRICT="strip mirror"

DEPEND="app-admin/eselect-blas
	app-admin/eselect-cblas
	app-admin/eselect-lapack"
RDEPEND="${DEPEND}
	doc? ( app-doc/blas-docs app-doc/lapack-docs )
	mpi? ( virtual/mpi )"

MKL_DIR=/opt/intel/${PN}/${PV}
INTEL_LIC_DIR=/opt/intel/licenses

# TODO FIXME: something more specific here?
# Note: there are a ton of EXECSTACK files and they're binary source
#QA_EXECSTACK_amd64="opt/intel/${PN}/${PV}/lib/em64t/.*.a:.*
#					opt/intel/${PN}/${PV}/lib/em64t/.*.so"
QA_EXECSTACK="*"

# text relocations: only one -- libmkl_def.so
QA_TEXTRELS="*"

pkg_setup() {
	# Check the license
	if [[ -z ${MKL_LICENSE} ]]; then
		MKL_LICENSE="$(grep -ls MKern ${ROOT}${INTEL_LIC_DIR}/* | tail -n 1)"
		MKL_LICENSE=${MKL_LICENSE/${ROOT}/}
	fi
	if  [[ -z ${MKL_LICENSE} ]]; then
		eerror "Did not find any valid mkl license."
		eerror "Register at ${HOMEPAGE} to receive a license"
		eerror "and place it in ${INTEL_LIC_DIR} or run:"
		eerror "export MKL_LICENSE=/my/license/file emerge mkl"
		die "license setup failed"
	fi

	# TODO FIXME - a patch that adds the following snippet to .S files is
	# preferred:
#	#if defined(__linux__) && defined(__ELF__)
#	.section .note.GNU-stack,"",%progbits
#	#endif
	# instead fix CFLAGS to create non-executable .so (assembly)
#	append-flags -Wa,--noexecstack
	# instead fix CFLAGS to create non-executable .so (linker)
#	append-ldflags -Wl,-z,noexecstack

	# Check if we have enough free diskspace to install
	CHECKREQS_DISK_BUILD="1100"
	check_reqs

	# Check and setup fortran
	FORTRAN="gfortran ifc g77"
	use int64 && FORTRAN="gfortran ifc"
	if use fortran95; then
		FORTRAN="gfortran ifc"
		# blas95 and lapack95 don't compile with gfortran < 4.2
		[[ $(gcc-major-version)$(gcc-minor-version) -lt 42 ]] && FORTRAN="ifc"
	fi
	fortran_pkg_setup
	MKL_FC="gnu"
	[[ ${FORTRANC} == if* ]] && MKL_FC="intel"

	# build profiles according to what compiler is installed
	MKL_CC="gnu"
	[[ $(tc-getCC) == icc ]] && MKL_CC="intel"

	if has_version sys-cluster/mpich; then
		MKL_MPI=mpich
	elif has_version sys-cluster/mpich2; then
		MKL_MPI=mpich2
	elif has_version sys-cluster/openmpi; then
		MKL_MPI=openmpi
	else
		MKL_MPI=intelmpi
	fi
}

src_unpack() {

	unpack ${A}
	cd l_${PN}_*_${PV}

	cp ${MKL_LICENSE} "${WORKDIR}"/
	MKL_LIC="$(basename ${MKL_LICENSE})"

	# binary blob extractor installs rpm leftovers in /opt/intel
	addwrite /opt/intel
	addwrite /usr/local/share/macrovision
	# undocumented features: INSTALLMODE_mkl=NONRPM

	# We need to install mkl non-interactively.
	# If things change between versions, first do it interactively:
	# tar xf l_*; ./install.sh --duplicate mkl.ini;
	# The file will be instman/mkl.ini
	# Then check it and modify the ebuild-created one below
	# --norpm is required to be able to install 10.x
		#[MKL]
	cat > mkl.ini <<-EOF
		PSET_LICENSE_FILE=${WORKDIR}/${MKL_LIC}
		ACTIVATION=license_file
		CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes
		CONTINUE_WITH_OPTIONAL_ERROR=yes
		PSET_INSTALL_DIR=${S}
		INSTALL_MODE=NONRPM
		ACCEPT_EULA=accept
	EOF
	einfo "Extracting ..."

	# make sure the install doesn't fail because of a previous failed install
	rm -f /opt/intel/.*mkl*.log /opt/intel/intel_sdp_products.db
	# test that the install script exists
	./install.sh \
		--silent ./mkl.ini \
		&> ./log.txt

	if [[ -z $(find "${S}/lib" -name libmkl_core.so) ]]; then
		eerror "Could not find extracted files"
		eerror "expected at ${S} (lib/libmkl_core.so)"
		eerror "See ${PWD}/log.txt to see why"
		die "extracting failed"
	fi
	# remove left over
	rm -f /opt/intel/.*mkl*.log /opt/intel/intel_sdp_products.db
	rm -rf ${S}/tmp*
	# clean up macrovision junk
	rm -f /usr/local/share/macrovision/storage/FLEXnet/INTEL_*.data
	rmdir --ignore-fail-on-non-empty /usr/local/share/macrovision/storage/FLEXnet
	rmdir --ignore-fail-on-non-empty /usr/local/share/macrovision/storage
	rmdir --ignore-fail-on-non-empty /usr/local/share/macrovision
	# remove unused stuff and set up intel names
	rm -rf "${WORKDIR}"/l_*

	cd "${S}"
	# allow openmpi to work
	epatch "${FILESDIR}"/${PN}-10.0.2.018-openmpi.patch
	# make scalapack tests work for gfortran
	#epatch "${FILESDIR}"/${PN}-10.0.2.018-tests.patch
	case ${ARCH} in
		x86)	MKL_ARCH=32
				MKL_KERN=ia32
				rm -rf lib*/{em64t,64}
				;;

		amd64)	MKL_ARCH=em64t
				MKL_KERN=em64t
				rm -rf lib*/{32,64}
				;;

		ia64)	MKL_ARCH=64
				MKL_KERN=ipf
				rm -rf lib*/{32,em64t}
				;;
	esac
	MKL_LIBDIR=${MKL_DIR}/lib/${MKL_ARCH}
	# fix env scripts
	sed -i \
		-e "s:${S}:${MKL_DIR}:g" \
		tools/environment/*sh || die "sed support file failed"
}

src_compile() {
	cd "${S}"/interfaces
	if use fortran95; then
		einfo "Compiling fortan95 static lib wrappers"
		# TODO INSTALL_DIR should be to somewhere that will get installed??
		local myconf="lib${MKL_ARCH} INSTALL_DIR=lib95"
		[[ ${FORTRANC} == gfortran ]] && \
			myconf="${myconf} FC=gfortran"
		if use int64; then
			myconf="${myconf} interface=ilp64"
			[[ ${FORTRANC} == gfortran ]] && \
				myconf="${myconf} FOPTS=-fdefault-integer-8"
		fi
		for x in blas95 lapack95; do
			pushd ${x}
			emake ${myconf} || die "emake ${x} failed"
			popd
		done
	fi

	if use fftw; then
		local fftwdirs="fftw2xc fftw2xf fftw3xc fftw3xf"
		# fftw makefile has dependancy issues w/ -j5... force -j1
		local myconf="-j1 lib${MKL_ARCH} compiler=${MKL_CC}"
		if use mpi; then
			fftwdirs="${fftwdirs} fftw2x_cdft"
			myconf="${myconf} mpi=${MKL_MPI}"
		fi
		einfo "Compiling fftw static lib wrappers"
		for x in ${fftwdirs}; do
			pushd ${x}
			emake ${myconf} || die "emake ${x} failed"
			popd
		done
	fi
}

src_test() {
	cd "${S}"/tests
	local myconf
	local testdirs="blas cblas"
	use int64 && myconf="${myconf} interface=ilp64"
	# buggy with g77 and gfortran
	#if use mpi; then
	#	testdirs="${testdirs} scalapack"
	#	myconf="${myconf} mpi=${MKL_MPI}"
	#fi
	for x in ${testdirs}; do
		pushd ${x}
		einfo "Testing ${x}"
		emake \
			compiler=${MKL_FC} \
			${myconf} \
			so${MKL_ARCH} \
			|| die "emake ${x} failed"
		popd
	done
}

mkl_make_generic_profile() {
	cd "${S}"
	# produce eselect files
	# don't make them in FILESDIR, it changes every major version
	cat  > eselect.blas <<-EOF
		${MKL_LIBDIR}/libmkl_${MKL_KERN}.a /usr/@LIBDIR@/libblas.a
		${MKL_LIBDIR}/libmkl_core.so /usr/@LIBDIR@/libblas.so
		${MKL_LIBDIR}/libmkl_core.so /usr/@LIBDIR@/libblas.so.0
	EOF
	cat  > eselect.cblas <<-EOF
		${MKL_LIBDIR}/libmkl_${MKL_KERN}.a /usr/@LIBDIR@/libcblas.a
		${MKL_LIBDIR}/libmkl_core.so /usr/@LIBDIR@/libcblas.so
		${MKL_LIBDIR}/libmkl_core.so /usr/@LIBDIR@/libcblas.so.0
		${MKL_DIR}/include/mkl_cblas.h /usr/include/cblas.h
	EOF
	cat > eselect.lapack <<-EOF
		${MKL_LIBDIR}/libmkl_lapack.a /usr/@LIBDIR@/liblapack.a
		${MKL_LIBDIR}/libmkl_lapack.so /usr/@LIBDIR@/liblapack.so
		${MKL_LIBDIR}/libmkl_lapack.so /usr/@LIBDIR@/liblapack.so.0
	EOF
}

# usage: mkl_add_profile <profile> <interface_lib> <thread_lib> <rtl_lib>
mkl_add_profile() {
	cd "${S}"
	local prof=${1}
	for x in blas cblas lapack; do
		cat > ${x}-${prof}.pc <<-EOF
			prefix=${MKL_DIR}
			libdir=${MKL_LIBDIR}
			includedir=\${prefix}/include
			Name: ${x}
			Description: Intel(R) Math Kernel Library implementation of ${x}
			Version: ${PV}
			URL: ${HOMEPAGE}
		EOF
		einfo "AB TODO 0 ${x}-${prof}"
		cat ${x}-${prof}.pc
	done
einfo "AB TODO 1 cblas-${prof}"
cat cblas-${prof}.pc
	cat >> blas-${prof}.pc <<-EOF
		Libs: -Wl,--no-as-needed -L\${libdir} -Wl,--start-group,${2},${3},-lmkl_core,--end-group ${4} -lpthread
	EOF
einfo "AB TODO cblas 1"
	cat >> cblas-${prof}.pc <<-EOF
		Requires: blas
		Libs: -Wl,--no-as-needed -L\${libdir} -Wl,--start-group,${2},${3},-lmkl_core,--end-group ${4} -lpthread
		Cflags: -I\${includedir}
	EOF
einfo "AB TODO 2 cblas-${prof}"
cat cblas-${prof}.pc
	cat >> lapack-${prof}.pc <<-EOF
		Requires: blas
		Libs: -Wl,--no-as-needed -L\${libdir} -Wl,--start-group,${2},${3},-lmkl_core,-lmkl_lapack,--end-group ${4} -lpthread
	EOF
	insinto ${MKL_LIBDIR}
	for x in blas cblas lapack; do
		doins ${x}-${prof}.pc
		cp eselect.${x} eselect.${x}.${prof}
		echo "${MKL_LIBDIR}/${x}-${prof}.pc /usr/@LIBDIR@/pkgconfig/${x}.pc" \
			>> eselect.${x}.${prof}
		eselect ${x} add $(get_libdir) eselect.${x}.${prof} ${prof}
	done
}

mkl_make_profiles() {
	local clib
	has_version 'dev-lang/ifc' && clib="intel"
	built_with_use sys-devel/gcc fortran && clib="${clib} gf"
	local slib="-lmkl_sequential"
	local rlib="-fopenmp" #GCC 4.2 is now unmasked, so use gnu openmp impl. (was -liomp5)
	local pbase=${PN}
	for c in ${clib}; do
		local ilib="-lmkl_${c}_lp64"
		use x86 && ilib="-lmkl_${c}"
		local tlib="-lmkl_${c/gf/gnu}_thread"
		local comp="${c/gf/gfortran}"
		comp="${comp/intel/ifort}"
		mkl_add_profile ${pbase}-${comp} ${ilib} ${slib}
		mkl_add_profile ${pbase}-${comp}-threads ${ilib} ${tlib} ${rlib}
		if use int64; then
			ilib="-lmkl_${c}_ilp64"
			mkl_add_profile ${pbase}-${comp}-int64 ${ilib} ${slib}
			mkl_add_profile ${pbase}-${comp}-threads-int64 ${ilib} ${tlib} ${rlib}
		fi
	done
}

src_install() {
	dodir ${MKL_DIR}

	# install license
	if  [[ ! -f ${INTEL_LIC_DIR}/${MKL_LIC} ]]; then
		insinto ${INTEL_LIC_DIR}
		doins "${WORKDIR}"/${MKL_LIC} || die "install license failed"
	fi

	# install main stuff: cp faster than doins
	einfo "Installing files..."
	local cpdirs="benchmarks doc include interfaces lib man"
	# skip: examples tests
	local doinsdirs="tools"
	cp -pPR ${cpdirs} "${D}"${MKL_DIR} \
		|| die "installing mkl failed"
	insinto ${MKL_DIR}
	doins -r ${doinsdirs} || die "doins ${doinsdirs} failed"
	dosym mkl_cblas.h ${MKL_DIR}/include/cblas.h

	# install blas/lapack profiles
	mkl_make_generic_profile
	mkl_make_profiles

	# install env variables
	cat > 35mkl <<-EOF
		MKLROOT=${MKL_DIR}
		LDPATH=${MKL_LIBDIR}
		MANPATH=${MKL_DIR}/man
	EOF
	doenvd 35mkl || die "doenvd failed"
}

pkg_postinst() {
	# if blas profile is mkl, set lapack and cblas profiles as mkl
	local blas_prof=$(eselect blas show | cut -d' ' -f2)
	local def_prof="mkl-gfortran-threads"
	has_version 'dev-lang/ifc' && def_prof="mkl-ifort-threads"
	use int64 && def_prof="${def_prof}-int64"
	for x in blas cblas lapack; do
		local cur_prof=$(eselect ${x} show | cut -d' ' -f2)
		if [[ -z ${cur_prof} ||	${cur_prof} == ${def_prof} ]]; then
			# work around eselect bug #189942
			local configfile="${ROOT}"/etc/env.d/${x}/$(get_libdir)/config
			[[ -e ${configfile} ]] && rm -f ${configfile}
			eselect ${x} set ${def_prof}
			elog "${x} has been eselected to ${def_prof}"
		else
			elog "Current eselected ${x} is ${current_lib}"
			elog "To use one of mkl profiles, issue (as root):"
			elog "\t eselect ${x} set <profile>"
		fi
		if [[ ${blas_prof} == mkl* && ${cur_prof} != ${blas_prof} ]]; then
			eselect blas set ${def_prof}
			elog "${x} is now set to ${def_prof} for consistency"
		fi
	done
	if [[ $(gcc-major-version)$(gcc-minor-version) -lt 42 ]]; then
		elog "Multi-threading OpenMP for GNU compilers only available"
		elog "with gcc >= 4.2. Make sure you have a compatible version"
		elog "and select it with gcc-config before selecting gnu profiles"
	fi
}
