# Usage: re_pair [device_name]
# Reconnects a Bluetooth device. If no argument is provided, "trackpad" will be used as default.
# Examples: re_pair keyboard - reconnects keyboard, re_pair - reconnects trackpad
# modified from ref: https://www.reddit.com/r/MacOS/comments/vytkja/comment/jd7ox2f/
#!/bin/bash

function re_pair() {
  local device_name=${1:-"TrackPad"} # Default device name is "TrackPad" if no argument is provided
  local devices=() # Initialize an array to store the list of devices
  local device_info # Variable to store the selected device's information
  local id # Variable to store the device ID
  local name # Variable to store the device name
  local line # Temporary variable for reading lines

  echo "Searching for paired devices containing '$device_name'..."

  # Read the output of 'blueutil --paired | grep' line by line into the 'devices' array
  # This method is more compatible with older versions of Bash and also works in zsh
  while IFS= read -r line; do
    # Check if the line is not empty before adding
    if [[ -n "$line" ]]; then
      devices+=("$line")
    fi
  done < <(blueutil --paired | grep "$device_name") # Process substitution <(...) requires Bash or Zsh

  # If no devices were found
  if [ ${#devices[@]} -eq 0 ]; then
    echo "Error: No devices found matching '$device_name'"
    return 1 # Return error code 1 and exit the function
  fi

  # If multiple devices were found
  if [ ${#devices[@]} -gt 1 ]; then
    echo "Warning: Multiple devices found matching '$device_name'. Using the first one:"
    # Print the list of found devices with numbers
    for i in "${!devices[@]}"; do
      echo "[$i] ${devices[$i]}"
    done
  fi

  # Use the information from the first device in the array
  device_info="${devices[0]}"
  echo "Selected device info: $device_info"

  # Extract the device ID (MAC address format: xx-xx-xx-xx-xx-xx)
  # grep -Eo options: Extract Only the matching parts (o) using Extended regular expressions (E)
  id=$(echo "$device_info" | grep -Eo '[a-f0-9]{2}(-[a-f0-9]{2}){5}')

  # Extract the device name (from the 'name: "Name"' format)
  # Use sed command to remove 'name: "' and the trailing quote
  name=$(echo "$device_info" | grep -Eo 'name: "[^"]+"' | sed 's/name: "//; s/"$//')

  # If ID extraction failed, print an error message and exit
  if [[ -z "$id" ]]; then
    echo "Error: Could not extract device ID from: $device_info"
    return 1
  fi

  echo "Attempting to re-pair device:"
  echo "  ID: $id"
  echo "  Name: $name"

  # Unpair the existing connection
  echo "Unpairing..."
  if ! blueutil --unpair "$id"; then
    echo "Warning: Failed to unpair device $id. Attempting to continue..."
    # Continue even if unpairing fails (it might already be unpaired)
  fi

  echo "Waiting for 3 seconds..."
  sleep 3 # Pause execution to allow the device to become pairable

  # Attempt to pair again (using PIN code "0000")
  echo "Pairing..."
  # The PIN code might not be necessary for all devices.
  if ! blueutil --pair "$id" "0000"; then
    echo "Warning: Failed to pair with device $id. Attempting to connect anyway..."
     # Try to connect even if pairing fails
  fi

  # Attempt to connect to the device
  echo "Connecting..."
  if ! blueutil --connect "$id"; then
    echo "Error: Failed to connect to device $id."
    return 1 # Return error code 1 if connection fails
  fi

  echo "Successfully re-paired and connected to device ID: $id (Name: $name)"
  return 0 # Return success code 0
}

# Call the re_pair function when the script is executed directly.
# Example: ./re-pair.sh "My Trackpad"
# If the script is sourced (e.g., `source ./re-pair.sh`),
# you can call the function directly in the terminal like `re_pair "My Trackpad"`.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  re_pair "$@"
fi
