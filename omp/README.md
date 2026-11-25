# omp Setup

> **TEMPORARY: CHECK THIS ON THE SECOND COMPUTER**
>
> This document records the behavior observed on Richard's current Mac and the
> settings believed to produce it. The GPT 6 Luna behavior has not been checked
> against that computer's model catalog or provider responses. Do not treat the
> explanation below as confirmed until the verification checklist passes.

## What This Setup Changes

This repository does not contain a patched or rebuilt omp binary. Install omp
from its normal distribution before running `setup_omp.sh`.

The setup changes omp through files copied into `~/.omp/agent/`:

| File | Purpose |
|---|---|
| `config.yml` | Models, thinking display, transcript display, compaction and other omp settings |
| `extensions/compact-tool-cards.ts` | Displays model tool calls using omp's compact transcript presenter |
| `extensions/ci-watch/index.ts` | Adds CI monitoring behavior |
| `themes/titanium-prompts.json` | Controls transcript, thinking, tool and status-line colors |
| `RULES.md` | Instructions applied to agent behavior |
| `models.yml` | Registers the local AIOS model providers |
| `mcp.json` | Registers MCP servers; the GitHub token is deliberately not stored in this repository |

The Rex composer and `ompa` launcher are separate. They live under `rex/` and
are installed by `setup_rex.sh`.

## Install

Install omp, clone this repository and run:

```bash
./setup_omp.sh
```

The script copies `omp/agent/` to `~/.omp/agent/`.

After installation:

1. Start omp and sign in to each provider you use.
2. Replace `REPLACE_WITH_GITHUB_PAT` in `~/.omp/agent/mcp.json` with the GitHub
   token for that computer.
3. Start the AIOS loopback proxy on port 4019 before using either `aios-agent`
   provider from `models.yml`.
4. Restart existing omp sessions. A running session can retain settings and
   extensions loaded before these files were installed.

Credentials are not in this repository. `omp auth export` produces sensitive
credential material and its output must not be committed.

## Thinking Display

These are the settings involved in thinking display:

```yaml
defaultThinkingLevel: auto
hideThinkingBlock: false
expandThinkingBlocks: false
proseOnlyThinking: true
```

Their current omp meanings are:

| Setting | Meaning |
|---|---|
| `defaultThinkingLevel: auto` | Lets omp choose a supported thinking level for the selected model. It does not guarantee that the provider returns displayable thinking text. |
| `hideThinkingBlock: false` | Allows thinking blocks returned by the provider to appear in the TUI. |
| `expandThinkingBlocks: false` | Shows thinking while the model is working, then collapses finished thinking to its heading. Set it to `true` if completed thinking must remain expanded. |
| `proseOnlyThinking: true` | Keeps prose in thinking summaries but replaces code blocks with an ellipsis. |

To keep completed thinking expanded on the second computer:

```bash
omp config set hideThinkingBlock false
omp config set expandThinkingBlocks true
omp config set proseOnlyThinking true
```

To reproduce the current Mac exactly, use `false` for
`expandThinkingBlocks`. The practical difference must be checked before making
the repository default permanent.

Print mode has a separate flag. Use `--print-thoughts` when thinking should be
included in output from `omp -p`:

```bash
omp -p --print-thoughts --thinking high --model '<provider/model>' \
  'Explain your approach before answering.'
```

The following command-line options can override or defeat the configuration:

- `--hide-thinking` hides thinking in the TUI.
- `--thinking off` disables model thinking.
- `--no-extensions` prevents the custom transcript presenter from loading.
- `--no-tools` disables tools entirely.

## Why A Model May Show Only Thinking Headings

omp can display only the information returned by the selected model and its
provider. A model may reason internally while exposing only one or more of:

- a progress heading;
- a short reasoning summary;
- a reasoning-token count;
- encrypted reasoning state used for later turns;
- no displayable reasoning content.

Display configuration cannot recover private chain-of-thought that a provider
does not send. Therefore, seeing full thinking with Claude and headings only
with GPT 6 Luna under the same configuration would point to a model or provider
capability difference, not necessarily a broken omp installation.

`defaultThinkingLevel: auto` is another variable. The model registration may
support reasoning but cause `auto` to select a different level. Test with an
explicit supported level before concluding that the display is broken.

## Check GPT 6 Luna's Registration

Run this on the computer where Luna is available:

```bash
omp models --json | jq '
  .models[]
  | select(
      ((.id // "") | ascii_downcase | contains("luna")) or
      ((.name // "") | ascii_downcase | contains("luna")) or
      ((.selector // "") | ascii_downcase | contains("luna"))
    )
  | {
      provider,
      id,
      selector,
      name,
      reasoning,
      thinking,
      contextWindow,
      maxTokens
    }
'
```

Interpret the important fields carefully:

| Result | Interpretation |
|---|---|
| `reasoning: false` | omp's model catalog considers the model non-reasoning. Thinking settings will not create thinking output. |
| `reasoning: true`, `thinking: null` | The model is marked as reasoning-capable, but no selectable thinking levels are registered. It may expose summaries or no visible reasoning. |
| `reasoning: true`, `thinking: ["low", ...]` | omp can request one of the listed levels. This still does not prove that the provider returns raw thinking text. |
| No matching row | Luna is registered under another name, provided by an extension not loaded by this command, or unavailable in the current provider catalog. Run `omp models` and identify its exact selector. |

