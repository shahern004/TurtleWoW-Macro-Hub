# GitHub Repository Study: Extract Implementation Patterns

## Context
I'm building a ${project_description:combat automation system} using these dependencies:
${dependency_list}

My current approach is ${current_approach:macro-based}, but I'm open to discovering
that a different approach is superior. Analyze the target repo on its own terms first,
then help me evaluate what to adopt.

## Target Repository
**${repo_name}** (${repo_url})
${repo_description:A working system using the same or overlapping dependency stack.}

## Task
Analyze this repository and produce structured notes covering:

### 1. Architecture & Execution Model
- How is the system structured? (addon frames, event-driven, macro-based, hybrid?)
- What's the entry point / initialization flow?
- How does the user interact with it? (keybinds, slash commands, UI, macro buttons?)
- What's the core execution loop — how does it decide what to do next?

### 2. Core Logic & Priority System
- How are priorities expressed? (hardcoded logic, config tables, priority queues?)
- How does it handle cooldowns, timing windows, and resource management?
- How does it interleave filler actions with cooldown-gated actions?
- Are there any timing-sensitive operations and how are they handled?

### 3. State Management & Decision-Making
- What state does it track? (timers, cooldowns, buffs/debuffs, resources?)
- How does it read that state? (API calls, events, polling?)
- How does it handle context switching (e.g., target changes, mode changes)?
- Are there any caching or performance patterns worth noting?

### 4. Dependency Usage
- Which APIs from the shared dependency stack does it actually use?
- Are there dependencies it relies on that I haven't listed?
- How tightly coupled is the logic to specific dependency features?

### 5. Anti-Patterns & Defensive Code
- Any workarounds for known bugs or quirks in the platform/dependencies?
- Any patterns that seem intentionally defensive (and why)?
- Any code smells or limitations worth being aware of?

### 6. Transferable Ideas
- What are the strongest design decisions in this repo?
- Which patterns are paradigm-independent (useful regardless of my approach)?
- If adopting this repo's approach wholesale: what would the migration path look like?
- If staying with my current approach: which specific techniques could I borrow?

## Output Format
Produce a single markdown document with the 6 sections above. Use code blocks for any
code snippets. Keep explanations concise — prioritize concrete examples over theory.
Do not assume which approach I should take — present findings neutrally so I can make
an informed decision.
