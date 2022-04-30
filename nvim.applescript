on findReplace(t, toFind, toReplace)
	set {tid, text item delimiters} to {text item delimiters, toFind}
	set t to text items of t
	set text item delimiters to toReplace
	set t to t as text
	set text item delimiters to tid
	return t
end findReplace

on run {input, parameters}
	try
		set filename to POSIX path of input
	on error
		set filename to "~/Documents/nvim-" & (do shell script "date +%F") & "__" & (random number from 1000 to 9999) & ".md"
	end try

	tell application "iTerm"
		activate
		if (count of windows) = 0 then
			set t to (create window with default profile)
		else
			set t to current window
		end if
		tell t
			tell current session
				write text "nvim " & (my findReplace(filename, " ", "%20"))
			end tell
		end tell
	end tell
end run
