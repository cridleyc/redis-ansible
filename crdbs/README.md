# CRDB json examples
The playbook create A/A (crdb) databases uses json definitions to create the target databases.  The role that creates the database will substitute the vars beginning and ending with '_" using values passed in at runtime.
<br>
for example, '_dbname_', will be replaced with with the value of the runtime var 'dbname', set by the example shell script 'redis-create-crdb.sh'
<br>
The json block itself is used by the API call '/v1/crdbs' - more information can be found [here](https://storage.googleapis.com/rlecrestapi/rest-html/crdb_rest_api.html#post--crdbs)
