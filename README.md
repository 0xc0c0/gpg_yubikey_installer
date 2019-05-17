# gpg_yubikey_installer
The principal purpose behind this repo is to automate the setup of a linux environment to enable Yubikey (version 4 or later) to be used as a hardware token for SSH authentication.

## linux variants tested:
  - Ubuntu 18.04 
  
## future work
  - Test on Debian
  - Test on older OS variants
  - Port to `zsh` instead of just `bash`

## current prerequisites:
  - Yubikey 4+
  - setup the Yubikey's GPG slot with signing, encryption, and authentication keys
  - publish your public GPG keys to `keys.gnupg.net` or other public GPG service

## usage
  `bash install_gnupg.sh <e-mail address>`
