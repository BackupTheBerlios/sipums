# $Id: Makefile,v 1.1 2004/07/20 03:01:04 richardz Exp $

BASEDIR=/usr/local/openums
LIBDIR=$(BASEDIR)/lib
INSTALL=/usr/bin/install

OPENUMS_LIBS= CallOut.pm Common.pm DbQuery.pm GlobalSettings.pm \
              Holidays.pm Log.pm PhoneSystem.pm \
              CallRecorder.pm Config.pm DbUtils.pm Greeting.pm \
              IMAP.pm Mwi.pm Permissions.pm

MENU_LIBS =  Menu/AAGMP.pm Menu/AdminMP.pm Menu/AppendMsgMP.pm \
             Menu/AutoAttendantMP.pm Menu/DbnmMP.pm Menu/DbnmResultMP.pm \
             Menu/ExtensionMP.pm Menu/ForwardMessageMP.pm \
             Menu/InfoMP.pm Menu/IntroMP.pm Menu/Menu.pm \
             Menu/MenuProcessor.pm Menu/MessageMP.pm Menu/PasswordMP.pm \
             Menu/PostRecMsgMP.pm Menu/RecMsgMP.pm Menu/UserSettingsMP.pm

OBJ_LIBS = Object/DbnmSpool.pm Object/ForwardMessageObj.pm Object/MessageObj.pm  \
           Object/MessageSpool.pm Object/User.pm Object/IpAddress.pm

PHONESYS_LIBS = PhoneSystem/Comdial.pm PhoneSystem/Mwi.pm PhoneSystem/NECAspire.pm \
                PhoneSystem/PhoneSystemBase.pm

LIBS = $(OPENUMS_LIBS) $(MENU_LIBS) $(OBJ_LIBS)

default: compile
.compiledok : compile

compile: $(LIBS)
	rm -f .compiledok
	perl -wcT -I.. ../tools/useall
	touch .compiledok

install: $(LIBS) .compiledok
	sudo $(INSTALL) -D -v -m 644 -o openums -g openums $(OPENUMS_LIBS) $(LIBDIR)/OpenUMS
	sudo $(INSTALL) -D -v -m 644 -o openums -g openums $(MENU_LIBS) $(LIBDIR)/OpenUMS/Menu
	sudo $(INSTALL) -D -v -m 644 -o openums -g openums $(OBJ_LIBS) $(LIBDIR)/OpenUMS/Object
	sudo $(INSTALL) -D -v -m 644 -o openums -g openums $(PHONESYS_LIBS) $(LIBDIR)/OpenUMS/PhoneSystem
	rm -f .compiledok

