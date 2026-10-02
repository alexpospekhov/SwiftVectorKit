# Xcode 27 & Apple Foundation Models — SDK Ground-Truth Audit

**Date:** 2026-10-02  
**Hardware:** Apple M3 Max (`Mac15,9`), 40 GB Unified Memory  
**OS:** macOS 27.2 Beta (Build `26B5091g`)  
**IDE & Toolchain:** Xcode 27.0 Beta (Build `27A5252f`) at `/Applications/Xcode-beta.app`  
**Swift Compiler:** Apple Swift version 6.4 (`swiftlang-6.4.0.33.1`, Clang `2100.3.33.1`)  
**Target Architecture:** `arm64-apple-macosx27.0`  

---

## 1. Verified SDK Capabilities

### 1.1. Dual-Tier Foundation Models API (`FoundationModels.framework`)
- **`SystemLanguageModel`**: On-device model (~3B parameters) running natively on Apple Silicon.
- **`PrivateCloudComputeLanguageModel`**: Public class exposed in macOS 27.0 SDK providing direct access to Apple Private Cloud Compute with end-to-end encryption.
- Both conform to `FoundationModels.LanguageModel`.
- Verified live on machine:
  ```swift
  let pcc = PrivateCloudComputeLanguageModel()
  print("Available: \(pcc.isAvailable)") // true
  print("Status: \(pcc.quotaUsage.status)") // belowLimit(isApproachingLimit: false)
  ```

### 1.2. Structured Output via Macros
- `@Generable`: Enforces schema conformance directly at logit sampling level.
- `@Guide`: Constrains field boundaries, ranges, and descriptions.

### 1.3. Native Tool Calling
- `FoundationModels.Tool`: Protocol enabling language models to invoke Swift functions with structured arguments.
- `_Vision_FoundationModels.framework`: Native `OCRTool` and `BarcodeReaderTool`.
- `_CoreSpotlight_FoundationModels.framework`: Native `SpotlightSearchTool`.

### 1.4. Adapter Compiler (`fmadapterc`)
- Preinstalled at `/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/fmadapterc`.
- Compiles LoRA weights (`adapter_weights.bin`) into `.fmadapter` archives for `SystemLanguageModel.Adapter`.

### 1.5. Built-in Xcode MCP Infrastructure
- Active background server at `/Applications/Xcode-beta.app/Contents/Developer/usr/bin/mcp-server`.
- Stdio bridge at `/Applications/Xcode-beta.app/Contents/Developer/usr/bin/mcpbridge`.
- LLDB debugger tool at `/Applications/Xcode-beta.app/Contents/Developer/usr/bin/lldb-mcp`.
