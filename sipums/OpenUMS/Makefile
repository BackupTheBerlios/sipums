BASEDIR=/usr/local/openums
LIBDIR=$(BASEDIR)/lib
INSTALL=/usr/bin/install

OPENUMS_LIBS= OpenUMS/CallOut.pm OpenUMS/Common.pm OpenUMS/DbQuery.pm OpenUMS/GlobalSettings.pm \
              OpenUMS/Holidays.pm OpenUMS/Log.pm OpenUMS/PhoneSystem.pm \
              OpenUMS/CallRecorder.pm OpenUMS/Config.pm OpenUMS/DbUtils.pm OpenUMS/Greeting.pm \
              OpenUMS/IMAP.pm OpenUMS/SipUmsMwi.pm OpenUMS/Permissions.pm 
                                                                                                                                               
MENU_LIBS =  OpenUMS/Menu/AAGMP.pm OpenUMS/Menu/AdminMP.pm OpenUMS/Menu/AppendMsgMP.pm \
             OpenUMS/Menu/AutoAttendantMP.pm OpenUMS/Menu/DbnmMP.pm OpenUMS/Menu/DbnmResultMP.pm \
             OpenUMS/Menu/ExtensionMP.pm OpenUMS/Menu/ForwardMessageMP.pm \
             OpenUMS/Menu/InfoMP.pm OpenUMS/Menu/IntroMP.pm OpenUMS/Menu/Menu.pm \
             OpenUMS/Menu/MenuProcessor.pm OpenUMS/Menu/MessageMP.pm OpenUMS/Menu/PasswordMP.pm \
             OpenUMS/Menu/PostRecMsgMP.pm OpenUMS/Menu/RecMsgMP.pm OpenUMS/Menu/UserSettingsMP.pm
                                                                                                                                               
OBJ_LIBS = OpenUMS/Object/DbnmSpool.pm OpenUMS/Object/ForwardMessageObj.pm OpenUMS/Object/MessageObj.pm  \
           OpenUMS/Object/MessageSpool.pm OpenUMS/Object/User.pm OpenUMS/Object/IpAddress.pm \
           OpenUMS/Object/Prompt.pm OpenUMS/Object/SoundVariables.pm
                                                                                                                                               
PHONESYS_LIBS = OpenUMS/PhoneSystem/PhoneSystemBase.pm OpenUMS/PhoneSystem/SIP.pm 

CTPORT_LIBS = Telephony/CTPortJr.pm Telephony/SemsIvr.pm

DELIVER_MAIL = bin/delivermail
PURGE_DELETE = bin/purge_delete
ADD_VM_USER = bin/addvmuser
DEL_VM_USER = bin/deletevmuser
SIPUMS_MYSQL_PASSORD = olseh

LIBS = $(OPENUMS_LIBS) $(MENU_LIBS) $(OBJ_LIBS)

default: compile
.compiledok : compile
                                                                                                                                               
compile: $(LIBS)
	rm -f .compiledok
	touch .compiledok
	perl -wc  bin/useall
	perl -wc -I .  bin/delivermail
install: $(LIBS)  .compiledok
	mkdir -p $(LIBDIR)
#	cd OpenUMS && make install
#	cd Telephony && make install
	mkdir -p $(LIBDIR)/OpenUMS
	mkdir -p $(LIBDIR)/OpenUMS/Menu
	mkdir -p $(LIBDIR)/OpenUMS/Object
	mkdir -p $(LIBDIR)/OpenUMS/PhoneSystem
	mkdir -p $(LIBDIR)/Telephony
#   replace mysql password        
	$(INSTALL) -D -v -m 644 $(OPENUMS_LIBS) $(LIBDIR)/OpenUMS
	$(INSTALL) -D -v -m 644 $(MENU_LIBS) $(LIBDIR)/OpenUMS/Menu
	$(INSTALL) -D -v -m 644 $(OBJ_LIBS) $(LIBDIR)/OpenUMS/Object
	$(INSTALL) -D -v -m 644 $(PHONESYS_LIBS) $(LIBDIR)/OpenUMS/PhoneSystem
	$(INSTALL) -D -v -m 644 $(CTPORT_LIBS) $(LIBDIR)/Telephony
	$(INSTALL) -v -m 774 $(PURGE_DELETE) $(BASEDIR)/
	$(INSTALL) -v -m 774 $(DELIVER_MAIL) $(BASEDIR)/
	$(INSTALL) -v -m 774 $(ADD_VM_USER) $(BASEDIR)/
	$(INSTALL) -v -m 774 $(DEL_VM_USER) $(BASEDIR)/
	# remove change the password
	perl -pi -e " s/SIPUMS_MYSQL_PASSORD/$(SIPUMS_MYSQL_PASSORD)/g; " $(LIBDIR)/OpenUMS/Config.pm
	rm -f .compiledok
