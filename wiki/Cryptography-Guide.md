# Cryptography Guide

End-to-end guide to the cipher tools: how a mission maker plants encrypted intel, and how a player reads it back with `crypto`, `crack`, and the Cryptography desktop app.

## Table of Contents

- [What the Cipher Tools Are](#what-the-cipher-tools-are)
- [Supported Algorithms](#supported-algorithms)
  - [At a Glance](#at-a-glance)
  - [Per-cipher reference](#morse)
  - [Reading crack Output](#reading-crack-output)
- [Player Workflow](#player-workflow)
- [Reading Intercepted Mail and Chat](#reading-intercepted-mail-and-chat)
- [Mission Maker Workflow](#mission-maker-workflow)
- [Troubleshooting](#troubleshooting)

---

## What the Cipher Tools Are

Two terminal commands and two desktop apps, all running the same cipher engine:

| Interface | Purpose |
|-----------|---------|
| `crypto` (terminal) | Encrypt or decrypt text or a file when the algorithm and key are known |
| `crack` (terminal) | Identify or brute-force a cipher when they are not |
| **Cryptography** app (desktop) | Point-and-click version of `crypto`, with file and message input sources |
| **Crack** app (desktop) | Point-and-click version of `crack` |

All four require the hacking toolset on the laptop - installed by the **Add Hacking Tools** module or delivered by a Rubberducky USB. On a laptop without the tools the commands do not exist and the apps do not appear.

---

## Supported Algorithms

Thirteen ciphers are offered by the `crypto` command and the Cryptography app; two more, Caesar and Columnar, come from AE3 and are reachable through file encryption and through `crack` (see [Caesar and Columnar](#caesar-and-columnar)).

### At a Glance

| Cipher | Kind | Key / options | Needs a key to break? |
|--------|------|---------------|-----------------------|
| `morse` | Substitution into dots and dashes | none | No |
| `spelling` | Substitution into the NATO alphabet | none | No |
| `rot` | Fixed-shift rotation | `--variant=rot5\|rot13\|rot18\|rot47` | No - four variants only |
| `affine` | Letter arithmetic | `a=<num> b=<num>` | Small keyspace |
| `vigenere` | Repeating-key shift | `-k=<word>` | Yes |
| `bacon` | Each letter becomes 5 A/B symbols | `--variant=standard\|extended` | No |
| `alpha_sub` | One fixed scrambled alphabet | `alphabet=<26 letters>` | Yes |
| `railfence` | Zig-zag transposition | `--rails=<num>` | Small keyspace |
| `base32` | Encoding | none | No |
| `base64` | Encoding | none | No |
| `ascii85` | Encoding | none | No |
| `unicode` | Code-point notation | none | No |
| `integer` | Numeric byte values | `radix=`, `width=`, `signed=` | No |

"Encoding" means the text is only re-written, not secured: anyone who recognises the format can read it back. Use those for flavour, and a keyed cipher when the mission wants a real obstacle.

Characters a cipher does not handle are passed through untouched - digits, punctuation and spaces survive a Vigenere run, for instance, which is also what makes a message's shape recognisable in the output.

---

### morse

Each letter or digit becomes its Morse code; groups are separated by a single space and a space in the text becomes `/`.

```sqf
crypto -m=encrypt -a=morse "HI THERE"
.... .. / - .... . .-. .
```

Decrypting accepts `/` or `|` as the word separator. Unknown symbols are dropped on the way back.

---

### spelling

The NATO spelling alphabet, same layout as Morse: one word per character, `/` for a space.

```sqf
crypto -m=encrypt -a=spelling "AB C"
Alpha Bravo / Charlie
```

---

### rot

Rotation by a fixed amount, chosen with `--variant` (default `rot13`):

| Variant | Affects | Shift |
|---------|---------|-------|
| `rot5` | digits only | 5 |
| `rot13` | letters only | 13 |
| `rot18` | letters and digits | 13 / 5 |
| `rot47` | every printable ASCII character | 47 |

```sqf
crypto -m=encrypt -a=rot --variant=rot13 "Attack at 5"
Nggnpx ng 5
```

Every ROT variant is its own inverse - each shift is exactly half its alphabet, so encrypting twice returns the original and `-m=decrypt` is a formality.

---

### affine

Each letter's position is put through `(a * x + b) mod 26`. Defaults are `a=5 b=8`. `a` must share no factor with 26 (1, 3, 5, 7, 9, 11, 15, 17, 19, 21, 23, 25); any other `a` returns an empty result rather than a wrong one. Case is preserved.

```sqf
crypto -m=encrypt -a=affine a=5 b=8 "attack"
izzisg
```

---

### vigenere

A repeating keyword shifts each letter by the position of the key letter (A shifts by 0, B by 1, and so on). Key defaults to `JSOC`; non-letters in the key are ignored, and non-letters in the text are passed through without consuming a key letter.

```sqf
crypto -m=encrypt -a=vigenere -k=LEMON "attack"
lxfopv
```

Decryption needs the same key. A longer key is stronger; a key as long as the message is unbreakable by the `crack` heuristic.

---

### bacon

Every letter becomes five `A`/`B` symbols, groups separated by spaces. The default `standard` variant uses the historical 24-letter alphabet, where I/J and U/V share a code; `--variant=extended` gives all 26 letters their own code.

```sqf
crypto -m=encrypt -a=bacon "AB"
AAAAA AAAAB
```

Decryption ignores everything that is not an A or a B, which is what allows the classic trick of hiding the pattern in the styling of an innocuous message.

---

### alpha_sub

One scrambled alphabet replaces the plain one, position for position. The default substitute is the keyboard-order alphabet `QWERTYUIOPASDFGHJKLZXCVBNM`, so A becomes Q, B becomes W, and so on. Supply your own with `alphabet=` - it must be 26 letters or it is ignored and the text comes back unchanged. Output is uppercase.

```sqf
crypto -m=encrypt -a=alpha_sub "cab"
EQW
```

---

### railfence

A transposition: the text is written in a zig-zag down and up a number of rails, then read off row by row. `--rails` defaults to 7. Letters are not changed, only reordered - which is the giveaway.

```sqf
crypto -m=encrypt -a=railfence --rails=3 "HELLOWORLD"
HOLELWRDLO
```

If the rail count is equal to or greater than the message length there is no zig-zag to make, and the text is returned unchanged.

---

### base32 / base64 / ascii85

Standard binary-to-text encodings. Base32 uses `A-Z2-7` and pads with `=`; Base64 uses the usual 64-character alphabet and pads with `=`; Ascii85 wraps its output in `<~` and `~>`.

```sqf
crypto -m=encrypt -a=base32 "Hi"
JBUQ====

crypto -m=encrypt -a=base64 "Hi"
SGk=

crypto -m=encrypt -a=ascii85 "Hi"
<~88/~>
```

Whitespace inside the input is ignored on decryption, so a value split across lines in a document still decodes.

---

### unicode

Each character becomes its code point in `U+XXXX` notation, separated by spaces. Decryption accepts `U+` or `\u` prefixes.

```sqf
crypto -m=encrypt -a=unicode "Hi"
U+0048 U+0069
```

---

### integer

Each character becomes its numeric byte value. Options: `radix=` (2, 8, 10 or 16 - default 16), `width=` bits (default 8), and `signed=1` to express high values as negatives. Binary, octal and hex output is zero-padded to the width; decimal is not.

```sqf
crypto -m=encrypt -a=integer radix=16 "Hi"
48 69

crypto -m=encrypt -a=integer radix=10 "Hi"
72 105

crypto -m=encrypt -a=integer radix=2 width=8 "Hi"
01001000 01101001
```

Decryption splits on spaces, commas or semicolons, so a list pasted in any of those forms works.

---

### Caesar and Columnar

These two come from AE3 rather than this mod. They appear in the encryption picker on the Add File modules and in a `crack -a=all` sweep, and are used the same way as the rest:

- **Caesar** - shifts every letter by a fixed number, `shift=` (default 7). The one-number version of Affine, and the first thing `crack` tries.
- **Columnar** - a keyword transposition: the text is written in rows under the keyword and read out in the keyword's alphabetical column order. Key defaults to `JSOC` and must be at least two characters.

---

### Reading `crack` Output

A brute-force run prints one block per cipher under a `[cipher]` header. Caesar and ROT have keyspaces small enough to print whole - all 26 shifts, all four variants - so every candidate is listed. Every other cipher is cut to the ten strongest candidates, ranked by a heuristic that rewards English letter frequency, spaces, and common words such as "the", "and", "message" and "secret". The top line is the best guess, not an answer: a short message or an unusual plaintext can easily rank below a wrong one.

---

## Player Workflow

### 1. Find the ciphertext

Encrypted content reaches a player as a downloaded file, a file already sitting on a laptop, an email, or a chat message.

### 2. Decrypt it when the algorithm is known

```sqf
crypto -m=decrypt -a=vigenere -k=LEMON "gvvcgb gv hbal"
crypto -m=decrypt -a=base64 /root/Downloads/message.txt
crypto -m=decrypt -a=rot --variant=13 /root/Downloads/orders.txt -o=/root/orders_plain.txt
```

`-o=` writes the result to a file instead of only printing it.

### 3. Crack it when it is not

```sqf
crack -a=rot  /root/Downloads/cipher.txt     # brute-force one cipher's keyspace
crack -a=all  /root/Downloads/cipher.txt     # try every cipher, rank the candidates
```

An `all` or brute-force run prints one block per cipher, each under its own `[cipher]` header and separated by blank lines, so a result that spans several lines can still be traced back to the cipher that produced it. Candidates are ranked by a letter-frequency and common-word heuristic - the top entry is a guess, not a verdict.

### 4. Or use the desktop

Open **Hackerman.exe** → **Cryptography**. Pick the mode, the algorithm, and the input source, then run. Results can be saved back into the laptop filesystem.

---

## Reading Intercepted Mail and Chat

The Cryptography app takes its input from three sources:

| Source | What it reads |
|--------|---------------|
| Text | Whatever is typed into the input box |
| File | Any file on the laptop the logged-in account may read |
| Messages | The laptop's inbox, sent mail, and chat conversations |

With **Messages** selected, the app lists the laptop's mail and chat traffic; picking an entry loads that message body straight into the input box. Nothing needs to be copied out by hand.

The reverse route also exists: in the Email and Messenger apps, right-click a message in the list, an open email, a single chat bubble, or a whole conversation, and choose **Send to Cryptography**. The app opens with that text already loaded. The entry only appears on laptops that carry the hacking toolset.

---

## Mission Maker Workflow

### Encrypt at mission build time (Eden)

The **Add Hackable File** module and AE3's own **Add File** module both expose cipher fields: pick the algorithm, set the key or variant, and type the plaintext. The module stores the encrypted form, so the file is already unreadable when the mission starts.

Watch the file rules while doing it - a path or owner containing a space is rejected and the module is removed at mission start. See the AE3 wiki's *Add Files and Folders* page for the full list.

### Encrypt during play (Zeus)

The **Cipher Tools** Zeus module encrypts or decrypts text on the fly, for intel a curator improvises mid-mission.

### Encrypt from a script

```sqf
private _options = createHashMap;
_options set ["key", "LEMON"];
private _cipherText = ["vigenere", "encrypt", "attack at dawn", _options] call Root_fnc_cipherProcess;

// Register the encrypted text as a downloadable file
[_server, "orders.enc", 10, _cipherText, 0, [], "", true] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
```

`Root_fnc_cipherOptionsFromText` turns a `crypto`-style option string such as `"-k=LEMON --variant=13"` into the hashmap this function expects. Full parameter reference: [Mission Maker Guide](Mission-Maker-Guide#cipher-functions).

### Design advice

- Give players the algorithm somewhere in the mission and make them find the key, or the reverse. Handing over neither turns the puzzle into a `crack -a=all` formality.
- Classical ciphers are short-text ciphers. A paragraph of Vigenere is solvable; a page of it is tedious rather than interesting.
- Base64 and friends are encodings, not secrets. Use them for flavour, not for gating an objective.

---

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `crypto` / `crack` not found | The laptop has no hacking tools - install them with the module, or plug in a Rubberducky |
| Cryptography app missing from the desktop | Same cause; the app group only appears while the tools are available |
| **Send to Cryptography** missing from a right-click menu | Same cause - the entry is hidden on laptops without the toolset |
| Decrypt returns gibberish | Wrong key, wrong variant, or wrong algorithm - try `crack -a=<algorithm>` to sweep that cipher's keyspace |
| A file cannot be opened for decryption | The logged-in account has no read permission on it, or the path is wrong; `ls -l` shows owner and permissions |
| `Permission denied` browsing `/root` | `/root` is root's own home directory. Log in as root where the mission allows it, use `sudo`/`su` from an account in `/etc/sudoers`, or keep player-facing content under `/home/<user>` |

---

## Related Pages

- [Player Guide](Player-Guide) - full terminal command reference including `crypto` and `crack`
- [Mission Maker Guide](Mission-Maker-Guide) - `Root_fnc_cipherProcess` and the database registration functions
- [Zeus Guide](Zeus-Guide) - Cipher Tools module
- [Configuration](Configuration) - CBA settings
