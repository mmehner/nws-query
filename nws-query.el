(provide 'nws-query)

(defvar nws-local ""
  "Variable for a path under which to save nws-search queries; set in your init-file to the path you wish to keep a backlog in order enable local saving and offline searching.")

(defun nws-search (searchstr)
  "query the nws"
  (interactive (list (nws-get-searchstr)))

  (cond ((get-buffer (concat "NWS_" searchstr))
	 (display-buffer-pop-up-frame (concat "NWS_" searchstr) nil))
	(t (let ((w3m-pop-up-frames t))
	     (w3m-browse-url (concat "https://nws.uzi.uni-halle.de/search?utf8=✓&q=" searchstr "&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on") t)))
	))

(defun nws-search-local (searchstr)
  "query your local backlog"
  (interactive (list (nws-get-searchstr)))
  (if (eq nws-local "")
      (message "Variable 'nws-local' is not set.")
    (if (file-exists-p (concat nws-local "/NWS_" searchstr))
	(progn
	  (find-file-read-only-other-frame (concat nws-local "/NWS_" searchstr))
	  (nws-redisplay)
	  (local-set-key (kbd "q") 'delete-frame))
      (message "Searchstring is not in the local querylog."))
    ))

(defun nws-get-searchstr ()
  (seq-reduce
   (lambda (string regexp-replacement-pair)
     (replace-regexp-in-string
      (car regexp-replacement-pair)
      (cdr regexp-replacement-pair)
      string))
   '(("ā" . "A" )
     ("ī" . "I" )
     ("ū" . "U" )
     ("ṛ" . "R" )
     ("ṝ" . "RR" )
     ("ḷ" . "L" )
     ("ṃ" . "M" )
     ("ḥ" . "H" )
     ("ṅ" . "G" )
     ("ṇ" . "N" )
     ("ñ" . "J" )
     ("[śZ]" . "z" )
     ("ṣ" . "S" )
     ("ṭ" . "T" )
     ("ḍ" . "D" ))
   (if mark-active
      (buffer-substring-no-properties (region-beginning) (region-end))
    (read-string "Search string (IAST or HK): " nil nil nil t)
    )))

(defun nws-scrape ()
  ""
  (interactive)
  (unless (eq nws-local "")
    (if (not (file-exists-p (concat default-directory "index_pw-PW_sorted_uniq.txt")))
	(message "Can't find index. Please cd into directory providing the package query-nws.el")
    (mapc (lambda (lemma)
	    ;; skip if already existing
	    (unless (file-exists-p (concat nws-local "/NWS_" lemma))
	      (w3m-browse-url (concat "https://nws.uzi.uni-halle.de/search?utf8=✓&q=" lemma "&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on") t)
	      (sleep-for (random 2) (random 100))
	      (kill-this-buffer)
	    ))
	  (split-string 
	   (nws-get-headwords "index_pw-PW_sorted_uniq.txt") "\n" t)
	  ))))

(defun nws-get-headwords (f)
  (with-temp-buffer
    (insert-file-contents f)
    (buffer-substring-no-properties
       (point-min)
       (point-max))))

;; call function when w3m is done displaying web content
(defun nws/w3m-post-display (url)
  ""
  (when (string-match "nws.uzi.uni-halle.de/search" url)
    (nws-rename url)
    (unless (eq nws-local "")
      (nws-save))
    (nws-redisplay)
    )
  )

(add-hook 'w3m-display-hook 'nws/w3m-post-display)

(defun nws-rename (url)
  "called by nws/w3m-post-display when searching nws, renames buffer for comparison"
  (rename-buffer (concat "NWS_" (substring (substring-no-properties url (string-match "&q=" url) (string-match "&m=&" url)) 3)) t))

(defun nws-save ()
  "called by w3m-display-hook when searching nws, saves relevant region locally as a text file, unless there are no results or a recent file is already existing"
  (save-excursion
    (unless (search-forward "Keine Suchergebnisse." nil t 3)
      (goto-char (point-min))
      (cond
       ;; save query if there isn't a file already
       ((not (file-exists-p (concat nws-local "/" (buffer-name))))
	(write-region (search-forward "Nachtragswörterbuch des Sanskrit" nil t) (point-max) (concat nws-local "/" (buffer-name)) nil nil nil))
       ;; if there is, only overwrite if the current file is older than 100 days
       ((< 8640000 (string-to-number (format-time-string "%s" (time-subtract (current-time) (file-attribute-modification-time (file-attributes (concat nws-local "/" (buffer-name))))))))
	(write-region (search-forward "Nachtragswörterbuch des Sanskrit" nil t) (point-max) (concat nws-local "/" (buffer-name)) nil nil nil))
       (t
	(message "Query has already been saved locally less than 100 days ago."))
       ))))

(defun nws-redisplay ()
  "called by w3m-display-hook when searching nws, jumps to the main entry and centers view"
  (goto-char (point-min))
  (re-search-forward "^pw" nil t)
  (recenter-top-bottom))
