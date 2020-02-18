param(

    [string]$tenantID="",
    [string]$subID=""

    ) 

if (Get-Module -ListAvailable -Name AzureRM) {
    Write-Host "Module exists"
} else {
    Install-Module AzureRM
}

Import-Module AzureRM

if ($tenantID -eq "") {
    login-azurermaccount 
    $subs = Get-AzureRmSubscription 
} else {
    login-azurermaccount -tenantid $tenantID 
    $subs = Get-AzureRmSubscription -TenantId $tenantID
}


$ip = Read-Host -Prompt 'Input the IP address you seek to find'

function searchLB{
    param($sub)

    #1 Try to find in Load Balancers

    Write-Host "Searching for Load Balancers..."

    $ress = Get-AzureRmResource -ResourceType Microsoft.Network/loadBalancers
    $total = $ress.Count
    $i = 0
    foreach ($res in $ress)
    {
        Write-Progress -Activity "Searching for LBs..." -PercentComplete (100*($i/$total)) -status "Scanned: $i of $total"
        $lb = Get-AzureRmLoadBalancer -ResourceGroupName $res.ResourceGroupName -Name $res.Name
        if($lb.FrontendIpConfigurations.PrivateIpAddress -eq $ip){
            Write-Host "Gotcha! " $ip " belongs to the Load Balancer "$lb.Name " in Subscription: " $sub
            exit
        }
        $i++;
    }
}

function searchVM{
    param($sub)

    #2 Try to find in Network Interfaces

    Write-Host "Searching for VM Network Interfaces..."

    $ress = Get-AzureRmResource -ResourceType Microsoft.Network/networkInterfaces
    $total = $ress.Count
    $i = 0
    foreach ($res in $ress)
    {
        Write-Progress -Activity "Searching for VMs..." -PercentComplete (100*($i/$total)) -status "Scanned: $i of $total"
        $nic = Get-AzureRmNetworkInterface -Name $res.Name -ResourceGroupName $res.ResourceGroupName
        $nicIPConfigs = $nic.IpConfigurations
        foreach ($nicIPConfig in $nicIPConfigs){
            if($nicIPConfig.PrivateIpAddress -eq $ip){
                Write-Host "Gotcha! " $ip " belongs to the VM nic " $nic.Name " in Subscription: " $sub
                exit
            }
        }
        $i++;
    } 
}

function searchATM{
    param($sub)

    #3 In traffic Manager Profiles

    Write-Host "Searching for Traffic Manager Profiles..."

    $ress = Get-AzureRmResource -ResourceType Microsoft.Network/trafficmanagerprofiles
    $total = $ress.Count
    $i = 0
    foreach ($res in $ress)
    {
        Write-Progress -Activity "Searching for ATMs..." -PercentComplete (100*($i/$total)) -status "Scanned: $i of $total"
        $atm = Get-AzureRmTrafficManagerProfile -Name $res.Name -ResourceGroupName $res.ResourceGroupName
        foreach ($endpoint in $atm.Endpoints){
            $atmEndpoint = Get-AzureRmTrafficManagerEndpoint -TrafficManagerEndpoint $endpoint
            if($atmEndpoint.Target -eq $ip){
                Write-Host "Gotcha! " $ip " belongs to the ATM " $atm.Name ":" $atmEndpoint.Name " in Subscription: " $sub
                exit
            }
        }
        $i++;
    }  
}

function searchIP{
    param($sub)

    #Seach for that IP in current selected Subscription

    searchLB -sub $sub
    searchATM -sub $sub
    searchVM -sub $sub
}

#Search for the IP

if($subID -eq ""){
    Write-Host "Total Subscriptions: " $subs.Count
    $i = 0
    foreach($sub in $subs){
        $i++;
        Write-Host "Subscription #$i of $($subs.count)"
        try
        {
            Write-Host "Searching in Subscription: " $sub
            Select-AzureRmSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue | Out-null
            searchIP -sub $sub
        }
        catch
        {
            Write-Host $error[0]
        }
    }
}else{
    Write-Host "Only one Subscription selected: " $subID
    Select-AzureRmSubscription -SubscriptionId $subID -ErrorAction Continue | Out-null
    searchIP -sub $subID
}