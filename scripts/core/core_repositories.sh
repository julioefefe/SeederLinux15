#!/bin/bash
# ============================================================================
# Core Script: core_repositories.sh
# SeederLinux Lite - Configurar sources.list (APT)
# ============================================================================
# Detecta a distribuicao (Debian, Ubuntu, Mint, Zorin) e configura os
# repositorios APT conforme o modo e as variaveis por distro:
#   REPOSITORY_DEBIAN_ENABLED / REPOSITORY_DEBIAN_URL
#   REPOSITORY_UBUNTU_ENABLED / REPOSITORY_UBUNTU_URL
#   REPOSITORY_MINT_ENABLED   / REPOSITORY_MINT_URL
#   REPOSITORY_ZORIN_ENABLED  / REPOSITORY_ZORIN_URL
# NUNCA altera sources.list se o modo for PUBLIC ou se o mirror da distro
# detectada nao estiver habilitado.
# Os placeholders VARIAVEL sao substituidos automaticamente
# pelo sistema na geracao do bundle.
# ============================================================================

set -e

echo "============================================================"
echo "02 - Configurar repositorios APT"
echo "============================================================"

# ============================================================
# Variaveis globais
# ============================================================
REPOSITORY_MODE="{{REPOSITORY_MODE}}"
REPOSITORY_URL="{{REPOSITORY_URL}}"
REPOSITORY_FALLBACK="{{REPOSITORY_FALLBACK}}"

# Variaveis por distro
REPOSITORY_DEBIAN_ENABLED="{{REPOSITORY_DEBIAN_ENABLED}}"
REPOSITORY_DEBIAN_URL="{{REPOSITORY_DEBIAN_URL}}"
REPOSITORY_UBUNTU_ENABLED="{{REPOSITORY_UBUNTU_ENABLED}}"
REPOSITORY_UBUNTU_URL="{{REPOSITORY_UBUNTU_URL}}"
REPOSITORY_MINT_ENABLED="{{REPOSITORY_MINT_ENABLED}}"
REPOSITORY_MINT_URL="{{REPOSITORY_MINT_URL}}"
REPOSITORY_ZORIN_ENABLED="{{REPOSITORY_ZORIN_ENABLED}}"
REPOSITORY_ZORIN_URL="{{REPOSITORY_ZORIN_URL}}"

# CORRECAO: faltava tratamento de NON_INTERACTIVE (ja usado em
# core_dns.sh/core_domain.sh). Sem isso, os `read -p` abaixo
# dependiam do stdin do cron vir vazio por acaso para nao travar.
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"

echo ">>> Modo de repositorio: $REPOSITORY_MODE"

# ============================================================
# Detectar a distribuicao
# ============================================================
detect_distro() {
    if [ -f /etc/linuxmint/info ]; then
        echo "mint"
    elif [ -f /etc/zorin-release ]; then
        echo "zorin"
    elif grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
        echo "ubuntu"
    elif grep -qi "debian" /etc/os-release 2>/dev/null; then
        echo "debian"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)
echo ">>> Distribuicao detectada: $DISTRO"

# ============================================================
# Backup do sources.list original
# ============================================================
backup_sources() {
    if [ -f /etc/apt/sources.list ]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)
        echo ">>> Backup do sources.list criado"
    fi
}

# ============================================================
# Obter codename da distro
# ============================================================
# CORRECAO: antes dependia exclusivamente de `lsb_release -cs`. O
# pacote que fornece esse comando (lsb-release) so e instalado no
# core_packages.sh, que roda na etapa 03 - mas este script (repos)
# roda na etapa 02, ANTES. Numa instalacao minima sem lsb_release
# presente, caia direto no fallback hardcoded (ex.: "noble"), que so
# acerta por coincidencia se a estacao realmente for essa versao -
# numa frota com versoes misturadas, aponta pro codename errado e
# quebra o apt-get update.
#
# Agora le VERSION_CODENAME direto de /etc/os-release primeiro: esse
# arquivo existe por padrao em qualquer Debian/Ubuntu/Mint/Zorin, sem
# precisar de nenhum pacote extra instalado, e reflete a versao real
# da estacao com mais confianca. lsb_release fica como segunda opcao
# (caso ja esteja instalado) e o parametro passado como ultimo
# fallback, igual antes.
get_codename() {
    local fallback="$1"
    local codename=""

    if [ -f /etc/os-release ]; then
        codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    fi

    if [ -z "$codename" ] && command -v lsb_release &>/dev/null; then
        codename="$(lsb_release -cs 2>/dev/null)"
    fi

    if [ -z "$codename" ]; then
        echo ">>> AVISO: nao foi possivel determinar o codename real da estacao." >&2
        echo ">>> Usando fallback hardcoded: $fallback" >&2
        codename="$fallback"
    fi

    echo "$codename"
}

