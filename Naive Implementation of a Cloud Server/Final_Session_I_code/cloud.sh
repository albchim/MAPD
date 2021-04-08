################################################################################
# CLOUDSTORE shell library - Data Technologies Exercise 3 - CSC 2018
################################################################################
# -------------------------------------
# - low level functions (mostly implemented)
# -------------------------------------
# --- helper functions
# h8d        : 8 value hash function
# h4d        : 4 value hash function (not implemented)
# leftvalue  : return's the left neighbour of a hash value
# rightvalue : return's the right neighbour of a has value
# sha1string : compute SHA1 hash of a string
# hostmap    : map hash values to host names
# portmap    : map hash values to port names
# dbmap      : map hash values to db names
# reset      : re-initialize a kv store to be empty
# --- primary functions
# upload     : upload a file
# download   : download a file
# list       : list files
# delete     : delete a file
# --------------------------------------------------------
# - high level functions (to implement) 
# --------------------------------------------------------
# cloud_upload    : upload a file to the cloud storage
# cloud_download  : download a file from the cloud storage
# cloud_rm        : remove a file from the cloud storage
# cloud_ls        : list files on the cloud storage
# --------------------------------------------------------
################################################################################




# ------------------------------------------------------------------------------
# Convert a hexadecimal character (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) to decimal, divide by 2 and add 1 e.g
# - maps 0-f => 1-8
# args: <hex value> 
# Example: hash=`h8d f` (=> hash=8)
# ------------------------------------------------------------------------------
function h8d { 
    # args: <hex value> 
    echo "obase=10; ibase=16; $( echo "$*/2+1" | sed -e 's/0x//g' -e 's/\([a-z]\)/\u\1/g' )" | bc; 
}

# ------------------------------------------------------------------------------
# Convert a hexadecimal character (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) to decimal, divide by 4 and add 1 e.g
# - maps 0-f => 1-4
# Example: hash=`h4d f` (=> hash=4)
# ------------------------------------------------------------------------------
function h4d { 
    # => to implement
    echo "<implement me>"
}

# ------------------------------------------------------------------------------
# Return the 'left' neighbour hash value for a given hash value for a given hash value range
# args: <hex value> <hash range start> <hash range stop> 
# Example: hashleft=`leftvalue 1 1 8 ` (=> hashleft=8)
# ------------------------------------------------------------------------------
function leftvalue {
    hashleft=$1;
    let hashleft=$hashleft-1;
    if [ $hashleft -lt $2 ]; then 
	echo $3;
    else
	echo $hashleft;
    fi
}

# ------------------------------------------------------------------------------
# Return the 'right' neighbour hash value for a given hash value for a given hash value range
# args: <hex value> <hash range start> <hash range stop> 
# Example: hashright=`rightvalue 8 1 8 ` (=> hashleft=1)
# ------------------------------------------------------------------------------
function rightvalue {
    hashright=$1;
    let hashright=$hashright+1;
    if [ $hashright -gt $3 ]; then 
	echo $2;
    else
	echo $hashright;
    fi
}

# ------------------------------------------------------------------------------
# Compute the SHA1 checksum of a string (filename)
# args: <string> 
# Example: sha1string myfile (=> db00b2897b10a1a3f858609528214a878dd8015d)
# ------------------------------------------------------------------------------
function sha1string() {
    # args: <string> 
    echo $1 | sha1sum | cut -d " " -f 1
}
# ------------------------------------------------------------------------------
# Map a hash values 1-X to a node names ...
# Example: hostmap 1 ( => host1 ... )
# ------------------------------------------------------------------------------

function hostmap() {
    if [ "$1" = "1" ]; then echo localhost; fi
    if [ "$1" = "2" ]; then echo localhost; fi
    if [ "$1" = "3" ]; then echo localhost; fi
    if [ "$1" = "4" ]; then echo localhost; fi
    if [ "$1" = "5" ]; then echo localhost; fi
    if [ "$1" = "6" ]; then echo localhost; fi
    if [ "$1" = "7" ]; then echo localhost; fi
    if [ "$1" = "8" ]; then echo localhost; fi
}

