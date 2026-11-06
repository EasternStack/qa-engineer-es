# Examples

- `test-cases/` — five Markdown cases for the Eastern Stack demo storefront,
  one per module, with the input-directory README frontmatter.
- `test-cases.xlsx` — the same five cases in Excel, with `Config`, `Accounts`,
  and `TestCases` sheets.
- `sample-run/` — illustrative output format only. It is **not** a real
  execution, and the evidence files are omitted.

Run the examples against the demo SUT:

```
/qa-run --input qa/examples/test-cases.xlsx
/qa-run --input qa/examples/test-cases
```

To try a single case:

```
/qa-run --input qa/examples/test-cases.xlsx --only TC-AUTH-001
```

Replace `base_url`, `accounts`, and the cases to point the harness at your own
application.
