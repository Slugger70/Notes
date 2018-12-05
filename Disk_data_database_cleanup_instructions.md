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

```sh
$> sudo su - galaxy

$> psql -p 5930 #The port number of the PostgreSQL server.

```

You are now in the command line interface for the PostgreSQL server.

#### 2. Get the list of jobs with state = `'new'`

We want to get the list of the jobs we are going to change the status of. To get the details of all of these jobs use the following command.

```sql
galaxy=> select j from job j where j.state = 'new';
```

This will return a list of all the jobs that are in state 'new'. It will give all the details of these jobs. Have a look and find the ones you are interested in. Now to make sure we do not delete any brand new jobs while we are playing with things, copy the timestamp from the most recent job you want to get rid of. We will use it in the next set of commands to check and make sure we're only altering the records of interest.

#### 3. Get a list of jobs whose state we want to change

Now write a new query to select just the job id's of all the jobs we want to update. Substitute the timestamp shown here for the one you copied earlier.

```sql
galaxy=> select j.id as id from job j where j.state = 'new' and j.create_time <= '2018-05-17 07:29:05.800232';
```

Compare and check the returned list carefully with the list of jobs shown on the **Manage Jobs** Admin UI page in Galaxy. If they are the same then proceed. If not, modify the above query to get the list you want.

#### 4. Set the state of those jobs to `'error'`

Using the id list generation query as a sub-query, write an UPDATE query to fix all the "broken" records in the database.

```sql
galaxy=> update job set state = 'error' from (select j.id as id from job j where j.state = 'new' and j.create_time <= '2018-05-17 07:29:05.800232') as sub_query where job.id = sub_query.id;

```

Cross your fingers! Hopefully, everything should be fixed now. Check it out in the **Manage Jobs** Admin UI page.

## Deleting old user data

According to our data retention policy we can delete data that hasn't been touched for 90 days. The best way to do this is probably look at the history update times. But first we have some setup to do...

### 1. Setup the environment

* ssh into the Galaxy server you want to do this on.

* **(Optional)** As the ubuntu user, get the latest copy of `gxadmin`. A very useful tool for admins with lots of cool queries built in. (Unfortunately, not what we want here but never mind..)

    ```sh
    $ curl https://raw.githubusercontent.com/usegalaxy-eu/gxadmin/master/gxadmin
    $ chmod +x gxadmin
    $ sudo mv gxadmin /usr/bin/
    ```

* Become the galaxy user on the server of interest and go to the home dir:

    ```sh
    $ sudo su - galaxy
    $ cd ~
    ```

* Edit the .bashrc file to add some environment variables for `PGHOST`, `PGUSER`, `PGPORT` & `PGDATABASE`. e.g.

    ```sh
    export PGHOST="<address_of_db_server>"
    export PGUSER="galaxy"
    export PGPORT="<port_number>"
    export PGDATABASE="galaxy"
    ```

* Create a `.pgpass` file in the galaxy home dir with the following contents:

    ```vim
    hostname:port:database:username:password
    ```
    where:
    * `hostname` = address of db server
    * `port` = databae connection port
    * `database` = galaxy
    * `username` = galaxy
    * `password` = the galaxy user's password on that server.

* source the .bashrc file to get the exports.

    ```sh
    $ source ~/.bashrc
    ```

* Test it to see if you can log into the database

    ```sh
    $ psql
    psql (9.5.14, server 10.5 (Ubuntu 10.5-0ubuntu0.18.04))
    WARNING: psql major version 9.5, server major version 10.
             Some psql features might not work.
    Type "help" for help.

    galaxy=>
    ```

* Run a simple command to see if it's all working.

    ```sql
    galaxy=> \l
     galaxy    | galaxy   | UTF8     | en_AU.UTF-8 | en_AU.UTF-8 |
     postgres  | postgres | UTF8     | en_AU.UTF-8 | en_AU.UTF-8 |
     template0 | postgres | UTF8     | en_AU.UTF-8 | en_AU.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
     template1 | postgres | UTF8     | en_AU.UTF-8 | en_AU.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
    ```

* Press ctrl-d to exit

Awesome, everything should be working now!

### 2. Make a list of histories that are older than X weeks


So we want to delete histories that are:

* Older than the cutoff time (90 days nominally)
* Are not marked as deleted
* Are not marked as "Published"

A query against the Galaxy database can give us the list of histories.

* Run the following command to get all histories older than 1 year old and store it in a file:

    ```sh
    $ psql -c "select h.id, h.update_time, h.user_id, u.email, h.published, h.deleted, h.purged, h.hid_counter from history h, galaxy_user u where h.update_time < (now() - '52 weeks'::interval) and h.user_id = u.id and h.deleted = FALSE and h.published = FALSE order by h.update_time;" > 1_year_old_histories.txt

    $ head 1_year_old_histories.txt
    id   |        update_time         | user_id |                   email                    | published | deleted | purged | hid_counter
-------+----------------------------+---------+--------------------------------------------+-----------+---------+--------+-------------
    1596 | 2016-01-28 00:35:05.194006 |      12 | xxxxxxxxxxxxxxxxxxxx                       | f         | f       | f      |           1
    1576 | 2016-01-28 04:17:39.167999 |      11 | xxxxxxxxxxxxxxxxxxxxxxxxxx                 | f         | f       | f      |          22
    1571 | 2016-01-31 06:44:15.470148 |       5 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        | f         | f       | f      |         101
    1549 | 2016-02-01 03:25:50.110857 |       9 | xxxxxxxxxxxxxxxxxxxx                       | f         | f       | f      |          45
    1572 | 2016-02-01 06:42:53.94472  |       5 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        | f         | f       | f      |         102
    1676 | 2016-02-02 04:09:25.617383 |      14 | xxxxxxxxxxxxxxxxxxxxx                      | f         | f       | f      |          10
    2093 | 2016-02-03 08:46:43.633603 |      18 | xxxxxxxxxxxxxxxxxxxxxxxxxx                 | f         | f       | f      |          25
    2605 | 2016-02-04 02:49:20.324186 |      17 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx       | f         | f       | f      |           6
    ```

    The fields returned from this query are kinda cool.
    * `id` = history_id
    * `update_time` = Time of last change to any of the history contents
    * `user_id` = The owner of the history's user_id
    * `email` = The user's email address
    * `published` = Has the history been published (we've selected for FALSE here)
    * `deleted` = Has the history been marked as deleted (we've selected for FALSE here)
    * `purged` = Has the history been purged (should be FALSE as deleted should be FALSE)
    * `hid_counter` = The number of data object associated with the history

By changing the `52` in the section of the query ` < (now() - '52 weeks'::interval)` to what ever minimum age we want, we can create a list of histories to be deleted.

### 3. Deleting the histories

I think we need to update the database saying that these histories can be marked as deleted. I'm not sure yet and this could be fraught with **DANGER**.. :)

TBC....
