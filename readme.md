# Lwatcher

L-Watcher est un outil FIM conçu pour Linux. Il surveille en temps réel un ou plusieurs répertoires configurés par l'utilisateur, détecte chaque événement survenu sur le système de fichiers comme création, modification, suppression, déplacement, changement de permissions d'un fichier et en produit une trace structurée et lisible.

# Installation

```bash
# Compiler le code source
make

# Installer automatiquement
sudo make install

# Verifier l'installation
which lwatcher
```

>**Note :** Il faut se connecter en tant que `root` pour utiliser lwatcher

# Desinstallation
```bash
# seulemnt desinstaller mais garde les fichiers de sauvegarde et log
make remove

# supprimer tous les fichiers en relation avec lwatcher
make purge
```