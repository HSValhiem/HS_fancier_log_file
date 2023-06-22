#1. The script uses the Get-Content cmdlet to read the contents of the log file specified by $filePath. 
	#The -Wait parameter ensures that the script continues to monitor the file for changes and display any new content that is appended to it.

#2. The output from Get-Content is piped (|) to the Where-Object cmdlet, which filters the lines based on two conditions:
	# $_ -match '\S' matches lines that contain non-whitespace characters, ensuring empty lines are excluded.
	# $_ -notmatch 'Loaded localization file' excludes lines that contain the specific string "Loaded localization file" from being displayed.

#3. The filtered lines are then piped to the ForEach-Object cmdlet for further processing.
	# Inside the ForEach-Object block, each line is assigned to the variable $line.

#4. The script sets the default foreground color ($FGcolor) to "White" and the background color ($BGcolor) to "Black".
	#The script uses a series of if and elseif statements to check the content of each line 
	#and assign appropriate colors to $FGcolor and $BGcolor based on specific keywords. 
	#For example, if the line contains the word "Error," the foreground color is set to "Red."

#5. The script uses regular expressions and string manipulation to remove timestamps and re-add them uniformly to each line:
	# The line is first checked for a timestamp using the regular expression matching "MM/dd/yyyy HH:mm:ss: "
	# If a timestamp is found, it is removed from the line using the -replace operator.
	# A new timestamp is generated using Get-Date and formatted as "MM/dd/yyyy hh:mm:ss.ffff tt".
	# The timestamp is then prepended to the line using string concatenation.

#6. Finally, the colored and timestamped line is output using the Write-Host cmdlet, 
	#with the foreground and background colors specified by $FGcolor and $BGcolor, respectively.


# Specify the path of the log file
$filePath = ".\LogOutput.log"

# Continuously display the log file with color
Get-Content $filePath -Wait | Where-Object { $_ -match '\S' -and $_ -notmatch 'Loaded localization file' } | ForEach-Object {
    $line = $_

    # Set default color to white on black
    $FGcolor = "White"
	$BGcolor = "Black"

	# Match lines with specific text and set their color
	if ($line -match "Error" -or $line -match "Failed") {
		$FGcolor = "Red"
	}
    elseif ($line -match "AzuAntiCheat") {
        $FGcolor = "Black"
		$BGcolor = "Red"
    }
   	elseif ($line -match "Warning") {
        $FGcolor = "Yellow"
    }
    elseif ($line -match "Received 1 configs") {
		$FGcolor = "Yellow"
        $BGcolor = "Blue"
    }
    elseif ($line -match "Steam game server initialized" -or $line -match "Game server connected") {
        $FGcolor = "Blue"
    }
    elseif ($line -match "Message") {
        $FGcolor = "Cyan"
    }
    elseif ($line -match "Unity Log") {
        $FGcolor = "Magenta"
    }
    elseif ($line -match "BepInEx") {
        $FGcolor = "Green"
    }

    # Check if mod name or other info exists, to include in the output later. 
	$pattern = "(?<=:)[^\]]+(?=\])"
	$name = [regex]::Match($line, $pattern).Value.TrimStart()

	# Remove everything between the first set of brackets. 
    $line = $line -replace '\[.*?\] ', ''
	
	# Create a regular expression that matches timestamps "MM/dd/yyyy HH:mm:ss: "
	$regex = '^([0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}):\s'
	
	# Check if a timestamp already exists and remove it.
	if ($line -match $regex) {
		# Remove the timestamp from the line
		$line = $line -replace $regex, ''
	}
	
	# Remove leading spaces from the line that are sometimes left after removing the timestamp
    $line = $line.TrimStart()
	
	# Add timestamps and mod names (or other info) back in, to maintain consistency in the log.
	$timestamp = Get-Date -Format 'hh:mm:ss.ffff tt'
	if ($name -ne $null -and $name -ne '') {
		$line = "[$timestamp]: ($name) $line"
	}
	else {
		$line = "[$timestamp]: $line"
	}
    # Write the colored line
    Write-Host $line -ForegroundColor $FGcolor -BackgroundColor $BGcolor 
}
