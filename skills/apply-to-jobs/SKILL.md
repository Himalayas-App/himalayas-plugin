---
name: apply-to-jobs
description: Help the user apply to a remote job on Himalayas, from checking fit to a tailored resume and cover letter, saved application answers, the employer's apply link and interview practice. Use when the user wants to apply to a job, tailor a resume or cover letter to one, answer application questions, or prepare for an interview.
---

# Apply to jobs

Follow [himalayas-basics](../himalayas-basics/SKILL.md) for the shared rules.
Applying needs a Himalayas account. The user submits every application
themselves on the employer's site.

## 1. Check fit

Read the job with `get_job_details` and the user's profile with
`get_my_profile`. Before going further, point out anything that rules the job
out: the countries it is open to, required work permits, time zone, seniority
or salary. If the user decides not to apply, offer `skip_job` with the reason.

## 2. Tailor the documents (optional)

`generate_application_documents` writes a resume and a cover letter tailored
to the job from the user's profile and saves them to their account, where they
can edit them and download a PDF.

- Ask first. A free account gets one tailored resume and one cover letter in
  total, so tell the user before using it. Plus includes them for every job.
- Pass `documents` to make only one of the two.
- A second call for the same job returns the documents already made.
- `list_documents` and `get_document` read them back. `update_document`
  renames a document or replaces a cover letter's text. Resume content is
  edited in the website's resume editor.

A thin profile makes thin documents. If the profile is missing experience,
offer [build-candidate-profile](../build-candidate-profile/SKILL.md) first.

## 3. Application questions

`list_saved_answers` shows answers the user saved to common questions, such as
work authorisation or notice period. Use them to draft answers for this
application, and show the drafts to the user. `update_saved_answer` changes
one after the user confirms.

## 4. Apply

When the user has decided to apply, call `get_apply_link`. It returns the
employer's application link and marks the job as applied in the tracker. The
user opens the link and submits the application. Never fill in the employer's
form for them. The limit is 50 links per account per day.

## 5. Prepare for interviews

- `get_interview_practice_link` returns the Himalayas page where the user
  practises interviewing for this job, or for a job elsewhere with
  `application_link`.
- `list_interviews` shows past practice and the minutes and credits left.
- `get_interview_results` returns scores and feedback for one job. Summarise
  the two or three things to work on.

## 6. Afterwards

Record progress with `update_job_status` (see
[track-applications](../track-applications/SKILL.md)).
