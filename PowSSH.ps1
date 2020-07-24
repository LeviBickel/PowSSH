###
#   Created by: Levi Bickel on July 15th 2020
#   Using PowerShell and the OpenSSH function in Windows 10 to launch a SSH session to nodes provided below while also logging the 
#   connection attempt to the Windows Event Log.
###

@'
{
    "Nodes" : [
      {
         "Name": "Test-Node-1",
         "IP": "192.168.0.1"
      },
      {
         "Name": "Test-Node-2",
         "IP": "192.168.0.2"
      }
    ]
}
'@ | Set-Content json.json 

Add-Type -assembly System.Windows.Forms

$main_form = New-Object System.Windows.Forms.Form

###
#       Adding Controls to the Form
###

#Adds a Label to the form.
$Label = New-Object System.Windows.Forms.Label
$Label.Text= "Host"
$Label.Location = New-Object System.Drawing.Point(0,10)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

#Adding a Dropbox to the form
### This Combo box populates with Node Names 
$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 300
$json = (Get-Content "json.json" -Raw) | ConvertFrom-Json
Foreach ($Node in $json.Nodes){
    [void]$ComboBox.Items.Add($Node.Name);
}
$ComboBox.Sorted = $true
$ComboBox.Location  = New-Object System.Drawing.Point(60,10)
$main_form.Controls.Add($ComboBox)

#Adding another label
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Username"
$Label2.Location  = New-Object System.Drawing.Point(0,40)
$Label2.AutoSize = $true
$main_form.Controls.Add($Label2)
#Adding Username field
$TextUser = New-Object System.Windows.Forms.Textbox
$TextUser.Text = ""
$TextUser.Location  = New-Object System.Drawing.Point(60,40)
$TextUser.Size = New-Object System.Drawing.Size(260,20)
$main_form.Controls.Add($TextUser)
#Adding a button to the form
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(400,10)
$Button.Size = New-Object System.Drawing.Size(120,23)
$Button.Text = "Connect"
$main_form.Controls.Add($Button)

function Connect($user, $IP, $runUser){
    $command = "$user@$IP"
    #Write-Host $IP
    #Write-Host "Command: $command"
    #Start-Process powershell.exe -argument "-noexit -nologo -noprofile -command ssh $command"
    Start-Process powershell.exe -ArgumentList "-noexit -nologo -noprofile -command Invoke-Command -scriptblock{ssh $command; Write-EventLog -LogName 'Application' -Source 'PowerShell SSH' -EventId 3001 -EntryType Information -Message 'Connection closed to $selected by $runUser using credential $user' -Category 1 -RawData 10,20; [Environment]::Exit(1) }"
    Remove-Item json.json
}



#Adding functionality to the button
$Button.Add_Click({
    $selected = $ComboBox.Text
    #Write-Host $selected
    $user = $TextUser.Text
    $runUser = $env:USERNAME
    Write-EventLog -LogName "Application" -Source "PowerShell SSH" -EventId 3001 -EntryType Information -Message "Connection made to $selected by $runUser using credential $user" -Category 1 -RawData 10,20 
    #Invoke-Item C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
    if($selected -ne ""){
        if($user -ne ""){
            if($selected -like '*.*'){
                $IP = $selected
                Connect $user $IP $runUser
                [Environment]::Exit(1)
            }
            else{
                Foreach ($Node in $json.Nodes){
                    #$ComboBox.Items.Add($Node.Name);
                    if($selected -eq $Node.Name){
                        $IP = $Node.IP;
                        Connect $user $IP $runUser
                        [Environment]::Exit(1)
                    }
                }
            }
        }
        else{Write-Host "Please enter a username"}
    }
    else{ Write-Host "Please enter a host"}
    
})

###
#       Creating the Form itself.
###

$main_form.Text='PowSSH'
$main_form.Width=600
$main_form.Height=100
$main_form.AutoSize=$true
$main_form.ShowDialog()


