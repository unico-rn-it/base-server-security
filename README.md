# Base Server Security

This repo keeps the setup minimal.

- [ssh/setup.sh](/Users/niktverd/code/unico.rn.it-dir/base-server-security/ssh/setup.sh) installs [ssh/sshd_config](/Users/niktverd/code/unico.rn.it-dir/base-server-security/ssh/sshd_config) as `/etc/ssh/sshd_config.d/99-hardening.conf`
- validates SSH with `sshd -t`
- disables `ssh.socket` and starts `ssh.service`
- enables only `80/tcp`, `443/tcp`, and `10022/tcp` in UFW

It assumes the server already uses the standard Debian/Ubuntu `Include /etc/ssh/sshd_config.d/*.conf` line in `/etc/ssh/sshd_config`.

## Usage

```bash
sudo ./ssh/setup.sh
```

Then test from another terminal before closing the current SSH session:

```bash
ssh -p 10022 root@<server-ip>
```

## Working Server Flow

This was the sequence on the working server. Replace repo addresses later as needed.

1. Create an SSH key for GitHub:

```bash
cd ~/.ssh && ssh-keygen -t ed25519 -C "some@email.com" && \
cat ~/.ssh/id_ed25519.pub
```

2. Add the public key to GitHub.

3. Clone the project repo:

```bash
cd ~/ && \
mkdir -p ~/code && \
cd ~/code && \
git clone git@github.com:unico-rn-it/base-server-security.git
```

4. Go to the repo and run the SSH/firewall setup:

```bash
cd ~/code/base-server-security && \
bash ssh/setup.sh
```

## What The Script Applies

`ssh/sshd_config` contains:

- `Port 10022`
- `PubkeyAuthentication yes`
- `PasswordAuthentication no`
- `KbdInteractiveAuthentication no`
- `PermitRootLogin prohibit-password`
- `UsePAM yes`
- `X11Forwarding no`
- `MaxAuthTries 10`
- `ClientAliveInterval 300`
- `ClientAliveCountMax 2`

## Extra Ports

Open an extra TCP port:

```bash
sudo ./ssh/open 3000
```

Close an extra TCP port:

```bash
sudo ./ssh/close 3000
```

## ShellCheck

Run ShellCheck directly with `npx`:

```bash
npx --yes shellcheck ssh/setup.sh ssh/open ssh/close
```

The repo-level ShellCheck settings are stored in [.shellcheckrc](/Users/niktverd/code/unico.rn.it-dir/base-server-security/.shellcheckrc).
