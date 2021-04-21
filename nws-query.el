(provide 'nws-query)

(defvar nwslocal ""
  "Variable for a path under which to save nws-search queries; set in your init-file to the path you wish to keep a backlog in order enable local saving and offline searching.")

(defun nws-query (searchstr)
  "query the nws"
  (interactive (list (nws-get-searchstr)))

  (if (get-buffer (concat "NWS_" searchstr))
      (display-buffer-pop-up-frame (concat "NWS_" searchstr) nil)
    (if (eq nwslocal "")
	(progn
	  (message "Variable 'nwslocal' is not set, defaulting to online search.")
	  (nws-search-online searchstr))
      (if (file-exists-p (concat nwslocal "NWS_" searchstr))
	  (nws-search-local searchstr)
	(message "Searchstring is not in the local querylog, searching online.")
	(nws-search-online searchstr)
      )
    )
  )
)
  
(defun nws-search-online (searchstr)
  (interactive (list (nws-get-searchstr)))
  (let ((w3m-pop-up-frames t))
    (w3m-browse-url (concat "https://nws.uzi.uni-halle.de/search?utf8=✓&q=" searchstr "&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on") t))
  )

(defun nws-search-local (searchstr)
  "query your local backlog"
  (interactive (list (nws-get-searchstr)))
  (find-file-read-only-other-frame (concat nwslocal "NWS_" searchstr))
  (nws-redisplay)
  (local-set-key (kbd "q") 'delete-frame)
  )

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
    (nws-save)
    (nws-redisplay)
    )
  )

(add-hook 'w3m-display-hook 'nws/w3m-post-display)

(defun nws-rename (url)
  "called by nws/w3m-post-display when searching nws, renames buffer for comparison"
  (rename-buffer (concat "NWS_" (substring (substring-no-properties url (string-match "&q=" url) (string-match "&m=&" url)) 3)) t))

(defun nws-redisplay ()
  "called by w3m-display-hook when searching nws, jumps to the main entry and centers view"
  (goto-char (point-min))
  (re-search-forward "^pw" nil t)
  (recenter-top-bottom)
  )

(defun nws-save ()
  ""
  (unless (or (eq nwslocal "")
	     (string-match "\*" (buffer-name))
	     (string-match "\?" (buffer-name))
	     (search-forward "Keine Suchergebnisse." nil t 3)
	     (search-forward "Cannot retrieve URL:" nil t))
      (save-excursion
	(goto-char (point-min))
	(write-region (re-search-forward "^NWS" nil t) (point-max) (concat nwslocal (buffer-name)) nil nil nil)
	(write-region (concat (substring-no-properties (buffer-name) 4) "\n") nil (concat nwslocal "new_headlines") 'append)
	)
    )
  )
