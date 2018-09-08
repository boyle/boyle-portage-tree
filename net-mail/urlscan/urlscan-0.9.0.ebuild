# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6} )

inherit python-r1 distutils-r1 eutils

DESCRIPTION="launch a Web browser for URLs contained in email messages"
HOMEPAGE="https://github.com/firecat53/urlscan"
https://github.com/firecat53/urlscan/archive/0.9.0.tar.gz
SRC_URI="https://github.com/firecat53/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/urwid"
RDEPEND="${DEPEND}"

#src_configure(){
#	python_configure() {
#		./configure || die
#	}
#	python_foreach_impl python_configure
#}
#
#src_compile() {
#	python_compile() {
#	}
#	python_foreach_impl python_compile
#}

#src_test() {
##	python_foreach_impl python_test
#    cat > test <<EOF
##! /usr/bin/python3
#import tensorflow as tf
#hello = tf.constant('hello world')
#sess = tf.Session()
#print(sess.run(hello))
#EOF
#    chmod +x test
#	./test || die
#}

#src_install() {
#	python_install() {
#		# steal site-package path determination from sci-mathematics/z3
#		local PYTHON_SITEDIR
#		python_export PYTHON_SITEDIR
#		cp -av tensorflow_pkg/"${P}".data/purelib/tensorflow/ "$PYTHON_SITEDIR" || die
#		cp -av tensorflow_pkg/"${P}".dist-info "$PYTHON_SITEDIR" || die
#		# mkdir -p "${D}/usr/$(get_libdir)/python3.6/site-packages" || die
#		# cp -av tensorflow_pkg/"${P}".data/purelib/tensorflow/ "${ED}/usr/$(get_libdir)/python3.6/site-packages/" || die
#		# cp -av tensorflow_pkg/"${P}".dist-info "${ED}/usr/$(get_libdir)/python3.6/site-packages/" || die
#	}
#	python_foreach_impl python_install
#	einstalldocs
#}
