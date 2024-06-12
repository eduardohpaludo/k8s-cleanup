#!/bin/sh

echo "Starting cleanup..."
echo "Removing empty directories from etcd..."

cleanup_empty_dirs () {
  if [ "$(etcdctl ls $1)" ]; then
    for SUBDIR in $(etcdctl ls -p $1 | grep "/$")
    do
      cleanup_empty_dirs ${SUBDIR}
    done
  else
    echo "Removing empty key $1 ..."
    etcdctl rmdir $1
  fi
}

cleanup_empty_dirs "/registry"
echo "Done with cleanup."