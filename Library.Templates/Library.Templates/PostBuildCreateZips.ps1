# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$VsProjectName = $args[0]

$PathRoot = $PSScriptRoot

$FileSuffix = '.zip'

$PathMyDocuments   = [environment]::getfolderpath("mydocuments")
$PathUserTemplates = $PathMyDocuments + '\Visual Studio 2022\Templates\ItemTemplates\' + $VsProjectName + '\'

Write-Host

Write-Host ('Deleting files:  ' + $PathRoot + '\bin\*.zip')
Remove-Item -Recurse -Force -Path ($PathRoot + '\bin\*.zip')

Write-Host ('Deleting folder: ' + $PathUserTemplates)
Remove-Item -Recurse -Force -Path $PathUserTemplates

Write-Host ('Creating folder: ' + $PathUserTemplates)
New-Item -ItemType Directory -Force -Path $PathUserTemplates | Out-Null

Write-Host
Write-Host 'Compressing:'

$Folders = Get-ChildItem -Path $PathRoot -Exclude bin,obj,Icons -Directory -Force -ErrorAction SilentlyContinue -Name

foreach ($Folder in $Folders)
{
    $PathSource    = ($PathRoot + '\' + $Folder + '\*')
    $PathTargetBin = ($PathRoot + '\bin\' + $Folder + $FileSuffix)
    $PathTargetUsr = ($PathUserTemplates  + $Folder + $FileSuffix)

    Write-Host ($Folder + '\*')

    Compress-Archive -Path $PathSource -DestinationPath $PathTargetBin -Force
    Compress-Archive -Path $PathSource -DestinationPath $PathTargetUsr -Force
}

Write-Host
Write-Host 'Compressed files:'
Write-Host ($PathRoot + '\bin\')
Write-Host $PathUserTemplates