source cloud.sh

# Deleate preexisting files
redis-cli -h `hostmap 1` -p `portmap 1` -n `dbmap 1` FLUSHALL;

# Create directories to store the times
if [ ! -f "no_buck" ]; then
    mkdir -m u=rwx,g=rx,o= no_buck
fi
if [ ! -f "w_buck" ]; then
    mkdir -m u=rwx,g=rx,o= w_buck
fi

# Create 1kb file if it doesn't exist
if [ ! -f "1k.txt" ] ; then
    dd if=/dev/zero of=1k.txt bs=1k count=1;
fi

# Loop over the copies
for n_files in 100 500 1000 5000 10000 100000
    do echo "Uploading $n_files files";
    # Reinitialize the database
    redis-cli -h `hostmap 1` -p `portmap 1` -n `dbmap 1` FLUSHALL > /dev/null;
    TIMEFORMAT=%R
    # Upload files
    for ((j=1; j<=$n_files; j++))
	do cloud_upload 1k.txt $(uuidgen) > /dev/null;
	done;
    # Store times
    if [ ! -f "cloudset.sh" ]; then
        (printf %s "$n_files; ") >> no_buck/time.txt;
        (time cloud_ls | wc -l) 2>> no_buck/time.txt;
    fi
    if [ -f "cloudset.sh" ]; then
        (printf %s "$n_files; ") >> w_buck/time.txt;
        (time cloud_ls | wc -l) 2>> w_buck/time.txt;
    fi
    echo "Done!"
    done;
