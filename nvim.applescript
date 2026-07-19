use scripting additions

on run {input, parameters}
	try
		set filename to POSIX path of input
	on error
		set theDate to current date
		set y to (year of theDate) as string
		set m to text -2 thru -1 of ("0" & ((month of theDate) as integer))
		set d to text -2 thru -1 of ("0" & (day of theDate))
		set randNum to (random number from 1000 to 9999) as string
		set filename to (POSIX path of (path to documents folder)) & "nvim-" & y & "-" & m & "-" & d & "__" & randNum & ".md"
	end try
	
	tell application "Ghostty"
		activate
		set cfg to new surface configuration
		set command of cfg to "/usr/local/bin/nvim " & quoted form of filename
		if (count of windows) > 0 then
			new tab in (front window) with configuration cfg
		else
			new window with configuration cfg
		end if
	end tell
end run
