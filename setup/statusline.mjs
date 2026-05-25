#!/usr/bin/env node
//
// Standalone Claude Code status line — node-based, zero dependencies.
// Layout: <path> [git::branch[*]] [model] ctx:NN% [today:Nk] [5h:NN%↻HH:MMm] [7d:NN%↻HH:MMm]
// Wire up via settings.json:
//   { "statusLine": { "type": "command", "command": "$HOME/.claude/statusline-launcher.sh" } }
//
// Reads Claude Code's input JSON from stdin (cwd, model, context_window).
// Optionally enriches with:
//   - daily token usage from ~/.claude/stats-cache.json
//   - rate-limit utilization from Anthropic OAuth API (60s cache)
//
// Rate-limit fetching vendored from oh-my-claudecode/src/hud/usage-api.ts (Apache 2.0).
// Stripped of: SSRF guard, file locking, z.ai fallback, exponential backoff, token refresh.
// Hostname hardcoded to api.anthropic.com — ANTHROPIC_BASE_URL is intentionally ignored
// (proxy setups should keep the OMC plugin's HUD instead).
// Acceptable trade-off at single-user scale — see docs/decisions/0001-build-before-install.md.
//
// Customize: edit format() at the bottom.

import { readFileSync, existsSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { homedir } from "node:os";
import { join, basename } from "node:path";
import https from "node:https";

const C = {
  reset: "\x1b[0m",
  dim: "\x1b[2m",
  blue: "\x1b[34m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
  cyan: "\x1b[36m",
  white: "\x1b[37m",
};

function readStdin() {
  try { return JSON.parse(readFileSync(0, "utf8")); }
  catch { return {}; }
}

function git(cwd, args) {
  try {
    return execFileSync("git", ["--no-optional-locks", ...args], {
      cwd,
      stdio: ["ignore", "pipe", "ignore"],
      encoding: "utf8",
    }).trim();
  } catch { return ""; }
}

function gitInfo(cwd) {
  if (!cwd) return null;
  const branch = git(cwd, ["symbolic-ref", "--short", "HEAD"]) || git(cwd, ["rev-parse", "--short", "HEAD"]);
  if (!branch) return null;
  const status = git(cwd, ["status", "--porcelain"]);
  return { branch, dirty: status.length > 0 };
}

function dailyTokens() {
  const path = join(homedir(), ".claude", "stats-cache.json");
  if (!existsSync(path)) return null;
  try {
    const stats = JSON.parse(readFileSync(path, "utf8"));
    const today = new Date().toISOString().slice(0, 10);
    const row = (stats.dailyModelTokens || []).find(r => r.date === today);
    if (!row) return null;
    return Object.values(row.tokens || {}).reduce(
      (sum, t) => sum + (t.input || 0) + (t.output || 0) + (t.cacheRead || 0) + (t.cacheCreation || 0),
      0,
    );
  } catch { return null; }
}

// ---------- Rate-limit fetch (vendored from OMC, simplified) ----------

const RL_CACHE_PATH = join(homedir(), ".claude", ".rate-limit-cache.json");
const RL_CACHE_TTL_MS = 60_000;
const RL_API_TIMEOUT_MS = 3000;

function readOAuthToken() {
  // macOS Keychain
  if (process.platform === "darwin") {
    try {
      const out = execFileSync(
        "/usr/bin/security",
        ["find-generic-password", "-s", "Claude Code-credentials", "-w"],
        { encoding: "utf8", timeout: 2000, stdio: ["pipe", "pipe", "ignore"] },
      ).trim();
      const parsed = JSON.parse(out);
      const creds = parsed.claudeAiOauth || parsed;
      if (creds.accessToken && (!creds.expiresAt || creds.expiresAt > Date.now())) {
        return creds.accessToken;
      }
    } catch { /* fall through to file */ }
  }
  // File fallback
  try {
    const path = join(homedir(), ".claude", ".credentials.json");
    if (!existsSync(path)) return null;
    const parsed = JSON.parse(readFileSync(path, "utf8"));
    const creds = parsed.claudeAiOauth || parsed;
    if (creds.accessToken && (!creds.expiresAt || creds.expiresAt > Date.now())) {
      return creds.accessToken;
    }
  } catch { /* ignore */ }
  return null;
}

function readRLCache() {
  try {
    if (!existsSync(RL_CACHE_PATH)) return null;
    const cache = JSON.parse(readFileSync(RL_CACHE_PATH, "utf8"));
    if (Date.now() - cache.timestamp > RL_CACHE_TTL_MS) return null;
    return cache.data;
  } catch { return null; }
}

function writeRLCache(data) {
  try {
    writeFileSync(RL_CACHE_PATH, JSON.stringify({ timestamp: Date.now(), data }, null, 2), { mode: 0o600 });
  } catch { /* best-effort */ }
}

function fetchUsage(token) {
  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: "api.anthropic.com",
        path: "/api/oauth/usage",
        method: "GET",
        headers: {
          "Authorization": `Bearer ${token}`,
          "anthropic-beta": "oauth-2025-04-20",
          "Content-Type": "application/json",
        },
        timeout: RL_API_TIMEOUT_MS,
      },
      (res) => {
        let body = "";
        res.on("data", (c) => { body += c; });
        res.on("end", () => {
          if (res.statusCode !== 200) return resolve(null);
          try {
            const r = JSON.parse(body);
            resolve({
              fiveHourPercent: r.five_hour?.utilization ?? null,
              fiveHourResetsAt: r.five_hour?.resets_at ?? null,
              weeklyPercent: r.seven_day?.utilization ?? null,
              weeklyResetsAt: r.seven_day?.resets_at ?? null,
            });
          } catch { resolve(null); }
        });
      },
    );
    req.on("error", () => resolve(null));
    req.on("timeout", () => { req.destroy(); resolve(null); });
    req.end();
  });
}

