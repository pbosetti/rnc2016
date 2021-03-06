#!/bin/bash 
echo 
echo "************************************"
echo "Fixing sources.list"

(
cat <<EOS
deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main
deb http://http.debian.net/debian/ jessie main
deb-src http://http.debian.net/debian/ jessie main
EOS
) > /etc/apt/sources.list.d/rnc.list

echo 
echo "************************************"
echo "Updating package list"
if ! apt-get update; then
  echo "Could not update package list"
  exit $?
fi
 
pkgs=(ruby ruby-dev git clang make gnuplot curl libreadline6-dev libssl-dev zlib1g-dev libglew-dev libglu1-mesa-dev freeglut3-dev ntp build-essential)

echo 
echo "************************************"
echo "Installing packages"
for p in ${pkgs[@]}
do
  echo
  echo "Installing ${p}"
  echo "---------------"
  if ! apt-get install -y --force-yes ${p}; then
    echo "Error while installing ${p}"
    exit $?
  fi
done

echo 
echo "************************************"
echo "Installing ruby gems"
gem install pry colorize ffi gnuplotr rake --no-rdoc --no-ri
 
echo 
echo "************************************"
echo " ALL DONE!"
echo "************************************"
echo
