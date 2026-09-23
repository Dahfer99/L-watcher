all:
	gcc ./src/inotify.c -o ./bin/inotify

install:
	mkdir -p ~/lwatcher
	mkdir -p /opt/lwatcher
	mkdir -p /var/log/lwatcher
	mkdir -p /etc/lwatcher && touch /etc/lwatcher/inotify.config
	cp -r ./scripts /opt/lwatcher/ && cp -r ./bin /opt/lwatcher
	cp lwatcher /opt/lwatcher/
	ln -s /opt/lwatcher/lwatcher /usr/local/bin/lwatcher
	chmod 755 /usr/local/bin/lwatcher
	chmod -R 755 /opt/lwatcher/scripts/*
	cp Makefile /opt/lwatcher/

remove:
	rm -rf /opt/lwatcher
	rm -f /usr/local/bin/lwatcher
	rm -rf /etc/lwatcher

purge:
	rm -rf /opt/lwatcher
	rm -rf /usr/local/bin/lwatcher
	rm -rf ~/lwatcher
	rm -rf /var/log/lwatcher
	rm -rf /etc/lwatcher

.PHONY: clean
clean:
	rm -f ./bin/inotify

