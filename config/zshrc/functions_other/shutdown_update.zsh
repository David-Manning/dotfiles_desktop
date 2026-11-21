# Shutdown and update
shutdown_update()
{
	echo "Updating and closing down once you enter your password"
	sudo dnf upgrade --refresh -y
	shutdown 0
}
