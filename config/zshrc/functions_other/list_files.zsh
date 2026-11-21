# Eza settings
list_files()
{

	local file_count=$(ls -1A | wc -l)
	if [[ $file_count -le 30 ]]; then
		echo "Printing nested files:"
		eza --long --header --tree --total-size
	else
		echo "Printing only files in this directory:"
		eza --long --header --total-size
	fi
}
