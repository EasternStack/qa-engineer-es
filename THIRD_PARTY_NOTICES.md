# Third-party notices

## xlsx skill

- **Path:** `.qoder/skills/xlsx/`
- **Source:** https://github.com/AutumnsGrove/ClaudeSkills (`xlsx` directory)
- **Status:** The upstream repository declares **no license**. As of 2026-11-06
  it has no `LICENSE` file, and the GitHub license API returns `404 Not Found`.

The MIT license in this repository covers the original code of `qa-engineer-es`
only. It does **not** grant rights to this vendored component. The component is
included because the `qa-run` workflow depends on it.

Before publishing or redistributing this repository, do one of the following:

1. Obtain permission from the upstream author and keep the attribution above.
2. Replace `.qoder/skills/xlsx/` with an implementation you own.
3. Remove the component and rely on the inline `openpyxl` commands in the
   `qa-run` skill.

This notice is informational, not legal advice. Consult a lawyer if you need a
definitive answer for your jurisdiction.
