#Requires -Version 4
<#
    .Synopsis
    This script is used to change contact information for registered domains in AWS Route 53
    .DESCRIPTION
    This script is used to change contact information for registered domains in AWS Route 53
    .EXAMPLE
    .\route53changeContactInfo.ps1 -All|-Admin|-Registrant|-Tech
    .NOTES
    File Name  : route53changeContactInfo.ps1
    Author     : Jostein Elvaker Haande
    Email      : tolecnal@tolecnal.net
    Requires   : PowerShell Version 4.0
#>

<# REVISION HISTORY

Version: 0.1
Date: 2023-10-12
Comment: first release

#>

#region PARAMETERS
[CmdletBinding()]
Param
(
  # Parameter help description
  [Parameter(Mandatory = $true, HelpMessage = "Domain name to update")]
  [string]$DomainName
  ,
  [Parameter(Mandatory = $true, HelpMessage = "AWS Profile to use")]
  [string]$AWSProfile
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update all contact information")]
  [boolean]$All = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update admin contact information")]
  [boolean]$Admin = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update registrant contact information")]
  [boolean]$Registrant = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "User ID of the user to delete")]
  [boolean]$Tech = $false
)
#endregion PARAMETERS

#region imports
Import-Module AWS.Tools.Common
Import-Module AWS.Tools.Route53
Import-Module AWS.Tools.Route53Domains
#endregion imports

#region script
$ThisScript = $SCRIPT:MyInvocation.MyCommand
$scriptFolder = $(Get-Item $ThisScript.Path).DirectoryName

Start-Transcript -Append -Path $($scriptFolder + "/route53changeContactInfo.txt")

try {
  Set-AWSCredentials -ProfileName $AWSProfile
}
catch {
  throw $_.Exception.Message
}

# Load configuration file if it exists
try {
  Foreach ($i in $(Get-Content route53changeContactInfo.conf)) {
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=", 2)[1]
  }
}
catch {
  throw $_.Exception.Message
}


# Update the admin contact information for the domain
if ($All -or $Admin) {
  try {
    $res = Update-R53DDomainContact -Domain $DomainName -AdminContact_AddressLine1 $adminContact_AddressLine1 `
      -AdminContact_City $adminContact_City -AdminContact_CountryCode $AdminContact_CountryCode `
      -AdminContact_Email $AdminContact_Email -AdminContact_FirstName $AdminContact_FirstName `
      -AdminContact_LastName $AdminContact_LastName -AdminContact_OrganizationName $AdminContact_OrganizationName `
      -AdminContact_PhoneNumber $AdminContact_PhoneNumber -AdminContact_ZipCode $AdminContact_ZipCode
  }
  catch {
    throw $_.Exception.Message
  }

  # Wait for the update to be successful
  $tempStatus = Get-R53DOperationDetail -OperationId $res
  while ($tempStatus.Status -ne "SUCCESSFUL") {
    Start-Sleep -Seconds 15
    $tempStatus = Get-R53DOperationDetail -OperationId $res
    Write-Host "Status admin update: $($tempStatus.Status)"
  }
}


# Update the registrant contact information for the domain
if ($All -or $Registrant) {
  try {
    $res = Update-R53DDomainContact -Domain $DomainName -RegistrantContact_AddressLine1 $RegistrantContact_AddressLine1 `
      -RegistrantContact_City $RegistrantContact_City -RegistrantContact_CountryCode $RegistrantContact_CountryCode `
      -RegistrantContact_Email $RegistrantContact_Email -RegistrantContact_FirstName $RegistrantContact_FirstName`
      -RegistrantContact_LastName $RegistrantContact_LastName -RegistrantContact_OrganizationName $RegistrantContact_OrganizationName `
      -RegistrantContact_PhoneNumber $RegistrantContact_PhoneNumber -RegistrantContact_ZipCode $RegistrantContact_ZipCode
  }
  catch {
    throw $_.Exception.Message
  }

  # Wait for the update to be successful
  $tempStatus = Get-R53DOperationDetail -OperationId $res
  while ($tempStatus.Status -ne "SUCCESSFUL") {
    Start-Sleep -Seconds 15
    $tempStatus = Get-R53DOperationDetail -OperationId $res
    Write-Host "Status registrant update: $($tempStatus.Status)"
  }
}

# Update the tech contact information for the domain
if ($All -or $Tech) {
  try {
    $res = Update-R53DDomainContact -Domain $DomainName -TechContact_AddressLine1 $TechContact_AddressLine1 `
      -TechContact_City $TechContact_City -TechContact_CountryCode $TechContact_CountryCode `
      -TechContact_Email $TechContact_Email -TechContact_FirstName $TechContact_FirstName `
      -TechContact_LastName $TechContact_LastName -TechContact_OrganizationName $TechContact_OrganizationName `
      -TechContact_PhoneNumber $TechContact_PhoneNumber -TechContact_ZipCode $TechContact_ZipCode
  }
  catch {
    throw $_.Exception.Message
  }

  # Wait for the update to be successful
  $tempStatus = Get-R53DOperationDetail -OperationId $res
  while ($tempStatus.Status -ne "SUCCESSFUL") {
    Start-Sleep -Seconds 15
    $tempStatus = Get-R53DOperationDetail -OperationId $res
    Write-Host "Status tech update: $($tempStatus.Status)"
  }
}

Stop-Transcript
#endregion script
