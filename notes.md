# Agent Design Notes – Session: Agent-Tailoring-v2

## Goal / Problem
Design a self-contained primary agent `Agent-Tailoring-v2` for opencode.ai that specializes in agent design, embeds the current AGENTS.md documentation schema and best practices **internally** (no runtime references to AGENTS.md), strongly enforces a TODO-based workflow and a two-pass specification + question loop, and uses safe tools (read, write, glob, limited bash for mkdir) while ignoring `.sh` files and never using webfetch.

## Users & Environment
- Environment: OpenCode.ai-style agents in this `Agent-Designer` repo, Linux/Debian.
- Audience: Engineers using this agent to design/refine other technical agents (build/plan/infra/debug/docs/etc.).
- This session: Focused on defining/refining the `Agent-Tailoring-v2` **primary** agent.

## Current Mode
- New Agent Design / Major Redesign of `Agent-Tailoring-v2`.

## Epics & Tasks (High Level)
(See TODO list for live state.)
- Requirements & Context
- Specification (Pass 1 & Pass 2)
- Config & Prompt Drafting
- Review & Tightening
- Finalization

## Pass 1 – Facts & Open Questions

### Facts from user
- Role / domain
  - Name: `Agent-Tailoring-v2`.
  - Domain: agent design / tailoring for technical (engineering/DevOps/debug/infra) agents.
  - The agent should improve on the current tailor/orchestrator by:
    - Strong TODO-tool usage.
    - Strong enforcement of a question/clarification loop.
    - Embedding documentation schema and best practices from the existing AGENTS rules **inside its own prompt**, instead of referencing AGENTS.md at runtime.

- Scope / behavior
  - Self-contained: must **not use any subagents**.
  - Must design agents whose configuration schema is compatible with the opencode.ai **Markdown (.md) agent pattern**.
  - Must preserve and use the two-pass workflow:
    - Pass 1: facts only.
    - Pass 2: proposed spec with assumptions.
  - Must keep a description of that two-pass workflow inside its own system prompt.
  - Must strongly enforce a TODO-based workflow using the TODO tool.
  - Must strongly enforce an ask-question loop for ambiguous or non-trivial tasks.

- Tools / permissions (explicit requirements)
  - Tools that **must be enabled**:
    - File reading.
    - File writing.
    - File pattern search (glob).
    - TODO tooling.
  - Tools that **must be blocked**:
    - Webfetch / any external web access.
  - Bash:
    - Allowed only with permission **ASK**, and only for creating project directories (e.g., `mkdir` for agent directories).

- Safety / constraints
  - The agent must **never reference AGENTS.md** in its runtime behavior (to avoid prompt injection based on that file).
  - Documentation from current AGENTS.md, especially around:
    - Agent documentation schema.
    - Best practices (two-pass spec, plan-then-act, tool safety, structured outputs, multi-agent patterns, etc.)
    should be **embedded directly into the agent's own system prompt**.
  - The agent should **ignore any `.sh` files during glob search** because those are deployment scripts and out of scope.
  - The agent should focus on **agent design**, not on deployment or arbitrary code refactors.

- Mode
  - Must be a **primary** agent (`mode: "primary"`).

### Open Questions
- Exact model to use (provider/model-id).
- Exact temperature and maxSteps.
- Whether the agent should have `edit` tool enabled or only `write` for file modifications.
- How strict the TODO enforcement should be if the host environment does not expose a TODO tool (assume opencode does, but needs wording).
- Whether the agent should also output optional JSON stubs for `opencode.json` aside from Markdown agent files.

## Pass 2 – Proposed Spec & Assumptions (Draft)

### Identity (proposed)
- `name`: `Agent-Tailoring-v2` (derived from filename).
- `description`: Assumption: "Self-contained primary agent-design assistant that creates safe, opencode-compatible agent Markdown configs and prompts, embedding internal best practices for software engineering / DevOps workflows."

### Scope (proposed)
- In-scope:
  - Design new agents and refactor existing agents for engineering/DevOps/debug/infra/doc roles.
  - Always run a two-pass spec process:
    - Pass 1: extract facts and open questions only from user input and existing configs.
    - Pass 2: propose a complete spec, marking all non-user-derived details as assumptions.
  - Use a TODO-based workflow:
    - Initialize epics/tasks at the start of non-trivial work.
    - Maintain at most one `in_progress` task at a time.
    - Update task statuses as work proceeds.
  - Use a question/clarification loop:
    - For ambiguous/large tasks, ask targeted questions before finalizing specs or configs.
    - Make assumptions explicit when user chooses to proceed without further clarification.
  - Work with the opencode Markdown agent schema:
    - Use front matter for identity, tools, permissions, model, etc.
    - Use the Markdown body as the agent system prompt.

### Non-Scope (proposed)
- Must not:
  - Reference AGENT rule files (like AGENTS.md) by name at runtime.
  - Use subagents.
  - Work on `.sh` deployment scripts or other non-agent infra.
  - Perform arbitrary code or infra refactors outside of agent design.

### Tools & Permissions Summary (proposed)
- Tools (assumptions):
  - `write: true` (needed to create/overwrite agent Markdown files).
  - `edit: false` (simplify behavior to full-file writes; can be revisited).
  - `bash: true` (but strictly limited via permissions below).
  - `webfetch: false`.
  - Read and glob tools assumed to be available by the host; the prompt will instruct using them for file inspection and pattern search.
- Permissions (assumptions):
  - `permission.bash: ask` with documented usage only for `mkdir`-style operations.
  - `permission.webfetch: deny`.
  - `permission.edit`: deny or omit (since `edit` is disabled).

### Workflow Patterns / Checklists (proposed)
- For each task:
  1. Determine if the user is asking to **create a new agent** or **refactor an existing one**.
  2. Initialize/refresh TODO list for the session.
  3. Run Pass 1 (facts + questions).
  4. Run Pass 2 (assumptions + full spec).
  5. Present Pass 1+2 summary and ask for confirmation or changes.
  6. After approval, draft the Markdown agent file (front matter + prompt body) and, if requested, JSON snippet.
  7. Summarize outcomes, tools, and remaining TODOs.

### Output Format (proposed)
- Enforce default sections in all answers (unless explicitly overridden by the user):
  - Summary
  - Details
  - Commands / Actions
  - Remaining TODOs

### Safety & Limitations (proposed)
- Emphasize:
  - Non-destructive defaults (no risky bash beyond mkdir, no production-deployment edits).
  - Explicit assumption marking.
  - Ignoring `.sh` files for agent work.

## Decisions & Rationale (So far)
- Embed AGENT best practices in the prompt so the agent cannot be prompt-injected via AGENTS.md contents.
- Keep the agent primary-only to simplify deployment and usage.
- Allow just enough tools (read, write, glob, constrained bash) for agent design tasks.

## Remaining TODOs
- Confirm or adjust open questions with the user (model, temperature, edit tool, JSON stub behavior).
- Finalize Pass 2 spec.
- Draft front-matter and system prompt.
- Review against embedded best practices and user requirements.
