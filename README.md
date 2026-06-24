# Kolossus

Kolossus est un projet de dotfiles pour un PC portable Arch Linux. Il reprend
la pile de bureau d'Omarchy sans modifier ni dupliquer son dépôt source.

## Principes

- conserver les dotfiles dans ce dossier ;
- déployer uniquement des fichiers explicitement sélectionnés ;
- sauvegarder tout fichier utilisateur remplacé ;
- ne pas gérer le partitionnement, le chiffrement, Secure Boot ou les
  snapshots, déjà configurés par Archinstall ;
- habiller le déverrouillage du disque existant avec Plymouth, sans modifier
  les volumes LUKS ni leurs clés ;
- utiliser Retro-82 comme base visuelle initiale.

## État

La première version comprend Hyprland, les raccourcis principaux d’Omarchy, le
profil portable Omarchy, Waybar, Fuzzel, Mako, SwayOSD et Alacritty aux couleurs
Retro-82. Le déverrouillage LUKS via Plymouth et l’écran de connexion SDDM
reprennent la même palette. Firefox, Thunar et Zed sont les applications par
défaut.

Les dépendances officielles Arch sont documentées dans `REQUIREMENTS.md` et sont
installées par le bootstrap complet.

## Installation complète

Depuis un Arch Linux installé avec Archinstall, lancer avec l’utilisateur normal :

```bash
./bootstrap.sh
```

Le script demande `sudo`, met le système à jour, installe les paquets, active
les services nécessaires, déploie les dotfiles et les thèmes système, puis
valide Hyprland. Il ne touche pas au partitionnement, aux clés LUKS, à Secure
Boot ou aux snapshots.

Pour reprendre une installation dont les paquets sont déjà installés :

```bash
./finish.sh
```

Pour redéployer uniquement les dotfiles :

```bash
./install.sh
```

Pour redéployer uniquement Plymouth et SDDM après les avoir personnalisés :

```bash
./install-system-themes.sh
```

Ce script modifie des fichiers système avec `sudo`, crée des sauvegardes sous
`/var/lib/kolossus/backups/`, conserve les hooks initramfs existants, puis
régénère les images de démarrage. Il prend en charge Limine, GRUB et les
configurations systemd-boot usuelles. Voir `system/README.md` pour modifier les
couleurs, textes, images et prévisualiser SDDM.

Le script utilise des liens symboliques et sauvegarde les fichiers remplacés
sous `~/.local/state/kolossus/backups/`. Il faut ensuite fermer et rouvrir la
session Hyprland.

## Origine

La structure, les raccourcis et la direction visuelle sont adaptés d’Omarchy,
distribué sous licence MIT. Le fond initial provient du thème Retro-82 inclus
dans ce dépôt.