Do not request a level absent from the model's `thinking` list. Select one of
the reported levels for the comparison test.

## Controlled Thinking Comparison

Use the same prompt, terminal, omp version and display settings for Luna and a
model known to return visible thinking. Start new sessions so an old session's
state does not affect the result.

First record the installed version and effective settings:

```bash
omp --version
omp config get defaultThinkingLevel
omp config get hideThinkingBlock
omp config get expandThinkingBlocks
omp config get proseOnlyThinking
```

Then run both models in the TUI with an explicit thinking level:

```bash
omp --model '<luna-selector>' --thinking high
omp --model '<comparison-selector>' --thinking high
```

Give each model the same prompt:

```text
Compare two implementation approaches for an LRU cache, reason through the
trade-offs, and then recommend one.
```

Record separately:

1. Whether thinking prose appears while the response streams.
2. Whether only a heading or progress label appears.
3. Whether the thinking prose collapses when the turn finishes.
4. Whether expanding the finished block reveals prose.
5. Whether `expandThinkingBlocks: true` changes the finished transcript.

If the comparison model shows prose and Luna does not, while all settings are
identical, classify Luna's behavior as a model/provider limitation. If neither
model shows prose, inspect the effective config and launch flags before blaming
either model.

## Tool And Command Presentation

These settings make tool activity visible and allow custom transcript
presenters:

```yaml
display:
  hideToolActivity: false
  shellVisualization: true

extensionRenderers:
  transcriptPresenters: true
```

Their current omp meanings are:

| Setting | Meaning |
|---|---|
| `display.hideToolActivity: false` | Shows model-initiated tool calls and their results in the transcript. |
| `display.shellVisualization: true` | Shows shell commands using omp's interactive execution visualization instead of plain shell command output. |
| `extensionRenderers.transcriptPresenters: true` | Allows extensions to choose full, compact or hidden transcript presentation without changing session data, exports or model context. |

The compact tool-card behavior comes from
`extensions/compact-tool-cards.ts`:

```ts
pi.registerTranscriptPresenter(block =>
  block.type === "toolCall" ? "compact" : undefined
);
```

This asks omp to display every `toolCall` block as a compact row. It does not
change the tool request, result, saved session or information sent back to the
model.

Check that the extension exists after installation:

```bash
test -f ~/.omp/agent/extensions/compact-tool-cards.ts &&
  echo "compact tool cards installed"
```

Check the effective settings:

```bash
omp config get display.hideToolActivity
omp config get display.shellVisualization
omp config get extensionRenderers.transcriptPresenters
```

Expected values:

```text
false
true
true
```

Start omp normally, without `--no-extensions`, and ask it to run a harmless
command such as:

```text
Run pwd and tell me the current directory.
```

The transcript should show a compact tool row, and the shell command should use
the interactive shell visualization.

## Known Export Mismatch

At the time this temporary document was written:

- The current Mac reported `display.shellVisualization: true`.
- The committed `omp/agent/config.yml` reported
  `display.shellVisualization: false`.

That difference explains why shell commands can look different after installing
from this repository. Do not silently choose one value. Verify the desired
appearance on the second computer, then update `omp/agent/config.yml` to the
chosen value.

The current Mac also used `expandThinkingBlocks: false`, which intentionally
collapses finished thinking. If the requirement is to keep all completed
thinking visible, the repository default should become `true` after the
comparison.

## Full Diagnostic Snapshot

Run this on both computers and compare the output:

```bash
printf '%s\n' \
  "omp version: $(omp --version)" \
  "config path: $(omp config path)"

for key in \
  defaultThinkingLevel \
  hideThinkingBlock \
  expandThinkingBlocks \
  proseOnlyThinking \
  display.hideToolActivity \
  display.shellVisualization \
  extensionRenderers.transcriptPresenters
do
  printf '%s: ' "$key"
  omp config get "$key"
done

printf '%s\n' "extensions:"
find ~/.omp/agent/extensions -maxdepth 2 -type f -print | sort
```

Also compare the selected model's catalog row using the Luna query above. Two
computers can have identical config files but behave differently because they
have different omp versions, provider catalogs, extensions, model selectors or
provider response formats.

## Verification Checklist

Before removing the temporary warning:

- [ ] Run `setup_omp.sh` on the second computer.
- [ ] Confirm the second computer loads `compact-tool-cards.ts`.
- [ ] Confirm tool activity is visible.
- [ ] Confirm shell commands use the preferred plain or interactive rendering.
- [ ] Record Luna's exact provider, selector, `reasoning` value and `thinking`
      levels.
- [ ] Compare Luna with one known reasoning model using the same prompt and
      explicit thinking level.
- [ ] Decide whether completed thinking should collapse or remain expanded.
- [ ] Update `omp/agent/config.yml` with the chosen
      `display.shellVisualization` value.
- [ ] Update `omp/agent/config.yml` with the chosen
      `expandThinkingBlocks` value.
- [ ] Re-run the full diagnostic snapshot and confirm both machines match.
- [ ] Replace this warning with the date, omp version and models actually
      checked.

Until this checklist is complete, the statement that GPT 6 Luna does not expose
displayable thinking remains an inference.
