# COMP8003_Assignment6

Welcome to the `COMP8003_Assignment6` repository. This guide will help you set up and run the provided scripts.

## **Table of Contents**

1. [Cloning the Repository](#cloning-the-repository)
2. [Prerequisites](#Prerequisites)
3. Running the programs](#building-and-running-the-programs)

## **Overview**
The check-integrity.sh bash script monitors the integrity of files within the /etc directory using SHA-256 hashes, logs, and alerts the details of the changes to the system's log at /var/log/syslog file.

## **Disclaimer**
This script uses the /etc and /var/log directories of any Linux-based machines to operate. However, it does not modify one's /etc or /var/log directory. In detail, the script hashes all files and links in the /etc directory and saves the hashes in the project's root for integrity check purpose.

## **Prerequisites**

- Install [python](https://www.python.org/downloads/)

## **Cloning the Repository**

Clone the repository using the following command:

```bash
git clone https://github.com/iamBillyNguyen/COMP8003_Assignment6.git
```

Navigate to the cloned directory:

```bash
cd COMP8003_Assignment6
```

## **Running the script**

To run the script run:

```bash
./check-integrity [-h] [-b] [-c] [-r]
```
