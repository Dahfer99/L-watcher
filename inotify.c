#include <stdio.h>
#include<signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <sys/inotify.h>

#define EVENT_SIZE sizeof(struct inotify_event)
#define EVENT_BUF_LEN (10 * (EVENT_SIZE + NAME_MAX + 1))



int fd, wd[12],wd_count, i = 0;

void cleanup(int sig){
	for(int i=0; i<wd_count; i++){
		inotify_rm_watch(fd, wd[i]);
	}
	close(fd);
	printf("\nClosing...\n");
	exit(0);
}

int main(int argc, char **argv)
{
	FILE *conf;
	char buffer[EVENT_BUF_LEN];
	char path[512];
	
	signal(SIGINT, cleanup);   // Ctrl+C
	signal(SIGTERM, cleanup);  // kill command
	

	
	// Initialisation de inotify --- Initialize inotify
	fd = inotify_init();
	if (fd < 0)
	{
		perror("inotify_init");
		return -1;
	}
	
	conf = fopen("./config/inotify.config", "r");
	// Verifier si le fichier existe --- check if file exist
	if (conf == NULL)
	{
		perror("config file");
		exit(0);
	}
	
	// Assignation des wd --- Getting wd
	while ((fgets(path, sizeof(path), conf)) != NULL)
	{
		if (path[0] == '#' || path[0] == '\0'){continue;}
		path[strcspn(path, "\n")] = '\0';
		wd[i] = inotify_add_watch(fd, path, IN_ALL_EVENTS);
		if (wd[i] < 0)
		{
			perror("inotify_add_watch");
			printf("Check error in the inotify.conf file to fix the problem\n");
			close(fd);
			exit(1);
		}
		i++;
		wd_count++;
	}
	
	while (1)
	{
		char *ptr = buffer;
		int length = read(fd, buffer, EVENT_BUF_LEN);
		while (ptr < buffer + length)
		{
			struct inotify_event *event = (struct inotify_event *)ptr;
			if (event->mask & IN_ISDIR)
			{
				if (event->mask & IN_CREATE){printf("CREATED:DIRECTORY:%s\n", event->name);}
				if (event->mask & IN_DELETE){printf("DELETED:DIRECTORY:%s\n", event->name);}
				// if ( event->mask & IN_MODIFY ) { printf("%s modified\n", event->name);}
				// if ( event->mask & IN_OPEN ) { printf("%s opened\n", event->name);}
				// if ( event->mask & IN_MOVE ) { printf("%s moved\n", event->name);}
				// if ( event->mask & IN_CLOSE ) { printf("%s closed\n", event->name);}
				// if ( event->mask & IN_ACCESS ) { printf("%s accessed\n", event->name);}
				// if ( event->mask & IN_ATTRIB ) { printf("%s metadata changed\n", event->name);}
			}

			else

			{
				if (event->mask & IN_CREATE){printf("CREATED:FILE:%s\n", event->name);}
				if (event->mask & IN_DELETE){printf("DELETED:FILE:%s\n", event->name);}
				if (event->mask & IN_MODIFY){printf("MODIFIED:FILE:%s\n", event->name);}
				// if ( event->mask & IN_OPEN ) { printf("%s opened\n", event->name);}
				// if ( event->mask & IN_MOVE ) { printf("%s moved\n", event->name);}
				// if ( event->mask & IN_CLOSE ) { printf("%s closed\n", event->name);}
				// if ( event->mask & IN_ACCESS ) { printf("%s accessed\n", event->name);}
				// if ( event->mask & IN_ATTRIB ) { printf("%s metadata changed\n", event->name);}
			}

			ptr += EVENT_SIZE + event->len;
		}
	}
	return 0;
}
