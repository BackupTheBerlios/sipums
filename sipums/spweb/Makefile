BASEDIR=/var/www/spweb
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
	$(INSTALL) -v -m 644 *.php $(BASEDIR)
	$(INSTALL) -v -m 644 data_layer/*.php $(DATADIR)
	$(INSTALL) -v -m 644 lib/*.php $(LIBDIR)
	$(INSTALL) -v -m 644 style/*.css $(STYLEDIR)
	$(INSTALL) -v -m 644 templates/*.tpl $(TEMPLATEDIR)
