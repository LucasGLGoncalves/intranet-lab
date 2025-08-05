# Vault Server - Docker Compose

Este projeto sobe um Vault da HashiCorp com interface web, armazenamento persistente e configuração segura para uso em ambientes de testes ou produção local (sem TLS).

---

## 📦 Requisitos

- Docker
- Docker Compose
- Navegador web

---

## 🚀 Subindo o Vault

1. Clone o repositório ou crie a estrutura abaixo:

```
.
├── compose.yml
└── vault.hcl
````

2. **Conteúdo do `docker-compose.yml`:**

```yaml
services:
  vault:
    image: hashicorp/vault:1.20
    container_name: vault-server
    ports:
      - "18200:8200"
    environment:
      VAULT_API_ADDR: http://127.0.0.1:8200
    cap_add:
      - IPC_LOCK
    volumes:
      - ./vault-data:/vault/file
      - ./vault.hcl:/vault/config/vault.hcl
    command: vault server -config=/vault/config/vault.hcl
    ```
```

3. **Conteúdo do `vault.hcl`:**

```hcl
ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "file" {
  path = "/vault/file"
}

disable_mlock = true
```

4. **Suba o container:**

```bash
docker compose up -d
```

---

## 🌐 Acessando a interface

Abra no navegador:

```
http://localhost:18200
```

---

## 🔐 Inicializando o Vault

Na primeira vez, a interface solicitará a **quantidade de chaves** e **threshold**:

* **Key Shares:** `5`
* **Key Threshold:** `3`

Clique em **"Initialize"**.

Serão gerados:

* 5 Unseal Keys
* 1 Root Token

⚠️ **Guarde esses dados com segurança!**

---

## 🔓 Desbloqueando o Vault (Unseal)

A interface pedirá que você insira 3 das 5 chaves para desbloquear.

Cole as chaves **uma por vez**.

Após isso, o Vault estará desbloqueado e pronto para uso.

---

## 🔑 Acessando com o Root Token

Depois de desbloquear, cole o **Root Token** gerado na inicialização para acessar o Vault.

---

## 🗄️ Criando e consultando segredos

1. Acesse a aba **"Secrets"**
2. Clique em **"Enable new engine"** e selecione **"KV - Key/Value"**
3. Crie um novo caminho, como `secrets/`
4. Dentro dele, crie chaves e valores (ex: `senha=123456`, `api_key=abc123`)

---

## ✅ Comandos úteis (CLI)

```bash
docker exec -it vault-server sh
export VAULT_ADDR=http://127.0.0.1:8200
vault status
vault operator unseal
vault login <root_token>
vault kv put secret/minha-senha senha=123456
vault kv get secret/minha-senha
```

---

## 🧼 Resetando o Vault (caso necessário)

```bash
docker compose down
sudo rm -rf vault-data/
```

---

## 🔒 Observações de Segurança

* TLS está desabilitado (útil para ambientes controlados ou VPN)
* Idealmente, configure o `api_addr` com IP da rede WireGuard
* Para uso real em produção, recomenda-se ativar TLS, mlock e auto-unseal com cloud KMS