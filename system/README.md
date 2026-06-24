# Personnalisation des écrans système

Ces fichiers gèrent deux écrans distincts :

- `plymouth/kolossus/` : le splash de démarrage et la saisie du mot de passe
  LUKS dans l’initramfs ;
- `sddm/kolossus/` : la saisie du mot de passe de l’utilisateur avant la session
  Hyprland.

Après chaque modification, appliquer les thèmes avec :

```bash
./install-system-themes.sh
```

Le script sauvegarde les fichiers système remplacés sous
`/var/lib/kolossus/backups/`, installe les thèmes, ajoute Plymouth aux hooks
`mkinitcpio` avant `encrypt` ou `sd-encrypt`, ajoute `quiet splash` au chargeur
de démarrage reconnu, puis régénère l’initramfs. Il ne crée, ne reformate et ne
modifie aucun volume LUKS.

## Modifier Plymouth / LUKS

Les principaux fichiers sont :

- `plymouth/kolossus/render-assets.sh` pour les couleurs, dimensions, textes et
  formes raster ;
- `plymouth/kolossus/kolossus.script` pour les positions et le comportement ;
- `plymouth/kolossus/kolossus.plymouth` pour les métadonnées.

La palette est déclarée au début de `render-assets.sh`. Les deux couleurs de
fond sont également présentes au début de `kolossus.script`, au format RGB
compris entre 0 et 1.

Plymouth est inclus dans l’initramfs : il faut toujours relancer
`install-system-themes.sh` après une modification. Le résultat complet se
vérifie au redémarrage, au moment où le volume chiffré est demandé.

## Modifier SDDM

Les principaux fichiers sont :

- `sddm/kolossus/theme.conf` pour les couleurs et les textes ;
- `sddm/kolossus/Main.qml` pour la disposition et le comportement ;
- `dotfiles/.config/swaybg/retro-82.jpg` pour l’image de fond partagée avec le
  bureau.

Après installation, prévisualiser le thème sans fermer la session :

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/kolossus
```

Si une connexion automatique SDDM est configurée, elle doit être désactivée pour
que cet écran soit affiché.

La prévisualisation n’effectue pas réellement les actions de connexion,
redémarrage ou extinction. Le thème réel est choisi par
`/etc/sddm.conf.d/zz-kolossus-theme.conf`.

Au premier démarrage, SDDM peut ne pas encore connaître le dernier utilisateur.
L’installateur préremplit donc le champ avec le compte normal qui lance le
script. Ce nom reste visible et modifiable ; il doit correspondre au nom de
compte Unix, pas au nom complet affiché dans d’autres interfaces.

### Récupération depuis un écran de connexion défectueux

Ouvrir un TTY avec `Ctrl+Alt+F3`, se connecter avec le compte Unix, revenir dans
le dépôt puis exécuter `./install-system-themes.sh`. Redémarrer ensuite SDDM avec
`sudo systemctl restart sddm`.

## Chargeur de démarrage non reconnu

L’installateur reconnaît Limine avec `limine-mkinitcpio`, GRUB,
`/etc/kernel/cmdline` et les entrées systemd-boot classiques. Pour un autre
chargeur, il installe tout de même les thèmes et affiche un avertissement. Il
faut alors ajouter manuellement les paramètres noyau suivants avant de relancer
le script :

```text
quiet splash
```
