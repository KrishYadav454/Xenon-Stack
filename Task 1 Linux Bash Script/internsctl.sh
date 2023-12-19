#!/bin/bash

# internsctl script

show_help() {
    echo "Usage: internsctl [OPTIONS]"
    echo "  --help       Display help information"
    echo "  --version    Display the command version"
    echo "  cpu getinfo  Get CPU information"
    echo "  memory getinfo  Get memory information"
    echo "  user create <username>  Create a new user"
    echo "  user list [--sudo-only]  List all users or users with sudo permissions"
    echo "  file getinfo [options] <file-name>  Get information about a file"
    echo "    --size, -s            Print size"
    echo "    --permissions, -p     Print file permissions"
    echo "    --owner, -o           Print file owner"
    echo "    --last-modified, -m   Print last modified time"
}

show_version() {
    echo "internsctl v0.1.0"
}

get_cpu_info() {
    lscpu
}

get_memory_info() {
    free
}

create_user() {
    if [ -z "$1" ]; then
        echo "Error: Username not provided."
        exit 1
    fi

    username="$1"
    sudo useradd -m "$username" || { echo "Error creating user $username."; exit 1; }
}

list_users() {
    cut -d: -f1 /etc/passwd
}

list_sudo_users() {
    grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'
}

get_file_info() {
    if [ -z "$1" ]; then
        echo "Error: File name not provided."
        exit 1
    fi

    file="$1"
    size=$(stat --printf="%s" "$file")
    permissions=$(stat --printf="%a" "$file")
    owner=$(stat --printf="%U" "$file")
    last_modified=$(stat --printf="%y" "$file")
    
    case "$2" in
        --size|-s)
            echo "$size"
            ;;
        --permissions|-p)
            echo "$permissions"
            ;;
        --owner|-o)
            echo "$owner"
            ;;
        --last-modified|-m)
            echo "$last_modified"
            ;;
        *)
            echo "File: $file"
            echo "Access: $permissions"
            echo "Size(B): $size"
            echo "Owner: $owner"
            echo "Modify: $last_modified"
            ;;
    esac
}

case "$1" in
    --help)
        show_help
        ;;
    --version)
        show_version
        ;;
    cpu)
        if [ "$2" == "getinfo" ]; then
            get_cpu_info
        fi
        ;;
    memory)
        if [ "$2" == "getinfo" ]; then
            get_memory_info
        fi
        ;;
    user)
        if [ "$2" == "create" ]; then
            create_user "$3"
        elif [ "$2" == "list" ]; then
            if [ "$3" == "--sudo-only" ]; then
                list_sudo_users
            else
                list_users
            fi
        fi
        ;;
    file)
        if [ "$2" == "getinfo" ]; then
            get_file_info "$3" "$4"
        fi
        ;;
    *)
        echo "Invalid command. Use --help for usage information."
        exit 1
        ;;
esac

exit 0