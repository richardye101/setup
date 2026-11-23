import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function compactToolCards(pi: ExtensionAPI): void {
	pi.setLabel("Compact tool cards");
	pi.registerTranscriptPresenter(block => (block.type === "toolCall" ? "compact" : undefined));
}
