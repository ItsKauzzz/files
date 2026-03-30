# Discord D20 Bot

Bot simples de Discord com **slash command** `/r` para rolar **1d20**.

## Requisitos

- Python 3.10+
- Um bot criado no [Discord Developer Portal](https://discord.com/developers/applications)

## Instalação

```bash
cd discord-d20-bot
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Configuração

1. Copie o arquivo de exemplo:

```bash
cp .env.example .env
```

2. Defina o token na variável de ambiente `DISCORD_TOKEN`.

Exemplo (Linux/macOS):

```bash
export DISCORD_TOKEN="seu_token"
```

## Rodando o bot

```bash
python bot.py
```

Ao entrar no Discord, use:

- `/r 1d20`

O bot responderá com um número aleatório de 1 a 20.

## Observação de segurança

Se um token foi compartilhado em local público, **revogue/regere** imediatamente no Discord Developer Portal e passe a usar o novo token.
