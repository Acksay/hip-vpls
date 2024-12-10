#!/bin/bash
project="/home/ubuntu2/git_clone/hip-vpls"
r1="/router1/hiplib"
r2="/router2/hiplib"
r3="/router3/hiplib"
r4="/router4/hiplib"
r5="/router5/hiplib"
r6="/router6/hiplib"

# Copy hlib.py file from router 1 to router 2 3 and 4
for i in ${project}${r2}/hlib.py ${project}${r3}/hlib.py ${project}${r4}/hlib.py ${project}${r5}/hlib.py ${project}${r6}/hlib.py
do 
    sudo cp ${project}${r1}/hlib.py $i
done 

# Copy switchd.py file from router 1 to router 2 3 and 4
for i in ${project}/router2/switchd.py ${project}/router3/switchd.py ${project}/router4/switchd.py ${project}/router5/switchd.py  ${project}/router6/switchd.py 
do 
    sudo cp ${project}/router1/switchd.py $i
done 


# Copy relevant folders from router 1 to router 2 3 and 4
for f in crypto packets databases utils
do
    for i in ${project}${r2}/${f} ${project}${r3}/${f} ${project}${r4}/${f} ${project}${r5}/${f} ${project}${r6}/${f}
    do 
        sudo cp -r -T ${project}${r1}/${f} $i
    done 
done
