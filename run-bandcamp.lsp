(in-package :uiop)
(load "~/Documents/sc-preload/bandcamp-fixer.lsp")

(let ((ignore-list  '("Fiona Apple" "iTunes"
				 "richard-bolley-20180920"
				 "Automatically Add to iTunes"
				 "get_iplayer" "Voice Memos"
				 "NotWaiting-20190924"
				 "Ableton"
				 "Lily Greenham Lingual Music Disc 2"
				 "Black_Music_in_Europe_BBC"
				 "rques-choir-20190309" "ed-recs-20190304"
				 "NM23" "NM21" "TheVictoriaConsort Sessions"
				 "GarageBand" "dominic-20180817"
				 "richard-bolley-20180605"
				 "Audio Music Apps" "cocktails-20180619"
				 "bfc-dorchester-20180714"
				 "bcf-cheltenham-20180713" 
				 "Gamelan Concert 2018 mp3"
				 "GS-improv-20180319" "BFC-20180107"
				 "kindohm-zeroLikes")))
  (bandcamp-fixer "~/Music/" 
			 :ignore ignore-list
			 :extension ".wav"))
