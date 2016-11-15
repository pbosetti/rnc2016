#!/bin/bash 
echo 
echo "************************************"
echo "Updating package list"
if ! sudo apt-get update; then
  echo "Could not update package list"
  exit $?
fi
 
pkgs=(ruby2.1 ruby2.1-dev git clang make gnuplot curl libreadline6-dev libssl-dev zlib1g-dev libglew-dev libglu1-mesa-dev freeglut3-dev ntp build-essential)

echo 
echo "************************************"
echo "Installing packages"
for p in ${pkgs[@]}
do
  echo
  echo "Installing ${p}"
  echo "---------------"
  if ! sudo apt-get install -y --force-yes ${p}; then
    echo "Error while installing ${p}"
    exit $?
  fi
done

echo 
echo "************************************"
echo "Installing ruby gems"
sudo gem install pry colorize ffi gnuplotr rake --no-rdoc --no-ri
 
echo 
echo "************************************"
echo " ALL DONE!"
echo "************************************"
echo
