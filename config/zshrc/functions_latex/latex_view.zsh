
function latex_view() 
{
    if [[ -z "$1" ]]; then
        echo "No file name submitted"
        return 1
    fi
    
    local texfile="$1"
    local pdffile="${texfile%.tex}.pdf"
    
    if [[ ! -f "$texfile" ]]; then
        echo "File not found"
        return 1
    fi
    
    local output=$(pdflatex -interaction=nonstopmode "$texfile" 2>&1)
    
    # Check for errors in the output
    if echo "$output" | grep -q "! LaTeX Error:"; then
        echo "Failed!"
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
        echo "Success! Opening $pdffile in Firefox"
        (firefox "$pdffile" >/dev/null 2>&1 &)
        return 0
    fi
}
