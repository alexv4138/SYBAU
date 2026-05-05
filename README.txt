SYBAU
=====

Tiny WoW addon that hides Silvermoon Guard ambient chat spam.

It blocks the dialogue lines from:

https://warcraft.wiki.gg/wiki/Silvermoon_Guard

Quote source content from Warcraft Wiki is under CC BY-SA 4.0 unless otherwise noted.

Included:

- Dialogue pre-Dawnwell
- Dialogue post-Dawnwell

Excluded:

- Gossip

It filters across likely chat events:
system, text emote, monster emote, monster say/yell/whisper, and raid boss emote/whisper.

Install
-------

Copy the SYBAU folder into:

World of Warcraft\_retail_\Interface\AddOns\

Then restart WoW or run /reload.

Commands
--------

/sybau
Shows status, count, and commands.

/sybau toggle
Toggles filtering.

/sybau tutorial
Toggles the startup tutorial message.

/sybau reset
Resets blocked line count.

/sybau add <text>
Adds another line starter or pattern to block if Blizzard changes the wording.

/sybau list
Lists extra patterns.

/sybau remove <number>
Removes an extra pattern from /sybau list.

Edit blocked lines
------------------

Open sybau_lines.lua.

Add one blocked line per line inside the SYBAU_BLOCKED_LINES block.

Lines beginning with # are ignored.

Use <race> or <class> where the game inserts player race/class text.

User-added lines also support any <word> variable and * wildcards. User-added lines match from the start of the chat line, so you can add a full line or only the starting word(s).

Example:

Another <race> wielding the light.

Notes
-----

This does not use NPC IDs. /fstack will not show the real source because these lines are chat, not stable clickable UI frames.

If the addon shows as out of date, check the current interface number in game:

/dump select(4, GetBuildInfo())

Then edit the Interface line in SYBAU.toc.