# ============================================================
# Configuracao conforme o modo
# ============================================================
case "$REPOSITORY_MODE" in
    PUBLIC|"")
        echo ">>> Modo PUBLIC: mantendo repositorios padrao da distribuicao ($DISTRO)."
        echo ">>> Nenhuma alteracao em sources.list foi feita."
        ;;

    MIRROR|HYBRID)
        case "$DISTRO" in
            debian)
                if [ "${REPOSITORY_DEBIAN_ENABLED:-false}" = "true" ] && [ -n "${REPOSITORY_DEBIAN_URL:-}" ]; then
                    echo ">>> Configurando mirror Debian: $REPOSITORY_DEBIAN_URL"
                    backup_sources
                    DEBIAN_CODENAME=$(get_codename trixie)
                    cat > /etc/apt/sources.list <<EOF
deb $REPOSITORY_DEBIAN_URL/debian $DEBIAN_CODENAME main contrib non-free non-free-firmware
deb $REPOSITORY_DEBIAN_URL/debian-security $DEBIAN_CODENAME-security main contrib non-free non-free-firmware
deb $REPOSITORY_DEBIAN_URL/debian $DEBIAN_CODENAME-updates main contrib non-free non-free-firmware
EOF
                    if [ "$REPOSITORY_MODE" = "HYBRID" ] && [ -n "$REPOSITORY_FALLBACK" ]; then
                        echo ">>> Adicionando fallback Debian..."
                        cat >> /etc/apt/sources.list <<EOF
deb $REPOSITORY_FALLBACK/debian $DEBIAN_CODENAME main contrib non-free non-free-firmware
deb $REPOSITORY_FALLBACK/debian-security $DEBIAN_CODENAME-security main contrib non-free non-free-firmware
deb $REPOSITORY_FALLBACK/debian $DEBIAN_CODENAME-updates main contrib non-free non-free-firmware
EOF
                    fi
                else
                    echo ">>> Mirror Debian nao habilitado. Mantendo repositorios oficiais."
                fi
                ;;

            ubuntu)
                if [ "${REPOSITORY_UBUNTU_ENABLED:-false}" = "true" ] && [ -n "${REPOSITORY_UBUNTU_URL:-}" ]; then
                    echo ">>> Configurando mirror Ubuntu: $REPOSITORY_UBUNTU_URL"
                    backup_sources
                    UBUNTU_CODENAME=$(get_codename noble)
                    cat > /etc/apt/sources.list <<EOF
deb $REPOSITORY_UBUNTU_URL/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb $REPOSITORY_UBUNTU_URL/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb $REPOSITORY_UBUNTU_URL/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    if [ "$REPOSITORY_MODE" = "HYBRID" ] && [ -n "$REPOSITORY_FALLBACK" ]; then
                        echo ">>> Adicionando fallback Ubuntu..."
                        cat >> /etc/apt/sources.list <<EOF
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    fi
                else
                    echo ">>> Mirror Ubuntu nao habilitado. Mantendo repositorios oficiais."
                fi
                ;;

            mint)
                MINT_CODENAME=$(get_codename wilma)
                UBUNTU_CODENAME=$(grep UBUNTU_CODENAME /etc/linuxmint/info 2>/dev/null | cut -d= -f2 || echo noble)
                MINT_OK=false

                if [ "${REPOSITORY_MINT_ENABLED:-false}" = "true" ] && [ -n "${REPOSITORY_MINT_URL:-}" ]; then
                    MINT_OK=true
                fi

                if [ "$MINT_OK" = "true" ]; then
                    echo ">>> Configurando mirror Mint: $REPOSITORY_MINT_URL"
                    backup_sources
                    cat > /etc/apt/sources.list <<EOF
deb $REPOSITORY_MINT_URL/mint $MINT_CODENAME main upstream import backport
EOF
                    if [ "${REPOSITORY_UBUNTU_ENABLED:-false}" = "true" ] && [ -n "${REPOSITORY_UBUNTU_URL:-}" ]; then
                        echo ">>> Configurando mirror Ubuntu base para Mint: $REPOSITORY_UBUNTU_URL"
                        cat >> /etc/apt/sources.list <<EOF
