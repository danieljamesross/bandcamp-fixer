# bandcamp-fixer.lsp

This little file exists becuase I love buying music on Bandcamp but dislike how each track is displayed when I download the them onto my phone.
 
When you buy an album on Bandcamp, each track is labelled in the following
format:
"Artist - Album - 01 Track Name"

Whilst this has all the information you need, when you view the track name
on a small screen, all you ever see is the artist's name. This file fixes
that.

In a nutshell, it rearranges the track names of all your Bandcamp purshases
to the following format:
"01_Track_Name___Artist___Album"

Not only does it rearrange the names to make them more legible, it also
removes dreaded whiespace AND keeps track of all the albums it has already
acted upon.

---

### MAIN FUNCTION
```lisp

(bandcamp-albums-fixer)
```

### ARGUMENTS
- the path to your music library

### OPTIONAL ARGUMENTS
#### keyword arguments
- :ref - the file that will store the list of albums that have already been
processed in order to prevent them from being constantly rearranged.

- :ignore - a list of strings that are the names of the directories that you
do not want to apply the function to.
For example:
```lisp
'("iTunes" "a non bandcamp album" "another album I didn't buy on bandcamp")
```

- :extension - the extension of the audio files to look for. At the moment
this can only accept one and may break if you apply the function to a folder
with more than one kind of extension. I will try to fix this if/when I find
time. For now it works and bandcamp downloads only ever contain a single file
format anyway.

### RETURN VALUE

An integer representing the number of albums processed.

---

## WARNINGS

NB: this function will also create a file, by default ".bandcamp_fixes" in
the root director of you music collect. You need this. Do not delete. If you
do delete it and then run the function again, who knows what might happen to
your track names. You have been warned!

NB: This is a work in progress and it may break on certain tracknames if
they are quite complex and contain lots of hyphnes and stuff. Why not help me
fix it?
 
---

## TODO

 1. Make the function work on multiple extensions as once
 2. Make the renaming bulletproof
 3. Add some kind of memory and a funciton to undo, just in case.

---

## EXAMPLE

```lisp
(load "/path/to/bandcamp-fixer.lsp")

(bandcamp-fixer "/path/to/music/" ; needs this last trailing slash!
		       :ignore '("iTunes" "Non-Bandcamp Album" 
				 "Another album I don't want this to apply to")
		       :extension ".wav"
		       :ref ".bandcamp_fixes")
```
