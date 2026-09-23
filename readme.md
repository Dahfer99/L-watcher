# Lwatcher

L-Watcher is a FIM tool designed for Linux. It monitors in real time one or more user-configured directories, detects every event that occurs on the file system such as creation, modification, deletion, moving, or permission changes of a file, and produces a structured and readable trace.

# Installation

```bash
# Compile the source code
make

# Install automatically
sudo make install

# Verify the installation
which lwatcher
```

>**Note:** You must be logged in as `root` to use lwatcher

# Uninstallation
```bash
# only uninstall but keep the backup and log files
make remove

# delete all files related to lwatcher
make purge
```