# variables
export GDRIVE="/home/matteo/GoogleDrive"
export PROJECTS="/home/matteo/Documents/projects"
export SSHDIR="${HOME}/.ssh"

# rclone
alias gup="rclone sync --create-empty-src-dirs --exclude .directory  --copy-links --progress /home/matteo/GoogleDrive googledrive:"
alias gdown="rclone sync --create-empty-src-dirs --exclude .directory --copy-links --progress googledrive: /home/matteo/GoogleDrive"

# extra
## neofecth
if [ ${NEOFETCH:=true} = true ]; then
	neofetch
fi
## GPG
export GPG_TTY="$(tty)"

addssh() {
	if [ $# -ne 0 ]; then
		keychain "${SSHDIR}/id_$@"
	else
		echo "Specify at least one argument!"
	fi
}
