rem https://www.windowscentral.com/how-prevent-windows-10-rebooting-after-installing-updates

cd %windir%\System32\Tasks\Microsoft\Windows\UpdateOrchestrator
rename Reboot Reboot.old
mkdir Reboot
icacls Reboot /deny "LOCAL SERVICE":FMWD
icacls Reboot /deny "SYSTEM":FMWD
icacls Reboot /deny %USERNAME%:FMWD
