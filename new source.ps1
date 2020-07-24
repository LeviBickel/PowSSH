###
#   Creates a new source in the Windows Event Log to enable logging from PowSSH.
#   This must be run as an administrator.
###
New-EventLog -LogName "Application" -Source "PowerShell SSH"