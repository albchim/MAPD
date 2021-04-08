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

n_files=1000000
echo "Uploading $n_files files";
# Upload files
TIMEFORMAT=%R
for ((j=1; j<=$n_files; j++))
    do echo "$j";
    if [ ! -f "cloudset.sh" ]; then
        (printf %s "$j; ") >> no_buck/time_1mill.txt;
        (time (cloud_upload 1k.txt $(uuidgen) > /dev/null)) 2>> no_buck/time_1mill.txt
    fi
    if [ -f "cloudset.sh" ]; then
        (printf %s "$j; ") >> w_buck/time_1mill.txt;
        (time (cloud_upload 1k.txt $(uuidgen) > /dev/null)) 2>> w_buck/time_1mill.txt
    fi
done;

time (cloud_ls | wc -l > /dev/null) 2> temp_final.txt

