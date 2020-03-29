# Special Needs Linux

## Introduction

The world of special needs is largely unseen - until you are thrust into it. This is the position my wife and I found ourselves in, in 2004, when she gave birth to our twins Morgan and James. Due to a [condition during pregnancy](https://en.wikipedia.org/wiki/Twin-to-twin_transfusion_syndrome) our boys both have profound special needs. Morgan has severe spastic cerebral palsy, is quadriplegic and vision impaired. James has severe learning difficulties, is on the autistic spectrum and suffers from anxiety.

The following years have been a massive learning experience and, I hope, character building! What has become abundantly apparent is that there are gaps in the market, for all sorts of specialist provision. And that where specialist provision *does* exist, applying the label "disabled" or "adapated" to any product or service reduces its market and increases its cost, dramatically. (A specialist bath for Morgan comes in at £10,000, or thereabouts.)

It does not have to be costly, to meet computing needs. This open source (free!) repository contains an [Ansible](https://www.ansible.com/) playbook for customising Linux to help users with special needs. The aim of this project is to create an Ansible build that converts a Linux installation into something suitable for users (particularly children) with special needs.

Why Linux rather than Windows? Several reasons:

* **Cost.** Open source licensing allows us to distribute the finished work at no cost to end users - who for the reasons above may aleady find their lives to be expensive!
* **Simplicity.** Using open source software as a starting point avoids becoming bogged down in licensing issues.
* **Familiarity.** I've been using Linux for over twenty years. I've worked with developers and picked up knowledge of orchestration and text-based configuration. It's much easier for me to achieve this project's goals with Linux.

For prerequsites and usage instructions, refer to ```INSTALL.md```

-- [Rob Pomeroy](https://pomeroy.me/contact "contact me via my website") | [Twitter](https://twitter.com/robpomeroy "reach me on Twitter") | [LinkedIn](https://linkedin/com/in/robpomeroy "connect via LinkedIn")

## Goals

Why this playbook? Why this approach?

1. **Accessible fun.** This project should enhance the lives of people who may otherwise struggle to use a computer.
2. **Safety.** When preparing a computer environment for vulnerable people, their safety is of paramount importance.
3. **Longevity.** Many great, education-focused Linux distributions have started well but fizzled out. A low-maintenance strategy is key to survival of a project of this nature. An orchestration approach reduces much of the work normally associated to maintaining a single-purpose operating system, hence Ansible.

## Progress/state of development

We're a long way from production-ready. Currently the playbook, starting from a bare-bones Ubuntu installation, sets up a KDE desktop with automatic passwordless login for a default user. The desktop environment is partially locked down. You'll see from the TODO list below there's a lot left... to do...

## Licence

This work is licensed under GNU General Public License v3.0. See the ```LICENCE``` file for the text. I'm British, so yes, that's how I spell 'licence'. :-)

## Choice of base OS

An ideal scenario would be to generalise this project so that it could work with almost any mainstream flavour GNU/Linux. At present however, it isn't possible to install KDE on the latest version of CentOS (8.1 at the time of writing). KDE is preferable, due to its built in kiosk framework. So that rules out CentOS/RedHat/Fedora for now.

Ubuntu has a lot of traction, features and support. This makes it an ideal starting point for this project. This Ansible playbook contains some RedHat-focused components; this is in the hope that KDE support becomes available in due course.

## Accessibility guidelines

It is not possible to build a *simple* operating system that specilises in meeting *all* special needs. Special Needs Linux aims to accommodate:

* Fine motor control limitations (e.g. games need not require precise mouse movements)
* Mild vision impairment (audible feedback desirable, but not necessarily full text-to-speech synthesis)
* Learning difficulties (games involving repetition and very slowly increasing difficulty levels help here)

These are not hard-and-fast rules however. Individual games and applications may not necessarily meet all guidelines.

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

* Ubermix: still under active development; focused on children and education (but not special needs); has some strong features including "20 second quick recovery mechanism"
* Elementary Linux OS: mature, actively developed OS built on Ubuntu/Gnome; focused on education and ease-of-use, but not aimed at special needs
* Debian Edu/Skolelinux: a mature project; last release Jul 2019 after a two-year hiatus; focus is education rather than special needs
* DoudouLinux: the OS I currently use for my son James (on a machine that is not network-connected); apparently abandoned in 2015
* Edubuntu: was a benchmark at one point, but now seems to be obsolete; the latest release was in 2016
* Qimo 4 Kids: project officially retired in 2016
* openSUSE-Edu Li-f-e: some good packages and features; project stalled in 2016; an[Ubuntu version exists](https://sourceforge.net/projects/cyberorg-home/files/Li-f-e/) but its future is not clear; not aimed at special needs
* LinuxKidX: last updated in 2016, seems to have been abandoned
* UberStudent: aimed at secondary and higher education; last release 2015
* Educado: particularly interesting due to its inclusion of parental controls; last release 2014
* UKnow4Kids: child-friendly Linux; last release was in 2010
* KnoSciences: educational distribution; last release was in 2006
* Leeenux Kids: a child-friendly version of Leeenux, a *non-free* OS that specifically targets netbooks (like the Asus Eee PC); less generalised from a hardware perspective than most other Linux distributions; documentation about Kids version is scant; not focused on special needs

## A note on the name

With apologies, I do not have any appetite for [arguments about whether we should insist on calling the operating system "GNU/Linux"](https://en.wikipedia.org/wiki/GNU/Linux_naming_controversy). I certainly intend no disrespect to any of the people who have worked so hard, over so many years, to contribute to the many many packages that bring us a competent, modern and [free](https://en.wikipedia.org/wiki/Free_and_open-source_software) operating system.