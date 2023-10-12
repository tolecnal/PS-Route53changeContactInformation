#Requires -Version 4
<#
    .Synopsis
    This script is used to change contact information for registered domains in AWS Route 53
    .DESCRIPTION
    This script is used to change contact information for registered domains in AWS Route 53
    .EXAMPLE
    .\route53changeContactInfo.ps1 -All $true -Wait $true -DomainName example.com
    .EXAMPLE
    .\route53changeContactInfo.ps1 -Admin $true -Wait $false -DomainName example.com
    .PARAMETER DomainName
    The domain name to update
    .PARAMETER AWSProfile
    The AWS profile to use, as per ~/.aws/credentials
    .PARAMETER Wait
    Wait for updates to finish, i.e. output to stdout?
    .PARAMETER All
    Update all contact information? I.e: admin, registrant and tech
    .PARAMETER Admin
    Update admin contact information?
    .PARAMETER Registrant
    Update registrant contact information?
    .PARAMETER Tech
    Update tech contact information?
    .PARAMETER WaitInterval
    The interval used to check for updates from the API, in seconds
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
  [Parameter(Mandatory = $true, HelpMessage = "Domain name to update, e.g. example.com")]
  [string]$DomainName
  ,
  [Parameter(Mandatory = $true, HelpMessage = "AWS Profile to use, as per ~/.aws/credentials")]
  [string]$AWSProfile
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Wait for updates to finish, i.e. output to stdout?")]
  [boolean]$Wait = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update all contact information? I.e: admin, registrant and tech")]
  [boolean]$All = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update admin contact information?")]
  [boolean]$Admin = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update registrant contact information?")]
  [boolean]$Registrant = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "Update tech contact information?")]
  [boolean]$Tech = $false
  ,
  [Parameter(Mandatory = $false, HelpMessage = "The interval used to check for updates from the API, in seconds")]
  [int]$WaitInterval = 30
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

if ($All -and -not $Wait) {
  Write-Warning "Not waiting is not supported when updating all contact information"
  Write-Warning "This due to the Route 53 API being rate limited for update requests"
  Exit 1
}

# Update the admin contact information for the domain
if ($All -or $Admin) {
  Write-Output "Updating admin contact information for domain $DomainName"
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
  $waitSequence = 1
  if ($Wait) {
    $tempStatus = Get-R53DOperationDetail -OperationId $res
    while ($tempStatus.Status -ne "SUCCESSFUL") {
      Start-Sleep -Seconds $WaitInterval
      $tempStatus = Get-R53DOperationDetail -OperationId $res
      Write-Host "Status admin update: $($tempStatus.Status) - Sequence: $waitSequence"
      $waitSequence++
    }
  }
}

# Update the registrant contact information for the domain
if ($All -or $Registrant) {
  Write-Output "Updating registrant contact information for domain $DomainName"
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
  $waitSequence = 1
  if ($Wait) {
    $tempStatus = Get-R53DOperationDetail -OperationId $res
    while ($tempStatus.Status -ne "SUCCESSFUL") {
      Start-Sleep -Seconds $WaitInterval
      $tempStatus = Get-R53DOperationDetail -OperationId $res
      Write-Host "Status admin update: $($tempStatus.Status) - Sequence: $waitSequence"
      $waitSequence++
    }
  }
}

# Update the tech contact information for the domain
if ($All -or $Tech) {
  Write-Output "Updating tech contact information for domain $DomainName"
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
  $waitSequence = 1
  if ($Wait) {
    $tempStatus = Get-R53DOperationDetail -OperationId $res
    while ($tempStatus.Status -ne "SUCCESSFUL") {
      Start-Sleep -Seconds $WaitInterval
      $tempStatus = Get-R53DOperationDetail -OperationId $res
      Write-Host "Status admin update: $($tempStatus.Status) - Sequence: $waitSequence"
      $waitSequence++
    }
  }
}

Stop-Transcript
#endregion script
