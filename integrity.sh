#!/usr/bin/env sh
# Script Name: integrity.sh
# Author: Vu Phuong Quynh (Billy) Nguyen
# Date: 2025-03-01
# Description: This script offers the following options 
#              along with their purposes:
#              	--baseline: generates SHA-256 hashes of all the files in the
#				/etc directory of the machine, and saves them as
#			  	baseline value in a local txt file.
#		--check: generates new SHA-256 hashes of the current files in
#				the /etc directory of the machine, and compares
#				them to the baseline hashes, and logs the
#				details to a local log file of potential
#				integrity tampering and changes.
#		--report: displays the logged report.

