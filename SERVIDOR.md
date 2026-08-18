# Configuração do Servidor — SeederLinux Lite

Este documento complementa o `README.md` com instruções de instalação, configuração do servidor web, banco de dados, permissões e solução de problemas.

---

## 1. Estrutura de diretórios

A instalação recomendada é:

```
/var/www/seederlinux-lite/
├── admin.html
├── api/
│   ├── index.php
│   └── download.php
├── assets/
│   ├── css/
│   ├── js/
│   ├── logos/
│   └── wallpapers/
├── backend/
├── downloads/
│   ├── agent.py
│   └── ...
├── index.html
├── install/
│   ├── install.sh
│   ├── schema.sql
│   ├── insert_core_scripts.sql
│   └── gen_insert_core.py
├── lib/
├── login.html
├── scripts/
│   └── core/
│       ├── core_dns.sh
│       ├── core_repositories.sh
│       └── ...
├── storage/
└── tests/
```

O repositório Git em produção costuma ficar em:

```
/opt/SeederLinux_14
```

A instalação Apache é feita em:

```
/var/www/seederlinux-lite
```

---

## 2. Instalação rápida

### 2.1 Clonar o repositório

```bash
sudo mkdir -p /opt/SeederLinux_14
sudo git clone https://github.com/Toledo-JC/SeederLinux_14.git /opt/SeederLinux_14
cd /opt/SeederLinux_14
```

### 2.2 Instalar dependências do sistema

```bash
sudo apt update
sudo apt install -y apache2 php php-pgsql php-mbstring php-curl php-json php-xml php-gd \
  postgresql postgresql-contrib git python3 python3-requests jq
```

### 2.3 Criar banco de dados e usuário

```bash
sudo -u postgres psql -c "CREATE USER seeder WITH PASSWORD 'sua_senha_segura';"
sudo -u postgres psql -c "CREATE DATABASE seederlinux OWNER seeder;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE seederlinux TO seeder;"
```

### 2.4 Executar o instalador

```bash
cd /opt/SeederLinux_14
sudo bash install/install.sh
```

O instalador se encarrega de copiar os arquivos para `/var/www/seederlinux-lite`, aplicar o schema e ajustar permissões.

---

## 3. Configuração do Apache

### 3.1 Criar VirtualHost

```bash
sudo nano /etc/apache2/sites-available/seederlinux-lite.conf
```

```apache
<VirtualHost *:80>
    ServerName seederlinux.comara.intraer
    DocumentRoot /var/www/seederlinux-lite

    <Directory /var/www/seederlinux-lite>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/seederlinux-lite_error.log
    CustomLog ${APACHE_LOG_DIR}/seederlinux-lite_access.log combined
</VirtualHost>
```

### 3.2 Habilitar site e módulos

```bash
sudo a2enmod rewrite headers
sudo a2ensite seederlinux-lite
sudo systemctl reload apache2
sudo systemctl restart apache2
```

### 3.3 Permissões

```bash
sudo chown -R www-data:www-data /var/www/seederlinux-lite
sudo chmod -R 755 /var/www/seederlinux-lite
sudo chmod -R 775 /var/www/seederlinux-lite/storage
sudo chmod -R 775 /var/www/seederlinux-lite/assets/wallpapers
sudo chmod -R 775 /var/www/seederlinux-lite/assets/logos
```

---

## 4. Configuração do Nginx (alternativa)

```nginx
server {
    listen 80;
    server_name seederlinux.comara.intraer;

    root /var/www/seederlinux-lite;
    index index.html index.php;

    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        try_files $uri /api/index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_HOST $host;
        fastcgi_param SERVER_NAME $host;
    }

    location ~ ^/(lib|backend|install|scripts|storage|tests)/ {
        deny all;
    }

    location ~ \.(sql|md|sh|py|env)$ {
        deny all;
    }
}
```

Habilitar:

```bash
sudo ln -s /etc/nginx/sites-available/seederlinux-lite /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 5. Configuração do banco de dados

O projeto utiliza o arquivo `.env` na raiz da instalação. Exemplo:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=seederlinux
DB_USER=seeder
DB_PASS=sua_senha_segura

APP_NAME=SeederLinux Lite
APP_VERSION=13
DEBUG=false
```

Após alterar o `.env`, reinicie o Apache/Nginx.

---

## 6. Gerar e sincronizar scripts Core

### 6.1 Gerar SQL dos scripts

```bash
cd /opt/SeederLinux_14
python3 install/gen_insert_core.py > install/insert_core_scripts.sql
```

Aplicar no banco:

```bash
sudo -u postgres psql -d seederlinux -f install/insert_core_scripts.sql
```

### 6.2 Sincronizar scripts do GitHub via servidor

```bash
cd /opt/SeederLinux_14
./install/seeder-sync-scripts.sh --server https://seederlinux.comara.intraer
```

---

## 7. Verificação

### Teste 1: página inicial

```bash
curl -I https://seederlinux.comara.intraer/index.html
# Deve retornar 200 OK
```

### Teste 2: API de status

```bash
curl https://seederlinux.comara.intraer/api/?action=dashboard
# Deve retornar JSON
```

### Teste 3: download do agente

```bash
curl -I https://seederlinux.comara.intraer/downloads/agent.py
# Deve retornar 200 OK
```

---

## 8. Problemas comuns

### 8.1 Redirecionamento para localhost

Verifique se `BASE_URL`, `SEEDER_SERVER` e `PROXY_URL` estão com o host correto da organização.

### 8.2 Página em branco

```bash
sudo tail -f /var/log/apache2/seederlinux-lite_error.log
```

Ou ative temporariamente erros no PHP:

```php
ini_set('display_errors', 1);
error_reporting(E_ALL);
```

### 8.3 404 na API

```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### 8.4 Erro de permissão

```bash
sudo chown -R www-data:www-data /var/www/seederlinux-lite
sudo chmod -R 755 /var/www/seederlinux-lite
```

---

## 9. Atualização do sistema

```bash
cd /opt/SeederLinux_14
git pull origin main
sudo bash install/install.sh
```

Se houver alteração em `install/schema.sql`, o instalador aplicará as migrações necessárias. Em caso de customizações locais, faça backup do banco antes:

```bash
sudo -u postgres pg_dump seederlinux > /tmp/seederlinux_backup_$(date +%Y%m%d_%H%M%S).sql
```

---

## 10. Observações de segurança

- Altere as senhas padrão imediatamente.
- Mantenha `DEBUG=false` em produção.
- Utilize HTTPS com certificado válido ou PKI interna.
- Restrinja o acesso aos diretórios sensíveis (`lib/`, `backend/`, `install/`, `storage/`).
- Monitore os logs de auditoria e erros.
