Function New-PatchCollection {
<#
.Synopsis
   Create SCCM Collections for patching along with the proper query statement per package
.DESCRIPTION
   Utilizes the ConfigurationManager Powershell Module commands to:
    UPDATE INFO

    The QueryExpression is in the Windows Query Language (WQL) format.
.EXAMPLE
    UPDATE INFO
   New-WWUDeviceCollection -CollectionName "There was a description here I removed"
.EXAMPLE
    UPDATE INFO
   New-WWUDeviceCollection -CollectionName "There was a description here I removed"
#>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   HelpMessage="Name of the product, Adobe Flash Player, 7-Zip")]
        [String]$Name,

        [Parameter(Mandatory = $true,
                   HelpMessage="32bit, 64bit")]
        [String]$Architecture,

        [Parameter(Mandatory = $true,
                   HelpMessage="7.4.2, 27.0.0.159, 16.04")]
        [String]$Version,

        [Parameter(Mandatory = $false,
                   HelpMessage="NPAPI, PPAPI, ActiveX")]
        [String]$Type,

        [Parameter(Mandatory = $false,
                   HelpMessage="Name of production collection")]
        [String]$ProdLimiting = "Software Patching - _Opt In For Software Updates", #Default

        [Parameter(Mandatory = $false,
                   HelpMessage="Name of test collection")]
        [String]$TestLimiting = "Software Patching - _Phase 1 - Test Group", #Default

        [Parameter(Mandatory = $false,
                   HelpMessage="Destination collection path")]
        [String]$CollectionPath = "WWU:\DeviceCollection\Deployments\Software Updates" #Default

    )

    Begin {}

    Process {
        
        # Default Schedule for collection updating
        $Schedule = New-CMSchedule -Start "03/13/2017 4:00 PM" -RecurInterval Days -RecurCount 1
        
        # Default path to destination 
        $NewTestCollection = "Test - Software Patching - $Name$Type $Version - $Architecture"
        $NewProdCollection = "Software Patching - $Name$Type $Version - $Architecture"

        # Create new patching collections, test/production
        New-CMDeviceCollection -Name $NewTestCollection -LimitingCollectionName $TestLimiting -RefreshSchedule $Schedule -RefreshType Periodic
        New-CMDeviceCollection -Name $NewProdCollection -LimitingCollectionName $ProdLimiting -RefreshSchedule $Schedule -RefreshType Periodic
        
        # Get newly created object IDs            
        $TestCollection = Get-CMDeviceCollection -Name $NewTestCollection
        $ProductionCollection = Get-CMDeviceCollection -Name $NewProdCollection
                
        # Move collections to destination
        Move-CMObject -InputObject $TestCollection -FolderPath $CollectionPath
        Move-CMObject -InputObject $ProductionCollection -FolderPath $CollectionPath
        
        switch ($Architecture) 
        { 
            "32bit" {
                Add-CMDeviceCollectionQueryMembershipRule -CollectionName $NewTestCollection -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like `"$Name%`" and SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like `"%$Type`" and SMS_G_System_ADD_REMOVE_PROGRAMS.Version < `"$Version`"" -RuleName "$Name$Type $Architecture < Latest Approved $Version"
                Add-CMDeviceCollectionQueryMembershipRule -CollectionName $NewProdCollection -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like `"$Name%`" and SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like `"%$Type`" and SMS_G_System_ADD_REMOVE_PROGRAMS.Version < `"$Version`"" -RuleName "$Name$Type $Architecture < Latest Approved $Version"
            }
            "64bit"{
                Add-CMDeviceCollectionQueryMembershipRule -CollectionName $NewTestCollection -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS_64 on SMS_G_System_ADD_REMOVE_PROGRAMS_64.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName like `"$Name%`" and SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName like `"%$Type`" and SMS_G_System_ADD_REMOVE_PROGRAMS_64.Version < `"$Version`"" -RuleName "$Name$Type $Architecture < Latest Approved $Version"
                Add-CMDeviceCollectionQueryMembershipRule -CollectionName $NewProdCollection -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS_64 on SMS_G_System_ADD_REMOVE_PROGRAMS_64.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName like `"$Name%`" and SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName like `"%$Type`" and SMS_G_System_ADD_REMOVE_PROGRAMS_64.Version < `"$Version`"" -RuleName "$Name$Type $Architecture < Latest Approved $Version"
            }
        }
    }

    End {}

}