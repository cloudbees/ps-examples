# CloudBees Core in K8s Data Gathering Script

This script gathers a snapshot of data from a specific cluster, tests the connections between one or more masters and CJOC, and gets the support bundles from CJOC and one or more masters.

## Single Master

It can be targeted at a specific master by passing in the following fields:

**Required**
-c | --cjoc-namespace CJOC_NAMESPACE
-n | --master-name MASTER_NAME

**Optional**
-m | --master-namespace MASTER_NAMESPACE (if no value is passed in, then the CJOC_NAMESPACE will be used)

## Set of Masters by Mapping File

It can also be targeted at a set of masters by passing in a mapping file that is a CSV where column one is the master name and column two is the master namespace. Pass in the following fields:

**Required**
-f | --file /path/to/mapping/file
-c | --cjoc-namespace CJOC_NAMESPACE

### Mapping File

The mapping file must be in the following format:

```csv
master-name1,master-namespace1
master-name2,master-namespace2
master-name3,master-namespace3
```

## Set of Masters with Dynamically Built Mapping File

By passing `-a true`, the script will build the mapping file for all masters dynamically. The user running the script **MUST HAVE** cluster admin privileges, otherwise the script will not work in this manner as it requires access to all namespaces.


### To-Do

* Testing needs to be done for masters with spaces in their name -- likely will cause some parts of the script to break and should be accounted for in a future iteration
* It may be worthwhile to add a section in to test service accounts to see if they have the capabilities to do all of the "things" necessary to make CloudBees Core work
