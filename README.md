# JamfAPI-PrivilegesChecker

**JamfAPI-PrivilegesChecker** is a Bash script designed to connect to a Jamf Pro server and retrieve a user's privileges and permissions via the Jamf Pro API.  
It provides a quick and easy way for Jamf administrators to audit and validate user access rights.

## Features

- Connects securely to the Jamf Pro API
- Retrieves and displays all privileges associated with an API user
- Assists in troubleshooting permission issues
- Lightweight and fast command-line tool
- No external dependencies beyond `curl` and `jq`

## Technologies

- Bash
- cURL
- jq (for parsing JSON responses)
- Jamf Pro API

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/paullstanley/JamfAPI-PrivilegesChecker.git
