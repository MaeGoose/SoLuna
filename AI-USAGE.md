# AI usage

## 1. How I used AI

### 2026-09-20 - Blueprint and Simple Layout

- **Tool:** Claude
- **What I asked for:** I simply asked for a simple layout of the whole thing just a blueprint of sorts following the instructions of the assignment.
- **What it gave back:** It gave me a few .dart files that were bare bones at most all 4 main screens, I just had to change the colours, shapes, padding and the such
- **What I kept, what I changed, and why:** Considering on how I worked on the login page first, I had to change some padding settings, change the box settings so that they don't go from one end to another of a screen and just be a proper rectangle. I added the colours, implemented google fonts and the such.
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/2ce97798e3f5050bb1751363cb425273108b1329

### 2026-09-24 - 

- **Tool:** Claude
- **What I asked for:** I asked for help with creating the Main.shell for the other screens as I needed a proper nav bar that didnt follow the rest of the screens.
- **What it gave back:** A working main.shell that worked throughout the screens. All 3 screens worked except the add one as its functionality wasn't done yet
- **What I kept, what I changed, and why:** I kept most of the code as it was all straightforward and worked, although I edited it so that it had the "add" tab in future commits.
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/5c3aabbe2da78984ba4cdcd178401b7a00e39a5b

### 2026-09-28 - 

- **Tool:** Claude
- **What I asked for:** I asked for how to properly add photos to folders properly, removing the current placeholders I have and making photo previews exist
- **What it gave back:** It gave back more .dart files that did work but had a few problems with the photo preview as it shows only a part of it when its too big
- **What I kept, what I changed, and why:** I changed the BoxFit.cover with a 'fit' option to make the whole photo actually seen (not in the commit as I fixed this much later)
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/8b885f8f09ebd53e72f50a42041b2b5334a559fb

### 2026-09-30 - 

- **Tool:** Claude
- **What I asked for:** I asked for help with how to implement a login function in my app itself with support from SUPABASE database.
- **What it gave back:** It gave me honestly the basics and an SQL to base of off and to put into SUPABASE 
- **What I kept, what I changed, and why:** There were some problems with the SUPABASE as it wasn't making the tables it was asking for so I ended up with errors in SUPABASE itself. I had to add a "drop policy if exists" so it wouldn't make an error anymore. 
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/fe72c2199dbfec638c39328c543145b445ea9075

### 2026-10-1 - 

- **Tool:** Claude 
- **What I asked for:** I asked for a fix on the On this day as what I did just didn't follow what I wanted, it kept just showing the most latest additions to memories, showing the newest photos I added in the database
- **What it gave back:** It made the On this day work as I wanted it to where it shows the photos where it matches the current Month and Day but REGARDLESS of year.
- **What I kept, what I changed, and why:** I kept most of it but added a function where it shows all the photos in a little collage
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/645dee1b959312317bf6661fd92063b2cba1f8d1

### 2026-09-30 - 

- **Tool:** Claude
- **What I asked for:** I asked for a simple rundown and things I could still improve on in the app itself.
- **What it gave back:** It gave me a list of things to choose from from making the scroll function go down instead and making the accounts bubbles actually lead to settings. It also fixed a bug that wouldn't let status save
- **What I kept, what I changed, and why:** I kept the 2 I mentioned above, although it gave me other suggestions, I thought that these were stretch goals already.
- **Commit:** 

## 2. Where the AI got it wrong

Three cases. Be specific. If you write that the AI was never wrong, this section
scores zero.

### Case 1 - Input boxes encompassing a whole row of a screen 

- **What it gave me:** It gave me a blueprint of the first screen wherein the login boxes, where you put passwords and emails, went from on end of the screen to the other, regardless of what size it was set on. 
- **What was wrong with it:** The rows being too long and annoying to look at
- **What I did instead:** I fixed it so that it doesn't wrap around the whole screen. I added centre to the screen and a ConstrainedBox with a max width of 480 so that it centers. 
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/2ce97798e3f5050bb1751363cb425273108b1329

### Case 2 - Settings tab suddenly disappearing after implementing  

- **What it gave me:** It gave me the Supabase SQL and a connection to the settings tab with Supabase. 
- **What was wrong with it:** After implementing Supabase and the joint account settings in the tab itself, it prevented it from showing up altogether. It had a line where the "Filled Button" Minimum size was "Size.fromHeight(48)" wherein it means an infinite width. So the FilledButton goes infinitely wide and crashes the whole layout
- **What I did instead:** I fixed it with a minimum of width:90 and a minimumSize.
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/fe72c2199dbfec638c39328c543145b445ea9075

### Case 3 - Saving the Status not working and Dissapearing link button

- **What it gave me:**  I asked to clean up most of the code if ever I messed up or added unnecessary code. It seems like my saving status function didnt work so I asked for it to be fixed.
- **What was wrong with it:** It did fix it and cleaned up some of the code however, It did remove the link button for some reason.
- **What I did instead:** I ended up fixing it on my own with some help from some peers. 
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/364b4cbb1c9b04f944be9e188465b74fb1d33793

## 3. Who wrote what

I worked on the blueprint that Claude gave me, I know just had to adjust and code what was needed based on my WireFrame and Mockups. Most of the App Themes, Colours, Margins, and Widgets were all pretty simple so most of those were done by me.

### Written by me

- **File:** main.dart, app_colors.dart, app_scroll_behavior.dart, app_spacing.dart, app_theme.dart
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/2ce97798e3f5050bb1751363cb425273108b1329
- **What it does and why it is built this way:** Main.dart obviously is the one that runs everything here, it has all the packages, device preview and leads to the other screens with the AuthEntryScreen being the first one to show It also is the main one that has the Supabase URL and its anonymous key basically in charge of its connection to Supabase. With regards however to the other themes screen, I basically was in charge of making these on how I deemed fit, the spacing, the theme I wanted it to have the colours, and the fonts I chose were mostly done by me. I only merely followed the layouts of our past activities. 
- 
### The AI-written part I understand best

- **File:** main.shell 
- **Commit:** https://github.com/MaeGoose/SoLuna/commit/5c3aabbe2da78984ba4cdcd178401b7a00e39a5b
- **What it does and why we kept it:** I honestly had some difficulty when it came to fixing up the nav bar at the bottom, It just seems to keep following with the screens, hence I asked an AI to help me through it, it suggested instead that I make a main.shell and gave me an example template to use of off. I got it to work wherein all 4 tabs go across without affecting the nav bar whatsoever.
