#!/bin/bash

## generate and save the diff between $1 and $2
save_diff() {
    src=$1
    dst=${2%/} # trim "/" in the end

    if [ ! -f $src ]; then
        echo "$src must be a file"
        return 1
    fi

    file_name=$(basename $src)
    diff_dir=/integration/tmp/$(hostname -f)

    mkdir -p $diff_dir

    # if dst is a file, construct the target file path, otherwise, assume dst is already a file
    target_file=$([[ -d $dst ]] && echo $dst/$file_name || echo $dst)
    # if target_file doesn't exit, make diff with empty file
    target_file=$([[ -f $target_file ]] && echo $target_file || echo /dev/null)

    diff $target_file $src >$diff_dir/$file_name.diff
}

diff_cp() {
    src=$1
    dst=$2

    # save the difference of new and old file
    save_diff src dst
    # then replace the old file with the new one
    cp src dst
}
