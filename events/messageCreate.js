import { Events } from "discord.js";

export const name = Events.MessageCreate;
export const once = false;

export async function execute(message) {
  if (message.author.bot) return;
  const channel = message.channel;

  if (channel.type !== 0) return;

  // Respond to "glorp" messages
  if (message.content.toLowerCase().includes("glorp")) {
    console.log(
      `Glorp message received from ${message.author.tag}: ${message.content}`
    );

    try {
      await message.reply("glorp");
      console.log(`Replied to message from ${message.author.tag}`);
    } catch (error) {
      console.error(
        `Error replying to message from ${message.author.tag}:`,
        error
      );
    }
  }

  // React to image attachments in #food channel
  if (channel.name === "food" && message.attachments.size > 0) {
    if (
      !message.attachments.every((attachment) =>
        attachment.contentType?.startsWith("image/")
      )
    ) {
      console.log(
        `Non-image attachment detected from ${message.author.tag} in #food channel.`
      );
    } else {
      console.log(
        `Image attachment(s) detected from ${message.author.tag} in #food channel.`
      );

      try {
        await message.react("⬆️");
        await message.react("⬇️");
        console.log(
          `Added voting reactions to message from ${message.author.tag} in #food channel.`
        );
      } catch (error) {
        console.error(
          `Error adding reactions to message from ${message.author.tag} in #food channel:`,
          error
        );
      }
    }
  }
}
