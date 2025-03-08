#!/usr/bin/env sh
# Script Name: integrity.sh
# Author: Vu Phuong Quynh (Billy) Nguyen
# Date: 2025-03-01
# Description: This script offers the following options 
#              along with their purposes:
#               --baseline: generates SHA-256 hashes of all the files in the
#				            /etc directory of the machine, and saves them as
#			  	            baseline value in a local txt file.
#		        --check: generates new SHA-256 hashes of the current files in
#				            the /etc directory of the machine, and compares
#				            them to the baseline hashes, and logs the
#				            details to a local log file of potential
#				            integrity tampering and changes.
#		        --report: displays the logged report.

etc_path="/etc"
test_etc="/Users/billy/Doc/BCIT_Bachelor_Fall_2024/Term 6/COMP8003"

# Print usage information
# Usage: Displays help information with details on how to use each command option.
print_usage() {
    echo "Usage: $0 [-h] [-b] [-c] [-r]"
    echo "Options:"
    echo "  -h, --help              Show this help message and exit"
    echo "  -b, --baseline          Generates SHA-256 hashes for all /etc files and saves to local txt file"
    echo "  -c, --check             Compares current SHA-256 hashes of all /etc files with baseline. Reports to log if found changes"
    echo "  -r, --report            Displays report"
}

# # Parse options
# OPTIONS=$(getopt -o hbcr --long help,baseline,check,report -- "$@")

# # Debugging output
# echo "OPTIONS after getopt: $OPTIONS"
# if [ $? -ne 0 ]; then
#     print_usage
#     exit 1
# fi
# echo "Here 1 option after eval = $1"
# # Reorganize positional parameters as per parsed options
# eval set -- "$OPTIONS"
# echo "Here 1 option after eval = $1"
# # Process each option, checking for errors and assigning values
# while true; do
#     case "$1" in
#         -h | --help)
#             print_usage
#             exit 0
#             ;;
#         -b | --baseline)
#             echo "Baseline option"
#             shift
#             ;;
#         -c | --check)
#             echo "Check option"
#             shift
#             ;;
#         -r | --report)
#             echo "Report option"
#             shift
#             ;;
#         --)
#             echo "-- option"
#             shift
#             break
#             ;;
#         *)
#             print_usage
#             exit 1
#             ;;
#     esac
# done

while getopts hbcr opt; do
   case $opt in
     h ) 
        print_usage                          
        ;;
     b ) 
        echo "Baseline option"                       
        ;;
     c ) 
        echo "Check option"                         
        ;;
     r ) 
        echo "Report option"     
        ;;
     \? )
        print_usage
        exit 1
        ;;
  esac
done
shift $((OPTIND-1))