all:
	gcc ./src/inotify.c ./src/trace.c -o ./bin/inotify

.PHONY: clean
clean:
	rm -f ./bin/inotify

