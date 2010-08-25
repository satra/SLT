#!/bin/tcsh
mkdir temp
cd temp
svn export /speechlab/software/SLT SLT
#mkdir SLT
#cp -r SLTdoc SLT
#cp -r SLTDemo SLT
#cp -r ASAP SLT
#cp -r RAT2 SLT
#cp -r SurfTools SLT
#cp -r FSTools SLT
#cp -r FSParc SLT
#cp -r utils SLT
#cp -r startup SLT
cd SLT
rm -r conversion
rm -r DIVA
rm -r MAT2
rm -r RAVE
rm -r SAT
rm -r scripts
rm -r SEM
rm -r slice_overlay
rm -r snpm2 
rm -r spm2 
rm -r spm2_dev 
rm -r spm2updates
rm -r spmd2 
rm -r RAT2/testdata
rm -r TalSpace
rm -r WFU_PickAtlas
rm create_distribution.csh
rm -r DIVA
echo `date +%d%b%Y` > BUILD.date
ln -s SLTdoc/SLTManual.pdf README.pdf
cd ..
tar jcf /speechlab/software/SLT_{`date +%d%b%Y`}.tar.bz2 SLT
rm -r SLT
cd ..
rm -r temp
