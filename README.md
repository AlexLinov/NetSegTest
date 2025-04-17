## Overview

**NetSegTest.ps1** is an interactive PowerShell script for network assessments.  
It quickly discovers live hosts and performs TCP or UDP port scans across multiple VLANs using Nmap.

- **Finds live hosts** in given VLAN ranges (e.g., `10.0.20.0/24`)
- **Saves** each VLAN’s live hosts to a text file (e.g., `vlan20.txt`)
- **Runs Nmap** full port scans on only the live hosts (TCP or UDP)
- Designed for blue teams, red teams, and network engineers who need efficient and targeted port scanning

---

## Requirements

- **Nmap** installed at  
  `C:\Program Files (x86)\Nmap\nmap.exe`  
  (Update the path in the script if yours is different)
- **PowerShell** (Tested on Windows 10/11)

---

## How To Use

1. **Open PowerShell as Administrator**
2. **Run the script:**
   ```powershell
   .\NetSegTest.ps1
   
