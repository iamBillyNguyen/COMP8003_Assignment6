#!/usr/bin/env sh
# Script Name: check-integrity.sh
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
test_etc="/home/billy/Downloads"
output_file="etc_hashes.txt"
temp_file="temp_hashes.txt"
hash_diff="hash_diff.txt"
log_file="/var/log/syslog"

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

log() {
	local level="$1"
	local message="$2"
	local tag="${3:-check-integrity}"
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	logger -p "user.$level" -t "$tag" "[$timestamp] $message"
}

baseline_generation() {
	echo "Info: Using $1"
	> "$1" || "Error: Cannot clear file $1"
	find $etc_path -type f,l 2>/dev/null | while read -r file; do
		if [ -r "$file" ]; then
    		sha256sum "$file" >> "$1" || echo "Error: Cannot hash $file. Try again."
		else
			echo "Error: Permission denied: $file"
		fi
	done
	echo "Baseline generation: DONE"
}

integrity_check() {
	> "$temp_file" || "Error: Cannot clear file $temp_file"
	> "$hash_diff" || "Error: Cannot clear file $hash_diff"
	echo "Info: Generating comparing hashes"
	baseline_generation "$temp_file"
	# Check if baseline hashes exist
	if [ -f "$output_file" ]; then
		diff "$output_file" "$temp_file" > $hash_diff
		
		# Check if hash_diff has content, meaning there are changes
		if [ -s $hash_diff ]; then
			echo "Warning: Found changes in /etc"
			log "info" "Found changes: \"$(cat $hash_diff)\""
		else
			echo "Info: Found no changes in /etc"
		fi
	else # If not, use current hashes as baseline by renaming files
		echo "Info: Found no baseline hashes. Generating new baseline"
		mv $temp_file $output_file || echo "Error: Cannot rename files"
	fi
	
	# Clean up temp hash and diff files
	rm -rf $temp_file || echo "Error: Cannot delete file, file not found"
	rm -rf $hash_diff || echo "Error: Cannot delete file, file not found"
}

report() {
	if [ -r "$log_file" ]; then
		# Display report with script's tag
		grep -a "check-integrity" $log_file || echo "Error: Cannot print report in $log_file. Try again."
	else
		echo "Error: Permission denied: $log_file"
	fi
}

 # Parse options
 OPTIONS=$(getopt -o hbcr --long help,baseline,check,report -- "$@")

 if [ $? -ne 0 ]; then
     print_usage
     exit 1
 fi

 # Reorganize positional parameters as per parsed options
 eval set -- "$OPTIONS"

 # Process each option, checking for errors and assigning values
 while true; do
	case "$1" in
		-h | --help)
		print_usage
		exit 0
		;;
	-b | --baseline)
		baseline_generation "$output_file"
		shift
		;;
	-c | --check)
		integrity_check
		shift
		;;
	-r | --report)
		report
		shift
		;;
	--)
		shift
		break
		;;
	*)
		print_usage
		exit 1
		;;
	esac
 done
