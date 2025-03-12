# DOT Files

This repo contains all the dotfile configurations for my commonly used tools...

I'm currently using GNU Stow to symlink these files to their config dirs.

The command I used at the great symlink disaster of 2025 is:

```bash
stow <package> -t $HOME
```

This will stow the <package> to the base directory. Just make sure the folder structure within the package folder aligns with where it needs to be relative to the base directory.
