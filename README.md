# Himalayas plugin

[Himalayas](https://himalayas.app) is a remote jobs marketplace: jobs,
companies, salary data, career profiles, an application tracker, and employer
tools. This plugin lets Claude work on Himalayas with you.

- **Job seekers:** search remote jobs and companies, check salaries, get new
  matches for your profile, tailor a resume and cover letter to a job, track
  applications, practise interviews and reply to recruiters.
- **Employers:** post and manage remote jobs, keep your company profile
  current, search candidates and message them.

Claude asks before anything that changes or removes data, sends a message or
costs money. Messages to companies or candidates are shown to you word for word
before they are sent, and payments, applications and ID checks always happen in
your own browser.

## What it connects to

The plugin adds the hosted Himalayas MCP server,
`https://mcp.himalayas.app/mcp`. Job, company and salary search work straight
away. For your profile, tracker or company, you sign in with your Himalayas
account on first use (OAuth): Claude never sees your password, a connection
only gets the access you approve, and you can disconnect at any time from
your connector settings.

## What it sends

- Requests to the Himalayas MCP server, made only when a task needs them:
  searches, reads of your profile, tracker, documents, inbox or company, and,
  after you confirm, changes to them.
- Text you give Claude for Himalayas, such as a job description to post, a
  LinkedIn URL or resume text to import, or a message to send.
- Problem reports, when Claude hits something Himalayas could do better: a
  short description of the goal and what got in the way, with no credentials
  or personal data.

The plugin itself runs no code, stores nothing and contacts no other service.
Your data stays in Himalayas, under the privacy policy below.

## Privacy policy

Himalayas' privacy policy, <https://himalayas.app/privacy>, covers what data
Himalayas collects, how it is used and stored, which services process it, how
long it is kept, and how to contact us. Questions: hi@himalayas.app.

## Commands

| Command | What it does |
| --- | --- |
| `/himalayas:start` | Connects your account, checks your plan and profile, suggests next steps. |
| `/himalayas:find-jobs` | Searches remote jobs and shortlists the best fits. |
| `/himalayas:matches` | New jobs for your profile since the last check (a fresh search on Free). |
| `/himalayas:apply` | Prepares an application: fit check, documents, answers, apply link, on any plan. |
| `/himalayas:interview` | Likely questions, a practice link and a practice round in chat. |
| `/himalayas:tracker` | Reviews your tracker and inbox and suggests follow-ups. |
| `/himalayas:profile` | Reviews your profile and suggests what to add or fix. |
| `/himalayas:salary` | Benchmarks remote pay by role, seniority and country. |
| `/himalayas:post-job` | Drafts and posts a remote job for your company. |
| `/himalayas:find-talent` | Searches candidates and shortlists the best fits. |

In Claude chat you can also just ask, for example "find remote product design
jobs I can do from Canada", "what does a senior data engineer earn in
Germany?" or "post this job for us".

## Skills

`himalayas-basics` holds the shared rules (read first, confirm, verify). The
task skills are `find-remote-jobs`, `apply-to-jobs`, `track-applications`,
`build-candidate-profile`, `research-companies-and-salaries`,
`post-remote-jobs`, `source-remote-talent` and `manage-company-profile`.

## Accounts and paid features

Every command works on a free Himalayas account. A free account covers
search, salary data, the tracker, the profile, applying, one tailored resume
and cover letter, and one text mock interview. Himalayas Plus (US$9 a month) adds tailored documents for every job,
new matches between sessions, spoken interview practice and more. Employers
post jobs for free, with optional paid extras. When a task needs a paid
feature, Himalayas says so, and you pay on Stripe yourself.

## Install

- **Claude**: install Himalayas from the plugin directory, or run
  `/plugin marketplace add Himalayas-App/himalayas-plugin` and then
  `/plugin install himalayas@himalayas`.
- **Codex, Cursor and Grok**: load this repository as a plugin.

## Help

- Documentation: <https://himalayas.app/docs/remote-jobs-mcp>
- Email: hi@himalayas.app
- Terms: <https://himalayas.app/terms>
