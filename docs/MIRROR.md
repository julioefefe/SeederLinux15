# Mirror real

O worker `scripts/mirror-sync.sh` executa jobs do Mirror somente quando o recurso esta habilitado em `mirror.config`. O endpoint administrativo apenas cria o job e inicia o worker em background; nenhuma sincronizacao e executada durante o desenvolvimento.

## Dependencias

No servidor Debian/Ubuntu, instale a ferramenta escolhida e o cliente PostgreSQL:

```bash
sudo apt-get update
sudo apt-get install -y postgresql-client
sudo apt-get install -y aptly
# ou, em vez de aptly:
sudo apt-get install -y apt-mirror
```

Configure `tool` em `mirror.config` como `aptly` ou `apt-mirror`. As URLs de origem sao obtidas das variaveis `REPOSITORY_DEBIAN_URL`, `REPOSITORY_UBUNTU_URL`, `REPOSITORY_MINT_URL` e `REPOSITORY_ZORIN_URL` das OMs que usam o mirror local.

## Diretorios

O worker cria, quando necessario, `tmp`, `log`, `cache`, `public` e `quarantine` dentro de `mirror_base_path`. Em uma instalacao padrao, o instalador cria o caminho `/var/lib/seederlinux/mirror` com proprietario `www-data`.

```
/var/lib/seederlinux/mirror/
├── cache/       # cache intermediario da ferramenta
├── log/         # logs dos jobs de sincronizacao
├── public/      # arquivos servidos pelo Apache via /mirror
├── quarantine/  # pacotes em quarentena (verificacao pendente)
└── tmp/         # arquivos temporarios
```

Para executar manualmente um job existente:

```bash
sudo -u www-data /var/www/seederlinux-lite/scripts/mirror-sync.sh JOB_ID
```

O log do job fica em `mirror_base_path/log/sync-JOB_ID.log`. O worker atualiza `mirror.jobs` para `running`, `success` ou `error` e registra um job `cleanup` quando a limpeza automatica esta ativa.

A sincronizacao real depende da disponibilidade da ferramenta, URLs validas e permissao de escrita no caminho configurado. O worker nao instala pacotes automaticamente.

## Acesso via Apache (Alias /mirror)

O instalador configura o Apache para servir o diretorio `public` do mirror diretamente, sem passar pelo PHP. A configuracao e incluida no VirtualHost em `/etc/apache2/sites-available/seederlinux-lite.conf`:

```apache
Alias /mirror /var/lib/seederlinux/mirror/public
<Directory /var/lib/seederlinux/mirror/public>
    Options +Indexes +FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    <FilesMatch "\.deb$">
        Header set Cache-Control "public, max-age=604800, immutable"
    </FilesMatch>
</IfModule>
```

### URL de acesso

A URL base e definida por `mirror.config.mirror_url_base`. Exemplo para o GAP-BE:

```
https://seederlinux.gapbe.intraer/mirror/debian
```

As estacoes usam essa URL no `sources.list` do APT para consumir pacotes do mirror local.

### Cabeçalhos HTTP

- `X-Content-Type-Options: nosniff` — aplicado a todos os arquivos do mirror.
- `Cache-Control: public, max-age=604800, immutable` — aplicado apenas a arquivos `.deb` (cache de 7 dias).

## Certificado SSL

O instalador usa o certificado snakeoil autoassinado do Debian (`/etc/ssl/certs/ssl-cert-snakeoil.pem`) para HTTPS. Isso e suficiente para desenvolvimento e testes.

Para producao, o GAP deve substituir por um certificado valido de uma CA confiavel ou de uma PKI interna. Para trocar o certificado:

1. Copie o certificado e a chave para o servidor:

```bash
sudo cp servidor.crt /etc/ssl/certs/seederlinux.crt
sudo cp servidor.key /etc/ssl/private/seederlinux.key
```

2. Edite o VirtualHost em `/etc/apache2/sites-available/seederlinux-lite.conf` e troque as linhas:

```apache
SSLCertificateFile /etc/ssl/certs/seederlinux.crt
SSLCertificateKeyFile /etc/ssl/private/seederlinux.key
```

3. Reinicie o Apache:

```bash
sudo systemctl restart apache2
```

### Clientes APT e certificado

Como o mirror usa HTTPS, as estacoes cliente precisam confiar no certificado do servidor. Existem duas opcoes:

- **Instalar a CA no cliente**: copiar o certificado da CA para `/usr/local/share/ca-certificates/` e executar `sudo update-ca-certificates`. O APT confiara no certificado automaticamente.
- **Usar `[trusted=yes]`**: adicionar `trusted=yes` na entrada do `sources.list` do cliente. Nao exige instalacao de CA, mas desativa a verificacao de integridade do canal — recomendado apenas para ambientes isolados e controlados.

Exemplo de `sources.list` no cliente:

```
deb [trusted=yes] https://seederlinux.gapbe.intraer/mirror/debian trixie main contrib non-free non-free-firmware
```
