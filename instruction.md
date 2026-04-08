Project: /Users/niktverd/code/unico-rn-it-docs

  Goal:
  Adapt docs from .sources/ssh_options into a Russian server-protection instruction set, using firewall setup
  as the base layer of protection.

  What was changed in the repo:
  - Added new docs section:
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/server-security/index.yaml
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/server-security/toc.yaml
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/server-security/baseline.md
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/server-security/ssh.md
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/server-security/audit.md
  - Linked this section from:
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/index.yaml
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/toc.yaml
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/servers.md
  - Also normalized multiline bash formatting in:
    - /Users/niktverd/code/unico-rn-it-docs/docs/ru/keycloak/deploy.md

  Main documentation decisions:
  - Base server setup should initially open only:
    - 10022/tcp for SSH
    - 3000/tcp for first Dokploy access
  - After Dokploy domain + HTTPS are working:
    - close 3000 in UFW
    - remove Dokploy port publish with:
      docker service update --publish-rm "published=3000,target=3000,mode=host" dokploy
  - Added explanation that the same --publish-rm pattern can be used for other Docker Swarm services if they
  should no longer be reachable as IP:port.
  - Added examples for:
    - custom app on 8080
    - Keycloak on 8080 / 9000
    - Temporal UI on 8080
  - Important caveat:
    - for Dokploy-managed services, removing the published port via CLI is not enough if the port is still
  configured in Dokploy, because redeploy may restore it.

  Important shell-formatting rule established:
  - For multiline bash command chains use:
    - && \
  - Not:
    - & \
  - Reason:
    - & backgrounds commands and is wrong here.

  Important SSH-doc correction:
  - A broken heredoc form was suggested at one point:
    - tee ... <<'EOF' && \
  - That is invalid because Bash then tries to execute lines like "Port 10022" as commands.
  - Correct one-copy-paste form is:

    install -d -m 0755 /etc/ssh/sshd_config.d && \
    cat >/etc/ssh/sshd_config.d/99-hardening.conf <<'EOF'
    Port 10022
    PubkeyAuthentication yes
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PermitRootLogin prohibit-password
    UsePAM yes
    X11Forwarding no
    MaxAuthTries 3
    ClientAliveInterval 300
    ClientAliveCountMax 2
    EOF

    ufw allow 10022/tcp && \
    sshd -t && \
    systemctl daemon-reload && \
    systemctl restart ssh.socket

  Docs/build verification:
  - Normal repo build command:
    - npm run build:docs
  - This repo has flaky docs-html temp-cache issues:
    - docs-html/.tmp_input / .tmp_output ENOENT errors happen intermittently
  - Clean validation was done with:
    - npx yfm --input docs --output /tmp/unico-rn-it-docs-build
  - That clean temp build passes.

  Live server situation / blocker:
  - Server involved:
    - 77.42.29.25
  - User applied SSH hardening.
  - External tests from Mac showed:
    - ssh root@77.42.29.25 -> port 22 timed out
    - ssh root@77.42.29.25 -p 10022 -> connection refused
  - Interpretation:
    - port 22 is blocked
    - nothing is listening on 10022
  - Most likely cause:
    - ssh.socket / socket activation did not bind to the new port
  - Important:
    - do NOT close the current root shell on the server

  Recommended recovery command from the still-open server session:
    cat /etc/ssh/sshd_config.d/99-hardening.conf && \
    sshd -t && \
    systemctl stop ssh.socket && \
    systemctl disable ssh.socket && \
    systemctl enable --now ssh.service && \
    ss -ltnp | grep 10022

  Then test from a second local terminal:
    ssh -p 10022 root@77.42.29.25

  If that still fails, collect:
    systemctl status ssh.service --no-pager && \
    journalctl -u ssh.service -n 50 --no-pager

  What the next assistant should help with:
  - Recover SSH access on 77.42.29.25 without losing the current session
  - Confirm whether ssh.service is listening on 10022
  - If needed, adjust systemd SSH mode away from ssh.socket
  - Optionally refine the docs after SSH recovery is confirmed