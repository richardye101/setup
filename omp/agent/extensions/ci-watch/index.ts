import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

// ── Pure-ish helpers (usable outside omp) ────────────────────────────────────

export interface Check {
	name: string;
	bucket: string; // pass | fail | pending | skipping | cancel
	link: string;
	state: string; // e.g. IN_PROGRESS | QUEUED | PENDING | SUCCESS | FAILURE
	startedAt?: string;
}

export interface PrSnapshot {
	repo: string;
	pr: number;
	counts: Record<string, number>;
	failing: Check[]; // non-ignored fail/cancel
	pending: number; // non-ignored pending
	running: number; // non-ignored pending that have started
	oldestStart?: number; // ms epoch of the oldest still-running check
	noChecks: boolean;
}

const LOG_LINES = 20;
const MAX_DELAY_MS = 5 * 60_000;
const TICK_MS = 5_000;

export async function gh(args: string[], cwd?: string): Promise<{ code: number; stdout: string; stderr: string }> {
	const proc = Bun.spawn(["gh", ...args], {
		cwd,
		stdout: "pipe",
		stderr: "pipe",
		env: { ...process.env, GH_PROMPT_DISABLED: "1", NO_COLOR: "1" },
	});
	const [stdout, stderr, code] = await Promise.all([
		new Response(proc.stdout).text(),
		new Response(proc.stderr).text(),
		proc.exited,
	]);
	return { code, stdout, stderr };
}

export async function defaultRepo(cwd: string): Promise<string> {
	const r = await gh(["repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"], cwd);
	const repo = r.stdout.trim();
	if (r.code !== 0 || !repo) throw new Error(`cannot determine repo in ${cwd}: ${r.stderr.trim()}`);
	return repo;
}

