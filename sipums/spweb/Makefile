BASEDIR=/var/www/spweb
PHPLIBDIR=/usr/share/php
CONFIGSDIR=$(BASEDIR)/configs
DATADIR=$(BASEDIR)/data_layer
LIBDIR=$(BASEDIR)/lib
STYLEDIR=$(BASEDIR)/style
TEMPLATEDIR=$(BASEDIR)/templates
INSTALL=/usr/bin/install

default: compile
.compiledok : compile
                                                                                                                                               
compile:  
	rm -f .compiledok
install:  .compiledok
	mkdir -p $(BASEDIR)/data_layer
	mkdir -p $(BASEDIR)/lib
	mkdir -p $(BASEDIR)/style
	mkdir -p $(BASEDIR)/templates
	mkdir -p $(PHPLIBDIR)/phplib
	$(INSTALL) -v -m 644 *.php $(BASEDIR)
	$(INSTALL) -v -m 644 data_layer/*.php $(DATADIR)
	$(INSTALL) -v -m 644 lib/*.php $(LIBDIR)
	$(INSTALL) -v -m 644 style/*.css $(STYLEDIR)
	$(INSTALL) -v -m 644 templates/*.tpl $(TEMPLATEDIR)
	$(INSTALL) -v -m 644 phplib/*.inc $(PHPLIBDIR)/phplib
