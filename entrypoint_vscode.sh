#!/usr/bin/env bash

echo "You are connecting with User ${MYUSERNAME}"
echo "args = $@"

ID=$(id -u)
#If we are root and we have give a MYUID different from default
if [ "$ID" -eq "0" ] && [ $MYUID != "" ]; then
    echo "Creating user $MYUSERNAME"
    groupadd -g $MYGID myusers || true
    useradd --uid $MYUID --gid $MYGID -s /bin/bash --home /home/$MYUSERNAME $MYUSERNAME
    echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} 
    sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME}

    echo "reset default env"
    export HOME=/home/${MYUSERNAME}
fi

if [ -f ${VSCODE_WORKING_COPY}/.workingcopyrc ]; then
    echo "There is a .workingcopyrc we source it and launch code"
    source ${VSCODE_WORKING_COPY}/.workingcopyrc

    echo "Copying .workingcopyrc to /etc/profile.d to making it execute for shells"
    echo "
NOTE: about .workingcopyrc and your shell environments:

If you want .workingcopyrc to be sourced into the env
of a shell started with 'docker exec' (and presumably you do), 
then use sh with the '-l' option, e.g. 
    docker exec -it my-container:vscode sh -l -c 'some commands'
"

    cp ${VSCODE_WORKING_COPY}/.workingcopyrc /etc/profile.d/workingcopyrc.sh
    # TODO: test to make sure putting the .workingcopyrc script in /etc/profile.d works for all shells cases
fi

if [ "$1" == "vscode" ]; then
    # Default CMD vscode, so we'll launch an x11 VS Code session.

    echo "Starting vscode $1, code"
    if [ $ID = 0 ];then
        if [ -f /home/$MYUSERNAME/.bashrc ]; then
            echo "there is a .bashrc we source it and launch code"
            su $MYUSERNAME -p -c "source /home/$MYUSERNAME/.bashrc && code --verbose -w ${VSCODE_WORKING_COPY}"
        else
            echo "there is NO .bashrc we just launch code -verbose -w ${VSCODE_WORKING_COPY}"
            su $MYUSERNAME -p -c "code -w ${VSCODE_WORKING_COPY}"
        fi
	    echo "Code a rendu la main..., we Exit"
    fi
else
    echo "Starting your overrided command: exec $@"
    exec $@
fi

echo "end of script"

exit 0
