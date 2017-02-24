# Upgrade GVL 4.1 to use uswgi instead of paster.

This lays out how to get the Galaxy server in GVL 4.1 running using the new uwsgi webserver instead of the old paster one. It will also install and configure supervisor to control galaxy start/stops.

* It will by default change the way galaxy works. We will set up a galaxy webserver and two galaxy headless handler services using the galaxymain script that comes with Galaxy.

* It will require some changes to the job_conf.xml file to include these new handlers.

**NOTES:**

* This will make the galaxy server non-repsonsive to commands from Cloudman. i.e. You won't be able to restart it from cloudman any longer.. A fix for this will require some changes to cloudman to make it use supervisor..

## Installations

We need to install a few things before we can begin... Namely uwsgi, its python libraries and supervisor.

`sudo apt install uwsgi uwsgi-plugin-python supervisor`

Then we need to install the uwsgi decorators to the galaxy python virtualenv..

`sudo -Hu galaxy /mnt/galaxy/galaxy-app/.venv/bin/pip install uwsgidecorators`

## Configure uwsgi

**galaxy.ini**

Add the following to `/mnt/galaxy/galaxy-app/config/galaxy.ini`. Put it above the `[server:main]` section.

```ini
[uwsgi]
processes = 2
threads = 2
socket = 127.0.0.1:4001     # uwsgi protocol for nginx
pythonpath = lib
master = True
logto = /mnt/galaxy/galaxy-app/uwsgi.log
logfile-chmod = 644
```

Also, make sure that there is a line in `galaxy.ini` that tells Galaxy about the location of the `job_conf.xml` file:

`job_config_file = /mnt/galaxy/galaxy-app/config/job_conf.xml`

## Configure job handlers

**job_conf.xml**

Edit the `/mnt/galaxy/galaxy-app/config/job_conf.xml` file and change the entire
```xml

<handlers ...>
  ...
</handlers>
```
section to:

```xml
<handlers default="handlers">
    <handler id="handler0" tags="handlers"/>
    <handler id="handler1" tags="handlers"/>
</handlers>
```

## Configure nginx

Configure the nginx configuration for galaxy so it uses uwsgi socket bindings instead of paster.

Edit the `galaxy.locations` file:

`sudo vim /etc/nginx/sites-enabled/galaxy.locations`

Change the `location /galaxy {` section so it looks like:
  
```conf
        location /galaxy {
            #proxy_pass  http://galaxy_app;
            #proxy_set_header   X-Forwarded-Host $host;
            #proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            uwsgi_pass           127.0.0.1:4001;
            include              uwsgi_params;
        }
```

Unfortunately, Cloudman will overwrite these changes so `chmod -w` this file with to prevent it.

Then restart nginx with `sudo service nginx restart`

## Stop old Galaxy

Now you need to stop Galaxy (if you haven't already)...

from the `/mnt/galaxy/galaxy-app` directory:

`sudo -Hu galaxy ./run.sh --log-file=main.log --pid-file=main.pid --stop-daemon`

## Setup supervisorctl

Now configure supervisor so that it can start/stop the Galaxy web front end and the two job handlers (headless Galaxys)..

Check to see if supervisor is running:

`sudo supervisorctl status`

If its running it will return it's status..

Now we need to configure a galaxy supervisor control file..

Create/edit the following file:

`sudo vim /etc/supervisor/conf.d/galaxy.conf`

add the following:

```conf
[program:galaxy]
command         = uwsgi --plugin python --virtualenv /mnt/galaxy/galaxy-app/.venv --ini-paste /mnt/galaxy/galaxy-app/config/galaxy.ini
directory       = /mnt/galaxy/galaxy-app
autostart       = true
autorestart     = true
startsecs       = 10
user            = galaxy
stopsignal      = INT

[program:handler]
command         = python ./scripts/galaxy-main -c /mnt/galaxy/galaxy-app/config/galaxy.ini --server-name=handler%(process_num)s --log-file /mnt/galaxy/galaxy-app/handler%(process_num)s.log
directory       = /mnt/galaxy/galaxy-app
process_name    = handler%(process_num)s
numprocs        = 2
umask           = 022
autostart       = true
autorestart     = true
startsecs       = 10
user            = galaxy
environment     = VIRTUAL_ENV="/mnt/galaxy/galaxy-app/.venv",PATH="/mnt/galaxy/galaxy-app/.venv/bin:%(ENV_PATH)s"

[group:gx]
programs = galaxy,handler
```

Now just update supervisor to get it all running..

`sudo supervisorctl update`

## Controlling Galaxy

**Start**

`sudo supervisorctl start gx:*`

**Stop**

`sudo supervisorctl stop gx:*`

**Restart**

`sudo supervisorctl restart gx:*`

It can be a bit more nuanced than that.. For example to just restart Galaxy's webapp: `sudo supervisroctl restart gx:galaxy` and to just restart one of the job handlers (say handler0): `sudo supervisorctl restart gx:handler0` 

## Log files

Galaxy's log files are now threefold. One for the webserver app and one each for the two headless job handlers.. They are now located as follows:

```
/mnt/galaxy/galaxy-app/uwsgi.log
/mnt/galaxy/galaxy-app/handler0.log
/mnt/galaxy/galaxy-app/handler1.log
```