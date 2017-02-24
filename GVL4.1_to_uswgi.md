# Upgrade GVL 4.1 to use uswgi instead of paster.

This lays out how to get the Galaxy server in GVL 4.1 running using the new uwsgi webserver instead of the old paster one. It will also install and configure supervisor to control galaxy start/stops.

* It will by default change the way galaxy works. We will set up a galaxy webserver and two galaxy headless handler services using galaxymain.

* It will require some changes to the job_conf.xml file to include these new handlers.

**NOTES:**

* This will make the galaxy server non-repsonsive to commands from Cloudman. i.e. You won't be able to restart it from cloudman any longer.. A fix for this will require some changes to cloudman to make it use supervisor..

## Installations

We need to install a few things before we can begin... Namely uwsgi, its python libraries and supervisor.

`sudo apt install uwsgi uwsgi-plugin-python supervisor`

Then we need to install the uwsgi decorators to the galaxy python virtualenv..

`sudo -Hu galaxy /mnt/galaxy/galaxy-app/.venv/bin/pip install uwsgidecorators`

