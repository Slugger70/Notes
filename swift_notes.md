# Notes on using swift for interactions with the object store.

## Installation of swift.

I usually create a virtualenv for swift and install it using pip3.

```
virtualenv swift_venv
source swift_venv/bin/activate 
pip3 install python-swiftclient
```

## Setting openstack credential env vars.

Openstack uses a bunch of environment variables to authenticate..

These are project specific and appropriate settings are contained in the **project_name-openrc.sh** file which is available for download from the NeCTAR dashboard.

### Getting the OpenStack RC file.

1. Login to the dashboard
2. Select the appropriate project
3. Click the *Access & Security* link on the left hand panel
4. Select the *API Access* tab in the centre pane.
5. Click the *Download OpenStack RC file* button.
6. Save the file somewhere you will be able to find it! It will be called `<project_name>-openrc.sh`

### Getting your Open Stack API key

You will need your Open Stack API key. If you don't already have one, you can get it or reset it and get a new one from the NeCTAR dashboard.

1. On the dashboard, click on your username on the top right of the screen.
2. Click *Settings*
3. Click *Reset Password* on the left hand pane.
4. Click the *Reset Password* button.
5. **Record the password somewhere as this is the only time you will ever see it on the Dashboard.** If you lose it, you will need a new one!

Now you have the credentials you need, put them somewhere you can use them and find them!

### Set the environment variables.

Just run the shell script! Enter your password at the prompt. You need to do this each time you want to run swift...

You can check if they've been set with `env`.

## Using swift

Once you have run the authentication shell script you can use swift.

Common commands are:

**To get a list of folders in your object store.**

 `swift list`

**To get a list of files in a folder**

`swift list <foldername>`


**To download a file or directory**

`swift download <foldername> <filename_or_directory>`

**To upload a file or directory (files are all < 4GB in size)**

`swift upload <foldername> <filename_or_directory>`

**To upload a file (some files are > 4GB in size)**

If a file is > 4GB, you need to set swift to chunk the file. There is no automatic option for this. (Stupid swift..)

You need to use the -S option for uploads and specify a size in Bytes. :(

e.g. TO chunk a file into 2GB pieces, use `-S 2000000000`

`swift upload -S <size_in_bytes> <foldername> <filename>`

## Getting help

You can get help with `swift --help` and `swift <subcommand> --help`