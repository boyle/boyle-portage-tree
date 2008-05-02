# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# NOTE: The comments in this file are for instruction and documentation.  
# They're not meant to appear with your final, production ebuild.  Please
# remember to remove them before submitting or committing your ebuild.  That
# doesn't mean you can't add your own comments though.

# The 'Header' on the third line should just be left alone.  When your ebuild
# will be committed to cvs, the details on that line will be automatically
# generated to contain the correct data.

inherit eutils

DESCRIPTION="SQL-Ledger is a double entry accounting system"
HOMEPAGE="http://www.sql-ledger.org/"
#SRC_URI="ftp://www.sql-ledger.org/source/${P}.tar.gz"
SRC_URI="${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE="latex"
# has to be downloaded from somewhere
RESTRICT="fetch"

# A space delimited list of portage features to restrict. man 5 ebuild
# for details.  Usually not needed.
#RESTRICT="nostrip"

DEPEND=">=dev-lang/perl-5.6.1-r1 
  >=net-www/apache-2.0.54-r31 
  >=dev-db/postgresql-8.0.3 
  >=dev-perl/DBD-Pg-1.22 
  >=dev-perl/DBI-1.46 
  latex? (>=app-text/tetex-2.0.2-r5)"

src_compile() {
	einfo "No compile phase!"
}

src_install() {
	# install the apache module config file
	# TODO .. bad install outside of ${D}
#	cp ${FILESDIR}/99_sql-ledger.conf	/etc/apache2/modules.d/99_sql-ledger.conf || \
#	  die "couldn't install apache modules conf"
	
	# install sql-ledger
	cp -r ${S}/* ${D} || \
	   die "couldn't install sql-ledger"

	# fix permissions
	chown -hR nobody:nogroup ${D}/users ${D}/templates ${D}/css ${D}/spool

	einfo "No setup of the PostgreSQL server is done.. do that youerself!"
	# TODO: if NEW
	# 1. su postgres
	# 2. createuser -d sql-ledger
	# 3. createuser -d -P sql-ledger
	# 4. createlang plpgsql template1
#	6. load admin.pl
#	 7. create datasets for companies
#	  8. add users
#	   
#	       In the Database section enter
#		       
#			       a) PostgreSQL
#				       
#					          Host:     for local connections leave blank
#							         Dataset:  the dataset created in step 7
#									        Port:     for local connections
#											leave blank
#											       User:     sql-ledger
#												          Password: password for
#														  sql-ledger
														  

	# TODO: if upgrading (see setup.pl on website)
	# 1. load admin.pl and lock the system
	# 2. untar the new version over top
	# 3. check the doc directory for specific notes
	# 4. load admin.pl and unlock the system
	# 5. log in
		
	
}

# TODO make a backup of the DB...
pkg_preinst() {
	einfo "TODO make a DB backup in the preinst stage"
}
