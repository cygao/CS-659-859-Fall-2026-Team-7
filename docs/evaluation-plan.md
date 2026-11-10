# Evaluation Plan

This plan records the experiment in the approved proposal. It does not report results. The team must keep prompt development separate from verification.

## Proposed experiment

- Create 10 synthetic SFSU student resumes with two language model providers.
- Collect 5 real entry-level software engineering job postings.
- Tailor each resume to each posting. This produces 50 resume and job pairs.
- Use a separate language model as a judge. Ask it to score the original and tailored resumes on a 1–4 scale.
- Keep the development set separate from the verification set. Do not tune prompts on verification examples.

The team must define the split, scoring rubric, model names, prompt versions, and run procedure before it collects results. Do not invent missing methods or results.

## Measures and limits

Report score changes for each pair and the counts that improved, stayed the same, or decreased. The same 10 resumes appear in multiple pairs, so the 50 pairs are not independent observations.

An LLM judge measures the judge's view of relevance. It does not show how a real ATS ranks a resume. It does not show whether a person will get an interview or job. State this limit in all reports.

Also review factual preservation. Check whether each suggestion is supported by the synthetic source resume. Include examples where a job asks for a skill that the resume does not show.

## Data handling

Keep evaluation inputs, scripts, and results in separate folders. Use only synthetic resumes. The approved plan uses real job postings; store only the text needed for the experiment, record its source, and follow the course rules for data use.

Do not put real applicant data in this repository. Do not commit credentials or model weights. Keep generated results separate from app sample data.

## Result record

Before each evaluation run, record the dataset version, development and verification split, generator provider and version, judge provider and version, prompts, date, and script version. Store raw outputs and summary results separately. Mark each missing value as unknown; do not infer it.
