
function latex_compile() 
{
    if [[ -z "$1" ]]; then
        echo "No file name submitted"
        return 1
    fi
    
    local texfile="$1"
    
    if [[ ! -f "$texfile" ]]; then
        echo "File not found"
        return 1
    fi
    
    local output=$(pdflatex -interaction=nonstopmode "$texfile" 2>&1)
    
    # Check for errors in the output
    if echo "$output" | grep -q "! LaTeX Error:"; then
        echo "Failed!"
        # Extract the first LaTeX error with line number
        local error=$(echo "$output" | grep -A1 "! LaTeX Error:" | head -2 | tr '\n' ' ')
        if [[ -n "$error" ]]; then
            echo "Error: $error"
        fi
        local line=$(echo "$output" | grep -o "l\.[0-9]*" | head -1)
        if [[ -n "$line" ]]; then
            echo "Line: ${line#l.}"
        fi
        return 1
    else
        echo "Success!"
        return 0
    fi
}
