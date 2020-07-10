---
layout: post
title: Is Software Immortal?
date: 2020-07-09 20:23 -0400
---

It seems like we've all accepted an unspoken truth that software does not die. Ask yourself:

When is the last time you rewrote a large codebase? Or ditched a tool you'd been using for a while?
Or really, when's the last time you totally scrapped a project that had made it into production?

Quite possibly, never. Or maybe just not recently. But I'd wager that you probably haven't done so
in the last 5 years.

The longer I spend in this industry the more I see it. Years and years of development on one project
all building up to... what exactly? 36 years into GNU Emacs, are we really on the same page as its
original creators? The Linux Kernel: do the truths of 1991 still apply today?

Zombie projects, living well beyond their expected shelf-life, constantly extended past their initial
goals. Maybe deprecated. But not rewritten. Why [MATE](https://mate-desktop.org/) over Gnome 3? And
how do we justify [Tauthon](https://github.com/naftaliharris/tauthon)? Do we just prefer to live in
the past? Or is our future missing something?

The same is true in commercial software. OS X lives on as the "macOS" 19 years since its introduction.
Signs are pointing to the long Windows line culminating in Windows 10 (side note, [why wasn't it called
Windows 9](https://www.reddit.com/r/technology/comments/2hwlrk/new_windows_version_will_be_called_windows_10/ckwq83x/)?).
Adobe CC has superseded all those generations of the Creative Suite as the one true release.

Where we once stepped forward through reinvention (MULTICS 🡒 UNIX 🡒 Minix 🡒 Linux, or DOS 🡒 NT),
we now iterate on the same programs ad infinitum. There _will be no_ "Steam 2." Nor will there be a
"Google Docs 2," a "Slack 2." Not even a "git++." [Deno](https://deno.land/) will not win over Node.
The abject failure of [Perl 6](https://en.wikipedia.org/wiki/Raku_(programming_language)) should tell
us so: the project is an anachronism today, hilariously trying to pretend as if starting over is ever
acceptable.

## It's not just a naming thing.

Or an "old = bad" thing. It's a fundamental shift from how software
was once developed. Beyond just sunsetting old projects, it seems like we've lost touch of the word
"complete" since software stopped being "shipped." As time goes on, the scope of a project seems to
grow indefinitely. There is no point to stopping development when 1 more tiny feature can be added
in or a user requests for some edge case to be handled.

We no longer sit down to think about whether a feature belongs in this product, or whether there's
an inherent flaw in our project. Pumping in life support has become the default.

## Why?

Without completeness, projects are bound to grow. A constant, self-fulfilling cycle of extending the
bounds and being left with software too big to fail. As project balloon from teams of 1-2 programmers
to teams of 10s or 100s, we have come to accept the 1 million line project. How do you approach a
rewrite? How do you even pitch restarting that? The idea of what a single piece of software can
contain is so skewed into this line of thinking that we don't even consider the alternatives.

Meanwhile, short-term thinking has won out. With quarterly deliverables, you cannot show impact when
replacing gargantuan software. Every component is so large of a behemoth that it would take years to
fully replace. Nobody wants to take a step back for a couple quarters, even if it means more
long-term productivity. At least as long as backwards compatability and tight deadlines are goals,
we will not see a change in the industry's sentiment.

And on top of it all the idea of a proper release is gone. The world is run by SaaS now. There are no
new versions, and users are not ready to accept a proper reset -- you see it when users complain about
the latest Facebook/YouTube/Twitter redesign, even when the actual features are unchanged.

## Is it a problem?

Maybe I'm just unusual in this way, but I hardly ever think I made the right choices 6 months into
a project. When faced with myriad choices, can we really expect to make the correct one on the first
try? Assumptions change. Oftentimes I find myself frustrated that I picked the language that I did,
or the framework. Or that I designed my code around a certain structure. The longer it stretches on
the more inclined I feel to ripping everything out and starting from scratch -- and when I do make
the leap and start over, problems start to resolve themselves. Will the software development of the
2030s and 2040s just be patching bugs and iterating over the same solutions? It sure seems that way.

More generally, we've all heard
[horror stories about projects like Oracle SQL](https://news.ycombinator.com/item?id=18442941).
41 years into its life, it's clearly starting to show signs of age. Maybe it's an extreme example,
but are other projects really fundamentally better about this? Do Visual Studio and Internet
Explorer really feel "snappy" (or "intuitive," "modern," etc.)? I feel like every day as a software
engineer I deal with clumsily designed software that shows its age. It _feels_ like it came from the
90s.

And it's just as apparent that others (even non-technical folks) feel the same way. You can't spend
time online without seeing people complain about the broken software they interact with. As software
becomes more ubiquitous -- a constant for humanity --  it seems like we'll need to address this. Or
do we just plan on using HTTP, Email, and Microsoft Word 100 years from now?
