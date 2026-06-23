# Dépendances

Kolossus n'installe aucun paquet. Les configurations supposent la présence des
commandes suivantes :

- bureau : `Hyprland`, `hypridle`, `hyprlock`, `waybar`, `walker`, `elephant` ;
- applications : `alacritty`, `firefox`, `thunar`, `zeditor` ;
- session : `mako`, `swaybg`, `swayosd-server`, `swayosd-client` ;
- contrôle : `brightnessctl`, `playerctl`, `wpctl`, `wiremix`, `impala`, `bluetui` ;
- outils : `btop`, `jq`, `hyprpicker` ;
- capture : `grimblast` ou `hyprshot` ;
- police : `JetBrainsMono Nerd Font`.

Le script `install.sh` vérifie uniquement le déploiement des dotfiles. Il ne
modifie pas les paquets du système.

