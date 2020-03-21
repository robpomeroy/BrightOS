# Special Needs Linux

## Introduction

The world of special needs is largely unseen - until you are thrust into it. This is the position my wife and I found ourselves in, in 2004, when she gave birth to our twins Morgan and James. Due to a [condition during pregnancy](https://en.wikipedia.org/wiki/Twin-to-twin_transfusion_syndrome) our boys both have profound special needs. Morgan has severe spastic cerebral palsy, is quadriplegic and vision impaired. James has severe learning difficulties, is on the autistic spectrum and suffers from anxiety.

The following years have been a massive learning experience and, I hope, character building! What has become abundantly apparent is that there are gaps in the market, for all sorts of specialist provision. And that where specialist provision *does* exist, applying the label "disabled" or "adapated" to any product or service reduces its market and increases its cost, dramatically. (A specialist bath for Morgan comes in at £10,000, or thereabouts.)

It does not have to be costly, to meet computing needs. This open source (free!) repository contains an [Ansible](https://www.ansible.com/) playbook for customising Linux to help users with special needs. The aim of this project is to create an Ansible build that converts a Linux installation into something suitable for users (particularly children) with special needs.

For prerequsites and usage instructions, refer to ```INSTALL.md```

-- [Rob Pomeroy](https://pomeroy.me/contact "contact me via my website") | [Twitter](https://twitter.com/robpomeroy "reach me on Twitter") | [LinkedIn](https://linkedin/com/in/robpomeroy "connect via LinkedIn")

## Goals

Why this playbook? Why this approach?

1. **Longevity.** Many great, education-focused Linux distributions have started well but fizzled out. A low-maintenance strategy is key to survival of a project of this nature. An orchestration approach reduces much of the work normally associated to maintaining a single-purpose operating system, hence Ansible.
2. **Safety.** When preparing a computer environment for vulnerable people, their safety is of paramount importance.
3. **Accessible fun.** This project should enhance the lives of people who may otherwise struggle to use a computer.

## Progress/state of development

We're a long way from production-ready. Currently the playbook, starting from a bare-bones Ubuntu installation, sets up a KDE desktop with automatic passwordless login for a default user. The desktop environment is partially locked down. You'll see from the TODO list below there's a lot left... to do...

## Licence

This work is licensed under GNU General Public License v3.0. See the ```LICENCE``` file for the text. I'm British, so yes, that's how I spell 'licence'. :-)

## Choice of base OS

An ideal scenario would be to generalise this project so that it could work with almost any mainstream flavour GNU/Linux. At present however, it isn't possible to install KDE on the latest version of CentOS (8.1 at the time of writing). KDE is preferable, due to its built in kiosk framework. So that rules out CentOS/RedHat/Fedora for now.

Ubuntu has a lot of traction, features and support. This makes it an ideal starting point for this project. This Ansible playbook contains some RedHat-focused components; this is in the hope that KDE support becomes available in due course.

## TODO

* Security hardening
    * AppArmor or SELinux
    * Firewall
* Built-in web proxy for safe surfing (squid + E2guardian)
* Generalise for GNU/Linuxes other than Ubuntu
* Games & apps
    * KTuberling/Potato Guy
    * GCompris
    * TuxMath
    * KDE Edu Suite
    * Tux Paint
* Project-specific customisation
    * Plymouth boot screen
    * Desktop background
    * Menu logo

Further down the line, other possibilities include:

* Generalising this overall (orchestration) approach to build a reproducible framework for *other* primary-purpose operating systems - education, ICS, healthcare, etc.
* Build pipelines (CI/CD) to generate downloadable ISOs, for non-technical users.

## Sources for other ideas

There are some existing child-friendly Linux distributions. These do not focus on the needs of users with special needs (a cause dear to my heart) and many of them suffer from a lack of ongoing maintenance. Nevertheless, they are very useful sources of inspiration for this project.

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

## A note on the name

With apologies, I do not have any appetite for [arguments about whether we should insist on calling the operating system "GNU/Linux"](https://en.wikipedia.org/wiki/GNU/Linux_naming_controversy). I certainly intend no disrespect to any of the people who have worked so hard, over so many years, to contribute to the many many packages that bring us a competent, modern and [free](https://en.wikipedia.org/wiki/Free_and_open-source_software) operating system.