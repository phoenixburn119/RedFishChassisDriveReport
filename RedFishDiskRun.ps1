# This module uses the Swordfish Powershell Toolkit in order to better address all redfish supported
# devices. This script will import all established ILO/IDRAC devices and retrieve all available disks
# and their health status. It will also export a handy csv file so you can easily parse through the
# exported data. https://github.com/SNIA/Swordfish-Powershell-Toolkit

# Three lines will import Redfish toolkit, import the host file from source, and creates the main array for storage.
Import-Module -Name ./Source/SwordFish/SNIASwordfish.psd1
$HostList = Import-Csv -Path ".\source\IDRACSource.csv"
[System.Collections.ArrayList]$DataCollector = @()

# Removes the existing drive export csv so a new one can replace it. No need for 20 csv's with info.
Try{Remove-Item -Path ./Export/RedFishostPhysicalDrives.csv|Out-Null}Catch{Write-Host "File Already Removed"}

# This is the main loop for the script. It will loop through all hosts on the host file.
for($idx = 0; $idx -lt $($HostList.IP).count; $idx++ ) {
    Write-host $($HostList[$idx].Hostname) welcome to the fight!

    # Connects and grabs a session token for the current host.
    Connect-RedfishTarget -Target $($HostList[$idx].IP)
    Get-RedfishSessionToken -Username $($HostList[$idx].Username) -Password $($HostList[$idx].Password)

    # Retrieves the all drives
    $TempDisks = Get-RedfishDrive

    # Will loop through all disks and check if it already exists in the DataCollector array. This is due to
    # the Redfish get-redfishdrive command returning all disks twice. Just does a quick If to knock out repeats.
    foreach($Disk in $TempDisks) {
        If(-not($Datacollector.Serial -contains $disk.serialnumber)) {
            # Formats the data so it's uniform and then adds that into the main DataCollector array.
            $ValueCollector = [pscustomobject]@{'Hostname'=$($HostList[$idx].Hostname); 'Serial'=$($($Disk.SerialNumber)); `
            'Controller'= $($disk.("@odata.id")); 'HealthStatus'= $($disk.Status); 'FailurePredicted'= $($Disk.FailurePredicted); `
            'MediaType'= ($Disk.MediaType); 'PartNumber' = ($Disk.PartNumber)}
            $DataCollector.add($ValueCollector)
        }
    }
}
# Exports all data collected to a csv under the Export folder.
$DataCollector | export-csv -Path ./Export/RedFishostPhysicalDrives.csv