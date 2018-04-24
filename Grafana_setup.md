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

Clone the playbook we use. The branch master has the changes we made for the setup we used.

The playbook `grafana.yml` contains a bunch of roles. We don't use a couple and the os/ssl hardening ones are optional also.

```
git clone https://github.com/gvlproject/infrastructure-playbook

git checkout stats_genome_edu_au_setup
```

#### Modify the playbook if required

* Set the ip/hostname in `hosts` under `[grafana]`

* Use the right key file.

#### Add a bot user to the galaxy server for testing purposes

* Create a bot user on Galaxy and get an api key.. bot@usegalaxy.org.au, 37dqztczh, 674ecd9a58dc67ecf35113a1526cc9ce

* Create `grafana.yml` in the `/secret_group_vars` directory of the infrastructure playbook

```yaml
galaxy_test_user__api_key: <apikey>
galaxy_test_user__password: <user_password>
```

Obviously, replace `<apikey>` with the actual api key etc.. :)

* Encrypt the `grafana.yml` file with `ansible-vault encrypt secret_group_vars/grafana.yml`. Use the password stored in .vault_password

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

#### Troubleshooting:

- Make sure Telegraf is running on the stats machine.
- Make sure the port `8086` is open on the stats machine.
- Make sure that Grafana and NGINX are configured properly.

### Set the retention policy for the Influx database.

We need to make sure that the disk doesn't fill up with all of our data. 2 weeks would probably be enough data.

ssh into the stats machine and do the following

```
$ influx

> show databases
name: databases
name
----
telegraf
_internal

> CREATE RETENTION POLICY "two_weeks" ON "telegraf" DURATION 2w REPLICATION 1 DEFAULT
> show retention policies
name      duration shardGroupDuration replicaN default
----      -------- ------------------ -------- -------
autogen   0s       168h0m0s           1        false
two_weeks 336h0m0s 24h0m0s            1        true
> exit

```

The `2w` after the `DURATION` sets the retention time. Can use `d`, `w`, `m`, `y` for days, weeks, months, years etc. here.

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
[[outputs.influxdb]]
    urls = ["http://stats.genome.edu.au:8086"]
    database = "telegraf"

```
* Make sure telgraf service has been restarted on machines after config file changes.


## Galaxy server monitoring

Monitoring of Galaxy queue, UI response times, jobs and job status etc. This requires a bit more of a complex setup.

* We need to add a couple of lines to the end Galaxy head node's telegraf config file. (The `statsd` input plugin for telegraf uses port `8125` by default and so we will tell Galaxy about it in a later step.)

```
[[inputs.statsd]]
  metrics_separator="."
```
* Restart telegraf `sudo service telegraf restart`

* Add the following lines to `galaxy.ini`

```
statsd_host = localhost
statsd_port = 8125
statsd_prefix = galaxy-mel
```

* Restart Galaxy (the web services will do, but for Galaxy-Mel I had to restart Galaxy)

* Now we need to setup some custom scripts that will poll the queue system etc. Checkout https://github.com/usegalaxy-eu/galaxy-playbook-temporary/tree/master/roles/monitoring
* In the ubuntu user directory I've created a `stats` dir.
* Inside this are a couple of files we need. `secret.yml` and `galaxy_queue_size.py`
* We need to create a python venv called `stats_venv` and install some packages.

```
virtualenv stats_venv
source stats_venv/bin/activate
pip install psycopg2 influxdb pyyaml
```

* Make sure the `python` used in the `!#` points to the one in the virtualenv.
* Make the following cron job with `crontab -e`

```
* * * * * /home/ubuntu/stats/stats_venv/bin/python /home/ubuntu/stats/galaxy_queue_size.py main
```


Phew! Nearly done. Now we can create a new Dashboard in Grafana

#### Create a new dashboard in Grafana.

* Go back to the Grafana server.
* Import a new dashboard using the file [Galaxy-1521564452764.json](Galaxy-1521564452764.json)
* Should be all working at this point!

## Step 4: Play around!

Can play around with monitoring, more dashboards, additional monitoring etc!

# Monitoring Galaxy Functionality with Nagios

This describes how to set up simple nagios to monitor our galaxy by getting it to run a small tool on different handlers and queues etc.

## Step 1: Install the nagios stuff to the stats machines

* Create a bot user on Galaxy and get an api key.. bot@usegalaxy.org.au, 37dqztczh, 674ecd9a58dc67ecf35113a1526cc9ce

* Create `grafana.yml` in the `/secret_group_vars` directory of the infrastructure playbook

```yaml
galaxy_test_user__api_key: <apikey>
galaxy_test_user__password: <user_password>
```

Obviously, replace `<apikey>` with the actual api key etc.. :)

* Edit the `grafana.yml` file in `/group_vars` and fix all the paths, handlers lists etc. etc.

* In the `grafana.yml` role in `/` comment out everything that's already been run..
