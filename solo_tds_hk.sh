#!/bin/bash
year=$1
month=$2
idir=/mnt/bigdata2/solo/rpw/HK
odir=/mnt/bigdata2/solo/tds/HK
if ! date -d "$year-$month-01" >/dev/null
then
	year=$(date +%Y)
	month=$(date +%m)
	echo "Invalid Year or Month set! Used current month"
fi
odir="$odir/$year"
echo $year $month $odir
if [ ! -d $odir ]
   then
	   mkdir -p $odir
   fi
   /usr/local/bin/matlab -nodisplay -r "cd('/mnt/raid/homes/dpisa/roc.sgse/solo_tds_hk'); HK_tds_monthly_log($month, $year, '$idir','$odir'); exit"

  exit
