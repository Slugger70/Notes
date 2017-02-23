# Upgrade the Galaxy version on GVL 4.1 to Galaxy 17.01

This will switch to the Galaxy Project's release branch of the git repo from the GVL project's Galaxy fork.

* Note: This will remove the genomespace setup for this machine.
* There is a git diff listed at the bottom of this procedure to help with restoration of genomespace functionality but it has yet to be tested.

### Add Galaxy project galaxy repo as upstream.

```console
sudo su galaxy
cd /mnt/galaxy/galaxy-app
```

**Set the username and email for the git operations..**
```console
git config --global user.email "slugger70@gmail.com"
git config --global user.name "Slugger70"
```

Then I did a status to see where I was at.

`git status`

There were some changed files but they were inconsequential.. So I **stashed the changes.**

```
git stash
git status
```

Now just shows some untracked changes (mainly static pages and logos etc)

```
branch: GVL 4.1.0.alpha

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	database/template_cache/
	lib/galaxy/jobs/rules/dyndests.py
	reports.conf.d/
	scripts/api/manage_bootstrap_user.py
	scripts/install_tool_shed_tools.py
	scripts/manage_bootstrap_user.py
	static/images/EMBL_Australia_logo.png
	static/images/Nectar_logo.jpeg
	static/images/RDSILOGO.jpg
	static/images/UOM-Rev3D_S_SmRBG.jpg
	static/images/ands-logo.jpg
	static/images/cloud.gif
	static/images/cloud_text.png
	static/images/embl.png
	static/images/gvl.png
	static/images/logo_uom.png
	static/images/nectardirectorate-footer-logo.png
	static/images/vlsci-logo.gif
	tool-data/fastx_clipper_sequences.txt
	tool-data/gatk2_annotations.txt
	tool-data/shared/ncbi/
	tool_list.yaml
```
Now list the remotes.

```
git remote -v

origin	https://github.com/gvlproject/galaxy (fetch)
origin	https://github.com/gvlproject/galaxy (push)
```

**Add the Galaxy project upstream**

```
git remote add upstream https://github.com/galaxyproject/galaxy
git remote -v
```

```
origin	https://github.com/gvlproject/galaxy (fetch)
origin	https://github.com/gvlproject/galaxy (push)
upstream	https://github.com/galaxyproject/galaxy (fetch)
upstream	https://github.com/galaxyproject/galaxy (push)
```

List all the branches

`git branch -a`

```
* gvl_4.1.0_alpha
  remotes/origin/HEAD -> origin/dev
  remotes/origin/dev
  remotes/origin/genomespace_workflows
  remotes/origin/gvl
  remotes/origin/gvl_4.0.0
  remotes/origin/gvl_4.0.0_genomespace
  remotes/origin/gvl_4.1.0_alpha
  remotes/origin/martenson-patch-1
  remotes/origin/master
  remotes/origin/release_13.01
  remotes/origin/release_13.02
  remotes/origin/release_13.04
  remotes/origin/release_13.06
  remotes/origin/release_13.08
  remotes/origin/release_13.11
  remotes/origin/release_14.02
  remotes/origin/release_14.04
  remotes/origin/release_14.06
  remotes/origin/release_14.08
  remotes/origin/release_14.10
  remotes/origin/release_15.01
  remotes/origin/release_15.03
  remotes/origin/release_15.05
```
**Pull in the upstream branches**

`git pull upstream`

List the branches again

`git branch -a`

```
* gvl_4.1.0_alpha
  remotes/origin/HEAD -> origin/dev
  remotes/origin/dev
  remotes/origin/genomespace_workflows
  remotes/origin/gvl
  remotes/origin/gvl_4.0.0
  remotes/origin/gvl_4.0.0_genomespace
  remotes/origin/gvl_4.1.0_alpha
  remotes/origin/martenson-patch-1
  remotes/origin/master
  remotes/origin/release_13.01
  remotes/origin/release_13.02
  remotes/origin/release_13.04
  remotes/origin/release_13.06
  remotes/origin/release_13.08
  remotes/origin/release_13.11
  remotes/origin/release_14.02
  remotes/origin/release_14.04
  remotes/origin/release_14.06
  remotes/origin/release_14.08
  remotes/origin/release_14.10
  remotes/origin/release_15.01
  remotes/origin/release_15.03
  remotes/origin/release_15.05
  remotes/upstream/dev
  remotes/upstream/master
  remotes/upstream/master-toolshed
  remotes/upstream/release_13.01
  remotes/upstream/release_13.02
  remotes/upstream/release_13.04
  remotes/upstream/release_13.06
  remotes/upstream/release_13.08
  remotes/upstream/release_13.11
  remotes/upstream/release_14.02
  remotes/upstream/release_14.04
  remotes/upstream/release_14.06
  remotes/upstream/release_14.08
  remotes/upstream/release_14.10
  remotes/upstream/release_15.01
  remotes/upstream/release_15.03
  remotes/upstream/release_15.05
  remotes/upstream/release_15.07
  remotes/upstream/release_15.10
  remotes/upstream/release_16.01
  remotes/upstream/release_16.04
  remotes/upstream/release_16.07
  remotes/upstream/release_16.10
  remotes/upstream/release_17.01
  remotes/upstream/revert-3572-fix_3548
  ```

**Now switch to the galaxyproject 17.01 release**
  
`git checkout upstream/release_17.01`
  
`git status`
  
```
HEAD detached at upstream/release_17.01
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	database/template_cache/
	lib/galaxy/jobs/rules/dyndests.py
	reports.conf.d/
	scripts/api/manage_bootstrap_user.py
	scripts/install_tool_shed_tools.py
	scripts/manage_bootstrap_user.py
	static/images/EMBL_Australia_logo.png
	static/images/Nectar_logo.jpeg
	static/images/RDSILOGO.jpg
	static/images/UOM-Rev3D_S_SmRBG.jpg
	static/images/ands-logo.jpg
	static/images/cloud.gif
	static/images/cloud_text.png
	static/images/embl.png
	static/images/gvl.png
	static/images/logo_uom.png
	static/images/nectardirectorate-footer-logo.png
	static/images/vlsci-logo.gif
	tool-data/fastx_clipper_sequences.txt
	tool-data/gatk2_annotations.txt
	tool-data/shared/ncbi/
	tool_list.yaml
  ```
  
`git log`

Should show all the commit history for the 17.01 branch

**Now we need to stop galaxy..**

from the galaxy directory (/mnt/galaxy/galaxy-app/)

`./run.sh --pid-file=main.pid --log-file=main.log --stop-daemon`

**upgrade the database**

`sh manage_db.sh upgrade`

Add the following line to the bottom of the galaxy.ini file in /mnt/galaxy/galaxy-app/config/galaxy.ini

`conda_auto_init = True`

**start galaxy again**

`./run.sh --pid-file=main.pid --log-file=main.log --daemon`


Everything should work!