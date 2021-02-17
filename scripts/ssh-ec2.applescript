-- Modified version of:
-- https://github.com/vitorgalvao/custom-alfred-iterm-scripts

-- Set this property to true to always open in a new window
property open_in_new_window : false

-- Handlers
on new_window(profileName)
	-- Need to retry for situations when it's a new dynamic profile just created and iTerm2 hasn't picked up on it yet
	set i to 4
	repeat while i > 0
		try
			tell application "iTerm" to create window with profile "${PROFILE}"
			set i to 0
		on error
			delay 0.5
		end try
		set i to i - 1
	end repeat
end new_window

on new_tab(profileName)
	-- Need to retry for situations when it's a new dynamic profile just created and iTerm2 hasn't picked up on it yet
	set i to 4
	repeat while i > 0
		try
			tell application "iTerm" to tell the first window to create tab with profile "${PROFILE}"
			set i to 0
		on error
			delay 0.5
		end try
		set i to i - 1
	end repeat
end new_tab

on call_forward()
	tell application "iTerm" to activate
end call_forward

on is_running()
	application "iTerm" is running
end is_running

on has_windows()
	if not is_running() then return false
	if windows of application "iTerm" is {} then return false
	true
end has_windows

on send_text(custom_text)
	tell application "iTerm" to tell the first window to tell current session to write text custom_text
end send_text

-- Main
on execute(cmd, profileName)
	set appLaunched to false

	if has_windows() then
		if open_in_new_window then
			new_window(profileName)
		else
			new_tab(profileName)
		end if
	else
		-- If iTerm is not running and we tell it to create a new window, we get two
		-- One from opening the application, and the other from the command
		if is_running() then
			new_window(profileName)
		else
			call_forward()
			set appLaunched to true
		end if
	end if

	-- Make sure a window exists before we continue, or the write may fail
	repeat until has_windows()
		delay 0.01
	end repeat

	-- if iTerm2 wasn't already running and is a first launch scenario
	if appLaunched then
		-- Bit of a hack but going with the inital opened tab on app launch won't execute command or get profile right
		tell application "iTerm" to tell the first window to tell current session to close
		repeat until not has_windows()
			delay 0.01
		end repeat
		new_window(profileName)
		repeat until has_windows()
			delay 0.01
		end repeat
	else
		#new_tab(profileName)
	end if

	send_text("clear")
	send_text(cmd)
	call_forward()
end execute