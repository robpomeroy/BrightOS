## Progress/state of development

The playbook converts a minimal Ubuntu 22.04 or AlmaLinux 9 installation into a
simple, passwordless, Gnome-based desktop environment, with a few applications
installed. It is ready for testing and feedback, but there is much work left to
do, as can be seen from the TODO list below.

## TODO
 
* Built-in content filter/proxy for safe surfing (privoxy)
* Games & apps
    * TuxMath
    * KDE Edu Suite
    * Tux Paint
* Detailed dconf lockdown. Paths of interest:
    * org.gnome.desktop.a11y (accessibility)
    * org.gnome.desktop.privacy
    * system.proxy
* Implement restricted shell: https://ostechnix.com/how-to-limit-users-access-to-the-linux-system/
* Project-specific customisation
    * Plymouth boot screen
    * Desktop background
    * Menu logo

Further down the line, other possibilities include:

* Generalising this overall (orchestration) approach to build a reproducible
  framework for *other* primary-purpose operating systems - education, ICS,
  healthcare, etc.
* Build pipelines (CI/CD) to generate downloadable ISOs, for non-technical
  users.

## Sources for other ideas

There are some existing child-friendly Linux distributions. These do not focus
on the needs of users with special needs (a cause dear to my heart) and many of
them suffer from a lack of ongoing maintenance. Nevertheless, they are very
useful sources of inspiration for this project.

* Ubermix: still under active development; focused on children and education
  (but not special needs); has some strong features including "20 second quick
  recovery mechanism"
* Elementary Linux OS: mature, actively developed OS built on Ubuntu/Gnome;
  focused on education and ease-of-use, but not aimed at special needs
* Debian Edu/Skolelinux: a mature project; last release Jul 2019 after a
  two-year hiatus; focus is education rather than special needs
* DoudouLinux: the OS I currently use for my son James (on a machine that is not
  network-connected); apparently abandoned in 2015
* Edubuntu: was a benchmark at one point, but now seems to be obsolete; the
  latest release was in 2016
* Qimo 4 Kids: project officially retired in 2016
* openSUSE-Edu Li-f-e: some good packages and features; project stalled in 2016;
  an[Ubuntu version
  exists](https://sourceforge.net/projects/cyberorg-home/files/Li-f-e/) but its
  future is not clear; not aimed at special needs
* LinuxKidX: last updated in 2016, seems to have been abandoned
* UberStudent: aimed at secondary and higher education; last release 2015
* Educado: particularly interesting due to its inclusion of parental controls;
  last release 2014
* UKnow4Kids: child-friendly Linux; last release was in 2010
* KnoSciences: educational distribution; last release was in 2006
* Leeenux Kids: a child-friendly version of Leeenux, a *non-free* OS that
  specifically targets netbooks (like the Asus Eee PC); less generalised from a
  hardware perspective than most other Linux distributions; documentation about
  Kids version is scant; not focused on special needs