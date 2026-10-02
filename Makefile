PREFIX ?= /usr/local
install:
	install -Dm755 vibefetch.sh $(PREFIX)/bin/vibefetch
uninstall:
	rm -f $(PREFIX)/bin/vibefetch
