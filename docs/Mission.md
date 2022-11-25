# Introduction

The world of special needs is largely unseen - until you are thrust into it.
This is the position my wife and I found ourselves in, in 2004, when she gave
birth to our twins Morgan and James. Due to a [condition during
pregnancy](https://en.wikipedia.org/wiki/Twin-to-twin_transfusion_syndrome) our
boys both have profound special needs. Morgan has severe spastic cerebral palsy,
is quadriplegic and vision impaired. James has severe learning difficulties, is
on the autistic spectrum and suffers from anxiety.

The following years have been a massive learning experience and, I hope,
character building! What has become abundantly apparent is that there are gaps
in the market, for all sorts of specialist provision. And that where specialist
provision *does* exist, applying the label "disabled" or "adapted" to any
product or service reduces its market and increases its cost, dramatically. (A
specialist bath for Morgan comes in at £10,000, or thereabouts.)

It does not have to be costly, to meet computing needs. This open source (free!)
repository contains an [Ansible](https://www.ansible.com/) playbook for
customising Linux to help users with special needs. The initial aim of this
project is to create an Ansible build that converts a Linux installation into
something suitable for users (particularly children) with special needs. Later,
we may take a more direct approach, creating a Linux distribution with
installer.

Why Linux rather than Windows? Several reasons:

* **Cost.** Open source licensing allows us to distribute the finished work at
  no cost to end users - who for the reasons above may aleady find their lives
  to be expensive!
* **Simplicity.** Using open source software as a starting point avoids becoming
  bogged down in licensing issues.
* **Familiarity.** I've been using Linux for over twenty years. I've worked with
  developers and picked up knowledge of orchestration and text-based
  configuration. It's much easier for me to achieve this project's goals with
  Linux.

I'm personally most interested in the protection of users with learning
difficulties. So the focus here is on safety and on enabling carers to control
the system for the intended user. Spin-offs or bespoke configuration may be
appropriate, to target other user groups, but that is not my initial objective.

# Goals

Why this playbook? Why this approach?

1. **Accessible fun.** This project should enhance the lives of people who may
   otherwise struggle to use a computer.
2. **Safety.** When preparing a computer environment for vulnerable people,
   their safety is of paramount importance.
3. **Longevity.** Many great, education-focused Linux distributions have started
   well but fizzled out. A low-maintenance strategy is key to survival of a
   project of this nature. An orchestration approach reduces much of the work
   normally associated to maintaining a single-purpose operating system, hence
   Ansible.

# Choice of base OS

To support longevity, it is sensible to choose an open base operating system
with a good track record and long-term prospects. At the same time, to give
end users a degree of choice, it is helpful to select operating systems from
more than one family of Linux. This playbook therefore targets Ubuntu, based on
Debian, and AlmaLinux, based on Red Hat. It may run on other related distros,
but I have not tested that.