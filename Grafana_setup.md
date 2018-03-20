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


#### Configure Telegraf on Stats server to test Things

Telegraf is installed as part of the playbook onto the stats server. We can get it to push data to the localhost influxdb server to test everything.

Make sure the following is located at: `/etc/telegraf/telegraf.conf`

```
# Telegraf configuration

[global_tags]

# Configuration for telegraf agent
[agent]
    interval = "10s"
    debug = false
    hostname = "stats.genome.edu.au"
    round_interval = true
    flush_interval = "10s"
    flush_jitter = "0s"
    collection_jitter = "0s"
    metric_batch_size = 1000
    metric_buffer_limit = 10000
    quiet = false
    logfile = ""
    omit_hostname = false

###############################################################################
#                                  OUTPUTS                                    #
###############################################################################

[[outputs.influxdb]]
    urls = ["http://stats.genome.edu.au:8086"]
    database = "telegraf"

###############################################################################
#                                  INPUTS                                     #
###############################################################################

[[inputs.cpu]]
    percpu = true
[[inputs.disk]]
[[inputs.kernel]]
[[inputs.processes]]
[[inputs.io]]
[[inputs.mem]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.net]]
[[inputs.netstat]]
```
#### Add a dashboard and hook it up!

We need to add a dashboard to display the data being collected. One has been built by Eric that is good.. We just need to import it. The file [Galaxy Node Detail-1521561338899.json](./Galaxy Node Detail-1521561338899.json) can be imported to create a test setup.

To import the dashboard:

On the LHS menu: Click the **+ -> Create -> Import** link.

Then use the **Upload JSON** button and point to the file.

Once loaded, you should see stats.genome.edu.au in the host list.

And data should be being collected and displayed.

**Troubleshooting:**
- Make sure Telegraf is running on the stats machine.
- Make sure the port 8086 is open on the stats machine.
- Make sure that Grafana and NGINX are configured properly.

## Step 3: Install Telegraf on machines you want to monitor.

I did this on Galaxy-Mel, W1 and W2.

#### Download the Telegraf client (deb package)

- From https://github.com/influxdata/telegraf grab the nightly build: https://dl.influxdata.com/telegraf/nightlies/telegraf_nightly_amd64.deb

- Then install it with:

```bash
sudo dpkg -i telegraf_nightly_amd64.deb

```

#### Configure telegraf

* Edit the `/etc/telegraf/telgraf.conf` file so it looks like the one above. Except, change the **hostname** to something unique for this machine. I used:
    * *Galaxy-mel.genome.edu.au*
    * *Galaxy-mel.W1*
    * *Galaxy-mel.W2*
    * For Galaxy-mel and it's workers respectively.
* Restart Telegraf:
```
sudo service telegraf restart
```


***Now each of the machines we just added Telegraf to will be sending data to the stats server and will be displayed.***

#### Troubleshooting:

* Make sure telegraf is running on each machine
* Make sure the port `8086` is open on stats machine
* Make sure that the telegraf config files all point to the telegraf database
```
...
[[outputs.influxdb]]
    urls = ["http://stats.genome.edu.au:8086"]
    database = "telegraf"
...
```
* Make sure telgraf service has been restarted on machines after config file changes.