# ------------------------------------------------------------------------------
# Map a hash values 1-X to database names ...
# Example: dbmap 1 ( => 0 ... )
# ------------------------------------------------------------------------------
function dbmap() {
    if [ "$1" = "1" ]; then echo 0; fi
    if [ "$1" = "2" ]; then echo 1; fi
    if [ "$1" = "3" ]; then echo 2; fi
    if [ "$1" = "4" ]; then echo 3; fi
    if [ "$1" = "5" ]; then echo 4; fi
    if [ "$1" = "6" ]; then echo 5; fi
    if [ "$1" = "7" ]; then echo 6; fi
    if [ "$1" = "8" ]; then echo 7; fi
}

# ------------------------------------------------------------------------------
# Map a hash values 1-X to port names ...
# Example: portmap 1 ( => 1 ... )
# ------------------------------------------------------------------------------
function portmap() {
    if [ "$1" = "1" ]; then echo 6379; fi
    if [ "$1" = "2" ]; then echo 6379; fi
    if [ "$1" = "3" ]; then echo 6379; fi
    if [ "$1" = "4" ]; then echo 6379; fi
    if [ "$1" = "5" ]; then echo 6379; fi
    if [ "$1" = "6" ]; then echo 6379; fi
    if [ "$1" = "7" ]; then echo 6379; fi
    if [ "$1" = "8" ]; then echo 6379; fi
}


# ------------------------------------------------------------------------------
# Reset DB at location
# <hash  value>   : hash value (1-8)
# ------------------------------------------------------------------------------
function reset() {
    # args: <hash value>
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` FLUSHALL
}


# ------------------------------------------------------------------------------
# Upload a local file to a storage node
# ------------------------------------------------------------------------------
# <source file>   : source file name to upload
# <hash  value>   : hash value (1-8)
# <target file>   : target file name to store
# return 0 if success
# ------------------------------------------------------------------------------
function upload() {
    # args: <source file> <hash value> <target file>

    if [ ! -f "$1" ]; then
	return -1;
    fi

    redis-cli -h `hostmap $2` -p `portmap $2` -n `dbmap $2` -x SET "name:$3" < $1
}

# ------------------------------------------------------------------------------
# Download a file from a storage node
# ------------------------------------------------------------------------------
# args: <hash value> <source name> <target name>
# <hash value>    : hash value (1-8)
# <source name>   : source file name in storage node
# <target name>   : target file name in local file system
# return 0 if success
# ------------------------------------------------------------------------------
function download() {
    # args: <hash value> <source name> <target name>

    # create all required target directories
    mkdir -p `dirname $3`
    
    # retrieve a key from REDIS and store the raw data in $3
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` --raw GET "name:$2" > $3

    size=`stat -c%s $3`;

    # redis adds to every returned value a '\n', so we need to remove the last byte
    let size=$size-1
    truncate -s $size $3

    # we have to distinguish if a value is 0 length or it does not exist in REDIS
    if [ $size = "0" ]; then
	redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $2` --raw KEYS "name:$2"> $3 && unlink $3 && echo "error: no such file or directory $2" && return -1
    else
	echo "# downloaded $3 with size=$size"
    fi
}

# ------------------------------------------------------------------------------
# Delete a file from a storage node
# <hash value>   : hash value (1-8)
# <delete name>  : file name to delete on storage node
# return 0 if it existed and has been deleted
# ------------------------------------------------------------------------------
function delete() {
    # args: <hash value> <name>
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` DEL "name:$2" | grep 1 > /dev/null
}

# ------------------------------------------------------------------------------
# List the contents of a storage node
# ------------------------------------------------------------------------------
# <hash value>   : hash value (1-8) to list
# <name>         : to list all files in a directory on location 1 use e.g. bash> list 1
# ------------------------------------------------------------------------------
function list() {
    # args: <hash value> [<name> --meta]
    redis-cli -h `hostmap $1` -p `portmap $1` -n `dbmap $1` --scan --pattern "name:$2*" | sed s/^name://
}

