//
// Created by unnamed on 30/05/2026.
//
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
//#include <errno.h>
#include <unistd.h>
#include <pwd.h>

void trace(char * target, char * username, int u_size)
{
    char proc_path[] = "/proc";
    char path[1024];
    char pid_path[1024];
    char link_path[1024];
    char status_path[1024]; // /proc/[pid]/status
    char buf[1024]; // Stocker le chemin reel du symbolique

    DIR * dirp = opendir(proc_path);
    if (dirp == NULL)
    {
        perror("opendir");
        exit(1);
    }

    struct dirent* entry;
    while ((entry = readdir(dirp)) != NULL)
    {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;
        if (entry->d_type == DT_DIR)
        {
            int PID = atoi(entry->d_name);
            if (PID == 0) continue;

            snprintf(pid_path, 1024, "%s/%s", proc_path, entry->d_name);
            snprintf(path, 1024, "%s/%s/fd/", proc_path, entry->d_name);
            DIR * fd_dirp = opendir(path);
            if (fd_dirp == NULL)
            {
                // perror("open_pid_dir");
                continue;
            }
            struct dirent *fd_entry;
            while ((fd_entry = readdir(fd_dirp)) != NULL)
            {
                snprintf(link_path, 1024, "%s/%s", path, fd_entry->d_name); // /proc/[pid]/fd/
                ssize_t len = readlink(link_path, buf, sizeof(buf) - 1); // avoir le chemin reel
                if (len == -1) continue;
                buf[len] = '\0'; // terminer le chemin avec \0

                if (strcmp(buf, target) == 0)
                {
                    snprintf(status_path, 1024, "%s/status", pid_path);
                    FILE *f = fopen(status_path, "r");
                    if (f == NULL)
                    {
                        // perror("fopen");
                        continue;
                    }

                    char line[256];
                    while (fgets(line, sizeof(line), f) != NULL)
                    {
                        if ((strncmp(line, "Uid:", 4)) == 0)
                        {
                            int uid;
                            sscanf(line, "Uid:\t%d", &uid);

                            struct passwd *pw = getpwuid(uid);
                            if (pw == NULL)
                            {
                                // perror("getpwuid");
                                continue;
                            }

                            snprintf(username, u_size, "%s", pw->pw_name);
                            fclose(f);
                            closedir(fd_dirp);
                            closedir(dirp);
                            return;
                        }
                    }

                }
            }
        }
    }
    snprintf(username, u_size, "%s", "unknown");
    closedir(dirp);
}
