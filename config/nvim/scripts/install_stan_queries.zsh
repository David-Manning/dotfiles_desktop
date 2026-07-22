#!/usr/bin/env zsh
# ~/.config/nvim/scripts/install_stan_queries.zsh
# This script installs stan queries from Brian Ward's GitHub repo
# It MUST be run before Stan syntax highlighting works
# It is not a dependency for Stan syntax checking

set -e

echo "Installing Stan tree-sitter queries..."

# Create directory
mkdir -p ~/.config/nvim/after/queries/stan

# Download queries directly (no need to clone entire repo)
BASE_URL="https://raw.githubusercontent.com/WardBrian/tree-sitter-stan/main/queries"
QUERIES=("highlights.scm" "indents.scm" "injections.scm" "locals.scm")

for query in "${QUERIES[@]}"; do
    echo "Downloading $query..."
    curl -fLo ~/.config/nvim/after/queries/stan/"$query" "$BASE_URL/$query"
done

echo "Stan queries installed successfully!"
