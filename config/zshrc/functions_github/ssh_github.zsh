# Connect SSH to Github
# Necessary for cloning and creating repos etc
ssh_github()
{
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/github_david_manning
}
