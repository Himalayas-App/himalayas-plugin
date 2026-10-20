---
description: Show new Himalayas jobs for my profile since the last check (the full list on Plus, a fresh search on Free).
---

Use the `find-remote-jobs` skill and call `get_new_matches` for jobs matching the user's Himalayas profile posted since an agent last checked.

- On Plus, show the matches.
- On Free, the reply gives the count only. Say that listing them needs Plus, then search `search_jobs` for the user's primary role and location, newest first, and show the best fits from that.
- If the profile is incomplete, say what is missing and search anyway.

For each job give the title, company, link, where it is open to, salary if listed, and one line on fit. Offer to save the best ones, or skip ones the user passes on with a reason. Change nothing without the user's yes.
