# gmail - kiosk for the web mailbox
# See LICENSE file for copyright and license details.
.POSIX:

include config.mk

SRC = gmail.c
WSRC = webext-surf.c
OBJ = $(SRC:.c=.o)
WOBJ = $(WSRC:.c=.o)
WLIB = $(WSRC:.c=.so)

all: options gmail $(WLIB)

options:
	@echo gmail build options:
	@echo "CC            = $(CC)"
	@echo "CFLAGS        = $(GMAILCFLAGS) $(CFLAGS)"
	@echo "WEBEXTCFLAGS  = $(WEBEXTCFLAGS) $(CFLAGS)"
	@echo "LDFLAGS       = $(LDFLAGS)"

gmail: $(OBJ)
	$(CC) $(GMAILLDFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

$(OBJ) $(WOBJ): config.h common.h config.mk

config.h:
	cp config.def.h $@

$(OBJ): $(SRC)
	$(CC) $(GMAILCFLAGS) $(CFLAGS) -c $(SRC)

$(WLIB): $(WOBJ)
	$(CC) -shared -Wl,-soname,$@ $(LDFLAGS) -o $@ $? $(WEBEXTLIBS)

$(WOBJ): $(WSRC)
	$(CC) $(WEBEXTCFLAGS) $(CFLAGS) -c $(WSRC)

clean:
	rm -f gmail $(OBJ)
	rm -f config.h
	rm -f $(WLIB) $(WOBJ)

distclean: clean
	rm -f config.h gmail-$(VERSION).tar.gz

dist: distclean
	mkdir -p gmail-$(VERSION)
	cp -R LICENSE Makefile config.mk config.def.h README \
	    arg.h TODO.md \
	    common.h $(SRC) $(WSRC) gmail-$(VERSION)
	tar -cf gmail-$(VERSION).tar gmail-$(VERSION)
	gzip gmail-$(VERSION).tar
	rm -rf gmail-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f gmail $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/gmail
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp -f $(WLIB) $(DESTDIR)$(LIBDIR)
	for wlib in $(WLIB); do \
	    chmod 644 $(DESTDIR)$(LIBDIR)/$$wlib; \
	done

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/gmail
	for wlib in $(WLIB); do \
	    rm -f $(DESTDIR)$(LIBDIR)/$$wlib; \
	done
	- rmdir $(DESTDIR)$(LIBDIR)

.PHONY: all options distclean clean dist install uninstall
