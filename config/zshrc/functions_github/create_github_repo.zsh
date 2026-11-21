
# Creates repo in my GH account, default to private
create_github_repo()
{
    # Parameters
    local repo_name=$1
    local privacy=${2:-private}  # Default to private
    local clean_name=${3:-}

    # Validate parameters
    if [ -z "$repo_name" ]; then
        echo "Error: Repository name must not be blank"
        return 1
    elif [ "$privacy" != "public" ] && [ "$privacy" != "private" ]; then
        echo "Error: Privacy must be one of 'public' or 'private'"
        return 1
    fi

    # Check if I have a repo with that name already
    if gh repo view "David-Manning/$repo_name" &>/dev/null; then
        echo "Error: Repository '$repo_name' already exists"
        return 1
    fi

    # Create repository
    ssh_github # Login
    if ! gh repo create "$repo_name" --"$privacy"; then
        echo "Failed to create repository"
        return 1
    fi

    # Check if destination folder already exists
    if [ -d ~/projects/"$repo_name" ]; then
        echo "Warning: Folder ~/projects/$repo_name already exists"
        echo "Options:"
        echo "  [r] Remove existing folder and clone fresh"
        echo "  [b] Backup existing folder and clone fresh"
        echo "  [s] Skip cloning (use existing folder)"
        echo "  [a] Abort"
        read -k 1 choice
        echo ""

        case "$choice" in
            r|R)
                rm -rf ~/projects/"$repo_name"
                ;;
             b|B)
                backup_name="$repo_name.bak.$(date +%Y%m%d%H%M%S)"
                mv ~/projects/"$repo_name" ~/projects/"$backup_name"
                echo "Folder backed up to ~/projects/$backup_name"
                ;;
            s|S)
                echo "Using existing folder"
                cd ~/projects/"$repo_name" || return 1
                return
                ;;
            *)
                echo "Operation aborted"
                return 1
                ;;
        esac
    fi

    # Clone repo
    mkdir -p ~/projects
    git clone "git@github.com:David-Manning/$repo_name.git" ~/projects/"$repo_name"
    cd ~/projects/"$repo_name" || return 1

    # Create README.md
    if [ "$clean_name" != "" ]; then
        echo "# $clean_name" > README.md

        git add README.md
        git commit -m "Initial commit: Add README"
        git push origin $(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

    elif [ -n "$repo_name" ]; then
        # Generate default name from repo_name
        default_name=$(echo "$repo_name" | sed 's/[_-]/ /g' | awk '{for(i=1;i<=NF;i++)                   $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1') # Turn titanic_data into Titanic Data (etc)
        echo "# $default_name Project" > README.md
        git add README.md
        git commit -m "Initial commit: Add README"
        git push origin $(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
    fi
	echo "Repository created and cloned successfully"
}

