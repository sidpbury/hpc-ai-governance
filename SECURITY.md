# Security

This project studies AI-assisted HPC operation. Treat all AI output as potentially incorrect or unsafe.

## Core security principles

- Markdown instructions are not a security boundary.
- Do not expose unrestricted shell execution through MCP.
- Do not permit AI services to bypass the user's normal authorization.
- Require server-side validation of tool parameters.
- Require explicit approval for state-changing HPC actions.
- Protect credentials, SSH keys, tokens, confidential research data, and unrelated user files.
- Test security controls in isolated/non-production environments whenever possible.

Do not publish real credentials, sensitive job data, private research data, or production secrets in issues, examples, or experiment artifacts.
