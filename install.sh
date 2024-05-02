#!/bin/sh
echo
echo "D&I updates and upgrades..."
echo
sudo apt update -y
sudo apt upgrade -y
echo
echo "D&I dependencies..."
echo
sudo apt install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget -y
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb
mkdir -p ~/ccminer
cd ~/ccminer

GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/CCminer-ARM-optimized/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].name")

if [ -f ~/ccminer/ccminer ]
then
  mv ~/ccminer/ccminer ~/ccminer/ccminer.old
  echo
  echo "A ccminer binary was found and renamed to ccminer.old as a backup"
  echo
fi

echo
echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"
echo
wget ${GITHUB_DOWNLOAD_URL} -P ~/ccminer

if [ -f ~/ccminer/config.json ]
then
  mv ~/ccminer/config.json ~/ccminer/config.json.old
  echo
  echo "A config.json file was found and renamed to config.json.old as a backup"
  echo
fi

echo
echo "Downloading latest config.json from github repo"
echo
wget https://raw.githubusercontent.com/low2k7/dallasccminer/main/config.json -P ~/ccminer

mv ~/ccminer/${GITHUB_DOWNLOAD_NAME} ~/ccminer/ccminer
chmod +x ~/ccminer/ccminer

cat << EOF > ~/ccminer/start.sh
#!/bin/sh
~/ccminer/ccminer -c ~/ccminer/config.json
EOF
chmod +x start.sh

echo
echo "Setup nearly complete!"
echo
echo "Edit the config with \"nano ~/ccminer/config.json\""
echo "Change pools, wallet address and worker name."
echo
echo "Use \"CTRL + x\" to exit and respond with \"y\" on the question and to save \"enter\" on the name."
echo
echo "Start the miner with \"~/ccminer/start.sh\""
echo 
echo "Stop the miner with \"CTRL + c\""
echo
