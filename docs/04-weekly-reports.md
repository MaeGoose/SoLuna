# Weekly reports

---

## Week 1 

**Done this week**
- Built the Create Account screen in flutter, not just as a design anymore.
- Turned the themes (colors, fonts, spacing) into actual code 
- made AppButton and LabeledTextField widgets so i'm not rewriting the same thing over and over
- centered the title/subtitle bc it looked weird stretched across the whole browser window
- finally got flutter run -d chrome to actually work after fighting my computer for like an hour

**In progress**
- The other Screens

**Blocked or stuck on**
- Flutter kept throwing 'C:\Users\Jacob' is not recognized, turns out having a SPACE in windows username it, had to move my entire flutter sdk to fix it

**Decisions made, and why**
- Using google_fonts for Caveat + Quicksand instead of downloading font files
- Added device_preview so i can check different screen sizes

**Hours spent, roughly:** 4-5 hrs 

**Next week I will:**
- Build the rest of the screens (today, dates, settings, etc) using fake/sample data since supabase isn't hooked up yet

---

## Week 2 

**Done this week**
- Built all the other screens: today screen, on this day expanded (the collage one), couple dates, couple date detail, and settings
- Made a bunch of new reusable widgets: search bar, avatar stack, memory card, folder tile, polaroid photo, sticky note tag, bottom nav
- Made a MainShell thing so the bottom nav actually switches between screens instead of me making 4 separate apps lol
- Added a folder detail screen + a photo preview screen when u tap a folder in memory collections 

**In progress**
- Everything's running on fake sample data, not real supabase data yet

**Blocked or stuck on**
- those two crashes ate a good chunk of this week ngl, the error messages were SO unhelpful at first, had to screenshot them and get help to actually figure out what was even wrong

**Decisions made, and why**
- sticking with setState for now instead of a state management package
- used Transform.translate instead of negative padding for the overlapping avatars since padding apparently just rejects negative values 

**Hours spent, roughly:** 10 hrs

**Next week I will:**
- start looking into hooking up supabase

---
