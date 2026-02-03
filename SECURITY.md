# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. As a logging library, we handle potentially sensitive data.

### How to Report

1. **Do NOT** open a public issue
2. Email details to the repository owner
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution Timeline**: Depends on severity
  - Critical: 24-48 hours
  - High: 7 days
  - Medium: 30 days
  - Low: 90 days

### Disclosure Policy

- We follow responsible disclosure
- Credit will be given to reporters (unless anonymity is requested)
- Please allow reasonable time for fixes before public disclosure

## Security Features

This library includes security features:

1. **PrivacyRedactor** - Automatically masks PII (emails, phones, IPs)
2. **@Sensitive** - Property wrapper for sensitive fields
3. **No external dependencies** - Reduced attack surface

## Security Best Practices

When using this library:

1. **Enable PrivacyRedactor** on external destinations
2. **Review log output** before enabling remote logging
3. **Secure remote endpoints** with HTTPS and authentication
4. **Rotate log files** to prevent disk exhaustion
5. **Don't log credentials** even in debug mode

## Contact

For security concerns, contact the maintainer through GitHub.

---

Thank you for helping keep this project secure! 🔒
