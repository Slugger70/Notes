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


Everything should work! (Except Genomespace but this can be fixed by reapplying the diff below...)

```diff
diff --git a/client/galaxy/scripts/mvc/tool/tool-genomespace.js b/client/galaxy/scripts/mvc/tool/tool-genomespace.js
index 1606f178b..d4adff81e 100644
--- a/client/galaxy/scripts/mvc/tool/tool-genomespace.js
+++ b/client/galaxy/scripts/mvc/tool/tool-genomespace.js
@@ -4,7 +4,7 @@ define([], function() {
 // tool form templates
 return {
     openFileBrowser: function( options ) {
-        var GS_UPLOAD_URL = "https://gsui.genomespace.org/jsui/upload/loadUrlToGenomespace.html?getLocation=true";
+        var GS_UPLOAD_URL = "https://genomespace.genome.edu.au/jsui/upload/loadUrlToGenomespace.html?getLocation=true";

         var newWin = window.open(GS_UPLOAD_URL, "GenomeSpace File Browser", "height=360px,width=600px");

diff --git a/config/datatypes_conf.xml.sample b/config/datatypes_conf.xml.sample
index a9d714cdf..159cda17f 100644
--- a/config/datatypes_conf.xml.sample
+++ b/config/datatypes_conf.xml.sample
@@ -395,7 +395,7 @@
     <datatype extension="embl" type="galaxy.datatypes.data:Text" subclass="True"/>
     <datatype extension="fitch" type="galaxy.datatypes.data:Text" subclass="True"/>
     <datatype extension="gcg" type="galaxy.datatypes.data:Text" subclass="True"/>
-    <datatype extension="genbank" type="galaxy.datatypes.data:Text" subclass="True" edam_format="format_1936"/>
+    <datatype extension="genbank" type="galaxy.datatypes.data:Text" subclass="True" edam_format="format_1936" display_in_upload="true"/>
     <datatype extension="hennig86" type="galaxy.datatypes.data:Text" subclass="True"/>
     <datatype extension="ig" type="galaxy.datatypes.data:Text" subclass="True"/>
     <datatype extension="jackknifer" type="galaxy.datatypes.data:Text" subclass="True"/>
diff --git a/lib/galaxy/web/form_builder.py b/lib/galaxy/web/form_builder.py
index aa86c9cd9..13207fdbb 100644
--- a/lib/galaxy/web/form_builder.py
+++ b/lib/galaxy/web/form_builder.py
@@ -246,7 +246,7 @@ class GenomespaceFileField(BaseField):
         self.value = value or ""

     def get_html(self, prefix=""):
-        return unicodify('<script src="https://gsui.genomespace.org/jsui/upload/gsuploadwindow.js"></script>'
+        return unicodify('<script src="https://genomespace.genome.edu.au/jsui/upload/gsuploadwindow.js"></script>'
                          '<input type="text" name="{0}{1}" value="{2}">&nbsp;'
                          '<a href="javascript:gsLocationByGet({{ successCallback: function(config)'
                          ' {{ selector_name = \'{0}{1}\'; selector = \'input[name=\' + selector_name.replace(\'|\', \'\\\\|\') + \']\';'
diff --git a/openid/genomespace.xml b/openid/genomespace.xml
index 65bf95ecb..983f31807 100644
--- a/openid/genomespace.xml
+++ b/openid/genomespace.xml
@@ -1,6 +1,6 @@
 <?xml version="1.0"?>
 <provider id="genomespace" name="GenomeSpace">
-    <op_endpoint_url>https://identity.genomespace.org/identityServer/xrd.jsp</op_endpoint_url>
+    <op_endpoint_url>https://genomespace.genome.edu.au/identityServer/xrd.jsp</op_endpoint_url>
     <sreg>
         <field name="nickname" required="True">
             <use_for name="username"/>

diff --git a/tools/data_source/ucsc_tablebrowser.xml b/tools/data_source/ucsc_tablebrowser.xml
index f93aca608..8dac1c17d 100644
--- a/tools/data_source/ucsc_tablebrowser.xml
+++ b/tools/data_source/ucsc_tablebrowser.xml
@@ -4,10 +4,10 @@
     the initial response.  If value of 'URL_method' is 'post', any additional params coming back in the
     initial response ( in addition to 'URL' ) will be encoded and appended to URL and a post will be performed.
 -->
-<tool name="UCSC Main" id="ucsc_table_direct1" tool_type="data_source" version="1.0.0">
+<tool name="UCSC Main" id="ucsc_table_direct1" tool_type="data_source">
     <description>table browser</description>
     <command interpreter="python">data_source.py $output $__app__.config.output_size_limit</command>
-    <inputs action="https://genome.ucsc.edu/cgi-bin/hgTables" check_values="false" method="get">
+    <inputs action="http://ucsc.genome.edu.au/cgi-bin/hgTables" check_values="false" method="get">
         <display>go to UCSC Table Browser $GALAXY_URL</display>
         <param name="GALAXY_URL" type="baseurl" value="/tool_runner" />
         <param name="tool_id" type="hidden" value="ucsc_table_direct1" />
@@ -39,8 +39,4 @@
         <data name="output" format="tabular" label="${tool.name} on ${organism}: ${table} (#if $description == 'range' then $getVar( 'position', 'unknown position' ) else $description#)"/>
     </outputs>
     <options sanitize="False" refresh="True"/>
-    <citations>
-        <citation type="doi">10.1093/database/bar011</citation>
-        <citation type="doi">10.1101/gr.229102</citation>
-    </citations>
-</tool>
+</tool>
```