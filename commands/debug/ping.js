import { SlashCommandBuilder } from "discord.js";

export const data = new SlashCommandBuilder()
  .setName("ping")
  .setDescription("Pings the user.");

export async function execute(interaction) {
  await interaction.reply("glorp");
}
