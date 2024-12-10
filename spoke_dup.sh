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
    if cd "${spoke_path}hiplib/"; then
        openssl genrsa -out private.pem 1024
        openssl rsa -in private.pem -outform PEM -pubout -out public.pem
        #openssl rsa -text -in private.pem
        mv public.pem private.pem ./config/
        cd - >/dev/null
    else
        echo "Failed to change directory to $spoke_path. Skipping spoke${new_spoke}."
        continue
    fi

    # Run python3 script to gen HIT for i+3
    if cd "${spoke_path}"; then
        python_output=$(sudo python3 "hiplib/tools/genhit.py")
        echo "HIT from genhit.py for spoke${new_spoke}: $python_output"
        cd - >/dev/null  # Return to the previous directory and suppress output
    else
        echo "Failed to change directory to $spoke_path. Skipping spoke${new_spoke}."
        continue
    fi
    # Update hub config
    # config_path="${project}${h1}${index}/hiplib/config/"
    # config=$(<"${config_path}/config.py")
    # # Add spoke to list #DOES NOT WORK!
    # updated_config=$(echo "$config" | sed -E "s/(spokes\": \{[^}]*\})+/\1\n\t${python_output}: INITIAL_STATE/")
    # echo "$updated_config"
    # echo "$updated_config" | sudo tee "$config_path/config.py" > /dev/null

    # Update spoke config
    config_path="${project}${s1}${new_spoke}/hiplib/config/"
    config=$(<"${config_path}/config.py")
    spokenr=$(($new_spoke + 3))
    # Update the l2interface
    updated_config=$(echo "$config" | sed -E "s/(l2interface\": \")[^\"]+/\1sp${new_spoke}-eth1/")
    # Update IP
    updated_config=$(echo "$updated_config" | sed -E "s/(source_ip\": \")[^\"]+/\1192.168.1.${spokenr}/")
    echo "$updated_config" | sudo tee "$config_path/config.py" > /dev/null

    #Update mesh file
    config=$(<"${config_path}/mesh")
    updated_mesh=$(echo "$config" | sed -E "s/^[^ ]* /${python_output} /")
    echo "$updated_mesh" | sudo tee "$config_path/mesh" > /dev/null

    #Update hosts file
    config=$(<"${config_path}/hosts")
    updated_hosts=$(echo "$config" | sed "2s/.*/${python_output} 192.168.1.${spokenr}/")
    echo "$updated_hosts" | sudo tee "$config_path/hosts" > /dev/null

    #NO NEED: Update mesh and hosts in Hub for spoke , clear the old added before doing this

    #Create mininet (prb modify setup script)
    echo "Updated configuration for spoke${new_spoke}"
done 

#Update Rules , make 1 file for everyone, could prb use mesh files
#Take initial rules file from hub and paste here / create template file
# rules=""
# spokes="${spokes:-0}" # Default to 0 if not set
# total_spokes=$((3 + spokes))

# for i in $(seq 1 $total_spokes); do
#   if [ "$i" -lt 4 ]; then
#     hub_path="${project}/${h1}${i}/hiplib/config/mesh"
#     if [ -f "$hub_path" ]; then
#       hub_mesh=$(<"$hub_path")
#       rules="${rules}$'\n'${hub_mesh}"
#     else
#       echo "Error: File not found at $hub_path" >&2
#     fi
#   fi
#   spoke_path="${project}/${s1}${i}/hiplib/config/mesh"
#   if [ -f "$spoke_path" ]; then
#     spoke_mesh=$(<"$spoke_path")
#     rules="${rules}$'\n'${spoke_mesh}"
#   else
#     echo "Error: File not found at $spoke_path" >&2
#   fi
# done

# for i in $(seq 1 $total_spokes); do
#   if [ "$i" -lt 4 ]; then
#     hub_path="${project}/${h1}${i}/hiplib/config/mesh"
#     echo "$rules" | sudo tee "$hub_path" > /dev/null
#   fi
#   spoke_path="${project}/${s1}${i}/hiplib/config/mesh"
#   echo "$rules" | sudo tee "$spoke_path" > /dev/null
# done

echo "Running python mn setup"

sudo python3 hipls-mn.py -n "${spokes}"

echo "Finished copying and creating $spokes spokes"
