;;; scimax-org.el --- org-mode configuration for scimax

;;; Commentary:


;;; Code:
(require 'org)

;; * Configuration of org-mode
;; don't allow invisible regions to be edited
(setq org-catch-invisible-edits t)

;; allow lists with letters in them.
(setq org-list-allow-alphabetical t)

;; setup archive location in archive directory in current folder
(setq org-archive-location "archive/%s_archive::")


;; * Speed commands
(setq org-use-speed-commands t)

;; Mark a subtree
(add-to-list 'org-speed-commands-user (cons "m" 'org-mark-subtree))

;; Widen
(add-to-list 'org-speed-commands-user (cons "S" 'widen))

;; kill a subtree
(add-to-list 'org-speed-commands-user (cons "k" (lambda ()
						  (org-mark-subtree)
						  (kill-region
						   (region-beginning)
						   (region-end)))))

;; Jump to headline
(add-to-list 'org-speed-commands-user
	     (cons "q" (lambda ()
			 (avy-with avy-goto-line
			   (avy--generic-jump "^\\*+" nil avy-style)))))

(defun org-teleport (&optional arg)
  "Teleport the current heading to after a headline selected with avy.
With a prefix ARG move the headline to before the selected
headline. With a numeric prefix, set the headline level. If ARG
is positive, move after, and if negative, move before."
  (interactive "P")
  ;; Kill current headline
  (org-mark-subtree)
  (kill-region (region-beginning) (region-end))
  ;; Jump to a visible headline
  (avy-with avy-goto-line (avy--generic-jump "^\\*+" nil avy-style))
  (cond
   ;; Move before  and change headline level
   ((and (numberp arg) (> 0 arg))
    (save-excursion
      (yank))
    ;; arg is what we want, second is what we have
    ;; if n is positive, we need to demote (increase level)
    (let ((n (- (abs arg) (car (org-heading-components)))))
      (cl-loop for i from 1 to (abs n)
	       do
	       (if (> 0 n)
		   (org-promote-subtree)
		 (org-demote-subtree)))))
   ;; Move after and change level
   ((and (numberp arg) (< 0 arg))
    (org-mark-subtree)
    (goto-char (region-end))
    (when (eobp) (insert "\n"))
    (save-excursion
      (yank))
    ;; n is what we want and second is what we have
    ;; if n is positive, we need to demote
    (let ((n (- (abs arg) (car (org-heading-components)))))
      (cl-loop for i from 1 to (abs n)
	       do
	       (if (> 0 n) (org-promote-subtree)
		 (org-demote-subtree)))))

   ;; move to before selection
   ((equal arg '(4))
    (save-excursion
      (yank)))
   ;; move to after selection
   (t
    (org-mark-subtree)
    (goto-char (region-end))
    (when (eobp) (insert "\n"))
    (save-excursion
      (yank))))
  (outline-hide-leaves))

(add-to-list 'org-speed-commands-user (cons "T" 'org-teleport))

;; * Org-id

