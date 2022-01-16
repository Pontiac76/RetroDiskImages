## Using the Windows Forms to get a proper dialog up
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
  Filter = 'All Images|*.d64;*.d71|1541 Images|*.d64|1571 Images|*.d71'
}
$null = $FileBrowser.ShowDialog()

$file=Get-Item $FileBrowser.Filename
$ext=$file.Extension

## Write out a status
Write-Host "Working with" $FileBrowser.FileName "using" $ext
Write-Host ""
Write-Host "Hard reset the drive"
cbmctrl command 8 "UJ"
Write-Host "Formatting disk in whatever mode it's in; Show Status; Extend Format (40 Sectors)"
cbmforng -s -x 8 disk,id
Write-Host "Initialize the drive"
cbmctrl command 8 I
if ( $ext -eq ".d71" ) {
    Write-Host "Select 1571 mode"
    cbmctrl command 8 "U0>M1"
    Write-Host "Select side 0"
    cbmctrl command 8 "U0>H0"
    $ds=-2
} else {
    Write-Host "Select 1541 mode"
    cbmctrl command 8 "U0>M0"
    $ds=""
}
Write-Host "Do the a complete format"
cbmctrl command 8 "N:LONGREFORMAT,LR"
Write-Host "Waiting for status"
cbmctrl status 8
Write-Host "Showing initial directory"
cbmctrl dir 8
Write-Host "Copy $File to diskette"
d64copy $ds "$file" 8
Write-Host "Wait for Status"
cbmctrl status 8
Write-Host "Showing new directory"
cbmctrl dir 8
