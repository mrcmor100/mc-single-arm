#!/bin/csh 
use root/6.10.02

cd /u/group/c-xem2/cmorean/monteCarlo/xgt1_2018/xgt1_2018_mc_10_27_21/mc-single-arm/

set i=0
while ($i < $2)
    set mcInp = "./infiles/$1.inp"
    set mcInpNum = "./infiles/$1_$i.inp"
    cp $mcInp $mcInpNum
    @ i=$i + 1
end

wait

cd ./src/
set i=0
while  ($i < $2)
    set inpStr = "$1_$i"
    mc_single_arm << endofinput >! ../runout/$1_$i.out &
$inpStr
endofinput
    sleep 0.5
    @ i=$i + 1
end

wait

cd ../

echo `pwd`

use root/6.10.02

set i = 0
set b=`echo "$1" | tr '[A-Z]' '[a-z]'`
while  ($i < $2)
    set inpStr = "./worksim/"$b"_"$i".rzdat"
    set outStr = "./worksim/$1_$i.root"
    h2root $inpStr $outStr &
    @ i=$i + 1
end

wait

set rmInpNum = "./infiles/$1_*.inp"
rm $rmInpNum



set joinedRootFile = "./worksim/$1.root"
set partialRootFiles = "./worksim/$1_*.root"
hadd -f $joinedRootFile $partialRootFiles

set rmRZDat = "./worksim/"$b"_*.rzdat"
rm $rmRZDat

rm $partialRootFiles
