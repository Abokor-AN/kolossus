# Dépendances

`packages.txt` contient exclusivement des paquets présents dans les dépôts
officiels Arch Linux. Aucun dépôt Omarchy ou paquet AUR n’est requis.

Le bootstrap installe notamment :

- Hyprland, UWSM, Waybar, Fuzzel, Mako et les portails Wayland ;
- Alacritty, Firefox, Thunar et Zed ;
- PipeWire, WirePlumber, SwayOSD et les contrôles multimédias ;
- SDDM, Polkit, GNOME Keyring et les services du portable ;
- les pilotes Intel nécessaires au ThinkPad ;
- les polices et utilitaires utilisés par les raccourcis.

`bootstrap.sh` effectue l’installation complète. `install.sh` reste disponible
pour redéployer uniquement les dotfiles.
