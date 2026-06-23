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

Le bureau utilise Niri et sa disposition en colonnes défilantes, avec Waybar,
Fuzzel, Mako, SwayOSD, Swayidle, Swaylock et Alacritty aux couleurs Retro-82.
Firefox, Thunar et Zed sont les applications par défaut. Xwayland-satellite
assure la compatibilité avec les applications X11.

Les dépendances officielles Arch sont documentées dans `REQUIREMENTS.md` et sont
installées par le bootstrap complet.

## Installation complète

Depuis un Arch Linux installé avec Archinstall, lancer avec l’utilisateur normal :

```bash
./bootstrap.sh
```

Le script demande `sudo`, met le système à jour, installe les paquets, active
les services nécessaires, supprime l’ancienne pile Hyprland, déploie les
dotfiles et valide Niri. Il ne touche
pas au partitionnement, au chiffrement, à Secure Boot ou aux snapshots.

Pour reprendre une installation dont les paquets sont déjà installés :

```bash
./finish.sh
```

Pour redéployer uniquement les dotfiles :

```bash
./install.sh
```

Le script utilise des liens symboliques et sauvegarde les fichiers remplacés
sous `~/.local/state/kolossus/backups/`. Il faut ensuite fermer et rouvrir la
session Niri.

## Origine

La structure, les raccourcis et la direction visuelle sont adaptés d’Omarchy,
distribué sous licence MIT. Le fond initial provient du thème Retro-82 inclus
dans ce dépôt.
