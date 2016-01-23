#!/bin/bash

###############################################################################
#
# Access SEQATOMs [http://www.bioinformatics.nl/tools/seqatoms/services.html]
# File name: downloadSEQATOMs.sh
# Author: Nicolas Palopoli
# Date created: 2016/01/19
# Date last modified: 2016/01/23
# Bash version: 4.3.11(1)-release 
#
###############################################################################

### FUNCTIONS ###

# Test file/dir exists
function testexist {
  if [ ! -f $1 ]
  then
    if [ ! -e $1 ]
    then
      echo "ERROR. Missing $1. Exit."
      exit
    fi
  fi
}

# Remove file if exists
function testrm {
  if [ -f $1 ]
  then
    rm "$1"
  fi
}

### SETUP ###

# Check required files
testexist PDBChain.lst

# Check/create output directory
if [ ! -d ./SEQATOMs_files ]
then
  mkdir ./SEQATOMs_files
fi

### START ###

# Activate to download files
while read line
do
  wget -q 'http://www.bioinformatics.nl/tools/seqatoms/cgi-bin/getseqs?db=pdb_seqatms&id='"$line" -O ./SEQATOMs_files/SEQATOM_"$line".fasta
done<PDBChain.lst
