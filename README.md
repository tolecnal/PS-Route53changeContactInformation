# PS-Route53changeContactInformation
PS-Route53changeContactInformation

## Introduction

This PowerShell script enables you to change the contact information of a hosted zone in AWS Route 53.

It relies on the following AWS modules:
- AWS.Tools.Common
- AWS.Tools.Route53
- AWS.Tools.Route53Domains

You can change all contact type information or just a specific one. Supports the following types:
- Admin
- Registrant
- Tech

## Usage

The relevant contact information is stored in the configuration file `route53changeContactInformation.conf`.

Edit this file to reflect the values you want the script to use. Then run the script to update the information.

## Parameters

- `DomainName`
  - Type: string
  - Description: The domain name to update, i.e. example.com
- `AWSProfile`
  - Type: string 
  - Description: the AWS profile to use, as defined in ~/.aws/credentials
- `Wait`
  - Type: boolean
  - Description: wait for updates to finish, i.e. output to stdout?
- `All`
  - Type: boolean
  - Description: update all contact information fields, i.e: admin, registrant and
- `Admin`
  - Type: boolean
  - Description: update admin contact information
- `Registrant`
  - Type: boolean
  - Description: update registrant contact information
- `Tech`
  - Type: boolean
  - Description: update tech contact information?
- `WaitInterval`
  - Type: integer
  - Default: 30 seconds
  - Description: the interval used to check for updates from the API, in seconds

### Update all contact types

Run: `.\route53changeContactInfo.ps1 -All $true -Wait $true -DomainName example.com`

### Update admin contact

Run: `.\route53changeContactInfo.ps1 -Admin $true -Wait $true -DomainName example.com`

### Update registrant contact

Run: `.\route53changeContactInfo.ps1 -Registrant $true -Wait $true -DomainName example.com`

### Update tech contact

Run: `.\route53changeContactInfo.ps1 -Admin $true -Wait $true -DomainName example.com`

## Caveats

Some changes are not allowed, due to the type of domain being changed. For instance, the TLD `SE` requires formal paperwork to change the organization.

While other changes might require approval of transfer of ownership, in most cases this approval request is sent by email, and has to be approved both by the existing owner and the new owner.

The script makes little effort to catch these cases in an effective method, expect to do some manual labour :) 
