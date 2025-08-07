## Passo 1: Executar um registry Docker via container

Com base na documentação oficial:

```bash
docker run -d -p 5000:5000 --name registry registry:3
```

Isso inicia um container com o Docker Registry na porta 5000 do seu host.

---

## Passo 2: Criar um `docker-compose.yml` com volume, porta e rede personalizada

Uma configuração básica usando Compose inclui:

```yaml
services:
  registry:
    image: registry:3
    ports:
      - "5000:5000"
    environment:
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
    volumes:
      - ./data:/data
    networks:
      - minha_rede

networks:
  minha_rede:
    driver: bridge
```

Essa configuração:

* Faz port‑forward da porta 5000 do host para o container.
* Define um volume local `./data` (no host) para persistir imagens.
* Cria uma rede customizada chamada `minha_rede` (driver padrão `bridge`).

---

## Passo 3: Subir tudo com Compose

No terminal, dentro da pasta com o `docker-compose.yml`:

```bash
docker compose up -d
```

Isso vai criar e conectar o serviço `registry` à rede `minha_rede`, além de expor a porta e montar o volume.

---

## Passo 4: Usar o registry (push/pull)

1. **Taguear** a imagem:

   ```bash
   docker tag minha-imagem localhost:5000/minha-imagem
   ```
2. **Fazer push**:

   ```bash
   docker push localhost:5000/minha-imagem
   ```
3. **Fazer pull**:

   ```bash
   docker pull localhost:5000/minha-imagem
   ```

A formatação `localhost:5000/…` indica que não é Docker Hub.

---

## Adicional: Autenticação (opcional)

Se quiser limitar o acesso ao registry, é possível usar **basic auth** via `htpasswd`. Exemplo no `docker-compose.yml`:

```yaml
services:
  registry:
    image: registry:2
    ports:
      - "5000:5000"
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: "Registry Realm"
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/registry.password
    volumes:
      - ./data:/data
      - ./auth:/auth
networks:
  minha_rede:
    driver: bridge
```

Nesse caso, você precisa:

```bash
sudo apt install apache2-utils
mkdir auth
htpasswd -Bc auth/registry.password usuario
```

E depois recriar o compose com `docker compose up -d --force-recreate`.

---

## Recapitulando

| Recurso               | Configuração                                         |
| --------------------- | ---------------------------------------------------- |
| Registro Docker       | `docker run` ou `docker compose up` com `registry:2` |
| Volume                | `./data:/data` via Compose                           |
| Port‑forward          | `"5000:5000"` na seção `ports`                       |
| Rede personalizada    | Definida em `networks` (ex: `minha_rede`)            |
| Basic Auth (opcional) | `htpasswd` + variáveis `REGISTRY_AUTH` no Compose    |