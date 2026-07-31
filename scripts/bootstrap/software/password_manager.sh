# Install password manager
#--------------------------------------------------------------
sudo dnf install -y \
	rbw \
	pinentry-tty

# Make pinentry-tty the default instead of a new container
mkdir -p ~/.gnupg
echo 'pinentry-program /usr/bin/pinentry-tty' >> ~/.gnupg/gpg-agent.conf
chmod 700 ~/.gnupg
