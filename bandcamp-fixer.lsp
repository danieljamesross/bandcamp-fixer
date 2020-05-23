;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; bandcamp-fixer.lsp
;;;
;;; This little file exists becuase I love buying music on Bandcamp but dislike
;;; how each track is displayed when I download the them onto my phone.
;;;
;;; When you buy an album on Bandcamp, each track is labelled in the following
;;; format:
;;; Artist - Album - 01 Track Name
;;;
;;; Whilst this has all the information you need, when you view the track name
;;; on a small screen, all you ever see is the artist's name. This file fixes
;;; that.
;;;
;;; In a nutshell, it rearranges the track names of all your Bandcamp purshases
;;; to the following format:
;;; 01_Track_Name___Artist___Album
;;;
;;; Not only does it rearrange the names to make them more legible, it also
;;; removes dreaded whiespace AND keeps track of all the albums it has already
;;; acted upon.
;;;
;;; MAIN FUNCTION: bandcamp-albums-fixer
;;;
;;; ARGUMENTS
;;; - the path to your music library
;;;
;;; OPTIONAL ARGUMENTS
;;; keyword arguments
;;; - :ref - the file that will store the list of albums that have already been
;;; processed in order to prevent them from being constantly rearranged.
;;;
;;; - :ignore - a list of strings that are the names of the directories that you
;;; do not want to apply the function to.
;;; For example:
;;; '("iTunes" "a non bandcamp album" "another album I didn't buy on
;;; bandcamp")
;;;
;;; - :extension - the extension of the audio files to look for. At the moment
;;; this can only accept one and may break if you apply the function to a folder
;;; with more than one kind of extension. I will try to fix this is I find
;;; time. For now it works and bandcamp downloads only ever contain a single file
;;; format anyway.
;;;
;;; RETURN VALUE
;;;
;;; An integer representing the number of albums processed.
;;;
;;; WARNINGS
;;;
;;; NB: This function will also create a file, by default ".bandcamp_fixes", in
;;; the root director of you music collect. You need this. Do not delete. If you
;;; do delete it and then run the function again, who knows what might happen to
;;; your track names. You have been warned!
;;;
;;; NB: This is a work in progress and it may break on certain tracknames if
;;; they are quite complex and contain lots of hyphens and stuff. Why not help me
;;; fix it?
;;;
;;; TODO
;;;
;;; 1. Make the function work on multiple extensions as once
;;; 2. Make the renaming bulletproof
;;; 3. Add some kind of memory and a funciton to undo, just in case.
;;;
;;; EXAMPLE
#|
(load "/path/to/bandcamp-fixer.lsp")

(bandcamp-fixer "/path/to/music/" 
		       :ignore '("iTunes" "Non-Bandcamp Album" 
				 "Another album I don't want this to apply to")
		       :extension ".wav"
		       :ref ".bandcamp_fixes")

|#

(in-package :uiop)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Rearrange the default bandcamp track names
;;; "Artist Name - Album Name - 01 Track Name.wav" ->
;;; "01_Track_Name___Artist_Name___Album_Name.wav"
;;;
;;; There are some unexpected hicoughs when the track names havelots of spaces
;;; and hyphens. I guess I'll have to do some matching / identifying with the
;;; name of directory the tracks are in which is in the format: 
;;; "Artist - Album" 
(defun bandcamp-trackname-rearrange (str &optional (extension ".wav"))
  "Rearrange the filename of a bandcamp track"
  (let* ((trackname (string-trim extension (file-namestring str)))
	 (str-split (split-string trackname :separator "-"  :max 3))
	 (artist (string-trim " " (first str-split)))
	 (album (string-trim " " (second str-split)))
	 (track (string-trim " " (third str-split)))
	 (new-trackname (strcat track "___" artist "___" album)))
    (concatenate 'string
		 (replace-all new-trackname " " "_")
		 extension)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bandcamp-trackname-fixer (file &optional (extension ".wav"))
  "Rename your bandcamp track file"
  (unless (probe-file file)
    (error "~%bandcamp-trackname-fixer: ~a does not exist" file))
  (rename-file file (bandcamp-trackname-rearrange file extension)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bandcamp-tracknames-fixer (dir &optional (extension ".wav"))
  "Rename all the files in a bandcamp album dir"
  (loop for file in (directory (concatenate 'string dir "*" extension))
	do (bandcamp-trackname-fixer file extension))
  (directory dir))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This is the main function you will need
(defun bandcamp-fixer (dir &key (ref ".bandcamp_fixes")
			     ignore (extension ".wav"))
  "Rename all the tracks of all the bandcamp albums in your collection and / 
keep track of which ones have been changed."
  (let ((count 0))
    (setq dir (native-namestring dir)
	  ref (concatenate 'string dir ref))
    (when ignore
      (unless (listp ignore)
	(setq ignore (list ignore)))
      (setq ignore
	    (loop for i in ignore
		  collect
		  ;; I don't like this line, adding the extra "/" at the
		  ;; end is clunky. I really should fix it.
		  (directory-namestring (concatenate 'string dir i "/")))))
    (loop for album in (subdirectories dir)
	  do
	     (with-open-file (nf ref :direction :output
				     :if-exists :append
				     :if-does-not-exist :create)
	       (unless (or (member (native-namestring album)
				   ignore
				   :test #'string=)
			   (member (native-namestring album)
				   (read-file-lines ref)
				   :test #'string=))
		 (bandcamp-tracknames-fixer (native-namestring album) extension)
		 (print (native-namestring album))
		 (format nf "~%~a" (native-namestring album))
		 (incf count))))
    count))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Helper Function
;;; Source: https://lispcookbook.github.io/cl-cookbook/strings.html
(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurrences of the part \
is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
	  for old-pos = 0 then (+ pos part-length)
	  for pos = (search part string
			    :start2 old-pos
			    :test test)
	  do (write-string string out
			   :start old-pos
			   :end (or pos (length string)))
	  when pos do (write-string replacement out)
	    while pos)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EOF bandcamp.lsp
