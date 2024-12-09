#!/bin/bash
echo "Run script with bash!"

while getopts "n:" arg; do
  case $arg in
    n) spokes=$OPTARG;;
  esac
done

if [[ -z $spokes ]]; then
  echo "Use -n flag to define the number of spokes"
  exit 1
fi

project="." # Path to project folder
s1="/spoke"
h1="/hub"

for i in $(seq 1 $spokes); do

    new_spoke=$(($i + 3))
    index=$(($i%3+1))
    spoke_path="${project}${s1}${new_spoke}/"
    hub_path="${project}${h1}${index}/hiplib/config/config.py"

    sudo rm -rf "${project}${s1}${new_spoke}"

    # Connect a third of the spokes to hub1, a third to hub2 and a third to hub3
    sudo cp -r "${project}${s1}${index}" "${project}${s1}${new_spoke}"

    # Generate key for spoke i+3
    sudo sh "${project}${s1}${new_spoke}/hiplib/tools/genkey.sh" "gen RSA 1024"

    # Run python3 script to gen HIT for i+3
    if cd "$spoke_path"; then
        python_output=$(sudo python3 "hiplib/tools/genhit.py")
        echo "HIT from genhit.py for spoke${new_spoke}: $python_output"
        cd - >/dev/null  # Return to the previous directory and suppress output
    else
        echo "Failed to change directory to $spoke_path. Skipping spoke${new_spoke}."
        continue
    fi

    # Update hub config
    config_path="${project}${h1}${index}/hiplib/config/"
    config=$(<"${config_path}/config.py")
    # Add spoke to list #DOES NOT WORK!
    updated_config=$(echo "$config" | sed -E "s/(spokes\": \{[^}]*\})+/\1\n\t${python_output}: INITIAL_STATE/")
    echo "$updated_config"
    echo "$updated_config" | sudo tee "$config_path/config.py" > /dev/null

    # Update spoke config
    config_path="${project}${s1}${new_spoke}/hiplib/config/"
    config=$(<"${config_path}/config.py")
    spokenr=$(($new_spoke + 3))
    # Update the l2interface
    updated_config=$(echo "$config" | sed -E "s/(l2interface\": \")[^\"]+/\1sp${new_spoke}-eth1/")
    # Update IP
    updated_config=$(echo "$updated_config" | sed -E "s/(source_ip\": \")[^\"]+/\1192.168.1.${spokenr}/")
    echo "$updated_config" | sudo tee "$config_path/config.py" > /dev/null

    echo "Updated configuration for spoke${new_spoke}"
    echo "Copied spoke${new_spoke}"
done 

echo "Finished copying and creating $spokes spokes"
