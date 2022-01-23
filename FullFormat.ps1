## Using the Windows Forms to get a proper dialog up
$Info="yellow"
$Waiting="gray"
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
  Filter = 'All Images|*.d64;*.d71|1541 Images|*.d64|1571 Images|*.d71'
}
$null = $FileBrowser.ShowDialog()

if  ( $FileBrowser.Filename -eq "" ) {
    Write-Host "Aborting."
    exit
}

$file=Get-Item $FileBrowser.Filename
$ext=$file.Extension

## Write out a status 
Write-Host "Working with" $FileBrowser.FileName "using" $ext -ForeGroundColor $Info
Write-Host ""
Write-Host "Hard reset the drive" -ForeGroundColor $Info
cbmctrl command 8 "UJ"
#Write-Host "Formatting disk in whatever mode it's in; Show Status; Extend Format (40 Sectors)"
#cbmforng -x 8 disk,id
Write-Host "Initialize the drive" -ForeGroundColor $Info
cbmctrl command 8 I
if ( $ext -eq ".d71" ) {
    Write-Host "Select 1571 mode" -ForeGroundColor $Info
    cbmctrl command 8 "U0>M1"
    Write-Host "Select side 0" -ForeGroundColor $Info
    cbmctrl command 8 "U0>H0"
    $ds=-2
} else {
    Write-Host "Select 1541 mode" -ForeGroundColor $Info
    cbmctrl command 8 "U0>M0"
    $ds=""
}
Write-Host "Do a complete format" -ForeGroundColor $Info
cbmctrl command 8 "N:LONGREFORMAT,LR"
Write-Host "Waiting for status" -ForeGroundColor $Waiting
cbmctrl status 8
Write-Host "Validating format and structure"
cbmctrl command 8 V
Write-Host "Showing initial directory" -ForeGroundColor $Info
cbmctrl dir 8
Write-Host "Copy $File to diskette" -ForeGroundColor $Info
d64copy $ds "$file" 8
Write-Host "Wait for Status" -ForeGroundColor $Waiting
cbmctrl status 8
Write-Host "Re-Validating format and structure"
cbmctrl command 8 V
Write-Host "Showing new directory" -ForeGroundColor $Info
cbmctrl dir 8
