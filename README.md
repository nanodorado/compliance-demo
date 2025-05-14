# ✅ Checkov Compliance Demo

This project demonstrates how to use **Checkov** to validate Infrastructure as Code (IaC) against compliance frameworks such as:

- **SOC 2**
- **HIPAA**
- **PCI-DSS**
- **ISO 27001**
- **GDPR**
- **CCPA**

You’ll see both:
- ❌ a **failing example** with misconfigurations
- ✅ a **passing example** that complies with best practices

---

## 📁 Project Structure

```
checkov-compliance-demo/
├── README.md
├── failing-example/     # Deliberately insecure Terraform config
├── passing-example/     # Corrected, secure version
```

---

## 🧪 Prerequisites

Install Checkov globally (requires Python):

```powershell
pip install checkov
```

If `pip` is not recognized, make sure Python is added to your system PATH.

---

## 🚨 Step 1: Run the Failing Example

```powershell
cd .\failing-example
checkov -d . --framework terraform
```

You’ll see several violations, such as:

- S3 bucket with public read access (violates **PCI-DSS, SOC 2**)
- Security group open to the world (violates **ISO 27001**)
- Public database instance (violates **HIPAA, PCI-DSS**)

Each issue includes:
- 🔎 The Checkov check ID
- 📋 The failed resource and line
- ⚠️ The severity and rationale

---

## ✅ Step 2: Run the Passing Example

```powershell
cd ..\passing-example
checkov -d . --framework terraform
```

This version resolves the issues:
- S3 bucket uses `private` ACL
- Security group limits SSH access
- RDS instance is not publicly accessible

Checkov will confirm: `Passed checks: ✅`

---

## 💡 Optional: Output as JSON

If you'd like to capture structured results:

```powershell
checkov -d . --framework terraform --output json
```

This is useful for feeding results into dashboards or parsing programmatically.

---

## 🛡️ Why This Matters

Checkov enforces security and compliance **at the IaC level**, before deploying to the cloud.

It aligns directly with:
- 🔐 Data protection standards (HIPAA, GDPR)
- 🚫 Least privilege (SOC 2)
- 🔍 Network access control (PCI-DSS)
- 📜 Audit visibility (ISO 27001)

---

## 🔚 Summary

This demo illustrates how Checkov:
- Detects security misconfigurations
- Maps them to compliance standards
- Encourages secure-by-default Terraform practices

---

## 🧰 Useful Links

- [Checkov documentation](https://www.checkov.io/)
- [Bridgecrew compliance mappings](https://www.checkov.io/3.Concepts/Policy%20Index.html)
