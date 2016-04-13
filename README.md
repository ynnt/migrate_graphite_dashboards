# migrate_graphite_dashboards

This script can save and restore your graphite dashboards using HTTP calls.

**Usage:**

 - Save:
 ```ruby migrate_dashboards.rb -h <graphite_host> > dashboards.txt```
 - Restore:
 ```ruby migrate_dashboards.rb -h <graphite_host> -a restore -i dashboards.txt```
 
 
See ```ruby migrate_dashboards.rb --help``` for a full list of options.

**Thanks**
http://blog.backslasher.net where did I find the initial variant of this script.
