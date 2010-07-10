# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/autotest-rails/autotest-rails-4.1.0.ebuild,v 1.9 2009/09/05 18:58:43 ranger Exp $
EAPI=2
USE_RUBY="ruby18"

#RUBY_FAKEGEM_DOCDIR="doc"
#RUBY_FAKEGEM_EXTRADOC="CHANGELOG.rdoc README.rdoc"
#RUBY_FAKEGEM_REQUIRE_PATHS="images sounds"
#RUBY_FAKEGEM_EXTRAINSTALL="images sounds"

RUBY_FAKEGEM_BINWRAP=""

inherit ruby-fakegem

DESCRIPTION="Add a comment summarizing the current schema to rails files."
HOMEPAGE="http://github.com/ctran/annotate_models/"
LICENSE="GPL"

KEYWORDS="amd64 ia64 ppc ppc64 ~sparc x86"
SLOT="0"
IUSE=""

# TODO dependancies are busted since autotest-rails is an old ebuild
#ruby_add_bdepend test "dev-ruby/mocha =dev-ruby/rack-1.0*"
#ruby_add_rdepend '>=dev-ruby/autotest-ruby-4.1.0'

# fix "annotate" file name collision w/ media-libs/gd-2.0.35-r1 
all_ruby_install() {
	elog "Note: annotate command renamed to 'rannotate' to avoid collision with media-libs/gd."
	ruby_fakegem_binwrapper annotate /usr/bin/rannotate
	all_fakegem_install
}

