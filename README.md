# SSH password bruteforcer with proxies

Tries every combination of username and password, uses random proxy from given list and saves checked combinations for future runs.

```bash
./ssh_password_brute_force.sh <host_address> <usernames_filepath> <passwords_filepath> <proxies_filepath> <checked_combos_save_to_dest> <checked_combos_filepath>
```

If `checked_combos_filepath` is set then `checked_combos_save_to_dest` will be ignored.

## Examples

```bash
./ssh_password_brute_force.sh 0.0.0.0 ~/Downloads/usernames.txt ~/Downloads/passwords.txt ~/Downloads/proxies.txt ./run
```

```bash
./ssh_password_brute_force.sh 0.0.0.0 ~/Downloads/usernames.txt ~/Downloads/passwords.txt ~/Downloads/proxies.txt ./run ~/Downloads/already_checked_combos.txt
```

## Files samples

usernames_filepath:
```txt
root
admin
```

passwords_filepath:
```txt
root
admin
12345
54321
```

proxies_filepath:
```txt
1.1.1.1:8080:login:password
2.2.2.2:8181:login:password
```

checked_combos_filepath:
```txt
root:root
root:admin
root:12345
root:54321
root:
admin:root
admin:admin
admin:12345
admin:54321
admin:
:root
:admin
:12345
:54321
:
```