/** Parse "3864", "#3864" or a PR URL into {repo, pr}. */
export function parsePr(ref: string | number, fallbackRepo?: string): { repo: string; pr: number } {
	const s = String(ref).trim();
	const url = s.match(/github\.com\/([^/]+\/[^/]+)\/pull\/(\d+)/);
	if (url) return { repo: url[1], pr: Number(url[2]) };
	const n = s.match(/^#?(\d+)$/);
	if (!n) throw new Error(`not a PR number or URL: ${s}`);
	if (!fallbackRepo) throw new Error(`no repo for PR ${s}`);
	return { repo: fallbackRepo, pr: Number(n[1]) };
}

// gh exits non-zero when checks fail or are pending, so trust stdout JSON, not the exit code.
export async function fetchChecks(repo: string, pr: number): Promise<Check[] | null> {
	const r = await gh(["pr", "checks", String(pr), "--repo", repo, "--json", "name,bucket,link,state,startedAt"]);
	if (/no checks reported/i.test(r.stderr)) return null;
	try {
		return JSON.parse(r.stdout) as Check[];
	} catch {
		throw new Error(`gh pr checks ${pr} failed (exit ${r.code}): ${r.stderr.trim() || r.stdout.trim()}`);
	}
}

export function summarize(repo: string, pr: number, checks: Check[] | null, ignore: Set<string>): PrSnapshot {
	const counts: Record<string, number> = {};
	const failing: Check[] = [];
	let pending = 0;
	let running = 0;
	let oldestStart: number | undefined;
	for (const c of checks ?? []) {
		const bucket = ignore.has(c.name) ? "ignored" : c.bucket;
		counts[bucket] = (counts[bucket] ?? 0) + 1;
		if (bucket === "ignored") continue;
		if (c.bucket === "fail" || c.bucket === "cancel") failing.push(c);
		else if (c.bucket === "pending") {
			pending++;
			const t = c.startedAt ? Date.parse(c.startedAt) : NaN;
			// Not-yet-started checks report state QUEUED/PENDING and a zero startedAt (year 1).
			if (c.state === "IN_PROGRESS" && t > 0) {
				running++;
				oldestStart = Math.min(oldestStart ?? t, t);
			}
		}
	}
	return { repo, pr, counts, failing, pending, running, oldestStart, noChecks: checks === null };
}

export async function snapshot(repo: string, pr: number, ignore: Set<string>): Promise<PrSnapshot> {
	return summarize(repo, pr, await fetchChecks(repo, pr), ignore);
}

export const isSettled = (s: PrSnapshot) => !s.noChecks && s.pending === 0;

const TS_PREFIX = /^\uFEFF?\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?Z ?/;

/** Last `n` lines of a failed Actions job log, timestamps and ANSI stripped. */
export async function failedLogTail(repo: string, link: string, n = LOG_LINES): Promise<string | undefined> {
	const m = link.match(/\/runs\/(\d+)\/job\/(\d+)/);
	if (!m) return undefined;
	let r = await gh(["run", "view", m[1], "--repo", repo, "--job", m[2], "--log-failed"]);
	let lines = r.code === 0 ? r.stdout.split("\n").map(l => l.replace(/^[^\t]*\t[^\t]*\t/, "")) : [];
	if (!lines.some(l => l.trim())) {
		// --log-failed refuses while other jobs of the run are still in progress; the job log API does not.
		r = await gh(["api", "--allow-escape-sequences", `repos/${repo}/actions/jobs/${m[2]}/logs`]);
		lines = r.code === 0 ? r.stdout.split("\n") : [];
		// The full job log ends with post-job cleanup; end the tail at the last error instead.
		const lastError = lines.findLastIndex(l => l.includes("##[error]"));
		if (lastError >= 0) lines = lines.slice(0, lastError + 1);
	}
	const clean = lines
		.map(l => l.replace(TS_PREFIX, "").replace(/\x1b\[[0-9;]*m/g, "").trimEnd())
		.filter(l => l && !l.startsWith("##[endgroup]"));
	return clean.length ? clean.slice(-n).join("\n") : undefined;
}

export function countsLine(s: PrSnapshot): string {
	if (s.noChecks) return "no checks reported yet";
	const order = ["pass", "fail", "cancel", "pending", "skipping", "ignored"];
	return order.filter(b => s.counts[b]).map(b => `${s.counts[b]} ${b}`).join(" · ") || "0 checks";
}

export async function describeFailures(repo: string, failures: Check[]): Promise<string> {
	const parts = await Promise.all(
		failures.map(async c => {
			const tail = await failedLogTail(repo, c.link).catch(() => undefined);
			const head = `  ✗ ${c.name} (${c.bucket}) — ${c.link}`;
			return tail ? `${head}\n    \`\`\`\n${tail.replace(/^/gm, "    ")}\n    \`\`\`` : head;
		}),
	);
	return parts.join("\n");
}

export function formatSnapshot(s: PrSnapshot): string {
	const state = s.failing.length ? "✗ failing" : isSettled(s) ? "✓ settled" : "… pending";
	const fails = s.failing.length ? `\n  failing: ${s.failing.map(c => c.name).join(", ")}` : "";
	return `${s.repo}#${s.pr}: ${state} (${countsLine(s)})${fails}`;
}

export interface PrMeta {
	state: string; // OPEN | MERGED | CLOSED
	base: string;
	review: string; // APPROVED | REVIEW_REQUIRED | CHANGES_REQUESTED | ""
}

export async function fetchMeta(repo: string, pr: number): Promise<PrMeta> {
	const r = await gh(["pr", "view", String(pr), "--repo", repo, "--json", "state,baseRefName,reviewDecision"]);
	if (r.code !== 0) throw new Error(`gh pr view ${pr} failed: ${r.stderr.trim()}`);
	const j = JSON.parse(r.stdout) as { state: string; baseRefName: string; reviewDecision?: string };
	return { state: j.state, base: j.baseRefName || "dev", review: j.reviewDecision ?? "" };
}

/** PR number → queue position for the merge queue of `repo`'s `branch`. */
export async function fetchQueue(repo: string, branch: string): Promise<Map<number, number>> {
	const [o, n] = repo.split("/");
	const query = `query($o:String!,$n:String!,$b:String!){repository(owner:$o,name:$n){mergeQueue(branch:$b){entries(first:50){nodes{position pullRequest{number}}}}}}`;
	const r = await gh(["api", "graphql", "-f", `query=${query}`, "-f", `o=${o}`, "-f", `n=${n}`, "-f", `b=${branch}`]);
	if (r.code !== 0) throw new Error(`merge queue query failed: ${r.stderr.trim()}`);
	const nodes = JSON.parse(r.stdout).data?.repository?.mergeQueue?.entries?.nodes ?? [];
	return new Map(nodes.map((e: { position: number; pullRequest: { number: number } }) => [e.pullRequest.number, e.position]));
}

export async function queueRemovalReason(repo: string, pr: number): Promise<string | undefined> {
	const [o, n] = repo.split("/");
	const query = `query($o:String!,$n:String!,$p:Int!){repository(owner:$o,name:$n){pullRequest(number:$p){timelineItems(last:1,itemTypes:[REMOVED_FROM_MERGE_QUEUE_EVENT]){nodes{... on RemovedFromMergeQueueEvent{reason}}}}}}`;
	const r = await gh(["api", "graphql", "-f", `query=${query}`, "-f", `o=${o}`, "-f", `n=${n}`, "-F", `p=${pr}`]);
	if (r.code !== 0) return undefined;
	return JSON.parse(r.stdout).data?.repository?.pullRequest?.timelineItems?.nodes?.[0]?.reason || undefined;
}

type Fg = (color: string, text: string) => string;

export interface PanelRow {
	pr: number;
	snap: PrSnapshot;
	state: string;
	review: string;
	queuePos?: number;
	queueLen?: number;
}

const BAR = 20;
const MAX_LINES = 10; // the widget truncates string arrays past 10 lines
const REVIEW: Record<string, [string, string]> = {
	APPROVED: ["success", "approved"],
	REVIEW_REQUIRED: ["warning", "review needed"],
	CHANGES_REQUESTED: ["error", "changes requested"],
};

export function elapsed(ms: number): string {
	const m = Math.floor(ms / 60_000);
	return m < 1 ? `${Math.max(0, Math.floor(ms / 1000))}s` : m < 60 ? `${m}m` : `${Math.floor(m / 60)}h${m % 60}m`;
}

/** 20-cell bar: passed+skipped █ green, failed █ red, running ▒ yellow, not started ░ dim. Ignored checks excluded. */
export function progressBar(s: PrSnapshot, fg: Fg): { bar: string; done: number; total: number } {
	const c = s.counts;
	const segs: [number, string, string][] = [
		[(c.pass ?? 0) + (c.skipping ?? 0), "success", "█"],
		[s.failing.length, "error", "█"],
		[s.running, "warning", "▒"],
		[s.pending - s.running, "dim", "░"],
	];
	const total = segs.reduce((a, [n]) => a + n, 0);
	if (!total) return { bar: fg("dim", "░".repeat(BAR)), done: 0, total: 0 };
	// Every non-empty segment gets at least one cell; rounding overflow comes out of the largest.
	const cells = segs.map(([n]) => (n ? Math.max(1, Math.round((n / total) * BAR)) : 0));
	let diff = BAR - cells.reduce((a, b) => a + b, 0);
	while (diff) {
		const i = cells.indexOf(Math.max(...cells));
		cells[i] += Math.sign(diff);
		diff -= Math.sign(diff);
	}
	const bar = segs.map(([, color, ch], i) => (cells[i] ? fg(color, ch.repeat(cells[i])) : "")).join("");
	return { bar, done: total - s.pending, total };
}

/** Header plus one aligned row per PR (max 8); a dim failure line under failing rows while lines remain. */
export function panelLines(rows: PanelRow[], fg: Fg, header: string, now = Date.now()): string[] {
	rows = rows.slice(0, 8);
	type Cell = { text: string; w: number };
	const cell = (plain: string, color?: string): Cell => ({ text: color ? fg(color, plain) : plain, w: plain.length });
	const table = rows.map(({ pr, snap: s, state, review, queuePos, queueLen }) => {
		const [color, word] =
			state === "MERGED" ? ["success", "merged"]
			: s.failing.length ? ["error", "failing"]
			: s.noChecks ? ["warning", "waiting"]
			: s.pending ? ["warning", "running"]
			: ["success", "passing"];
		const { bar, done, total } = progressBar(s, fg);
		const rv = state === "MERGED" ? undefined : REVIEW[review];
		return [
			{ text: `${fg(color, "●")} #${pr}`, w: 3 + String(pr).length },
			cell(word, color),
			{ text: bar, w: BAR },
			cell(`${done}/${total}`),
			rv ? cell(rv[1], rv[0]) : cell(""),
			queuePos !== undefined ? cell(`queue ${queuePos}/${queueLen ?? "?"}`, "accent") : cell(""),
			s.oldestStart && s.running ? cell(elapsed(now - s.oldestStart), "muted") : cell(""),
		];
	});
	const widths = table[0]?.map((_, i) => Math.max(...table.map(r => r[i].w))) ?? [];
	const out = [fg("dim", header)];
	let spare = MAX_LINES - 1 - rows.length;
	table.forEach((r, i) => {
		const line = r.map((c, j) => (widths[j] ? c.text + " ".repeat(widths[j] - c.w) : "")).filter((_, j) => widths[j]);
		out.push(line.join("  ").trimEnd());
		const failing = rows[i].snap.failing;
		if (failing.length && rows[i].state !== "MERGED" && spare-- > 0) {
			const more = failing.length > 1 ? `  +${failing.length - 1} more` : "";
			out.push(fg("dim", `${" ".repeat(widths[0] + 2)}↳ ${failing[0].name}${more}`));
		}
	});
	return out;
}

// ── Extension ────────────────────────────────────────────────────────────────

interface Watch {
	repo: string;
	pr: number;
	ignore: Set<string>;
	reported: Set<string>; // failing check names already announced
	last: PrSnapshot;
	state: string;
	base: string;
	review: string;
	queuePos?: number;
	queueLen?: number;
}

export default function ciWatch(pi: ExtensionAPI): void {
	const z = pi.zod;
	pi.setLabel("CI watch");

	// Per-session state (factories are rebound per session); survives compaction.
	const watches = new Map<string, Watch>();
	let ticker: unknown;
	let tickerCtx: ExtensionContext | undefined;
	let baseMs = 60_000;
	let delayMs = baseMs;
	let nextAt = 0;
	let busy = false;
	let lastReport = "";
	let settledAnnounced = false;
	let updatedAt = 0;

	function updateWidget(): void {
		if (!tickerCtx) return;
		const ui = tickerCtx.ui as typeof tickerCtx.ui & { theme?: { fg?: Fg } };
		if (!watches.size) return ui.setWidget("ci-watch", undefined);
		const fg: Fg = (c, t) => {
			try {
				return ui.theme?.fg ? ui.theme.fg(c, t) : t;
			} catch {
				return t;
			}
		};
		const repos = [...new Set([...watches.values()].map(w => w.repo))].join(", ");
		const ago = updatedAt ? ` · updated ${elapsed(Date.now() - updatedAt)} ago` : "";
		const rows = [...watches.values()].map(w => ({ pr: w.pr, snap: w.last, state: w.state, review: w.review, queuePos: w.queuePos, queueLen: w.queueLen }));
		ui.setWidget("ci-watch", panelLines(rows, fg, `CI · ${repos}${ago}`), { placement: "belowEditor" });
	}

	function updateStatus(): void {
		if (!tickerCtx) return;
		if (!watches.size) return tickerCtx.ui.setStatus("ci", undefined);
		let pending = 0;
		let failing = 0;
		for (const w of watches.values()) {
			pending += w.last.pending;
			failing += w.last.failing.length;
		}
		tickerCtx.ui.setStatus("ci", `CI: ${pending} pending · ${failing} failing`);
		updateWidget();
	}

	function stop(prs?: string[]): string[] {
		const removed: string[] = [];
		for (const [k, w] of watches) {
			if (!prs?.length || prs.some(p => k === p || String(w.pr) === p.replace(/^#/, "") || p.endsWith(`/pull/${w.pr}`))) {
				watches.delete(k);
				removed.push(k);
			}
		}
		if (!watches.size && ticker && tickerCtx) {
			tickerCtx.clearTimer(ticker as never);
			ticker = undefined;
		}
		updateStatus();
		return removed;
	}

	function send(text: string, wake: boolean): void {
		if (text === lastReport) return;
		lastReport = text;
		pi.sendMessage(
			{ customType: "ci-watch", content: text, display: true },
			wake ? { triggerTurn: true, deliverAs: "followUp" } : {},
		);
	}

	async function poll(): Promise<void> {
		if (busy || !watches.size) return;
		if (Date.now() < nextAt) return updateWidget(); // refresh "updated Ns ago"
		busy = true;
		try {
			const sections: string[] = [];
			let wake = false;
			let errors = 0;
			const queues = new Map<string, Map<number, number> | null>();
			for (const [key, w] of watches) {
				try {
					if (w.state === "MERGED") {
						watches.delete(key); // merged rows stay visible for one poll
						continue;
					}
					const meta = await fetchMeta(w.repo, w.pr);
					w.base = meta.base;
					w.review = meta.review;
					if (meta.state === "MERGED") {
						w.state = meta.state;
						w.queuePos = undefined;
						send(`#${w.pr} merged.`, false);
						continue;
					}
					if (meta.state !== "OPEN") {
						watches.delete(key);
						sections.push(`#${w.pr} was closed without merging — no longer watched.`);
						continue;
					}
					const qk = `${w.repo}@${w.base}`;
					if (!queues.has(qk)) queues.set(qk, await fetchQueue(w.repo, w.base).catch(() => null));
					const queue = queues.get(qk);
					if (queue) {
						const pos = queue.get(w.pr);
						if (w.queuePos !== undefined && pos === undefined) {
							const reason = await queueRemovalReason(w.repo, w.pr).catch(() => undefined);
							sections.push(`#${w.pr} left the merge queue${reason ? `: ${reason}` : ""}`);
							wake = true;
						}
						w.queuePos = pos;
						w.queueLen = queue.size;
					}
				} catch (err) {
					errors++;
					pi.logger?.warn?.(`ci-watch: ${String(err)}`);
					continue;
				}
				let snap: PrSnapshot;
				try {
					snap = await snapshot(w.repo, w.pr, w.ignore);
				} catch (err) {
					errors++;
					pi.logger?.warn?.(`ci-watch: ${String(err)}`);
					continue;
				}
				w.last = snap;
				const now = new Set(snap.failing.map(c => c.name));
				const fresh = snap.failing.filter(c => !w.reported.has(c.name));
				const recovered = [...w.reported].filter(n => !now.has(n));
				w.reported = now;
				if (!fresh.length && !recovered.length) continue;
				wake ||= fresh.length > 0;
				let section = `${formatSnapshot(snap)}`;
				if (fresh.length) section += `\n  new failures:\n${await describeFailures(w.repo, fresh)}`;
				if (recovered.length) section += `\n  no longer failing: ${recovered.join(", ")}`;
				sections.push(section);
			}
			updatedAt = Date.now();
			delayMs = errors ? Math.min(delayMs * 2, MAX_DELAY_MS) : baseMs;
			nextAt = Date.now() + delayMs;
			const allSettled = [...watches.values()].every(w => isSettled(w.last));
			if (!errors && watches.size && allSettled && !settledAnnounced) {
				const all = [...watches.values()].map(w => formatSnapshot(w.last)).join("\n");
				sections.push(`All watched PRs settled — still watching until merged (/ci stop to end).\n${all}`);
				wake = true;
			}
			settledAnnounced = allSettled;
			if (sections.length) send(`CI watch update\n${sections.join("\n\n")}`, wake);
			if (!watches.size) stop();
			updateStatus();
		} catch (err) {
			pi.logger?.warn?.(`ci-watch: ${String(err)}`);
		} finally {
			busy = false;
		}
	}

	/** Register a watch; returns the text snapshot. Merged/closed PRs are reported but not watched. */
	async function start(
		ctx: ExtensionContext,
		refs: string[],
		opts: { repo?: string; ignore?: string[]; intervalSeconds?: number },
	): Promise<string> {
		if (!refs.length) throw new Error("no PRs given");
		const fallback = opts.repo ?? (refs.every(r => /github\.com\//.test(r)) ? undefined : await defaultRepo(ctx.cwd));
		const ignore = new Set(opts.ignore ?? []);
		const lines: string[] = [];
		for (const ref of refs) {
			const { repo, pr } = parsePr(ref, fallback);
			const [snap, meta] = await Promise.all([snapshot(repo, pr, ignore), fetchMeta(repo, pr)]);
			let line = formatSnapshot(snap);
			if (snap.failing.length) line += `\n${await describeFailures(repo, snap.failing)}`;
			if (meta.state !== "OPEN") line += `\n  (${meta.state.toLowerCase()} — not watched)`;
			// Merged PRs get a panel row until the next poll; closed ones none.
			if (meta.state !== "CLOSED") {
				const w: Watch = { repo, pr, ignore, reported: new Set(snap.failing.map(c => c.name)), last: snap, state: meta.state, base: meta.base, review: meta.review };
				watches.set(`${repo}#${pr}`, w);
			}
			lines.push(line);
		}
		settledAnnounced = [...watches.values()].every(w => isSettled(w.last));
		updatedAt = Date.now();
		baseMs = Math.max(15, opts.intervalSeconds ?? 60) * 1000;
		delayMs = baseMs;
		lastReport = "";
		nextAt = Date.now(); // first poll fetches queue positions
		tickerCtx = ctx;
		if (watches.size && !ticker) ticker = ctx.setInterval(poll, TICK_MS);
		updateStatus();
		const watching = watches.size ? `Watching ${[...watches.keys()].join(", ")} every ${baseMs / 1000}s until merged; you will be notified of new failures, settling, and merge-queue changes.` : "Nothing left to watch.";
		return `${lines.join("\n")}\n\n${watching}`;
	}

	pi.on("session_shutdown", () => {
		ticker = undefined; // cleared by the runtime
	});

	pi.registerTool({
		name: "ci_watch",
		label: "CI Watch",
		description:
			"Watch GitHub CI checks for pull requests in the background. Returns the current snapshot immediately; later, a message is injected when a PR gets new failing checks (with log tails) or when all watched PRs have no pending checks. Do not poll CI yourself after calling this.",
		approval: "read",
		parameters: z.object({
			prs: z.array(z.string()).describe('PR numbers (e.g. "3864") or PR URLs'),
			repo: z.string().optional().describe("owner/name; default: repo of the current directory"),
			ignore: z.array(z.string()).optional().describe('Check names treated as non-blocking, e.g. ["SonarQube scan"]'),
			interval_seconds: z.number().optional().describe("Poll interval (default 60, min 15)"),
		}),
		async execute(_id, params, _signal, _onUpdate, ctx) {
			const text = await start(ctx, params.prs.map(String), {
				repo: params.repo,
				ignore: params.ignore,
				intervalSeconds: params.interval_seconds,
			});
			return { content: [{ type: "text", text }], details: { watching: [...watches.keys()] } };
		},
	});

	pi.registerTool({
		name: "ci_unwatch",
		label: "CI Unwatch",
		description: "Stop watching CI for the given PRs (numbers or URLs), or all PRs when none given.",
		approval: "read",
		parameters: z.object({ prs: z.array(z.string()).optional().describe("PRs to stop watching; omit for all") }),
		async execute(_id, params) {
			const removed = stop(params.prs?.map(String));
			const text = removed.length ? `Stopped watching ${removed.join(", ")}.` : "No matching watches.";
			return { content: [{ type: "text", text }], details: { removed } };
		},
	});

	pi.registerCommand("ci", {
		description: "CI watch: /ci (status) · /ci stop · /ci <pr...> [--repo o/r] [--ignore \"Check name\"]",
		handler: async (args, ctx) => {
			const tokens = (args.match(/"[^"]*"|'[^']*'|\S+/g) ?? []).map(t => t.replace(/^(["'])(.*)\1$/, "$2"));
			if (!tokens.length) {
				const eta = Math.max(0, Math.round((nextAt - Date.now()) / 1000));
				const table = [...watches.values()].map(w => formatSnapshot(w.last)).join("\n");
				return ctx.ui.notify(watches.size ? `${table}\nnext poll in ${eta}s` : "CI watch: nothing being watched.", "info");
			}
			if (tokens[0] === "stop") {
				const removed = stop(tokens.slice(1));
				return ctx.ui.notify(removed.length ? `Stopped watching ${removed.join(", ")}` : "No matching watches", "info");
			}
			const refs: string[] = [];
			const ignore: string[] = [];
			let repo: string | undefined;
			for (let i = 0; i < tokens.length; i++) {
				if (tokens[i] === "--ignore") ignore.push(tokens[++i] ?? "");
				else if (tokens[i] === "--repo") repo = tokens[++i];
				else refs.push(tokens[i]);
			}
			try {
				const text = await start(ctx, refs, { repo, ignore: ignore.filter(Boolean) });
				pi.sendMessage({ customType: "ci-watch", content: `CI watch started\n${text}`, display: true }, {});
			} catch (err) {
				ctx.ui.notify(`ci-watch: ${err instanceof Error ? err.message : String(err)}`, "error");
			}
		},
	});
}
