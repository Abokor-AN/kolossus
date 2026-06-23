# Kolossus

Kolossus est un projet de dotfiles pour un PC portable Arch Linux. Il reprend
la pile de bureau d'Omarchy sans modifier ni dupliquer son dépôt source.

## Principes

- conserver les dotfiles dans ce dossier ;
- déployer uniquement des fichiers explicitement sélectionnés ;
- sauvegarder tout fichier utilisateur remplacé ;
- ne pas gérer le partitionnement, le chiffrement, Secure Boot ou les
  snapshots, déjà configurés par Archinstall ;
- utiliser Retro-82 comme base visuelle initiale.

## État

La première version comprend Hyprland, les raccourcis principaux d’Omarchy, le
profil portable Omarchy, Waybar, Walker, Mako, SwayOSD et Alacritty aux couleurs
Retro-82. Firefox, Thunar et Zed sont les applications par défaut.

Les dépendances sont documentées dans `REQUIREMENTS.md` mais ne sont pas
installées automatiquement.

## Déploiement

Vérifier les dépendances, puis lancer :
```bash
./check.sh
```

Puis déployer :

```bash
./install.sh
```

Le script utilise des liens symboliques et sauvegarde les fichiers remplacés
sous `~/.local/state/kolossus/backups/`. Il faut ensuite fermer et rouvrir la
session Hyprland.

## Origine

La structure, les raccourcis et la direction visuelle sont adaptés d’Omarchy,
distribué sous licence MIT. Le fond initial provient du thème Retro-82 inclus
dans ce dépôt.
