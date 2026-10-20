---
description: Connect Himalayas, check the account and profile, and suggest the next steps for a job search or for hiring.
argument-hint: "[optional goal, e.g. find a job or hire]"
---

Use the `himalayas-basics` skill to get the user set up on Himalayas.

Goal: $ARGUMENTS

1. Call `get_my_profile`. If the account isn't connected yet, the user's client asks them to sign in to Himalayas (Google or a Himalayas login, either of which can create a new account). Explain that search works without signing in, and that their profile, tracker and applications need it.
2. Once connected, say who is signed in and whether the plan is Free or Plus, in one line.
3. For a job seeker, list what the profile is missing for good matches (role, location, work permits, salary, experience, skills), and offer the `build-candidate-profile` skill, including importing from LinkedIn or a resume.
4. For an employer, check `get_company_profile`, then offer to post a job or find candidates.
5. End with at most three next steps. Change nothing without the user's yes.
