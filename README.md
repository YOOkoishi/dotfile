### yoo 的配置 合集

包含了 nvim kitty vim 还有 zsh ，暂时存这些

使用 stow 进行dotfile的链接，在新设备使用时先确保设备上不存在配置文件 如 `.config/nvim/*` ，如果有，先删除。

然后使用 

```bash
stow -t ~ nvim
stow -t ~ vim
stow -t ~ zsh
stow -t ~ kitty
```

来导入配置文件，然后就可以愉快的进行 dotfile 的管理了