# ------------------------------------------------------------------------------
# cloud_download  : download a file from the cloud storage
# ------------------------------------------------------------------------------
# args: <cloud file> <local file> 
# <cloud  file>   : cloud file name to download
# <target file>   : target file name in the local filesystem
# return 0 if success
function cloud_download() {

   # check that the target is not yet existing
   if [ -f "$2" ]; then
      echo "error: target exists";
      return 1;
   fi

   hash=`sha1string $1`;
   hashkey=${hash:0:1}
   hashvalue=`h8d $hashkey`;
   echo "==> Downloading $1 with hash $hash from DHT location $hashvalue"
   download $hashvalue $1 $2

   # check if something was actually downloaded
   if [ ! -f $2 ]; then
      echo "error: download failed";
      return 1;
   fi
}


# ------------------------------------------------------------------------------
# cloud_rm        : remove a file from the cloud storage
# ------------------------------------------------------------------------------
# args: <cloud file> 
# <cloud file>    : file name to delete 
function cloud_rm() {
   hash=`sha1string $1`;
   hashkey=${hash:0:1}
   hashvalue=`h8d $hashkey`;
   echo "==> Deleting $1 with hash $hash from DHT location $hashvalue"
   delete $hashvalue $1
}



# ------------------------------------------------------------------------------
# ----------------------------------BUCKETS-------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------


# Include cloudset for buckets
if [ -f "cloudset.sh" ]; then
    . cloudset.sh
    echo "cloudset loaded successfully!"

    # personal bucket initialization
    bucketname="$USER"
    buckethash=`sha1string $bucketname`
    buckethashkey=${buckethash:0:1}
    bucketindex=`h8d $buckethashkey`
    # ------------------------------------------------------------------------------
    # cloud_upload    : upload a file to the cloud storage
    # ------------------------------------------------------------------------------
    # args: <source file> <cloud file>
    # <source file>   : source file name to upload
    # <cloud file>    : file name in the cloud system 
    # return 0 if success
    function cloud_upload() {

        # check if the source file exists
        if [ ! -f "$1" ] ; then
            echo "error: source file <$1> does not exist!";
            return 1;
        fi

        hash=`sha1string $2`;
        hashkey=${hash:0:1}
        hashvalue=`h8d $hashkey`;
        echo "==> Uploading $1 with hash $hash to DHT location $hashvalue"
        upload $1 $hashvalue $2
        # Associate buckethashkey
        set_add $bucketindex $bucketname $2
    }
    # ------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------
    # cloud_ls        : list files on the cloud storage
    # args: <none>
    # ------------------------------------------------------------------------------
    function cloud_ls() {
        set_ls $bucketindex $bucketname | sort
    }
    # ------------------------------------------------------------------------------
fi

if [ ! -f "cloudset.sh" ]; then
    echo "ATTENTION cloudset.sh MISSING, cannot use buckets!"

    # ------------------------------------------------------------------------------
    # cloud_upload    : upload a file to the cloud storage
    # ------------------------------------------------------------------------------
    # args: <source file> <cloud file>
    # <source file>   : source file name to upload
    # <cloud file>    : file name in the cloud system 
    # return 0 if success
    function cloud_upload() {

        # check if the source file exists
        if [ ! -f "$1" ] ; then
            echo "error: source file <$1> does not exist!";
            return 1;
        fi

        hash=`sha1string $2`;
        hashkey=${hash:0:1}
        hashvalue=`h8d $hashkey`;
        echo "==> Uploading $1 with hash $hash to DHT location $hashvalue"
        upload $1 $hashvalue $2
    }
    # ------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------
    # cloud_ls        : list files on the cloud storage
    # args: <none>
    # ------------------------------------------------------------------------------
    function cloud_ls() {
        tmpfile="/tmp/.cloud_ls.$RANDOM"
        for name in 1 2 3 4 5 6 7 8; do
            list $name >> $tmpfile
            done
        sort $tmpfile
        unlink $tmpfile
    }
    # ------------------------------------------------------------------------------

fi

