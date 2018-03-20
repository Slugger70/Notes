# Galaxy-Mel monitoring

*20/3/2018*

This describes what I did to setup the grafana server and connect Galaxy-mel to it.

## Step 1: Setup a Grafana server

*20/3/2018*

This describes what I did to set up the Grafana server for Galaxy-mel. We need ansible > 2 for this.

#### Create a server

1. Launch a Ubuntu 16.04 server in GenomicsVL
1. Added ip to ns1 as stats.genome.edu.au
1. apt-get update & upgrade & autoremove
1. apt install build-essential
1. Give it **cloudman key & cloudman security group & influxdb security group** (so it opens port 8086 which is what influx will listen on)

#### Clone the playbooks

Clone the playbook we use. The branch stats_genome_edu_au_setup has the changes we made for the setup we used.

The playbook `grafana.yml` contains a bunch of roles. We don't use a couple and the os/ssl hardening ones are optional also.

```
git clone https://github.com/gvlproject/infrastructure-playbook

git checkout stats_genome_edu_au_setup
```

#### Modify the playbook if required

Set the ip/hostname in `hosts` under `[grafana]`

Use the right key file.

#### Run the playbook

```
make grafana
```

The playbook will run.

**Grafana should be setup now and running at the ip address/DNS entry of the machine!**

## Step 2: Configure the Grafana server

**Change the admin user password!**

* Default setup is admin/admin.. Make it something sensible.

**Now the grafana server is ready to go!**
