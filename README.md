# 🚀 Serverless Power Tuning & Cost Optimization on AWS

This repository demonstrates a **production-ready pattern** for evaluating and optimizing the **AWS Lambda memory configuration** using **real performance data**, not guesswork.

It combines:

- **AWS Lambda Power Tuning** (Step Functions benchmarking state machine)
- **Terraform** for repeatable, environment-consistent infrastructure
- **GitHub Actions CI/CD** with *OIDC federation* (no stored IAM keys)
- **Postman + Newman** for automated API functional verification
- **Optional manual approval workflow** for controlled memory adjustments

This solution is designed for **enterprise platform teams, FinOps programs, Cloud CoEs, and architects** who require **evidence-based resource tuning** with automated governance.

---

## 🎯 Business & Architecture Overview

Lambda cost is influenced by two opposing factors:

| More Memory → More CPU | More CPU → Faster Execution |
|---|---|
| Higher configured memory increases cost *per ms* | Faster execution reduces *total ms billed* |

This means:
> **More memory does not always mean more cost** — and often results in **lower latency at similar cost**.

This repository **automates the discovery** of the optimal balance.

| Capability | Benefit |
|-----------|---------|
| Automated performance benchmarking | Scientific, repeatable memory tuning |
| Visual performance & cost comparison | Clear evidence for decision-makers |
| Optional approver-based rollout | Fits enterprise change governance |
| Zero long-lived IAM keys (OIDC) | Improves security posture |
| Fully IaC-defined (Terraform) | Portable across environments |

---

## 🧠 What Makes This Implementation Different

Most Power Tuning demos *only* show how to run the state machine manually.

This implementation goes **further**:

| Feature | Typical Tutorials | This Implementation |
|---|---|---|
| Automated tuning workflow | ❌ No | ✅ Yes |
| Load testing w/ Newman | ❌ No | ✅ Yes |
| Branch-aware deployment controls | ❌ No | ✅ Yes |
| Manual approval workflow (optional) | ❌ No | ✅ Yes |
| Reports stored for audit / review | ❌ No | ✅ Yes |
| OIDC IAM auth (no secrets) | ❌ Rare | ✅ Yes |
| Terraform-managed API + Lambda stack | ⚠️ Sometimes | ✅ Always |

This is a **repeatable tuning operating model**, not a one-off demo.

---

## 🔎 Key Optimization Result (Example)

| Memory Setting | Avg Duration | Cost per Execution | Outcome |
|---|---:|---:|---|
| **512 MB** | Higher latency | Standard cost | ❗ Suboptimal |
| **1024 MB** | **~40–55% faster** | ~Similar cost | ✅ Best performance / cost trade-off |

> Increasing memory improved CPU → reduced execution time → final cost remained nearly the same.

---

## 🧩 Architecture (High-Level)


---

## ⚙️ Key AWS Services

| Component | Purpose |
|---|---|
| **API Gateway** | REST interface (`/items`, `/items/{id}`) |
| **Lambda** | Application logic & DynamoDB CRUD |
| **DynamoDB** | Serverless low-latency database |
| **Power Tuner (Step Functions)** | Executes controlled performance test loops |
| **GitHub Actions + OIDC** | Deployment, testing, tuning, governance |
| **Newman** | Automated API smoke tests |

---

## 🧪 Reports & Evidence (Included in Repo)

| Report Type | Location | Purpose |
|---|---|---|
| Power Tuning Visuals | `reports/pwrt1.png`, `pwrt2.png`, `pwrt3.png` | Compare cost vs performance |
| Load Test (512 MB) | `reports/512MB.pdf` | Baseline |
| Load Test (1024 MB) | `reports/1024MB.pdf` | Optimized test |
| Memory Change Summary | `reports/memory-change-summary.md` | Decision justification |
| Full CI evidence history | `reports/history/` | Audit & review trail |

---

## ✅ When to Use This Pattern

Use this pattern when:

- You run **Lambda workloads at scale**
- Performance and user latency matter
- You need to **justify cloud costs with evidence**
- Your org requires **governance for configuration changes**

---

## 🏁 Key Takeaway

> **More memory = more CPU → faster execution → same or lower total cost.**
>
> The *only reliable way* to find the best configuration is to **measure it**.

This repository gives you the **measurement engine**, the **automation**, and the **approval controls** to do it **safely at scale**.

---

## 🌟 Developed By

**Mahesh Devendran**  
Cloud Architect • Serverless • FinOps • Platform Engineering  
*(Feel free to connect or reach out on LinkedIn!)*

