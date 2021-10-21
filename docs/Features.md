# Features

## DNS

This project forcibly sets specific DNS servers (the `dns_servers` variable in
`config.yml`). The recommended approach is to use the OpenDNS FamilyShield
servers, which provide some protection against content unsuitable for children
or particularly vulnerable people.

## Content filtering

We use Privoxy, to filter out certain malicious types of web content. At this
time, there is no obvious open source content filtering solution that would
provide truly unsupervised category-based protection for users.
Allow-/block-listing is an option, but that requires a lot of maintenance.
Suggestions for improvement in this area are welcome.