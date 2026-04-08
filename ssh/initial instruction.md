Шаг 3: Настройка Docker Compose

Создать ключи для гитхаба

cd ~/.ssh && ssh-keygen -t ed25519 -C "nn.tverd@gmail.com" && \
cat ~/.ssh/id_ed25519.pub

Добавить ключи в гитхаб

Спулить репозиторий

cd ~/ && \
mkdir -p ~/code && \
cd ~/code && \
git clone git@github.com:niktverd/gnk-proxy.git

Настроить ssh и firewall

cd gnk-proxy && \
bash ssh/create.sh