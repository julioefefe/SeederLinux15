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

Para executar manualmente um job existente:

```bash
sudo -u www-data /var/www/seederlinux-lite/scripts/mirror-sync.sh JOB_ID
```

O log do job fica em `mirror_base_path/log/sync-JOB_ID.log`. O worker atualiza `mirror.jobs` para `running`, `success` ou `error` e registra um job `cleanup` quando a limpeza automatica esta ativa.

A sincronizacao real depende da disponibilidade da ferramenta, URLs validas e permissao de escrita no caminho configurado. O worker nao instala pacotes automaticamente.
