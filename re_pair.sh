# Usage: re_pair [device_name]
# Reconnects a Bluetooth device. If no argument is provided, "trackpad" will be used as default.
# Examples: re_pair keyboard - reconnects keyboard, re_pair - reconnects trackpad
# ref: https://www.reddit.com/r/MacOS/comments/vytkja/comment/jd7ox2f/
function re_pair() {
  local device_name=${1:-"TrackPad"}
  
  # making array for paired devices
  readarray -t devices < <(blueutil --paired | grep "$device_name")
  
  if [ ${#devices[@]} -eq 0 ]; then
    echo "No devices found matching '$device_name'"
    return 1
  fi
  
  if [ ${#devices[@]} -gt 1 ]; then
    echo "Multiple devices found matching '$device_name'. Using the first one:"
    for i in "${!devices[@]}"; do
      echo "[$i] ${devices[$i]}"
    done
  fi
  
  # use first device
  device="${devices[0]}"
  id=$(echo "$device" | grep -Eo '[a-z0-9]{2}(-[a-z0-9]{2}){5}')
  name=$(echo "$device" | grep -Eo 'name: "\S+"')
  
  echo "unpairing with BT device $id, $name"
  blueutil --unpair "$id"
  echo "unpaired, waiting a few seconds for trackpad to go to pairable state"
  sleep 3
  echo "pairing with BT device $id, $name"
  blueutil --pair "$id" "0000"
  echo "paired"
  blueutil --connect "$id"
  echo "connected"
}
