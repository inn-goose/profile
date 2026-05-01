#! /usr/bin/env bash

set -x

rm -rf ~/.local/.profile

mkdir ~/.local/
mkdir ~/.local/bin

git clone https://github.com/inn-goose/profile.git ~/.local/.profile
rm -rf ~/.local/.profile/.git

ln -sf ~/.local/.profile/home/.bash_local ~/.bash_local
ln -sf ~/.local/.profile/home/.bash_profile ~/.bash_profile
ln -sf ~/.local/.profile/home/.bashrc ~/.bashrc
ln -sf ~/.local/.profile/home/.git-completion.bash ~/.git-completion.bash
ln -sf ~/.local/.profile/home/.inputrc ~/.inputrc
#ln -sf ~/.local/.profile/home/.python_startup ~/.python_startup
ln -sf ~/.local/.profile/home/.screenrc ~/.screenrc
#ln -sf ~/.local/.profile/home/.tmux.conf ~/.tmux.conf
ln -sf ~/.local/.profile/home/.vim/ ~/.vim
ln -sf ~/.local/.profile/home/.vimrc ~/.vimrc

ln -sf ~/.local/.profile/bin/sys_info ~/.local/bin/sys_info
#ln -sf ~/.local/.profile/bin/add_rsa_keys ~/.local/bin/add_rsa_keys
#ln -sf ~/.local/.profile/bin/grab_ssh_agent ~/.local/bin/grab_ssh_agent
