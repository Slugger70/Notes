# Galaxy cleanup!

18/05/2018

## Galaxy dataset/disk purge instructions.

In order to cleanup the Galaxy disk etc., we first need to remove deleted datasets from the Galaxy database and then purge the disk. There are a set of instructions to make sure this all goes smoothly. These instructions come from the Oslo version of the Admin training (specifically these slides: [http://galaxyproject.github.io/training-material/topics/admin/tutorials/monitoring-maintenance/slides.html#1](http://galaxyproject.github.io/training-material/topics/admin/tutorials/monitoring-maintenance/slides.html#1) ).

The following commands:

1. cd to the galaxy-app dir
2. Become the galaxy user
3. Activate the Galaxy python environment
4. Run the cleanup scripts.

I generally set the `-o` switch to 5 (days.)

```

>$ cd /mnt/galaxy/galaxy-app

>$ sudo su galaxy

>$ source .venv/bin/activate

>$ python ./scripts/cleanup_datasets/pgcleanup.py --help
Usage: pgcleanup.py [options]

Options:
  -h, --help            show this help message and exit
  -c CONFIG, --config=CONFIG
                        Path to Galaxy config file (config/galaxy.ini)
  -d, --debug           Enable debug logging
  --dry-run             Dry run (rollback all transactions)
  --force-retry         Retry file removals (on applicable actions)
  -o DAYS, --older-than=DAYS
                        Only perform action(s) on objects that have not been
                        updated since the specified number of days
  -U, --no-update-time  Don't set update_time on updated objects
  -s SEQUENCE, --sequence=SEQUENCE
                        Comma-separated sequence of actions, chosen from:
                        ['delete_datasets', 'delete_exported_histories',
                        'delete_userless_histories', 'purge_datasets',
                        'purge_deleted_hdas', 'purge_deleted_histories',
                        'update_hda_purged_flag']
  -w WORK_MEM, --work-mem=WORK_MEM
                        Set PostgreSQL work_mem for this connection

```

Then run the following sequence of commands.

```
>$ python ./scripts/cleanup_datasets/pgcleanup.py -o 5 -s delete_userless_histories

>$ python ./scripts/cleanup_datasets/pgcleanup.py -o 5 -s delete_exported_histories

>$ python ./scripts/cleanup_datasets/pgcleanup.py -o 5 -s purge_deleted_histories

>$ python ./scripts/cleanup_datasets/pgcleanup.py -o 5 -s purge_deleted_hdas

>$ python ./scripts/cleanup_datasets/pgcleanup.py -o 5 -s delete_datasets

>$ python ./scripts/cleanup_datasets/pgcleanup.py -o 5 -s purge_datasets

```

And you're done.


## Galaxy database job inconsistencies

Sometimes the Galaxy job database doesn't cleanup old jobs, especially if they were never set to running because a user deleted a dataset or some other related reason. This can lead to these jobs clogging up the **Manage Jobs** table in the Administrators interface. Selecting them in the GUI and pressing Stop Jobs will not get rid of them. In this case we need to edit the Galaxy Database directly.

**Things to know prior to beginning:**
* You will need to know which port your Galaxy database is running on. On most GVLs this is port `5930` but can be `5950` or others.
* The job id of the most recent job you want to get rid of.


We will change the state of jobs to `'error'` whose state is `'new'` and have a job id <= the most recent job you want to get rid of. I usually prefer to use timestamps for this operation as it seems to be a bit more fool proof. I will give the commands for this way of doing things..

**YOU WILL BE EDITING THE GALAXY DATABASE!! MAKE SURE YOU HAVE A BACKUP BEFORE STARTING THIS OPERATION.**

#### 1. Become the Galaxy User and connect to the Database

```
$> sudo su - galaxy

$> psql -p 5930 #The port number of the PostgreSQL server.

```

You are now in the command line interface for the PostgreSQL server.

We want to get the list of the jobs we are going to change the status of. To get the details of all of these jobs use the following command.

```
galaxy=> select j from job j where j.state = 'new';
```

This will return a list of all the jobs that are in state 'new'. It will give all the details of these jobs. Have a look and find the ones you are interested in. Now to make sure we do not delete any brand new jobs while we are playing with things, copy the timestamp from the most recent job you want to get rid of. We will use it in the next set of commands to check and make sure we're only altering the records of interest.

Now write a new query to select just the job id's of all the jobs we want to update. Substitute the timestamp shown here for the one you copied earlier.

```
galaxy=> select j.id as id from job j where j.state = 'new' and j.create_time <= '2018-05-17 07:29:05.800232';
```

Compare and check the returned list carefully with the list of jobs shown on the **Manage Jobs** Admin UI page in Galaxy. If they are the same then proceed. If not, modify the above query to get the list you want.

Using the id list generation query as a sub-query, write an UPDATE query to fix all the "broken" records in the database.

```
galaxy=> update job set state = 'error' from (select j.id as id from job j where j.state = 'new' and j.create_time <= '2018-05-17 07:29:05.800232') as sub_query where job.id = sub_query.id;

```

Cross your fingers! Hopefully, everything should be fixed now. Check it out in the **Manage Jobs** Admin UI page.
