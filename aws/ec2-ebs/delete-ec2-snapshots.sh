#!/bin/bash
#
# NAME: delete-ec2-snapshots.sh
# AUTHOR: Vagner Rodrigues Fernandes <vagner.rodrigues@gmail.com>
# USE: ./delete-ec2-snapshots.sh <REGION> <MIN-RETAIN-SNAPSHOTS> <VOLUME-ID>
#

MIN=$2
VOLUME_ID=$3
REGION=$1

aws --region $REGION ec2 describe-snapshots --filters Name=volume-id,Values="$VOLUME_ID" | grep "SnapshotId" | awk '{ print $2 }' > /tmp/__snaps.$$
TOTAL_SNAPS=`cat /tmp/__snaps.$$ | wc -l`

if [ $TOTAL_SNAPS -gt $MIN ]; then
  MIN=$(( $MIN + 1 ))
  for SNAPID in `cat /tmp/__snaps.$$ | tail -n +$MIN | sed 's/\,//g' | sed 's/\"//g'`; do

	aws --region $REGION ec2 delete-snapshot --snapshot-id $SNAPID

  done
fi

rm -f /tmp/__snaps.$$
