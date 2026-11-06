# Sample run (illustrative)

This directory shows the shape of a finished run. The files are examples, not
the result of an actual execution, and the PNG evidence files are intentionally
omitted to keep the repository small.

A real run creates:

```
qa/runs/<run-id>/
├── .qa-commit
├── .started-at
├── .finished-at
├── evidence/
│   └── TC-AUTH-001-04.png
├── report/
│   └── summary.md
├── results/
│   ├── admin.md
│   ├── auth.md
│   ├── cart.md
│   ├── catalog.md
│   └── checkout.md
└── test-cases.xlsx
```
