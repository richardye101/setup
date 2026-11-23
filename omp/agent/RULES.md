# Frontend design

When a task designs, builds, changes or reviews a user interface (screens, components, dialogs, layout, styling, copy on screen), read and use these skills before writing code and again before showing the result:

- `impeccable`: its critique and audit before handing over a screen, and its polish pass on what you changed.
- `better-ui`: exact values for radius, alignment, shadows, icons and motion. Check nested rounded corners, sticky headers and anything that clips or overflows.
- `frontend-design`: only for a new screen or a new visual direction.
- `interface-review`: on the branch's interface changes before reporting them done.

In an app with its own design system, such as Control Tower's ZDS, the design system's rules win wherever a skill disagrees. Before changing a pattern the app already has, find how it's done elsewhere in the app (including on dev) and reuse it. Check the result in a real browser, scrolled and unscrolled, light and dark, and look at the screenshots yourself before telling Richard it's done.

# Skills

Use the installed skills on every task and say which one you're using. Ponytail applies to all coding work. Before building a feature or changing behaviour, use superpowers' brainstorming to settle the design with Richard, then writing-plans for the plan. For bugs, use systematic-debugging. Before saying work is done, use verification-before-completion. For a change review, use ponytail-review.

# Less is more

Richard prefers the smallest design that does the job. Before building, ask what the system can do on its own with what it already has. Prefer an existing worker, table or flow over a new tool, prompt rule or approval step. Leave a step out unless a person or agent would be stuck without it. Skip optional extras unless he asks for them, and keep updates to him short. When a plan grows, stop and look for a smaller one before carrying on.

When running an agent, give it a short brief, the narrowest checks and a fast model. Don't restart it with new rules unless the change is worth the time it costs.

When talking to Richard, describe what something does for people and agents in plain words. Leave out file names, function names, table names, commit hashes and line counts unless he asks for them.

# Copy on screen, in docs and in commits

Richard rejects text that sounds like an AI wrote it. Write the way you would explain it to a coworker, in plain full sentences.

- No "Noun Every Noun Needs", "What X Knows", "Everything Y Gets" or any label built as a slogan. Name the thing: "Required Fields".
- No "X, not Y" contrast setups, no clipped fragments that trail a sentence ("..., and the record says so"), no lists of three for rhythm, no em-dash asides, no middle-dot meta strings.
- No sentence that praises or pitches the feature ("Every workspace that reads a domain gets it"). Say what the person can do or what happens next.
- Titles, field labels and buttons are Title Case. Helper text is one plain sentence, and only where a person would be stuck without it.
- Examples in placeholders and helper text differ from each other and come from the bank's own work.
- Before showing copy, read every string out loud once. If it sounds like a slogan, rewrite it.
