# ------------------------------ #
# Installing additional packages #
#                                #
#  - git / git-flow              #
#  - unzip                       #
#  - figlet                      #
#  - asciinema                   #
#  - mc                          #
#  - python-dev / python-pip     #
#  - sshuttle                    #
#  - jq                          #
#  - bat > cat                   #
#  - ruby                        #
#  - terraform                   #
#  - golang                      #
#  - vault                       #
#  - diff_so_fancy               #
# ------------------------------ #

install_git_staff:
  pkg.installed:
    - pkgs:
      - git
      - git-flow

install_unzip:
  pkg.installed:
    - name: unzip

install_figlet:
  pkg.installed:
    - name: figlet

install_asciinema:
  pkg.installed:
    - name: asciinema

install_mc:
  pkg.installed:
    - name: mc

install_python_staff:
  pkg.installed:
    - pkgs:
      - python-dev
      - python-pip

do_not_upgrade_pip:
  pip.installed:
    - name: pip
    - upgrade: False
    - require:
      - pkg: install_python_staff

install_sshuttle:
  pkg.installed:
    - name: sshuttle

install_jq:
  pkg.installed:
    - name: jq

install_bat:
  pkg.installed:
    - sources:
      - bat: https://github.com/sharkdp/bat/releases/download/v0.6.0/bat_0.6.0_amd64.deb

install_gpg_key_rvm:
  cmd.run:
    - name: gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

install_ruby:
  rvm.installed:
    - name: ruby-2.3.0
    - default: True

{% set rgems = ['bundler'] -%}
{% for gem in rgems -%}
{{ gem }}:
  gem.installed
{% endfor %}

create_terraform_directory:
  file.directory:
    - name: /opt/terraform
    - user: vagrant
    - group: vagrant
    - mode: 755
    - makedirs: True

download_terraform_installer:
  archive.extracted:
    - name: /opt/terraform
    - source: salt://files/terraform_0.11.7_linux_amd64.zip
    - skip_verify: True
    - enforce_toplevel: False
    - trim_output: 5
    - user: vagrant
    - group: vagrant

setup_terraform:
  file.append:
    - name: '/home/vagrant/.profile'
    - text:
      - export PATH=$PATH:/opt/terraform

create_golang_directory:
  file.directory:
    - name: /opt/go
    - user: vagrant
    - group: vagrant
    - mode: 755

download_golang_installer:
  archive.extracted:
    - name: /opt
    - source: salt://files/go1.8.3.linux-amd64.tar.gz
    - skip_verify: True
    - trim_output: 5
    - user: vagrant
    - group: vagrant

setup_golang:
  file.append:
    - name: '/home/vagrant/.profile'
    - text:
      - export PATH=$PATH:/opt/go/bin

create_vault_directory:
  file.directory:
    - name: /opt/vault
    - user: vagrant
    - group: vagrant
    - mode: 755
    - makedirs: True

download_vault_installer:
  archive.extracted:
    - name: /opt/vault
    - source: salt://files/vault_0.9.0_linux_amd64.zip
    - skip_verify: True
    - enforce_toplevel: False
    - trim_output: 5
    - user: vagrant
    - group: vagrant

setup_vault:
  file.append:
    - name: '/home/vagrant/.profile'
    - text:
      - export PATH=$PATH:/opt/vault

create_home_bin_directory:
  file.directory:
    - name: /home/vagrant/bin
    - user: vagrant
    - group: vagrant
    - mode: 755
    - makedirs: True

install_diff_so_fancy:
  file.managed:
    - name: /home/vagrant/bin/diff_so_fancy
    - source: salt://files/diff_so_fancy
    - mode: 755
    - user: vagrant
    - group: vagrant
    - require:
      - create_home_bin_directory  

# --------------------------------------- #
# Installing individual OpenStack clients #
#---------------------------------------- #

## cinder - Block Storage API and extensions ##

install_cinderclient:
  pkg.installed:
    - pkgs:
      - python-cinderclient
    - require:
      - pkg: install_python_staff

## neutron - Networking API ##

install_neutronclient:
  pkg.installed:
    - pkgs:
      - python-neutronclient
    - require:
      - pkg: install_python_staff

## nova - Compute API and extensions ##

install_novaclient:
  pkg.installed:
    - pkgs:
      - python-novaclient
    - require:
      - pkg: install_python_staff

## swift - Object Storage API ##

install_swiftclient:
  pkg.installed:
    - pkgs:
      - python-swiftclient
    - require:
      - pkg: install_python_staff

install_openstackclient:
  pip.installed:
    - name: python-openstackclient
    - upgrade: True
    - require:
      - pkg: install_python_staff

# ---------------------------------------- #
# Script to update/upgrade Ubuntu packages #
# ---------------------------------------- #

create_update_ubuntu_packages:
  file.managed:
    - name: /home/vagrant/update_packages.sh
    - source: salt://files/update_packages.sh
    - mode: 744
    - user: vagrant
    - group: vagrant

run_update_ubuntu_packages:
  cmd.run:
    - name: /home/vagrant/update_packages.sh
    - require:
      - file: create_update_ubuntu_packages

# -------------------------- #
# Git configuration settings #
# -------------------------- #

git_disable_ssl_verify:
  cmd.run:
    - name: git config --global http.sslverify false
    - cwd: ~
    - runas: vagrant

git_user_name:
  cmd.run:
    - name: git config --global user.name ""
    - cwd: ~
    - runas: vagrant

git_user_email:
  cmd.run:
    - name: git config --global user.email ""
    - cwd: ~
    - runas: vagrant

git_credential_helper:
  cmd.run:
    - name: git config --global credential.helper store
    - cwd: ~
    - runas: vagrant

git_pager_diff:
  cmd.run:
    - name: git config --global pager.diff "diff_so_fancy | less --tabs=1,5 -RFX"
    - cwd: ~
    - runas: vagrant
    - require:
      - install_diff_so_fancy

git_pager_show:
  cmd.run:
    - name: git config --global pager.show "diff_so_fancy | less --tabs=1,5 -RFX"
    - cwd: ~
    - runas: vagrant
    - require:
      - install_diff_so_fancy

# ------------------------------------ #
# Create new and manage existing files #
# ------------------------------------ #

/home/vagrant/.hushlogin:
  file.touch

/home/vagrant/.bash_aliases:
  file.touch

setup_aliases:
  file.append:
    - name: '/home/vagrant/.bash_aliases'
    - text:
      - alias cat='bat'

welcome_message:
  file.append:
    - name: '/home/vagrant/.bashrc'
    - text:
      - figlet "Welcome  to  Ubuntu  18.04.1"

# ------------------------------------------------------------------------------ #
# Fix incorrect nameserver for Ubuntu 18 causing problems behind corporate proxy #
# ------------------------------------------------------------------------------ #

remove_resolv_conf:
  cmd.run:
    - name: rm /etc/resolv.conf

create_new_symlink:
  cmd.run:
    - name: ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# ------------------- #
# Prompt modification #
# ------------------- #

add_parse_git_branch_function:
  file.append:
    - name: '/home/vagrant/.bashrc'
    - source: salt://files/parse_git_branch_func
    - require:
      - welcome_message