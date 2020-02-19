# PSScripts
Contains many super useful powershell scripts created by me to aid in work
<ul>
<li><b>findByIP.ps1 -</b> </li>This script takes an IP address as input, and then searches 
      all your subscriptions for the Azure Component to which this IP address belongs to. 
      This was created since this functionality is not inbuilt in Azure Portal right now, 
      and as part of a project I needed to trace a request using IP to which components it was going to.
      <p>
      <b><u>Input Parameters:</u></b>
      <ol>
      <li><b>subID (optional) - </b>Provide the Subscription ID if you want the search to be limited to a particular Subscription.</li>
      <li><b>tenantID (optional) - </b>Provide the AAD tenant ID for the tenant who has access to the subscriptions you want to search.</li>
      <li><b>IP Address - </b>After the script is run, you need to specify the IP address.</li>
      </ol>
      <p>
      Currently, the script supports searching the following Azure Components -
      <ol type="a">
      <li>Load Balancer</li>
      <li>Azure Traffic Manager</li>
      <li>Virtual Machines (nic)</li>
      </ol>
      <p>
      Will add additional Azure Network Components to search through in near future. <br>Also, will add option to select what type of Azure Resource you want to search specifically, basically giving you more control over the search.
 </ul>
      <h2> Issues </h2>
      <p>
      <ol>
      <li>Since the script is not digitally signed, you will need to execute this command in Powershell (as admin) in order to bypass digital sign verification:<br>
            <b>Set-ExecutionPolicy Unrestricted</b></li>
      <li>Your version of AzureRM module might be old, if so you might get this error: <br><i>"Parameter set cannot be resolved using the specified named parameters."</i><br>
            To resolve this error, you need to run this command in powershell as admin:<br><b>Update-Module -Name AzureRM</b></li>
            </ol>
      <h2>Changelog</h2>
      <ol>
      <li>Added option to search a particular Subscription</li>
      </ol>
