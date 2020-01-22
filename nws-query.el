(provide 'nws-query)

(defvar nws-searchstr ""
  "Variable for the most recent query of the nws-search function provided by the package of the same name.")

(defvar nws-local ""
  "Variable for a path under which to save nws-search queries; set in your init-file to the path you wish to keep a backlog in order enable local saving and offline searching.")

(defun nws-search ()
  ""
  (interactive)
  (nws-get-searchstring)
  (cond ((get-buffer (concat "NWS_" nws-searchstr))
	 (display-buffer-pop-up-frame (concat "NWS_" nws-searchstr) nil)
	 )
	((not nil)
	 (let ((w3m-pop-up-frames t))
	   (w3m-browse-url (concat "http://nws.uzi.uni-halle.de/search?utf8=✓&q=" nws-searchstr "&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on") t)))
	)
  )

(defun nws-search-local ()
  ""
  (interactive)
  (if (eq nws-local "")
      (message "Variable 'nws-local' not set.")
    (nws-get-searchstring)
    (if (file-exists-p (concat nws-local "/NWS_" nws-searchstr))
	(progn
	  (find-file-read-only-other-frame (concat nws-local "/NWS_" nws-searchstr))
	  (nws-redisplay))
      (message "Searchstring is not in the local querylog."))
    ))

(defun nws-get-searchstring ()
  (if mark-active
      (setq nws-searchstr (buffer-substring-no-properties (region-beginning) (region-end)))
    (setq nws-searchstr (read-string "Search string (IAST or HK): " nil nil nil t))
    )
  ;; standardize searchstring to Harvard-Kyoto
  (mapc (lambda (list)
	  (setq nws-searchstr (replace-regexp-in-string (eval (car list)) (eval (cdr list)) nws-searchstr))
	  )
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
	)
  )

;; call function when w3m is done displaying web content
(add-hook 'w3m-display-hook 'nws/w3m-post-display)

(defun nws/w3m-post-display (url)
  ""
  (when (string-match "nws.uzi.uni-halle.de/search" url)
    (nws-rename)
    (unless (eq nws-local "")
      (nws-save))
    (nws-redisplay)
    )
  )

(defun nws-rename ()
  "called by nws/w3m-post-display when searching nws, renames buffer for comparison"
  (rename-buffer (concat "NWS_" nws-searchstr) t)
  )

(defun nws-save ()
  "called by w3m-display-hook when searching nws, saves relevant region locally as a text file, unless there are no results or a recent file is already existing"
  (save-excursion
    (unless (search-forward "Keine Suchergebnisse." nil t 3)
      (goto-char (point-min))
      (cond
       ;; save query there isn't a file already
       ((not (file-exists-p (concat nws-local "NWS_" nws-searchstr)))
	(write-region (search-forward "Nachtragswörterbuch des Sanskrit" nil t) (point-max) (concat nws-local "/NWS_" nws-searchstr) nil nil nil))
       ;; if there is, only overwrite if the current file is older than 100 days
       ((< 8640000 (string-to-number (format-time-string "%s" (time-subtract (current-time) (file-attribute-modification-time (file-attributes (concat nws-local "/NWS_" nws-searchstr)))))))
	(write-region (search-forward "Nachtragswörterbuch des Sanskrit" nil t) (point-max) (concat nws-local "/NWS_" nws-searchstr) nil nil nil))
       ((not nil)
	(message "Query was already saved locally."))
       ))))

(defun nws-redisplay ()
  "called by w3m-display-hook when searching nws, jumps to the main entry and centers view"
  (goto-char (point-min))
  (re-search-forward "^pw" nil t)
  (recenter-top-bottom)
  )
