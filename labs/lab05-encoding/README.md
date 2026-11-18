# Lab 5 — Encoding forensics

Name: Amina · Date: 18.11.2026 · Tools: Git Bash, Excel, LibreOffice, Windwos host

## What I received
Excel: Columns were split correctly but the text was a little pressed aginst each other, the main thing is that the russian names were readable but kazakh ones not. For example: Ќасымов lost the specific kazakh letter at the start of his name.
LibreOffice: Same as Excel, plus the important note: the Character set default was "Автоматически", and it guessed Windows-1251. It also detected the separator as ; (semicolon).
Terminal (cat in Git Bash): Instead of the normal kazakh or russian letters there were □ boxes: Git Bash expects UTF-8, where every Cyrillic letter is two bytes. Your file gives it bytes it can’t read as UTF-8, so it shows □ (the replacement character). ID, the numbers and ; look fine, these are plain ASCII (english letters, digits, punctuation), and ASCII bytes are the same in almost every encoding. Only the non-English letters break.

## Diagnosis (made before the fix)
- file said: <…>  (evidence/file-before.txt)
- First 16 bytes: <hex>  (evidence/hexdump-before.txt)
- Encoding: <exact name> — because <bytes>
- Line ending: <CRLF / LF> — because <bytes>
- BOM: <yes / no> — because <bytes>; in the fixed file I <kept / removed / added> it because <reason>

## Fix
<the command or scripts/fix.sh, in a code block>

## Verification
<file-after.txt summary; the screenshot evidence/opens-correctly.png>

## What did not work the first time
<at least one real thing>