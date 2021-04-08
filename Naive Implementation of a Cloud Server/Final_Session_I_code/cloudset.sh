################################################################################
# CLOUDSTORE shell sub-library - DT Exercise 3 - CSC 2018
################################################################################
# -------------------------------------
# - contains functions to implement a string set stored in REDIS
# (like collection, directory or std::set<std::string> in C++)
# -------------------------------------
# set_delete : delete a set
# set_add    : add a string to a set
# set_remove : remove a string from a set
# set_ls     : list all the items in a given set
################################################################################


# ------------------------------------------------------------------------------
# Delete a set on a given location
# args: <hash value> <set-name>
# Example: set_delete 1 mybucket
# ------------------------------------------------------------------------------
function set_delete() {
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` DEL "set:$2"
}

# ------------------------------------------------------------------------------
# Add a string item to a set
# args: <hash value> <set-name> <item-name>
# Example: set_add 1 mybucket myfile
# ------------------------------------------------------------------------------
function set_add() {
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` SADD "set:$2" "$3"
}

# ------------------------------------------------------------------------------
# Remove a string item from a set
# args: <hash value> <set-name> <item-name>
# Example: set_remove 1 mybucket myfile
# ------------------------------------------------------------------------------
function set_remove() {
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` SREM "set:$2" "$3"
}

# ------------------------------------------------------------------------------
# List all string items in a set
# args: <hash value> <set-name>
# Example: set_ls 1 myfolder
# ------------------------------------------------------------------------------
function set_ls() {
    redis-cli --raw -h `hostmap $1` -p `portmap $1` -n `dbmap $1` SMEMBERS "set:$2"
}

