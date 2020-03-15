# Special Needs Linux

## Introduction

This repository contains an Ansible playbook for customising Linux to help users with special needs. The aim of this project is to create an Ansible build that converts a Linux installation into something suitable for users (particularly children) with special needs.

For prerequsites and usage instructions, refer to ```INSTALL.md```

-- Rob Pomeroy

Note to self: I'm leaning on Jeff Geerling's approach, for overall structure of the playbook: https://github.com/geerlingguy/mac-dev-playbook

## Licence

This work is licensed under GNU General Public License v3.0. See the ```LICENCE``` file for the text. I'm British, so yes, that's how I spell 'licence'. :-)

## Choice of base OS

An ideal scenario would be to generalise this project so that it could work with almost any mainstream flavour GNU/Linux. At present however, it isn't possible to install KDE on the latest version of CentOS (8.1 at the time of writing). KDE is preferable, due to its built in kiosk framework. So that rules out CentOS/RedHat/Fedora for now.

Ubuntu has a lot of traction, features and support. This makes it an ideal starting point for this project. This Ansible playbook contains some RedHat-focused components; this is in the hope that KDE support becomes available in due course.

## Wish list

These are the general aims for this project:

* Security hardening
  * AppArmor or SELinux
  * Firewall
* Built-in web proxy for safe surfing (squid + DansGuardian)
* Generalise for GNU/Linuxes other than Ubuntu
* Games & apps
  * KTuberling/Potato Guy
  * GCompris
  * TuxMath
  * KDE Edu Suite
  * Tux Paint
* Project-specific customisation
  * Plmouth boot screen
  * Desktop background
  * Menu logo

## Sources for ideas

See existing child-friendly Linux distributions:

* Debian Edu/Skolelinux
* DoudouLinux
* Edubuntu (seems to be obsolete - files aren't available)
* Qimo 4 Kids
* Ubermix
* OpenSUSE: Education-Li-f-e
* LinuxKidX
* KnoSciences
* Elementary Linux OS
* Leeenux Kids
* Educado
* UberStudent
* UKnow4Kids