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
      - [Great blog post on setting this up](https://www.esev.com/blog/post/2015-01-pgp-ssh-key-on-yubikey-neo/ "Eric Severance's Blog Post")
  - publish your public GPG keys to `keys.gnupg.net` or other public GPG service (this is also covered by the blog post)

## usage
  `bash install_gnupg.sh <e-mail address>`

## other notes
How to remove specific ssh keys from keyring:

### list all keys to identify which one
`ssh-add -L`

### list all md5 key hashes to match that with previous step
`ssh-add -E md5 -l`

### list all md5 key hashes of those stored in gpg
`gpg-connect-agent 'keyinfo --ssh-list --ssh-fpr'`
then remove the appropriate entry from ~/.gnupg/sshcontrol
remove the file in ~/.gnupg/private-keys-v1.d/
