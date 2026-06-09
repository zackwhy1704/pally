# OCR TEST IMAGES — for L1 (OCR latency) & L7 (OCR burst / rate-limit)

30 synthetic worksheet images across three quality tiers. They drive the **Claude Haiku-vision OCR** leg
(`POST /api/v1/avatars/{id}/files`, image MIME → `ClaudeVisionOcrService`).

| Tier | Count | Files | Simulates |
|------|-------|-------|-----------|
| `clean/` | 10 | PNG, crisp | flatbed scan / clean export |
| `photo/` | 10 | JPEG q72, skew + uneven lighting + blur + noise | phone photo on a desk |
| `lowq/`  | 10 | JPEG q52, grayscale + resolution loss + heavy noise | bad scan / old camera |

Each page ≈ 400 words: centre header, name/class/date, a topic notes block (Fractions / Photosynthesis /
Decimals), and 4 practice questions — so OCR returns real, varied text.

## Mapping to the plan
- **L1 (OCR per page, p95 < 10s):** use the 20 `clean/` + `photo/` images, uploaded sequentially.
- **L7 (30 uploads in 10s, rate-limit):** fire all 30 concurrently/in a burst.

Feed one to the real endpoint:
```bash
curl -X POST "$API/api/v1/avatars/$AVATAR/files" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@clean/ws_01_fractions.png" -F "skipRelevance=true"
# expect: 201, file PROCESSING→READY, extractedText non-empty
```

## Honest limits — what these DON'T cover
These are **printed** pages. They are correct for L1/L7 because those tests measure **latency and burst
behaviour**, which don't depend on OCR difficulty. They are **not** a fair test of OCR *accuracy/robustness*
on the hard cases your real users will produce. For that, get real data:

1. **Shoot your own (best):** photograph 25–30 actual worksheets/textbook pages — clean, skewed, dim,
   crumpled, with handwriting in the blanks. Free, and exactly matches your SG users + curriculum. This is
   the single most representative dataset you can build; an afternoon with a phone.
2. **Public document/OCR datasets (for robustness + handwriting):**
   - **FUNSD**, **SROIE**, **DocVQA**, **RVL-CDIP** — scanned printed documents (forms/receipts/mixed).
   - **IAM Handwriting Database** — handwritten English (free, registration required).
   - **CASIA-HWDB** / NIST SD19 — handwriting.
   Most are **research-only licences** — fine for internal testing, do not redistribute or train on without
   checking terms.
3. **Edge cases to add by hand:** a blank page, a pure-photo (no text), a non-English page → assert these
   come back **FAILED/IRRELEVANT cleanly**, not as garbage wiki (this is the OCR robustness check, separate
   from L1/L7).

Do **not** scrape copyrighted assessment books for test data — same reasoning as the content rule.
