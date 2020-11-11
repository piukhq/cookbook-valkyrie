---
page_title: "Valkyrie"
---

[![Build Status](https://git.bink.com/DevOps/Cookbooks/valkyrie/badges/master/pipeline.svg)](https://git.bink.com/DevOps/Cookbooks/valkyrie)

Deploys and Configures a Wireguard VPN on Ubuntu 20.04

The wireguard exporter listens on 9586 and reads in a CSV of `publickey,friendly name` to enrich the metrics

To run `./gen.sh` on a mac, you'll need wireguard tools which can be installed with `brew install wireguard-tools`

## Future improvements

* Create a selfsigned certificate so that the exporters are not serving HTTP over the internet.
