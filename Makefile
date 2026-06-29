all:
	gcc ./src/inotify.c -o ./bin/inotify

reload:
	rm -f ./bin/inotify
	gcc ./src/inotify.c -o ./bin/inotify

.PHONY: clean
clean:
	rm -f ./bin/inotify

