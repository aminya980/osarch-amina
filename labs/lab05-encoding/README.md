# Lab 5 — Encoding forensics

Name: Amina · Date: 18.11.2026 · Tools: Git Bash, Excel, LibreOffice, Windwos host

## What I received
Excel: Columns were split correctly but the text was a little pressed aginst each other, the main thing is that the russian names were readable but kazakh ones not. For example: Ќасымов lost the specific kazakh letter at the start of his name.
LibreOffice: Same as Excel, plus the important note: the Character set default was "Автоматически", and it guessed Windows-1251. It also detected the separator as ; (semicolon).
Terminal (cat in Git Bash): Instead of the normal kazakh or russian letters there were □ boxes: Git Bash expects UTF-8, where every Cyrillic letter is two bytes. Your file gives it bytes it can’t read as UTF-8, so it shows □ (the replacement character). ID, the numbers and ; look fine, these are plain ASCII (english letters, digits, punctuation), and ASCII bytes are the same in almost every encoding. Only the non-English letters break.

## Diagnosis (made before the fix)
- file said: Non-ISO extended-ASCII text, with CRLF line terminators (evidence/file-before.txt)
- First 16 bytes: 49 44 3b d4 e0 ec e8 eb e8 ff 3b c8 ec ff 3b ce (evidence/hexdump-before.txt)
- Encoding: KZ-1048 (RK1048) — because each letter is one byte; Russian letters match Windows-1251 (Ф = D4, а = E0), but the Kazakh letter Ә is the single byte A3, which is Ә in KZ-1048 and Ј in Windows-1251. `iconv -f RK1048` shows every name correctly; `iconv -f WINDOWS-1251` gives Јбдірахманова, Ќасымов.
- Line ending: CRLF — because line 1 ends with 0D 0A (offset 0x24)
- BOM: no — because the file starts with 49 44 ("ID"), not EF BB BF / FF FE / FE FF
- Separator: ;

**BOM**: add it. Excel on Windows only recognises UTF-8 on double-click when the file starts with a BOM.
**Line ending**: keep CRLF. The original is already CRLF, the users open it in Excel on Windows, and LibreOffice and cat read CRLF fine.
**Separator**: keep ;. Excel in Russian locale expects ;, which is why the columns were already split correctly.

## Fix
<the command or scripts/fix.sh, in a code block>

## Verification
<file-after.txt summary; the screenshot evidence/opens-correctly.png>

## What did not work the first time
<at least one real thing>