(setq org-id-link-to-org-use-id 'create-if-interactive)
(setq org-link-search-must-match-exact-headline 'query-to-create)
(setq org-id-locations-file
      (expand-file-name "user/.org-id-locations" scimax-dir))
(require 'org-id)

;; * Block templates
;; add <p for python expansion
(add-to-list 'org-structure-template-alist
	     '("p" "#+BEGIN_SRC python :results org drawer\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

;; add <por for python expansion with raw output
(add-to-list 'org-structure-template-alist
	     '("por" "#+BEGIN_SRC python :results output raw\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

;; add <pv for python expansion with value
(add-to-list 'org-structure-template-alist
	     '("pv" "#+BEGIN_SRC python :results value\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

;; add <el for emacs-lisp expansion
(add-to-list 'org-structure-template-alist
	     '("el" "#+BEGIN_SRC emacs-lisp\n?\n#+END_SRC"
	       "<src lang=\"emacs-lisp\">\n?\n</src>"))

;; add <sh for shell
(add-to-list 'org-structure-template-alist
	     '("sh" "#+BEGIN_SRC sh\n?\n#+END_SRC"
	       "<src lang=\"shell\">\n?\n</src>"))

(add-to-list 'org-structure-template-alist
	     '("lh" "#+latex_header: " ""))

(add-to-list 'org-structure-template-alist
	     '("lc" "#+latex_class: " ""))

(add-to-list 'org-structure-template-alist
	     '("lco" "#+latex_class_options: " ""))

(add-to-list 'org-structure-template-alist
	     '("ao" "#+attr_org: " ""))

(add-to-list 'org-structure-template-alist
	     '("al" "#+attr_latex: " ""))

(add-to-list 'org-structure-template-alist
	     '("ca" "#+caption: " ""))

(add-to-list 'org-structure-template-alist
	     '("tn" "#+tblname: " ""))

(add-to-list 'org-structure-template-alist
	     '("n" "#+name: " ""))

;; table expansions
(loop for i from 1 to 6
      do
      (let ((template (make-string i ?t))
	    (expansion (concat "|"
			       (mapconcat
				'identity
				(loop for j to i collect "   ")
				"|"))))
	(setf (substring expansion 2 3) "?")
	(add-to-list 'org-structure-template-alist
		     `(,template ,expansion ""))))

;; * Babel settings
;; do not evaluate code on export by default
(setq org-export-babel-evaluate nil)

;; enable prompt-free code running
(setq org-confirm-babel-evaluate nil
      org-confirm-elisp-link-function nil
      org-confirm-shell-link-function nil)

;; register languages in org-mode
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (sh . t)
   (matlab . t)
   (sqlite . t)
   (ruby . t)
   (perl . t)
   (org . t)
   (dot . t)
   (plantuml . t)
   (R . t)
   (fortran . t)
   (C . t)))

;; no extra indentation in the source blocks
(setq org-src-preserve-indentation t)

;; use syntax highlighting in org-file code blocks
(setq org-src-fontify-natively t)

;; ** jupyter ipython blocks

(add-to-list 'org-structure-template-alist
	     '("ip" "#+BEGIN_SRC ipython\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

(setq org-babel-default-header-args:ipython
      '((:results . "output replace")
	(:session . nil) 
	(:exports . "both")
	(:cache .   "no")
	(:noweb . "no")
	(:hlines . "no")
	(:tangle . "no")))

;; ** jupyter-hy blocks
;; make src blocks open in the right mode
(add-to-list 'org-src-lang-modes '("jupyter-hy" . hy))
(add-to-list 'org-latex-minted-langs '(jupyter-hy  "hylang"))

;; set default headers for convenience
(setq org-babel-default-header-args:jupyter-hy
      '((:results . "output replace")
	(:session . "hy")
	(:kernel . "hy")
	(:exports . "code")
	(:cache .   "no")
	(:noweb . "no")
	(:hlines . "no")
	(:tangle . "no")))

(defalias 'org-babel-execute:jupyter-hy 'org-babel-execute:ipython)
(defalias 'org-babel-prep-session:jupyter-hy 'org-babel-prep-session:ipython)
(defalias 'org-babel-jupyter-hy-initiate-session 'org-babel-ipython-initiate-session)

(add-to-list 'org-structure-template-alist
	     '("hy" "#+BEGIN_SRC jupyter-hy\n?\n#+END_SRC"
	       "<src lang=\"hy\">\n?\n</src>"))

;; * Images in org-mode

;; default with images open
(setq org-startup-with-inline-images "inlineimages")

;; default width
(setq org-image-actual-width '(600))

(add-hook 'org-babel-after-execute-hook
	  'org-display-inline-images)

(defun scimax-align-result-table ()
  "Align tables in the subtree."
  (save-restriction
    (save-excursion
      (unless (org-before-first-heading-p) (org-narrow-to-subtree))
      (org-element-map (org-element-parse-buffer) 'table
	(lambda (tbl)
	  (goto-char (org-element-property :begin tbl))
	  (while (not (looking-at "|")) (forward-line))
	  (org-table-align))))))

(add-hook 'org-babel-after-execute-hook
	  'scimax-align-result-table)

;; * Colored src blocks
;; based on patches from Rasmus <rasmus@gmx.us>

;; This function overwrites the org-src function to make src blocks be colored again.
(defun org-src-font-lock-fontify-block (lang start end)
  "Fontify code block.
LANG is the language of the block.  START and END are positions of
the block.  This function is called by Emacs automatic
fontification, as long as `org-src-fontify-natively' is non-nil."
  (let ((lang-mode (org-src--get-lang-mode lang)))
    (when (fboundp lang-mode)
      (let ((string (buffer-substring-no-properties start end))
	    (modified (buffer-modified-p))
	    (org-buffer (current-buffer))
	    (block-faces (let ((face-name (intern (format "org-block-%s" lang))))
			   (append (and (facep face-name) (list face-name))
				   '(org-block)))))
	(remove-text-properties start end '(face nil))
	(with-current-buffer
	    (get-buffer-create
	     (format " *org-src-fontification:%s*" lang-mode))
	  (erase-buffer)
	  (insert string " ") ;; so there's a final property change
	  (unless (eq major-mode lang-mode) (funcall lang-mode))
	  (org-font-lock-ensure)
	  (let ((pos (point-min)) next)
	    (while (setq next (next-single-property-change pos 'face))
	      (let ((new-face (get-text-property pos 'face)))
		(put-text-property
		 (+ start (1- pos)) (1- (+ start next)) 'face
		 (list :inherit (append (and new-face (list new-face))
					block-faces))
		 org-buffer))
	      (setq pos next))
	    ;; Add the face to the remaining part of the font.
	    (put-text-property (1- (+ start pos))
			       end 'face
			       (list :inherit block-faces) org-buffer)))
	(add-text-properties
	 start end
	 '(font-lock-fontified t fontified t font-lock-multiline t))
	(set-buffer-modified-p modified)))))

(defun org-fontify-meta-lines-and-blocks-1 (limit)
  "Fontify #+ lines and blocks."
  (let ((case-fold-search t))
    (if (re-search-forward
	 "^\\([ \t]*#\\(\\(\\+[a-zA-Z]+:?\\| \\|$\\)\\(_\\([a-zA-Z]+\\)\\)?\\)[ \t]*\\(\\([^ \t\n]*\\)[ \t]*\\(.*\\)\\)\\)"
	 limit t)
	(let ((beg (match-beginning 0))
	      (block-start (match-end 0))
	      (block-end nil)
	      (lang (match-string 7))
	      (beg1 (line-beginning-position 2))
	      (dc1 (downcase (match-string 2)))
	      (dc3 (downcase (match-string 3)))
	      end end1 quoting block-type ovl)
	  (cond
	   ((and (match-end 4) (equal dc3 "+begin"))
	    ;; Truly a block
	    (setq block-type (downcase (match-string 5))
		  quoting (member block-type org-protecting-blocks))
	    (when (re-search-forward
		   (concat "^[ \t]*#\\+end" (match-string 4) "\\>.*")
		   nil t)  ;; on purpose, we look further than LIMIT
	      (setq end (min (point-max) (match-end 0))
		    end1 (min (point-max) (1- (match-beginning 0))))
	      (setq block-end (match-beginning 0))
	      (when quoting
		(org-remove-flyspell-overlays-in beg1 end1)
		(remove-text-properties beg end
					'(display t invisible t intangible t)))
	      (add-text-properties
	       beg end '(font-lock-fontified t font-lock-multiline t))
	      (add-text-properties beg beg1 '(face org-meta-line))
	      (org-remove-flyspell-overlays-in beg beg1)
	      (add-text-properties	; For end_src
	       end1 (min (point-max) (1+ end)) '(face org-meta-line))
	      (org-remove-flyspell-overlays-in end1 end)
	      (cond
	       ((and lang (not (string= lang "")) org-src-fontify-natively)
		(org-src-font-lock-fontify-block lang block-start block-end)
		(add-text-properties beg1 block-end '(src-block t)))
	       (quoting
		(add-text-properties beg1 (min (point-max) (1+ end1))
				     (let ((face-name (intern (format "org-block-%s" lang))))
				       (append (and (facep face-name) (list face-name))
					       '(face org-block))))) ; end of source block
	       ((not org-fontify-quote-and-verse-blocks))
	       ((string= block-type "quote")
		(add-text-properties beg1 (min (point-max) (1+ end1)) '(face org-quote)))
	       ((string= block-type "verse")
		(add-text-properties beg1 (min (point-max) (1+ end1)) '(face org-verse))))
	      (add-text-properties beg beg1 '(face org-block-begin-line))
	      (add-text-properties (min (point-max) (1+ end)) (min (point-max) (1+ end1))
				   '(face org-block-end-line))
	      t))
	   ((member dc1 '("+title:" "+author:" "+email:" "+date:"))
	    (org-remove-flyspell-overlays-in
	     (match-beginning 0)
	     (if (equal "+title:" dc1) (match-end 2) (match-end 0)))
	    (add-text-properties
	     beg (match-end 3)
	     (if (member (intern (substring dc1 1 -1)) org-hidden-keywords)
		 '(font-lock-fontified t invisible t)
	       '(font-lock-fontified t face org-document-info-keyword)))
	    (add-text-properties
	     (match-beginning 6) (min (point-max) (1+ (match-end 6)))
	     (if (string-equal dc1 "+title:")
		 '(font-lock-fontified t face org-document-title)
	       '(font-lock-fontified t face org-document-info))))
	   ((equal dc1 "+caption:")
	    (org-remove-flyspell-overlays-in (match-end 2) (match-end 0))
	    (remove-text-properties (match-beginning 0) (match-end 0)
				    '(display t invisible t intangible t))
	    (add-text-properties (match-beginning 1) (match-end 3)
				 '(font-lock-fontified t face org-meta-line))
	    (add-text-properties (match-beginning 6) (+ (match-end 6) 1)
				 '(font-lock-fontified t face org-block))
	    t)
	   ((member dc3 '(" " ""))
	    (org-remove-flyspell-overlays-in beg (match-end 0))
	    (add-text-properties
	     beg (match-end 0)
	     '(font-lock-fontified t face font-lock-comment-face)))
	   (t ;; just any other in-buffer setting, but not indented
	    (org-remove-flyspell-overlays-in (match-beginning 0) (match-end 0))
	    (remove-text-properties (match-beginning 0) (match-end 0)
				    '(display t invisible t intangible t))
	    (add-text-properties beg (match-end 0)
				 '(font-lock-fontified t face org-meta-line))
	    t))))))



(defface org-block-emacs-lisp
  `((t (:background "LightCyan1")))
  "Face for elisp src blocks")

(defface org-block-python
  `((t (:background "DarkSeaGreen1")))
  "Face for python blocks")

(defface org-block-ipython
  `((t (:background "thistle1")))
  "Face for python blocks") 

(defface org-block-sh
  `((t (:background "gray90")))
  "Face for python blocks")


;; * Latex Export settings

;; Interpret "_" and "^" for export when braces are used.
(setq org-export-with-sub-superscripts '{})

(setq org-latex-default-packages-alist
      '(("AUTO" "inputenc" t)
	("" "lmodern" nil)
	("T1" "fontenc" t)
	("" "fixltx2e" nil)
	("" "graphicx" t)
	("" "longtable" nil)
	("" "float" nil)
	("" "wrapfig" nil)
	("" "rotating" nil)
	("normalem" "ulem" t)
	("" "amsmath" t)
	("" "textcomp" t)
	("" "marvosym" t)
	("" "wasysym" t)
	("" "amssymb" t)
	("" "amsmath" t)
	("version=3" "mhchem" t)
	("numbers,super,sort&compress" "natbib" nil)
	("" "natmove" nil)
	("" "url" nil)
	("" "minted" nil)
	("" "underscore" nil)
	("linktocpage,pdfstartview=FitH,colorlinks,
linkcolor=blue,anchorcolor=blue,
citecolor=blue,filecolor=blue,menucolor=blue,urlcolor=blue"
	 "hyperref" nil)
	("" "attachfile" nil)))

;; do not put in \hypersetup. Use your own if you want it e.g.
;; \hypersetup{pdfkeywords={%s},\n pdfsubject={%s},\n pdfcreator={%}}
(setq org-latex-with-hyperref nil)

;; this is for code syntax highlighting in export. you need to use
;; -shell-escape with latex, and install pygments.
(setq org-latex-listings 'minted)
(setq org-latex-minted-options
      '(("frame" "lines")
	("fontsize" "\\scriptsize")
	("linenos" "")))

;; avoid getting \maketitle right after begin{document}
;; you should put \maketitle if and where you want it.
(setq org-latex-title-command "")

;; ** Custom new classes
;; customized article. better margins
(add-to-list 'org-latex-classes
	     '("article-1"                          ;class-name
	       "\\documentclass{article}
\\usepackage[top=1in, bottom=1.in, left=1in, right=1in]{geometry}
 [PACKAGES]
 [EXTRA]" ;;header-string
	       ("\\section{%s}" . "\\section*{%s}")
	       ("\\subsection{%s}" . "\\subsection*a{%s}")
	       ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	       ("\\paragraph{%s}" . "\\paragraph*{%s}")
	       ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;; This is for when you don't want any default packages, and you want
;; to declare them all yourself.
(add-to-list 'org-latex-classes
	     '("article-no-defaults"                          ;class-name
	       "\\documentclass{article}
 [NO-DEFAULT-PACKAGES]
 [PACKAGES]
 [EXTRA]" ;;header-string
	       ("\\section{%s}" . "\\section*{%s}")
	       ("\\subsection{%s}" . "\\subsection*a{%s}")
	       ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	       ("\\paragraph{%s}" . "\\paragraph*{%s}")
	       ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


;; * Markup commands for org-mode
(loop for (type beginning-marker end-marker)
      in '((subscript "_{" "}")
	   (superscript "^{" "}")
	   (italics "/" "/")
	   (bold "*" "*")
	   (verbatim "=" "=")
	   (code "~" "~")
	   (underline "_" "_")
	   (strikethrough "+" "+"))
      do
      (eval `(defun ,(intern (format "org-%s-region-or-point" type)) ()
	       ,(format "%s the region, word or character at point"
			(upcase (symbol-name type)))
	       (interactive)
	       (cond
		((region-active-p)
		 (goto-char (region-end))
		 (insert ,end-marker)
		 (goto-char (region-beginning))
		 (insert ,beginning-marker)
		 (re-search-forward (regexp-quote ,end-marker))
		 (goto-char (match-end 0)))
		((thing-at-point 'word)
		 (cond
		  ((looking-back " " 1)
		   (insert ,beginning-marker)
		   (re-search-forward "\\>")
		   (insert ,end-marker))
		  (t
		   (re-search-backward "\\<")
		   (insert ,beginning-marker)
		   (re-search-forward "\\>")
		   (insert ,end-marker))))

		(t
		 (insert ,(concat beginning-marker end-marker))
		 (backward-char ,(length end-marker)))))))

(defun org-latex-math-region-or-point (&optional arg)
  "Wrap the selected region in latex math markup.
\(\) or $$ (with prefix ARG) or @@latex:@@ with double prefix.
Or insert those and put point in the middle to add an equation."
  (interactive "P")
  (let ((chars
	 (cond
	  ((null arg)
	   '("\\(" . "\\)"))
	  ((equal arg '(4))
	   '("$" . "$"))
	  ((equal arg '(16))
	   '("@@latex:" . "@@")))))
    (if (region-active-p)
	(progn
	  (goto-char (region-end))
	  (insert (cdr chars))
	  (goto-char (region-beginning))
	  (insert (car chars)))
      (insert (concat  (car chars) (cdr chars)))
      (backward-char (length (cdr chars))))))


(defun helm-insert-org-entity ()
  "Helm interface to insert an entity from `org-entities'.
F1 inserts utf-8 character
F2 inserts entity code
F3 inserts LaTeX code (does not wrap in math-mode)
F4 inserts HTML code
F5 inserts the entity code."
  (interactive)
  (helm :sources
	(reverse
	 (let ((sources '())
	       toplevel
	       secondlevel)
	   (dolist (element (append
			     '("* User" "** User entities")
			     org-entities-user org-entities))
	     (when (and (stringp element)
			(s-starts-with? "* " element))
	       (setq toplevel element))
	     (when (and (stringp element)
			(s-starts-with? "** " element))
	       (setq secondlevel element)
	       (add-to-list
		'sources
		`((name . ,(concat
			    toplevel
			    (replace-regexp-in-string
			     "\\*\\*" " - " secondlevel)))
		  (candidates . nil)
		  (action . (("insert utf-8 char" . (lambda (x)
						      (mapc (lambda (candidate)
							      (insert (nth 6 candidate)))
							    (helm-marked-candidates))))
			     ("insert org entity" . (lambda (x)
						      (mapc (lambda (candidate)
							      (insert
							       (concat "\\" (car candidate))))
							    (helm-marked-candidates))))
			     ("insert latex" . (lambda (x)
						 (mapc (lambda (candidate)
							 (insert (nth 1 candidate)))
						       (helm-marked-candidates))))
			     ("insert html" . (lambda (x)
						(mapc (lambda (candidate)
							(insert (nth 3 candidate)))
						      (helm-marked-candidates))))
			     ("insert code" . (lambda (x)
						(mapc (lambda (candidate)
							(insert (format "%S" candidate)))
						      (helm-marked-candidates)))))))))
	     (when (and element (listp element))
	       (setf (cdr (assoc 'candidates (car sources)))
		     (append
		      (cdr (assoc 'candidates (car sources)))
		      (list (cons
			     (format "%10s %s" (nth 6 element) element)
			     element))))))
	   sources))))


(defun ivy-insert-org-entity ()
  "Insert an org-entity using ivy."
  (interactive)
  (ivy-read "Entity: " (loop for element in (append org-entities org-entities-user)
			     when (not (stringp element))
			     collect
			     (cons 
			      (format "%10s | %s | %s | %s"
				      (car element)
				      (nth 1 element)
				      (nth 3 element)
				      (nth 5 element))
			      element))
	    :require-match t
	    :action '(1
		      ("u" (lambda (element) (insert (nth 5 element))) "utf-8")
		      ("o" (lambda (element) (insert "\\" (car element))) "org-entity")
		      ("l" (lambda (element) (insert (nth 1 element))) "latex")
		      ("h" (lambda (element) (insert (nth 3 element))) "html"))))

;; * Font-lock
;; ** Latex fragments
;; Show equations and fragments in a blue font.
;; (add-hook 'org-mode-hook
;; 	  (lambda ()
;; 	    (font-lock-add-keywords
;; 	     nil
;; 	     `((,(mapconcat (lambda (x)
;; 			      (nth 1 x))
;; 			    org-latex-regexps
;; 			    "\\|") 0 '(:foreground "blue"))
;; 	       ("@@latex:[^@]*@@" 0 '(:foreground "blue"))))))

(setq org-highlight-latex-and-related '(latex script entities))
(set-face-foreground 'org-latex-and-related "blue")

;; * New org links

(org-add-link-type
 "attachfile"
 (lambda (link-string) (org-open-file link-string))
 ;; formatting
 (lambda (keyword desc format)
   (cond
    ((eq format 'html) (format "")); no output for html
    ((eq format 'latex)
     ;; write out the latex command
     (format "\\attachfile{%s}" keyword)))))

(org-add-link-type
 "altmetric"
 (lambda (doi)
   (browse-url (format  "http://dx.doi.org/%s" doi)))
 (lambda (keyword desc format)
   (cond
    ((eq format 'html)
     (format "<script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>
<div data-badge-type='medium-donut' class='altmetric-embed' data-badge-details='right' data-doi='%s'></div>" keyword)) 
    ((eq format 'latex)
     ""))))


;; * ivy navigation
(defun ivy-org-jump-to-visible-headline ()
  "Jump to visible headline in the buffer."
  (interactive)
  (org-mark-ring-push)
  (avy-with avy-goto-line (avy--generic-jump "^\\*+" nil avy-style)))

(defun ivy-jump-to-visible-sentence ()
  "Jump to visible sentence in the buffer."
  (interactive)
  (org-mark-ring-push)
  (avy-with avy-goto-line (avy--generic-jump (sentence-end) nil avy-style))
  (forward-sentence))

(defun ivy-org-jump-to-heading ()
  "Jump to heading in the current buffer."
  (interactive)
  (let ((headlines '()))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
	      ;; this matches org headings in elisp too.
	      "^\\(;; \\)?\\(\\*+\\)\\(?: +\\(.*?\\)\\)?[ 	]*$"  nil t)
	(cl-pushnew (list
		     (format "%-80s"
			     (match-string 0))
		     (cons 'position (match-beginning 0)))
		    headlines)))
    (ivy-read "Headline: "
	      (reverse headlines)
	      :action (lambda (candidate)
			(org-mark-ring-push)
			(goto-char (cdr (assoc 'position candidate)))
			(outline-show-entry)))))


(defun ivy-org-jump-to-agenda-heading ()
  "Jump to a heading in an agenda file."
  (interactive)
  (let ((headlines '()))
    ;; these files should be open already since they are agenda files.
    (loop for file in (org-agenda-files) do
	  (with-current-buffer (find-file-noselect file)
	    (save-excursion
	      (goto-char (point-min))
	      (while (re-search-forward org-heading-regexp nil t)
		(cl-pushnew (list
			     (format "%-80s (%s)"
				     (match-string 0)
				     (file-name-nondirectory file))
			     :file file
			     :position (match-beginning 0))
			    headlines)))))
    (ivy-read "Headline: "
	      (reverse headlines)
	      :action (lambda (candidate)
			(org-mark-ring-push)
			(find-file (plist-get candidate :file))
			(goto-char (plist-get candidate :position))
			(outline-show-entry)))))



(defun ivy-org-jump-to-heading-in-files (files &optional fontify)
  "Jump to org heading in FILES.
Optional FONTIFY colors the headlines. It might slow things down
a lot with large numbers of org-files or long org-files. This
function does not open the files."
  (let ((headlines '())) 
    (loop for file in files do
	  (with-temp-buffer 
	    (insert-file-contents file)
	    (when fontify
	      (org-mode)
	      (font-lock-fontify-buffer))
	    (goto-char (point-min))
	    (while (re-search-forward org-heading-regexp nil t)
	      (cl-pushnew (list
			   (format "%-80s (%s)"
				   (match-string 0)
				   (file-name-nondirectory file))
			   :file file
			   :position (match-beginning 0))
			  headlines))))
    (ivy-read "Headline: "
	      (reverse headlines)
	      :action (lambda (candidate)
			(org-mark-ring-push)
			(find-file (plist-get candidate :file))
			(goto-char (plist-get candidate :position))
			(outline-show-entry)))))


(defun ivy-org-jump-to-heading-in-directory (recursive)
  "Jump to heading in an org file in the current directory.
Use a prefix arg to make it RECURSIVE.
Use a double prefix to make it recursive and fontified."
  (interactive "P")

  (let ((fontify nil))
    (when (equal recursive '(16))
      (setq fontify t))
    (ivy-org-jump-to-heading-in-files
     (f-entries "."
		(lambda (f)
		  (and 
		   (f-ext? f "org")
		   (not (s-contains? "#" f))))
		recursive)
     fontify)))

(defun ivy-org-jump-to-project-headline (fontify)
  "Jump to a headline in an org-file in the current project.
Use a prefix arg FONTIFY for colored headlines."
  (interactive "P")
  (ivy-org-jump-to-heading-in-files
   (mapcar
    (lambda (f) (expand-file-name f (projectile-project-root)))
    (-filter (lambda (f)
	       (and 
		(f-ext? f "org")
		(not (s-contains? "#" f))))
	     (projectile-current-project-files)))
   fontify))


;; * track changes
(require 'cm-mods)
(add-hook 'org-mode-hook #'cm-mode)

;; * The end
(provide 'scimax-org)

;;; scimax-org.el ends here
