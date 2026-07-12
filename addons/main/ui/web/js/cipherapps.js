(function () {
  function esc(s) { return String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }
  function arr(s) { return Array.from(String(s || "")); }
  function mod(n, m) { return ((n % m) + m) % m; }
  function gcd(a, b) { while (b !== 0) { var t = b; b = a % b; a = t; } return Math.abs(a); }
  function inv(a, m) { a = mod(a, m); for (var i = 1; i < m; i++) if (mod(a * i, m) === 1) return i; return -1; }
  var U = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", L = "abcdefghijklmnopqrstuvwxyz";
  var WORDS = ["the", "and", "that", "have", "for", "not", "with", "you", "this", "secret", "password", "message", "root", "cipher"];
  // Punctuation carries its own prosign. Without them a full stop would pass through as a bare "." and
  // decode back as the letter E, so a sentence would not survive the round trip.
  var MORSE = { A: ".-", B: "-...", C: "-.-.", D: "-..", E: ".", F: "..-.", G: "--.", H: "....", I: "..", J: ".---", K: "-.-", L: ".-..", M: "--", N: "-.", O: "---", P: ".--.", Q: "--.-", R: ".-.", S: "...", T: "-", U: "..-", V: "...-", W: ".--", X: "-..-", Y: "-.--", Z: "--..", 0: "-----", 1: ".----", 2: "..---", 3: "...--", 4: "....-", 5: ".....", 6: "-....", 7: "--...", 8: "---..", 9: "----.", ".": ".-.-.-", ",": "--..--", "?": "..--..", "'": ".----.", "!": "-.-.--", "(": "-.--.", ")": "-.--.-", "&": ".-...", ":": "---...", ";": "-.-.-.", "=": "-...-", "+": ".-.-.", "-": "-....-", "_": "..--.-", '"': ".-..-.", $: "...-..-", "@": ".--.-." };
  var NATO = { A: "Alpha", B: "Bravo", C: "Charlie", D: "Delta", E: "Echo", F: "Foxtrot", G: "Golf", H: "Hotel", I: "India", J: "Juliett", K: "Kilo", L: "Lima", M: "Mike", N: "November", O: "Oscar", P: "Papa", Q: "Quebec", R: "Romeo", S: "Sierra", T: "Tango", U: "Uniform", V: "Victor", W: "Whiskey", X: "Xray", Y: "Yankee", Z: "Zulu", 0: "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine" };
  var MORSE_REV = {}, NATO_REV = {};
  Object.keys(MORSE).forEach(function (k) { MORSE_REV[MORSE[k]] = k; });
  Object.keys(NATO).forEach(function (k) { NATO_REV[NATO[k].toLowerCase()] = k; });
  function bytes(s) { return window.TextEncoder ? new TextEncoder().encode(String(s || "")) : Uint8Array.from(unescape(encodeURIComponent(String(s || ""))), function (c) { return c.charCodeAt(0); }); }
  function text(bs) { return window.TextDecoder ? new TextDecoder("utf-8", { fatal: false }).decode(bs) : decodeURIComponent(escape(String.fromCharCode.apply(null, bs))); }
  function bin(bs) { var s = ""; for (var i = 0; i < bs.length; i += 8192) s += String.fromCharCode.apply(null, bs.slice(i, i + 8192)); return s; }
  // How much a candidate plaintext reads like English. Letter counts alone are the wrong measure on the
  // short texts this app handles - one "q" or "z" in a fifty-letter message is far above its English
  // average and would condemn a perfectly good decrypt - so the judgement is made on letter pairs, which
  // stay stable at that length: "th" and "er" are common in any English sentence, "rh" and "tg" in none.
  function score(s) {
    var t = String(s || "").toLowerCase(), v = 0;
    for (var i = 0; i < t.length; i++) {
      var code = t.charCodeAt(i);
      if (code < 32 && code !== 9 && code !== 10) v -= 40; else if (code > 126) v -= 20;
    }
    var run = letters(s);
    if (run.length >= 2) v += (englishFit(run) + BIGRAM_FLOOR) * run.length;
    WORDS.forEach(function (w) { if (t.indexOf(w) >= 0) v += w.length * 8; });
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
    // Groups of five spell one letter, a wider gap ends a word, and anything that is not a group of five
    // A/B letters - a digit, a full stop - is passed through untouched. Reading only the A's and B's would
    // throw away every space and every number in the message.
    return String(s || "").trim().split(/\s{2,}/).map(function (word) {
      return word.split(/\s+/).map(function (group) {
        var u = group.toUpperCase();
        if (!/^[AB]{5}$/.test(u)) return group;
        return base[parseInt(u.replace(/A/g, "0").replace(/B/g, "1"), 2)] || "?";
      }).join("");
    }).join(" ");
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
  // Caesar's shift, taken from its own field and falling back to a numeric key (the bruteforce path
  // and a single-cipher run both pass one). Returns null when no usable number was given.
  function caesarShift(o) {
    var v = (o.shift !== undefined && String(o.shift).trim() !== "") ? o.shift : o.key;
    if (v === undefined || v === null || String(v).trim() === "") return null;
    var n = Number(v);
    return isFinite(n) ? mod(Math.round(n), 26) : null;
  }
  // The variants each cipher understands, first entry being its default. One dropdown cannot speak for
  // fifteen ciphers at once, so an "All" run - which selects no cipher-specific variant - and any
  // mismatched selection both fall back to the cipher's own default instead of reaching run() as an
  // unknown value that silently returns the input untouched.
  var VARIANTS = {
    caesar: ["standard"], columnar: ["standard"], morse: ["standard"], spelling: ["nato"],
    affine: ["numeric"], rot: ["rot13", "rot5", "rot18", "rot47"], vigenere: ["manual", "wordlist"],
    bacon: ["standard", "extended"], alpha_sub: ["keyword", "manual"], railfence: ["zigzag"],
    base32: ["standard", "hex"], base64: ["standard", "url"], ascii85: ["adobe", "bare"],
    unicode: ["uplus", "escape"], integer: ["bin", "oct", "dec", "hex"]
  };
  function variantOf(cipher, o) {
    var list = VARIANTS[cipher] || ["standard"];
    var v = o && o.variant;
    return list.indexOf(v) >= 0 ? v : list[0];
  }
  // Affine's A and B share one free-text field, so they arrive as strings and may be blank. Returns null
  // when the pair is unusable - a blank field is not silently treated as a=1 b=0, which is the identity
  // map and would hand back the plaintext as if it had been encrypted.
  function affineParams(o) {
    var a = Number(o.a), b = Number(o.b);
    if (String(o.a === undefined ? "" : o.a).trim() === "" || !isFinite(a) || !isFinite(b)) return null;
    a = mod(Math.round(a), 26);
    if (gcd(a, 26) !== 1) return null;
    return [a, mod(Math.round(b), 26)];
  }
  // The substitution alphabet: a typed manual alphabet always wins, so an operator who fills that field
  // sees it used even during an "All" run that cannot select the Manual variant on its own.
  function subAlphabet(o, base) {
    var manual = String(o.manualAlphabet || "").toUpperCase().replace(/[^A-Z]/g, "");
    if (manual.length === base.length) return manual;
    if (variantOf("alpha_sub", o) === "manual") return "";
    return keywordAlphabet(o.keyword || "", base);
  }
  function run(cipher, mode, s, o) {
    o = o || {};
    var dec = mode === "decrypt";
    switch (cipher) {
      // Caesar shifts by a number, never by a word: a text key yields NaN and would map every letter to
      // a null character, so the shift comes from its own field (o.shift) and falls back to a numeric key.
      case "caesar": {
        var caesarKey = caesarShift(o);
        if (caesarKey === null) return "";
        return arr(s).map(function (ch) { var n = ch.charCodeAt(0), base = n >= 97 && n <= 122 ? 97 : (n >= 65 && n <= 90 ? 65 : 0); return base ? String.fromCharCode(base + mod(n - base + (dec ? -1 : 1) * caesarKey, 26)) : ch; }).join("");
      }
      case "columnar": {
        var key = String(o.key || ""), cols = key.length, text = String(s || ""); if (cols < 2) return "";
        var order = arr(key).map(function (c, i) { return { c: c, i: i }; }).sort(function (a, b) { return a.c === b.c ? a.i - b.i : (a.c < b.c ? -1 : 1); });
        var rows = Math.ceil(text.length / cols), out = "", r, c, p;
        if (!dec) { var padded = text; while (padded.length < rows * cols) padded += "_"; order.forEach(function (entry) { for (r = 0; r < rows; r++) out += padded[r * cols + entry.i]; }); return out; }
        if (text.length % cols) return ""; var grid = []; for (c = 0; c < cols; c++) grid[c] = []; p = 0; order.forEach(function (entry) { for (r = 0; r < rows; r++) grid[entry.i][r] = text[p++]; }); for (r = 0; r < rows; r++) for (c = 0; c < cols; c++) out += grid[c][r]; return out;
      }
      case "morse": return morse(s, dec);
      case "spelling": return spelling(s, dec);
      case "affine": {
        var ab = affineParams(o);
        if (ab === null) return "";
        return affine(s, { a: ab[0], b: ab[1], alphaMode: o.alphaMode, preserveCase: o.preserveCase }, dec);
      }
      case "rot": return rot(s, variantOf("rot", o), dec);
      case "vigenere": return vigenere(s, o.key || "", dec, o);
      case "bacon": return bacon(s, variantOf("bacon", o), dec);
      case "alpha_sub": {
        var base = alpha(o.alphaMode || "upper"), sub = subAlphabet(o, base);
        if (sub === "") return "";
        return dec ? mapAlpha(s, sub, base, !!o.preserveCase) : mapAlpha(s, base, sub, !!o.preserveCase);
      }
      case "railfence": return rail(s, Number(o.rails) || 2, dec);
      case "base32": return b32(s, dec, variantOf("base32", o) === "hex", o.padding !== false);
      case "base64": return b64(s, dec, variantOf("base64", o) === "url");
      case "ascii85": return a85(s, dec, variantOf("ascii85", o) === "adobe");
      case "unicode": return uni(s, dec, variantOf("unicode", o));
      case "integer": return integer(s, dec, o.radix || 16, o.width || 8, !!o.signed);
      default: return "";
    }
  }
  // Every concrete cipher, in the order they are offered in the app's algorithm list.
  var CIPHERS = ["caesar", "columnar", "morse", "spelling", "affine", "rot", "vigenere", "bacon", "alpha_sub", "railfence", "base32", "base64", "ascii85", "unicode", "integer"];
  // Ciphers whose run() case reads o.key (as key, password or keyword).
  var KEYED = ["caesar", "columnar", "vigenere", "alpha_sub"];
  // Why a cipher cannot run with the options given, or "" when it can. Reported in place of its output
  // so an unusable option shows as a reason instead of an empty or corrupted line.
  function optionProblem(cipher, mode, s, o) {
    if (cipher === "caesar" && caesarShift(o) === null) return "needs a whole-number Caesar shift (0-25)";
    if (cipher === "columnar") {
      var key = String(o.key || "");
      if (key.length < 2) return "needs a key of 2 or more characters";
      if (mode === "decrypt" && String(s || "").length % key.length) return "ciphertext length must be a multiple of the key length";
    }
    if (cipher === "affine" && affineParams(o) === null) return "needs A and B, e.g. 5/8, with A sharing no factor with 26";
    if (cipher === "vigenere" && String(o.key || "").replace(/[^A-Za-z]/g, "") === "") return "needs a key of one or more letters";
    if (cipher === "alpha_sub") {
      var manual = String(o.manualAlphabet || "").replace(/[^A-Za-z]/g, "");
      if (manual !== "" && manual.length !== 26) return "manual alphabet needs all 26 letters";
      if (manual === "" && String(o.keyword || "") === "") return "needs a keyword or a manual alphabet";
    }
    return "";
  }
  // Runs every concrete cipher and returns one labelled output line per cipher.
  function runEvery(mode, s, o) {
    var lines = [];
    CIPHERS.forEach(function (c) {
      var problem = optionProblem(c, mode, s, o), outText = "";
      if (!problem) {
        try { outText = run(c, mode, s, o); } catch (e) { problem = "cannot read this input"; }
        if (!problem && outText === "") problem = "cannot read this input";
      }
      lines.push("[" + c + "] " + (problem ? "(" + problem + ")" : outText));
    });
    return lines;
  }

  // ---- Analysis ----------------------------------------------------------------------------------
  // A sample of ordinary English. Nothing here is read as text: it is counted once at load to learn how
  // often each letter pair occurs, which is the yardstick every candidate plaintext is measured against.
  var CORPUS = "the quick men who guard the station were told to hold their ground until the morning came and the road was clear again. she said that the message would reach headquarters before the next patrol left the valley, and that nothing else needed to be done for now. it is not the first time that a signal has been lost in the mountains, and it will not be the last, but there is no reason to believe that the enemy has broken into our network. every operator knows that a password is only as good as the person who keeps it, and that a careless word in the wrong room can undo a month of careful work. when the light failed they used a hand lamp, and when the lamp failed they counted the steps between the door and the wall. we have four hours before the convoy moves, which should be enough to finish the report, check the radio, and get some sleep. the young officer asked whether the orders had changed, and the sergeant told him that orders never change, only the weather does. outside, the rain kept falling on the roof of the old house, and somewhere down the hill a dog was barking at nothing at all. by the time the sun came up the water had risen over the bridge, so they took the long way round through the trees and reached the camp with an hour to spare. he wrote the numbers down in a small book, closed it, and put it back in his coat pocket without saying a word to anyone. there are things you learn only by doing them, and this was one of them.";
  var BIGRAM = (function () {
    var t = CORPUS.toUpperCase().replace(/[^A-Z]/g, ""), counts = {}, m = {}, i, j, g;
    for (i = 0; i < t.length - 1; i++) { g = t.substr(i, 2); counts[g] = (counts[g] || 0) + 1; }
    var total = (t.length - 1) + 676;
    for (i = 0; i < 26; i++) for (j = 0; j < 26; j++) { g = U[i] + U[j]; m[g] = Math.log(((counts[g] || 0) + 1) / total); }
    return m;
  })();
  // Shifts the fitness so that English lands well above zero and noise below it, which lets score() weigh
  // it against the word bonus and the unprintable-byte penalty on one scale.
  var BIGRAM_FLOOR = 7.4;
  // The pair fitness a text has to reach before it counts as readable English.
  var FIT_ENGLISH = -6.1;
  // How closely the letter counts have to match English before the text counts as English letters that
  // were merely moved around.
  var FIT_LETTERS = 0.88;
  // The bar a recovered repeating key has to clear, once charged for its own length. A key search always
  // squeezes some English out of any text, so this sits below the plain reading bar: what matters is that
  // a real key beats what the search manages on a text that has no key at all.
  var FIT_VIGENERE = -6.25;
  // How often each letter appears in English. A transposition shuffles the letters without replacing any,
  // so it leaves these counts intact even though it destroys every letter pair - which is exactly what
  // tells a reordering apart from a substitution.
  var ENGLISH = [8.17, 1.49, 2.78, 4.25, 12.70, 2.23, 2.02, 6.09, 6.97, 0.15, 0.77, 4.03, 2.41, 6.75, 7.51, 1.93, 0.10, 5.99, 6.33, 9.06, 2.76, 0.98, 2.36, 0.15, 1.97, 0.07];
  function letters(s) { return String(s || "").toUpperCase().replace(/[^A-Z]/g, ""); }
  // Cosine similarity between the text's letter counts and English's. 1 is a perfect match.
  function letterFit(t) {
    if (!t.length) return 0;
    var f = [], i, dot = 0, na = 0, nb = 0;
    for (i = 0; i < 26; i++) f.push(0);
    for (i = 0; i < t.length; i++) f[t.charCodeAt(i) - 65]++;
    for (i = 0; i < 26; i++) {
      var a = f[i] / t.length, b = ENGLISH[i] / 100;
      dot += a * b; na += a * a; nb += b * b;
    }
    return dot / (Math.sqrt(na) * Math.sqrt(nb) || 1);
  }
  // Mean log-likelihood of the text's letter pairs under the corpus. Higher reads more like English.
  function englishFit(t) {
    if (t.length < 2) return -BIGRAM_FLOOR;
    var v = 0;
    for (var i = 0; i < t.length - 1; i++) v += BIGRAM[t.substr(i, 2)];
    return v / (t.length - 1);
  }
  // Index of coincidence: near 0.066 for a text enciphered with one alphabet (the letter frequencies are
  // only moved around), near 0.038 for one enciphered with many (a repeating key flattens them).
  function ic(t) {
    var n = t.length;
    if (n < 2) return 0;
    var f = {}, sum = 0;
    for (var i = 0; i < n; i++) f[t[i]] = (f[t[i]] || 0) + 1;
    Object.keys(f).forEach(function (k) { sum += f[k] * (f[k] - 1); });
    return sum / (n * (n - 1));
  }
  // The single shift that brings a letter run closest to English, with the fitness it reaches.
  function bestShift(t) {
    var best = 0, bestV = -1e9;
    for (var k = 0; k < 26; k++) {
      var d = "";
      for (var i = 0; i < t.length; i++) d += U[mod(t.charCodeAt(i) - 65 - k, 26)];
      var v = englishFit(d);
      if (v > bestV) { bestV = v; best = k; }
    }
    return [best, bestV];
  }
  function bestAffine(t) {
    var bestA = 1, bestB = 0, bestV = -1e9;
    for (var a = 1; a < 26; a++) {
      if (gcd(a, 26) !== 1) continue;
      for (var b = 0; b < 26; b++) {
        var v = englishFit(letters(affine(t, { a: a, b: b }, true)));
        if (v > bestV) { bestV = v; bestA = a; bestB = b; }
      }
    }
    return [bestA, bestB, bestV];
  }
  // A decode attempt that answers "" instead of throwing, and a check that what came back is text a
  // person could read rather than binary noise.
  function decode(cipher, s, o) {
    try { return run(cipher, "decrypt", s, o); } catch (e) { return ""; }
  }
  function readable(s) {
    var t = String(s || "");
    if (t.length < 4) return false;
    var ok = 0;
    for (var i = 0; i < t.length; i++) {
      var c = t.charCodeAt(i);
      if (c === 9 || c === 10 || c === 13 || (c >= 32 && c <= 126)) ok++;
    }
    return ok / t.length > 0.9;
  }
  function englishWords(s) {
    var t = String(s || "").toLowerCase(), n = 0;
    WORDS.forEach(function (w) { if (t.indexOf(w) >= 0) n++; });
    return n;
  }
  // Ranks the ciphers the input could plausibly be, so an operator bruteforces the one that fits instead
  // of every keyspace at once. Charset and structure decide the encodings; index of coincidence and
  // chi-squared decide between the letter ciphers; an English letter mix with no readable words points
  // at a transposition. Confidence is a 0-100 plausibility, not a probability.
  function analyse(s, o) {
    o = o || {};
    var t = String(s || "").trim();
    if (!t) return [];
    var found = {};
    function add(cipher, confidence, why) {
      confidence = Math.max(0, Math.min(100, Math.round(confidence)));
      if (confidence <= 0) return;
      if (!found[cipher] || found[cipher].confidence < confidence) found[cipher] = { cipher: cipher, confidence: confidence, why: why };
    }
    var body = t.replace(/\s+/g, ""), toks = t.split(/\s+/).filter(Boolean), L = letters(t);

    if (body.length && /^[.\-\/|]+$/.test(body) && /[.\-]/.test(body)) add("morse", 99, "only dots, dashes and separators");
    var natoTokens = toks.filter(function (p) { return p !== "/" && p !== "|"; });
    var natoHits = natoTokens.filter(function (p) { return NATO_REV[p.toLowerCase()] !== undefined; }).length;
    if (natoTokens.length && natoHits / natoTokens.length >= 0.6) add("spelling", 100 * natoHits / natoTokens.length, natoHits + " of " + natoTokens.length + " tokens are spelling-alphabet words");
    if (/^(?:U\+[0-9A-Fa-f]{2,6}|\\u[0-9A-Fa-f]{4}|\s)+$/.test(t)) add("unicode", 99, "every token is a code point");
    var ab = t.replace(/[^A-Za-z]/g, "");
    if (ab.length >= 5 && /^[ABab]+$/.test(ab) && ab.length % 5 === 0) add("bacon", 95, "only the letters A and B, in groups of five");
    // An alphabet check alone is not enough: plain English written without punctuation also fits the
    // Base64 alphabet. An encoding only counts when decoding it actually yields readable text.
    if (/^[A-Z2-7=]+$/.test(body) && body.length % 8 === 0 && body.length >= 8 && readable(decode("base32", t, o))) add("base32", 90, "Base32 alphabet that decodes to readable text");
    if (/^[A-Za-z0-9+/]+={0,2}$/.test(body) && body.length % 4 === 0 && body.length >= 8 && readable(decode("base64", t, o))) add("base64", 88, "Base64 alphabet that decodes to readable text");
    if (/^<~[\s\S]*~>$/.test(t)) add("ascii85", 96, "wrapped in the Adobe Ascii85 delimiters");
    else if (/^[!-u]+$/.test(body) && body.length >= 8 && readable(decode("ascii85", t, o))) add("ascii85", 55, "Ascii85 alphabet that decodes to readable text");
    var radix = Number(o.radix) || 16;
    var numeric = toks.filter(function (p) { return /^-?[0-9A-Za-z]+$/.test(p) && isFinite(parseInt(p, radix)) && /^-?[0-9A-Fa-f]+$/.test(p); }).length;
    if (toks.length > 2 && numeric === toks.length) add("integer", 85, "every token parses as a number in base " + radix);

    if (L.length >= 20) {
      var icv = ic(L), sh = bestShift(L), fit = englishFit(L), words = englishWords(t);
      var punctuation = body.replace(/[A-Za-z0-9]/g, "").length / body.length;
      if (punctuation > 0.25 && /[!-~]/.test(body)) add("rot", 45, "dense printable punctuation, which ROT47 produces");
      if (fit >= FIT_ENGLISH && words >= 1) {
        // Readable words made of English letter pairs: nothing was substituted or moved.
        add("caesar", 5, "the text already reads as English");
      } else if (letterFit(L) >= FIT_LETTERS) {
        // English letter counts without English letter pairs: every letter of the message is still here,
        // just not where it was.
        add("railfence", 64, "English letter counts but no readable words: the letters were reordered, not replaced");
        add("columnar", t.indexOf("_") >= 0 ? 74 : 60, t.indexOf("_") >= 0 ? "reordered English letters padded with the columnar pad character" : "English letter counts but no readable words: the letters were reordered, not replaced");
      } else if (sh[1] >= FIT_ENGLISH) {
        add("caesar", 92, "a single shift of " + sh[0] + " restores readable English");
        add("rot", sh[0] === 13 ? 92 : 50, sh[0] === 13 ? "the restoring shift is 13, which is ROT13" : "the ROT variants are shifts of their own");
      } else if (bestAffine(L)[2] >= FIT_ENGLISH) {
        var af = bestAffine(L);
        add("affine", 85, "an affine map (a=" + af[0] + ", b=" + af[1] + ") restores readable English");
      } else {
        // Every letter still stands for exactly one other letter, so the alphabet was either replaced
        // wholesale or rotated by a repeating key. Index of coincidence cannot separate the two on a
        // message this short, so the repeating key is simply recovered and tried: if it reads back as
        // English, that is what the text is.
        var vFit = -1e9, vKey = "";
        vigenereKeys(t, 12).forEach(function (k) {
          var f = vigenereFit(t, k) - (Math.log(26) * k.length / L.length);
          if (f > vFit) { vFit = f; vKey = k; }
        });
        if (vFit >= FIT_VIGENERE) {
          add("vigenere", 88, "a recovered repeating key of " + vKey.length + " letters restores readable English");
        } else {
          add("alpha_sub", 72, "one alphabet throughout, undone by no shift, affine map or repeating key");
          add("vigenere", 30, "index of coincidence " + icv.toFixed(3) + " still leaves a repeating key possible");
        }
      }
    }

    return Object.keys(found).map(function (k) { return found[k]; }).sort(function (a, b) { return b.confidence - a.confidence; });
  }
  function analysisLines(ranked) {
    if (!ranked.length) return ["No cipher fits this input."];
    return ["Likely ciphers:"].concat(ranked.map(function (r) {
      return ("  " + r.confidence + "%").slice(-6) + "  " + (r.cipher + "          ").slice(0, 10) + " " + r.why;
    }));
  }

  // ---- Bruteforce -------------------------------------------------------------------------------
  // Every letter a Vigenere key touches is shifted by the same amount, so each column of the ciphertext -
  // the letters one key letter enciphered - is a Caesar shift of English on its own. A column is not a
  // sentence, so its shift is found on letter counts rather than letter pairs, which need running text.
  function bestColumnShift(col) {
    var best = 0, bestV = -1;
    for (var k = 0; k < 26; k++) {
      var d = "";
      for (var i = 0; i < col.length; i++) d += U[mod(col.charCodeAt(i) - 65 - k, 26)];
      var v = letterFit(d);
      if (v > bestV) { bestV = v; best = k; }
    }
    return best;
  }
  function vigenereFit(s, key) {
    return englishFit(letters(vigenere(s, key, true, { preserveCase: true })));
  }
  // Recovers a Vigenere key from the ciphertext alone. The columns give a first guess, but on a message
  // of a few dozen letters a single column is far too short for its letter counts to be trusted, so each
  // key letter is then re-chosen against the pairs of the whole decrypted message: the rest of the
  // plaintext supplies the evidence the column lacks. Repeated until no single letter can be bettered.
  function vigenereKeys(s, maxKey) {
    var t = letters(s);
    if (t.length < 16) return [];
    var scored = [], keys = [], n, i, j, pass;
    for (n = 1; n <= maxKey; n++) {
      var key = [];
      for (i = 0; i < n; i++) {
        var col = "";
        for (j = i; j < t.length; j += n) col += t[j];
        key.push(U[bestColumnShift(col)]);
      }
      for (pass = 0; pass < 4; pass++) {
        var moved = false;
        for (i = 0; i < n; i++) {
          var bestK = key[i], bestV = vigenereFit(s, key.join(""));
          for (var k = 0; k < 26; k++) {
            key[i] = U[k];
            var v = vigenereFit(s, key.join(""));
            if (v > bestV) { bestV = v; bestK = U[k]; moved = true; }
          }
          key[i] = bestK;
        }
        if (!moved) break;
      }
      // A longer key has more letters to bend towards the text and will always fit it a little better,
      // right up to a key as long as the message, which "decrypts" anything into anything. Each key
      // letter is charged what it costs to state - log(26) spread over the message - so a length only
      // wins if it explains the text by more than it costs to describe.
      scored.push({ key: key.join(""), fit: vigenereFit(s, key.join("")) - (Math.log(26) * n / t.length) });
    }
    scored.sort(function (a, b) { return b.fit - a.fit; });
    scored.slice(0, 3).forEach(function (e) { if (keys.indexOf(e.key) < 0) keys.push(e.key); });
    return keys;
  }
  // Every column order for a given key length, expressed as a key whose alphabetical order reproduces it.
  // Only lengths that divide the ciphertext can have produced it, and only short keys are searched in
  // full: 7 columns already means 5040 orders.
  function columnarKeys(s, maxKey, o) {
    var len = String(s || "").length, out = [], typed = String(o.key || "");
    if (typed.length >= 2 && len % typed.length === 0) out.push(typed);
    for (var cols = 2; cols <= Math.min(maxKey, 6); cols++) {
      if (len % cols) continue;
      perms(cols).forEach(function (p) {
        var chars = [];
        for (var r = 0; r < cols; r++) chars[p[r]] = U[r];
        var key = chars.join("");
        if (out.indexOf(key) < 0) out.push(key);
      });
    }
    return out;
  }
  function perms(n) {
    var base = [], out = [];
    for (var i = 0; i < n; i++) base.push(i);
    (function walk(left, acc) {
      if (!left.length) { out.push(acc); return; }
      left.forEach(function (x, i) { walk(left.slice(0, i).concat(left.slice(i + 1)), acc.concat([x])); });
    })(base, []);
    return out;
  }
  // Hill-climb a substitution alphabet: start from the frequency-matched guess, then keep any letter swap
  // that makes the plaintext read more like English. Restarts shake it out of a local best.
  function solveAlphaSub(s, steps) {
    var t = letters(s);
    if (t.length < 20) return "";
    var counts = {}, i;
    for (i = 0; i < 26; i++) counts[U[i]] = 0;
    for (i = 0; i < t.length; i++) counts[t[i]]++;
    var byFreq = U.split("").sort(function (a, b) { return counts[b] - counts[a]; });
    var order = "ETAOINSHRDLCUMWFGYPBVKJXQZ".split("");
    var sub = [];
    for (i = 0; i < 26; i++) sub[U.indexOf(order[i])] = byFreq[i];
    var best = sub.join(""), bestScore = score(mapAlpha(s, best, U, true));
    for (var restart = 0; restart < 3; restart++) {
      var cur = best.split(""), curScore = bestScore, stale = 0;
      while (stale < steps) {
        var x = Math.floor(Math.random() * 26), y = Math.floor(Math.random() * 26);
        if (x === y) continue;
        var swap = cur.slice();
        swap[x] = cur[y]; swap[y] = cur[x];
        var v = score(mapAlpha(s, swap.join(""), U, true));
        if (v > curScore) { cur = swap; curScore = v; stale = 0; } else { stale++; }
      }
      if (curScore > bestScore) { bestScore = curScore; best = cur.join(""); }
    }
    return best;
  }
  function crackOne(cipher, s, o) {
    o = o || {};
    if (cipher === "all") return crackAuto(s, o);
    var cand = [];
    var limit = Math.max(1, Math.min(100, Number(o.maxResults) || 10));
    var maxKey = Math.max(2, Math.min(12, Number(o.maxKeyLen) || 12));
    // A decoder handed the wrong kind of text throws (atob on non-Base64, for one). A throw costs that
    // one candidate, never the rest of the run. The bias charges a candidate for the size of the key that
    // produced it, so a long key cannot win simply by having more letters to bend towards the text.
    function attempt(label, options, bias) {
      var plain = "";
      try { plain = run(cipher, "decrypt", s, options); } catch (e) { return; }
      if (plain) cand.push({ score: score(plain) - (bias || 0), line: label + " | " + plain });
    }
    if (cipher === "caesar") {
      for (var k = 1; k < 26; k++) attempt("shift=" + k, { shift: k });
    } else if (cipher === "rot") {
      VARIANTS.rot.forEach(function (v) { attempt(v, { variant: v }); });
    } else if (cipher === "affine") {
      for (var a = 1; a < 26; a++) {
        if (gcd(a, 26) !== 1) continue;
        for (var b = 0; b < 26; b++) attempt("a=" + a + " b=" + b, { a: a, b: b, preserveCase: true });
      }
    } else if (cipher === "railfence") {
      for (var r = 2; r <= maxKey; r++) attempt("rails=" + r, { rails: r });
    } else if (cipher === "vigenere") {
      var keys = String(o.wordlist || "").split(/[\s,;]+/).filter(Boolean);
      if (String(o.key || "").trim() !== "") keys.unshift(String(o.key).trim());
      if (!keys.length) keys = WORDS.slice();
      vigenereKeys(s, maxKey).forEach(function (v) { if (keys.indexOf(v) < 0) keys.push(v); });
      keys.forEach(function (v) { attempt("key=" + v, { key: v, preserveCase: true }, Math.log(26) * v.length); });
    } else if (cipher === "columnar") {
      columnarKeys(s, maxKey, o).forEach(function (v) { attempt("key=" + v, { key: v }); });
    } else if (cipher === "alpha_sub") {
      var words = String(o.wordlist || "").split(/[\s,;]+/).filter(Boolean);
      if (String(o.keyword || "").trim() !== "") words.unshift(String(o.keyword).trim());
      words.forEach(function (v) { attempt("keyword=" + v, { keyword: v, variant: "keyword", preserveCase: true }); });
      var solved = solveAlphaSub(s, 200);
      if (solved) attempt("solved alphabet=" + solved, { variant: "manual", manualAlphabet: solved, preserveCase: true });
    } else {
      attempt(cipher, o);
    }
    cand.sort(function (x, y) { return y.score - x.score; });
    return cand.slice(0, limit).map(function (c) { return c.line; });
  }
  // "All" in bruteforce mode means auto: rank the ciphers first and only attack the ones the text
  // actually looks like, instead of grinding every keyspace on every run.
  function crackAuto(s, o) {
    var ranked = analyse(s, o);
    if (!ranked.length) return ["No cipher fits this input - nothing to bruteforce."];
    var lines = analysisLines(ranked).concat([""]);
    // A charset match is close to proof, so when one lands there is no reason to spend a keyspace search
    // on the weaker guesses underneath it. Without one, the field is open and the leaders are all tried.
    var cutoff = ranked[0].confidence >= 90 ? 85 : 40;
    ranked.filter(function (r) { return r.confidence >= cutoff; }).slice(0, 3).forEach(function (r) {
      var res = crackOne(r.cipher, s, o);
      lines.push("[" + r.cipher + "] " + r.confidence + "%");
      lines = lines.concat(res.length ? res : ["(no candidates)"]);
      lines.push("");
    });
    return lines;
  }
  function makeApp(desc) {
    var unified = desc.extra && desc.extra.mode === "cryptography";
    var isCrack = desc.extra && desc.extra.mode === "crack";
    var algos = [["caesar", "Caesar"], ["columnar", "Columnar"], ["morse", "Morse Code"], ["spelling", "Spelling Alphabet"], ["affine", "Affine"], ["rot", "ROT"], ["vigenere", "Vigenere"], ["bacon", "Bacon"], ["alpha_sub", "Alphabetical Substitution"], ["railfence", "Railfence"], ["base32", "Base32"], ["base64", "Base64"], ["ascii85", "Ascii85"], ["unicode", "Unicode Notation"], ["integer", "Integer"]];
    if (isCrack || unified) algos = [["all", "All"]].concat(algos);
    var variants = { morse: [["standard", "Standard"]], spelling: [["nato", "NATO/ICAO"]], affine: [["numeric", "Numeric A/B"]], rot: [["rot5", "ROT5"], ["rot13", "ROT13"], ["rot18", "ROT18"], ["rot47", "ROT47"]], vigenere: [["manual", "Manual"], ["wordlist", "Wordlist"]], bacon: [["standard", "Standard"], ["extended", "Extended"]], alpha_sub: [["keyword", "Keyword"], ["manual", "Manual"]], railfence: [["zigzag", "Zigzag"]], base32: [["standard", "Standard"], ["hex", "Base32Hex"]], base64: [["standard", "Standard"], ["url", "URL-safe"]], ascii85: [["adobe", "Adobe"], ["bare", "Bare"]], unicode: [["uplus", "U+ notation"], ["escape", "\\u escape"]], integer: [["bin", "Binary"], ["oct", "Octal"], ["dec", "Decimal"], ["hex", "Hexadecimal"]], all: [["auto", "Auto"]] };
    // Every option input sits in a labelled field so the operator can tell what each one expects
    // (which cipher reads it, and in what format) instead of guessing from a placeholder.
    // Layout lives in the stylesheet below, never in inline styles: updateFields() hides and re-shows
    // fields by writing element.style.display, which would wipe an inline display rule and collapse the
    // label, hint and control onto one line.
    var field = function (label, hint, cls, control) {
      return '<div class="cfield ' + cls + '">' +
        '<label>' + label + '</label>' +
        (hint ? '<div class="chint">' + hint + '</div>' : '') +
        control + '</div>';
    };
    var STYLE = '<style>' +
      '.rcw-crypto{display:flex;flex-direction:column;gap:12px;height:100%}' +
      '.rcw-crypto .ctop{display:flex;gap:8px;flex-wrap:wrap;flex:0 0 auto}' +
      '.rcw-crypto .cgrid{display:grid;grid-template-columns:1.4fr 1fr;gap:14px;flex:1;min-height:0}' +
      '.rcw-crypto .ccol{display:flex;flex-direction:column;gap:12px;min-height:0}' +
      '.rcw-crypto .copts{overflow-y:auto;padding-right:6px}' +
      '.rcw-crypto .cfield{display:flex;flex-direction:column;gap:4px;min-width:0}' +
      '.rcw-crypto .cfield > label{font-size:12px;font-weight:600;line-height:1.3}' +
      '.rcw-crypto .chint{font-size:11px;line-height:1.4;color:var(--muted)}' +
      '.rcw-crypto .cfield .input,.rcw-crypto .cfield textarea,.rcw-crypto .cfield select{width:100%}' +
      '.rcw-crypto .crow{display:flex;gap:8px}' +
      '.rcw-crypto .crow > *{flex:1;min-width:0}' +
      '.rcw-crypto .crow > .btn{flex:0 0 auto;align-self:flex-start}' +
      '.rcw-crypto .cfinput{flex:0 0 auto}' +
      '.rcw-crypto .ctext{min-height:120px;resize:none}' +
      '.rcw-crypto .cfresult{flex:1;min-height:160px}' +
      '.rcw-crypto .cout{flex:1;min-height:0;resize:none;font-family:monospace}' +
      '.rcw-crypto .cwords{min-height:110px;resize:none}' +
      '.rcw-crypto .cfiles{border:1px solid var(--line);border-radius:6px;padding:8px;min-height:84px;overflow:auto}' +
      '.rcw-crypto .cbtns{display:flex;gap:8px;flex-wrap:wrap;flex:0 0 auto}' +
      '</style>';
    return { id: desc.id, title: desc.title, glyph: desc.glyph || (isCrack ? "K" : "C"), kind: "script", width: 940, height: 760, menu: "Hacking Tools", external: true, showInMenu: true, singleton: true, render: function (body, win) {
      body.innerHTML = STYLE + '<div class="pad rcw-crypto"><div class="ctop"><select class="input cmode" style="min-width:120px"></select><select class="input csrc" style="min-width:110px"><option value="text">Text</option><option value="files">Files</option></select><select class="input calgo" style="min-width:190px"></select><select class="input cvar" style="min-width:160px"></select></div><div class="cgrid"><div class="ccol">' +
        field("Input", "Text to process", "cfinput", '<textarea class="input ctext" rows="5" placeholder="Text input"></textarea>') +
        '<div class="cfiles" style="display:none"></div>' +
        // The result box takes every remaining pixel of the column: an "All" run prints one labelled
        // line per cipher, far more than a fixed-height textarea can show.
        '<div class="cfield cfresult"><label>Result</label><textarea class="input cout" readonly placeholder="Result"></textarea></div>' +
        '<div class="cbtns"><button class="btn accent crun">' + (isCrack ? "Bruteforce" : "Run") + '</button><button class="btn canalyse">Analyse</button><button class="btn csave">Save Output</button><button class="btn cclear">Clear</button><button class="btn cadd" style="display:none">Add File</button><button class="btn crem" style="display:none">Remove Selected</button><button class="btn cclrfiles" style="display:none">Clear Files</button></div></div><div class="ccol copts">' +
        field("Key / password / keyword", "Columnar (2+ characters), Vigenere, Alphabetical Substitution", "cfkey", '<input class="input ckey" placeholder="e.g. SECRET">') +
        field("Caesar shift", "Whole number 0-25 - Caesar only, it cannot use a text key", "cfshift", '<input class="input cshift" type="number" min="0" max="25" value="3">') +
        field("Manual alphabet", "Substitution alphabet for Alphabetical Substitution", "cfalpha", '<input class="input calpha" placeholder="e.g. QWERTYUIOPASDFGHJKLZXCVBNM">') +
        field("Affine A/B or rail count", "Affine: two numbers (e.g. 5/8). Railfence: one number", "cfraw", '<input class="input craw" placeholder="e.g. 5/8 or 3">') +
        field("Bruteforce limits", "Longest key to try, and how many candidates to list", "cflimits", '<div class="crow"><input class="input cmax" type="number" min="2" max="12" value="12" placeholder="Max key length"><input class="input cstep" type="number" min="1" max="100" value="10" placeholder="Max results"></div>') +
        field("Integer notation", "Number base and word size", "cfint", '<div class="crow"><select class="input cradix"><option value="2">Binary</option><option value="8">Octal</option><option value="10">Decimal</option><option value="16" selected>Hex</option></select><select class="input cwidth"><option value="8">8-bit</option><option value="16">16-bit</option><option value="32">32-bit</option></select></div>') +
        field("Output options", "Letter case, sign and padding", "cfout", '<div class="crow"><select class="input cpres"><option value="1">Preserve case</option><option value="0">Force upper</option></select><select class="input csigned"><option value="0">Unsigned</option><option value="1">Signed</option></select><select class="input cpad"><option value="1">Pad output</option><option value="0">No pad</option></select></div>') +
        field("Wordlist", "One candidate key per line - Vigenere bruteforce", "cfwords", '<div class="crow"><textarea class="input cwords" rows="6" placeholder="Wordlist (one key per line)"></textarea><button class="btn cwordfile">Wordlist File</button></div>') +
        '</div></div></div>';
      var mode = body.querySelector(".cmode"), src = body.querySelector(".csrc"), algo = body.querySelector(".calgo"), variant = body.querySelector(".cvar"), txt = body.querySelector(".ctext"), out = body.querySelector(".cout"), key = body.querySelector(".ckey"), shift = body.querySelector(".cshift"), alphaBox = body.querySelector(".calpha"), raw = body.querySelector(".craw"), radix = body.querySelector(".cradix"), width = body.querySelector(".cwidth"), preserve = body.querySelector(".cpres"), signed = body.querySelector(".csigned"), padding = body.querySelector(".cpad"), words = body.querySelector(".cwords"), filesWrap = body.querySelector(".cfiles"), addBtn = body.querySelector(".cadd"), remBtn = body.querySelector(".crem"), clearFilesBtn = body.querySelector(".cclrfiles"), wordFileBtn = body.querySelector(".cwordfile");
      var maxLen = body.querySelector(".cmax"), maxResults = body.querySelector(".cstep"), analyseBtn = body.querySelector(".canalyse");
      var fieldOf = function (el) { return el.closest(".cfield") || el; };
      (unified ? [["encrypt", "Encrypt"], ["decrypt", "Decrypt"], ["bruteforce", "Bruteforce"]] : (isCrack ? [["bruteforce", "Bruteforce"]] : [["encrypt", "Encrypt"], ["decrypt", "Decrypt"]])).forEach(function (m) { var o = document.createElement("option"); o.value = m[0]; o.textContent = m[1]; mode.appendChild(o); });
      algos.forEach(function (a) { var o = document.createElement("option"); o.value = a[0]; o.textContent = a[1]; algo.appendChild(o); });
      var files = [], selected = -1;
      function fillVariants() { variant.innerHTML = ""; (variants[algo.value] || [["standard", "Standard"]]).forEach(function (v) { var o = document.createElement("option"); o.value = v[0]; o.textContent = v[1]; variant.appendChild(o); }); }
      function show(el, yes) { el.style.display = yes ? "" : "none"; }
      function updateFields() {
        var a = algo.value, fileMode = src.value === "files", every = a === "all";
        show(filesWrap, fileMode); show(fieldOf(txt), !fileMode); show(addBtn, fileMode); show(remBtn, fileMode); show(clearFilesBtn, fileMode);
        // "All" runs every cipher in one pass, so it needs every option a cipher can read - not just
        // the key. Each cipher then takes the field that belongs to it and ignores the rest.
        show(fieldOf(key), every || KEYED.indexOf(a) >= 0);
        show(fieldOf(shift), every || a === "caesar");
        show(fieldOf(alphaBox), every || a === "alpha_sub");
        show(fieldOf(raw), every || ["affine", "railfence"].indexOf(a) >= 0);
        var cracking = mode.value === "bruteforce";
        show(fieldOf(radix), a === "integer" || every);
        show(fieldOf(preserve), every || ["affine", "vigenere", "alpha_sub"].indexOf(a) >= 0);
        show(fieldOf(words), cracking && (["vigenere", "alpha_sub"].indexOf(a) >= 0 || every));
        show(fieldOf(maxLen), cracking);
        // Analysis only names the cipher a ciphertext looks like, so it has nothing to say about text the
        // operator is about to encrypt.
        show(analyseBtn, mode.value !== "encrypt");
      }
      function renderFiles() { filesWrap.innerHTML = files.length ? files.map(function (f, i) { return '<div data-i="' + i + '" style="padding:4px 6px;border-radius:4px;margin-bottom:4px;cursor:pointer;background:' + (i === selected ? "rgba(255,255,255,0.08)" : "transparent") + '">' + esc(f.name) + "</div>"; }).join("") : '<div class="muted">No files selected.</div>'; Array.prototype.slice.call(filesWrap.children).forEach(function (n) { n.onclick = function () { selected = Number(n.getAttribute("data-i")); renderFiles(); }; }); }
      function pickFile() { if (typeof AE3_pickFile !== "function") return; AE3_pickFile("open", { title: "Select file", start: window.AE3_HOME || "/home" }).then(function (p) { if (!p) return; files.push({ path: p, name: p.split("/").pop() }); selected = files.length - 1; renderFiles(); }); }
      function readFile(path) { return A3.request("fs_read", { path: path }).then(function (r) { return r && !r.error ? (r.content || "") : ""; }); }
      function inputs() { if (src.value !== "files") return Promise.resolve([{ name: "input", text: txt.value || "" }]); return Promise.all(files.map(function (f) { return readFile(f.path).then(function (t) { return { name: f.name, text: t }; }); })); }
      // shift is Caesar's own field. When Caesar is the only selected cipher a numeric key still works,
      // so an operator who types the shift into the key box is not punished for it.
      function opts() {
        var a = raw.value.trim().split(/[\/,\s]+/).filter(Boolean);
        var caesarShift = shift.value;
        if (algo.value === "caesar" && String(caesarShift).trim() === "" && String(key.value).trim() !== "") caesarShift = key.value;
        return {
          variant: variant.value, key: key.value, keyword: key.value, shift: caesarShift,
          manualAlphabet: alphaBox.value, a: a[0], b: a[1] || 0, rails: a[0] || 2,
          preserveCase: preserve.value === "1", wordlist: words.value,
          radix: Number(radix.value), width: Number(width.value),
          signed: signed.value === "1", padding: padding.value === "1",
          maxKeyLen: Number(maxLen.value), maxResults: Number(maxResults.value)
        };
      }
      function setOut(v) { out.value = Array.isArray(v) ? v.join("\n") : String(v || ""); }
      // A single cipher gets the same option check the "All" pass gives each of its ciphers, so a missing
      // shift or an unusable affine pair reads as a reason rather than as silent output.
      function runOne(cipher, m, s, o) {
        var problem = optionProblem(cipher, m, s, o);
        if (problem) return "(" + problem + ")";
        var result = "";
        try { result = run(cipher, m, s, o); } catch (e) { return "(cannot read this input)"; }
        return result === "" ? "(cannot read this input)" : result;
      }
      function runAll() {
        inputs().then(function (list) {
          var lines = [], o = opts(), cracking = mode.value === "bruteforce", every = algo.value === "all";
          if (!list.length) { setOut("No input."); return; }
          list.forEach(function (item) {
            if (list.length > 1) lines.push("[" + item.name + "]");
            // "All" encrypts or decrypts with every cipher and labels each output line; in bruteforce it
            // means auto, and crackOne ranks the input before attacking anything.
            if (cracking) lines = lines.concat(crackOne(algo.value, item.text, o));
            else lines = lines.concat(every ? runEvery(mode.value, item.text, o) : [runOne(algo.value, mode.value, item.text, o)]);
            if (list.length > 1) lines.push("");
          });
          setOut(lines);
        });
      }
      // Names the ciphers the input could be and preselects the strongest, so the next Run in bruteforce
      // mode attacks one keyspace instead of fifteen.
      function analyseInput() {
        inputs().then(function (list) {
          var o = opts(), lines = [];
          if (!list.length) { setOut("No input."); return; }
          var top = "";
          list.forEach(function (item) {
            var ranked = analyse(item.text, o);
            if (list.length > 1) lines.push("[" + item.name + "]");
            lines = lines.concat(analysisLines(ranked));
            lines.push("");
            if (!top && ranked.length) top = ranked[0].cipher;
          });
          if (top && CIPHERS.indexOf(top) >= 0) { algo.value = top; fillVariants(); updateFields(); }
          setOut(lines);
        });
      }
      fillVariants(); updateFields(); renderFiles();
      algo.onchange = function () { fillVariants(); updateFields(); }; mode.onchange = updateFields; src.onchange = updateFields; addBtn.onclick = pickFile; remBtn.onclick = function () { if (selected >= 0) { files.splice(selected, 1); selected = Math.min(selected, files.length - 1); renderFiles(); } }; clearFilesBtn.onclick = function () { files = []; selected = -1; renderFiles(); };
      wordFileBtn.onclick = function () { if (typeof AE3_pickFile !== "function") return; AE3_pickFile("open", { title: "Select wordlist", start: window.AE3_HOME || "/home" }).then(function (p) { if (!p) return; readFile(p).then(function (t) { words.value = t; }); }); };
      body.querySelector(".crun").onclick = runAll; analyseBtn.onclick = analyseInput; body.querySelector(".cclear").onclick = function () { txt.value = ""; out.value = ""; files = []; selected = -1; renderFiles(); };
      body.querySelector(".csave").onclick = function () { if (typeof AE3_pickFile !== "function") return; AE3_pickFile("save", { title: "Save output", start: window.AE3_HOME || "/home", filename: algo.value + ".txt" }).then(function (p) { if (p) A3.request("fs_save", { path: p, content: out.value || "" }); }); };
      win.app.onClose = function () {};
    } };
  }
  window.RootCW_makeCipherApp = makeApp;
})();
