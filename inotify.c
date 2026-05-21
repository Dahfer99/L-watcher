#include <stdio.h>
#include <signal.h> //Gère les signals
#include <stdlib.h>
#include <unistd.h> // gère les I/O system call
#include <string.h> // gère le chaîne de caractère
#include <errno.h> // gère les erreur
#include <limits.h>
#include <dirent.h> // gère les répértoires
#include <sys/inotify.h>
#include <sys/stat.h>

#define EVENT_SIZE sizeof(struct inotify_event)
#define EVENT_BUF_LEN (10 * (EVENT_SIZE + NAME_MAX + 1))

void watch_recursive(const char *path);
void cleanup(int sig);

int fd, wd[32],wd_count;

void watch_recursive(const char *path){

	wd[wd_count] = inotify_add_watch(fd, path, IN_ALL_EVENTS);
	if (wd[wd_count] < 0) { perror(path); return; }
	wd_count++;

	DIR * dirp = opendir(path);
	char full_path[512];
	if (dirp == NULL){
		perror("dirp");
		return;
	}

	struct dirent *entry;
	while ((entry=readdir(dirp)) != NULL){
		if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;
		if ((entry->d_type) == DT_DIR){
			snprintf(full_path, sizeof(full_path), "%s/%s", path, entry->d_name);
			watch_recursive(full_path);
			/* wd[wd_count]= inotify_add_watch(fd, full_path, IN_ALL_EVENTS);
			if (wd[wd_count] < 0) {
				perror("inotify_add_watch - recursive");
				return;
			}
			wd_count++; */
		}

	}
}

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
	int i=0;
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
	
	
	while ((fgets(path, sizeof(path), conf)) != NULL)
	{
		if (path[0] == '#' || path[0] == '\0'){continue;}
		path[strcspn(path, "\n")] = '\0';
		watch_recursive(path); 
		/*wd[i] = inotify_add_watch(fd, path, IN_ALL_EVENTS);
		if (wd[i] < 0)
		{
			perror("inotify_add_watch");
			printf("Check error in the inotify.conf file to fix the problem\n");
			close(fd);
			exit(1);
		}
		i++;
		wd_count++; */
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
