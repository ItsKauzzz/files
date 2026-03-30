import os
import random
import re

import discord
from discord import app_commands
from discord.ext import commands

TOKEN = os.getenv("DISCORD_TOKEN")

intents = discord.Intents.default()
bot = commands.Bot(command_prefix="!", intents=intents)

DICE_PATTERN = re.compile(r"^(\d+)d(\d+)$", re.IGNORECASE)


@bot.event
async def on_ready() -> None:
    synced = await bot.tree.sync()
    print(f"Bot conectado como {bot.user}.")
    print(f"{len(synced)} comando(s) sincronizado(s).")


@bot.tree.command(name="r", description="Rola um dado no formato XdY (ex.: 1d20)")
@app_commands.describe(rolagem="Formato da rolagem. Atualmente suportado: 1d20")
async def rolar(interaction: discord.Interaction, rolagem: str) -> None:
    match = DICE_PATTERN.match(rolagem.strip())
    if not match:
        await interaction.response.send_message(
            "Formato inválido. Use `/r 1d20`.",
            ephemeral=True,
        )
        return

    quantidade = int(match.group(1))
    faces = int(match.group(2))

    if quantidade != 1 or faces != 20:
        await interaction.response.send_message(
            "No momento só está habilitado `/r 1d20`.",
            ephemeral=True,
        )
        return

    resultado = random.randint(1, 20)
    await interaction.response.send_message(f"🎲 Resultado de `1d20`: **{resultado}**")


if __name__ == "__main__":
    if not TOKEN:
        raise RuntimeError(
            "Defina a variável de ambiente DISCORD_TOKEN antes de rodar o bot."
        )

    bot.run(TOKEN)
