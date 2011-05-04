FOOBAR=husk
D_BIN=/usr/local/sbin
D_DOC=/usr/local/share/doc/$(FOOBAR)
D_CNF=/etc/$(FOOBAR)
D_LIB=/var/lib/$(FOOBAR)
D_HELPERS=$(D_CNF)/helpers/

all: bin docs config

install: bin docs config

bin: husk.pl fire.sh
	install -D -m 0755 $(FOOBAR).pl $(DESTDIR)$(D_BIN)/$(FOOBAR)
	install -D -m 0755 fire.sh $(DESTDIR)$(D_BIN)/fire
	install -D -m 0755 fetch-ibl.sh $(DESTDIR)$(D_BIN)/fetch-ibl
	mkdir -p $(DESTDIR)$(D_LIB)

docs: ABOUT README rules.conf.simple rules.conf.standalone LICENSE
	for FILE in ABOUT README rules.conf.simple rules.conf.standalone LICENSE ; do \
		install -D -m 0644 $$FILE $(DESTDIR)$(D_DOC)/$$FILE ; \
	done

config: husk.conf interfaces.conf addr_groups.conf
	# Install Distribution Helper Rule Files
	for FILE in icmp.conf samba.conf apple-ios.conf avg.conf dhcp.conf mail.conf dns.conf snmp.conf sql.conf gotomeeting.conf pptp.conf ; do \
		install -D -m 0444 helpers/$$FILE $(DESTDIR)$(D_HELPERS)/$$FILE ; \
	done
	# Install (without overwriting) configuration files
	for FILE in husk.conf interfaces.conf addr_groups.conf ; do \
		[[ -e $(DESTDIR)$(D_CNF)/$$FILE ]] || install -D -m 0644 $$FILE $(DESTDIR)$(D_CNF)/$$FILE ; \
	done

uninstall:
	rm -f $(DESTDIR)$(D_BIN)/$(FOOBAR)
	rm -f $(DESTDIR)$(D_BIN)/fire
	rm -f $(DESTDIR)$(D_DOC)/*
	rmdir $(DESTDIR)$(D_DOC)/
	rm -Rf $(DESTDIR)$(D_LIB)
	echo "Leaving '$(DESTDIR)$(D_CNF)' untouched"
