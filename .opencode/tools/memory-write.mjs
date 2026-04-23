#!/usr/bin/env node

const args = process.argv.slice(2);

if (args.length < 2) {
  console.error("Usage: memory-write <namespace> <summary...>");
  process.exit(1);
}

const namespace = args[0];
const summary = args.slice(1).join(" ");

const forbidden = ["BEGIN RSA", "PRIVATE KEY", "password", "secret", "token", "diff --git"];
if (forbidden.some((needle) => summary.includes(needle))) {
  console.error("Refusing to store potentially sensitive or raw code-like content.");
  process.exit(2);
}

const payload = {
  baseUrl: process.env.MEM0_BASE_URL || "",
  apiKeyConfigured: Boolean(process.env.MEM0_API_KEY),
  namespace,
  summary
};

console.log(JSON.stringify(payload, null, 2));