deb $REPOSITORY_UBUNTU_URL/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb $REPOSITORY_UBUNTU_URL/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb $REPOSITORY_UBUNTU_URL/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    else
                        echo ">>> Mirror Ubuntu nao habilitado. Mantendo repositorios oficiais do Ubuntu base."
                        cat >> /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    fi

                    if [ "$REPOSITORY_MODE" = "HYBRID" ] && [ -n "$REPOSITORY_FALLBACK" ]; then
                        echo ">>> Adicionando fallback..."
                        cat >> /etc/apt/sources.list <<EOF
deb $REPOSITORY_FALLBACK/mint $MINT_CODENAME main upstream import backport
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    fi
                else
                    echo ">>> Mirror Mint nao habilitado. Mantendo repositorios oficiais."
                fi
                ;;

            zorin)
                if [ "${REPOSITORY_ZORIN_ENABLED:-false}" = "true" ] && [ -n "${REPOSITORY_ZORIN_URL:-}" ]; then
                    echo ">>> Configurando mirror Zorin: $REPOSITORY_ZORIN_URL"
                    backup_sources
                    UBUNTU_CODENAME=$(get_codename jammy)
                    cat > /etc/apt/sources.list <<EOF
deb $REPOSITORY_ZORIN_URL/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb $REPOSITORY_ZORIN_URL/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb $REPOSITORY_ZORIN_URL/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    if [ "$REPOSITORY_MODE" = "HYBRID" ] && [ -n "$REPOSITORY_FALLBACK" ]; then
                        echo ">>> Adicionando fallback Zorin..."
                        cat >> /etc/apt/sources.list <<EOF
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb $REPOSITORY_FALLBACK/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse
EOF
                    fi
                else
                    echo ">>> Mirror Zorin nao habilitado. Mantendo repositorios oficiais."
                fi
                ;;

            *)
                echo ">>> Distribuicao nao reconhecida. Mantendo sources.list padrao."
                ;;
        esac
        ;;

    CUSTOM)
        CUSTOM_SKIP="false"
        if [ -z "$REPOSITORY_URL" ] || [ "$REPOSITORY_URL" = "" ]; then
            echo ">>> ERRO: REPOSITORY_URL nao definido para modo CUSTOM"
            if [ "$NON_INTERACTIVE" = "true" ]; then
                echo ">>> Modo nao interativo: mantendo sources.list atual (nao sobrescrevendo com valor vazio)."
                CUSTOM_SKIP="true"
            else
                read -p ">>> REPOSITORY_URL vazio. Manter sources.list atual e continuar? (S/n): " CONTINUE
                if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
                    echo ">>> Prosseguindo mesmo assim - mantendo sources.list atual (nao seria seguro escrever vazio)."
                fi
                CUSTOM_SKIP="true"
            fi
        fi

        if [ "$CUSTOM_SKIP" = "true" ]; then
            echo ">>> [02] Repositorio CUSTOM nao aplicado (REPOSITORY_URL ausente) - sources.list mantido como estava."
        else
            echo ">>> Configurando repositorio personalizado"
            backup_sources

            cat > /etc/apt/sources.list <<EOF
$REPOSITORY_URL
EOF
        fi
        ;;

    *)
        echo ">>> ERRO: Modo de repositorio invalido: $REPOSITORY_MODE"
        # CORRECAO: antes dava `exit 1` aqui, abortando o bundle
        # inteiro (script roda sem subshell, e e a etapa 02 - matar
        # tudo aqui significa nunca chegar no ingresso AD nem em
        # nada mais). Um REPOSITORY_MODE invalido e erro de config
        # da OM, nao motivo para travar o provisionamento inteiro -
        # mantem sources.list como esta e segue.
        if [ "$NON_INTERACTIVE" = "true" ]; then
            echo ">>> Modo nao interativo: mantendo sources.list atual."
        else
            read -p ">>> REPOSITORY_MODE invalido. Continuar sem alterar repositorios? (S/n): " CONTINUE
            if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
                echo ">>> Prosseguindo mesmo assim (sources.list mantido como esta)."
            fi
        fi
        echo ">>> [02] Nenhuma alteracao de repositorio aplicada (REPOSITORY_MODE='$REPOSITORY_MODE' invalido)."
        ;;
esac

# ============================================================
# Atualizar indice de pacotes
# ============================================================
echo ">>> Atualizando apt-get update..."
apt-get update

echo ">>> [02] Repositorios configurados com sucesso!"
echo "============================================================"
