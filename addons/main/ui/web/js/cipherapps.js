(function () {
  function esc(s) { return String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }
  function arr(s) { return Array.from(String(s || "")); }
  function mod(n, m) { return ((n % m) + m) % m; }
  function gcd(a, b) { while (b !== 0) { var t = b; b = a % b; a = t; } return Math.abs(a); }
  function inv(a, m) { a = mod(a, m); for (var i = 1; i < m; i++) if (mod(a * i, m) === 1) return i; return -1; }
  var U = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", L = "abcdefghijklmnopqrstuvwxyz";
  var WORDS = ["the", "and", "that", "have", "for", "not", "with", "you", "this", "secret", "password", "message", "root", "cipher"];
  var MORSE = { A: ".-", B: "-...", C: "-.-.", D: "-..", E: ".", F: "..-.", G: "--.", H: "....", I: "..", J: ".---", K: "-.-", L: ".-..", M: "--", N: "-.", O: "---", P: ".--.", Q: "--.-", R: ".-.", S: "...", T: "-", U: "..-", V: "...-", W: ".--", X: "-..-", Y: "-.--", Z: "--..", 0: "-----", 1: ".----", 2: "..---", 3: "...--", 4: "....-", 5: ".....", 6: "-....", 7: "--...", 8: "---..", 9: "----." };
  var NATO = { A: "Alpha", B: "Bravo", C: "Charlie", D: "Delta", E: "Echo", F: "Foxtrot", G: "Golf", H: "Hotel", I: "India", J: "Juliett", K: "Kilo", L: "Lima", M: "Mike", N: "November", O: "Oscar", P: "Papa", Q: "Quebec", R: "Romeo", S: "Sierra", T: "Tango", U: "Uniform", V: "Victor", W: "Whiskey", X: "Xray", Y: "Yankee", Z: "Zulu", 0: "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine" };
  var MORSE_REV = {}, NATO_REV = {};
  Object.keys(MORSE).forEach(function (k) { MORSE_REV[MORSE[k]] = k; });
  Object.keys(NATO).forEach(function (k) { NATO_REV[NATO[k].toLowerCase()] = k; });
  function bytes(s) { return window.TextEncoder ? new TextEncoder().encode(String(s || "")) : Uint8Array.from(unescape(encodeURIComponent(String(s || ""))), function (c) { return c.charCodeAt(0); }); }
  function text(bs) { return window.TextDecoder ? new TextDecoder("utf-8", { fatal: false }).decode(bs) : decodeURIComponent(escape(String.fromCharCode.apply(null, bs))); }
  function bin(bs) { var s = ""; for (var i = 0; i < bs.length; i += 8192) s += String.fromCharCode.apply(null, bs.slice(i, i + 8192)); return s; }
  function score(s) {
    var t = String(s || "").toLowerCase(), v = 0;
    for (var i = 0; i < t.length; i++) {
      var c = t[i], code = t.charCodeAt(i);
      if (c === " ") v += 2; else if ("etaoinshrdlu".indexOf(c) >= 0) v += 3; else if (/[a-z]/.test(c)) v += 1; else if (code < 32) v -= 20;
    }
    WORDS.forEach(function (w) { if (t.indexOf(w) >= 0) v += w.length * 4; });
    return v;
  }
  function alpha(mode) { return mode === "lower" ? L : U; }
  function keywordAlphabet(keyword, base) {
    var seen = {}, out = "";
    arr(String(keyword || "").toUpperCase() + base).forEach(function (c) { if (base.indexOf(c) >= 0 && !seen[c]) { seen[c] = 1; out += c; } });
    return out;
  }
  function mapAlpha(s, from, to, preserve) {
    return arr(s).map(function (ch) {
      var idx = from.indexOf(ch.toUpperCase());
      if (idx < 0) return ch;
      var out = to[idx % to.length];
      return preserve && ch === ch.toLowerCase() ? out.toLowerCase() : out;
    }).join("");
  }
  function morse(s, dec) {
    if (!dec) return arr(s).map(function (ch) { return ch === " " ? "/" : (MORSE[ch.toUpperCase()] || ch); }).join(" ");
    return String(s || "").trim().split(/\s+/).map(function (p) { return (p === "/" || p === "|") ? " " : (MORSE_REV[p] || ""); }).join("");
  }
  function spelling(s, dec) {
    if (!dec) return arr(s).map(function (ch) { return ch === " " ? "/" : (NATO[ch.toUpperCase()] || ch); }).join(" ");
    return String(s || "").trim().split(/\s+/).map(function (p) { return (p === "/" || p === "|") ? " " : (NATO_REV[p.toLowerCase()] || ""); }).join("");
  }
  function affine(s, o, dec) {
    var base = alpha(o.alphaMode || "upper"), a = Number(o.a || 1), b = Number(o.b || 0), n = base.length;
    if (gcd(a, n) !== 1) return "";
    if (dec) { a = inv(a, n); if (a < 0) return ""; b = -a * b; }
    return arr(s).map(function (ch) {
      var idx = base.indexOf(ch.toUpperCase());
      if (idx < 0) return ch;
      var out = base[mod(a * idx + b, n)];
      return o.preserveCase && ch === ch.toLowerCase() ? out.toLowerCase() : out;
    }).join("");
  }
  function rot(s, kind, dec) {
    var sign = dec ? -1 : 1;
    return arr(s).map(function (ch) {
      var code = ch.charCodeAt(0);
      if (kind === "rot47" && code >= 33 && code <= 126) return String.fromCharCode(33 + mod((code - 33) + sign * 47, 94));
      if ((kind === "rot5" || kind === "rot18") && /[0-9]/.test(ch)) return String.fromCharCode(48 + mod((code - 48) + sign * 5, 10));
      if ((kind === "rot13" || kind === "rot18") && /[A-Za-z]/.test(ch)) {
        var b = ch === ch.toLowerCase() ? 97 : 65;
        return String.fromCharCode(b + mod((code - b) + sign * 13, 26));
      }
      return ch;
    }).join("");
  }
  function vigenere(s, key, dec, o) {
    key = String(key || "").toUpperCase().replace(/[^A-Z]/g, "");
    if (!key) return "";
    var i = 0;
    return arr(s).map(function (ch) {
      if (!/[A-Za-z]/.test(ch)) return ch;
      var b = ch === ch.toLowerCase() ? 97 : 65, k = key.charCodeAt(i++ % key.length) - 65;
      var out = String.fromCharCode(b + mod((ch.charCodeAt(0) - b) + (dec ? -k : k), 26));
      return o.preserveCase ? out : out.toUpperCase();
    }).join("");
  }
  function bacon(s, variant, dec) {
    var base = variant === "extended" ? U : "ABCDEFGHIKLMNOPQRSTUWXYZ";
    if (!dec) return arr(s).map(function (ch) {
      var u = ch.toUpperCase();
      if (base.length === 24 && u === "J") u = "I";
      if (base.length === 24 && u === "V") u = "U";
      var idx = base.indexOf(u);
      return idx < 0 ? ch : idx.toString(2).padStart(5, "0").replace(/0/g, "A").replace(/1/g, "B");
    }).join(" ");
    var bits = String(s || "").toUpperCase().replace(/[^AB]/g, "").replace(/A/g, "0").replace(/B/g, "1"), out = [];
    for (var i = 0; i + 4 < bits.length; i += 5) out.push(base[parseInt(bits.slice(i, i + 5), 2)] || "?");
    return out.join("");
  }
  function rail(s, rails, dec) {
    rails = Math.max(2, Number(rails || 2) | 0);
    var cs = arr(s), len = cs.length;
    if (rails >= len) return s;
    var pat = [], r = 0, d = 1;
    for (var i = 0; i < len; i++) { pat.push(r); if (r === 0) d = 1; else if (r === rails - 1) d = -1; r += d; }
    if (!dec) {
      var rows = Array.from({ length: rails }, function () { return []; });
      cs.forEach(function (c, i2) { rows[pat[i2]].push(c); });
      return rows.map(function (row) { return row.join(""); }).join("");
    }
    var counts = Array.from({ length: rails }, function () { return 0; });
    pat.forEach(function (p) { counts[p]++; });
    var slices = [], pos = 0;
    counts.forEach(function (c) { slices.push(cs.slice(pos, pos + c)); pos += c; });
    var used = Array.from({ length: rails }, function () { return 0; });
    return pat.map(function (p) { return slices[p][used[p]++]; }).join("");
  }
  function b32(s, dec, hex, pad) {
    var alp = hex ? "0123456789ABCDEFGHIJKLMNOPQRSTUV" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    if (!dec) {
      var bs = bytes(s), out = "", val = 0, bits = 0;
      for (var i = 0; i < bs.length; i++) { val = (val << 8) | bs[i]; bits += 8; while (bits >= 5) { out += alp[(val >>> (bits - 5)) & 31]; bits -= 5; } }
      if (bits > 0) out += alp[(val << (5 - bits)) & 31];
      if (pad !== false) while (out.length % 8) out += "=";
      return out;
    }
    var map = {}, v = 0, b = 0, res = [];
    for (var j = 0; j < alp.length; j++) map[alp[j]] = j;
    arr(String(s || "").toUpperCase().replace(/=+$/g, "")).forEach(function (ch) {
      if (!(ch in map)) return;
      v = (v << 5) | map[ch]; b += 5;
      if (b >= 8) { res.push((v >>> (b - 8)) & 255); b -= 8; }
    });
    return text(Uint8Array.from(res));
  }
  function b64(s, dec, url) {
    if (!dec) return btoa(bin(bytes(s))).replace(/\+/g, url ? "-" : "+").replace(/\//g, url ? "_" : "/");
    var t = String(s || "").replace(/\s+/g, "");
    if (url) t = t.replace(/-/g, "+").replace(/_/g, "/");
    while (t.length % 4) t += "=";
    var raw = atob(t), out = [];
    for (var i = 0; i < raw.length; i++) out.push(raw.charCodeAt(i));
    return text(Uint8Array.from(out));
  }
  function a85(s, dec, adobe) {
    if (!dec) {
      var bs = bytes(s), out = [], i = 0;
      while (i < bs.length) {
        var remain = Math.min(4, bs.length - i), chunk = [0, 0, 0, 0];
        for (var j = 0; j < remain; j++) chunk[j] = bs[i + j];
        i += remain;
        var v = (((chunk[0] * 256 + chunk[1]) * 256 + chunk[2]) * 256 + chunk[3]) >>> 0, digs = ["", "", "", "", ""];
        for (var k = 4; k >= 0; k--) { digs[k] = String.fromCharCode((v % 85) + 33); v = Math.floor(v / 85); }
        out.push(digs.join("").slice(0, remain + 1));
      }
      return (adobe !== false ? "<~" : "") + out.join("") + (adobe !== false ? "~>" : "");
    }
    var clean = String(s || "").replace(/<~|~>/g, "").replace(/\s+/g, ""), bytesOut = [], group = "";
    arr(clean).forEach(function (ch) {
      if (ch === "z") { bytesOut.push(0, 0, 0, 0); return; }
      group += ch;
      if (group.length === 5) {
        var v = 0;
        for (var i = 0; i < 5; i++) v = v * 85 + (group.charCodeAt(i) - 33);
        bytesOut.push((v >>> 24) & 255, (v >>> 16) & 255, (v >>> 8) & 255, v & 255);
        group = "";
      }
    });
    if (group) {
      var p = 5 - group.length;
      while (group.length < 5) group += "u";
      var vv = 0;
      for (var q = 0; q < 5; q++) vv = vv * 85 + (group.charCodeAt(q) - 33);
      bytesOut = bytesOut.concat([(vv >>> 24) & 255, (vv >>> 16) & 255, (vv >>> 8) & 255, vv & 255].slice(0, 4 - p));
    }
    return text(Uint8Array.from(bytesOut));
  }
  function uni(s, dec, variant) {
    if (!dec) return arr(s).map(function (ch) { var h = ch.codePointAt(0).toString(16).toUpperCase().padStart(4, "0"); return variant === "escape" ? "\\u" + h : "U+" + h; }).join(" ");
    var toks = String(s || "").match(/(?:U\+[0-9A-Fa-f]{2,6}|\\u[0-9A-Fa-f]{4})/g);
    return toks ? toks.map(function (t) { return String.fromCodePoint(parseInt(t.slice(2), 16)); }).join("") : "";
  }
  function integer(s, dec, radix, width, signed) {
    radix = Number(radix || 16); width = Number(width || 8);
    var max = Math.pow(2, width), half = Math.pow(2, width - 1);
    if (!dec) return arr(s).map(function (ch) {
      var n = ch.codePointAt(0);
      if (signed && n >= half) n -= max;
      var v = Math.abs(n).toString(radix).toUpperCase();
      if (radix === 2) v = v.padStart(width, "0"); else if (radix === 8) v = v.padStart(Math.ceil(width / 3), "0"); else if (radix === 16) v = v.padStart(Math.ceil(width / 4), "0");
      return n < 0 ? "-" + v : v;
    }).join(" ");
    return String(s || "").trim().split(/[\s,;]+/).filter(Boolean).map(function (tok) {
      var neg = tok[0] === "-"; if (neg) tok = tok.slice(1);
      var n = parseInt(tok, radix); if (isNaN(n)) return "";
      if (neg) n = -n; if (signed && n < 0) n = max + n;
      return String.fromCodePoint(mod(n, max));
    }).join("");
  }
  function run(cipher, mode, s, o) {
    o = o || {};
    var dec = mode === "decrypt";
    switch (cipher) {
      case "caesar": return arr(s).map(function (ch) { var n = ch.charCodeAt(0), base = n >= 97 && n <= 122 ? 97 : (n >= 65 && n <= 90 ? 65 : 0); return base ? String.fromCharCode(base + mod(n - base + (dec ? -1 : 1) * Number(o.key || 0), 26)) : ch; }).join("");
      case "columnar": {
        var key = String(o.key || ""), cols = key.length, text = String(s || ""); if (cols < 2) return "";
        var order = arr(key).map(function (c, i) { return { c: c, i: i }; }).sort(function (a, b) { return a.c === b.c ? a.i - b.i : (a.c < b.c ? -1 : 1); });
        var rows = Math.ceil(text.length / cols), out = "", r, c, p;
        if (!dec) { var padded = text; while (padded.length < rows * cols) padded += "_"; order.forEach(function (entry) { for (r = 0; r < rows; r++) out += padded[r * cols + entry.i]; }); return out; }
        if (text.length % cols) return ""; var grid = []; for (c = 0; c < cols; c++) grid[c] = []; p = 0; order.forEach(function (entry) { for (r = 0; r < rows; r++) grid[entry.i][r] = text[p++]; }); for (r = 0; r < rows; r++) for (c = 0; c < cols; c++) out += grid[c][r]; return out;
      }
      case "morse": return morse(s, dec);
      case "spelling": return spelling(s, dec);
      case "affine": return affine(s, o, dec);
      case "rot": return rot(s, o.variant || "rot13", dec);
      case "vigenere": return vigenere(s, o.key || "", dec, o);
      case "bacon": return bacon(s, o.variant || "standard", dec);
      case "alpha_sub": {
        var base = alpha(o.alphaMode || "upper"), sub = o.variant === "manual" ? (o.manualAlphabet || base) : keywordAlphabet(o.keyword || "", base);
        return dec ? mapAlpha(s, sub, base, !!o.preserveCase) : mapAlpha(s, base, sub, !!o.preserveCase);
      }
      case "railfence": return rail(s, o.rails || 2, dec);
      case "base32": return b32(s, dec, (o.variant || "standard") === "hex", o.padding !== false);
      case "base64": return b64(s, dec, (o.variant || "standard") === "url");
      case "ascii85": return a85(s, dec, (o.variant || "adobe") === "adobe");
      case "unicode": return uni(s, dec, o.variant || "uplus");
      case "integer": return integer(s, dec, o.radix || 16, o.width || 8, !!o.signed);
      default: return "";
    }
  }
  // Every concrete cipher, in the order they are offered in the app's algorithm list.
  var CIPHERS = ["caesar", "columnar", "morse", "spelling", "affine", "rot", "vigenere", "bacon", "alpha_sub", "railfence", "base32", "base64", "ascii85", "unicode", "integer"];
  // Ciphers whose run() case reads o.key (as key, password or keyword).
  var KEYED = ["caesar", "columnar", "vigenere", "alpha_sub"];
  // Runs every concrete cipher and returns one labelled output line per cipher.
  function runEvery(mode, s, o) {
    var lines = [];
    CIPHERS.forEach(function (c) { lines.push("[" + c + "] " + run(c, mode, s, o)); });
    return lines;
  }
  function crackOne(cipher, s, o) {
    var cand = [];
    if (cipher === "all") {
      var lines = [];
      CIPHERS.forEach(function (c) { lines.push("[" + c + "]"); lines = lines.concat(crackOne(c, s, o)); lines.push(""); });
      return lines;
    }
    function add(label, plain) { if (plain) cand.push({ score: score(plain), line: label + " | " + plain }); }
    if (cipher === "caesar") for (var k = 1; k < 26; k++) add("shift=" + k, run("caesar", "decrypt", s, { key: k }));
    else if (cipher === "rot") ["rot5", "rot13", "rot18", "rot47"].forEach(function (v) { add(v, run("rot", "decrypt", s, { variant: v })); });
    else if (cipher === "affine") for (var a = 1; a < 26; a++) if (gcd(a, 26) === 1) for (var b = 0; b < 26; b++) add("a=" + a + " b=" + b, run("affine", "decrypt", s, { a: a, b: b, preserveCase: true }));
    else if (cipher === "railfence") for (var r = 2; r <= 12; r++) add("rails=" + r, run("railfence", "decrypt", s, { rails: r }));
    else if (cipher === "vigenere") String(o.wordlist || WORDS.join(" ")).split(/[\s,;]+/).filter(Boolean).forEach(function (k) { add("key=" + k, run("vigenere", "decrypt", s, { key: k, preserveCase: true })); });
    else add(cipher, run(cipher, "decrypt", s, o));
    cand.sort(function (a, b) { return b.score - a.score; });
    return cand.slice(0, 10).map(function (c) { return c.line; });
  }
  function makeApp(desc) {
    var unified = desc.extra && desc.extra.mode === "cryptography";
    var isCrack = desc.extra && desc.extra.mode === "crack";
    var algos = [["caesar", "Caesar"], ["columnar", "Columnar"], ["morse", "Morse Code"], ["spelling", "Spelling Alphabet"], ["affine", "Affine"], ["rot", "ROT"], ["vigenere", "Vigenere"], ["bacon", "Bacon"], ["alpha_sub", "Alphabetical Substitution"], ["railfence", "Railfence"], ["base32", "Base32"], ["base64", "Base64"], ["ascii85", "Ascii85"], ["unicode", "Unicode Notation"], ["integer", "Integer"]];
    if (isCrack || unified) algos = [["all", "All"]].concat(algos);
    var variants = { morse: [["standard", "Standard"]], spelling: [["nato", "NATO/ICAO"]], affine: [["numeric", "Numeric A/B"]], rot: [["rot5", "ROT5"], ["rot13", "ROT13"], ["rot18", "ROT18"], ["rot47", "ROT47"]], vigenere: [["manual", "Manual"], ["wordlist", "Wordlist"]], bacon: [["standard", "Standard"], ["extended", "Extended"]], alpha_sub: [["keyword", "Keyword"], ["manual", "Manual"]], railfence: [["zigzag", "Zigzag"]], base32: [["standard", "Standard"], ["hex", "Base32Hex"]], base64: [["standard", "Standard"], ["url", "URL-safe"]], ascii85: [["adobe", "Adobe"], ["bare", "Bare"]], unicode: [["uplus", "U+ notation"], ["escape", "\\u escape"]], integer: [["bin", "Binary"], ["oct", "Octal"], ["dec", "Decimal"], ["hex", "Hexadecimal"]], all: [["auto", "Auto"]] };
    return { id: desc.id, title: desc.title, glyph: desc.glyph || (isCrack ? "K" : "C"), kind: "script", width: 940, height: 620, menu: "Hacking Tools", external: true, showInMenu: true, singleton: true, render: function (body, win) {
      body.innerHTML = '<div class="pad" style="display:flex;flex-direction:column;gap:8px;height:100%"><div style="display:flex;gap:8px;flex-wrap:wrap"><select class="input cmode" style="min-width:120px"></select><select class="input csrc" style="min-width:110px"><option value="text">Text</option><option value="files">Files</option></select><select class="input calgo" style="min-width:190px"></select><select class="input cvar" style="min-width:160px"></select></div><div style="display:grid;grid-template-columns:1.35fr .95fr;gap:8px;min-height:0;flex:1"><div style="display:flex;flex-direction:column;gap:8px;min-height:0"><textarea class="input ctext" rows="7" placeholder="Text input"></textarea><div class="cfiles" style="display:none;border:1px solid var(--line);border-radius:6px;padding:8px;min-height:84px;overflow:auto"></div><textarea class="input cout" rows="8" readonly placeholder="Result"></textarea><div style="display:flex;gap:8px;flex-wrap:wrap"><button class="btn accent crun">' + (isCrack ? "Analyse" : "Run") + '</button><button class="btn csave">Save Output</button><button class="btn cclear">Clear</button><button class="btn cadd" style="display:none">Add File</button><button class="btn crem" style="display:none">Remove Selected</button><button class="btn cclrfiles" style="display:none">Clear Files</button></div></div><div class="opts" style="display:flex;flex-direction:column;gap:8px;min-height:0;overflow:auto"><input class="input ckey" placeholder="Key / password / keyword"><input class="input calpha" placeholder="Manual alphabet / substitution alphabet"><input class="input craw" placeholder="Affine A/B or rail count"><div style="display:flex;gap:8px"><input class="input cmax" type="number" min="1" max="12" value="12" style="flex:1" placeholder="Max key length"><input class="input cstep" type="number" min="1" value="400" style="flex:1" placeholder="Solver steps"></div><div style="display:flex;gap:8px"><select class="input cradix" style="flex:1"><option value="2">Binary</option><option value="8">Octal</option><option value="10">Decimal</option><option value="16" selected>Hex</option></select><select class="input cwidth" style="flex:1"><option value="8">8-bit</option><option value="16">16-bit</option><option value="32">32-bit</option></select></div><div style="display:flex;gap:8px;flex-wrap:wrap"><select class="input cpres"><option value="1">Preserve case</option><option value="0">Force upper</option></select><select class="input csigned"><option value="0">Unsigned</option><option value="1">Signed</option></select><select class="input cpad"><option value="1">Pad output</option><option value="0">No pad</option></select></div><div style="display:flex;gap:8px"><textarea class="input cwords" rows="6" placeholder="Wordlist (one key per line)" style="flex:1"></textarea><button class="btn cwordfile" style="align-self:flex-start">Wordlist File</button></div></div></div></div>';
      var mode = body.querySelector(".cmode"), src = body.querySelector(".csrc"), algo = body.querySelector(".calgo"), variant = body.querySelector(".cvar"), txt = body.querySelector(".ctext"), out = body.querySelector(".cout"), key = body.querySelector(".ckey"), alphaBox = body.querySelector(".calpha"), raw = body.querySelector(".craw"), radix = body.querySelector(".cradix"), width = body.querySelector(".cwidth"), preserve = body.querySelector(".cpres"), signed = body.querySelector(".csigned"), padding = body.querySelector(".cpad"), words = body.querySelector(".cwords"), filesWrap = body.querySelector(".cfiles"), addBtn = body.querySelector(".cadd"), remBtn = body.querySelector(".crem"), clearFilesBtn = body.querySelector(".cclrfiles"), wordFileBtn = body.querySelector(".cwordfile");
      (unified ? [["encrypt", "Encrypt"], ["decrypt", "Decrypt"], ["bruteforce", "Bruteforce"]] : (isCrack ? [["bruteforce", "Bruteforce"]] : [["encrypt", "Encrypt"], ["decrypt", "Decrypt"]])).forEach(function (m) { var o = document.createElement("option"); o.value = m[0]; o.textContent = m[1]; mode.appendChild(o); });
      algos.forEach(function (a) { var o = document.createElement("option"); o.value = a[0]; o.textContent = a[1]; algo.appendChild(o); });
      var files = [], selected = -1;
      function fillVariants() { variant.innerHTML = ""; (variants[algo.value] || [["standard", "Standard"]]).forEach(function (v) { var o = document.createElement("option"); o.value = v[0]; o.textContent = v[1]; variant.appendChild(o); }); }
      function show(el, yes) { el.style.display = yes ? "" : "none"; }
      function updateFields() {
        var a = algo.value, fileMode = src.value === "files";
        show(filesWrap, fileMode); show(txt, !fileMode); show(addBtn, fileMode); show(remBtn, fileMode); show(clearFilesBtn, fileMode);
        show(key, a === "all" || KEYED.indexOf(a) >= 0); show(alphaBox, a === "alpha_sub"); show(raw, ["affine", "railfence"].indexOf(a) >= 0);
        var cracking = mode.value === "bruteforce"; show(radix.parentNode, a === "integer" || (cracking && a === "all")); show(preserve.parentNode, ["affine", "vigenere", "alpha_sub"].indexOf(a) >= 0); show(words.parentNode, cracking && (a === "vigenere" || a === "all"));
      }
      function renderFiles() { filesWrap.innerHTML = files.length ? files.map(function (f, i) { return '<div data-i="' + i + '" style="padding:4px 6px;border-radius:4px;margin-bottom:4px;cursor:pointer;background:' + (i === selected ? "rgba(255,255,255,0.08)" : "transparent") + '">' + esc(f.name) + "</div>"; }).join("") : '<div class="muted">No files selected.</div>'; Array.prototype.slice.call(filesWrap.children).forEach(function (n) { n.onclick = function () { selected = Number(n.getAttribute("data-i")); renderFiles(); }; }); }
      function pickFile() { if (typeof AE3_pickFile !== "function") return; AE3_pickFile("open", { title: "Select file", start: window.AE3_HOME || "/home" }).then(function (p) { if (!p) return; files.push({ path: p, name: p.split("/").pop() }); selected = files.length - 1; renderFiles(); }); }
      function readFile(path) { return A3.request("fs_read", { path: path }).then(function (r) { return r && !r.error ? (r.content || "") : ""; }); }
      function inputs() { if (src.value !== "files") return Promise.resolve([{ name: "input", text: txt.value || "" }]); return Promise.all(files.map(function (f) { return readFile(f.path).then(function (t) { return { name: f.name, text: t }; }); })); }
      function opts() { var a = raw.value.trim().split(/[\/,\s]+/); return { variant: variant.value, key: key.value, keyword: key.value, manualAlphabet: alphaBox.value, a: a[0] || 1, b: a[1] || 0, rails: a[0] || 2, preserveCase: preserve.value === "1", wordlist: words.value, radix: Number(radix.value), width: Number(width.value), signed: signed.value === "1", padding: padding.value === "1" }; }
      function setOut(v) { out.value = Array.isArray(v) ? v.join("\n") : String(v || ""); }
      function runAll() {
        inputs().then(function (list) {
          var lines = [], o = opts(), cracking = mode.value === "bruteforce", every = algo.value === "all";
          if (!list.length) { setOut("No input."); return; }
          list.forEach(function (item) {
            if (list.length > 1) lines.push("[" + item.name + "]");
            // "All" encrypts/decrypts with every cipher and labels each output line; bruteforce has its own
            // all-cipher handling in crackOne.
            if (cracking) lines = lines.concat(crackOne(algo.value, item.text, o));
            else lines = lines.concat(every ? runEvery(mode.value, item.text, o) : [run(algo.value, mode.value, item.text, o)]);
            if (list.length > 1) lines.push("");
          });
          setOut(lines);
        });
      }
      fillVariants(); updateFields(); renderFiles();
      algo.onchange = function () { fillVariants(); updateFields(); }; mode.onchange = updateFields; src.onchange = updateFields; addBtn.onclick = pickFile; remBtn.onclick = function () { if (selected >= 0) { files.splice(selected, 1); selected = Math.min(selected, files.length - 1); renderFiles(); } }; clearFilesBtn.onclick = function () { files = []; selected = -1; renderFiles(); };
      wordFileBtn.onclick = function () { if (typeof AE3_pickFile !== "function") return; AE3_pickFile("open", { title: "Select wordlist", start: window.AE3_HOME || "/home" }).then(function (p) { if (!p) return; readFile(p).then(function (t) { words.value = t; }); }); };
      body.querySelector(".crun").onclick = runAll; body.querySelector(".cclear").onclick = function () { txt.value = ""; out.value = ""; files = []; selected = -1; renderFiles(); };
      body.querySelector(".csave").onclick = function () { if (typeof AE3_pickFile !== "function") return; AE3_pickFile("save", { title: "Save output", start: window.AE3_HOME || "/home", filename: algo.value + ".txt" }).then(function (p) { if (p) A3.request("fs_save", { path: p, content: out.value || "" }); }); };
      win.app.onClose = function () {};
    } };
  }
  window.RootCW_makeCipherApp = makeApp;
})();
