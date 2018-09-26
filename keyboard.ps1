[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.SendKeys]::SendWait("^{ESC}")
[System.Windows.Forms.SendKeys]::SendWait("{c}")
[System.Windows.Forms.SendKeys]::SendWait("{m}")
[System.Windows.Forms.SendKeys]::SendWait("{d}")
sleep 1
[System.Windows.Forms.SendKeys]::SendWait("+{f10}")
[System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
sleep 2
[System.Windows.Forms.SendKeys]::SendWait("{LEFT}")
sleep 2
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
