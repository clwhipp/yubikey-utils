# yubikey-utils
Contains scripts and tools for making use of yubikeys throughout network architecture for protection of resources.

## Bitwarden Command Line Interface (CLI) Access

The ykbw application serves as a wrapper around the bw executable provided by
Bitwarden. The ykbw utility serves as a means for wrapping the vault master key
using hmac-sha1 with a yubikey.

The first step is to login to the Bitwarden Vault via the cli and then lock the vault.

```bash
user@admin:~/Documents/yubikey-utils$ bw status
{"serverUrl":null,"lastSync":"2024-08-04T02:13:04.491Z","userEmail":"XXXXX@pm.me","userId":"1234","status":"locked"}
```

With the vault locked, the next step is to plug-in the yubikey and perform an enrollment operation for the vault. The enrollment
process is initiated by running the *ykbw enroll*. You'll then be prompted for the vault password.

```bash
user@admin:~/Documents/yubikey-utils$ ./ykbw enroll
Registering: 16166389
Enter vault master password
```

After entering the password, the tool will reach out to the yubikey to generate the encryption key for the bundle. It may be necessary
to touch your yubikey at this stage depending on the devices configuration. When completed, something like the following should be seen
on the screen.

```bash
Registering: 16166389
Enter vault master password: 
Sending challenge to yubikey. If necessary, please touch yubikey for use of second slot ...
Enrollment Complete for 16166389
```

It's possible to also check the enrollments with the *ykbw list* command as well.

```bash
user@admin:~/Documents/yubikey-utils$ ./ykbw list
 -- SN: 16166389
```

At this point, it's now possible to trigger the unlock of the vault using that yubikey and the ykbw utility. The unlock
process is as simple as typing *ykbw unlock*.

```bash
user@admin:~/Documents/yubikey-utils$ ./ykbw unlock
Sending challenge to yubikey. If necessary, please touch yubikey for use of second slot ...
Spawning Bash Session ...

user@admin:~/Documents/yubikey-utils$ bw status
{"serverUrl":null,"lastSync":"2024-08-04T02:13:04.491Z","userEmail":"XXXX@pm.me","userId":"1234","status":"unlocked"}
```

The unlock command will spawn a new bash shell with the BW_SESSION defined meaning that bw cli will see the vault as unlocked
and ready for consumption. When the session is finished a simple exit command will result in the vault being locked.
