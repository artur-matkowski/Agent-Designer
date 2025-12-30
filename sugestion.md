- Suggested subagents for General-Researcher (to be designed in future sessions):
  - general-researcher/web-scraper.md – Web research subagent with webfetch, focused on official docs first, community sources clearly marked.
  - general-researcher/doc-scraper.md – Reads and summarizes user-provided documents, producing structured notes and citations.
  - general-researcher/alternative-discoverer.md – High-temperature creative subagent to propose alternative angles and exploration paths when research stalls.

- Created subagents (completed):
  - tdd-developer/creative-unblocking.md – General-purpose creative unblocking subagent that breaks primary agent fixation cycles by proposing alternative solutions, re-scoping requirements, and suggesting different technology approaches. Can be invoked by any primary agent when stuck in repeated failure loops.

- devops (make developer aware of it)
- task creator agent (like dedicated remote ssh bash command)


User manual input:
- Web scanner: User specifies comapny. Agent is to scan web (linkedin, fb, any other, social network, and oficial website) sources to find as many peopple working there. With special focus on department sugested by user. Createsa list of people for subsequent sanning. Tries to find as mutch as possible about thouse people: social networks, github, gitlab, compony porfiles. Vector is to find out their expertiese, especially techical one. Scan their repository, if AI agent repository is found start there, roead all the agent prompts, and try to determine baseline for persone who wrote them. What he does what are his expertiese.