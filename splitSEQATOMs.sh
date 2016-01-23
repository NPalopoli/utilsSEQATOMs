#!/bin/bash

###############################################################################
#
# Split SEQATOMs files by SEQRES and SEQATOM
# File name: splitSEQATOMs.sh
# Author: Nicolas Palopoli
# Date created: 2016/01/22
# Date last modified: 2016/01/22
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

# Print help
function usage {
  description="$(basename "$0")\nProgram to split SEQATOMs files by SEQRES and SEQATOM.\nArguments:\n"
  arguments="-h|--help\tShow this help\n
             -f|--dirfasta\tPath to SEQATOM_<pdb>_<chain>.fasta files\n"
  echo -e -n $description $arguments
}

### SETUP ###

# Set default paths
dirfasta='/home/npalopoli/DBs/SEQATOMs/SEQATOMs_files'

# Parse arguments to override defaults
while [[ $# > 0 ]]  # number of positional parameters
do
  argument="$1"
  case $argument in
    -f|--dirfasta)
      dirfasta="$2"
      testexist $dirfasta
      shift  # past argument
      ;;
    -h|--help)
      usage
      exit
      ;;
    *)
      shift  # unknown option
      ;;
  esac
  shift # past argument or value
done

# Check required files
testexist splitSEQATOMs.py

# Write list of files to process
if [ ! -f ./splitSEQATOMs_files.lst ]
then
#  ls "$dirfasta"/*.fasta | xargs -n 1 basename | cut -d'.' -f 1 >splitSEQATOMs_files.lst
# Sample subsets for testing
  ls "$dirfasta"/SEQATOM_2H8K*.fasta | xargs -n 1 basename | cut -d'.' -f 1 >splitSEQATOMs_files.lst
fi

# Check/create output directory
if [ ! -d ./SEQATOMs_split ]
then
  mkdir ./SEQATOMs_split
fi

# Remove temporary/output files if existing
testrm splitSEQATOMs.tmp
testrm splitSEQATOMs_files_fasta.lst
testrm SEQATOMs_split_all.fasta

### START ###

# Run splitSEQATOMs.py for each in splitSEQATOMs_files.lst
while read line
do
  touch splitSEQATOMs.tmp
  pdb=`echo "$line" | cut -c9-12`
  chain=`echo "$line" | cut -c14`
  ./splitSEQATOMs.py "$dirfasta"/"$line".fasta "$pdb" "$chain"
  for i in `find . -newer splitSEQATOMs.tmp | tail -n +2`
  do
    mv "$i" SEQATOMs_split/.
  done
done<splitSEQATOMs_files.lst

# Collect results in single output
(cd SEQATOMs_split && ls) >splitSEQATOMs_files_fasta.lst
while read line
do
  cat SEQATOMs_split/"$line" >>SEQATOMs_split_all.fasta
  echo >>SEQATOMs_split_all.fasta
done<splitSEQATOMs_files_fasta.lst

# Cleanup
testrm splitSEQATOMs.tmp
testrm splitSEQATOMs_files.lst
testrm splitSEQATOMs_files_fasta.lst
