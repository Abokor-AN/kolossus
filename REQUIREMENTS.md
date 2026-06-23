# Dépendances

`packages.txt` contient exclusivement des paquets présents dans les dépôts
officiels Arch Linux. Aucun dépôt Omarchy ou paquet AUR n’est requis.

Le bootstrap installe notamment :

- Niri, Waybar, Fuzzel, Mako, Swayidle, Swaylock et les portails Wayland ;
- Xwayland-satellite pour les applications X11 ;
- Alacritty, Firefox, Thunar et Zed ;
- PipeWire, WirePlumber, SwayOSD et les contrôles multimédias ;
- SDDM, Polkit, GNOME Keyring et les services du portable ;
- les pilotes Intel nécessaires au ThinkPad ;
- les polices et utilitaires utilisés par les raccourcis.

`bootstrap.sh` effectue l’installation complète et retire les paquets listés
dans `obsolete-packages.txt`. `install.sh` reste disponible pour redéployer
uniquement les dotfiles.
