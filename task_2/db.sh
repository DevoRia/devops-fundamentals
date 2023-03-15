#!/bin/bash

DB_FILE="users.db"
BACKUP_DIR="backup"
DATE_FORMAT="+%Y-%m-%d_%H-%M-%S"

add_user() {
    read -p "Enter username: " username
    if ! echo "$username" | grep -E '^[[:alpha:]]+$' > /dev/null; then
        echo "Invalid username format. Username should contain Latin letters only."
        return
    fi
    read -p "Enter role: " role
    if ! echo "$role" | grep -E '^[[:alpha:]]+$' > /dev/null; then
        echo "Invalid role format. Role should contain Latin letters only."
        return
    fi
    echo "$username, $role" >> "$DB_FILE"
    echo "User added: $username, $role"
}

backup_db() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir "$BACKUP_DIR"
    fi
    cp "$DB_FILE" "$BACKUP_DIR/$(date "$DATE_FORMAT")-users.db.backup"
    echo "Backup created."
}

restore_db() {
    latest_backup=$(ls -t "$BACKUP_DIR"/*.backup 2> /dev/null | head -n1)
    if [ -z "$latest_backup" ]; then
        echo "No backup file found."
        return
    fi
    cp "$latest_backup" "$DB_FILE"
    echo "Database restored from $latest_backup."
}

find_user() {
    read -p "Enter username: " username
    found=0
    while IFS=, read -r db_username db_role; do
        if [ "$username" = "$db_username" ]; then
            echo "$db_username, $db_role"
            found=1
        fi
    done < "$DB_FILE"
    if [ $found -eq 0 ]; then
        echo "User not found."
    fi
}

list_users() {
    if [ "$1" = "--inverse" ]; then
        tac "$DB_FILE" | awk '{print NR". "$0}'
    else
        awk '{print NR". "$0}' "$DB_FILE"
    fi
}

if [ ! -f "$DB_FILE" ]; then
    read -p "users.db file not found. Do you want to create one? (y/n) " create_db
    if [ "$create_db" = "y" ]; then
        touch "$DB_FILE"
    else
        echo "Operation cancelled."
        exit 1
    fi
fi

case "$1" in
    add)
        add_user
        ;;
    backup)
        backup_db
        ;;
    restore)
        restore_db
        ;;
    find)
        find_user
        ;;
    list)
        list_users "$2"
        ;;
    help)
        echo "Usage: db.sh {add|backup|restore|find|list|help}"
        echo "  add     Adds a new line to the users.db."
        echo "  backup  Creates a new backup file."
        echo "  restore Restores the last created backup file."
        echo "  find    Finds and prints the username and role of a user."
        echo "  list    Lists all users in the database."
        echo "  help    Prints instructions on how to use this script."
        ;;
    *)
        echo "Invalid command. Use 'db.sh help' for instructions."
        ;;
esac
