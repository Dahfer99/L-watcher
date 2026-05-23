#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include <signal.h>
#include <dirent.h>
#include <sys/stat.h>

#include <unistd.h>
#include <sys/inotify.h>

// Constant
#define EVENT_SIZE sizeof(struct inotify_event)
#define EVENT_BUF_LEN (10 * (EVENT_SIZE + NAME_MAX + 1))

// Function prototype
void watch_recursive(const char *path);
void cleanup(int sig);

// Global var
int fd; 
int wd[32];
int wd_count;
char wd_path[32][512];

// function
void watch_recursive(const char *path){

	
	wd[wd_count] = inotify_add_watch(fd, path, IN_ALL_EVENTS);
	if (wd[wd_count] < 0) { perror(path); return; }
	snprintf(wd_path[wd_count], 512, "%s", path);
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

// Main
int main(int argc, char **argv)
{
	int i=0;
	FILE *conf;
	char buffer[EVENT_BUF_LEN];
	char path[512];
	
	signal(SIGINT, cleanup);   // Ctrl+C
	signal(SIGTERM, cleanup);  // kill command
	
	
	fd = inotify_init();
	if (fd < 0)
	{
		perror("inotify_init");
		return -1;
	}
	
	conf = fopen("./config/inotify.config", "r");
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
	}
	
	while (1)
	{
		char *ptr = buffer;
		int length = read(fd, buffer, EVENT_BUF_LEN);
		while (ptr < buffer + length)
		{
			struct inotify_event *event = (struct inotify_event *)ptr;
			
			int index = -1;
			for (i=0; i<wd_count; i++){
				if (wd[i] == event->wd){
					index = i;
					break;
				}
			}
			

			if (event->mask & IN_ISDIR)
			{
				if (event->mask & IN_CREATE){
					char full_path[512];
					printf("CREATED:DIRECTORY:%s:%s\n",wd_path[index], event->name);
					fflush(stdout);
					snprintf(full_path, sizeof(full_path), "%s/%s", wd_path[index], event->name);
					watch_recursive(full_path);
				}
				if (event->mask & IN_DELETE){printf("DELETED:DIRECTORY:%s/:%s\n",wd_path[index], event->name); fflush(stdout);}
				if (event->mask & IN_MOVE){printf("MOVED:DIRECTORY:%s/:%s\n",wd_path[index], event->name); fflush(stdout);}
				if (event->mask & IN_ATTRIB ){
					if (!(event->mask & IN_CREATE)){
						printf("ATTRIB:DIRECTORY:%s/:%s\n",wd_path[index], event->name);
						fflush(stdout);
					}

				}
				//if (event->mask & IN_ACCESS ) {printf("%s accessed\n", event->name);}
				// if ( event->mask & IN_MODIFY ) { printf("%s modified\n", event->name);}
				// if ( event->mask & IN_OPEN ) { printf("%s opened\n", event->name);}
				// if ( event->mask & IN_MOVE ) { printf("%s moved\n", event->name);}
				// if ( event->mask & IN_CLOSE ) { printf("%s closed\n", event->name);}
			}

			else

			{
				if (event->mask & IN_CREATE){printf("CREATED:FILE:%s/:%s\n",wd_path[index], event->name); fflush(stdout);}
				if (event->mask & IN_DELETE){printf("DELETED:FILE:%s/:%s\n",wd_path[index], event->name); fflush(stdout);}
				if (event->mask & IN_MODIFY){printf("MODIFIED:FILE:%s/:%s\n",wd_path[index], event->name); fflush(stdout);}
				if (event->mask & IN_MOVE){printf("MOVED:FILE:%s/:%s\n",wd_path[index], event->name); fflush(stdout);}
				if (event->mask & IN_ATTRIB){
					if (!(event->mask & IN_CREATE)){
						printf("ATTRIB:FILE:%s/:%s\n",wd_path[index], event->name); fflush(stdout);
					}
				}
				// if ( event->mask & IN_CLOSE ) { printf("%s closed\n", event->name);}
				// if ( event->mask & IN_ACCESS ) { printf("%s accessed\n", event->name);}
				// if ( event->mask & IN_OPEN ) { printf("%s opened\n", event->name);}
			}

			ptr += EVENT_SIZE + event->len;
		}
	}
	return 0;
}