async function getRateLimits() {
  const cached = readRLCache();
  if (cached) return cached;
  const token = readOAuthToken();
  if (!token) return null;
  const data = await fetchUsage(token);
  if (data) writeRLCache(data);
  return data;
}

function fmtTimeUntil(isoStr) {
  if (!isoStr) return "";
  const ms = new Date(isoStr).getTime() - Date.now();
  if (!isFinite(ms) || ms <= 0) return "now";
  const h = Math.floor(ms / 3_600_000);
  const m = Math.floor((ms % 3_600_000) / 60_000);
  if (h >= 24) return `${Math.floor(h / 24)}d${h % 24}h`;
  return h > 0 ? `${h}h${m}m` : `${m}m`;
}

function rlColor(pct) {
  if (pct >= 90) return C.red;
  if (pct >= 70) return C.yellow;
  return C.green;
}

// ---------- Display ----------

function ctxColor(pct) {
  if (pct >= 80) return C.red;
  if (pct >= 50) return C.yellow;
  return C.green;
}

function fmtTokens(n) {
  if (n >= 1e9) return `${(n / 1e9).toFixed(1)}B`;
  if (n >= 1e6) return `${(n / 1e6).toFixed(1)}M`;
  if (n >= 1e3) return `${Math.round(n / 1e3)}k`;
  return `${n}`;
}

function format(input, rateLimits) {
  const cwd = input.cwd || input.workspace?.current_dir || "";
  const dir = cwd ? basename(cwd) : "";
  const model = input.model?.display_name || "";
  const ctx = input.context_window?.used_percentage;

  const parts = [];
  if (dir) parts.push(`${C.blue}${dir}${C.reset}`);

  const g = gitInfo(cwd);
  if (g) {
    const dirty = g.dirty ? `${C.red}*${C.reset}` : "";
    parts.push(`${C.green}[git::${g.branch}${dirty}${C.green}]${C.reset}`);
  }

  if (model) parts.push(`${C.cyan}${model}${C.reset}`);

  if (typeof ctx === "number") {
    parts.push(`${C.dim}ctx:${C.reset}${ctxColor(ctx)}${Math.round(ctx)}%${C.reset}`);
  }

  const tokens = dailyTokens();
  if (tokens) parts.push(`${C.dim}today:${C.reset}${C.white}${fmtTokens(tokens)}${C.reset}`);

  if (rateLimits?.fiveHourPercent != null) {
    const pct = Math.round(rateLimits.fiveHourPercent);
    const reset = fmtTimeUntil(rateLimits.fiveHourResetsAt);
    parts.push(`${C.dim}5h:${C.reset}${rlColor(pct)}${pct}%${C.reset}${reset ? `${C.dim}↻${reset}${C.reset}` : ""}`);
  }
  if (rateLimits?.weeklyPercent != null) {
    const pct = Math.round(rateLimits.weeklyPercent);
    const reset = fmtTimeUntil(rateLimits.weeklyResetsAt);
    parts.push(`${C.dim}7d:${C.reset}${rlColor(pct)}${pct}%${C.reset}${reset ? `${C.dim}↻${reset}${C.reset}` : ""}`);
  }

  return parts.join(" ");
}

const stdin = readStdin();
const rateLimits = await getRateLimits();
process.stdout.write(format(stdin, rateLimits));
