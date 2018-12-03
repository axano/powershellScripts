function sendAs($toEmail){
#SMTP Testing Tool 
#Matt Hansen 3/25/2015
#Edit lines 5,12,13,18,19,21,24,25 for full functionality.
#################################################################
$smtpServer = "smtp.scarlet.be"

 #Creating a Mail object
 $msg = new-object Net.Mail.MailMessage

 #Creating SMTP server object
 $smtp = new-object Net.Mail.SmtpClient($smtpServer)
 $smtp.Enablessl = $true
 $smtp.port = 25

 #Email structure 
 $msg.From = "events@contoso.com"
 


$msg.To.Add($toEmail) 
 
 $msg.subject = "SMTP Test"


 $msg.IsBodyHTML = $true
 #$msg.body = "This is an email testing email."+"<br /><br />"
 $msg.body = '
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1" name="viewport">
    <meta name="x-apple-disable-message-reformatting">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta content="telephone=no" name="format-detection">
    <title></title>
    <!--[if (mso 16)]>
    <style type="text/css">
    a {text-decoration: none;}
    </style>
    <![endif]-->
    <!--[if gte mso 9]><style>sup { font-size: 100% !important; }</style><![endif]-->
	<style>body{font-family:arial;}</style>
</head>

<body>
    <div class="es-wrapper-color">
        <!--[if gte mso 9]>
			<v:background xmlns:v="urn:schemas-microsoft-com:vml" fill="t">
				<v:fill type="tile" color="#f6f6f6"></v:fill>
			</v:background>
		<![endif]-->
        <table cellpadding="0" cellspacing="0" class="es-wrapper" width="100%">
            <tbody>
                <tr>
                    <td valign="top" class="esd-email-paddings">
                        <table cellpadding="0" cellspacing="0" class="es-header esd-header-popover" align="center">
                            <tbody>
                                <tr>
                                    <td class="esd-stripe" align="center">
                                        <table class="es-header-body" align="center" cellpadding="0" cellspacing="0" width="600">
                                            <tbody>
                                                <tr>
                                                    <td class="esd-structure es-p20b es-p20r es-p20l" align="left" style="background-position: left top; background-color: rgb(255, 255, 255);" bgcolor="#ffffff">
                                                        <table cellpadding="0" cellspacing="0" width="100%">
                                                            <tbody>
                                                                <tr>
                                                                    <td width="560" class="esd-container-frame" align="center" valign="top">
                                                                        <table cellpadding="0" cellspacing="0" width="100%">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" class="esd-block-image es-p10">
                                                                                        <a href="http://
                                                                                        ecobrain.be" target="_blank"><img src="https://www.gewekehospitality.com/" alt="" width="124" style="display: block;"> </a>
                                                                                    </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <table cellpadding="0" cellspacing="0" class="es-content" align="center">
                            <tbody>
                                <tr>
                                    <td class="esd-stripe" align="center">
                                        <table bgcolor="#ffffff" class="es-content-body" align="center" cellpadding="0" cellspacing="0" width="600">
                                            <tbody>
                                                <tr>
                                                    <td class="esd-structure es-p20" align="left" style="background-position: left top; background-color: rgb(255, 255, 255);" bgcolor="#ffffff">
                                                        <table cellpadding="0" cellspacing="0" width="100%">
                                                            <tbody>
                                                                <tr>
                                                                    <td width="560" class="esd-container-frame" align="center" valign="top">
                                                                        <table cellpadding="0" cellspacing="0" width="100%">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="left" class="esd-block-text es-p15b">
                                                                                        <h2 style="line-height: 100%; font-size: 18px;">Dear colleagues,<br><br>
                                                                                        On Friday the 21<span style="font-size:17px;">th</span> of December, there will be a team building event.<br>
                                                                                        Everyone&nbsp;needs&nbsp;to either confirm or deny their invitation by logging in with their personal account.<br>
																						You will receive more info after logging in.</h2>
                                                                                        </h2>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="esd-block-html"> <a href="https://ecobrain.be" style="text-decoration:none;text-align:center;display: inline-block;border-radius: 3px; background: rgb(0, 156, 222);width: 100%;height: 56px;color: rgb(255, 255, 255); font-size: 20px;line-height: 56px; font-weight: 700;padding: 0px;text-transform: uppercase;">Accept Invitation</a></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="left" class="esd-block-text">
                                                                                        <p><br></p>
                                                                                        <p><strong>PRACTICAL INFO</strong></p>
                                                                                        <p>Friday 21th we expect you to join our CSA. Be sure to arrive at 9:00 sharp. We will be ready to welcome you with your first briefing and T-shirt!</p>
                                                                                    </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <table cellpadding="0" cellspacing="0" class="es-content esd-footer-popover" align="center">
                            <tbody>
                                <tr>
                                    <td class="esd-stripe" align="center">
                                        <table class="es-content-body" align="center" cellpadding="0" cellspacing="0" width="600">
                                            <tbody>
                                                <tr>
                                                    <td class="esd-structure" align="left">
                                                        <table cellpadding="0" cellspacing="0" width="100%">
                                                            <tbody>
                                                                <tr>
                                                                    <td width="600" class="esd-container-frame" align="center" valign="top">
                                                                        <table cellpadding="0" cellspacing="0" width="100%">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" class="esd-block-spacer" height="15"> </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</body>

</html>
 '

 $ok=$true 
 Write-Host "SMTP Server:" $smtpserver "Port #:" $smtp.port "SSL Enabled?" $smtp.Enablessl
 echo $msg
 
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
$reader = [System.IO.File]::OpenText("C:\Users\axano1\Downloads\emails.txt")
while($null -ne ($line = $reader.ReadLine())) {
    sendAs $line
}
