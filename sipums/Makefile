DISTDIR=/home/kenglish/dist/sipums
BASEDIR=/usr/local/openums
LIBDIR=$(BASEDIR)/lib
INSTALL=/usr/bin/install

DOMAIN_DIRS = $(BASEDIR)/scripts/o-matrix.org $(BASEDIR)/scripts/o-matrix.net $(BASEDIR)/scripts/o-matrix.com
SEMS_SCRIPT= scripts/main.pl

default: compile
.compiledok : compile
                                                                                                                                               
compile:  
	rm -f .compiledok
dist:  .compiledok
#	Make the directories
	mkdir -p $(DISTDIR)/OpenUMS/OpenUMS/Menu 
	mkdir -p $(DISTDIR)/OpenUMS/OpenUMS/Object 
	mkdir -p $(DISTDIR)/OpenUMS/OpenUMS/PhoneSystem 
	mkdir -p $(DISTDIR)/OpenUMS/Telephony
	mkdir -p $(DISTDIR)/OpenUMS/db
	mkdir -p $(DISTDIR)/OpenUMS/bin

	mkdir -p $(DISTDIR)/cgi-bin/templates/reports
	mkdir -p $(DISTDIR)/cgi-bin/OpenUMS/WWW
	mkdir -p $(DISTDIR)/cgi-bin/OpenUMS/WWW
	mkdir -p $(DISTDIR)/scripts

#	Copy the files
	cp  README $(DISTDIR)
	cp  INSTALL $(DISTDIR)
	cp  OpenUMS/Makefile $(DISTDIR)/OpenUMS
	cp  OpenUMS/README $(DISTDIR)/OpenUMS
	cp  OpenUMS/NEWS $(DISTDIR)/OpenUMS
	cp  OpenUMS/LICENSE $(DISTDIR)/OpenUMS
	cp  OpenUMS/make_media_dirs.sh $(DISTDIR)/OpenUMS

	cp  OpenUMS/db/voicemaildb.sql $(DISTDIR)/OpenUMS/db
	cp  OpenUMS/bin/useall $(DISTDIR)/OpenUMS/bin
	cp  OpenUMS/bin/delivermail $(DISTDIR)/OpenUMS/bin


	cp  OpenUMS/OpenUMS/*.pm $(DISTDIR)/OpenUMS/OpenUMS
	cp  OpenUMS/OpenUMS/Menu/*.pm $(DISTDIR)/OpenUMS/OpenUMS/Menu
	cp  OpenUMS/OpenUMS/Object/*.pm $(DISTDIR)/OpenUMS/OpenUMS/Object
	cp  OpenUMS/OpenUMS/PhoneSystem/*.pm $(DISTDIR)/OpenUMS/OpenUMS/PhoneSystem
	cp  OpenUMS/Telephony/*.pm $(DISTDIR)/OpenUMS/Telephony
	 
	cp cgi-bin/*.cgi $(DISTDIR)/cgi-bin
	cp cgi-bin/templates/*.html $(DISTDIR)/cgi-bin/templates
	cp cgi-bin/templates/reports/*.html $(DISTDIR)/cgi-bin/templates/reports
	cp cgi-bin/OpenUMS/WWW/*.pm $(DISTDIR)/cgi-bin/OpenUMS/WWW
	cp scripts/main.pl $(DISTDIR)/scripts/o-matrix.org
	cp scripts/main.pl $(DISTDIR)/scripts/o-matrix.com
	cp scripts/main.pl $(DISTDIR)/scripts/o-matrix.net

	rm -f .compiledok
install:  .compiledok
	cd OpenUMS && make install
	$(INSTALL) -v -m 744 $(SEMS_SCRIPT) $(BASEDIR)/scripts/o-matrix.org/
	$(INSTALL) -v -m 744 $(SEMS_SCRIPT) $(BASEDIR)/scripts/o-matrix.com/
	$(INSTALL) -v -m 744 $(SEMS_SCRIPT) $(BASEDIR)/scripts/o-matrix.net/
