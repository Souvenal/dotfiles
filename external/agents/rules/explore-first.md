---
description: explore first rules
alwaysApply: false
paths: **/*.{h,hpp,c,cpp}
enabled: true
---

# Explore First Before Implement

---

## Core Principle

- Local authentic source code = single source of truth for APIs and implementations
- Proactively use Context7 MCP as a strong auxiliary tool for understanding and best practices

## 1. Authority & Usage Guidance
1. **Local source code takes absolute priority** for all concrete interfaces, function signatures, structs, classes, and actual behavior, especially for fixed library versions.
2. **Actively use Context7 MCP** to deepen understanding and improve implementation quality:
   - Learn core concepts, design philosophy, and architectural intent of libraries
   - Research idiomatic patterns, standard usages, and industry best practices
   - Understand common usage paradigms and potential pitfalls
   - Clarify high-level logic and design tradeoffs
3. When Context7 provides API references or sample code, always verify and align them with local source code before application.

## 2. Proactive Workflow (Required)
Before writing any code, follow this flow in order:
1. **First: search local codebase**
   Proactively scan local library sources, dependency headers, internal utilities, and existing project implementations to reuse available logic.
2. **Then: actively consult Context7**
   Even if a local implementation exists, use Context7 to better understand its intended usage, best practices, or conceptual background.
3. **Implement & align**
   Write code based on local real implementations, enhanced by insights from Context7.
4. **Last resort: new code**
   Create new functions/structs/classes only when no equivalent logic exists in local source.

## 3. Restrictions (Avoid Reinventing Wheels)
- Do not reimplement utilities, data structures, or helper logic that already exists locally.
- Do not directly copy API signatures or implementations from Context7 that conflict with local source.
- Do not hallucinate interfaces or guess behavior without checking local code.

## 4. Required Annotations
Label code origin clearly for traceability:
- Reused local code:
  `// Reused local source | Symbol: ${NAME} | Path: ${FILE_PATH}`
- Code informed by Context7:
  `// Context7 enriched | Type: concept / best practice / usage pattern`
- Newly added code:
  `// Verified local source: no equivalent implementation found; new code added`
