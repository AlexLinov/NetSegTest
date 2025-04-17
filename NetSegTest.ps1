<#
.SYNOPSIS
    Interactive Nmap VLAN Scanner

.DESCRIPTION
    This PowerShell script performs discovery and TCP/UDP port scans across specified VLAN subnets.
    It uses Nmap to:
    - Discover live hosts using a ping sweep (-sn)
    - Save live IPs per VLAN to `vlan<id>.txt`
    - Perform either a full TCP (-p-) or UDP (-sU) port scan on the discovered live hosts

.AUTHOR
    Alex L.

.VERSION
    1.0

.LASTUPDATED
    2025-04-17

.NOTES
    - Requires Nmap installed at: C:\Program Files (x86)\Nmap\nmap.exe
    - Script will skip VLANs with no detected live hosts
#>

# Configuration
$NmapPath = "C:\Program Files (x86)\Nmap\nmap.exe"
if (-Not (Test-Path $NmapPath)) {
    Write-Host "[X] Nmap not found at: $NmapPath" -ForegroundColor Red
    exit
}

# 1. Scan type
$scanType = Read-Host "Enter scan type (TCP or UDP)"
$scanType = $scanType.Trim().ToUpper()
if ($scanType -ne "TCP" -and $scanType -ne "UDP") {
    Write-Host "[X] Invalid scan type entered. Must be 'TCP' or 'UDP'." -ForegroundColor Red
    exit
}

# 2. IP Prefix
$ipPrefix = Read-Host "Enter first two octets of IP (e.g., 10.0 or 10.10)"

# 3. VLANs
$vlanInput = Read-Host "Enter VLAN IDs (comma-separated, e.g., 10,20,30)"
$vlanIds = $vlanInput -split "," | ForEach-Object { $_.Trim() }

foreach ($vlanId in $vlanIds) {
    $vlanRange = "$ipPrefix.$vlanId.0/24"
    $hostFile = "vlan$vlanId.txt"
    $scanFile = "vlan$vlanId.$($scanType.ToLower()).scan"

    Write-Host "`n[>] Starting host discovery for VLAN $vlanId ($vlanRange)..." -ForegroundColor Yellow

    # Step 1: Discover live hosts
    & $NmapPath -sn $vlanRange -oG "$hostFile.grep"

    # Step 2: Extract live hosts only
    Get-Content "$hostFile.grep" | Where-Object { $_ -match "^Host:\s+(\d+\.\d+\.\d+\.\d+)" } |
        ForEach-Object {
            if ($_ -match "^Host:\s+(\d+\.\d+\.\d+\.\d+)") {
                $matches[1]
            }
        } | Set-Content $hostFile

    Remove-Item "$hostFile.grep" -Force

    if (-Not (Get-Content $hostFile | Measure-Object).Count) {
        Write-Host "[!] No live hosts found in VLAN $vlanId. Skipping scan." -ForegroundColor DarkYellow
        continue
    }

    # Step 3: Port Scan
    Write-Host "[>] Starting $scanType scan on live hosts in VLAN $vlanId..." -ForegroundColor Cyan
    if ($scanType -eq "TCP") {
        & $NmapPath -p- --open -iL $hostFile -vvv -oN $scanFile
    } else {
        & $NmapPath -sU --open -iL $hostFile -vvv -oN $scanFile
    }

    Write-Host "[DONE] Completed $scanType scan -> Output: $scanFile" -ForegroundColor Green
}
