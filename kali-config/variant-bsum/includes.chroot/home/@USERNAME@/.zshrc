# variables
export GDRIVE="${HOME}/GoogleDrive"
export PROJECTS="${HOME}/Documents/projects"
export SSHDIR="${HOME}/.ssh"

# rclone
alias gup="rclone sync --create-empty-src-dirs --exclude .directory --copy-links --progress ${GDRIVE} googledrive:"
alias gdown="rclone sync --create-empty-src-dirs --exclude .directory --copy-links --progress googledrive: ${GDRIVE}"

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
		>&2 echo "Specify at least one argument!"
	fi
}
