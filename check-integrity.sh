#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Script Name: check-integrity.sh
# Author: Vu Phuong Quynh (Billy) Nguyen
# Date: 2025-03-01
# Description: This script offers the following options 
#              along with their purposes:
#               --baseline: generates SHA-256 hashes of all the files in the
#				            /etc directory of the machine, and saves them as
#			  	            baseline value in a local txt file at the script's directory.
#		        --check: generates new SHA-256 hashes of the current files in
#				            the /etc directory of the machine, and compares
#				            them to the baseline hashes, and logs the
#				            details to a local log file of potential
#				            integrity tampering and changes.
#		        --report: displays the log report.

etc_path="/etc"
output_file="etc_hashes.txt"
temp_file="temp_hashes.txt"
hash_diff="hash_diff.txt"
log_file="/var/log/syslog"

# Function: print_usage
# Purpose: This function displays help information with details on how to use each command option.
print_usage() {
    echo "Usage: $0 [-h] [-b] [-c] [-r]"
    echo "Options:"
    echo "  -h, --help              Show this help message and exit"
    echo "  -b, --baseline          Generates SHA-256 hashes for all /etc files and saves to local txt file"
    echo "  -c, --check             Compares current SHA-256 hashes of all /etc files with baseline. Reports to log if found changes"
    echo "  -r, --report            Displays report"
}

# Function: log
# Purpose: This function logs messages to /var/log/syslog. 
#			A log message will consist of priority, tag, timestamp, and the message.
# Parameters:
#   $1 - Priority level of the log message. The priority may be specified numerically or as a facility.level pair.
#   $2 - The message to be logged.
# Error Conditions:
#   - If logger command fails,
#	  the function prints an error message.
log() {
	local level="$1"
	local message="$2"
	local tag="${3:-check-integrity}"
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	logger -p "user.$level" -t "$tag" "[$timestamp] $message" || echo "Error: Failed to log."
}

# Function: baseline_generation
# Purpose: This function generates SHA-256 hashes of all the files in the /etc directory of the machine, 
# 			and saves them as baseline value in a local txt file at the script's directory.  
# Parameters:
#   $1 - Output file to save the generated hashes to.
# Error Conditions:
#	- If output file cannot be cleared,
#	  the function prints an error message.
#   - If a file in the /etc directory cannot be read (permission denied),
#	  the function prints an error message.
#   - If sha256sum command fails,
#	  the function prints an error message.
baseline_generation() {
	echo "Info: Writing to $1"
	> "$1" || "Error: Cannot clear file $1. Try again."
	
	# Check all files and symbolic links
	find $etc_path -type f,l 2>/dev/null | while read -r file; do
		if [ -r "$file" ]; then
		
			# Check for common temporary or backup file patterns
			if [[ "$file" =~ \.(bak|tmp|swp|swx|sw~|~)$ ]] || [[ "$file" =~ \#.*\# ]]; then
				echo "Info: Temporary file found. Skipping $file"
				continue
			fi
				
			# Hash current file read, error handling if any files cannot be hashed
    		sha256sum "$file" >> "$1" || echo "Error: Cannot hash $file. Try again." 
		else
			echo "Error: Permission denied: $file"
		fi
	done
	echo "Hashes generation: DONE"
	echo "=========================================="
}

# Function: integrity_check
# Purpose: This function generates new SHA-256 hashes of the current files in the /etc directory of the machine, 
# 			and compares them to the baseline hashes. If changes are found, it logs logs the details to a local log 
# 			file of potential integrity tampering and changes. If the baseline is not found, it uses the current 
#			hashes as the baseline. 
# Error Conditions:
#	- If temp file cannot be cleared,
#	  the function prints an error message.
#	- If diff file cannot be cleared,
#	  the function prints an error message.
#   - If temp file cannot be removed,
#	  the function prints an error message.
#   - If diff file cannot be removed,
#	  the function prints an error message.
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
			# Log the details of the changes to a report file
			log "info" "Potential tampering found. Changes: \"$(cat $hash_diff)\""
			# Alert the user by printing
			report
		else
			echo "Info: Found no changes in /etc"
		fi
	else # If not, use current hashes as baseline by renaming files
		echo "Info: Found no baseline hashes. Generating new baseline"
		mv $temp_file $output_file
	fi
	
	# Clean up temp hash and diff files
	rm -rf $temp_file || echo "Error: Cannot delete file, file not found"
	rm -rf $hash_diff || echo "Error: Cannot delete file, file not found"
	echo "Integrity check: DONE"
	echo "=========================================="
}

# Function: report
# Purpose: This function displays the log report from /var/log/syslog, filtering for this script's tag.  
# Error Conditions:
#	- If grep command fails,
#	  the function prints an error message.
#   - If /var/log/syslog cannot be read (permission denied),
#	  the function prints an error message.
report() {
	if [ -r "$log_file" ]; then
		# Display report with script's tag
		grep -a "check-integrity" $log_file || echo "Error: Cannot print report in $log_file. Try again."
	else
		echo "Error: Permission denied: $log_file"
	fi
	echo "Report: DONE"
	echo "=========================================="
}

parse_options() {
	# Parse options
	OPTIONS=$(getopt -o hbcr --long help,baseline,check,report -- "$@")
	
	# Check if getopt succeeded
	if [ $? -ne 0 ]; then
		print_usage
		exit 1
	fi

	# Reorganize positional parameters as per parsed options
	eval set -- "$OPTIONS"
	
	# If the first argument is '--', it means no flags/options were passed
	if [ "$1" == "--" ]; then
    	print_usage
    fi

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
}

echo "Script is running from $(pwd)"
parse_options "$@"

