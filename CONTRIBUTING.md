# Contributing

Issues and pull requests are welcome.

- Skill and command names are stable from 1.0.0. A rename ships as a new name,
  with the old one kept as a deprecated alias.
- Raise `version` in every manifest and add a `CHANGELOG.md` entry with each
  release: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
  `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`,
  `.grok-plugin/plugin.json`, `plugin.json`, `gemini-extension.json` and
  `chatgpt/plugin.json`.
- Skills describe the tools on the hosted server. Check tool names and
  parameters against `skills/himalayas-basics/references/tools.md`.
- Run `claude plugin validate --strict .claude-plugin/plugin.json` before
  opening a pull request.
