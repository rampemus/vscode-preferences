on findReplace(t, toFind, toReplace)
    set {tid, text item delimiters} to {text item delimiters, toFind}
    set t to text items of t
    set text item delimiters to toReplace
    set t to t as text
    set text item delimiters to tid
    return t
end findReplace

on run {input, parameters}
	-- If run without input, open random file at $HOME
	try
		set filename to POSIX path of input
	on error
		set filename to "~/Documents/nvim-" & (do shell script "date +%F") & "__" & (random number from 1000 to 9999) & ".md"
	end try

	tell application "Terminal"
		if not (exists window 1) then
			reopen
		else
			set newTab to do script -- create a new window with no initial command
		end if
		activate
		do script "nvim " & (my findReplace(filename, " ", "%20")) in window 1
	end tell

	return input
end run
