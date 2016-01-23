#!/bin/bash

# Parse PDBID_Chain list from downloaded RCSB's PDB Custom Report
# ./getPDBChainList.sh 20160122_RCSB_PDBCustomReport.csv

cat "$1" | cut -d',' -f 1,2 | tr -d '"' | sed 's/,/_/g' | tail -n +2 >PDBChain.lst
