;start the emacsclient server
(server-start)

;remove annoying "Buffer `buffername' still has clients; kill it?" message
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(setq 
  tags-revert-without-query 1      ; automatically reload the TAGS
                                   ; table if it changes
  ;; when using ido, the confirmation is rather annoying...
  warning-suppress-types nil
  confirm-nonexistent-file-or-buffer nil
  ido-save-directory-list-file "~/.emacs.d/cache/ido.last"
  ido-ignore-buffers ;; ignore these guys
  '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido" "^\*trace"
     "^\*compilation" "^\*GTAGS" "^session\.*" "^\*")
  ido-work-directory-list '("~/" "~/Desktop" "~/Documents" "~src")
  ido-case-fold  t                 ; be case-insensitive
  ido-enable-last-directory-history t ; remember last used dirs
  ido-max-work-directory-list 30   ; should be enough
  ido-max-work-file-list      50   ; remember many
  ido-use-filename-at-point nil    ; don't use filename at point (annoying)
  ido-use-url-at-point nil         ; don't use url at point (annoying)
  ido-enable-regexp t              ; use regexp matchin
  ido-enable-flex-matching nil     ; disabled so we can use regexp matching
  ido-max-prospects 8              ; don't spam my minibuffer
  ido-confirm-unique-completion t) ; wait for RET, even with unique completion

; enable tramp to open files using sudo on a remote machine by
; doing C-x C-f /sudo:root@host[#port]:/path/to/file
(set-default 'tramp-default-proxies-alist (quote ((".*" "\\`root\\'" "/ssh:%h:"))))

;;; SET DEFAULT FONT SIZE/HEIGHT
; (set-face-attribute 'default nil :font "DejaVu Sans Mono-12")
(set-face-attribute 'default nil :height 123)


;; increase minibuffer size when ido completion is active
(add-hook 'ido-minibuffer-setup-hook 
  (function
    (lambda ()
      (make-local-variable 'resize-minibuffer-window-max-height)
      (setq resize-minibuffer-window-max-height 1))))

(setq initial-scratch-message nil)
(setq scroll-in-place t)
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; Put autosave files (ie #foo#) in one place, *not*
;; scattered all over the file system!
(defvar autosave-dir "~/tmp/emacs_autosaves/")
(make-directory autosave-dir t)

(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))

(defun make-auto-save-file-name ()
  (concat autosave-dir
          (if buffer-file-name
              (concat "#" (file-name-nondirectory buffer-file-name) "#")
            (expand-file-name
             (concat "#%" (buffer-name) "#")))))

;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir "~/tmp/emacs_autosaves/")
(setq backup-directory-alist (list (cons "." backup-dir)))

;; allow us to copy between emacs and other x programs
(setq x-select-enable-clipboard t)


(setq cua-enable-cua-keys nil) ;; only for rectangles
(cua-mode t)


;; COPYING LINES WITHOUT SELECTING THEM
;; http://emacs-fu.blogspot.com/2009/11/copying-lines-without-selecting-them.html
;; When I'm programming, I often need to copy a line. Normally, this requires me to first select ('mark') the line I want to copy. That does not seem like a big deal, but when I'm in the 'flow' I want to avoid any little obstacle that can slow me down.

;; So, how can I copy the current line without selection? I found a nice trick by MacChan on EmacsWiki to accomplish this. It also adds ta function to kill (cut) the current line (similar to kill-line (C-k), but kills the whole line, not just from point (cursor) to the end.

;; The code below simply embellishes the normal functions with the functionality 'if nothing is selected, assume we mean the current line'. The key bindings stay the same (M-w, C-w).

;; To enable this, put the following in your .emacs:

(defadvice kill-ring-save (before slick-copy activate compile) "When called
  interactively with no active region, copy a single line instead."
  (interactive (if mark-active (list (region-beginning) (region-end)) (message
  "Copied line") (list (line-beginning-position) (line-beginning-position
  2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
    (if mark-active (list (region-beginning) (region-end))
      (list (line-beginning-position)
        (line-beginning-position 2)))))

;; END COPYING LINES WITHOUT SELECTING THEM


;; DUPLICATING LINES AND COMMENTING THEM
;; http://emacs-fu.blogspot.com/
;; Someone on the Emacs Help mailing list asked for an easy way to duplicate a line
;; and, optionally, comment-out the first one.

;; I hacked up something quickly to solve both questions, and it has evolved a
;; little bit since – to answer both of the questions. The bit of weirdness in
;; the end is because of the special case of the last line in a buffer. It
;; defines key bindings C-c y for duplicating a line, and C-c c for
;; duplicating + commenting – but of course you can change those.
(defun djcb-duplicate-line (&optional commentfirst)
  "comment line at point; if COMMENTFIRST is non-nil, comment the original" 
  (interactive)
  (beginning-of-line)
  (push-mark)
  (end-of-line)
  (let ((str (buffer-substring (region-beginning) (region-end))))
    (when commentfirst
    (comment-region (region-beginning) (region-end)))
    (insert-string
      (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
    (forward-line -1)))

;; or choose some better bindings....

;; duplicate a line
(global-set-key (kbd "C-c y") 'djcb-duplicate-line)

;; duplicate a line and comment the first
(global-set-key (kbd "C-c c") (lambda()(interactive)(djcb-duplicate-line t)))

;; END DUPLICATING LINES AND COMMENTING THEM
(global-linum-mode t)

(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on) 

(defun transpose-buffers (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(require 'rinari)
(setq rinari-tags-file-name "TAGS")
(define-key rinari-minor-mode-map [(control meta shift down)] 'rinari-find-rspec)
(define-key rinari-minor-mode-map [(control meta shift left)] 'rinari-find-controller)
(define-key rinari-minor-mode-map [(control meta shift up)] 'rinari-find-model)
(define-key rinari-minor-mode-map [(control meta shift right)] 'rinari-find-view)
(global-set-key [f6] 'split-window-horizontally)
(global-set-key [f7] 'split-window-vertically)
(global-set-key [f8] 'delete-window)
(global-set-key (kbd "C-x C-j") 'dired-jump)
(global-set-key "\M-n"  (lambda () (interactive) (scroll-up   1)) )
(global-set-key "\M-p"  (lambda () (interactive) (scroll-down 1)) )
(global-set-key "\M-g"  'goto-line)
(global-set-key [f5] 'call-last-kbd-macro)

(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
n    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

;;; disabled, since I rarely use these
;; (global-set-key (kbd "M-<up>") 'move-line-up)
;; (global-set-key (kbd "M-<down>") 'move-line-down)

(global-set-key (kbd "<f9>")  ;make F9 switch to *scratch*     
  (lambda()(interactive)(switch-to-buffer "*scratch*")))

(defun xacohen-save-current-directory ()
  "Save the current directory to the file ~/.emacs.d/acohen/current-directory"
  (interactive)
  (let ((dir default-directory))
    (with-current-buffer (find-file-noselect "~/.emacs.d/acohen/current-directory")
      (delete-region (point-min) (point-max))
      (insert (concat dir "\n"))
      (save-buffer)
      (kill-buffer (current-buffer)))))
(global-set-key [(super f10)] 'xacohen-save-current-directory)

;; save a list of open files in ~/.emacs.desktop
;; save the desktop file automatically if it already exists
(setq desktop-save 'if-exists)
(desktop-save-mode 1)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))

;;; by default, desktop mode only saves when you cleanly exit emacs.
;;; We want to autosave the desktop file whenever emacs is idle, so we
;;; use the following
  (defun my-desktop-save ()
    (interactive)
    ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
            (desktop-save desktop-dirname))
  (add-hook 'auto-save-hook 'my-desktop-save)

(defun lw ()
  (interactive)
  "insert log message containing clipboard contents"
  (set 'logmsg (concat "(%|\\n\\n[XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX]\\n"))
  (set 'logmsg (concat logmsg (concat "[" (car (last (split-string buffer-file-name "/"))) "]\\n")))
  (set 'logmsg (concat logmsg ( upcase (car kill-ring)) ": #{" (car kill-ring) ".inspect}\\n"))
  (set 'logmsg (concat logmsg "[XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX]\\n\\n|)" "\n"))
  (insert (concat "Rails.logger.debug" logmsg))
  (insert (concat "puts" logmsg))
  )

(defun lp ()
  (interactive)
  "insert puts message containing clipboard contents"
  (set 'logmsg (concat "(%|" ( upcase (car kill-ring)) ": #{" (car kill-ring) ".inspect}|)"))
  (insert (concat "puts \"XXXXXXXXXXXXXXXX\", " logmsg ", \"XXXXXXXXXXXXXXXX\"\n"))
)

(global-set-key (kbd "C-c C-j") 'lw)
(global-set-key (kbd "C-c C-p") 'lp)

(defun clear-shell ()
   (interactive)
   (let ((comint-buffer-maximum-size 0))
     (comint-truncate-buffer)))

;; reclaim some binding used by shell mode and shell-command.
;; the shell mode and associated mode and commands use keys in comint-mode-map.
(add-hook 'shell-mode-hook
 (lambda ()
   (define-key shell-mode-map (kbd "C-c C-f") 'find-file-at-point)
   (define-key shell-mode-map [f1] 'clear-shell)
))

;; remove P (ibuffer-do-print) in ibuffer mode, since it's
;; way too easy to print a shitload of buffers!
(add-hook 'ibuffer-mode-hook
 (lambda ()
   (define-key ibuffer-mode-map (kbd "P") 'ibuffer-backward-line)
))

(defun gf ()
  (interactive)
"copy the full path to the current buffer into the clipboard"
(kill-new buffer-file-name))

(defun gff ()
  (interactive)
"copy the relative path to the current buffer into the clipboard"
(kill-new (replace-regexp-in-string "/home/acohen/.*?/" "" buffer-file-name)))

;; Remove completion buffer when done
(add-hook 'minibuffer-exit-hook 
      '(lambda ()
         (let ((buffer "*Completions*"))
           (and (get-buffer buffer)
            (kill-buffer buffer)))))

;; originally from http://sites.google.com/site/steveyegge2/my-dot-emacs-file
;; adapted from http://stackoverflow.com/questions/384284/can-i-rename-an-open-file-in-emacs
;; to support moving to a new directory
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive
   (progn
     (if (not (buffer-file-name))
         (error "Buffer '%s' is not visiting a file!" (buffer-name)))
     (list (read-file-name (format "Rename %s to: " (file-name-nondirectory
                                                     (buffer-file-name)))))))
  (if (equal new-name "")
      (error "Aborted rename"))
  (setq new-name (if (file-directory-p new-name)
                     (expand-file-name (file-name-nondirectory
                                        (buffer-file-name))
                                       new-name)
                   (expand-file-name new-name)))
  ;; If the file isn't saved yet, skip the file rename, but still update the
  ;; buffer name and visited file.
  (if (file-exists-p (buffer-file-name))
      (rename-file (buffer-file-name) new-name 1))
  (let ((was-modified (buffer-modified-p)))
    ;; This also renames the buffer, and works with uniquify
    (set-visited-file-name new-name)
    (if was-modified
        (save-buffer)
      ;; Clear buffer-modified flag caused by set-visited-file-name
      (set-buffer-modified-p nil))
  (message "Renamed to %s." new-name)))

 (defun my-ido-project-files ()
      "Use ido to select a file from the project."
      (interactive)
      (let (my-project-root project-files tbl)
      (unless project-details (project-root-fetch))
      (setq my-project-root (cdr project-details))
      ;; get project files
      (setq project-files 
	    (split-string 
	     (shell-command-to-string 
	      (concat "find "
		      my-project-root
		      " \\( -name \"*.svn\" -o -name \"*.git\" \\) -prune -o -type f -print | grep -E -v \"\.(pyc)$\""
		      )) "\n"))
      ;; populate hash table (display repr => path)
      (setq tbl (make-hash-table :test 'equal))
      (let (ido-list)
      (mapc (lambda (path)
	      ;; format path for display in ido list
	      (setq key (replace-regexp-in-string "\\(.*?\\)\\([^/]+?\\)$" "\\2|\\1" path))
	      ;; strip project root
	      (setq key (replace-regexp-in-string my-project-root "" key))
	      ;; remove trailing | or /
	      (setq key (replace-regexp-in-string "\\(|\\|/\\)$" "" key))
	      (puthash key path tbl)
	      (push key ido-list)
	      )
	    project-files
	    )
      (find-file (gethash (ido-completing-read "project-files: " ido-list) tbl)))))
    ;; bind to a key for quick access
    (define-key global-map [f6] 'my-ido-project-files)

;; I know that string is in my Emacs somewhere!
(defcustom search-all-buffers-ignored-files (list (rx-to-string '(and bos (or ".bash_history" "TAGS") eos)))
  "Files to ignore when searching buffers via \\[search-all-buffers]."
  :type 'editable-list)

(require 'grep)
(defun search-all-buffers (regexp prefix)
  "Searches file-visiting buffers for occurence of REGEXP.  With
prefix > 1 (i.e., if you type C-u \\[search-all-buffers]),
searches all buffers."
  (interactive (list (grep-read-regexp)
                     current-prefix-arg))
  (message "Regexp is %s; prefix is %s" regexp prefix)
  (multi-occur
   (if (member prefix '(4 (4)))
       (buffer-list)
     (remove-if
      (lambda (b) (some (lambda (rx) (string-match rx  (file-name-nondirectory (buffer-file-name b)))) search-all-buffers-ignored-files))
      (remove-if-not 'buffer-file-name (buffer-list))))

   regexp))

(global-set-key [f7] 'search-all-buffers)

(defun my-ido-find-tag ()
    "Find a tag using ido"
    (interactive)
    (tags-completion-table)
    (let (tag-names)
      (mapc (lambda (x)
              (unless (integerp x)
                (push (prin1-to-string x t) tag-names)))
            tags-completion-table)
      (find-tag (ido-completing-read "Tag: " tag-names))))

(defun ido-find-file-in-tag-files ()
      (interactive)
      (save-excursion
        (let ((enable-recursive-minibuffers t))
          (visit-tags-table-buffer))
        (find-file
         (expand-file-name
          (ido-completing-read
           "Project file: " (tags-table-files) nil t)))))

(global-set-key [f8] 'ido-find-file-in-tag-files)

  ;; Display ido results vertically, rather than horizontally
  (setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
  (defun ido-disable-line-trucation () (set (make-local-variable 'truncate-lines) nil))
  (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-trucation)

(defvar my-local-shells
  '("*shell0*" "*shell1*" "*shell2*" "*shell3*"))

(defvar my-shells (append my-local-shells))

(custom-set-variables
 '(comint-scroll-to-bottom-on-input t)  ; always insert at the bottom
 '(comint-scroll-to-bottom-on-output nil) ; always add output at the bottom
 '(comint-scroll-show-maximum-output t) ; scroll to show max possible output
 ;; '(comint-completion-autolist t)     ; show completion list when ambiguous
 '(comint-input-ignoredups t)           ; no duplicates in command history
 '(comint-completion-addsuffix t)       ; insert space/slash after file completion
 '(comint-buffer-maximum-size 1000)    ; max length of the buffer in lines
 '(comint-prompt-read-only nil)         ; if this is t, it breaks shell-command
 '(comint-get-old-input (lambda () "")) ; what to run when i press enter on a
                                        ; line above the current prompt
 '(comint-input-ring-size 5000)         ; max shell history size
 '(protect-buffer-bury-p nil)
)

(setenv "PAGER" "cat")

;; truncate buffers continuously
(add-hook 'comint-output-filter-functions 'comint-truncate-buffer)

(defun make-my-shell-output-read-only (text)
  "Add to comint-output-filter-functions to make stdout read only in my shells."
  (if (member (buffer-name) my-shells)
      (let ((inhibit-read-only t)
            (output-end (process-mark (get-buffer-process (current-buffer)))))
        (put-text-property comint-last-output-start output-end 'read-only t))))
(add-hook 'comint-output-filter-functions 'make-my-shell-output-read-only)

(defun my-dirtrack-mode ()
  "Add to shell-mode-hook to use dirtrack mode in my shell buffers."
  (when (member (buffer-name) my-shells)
    (shell-dirtrack-mode 0)
    (set-variable 'dirtrack-list '("^.*[^ ]+:\\(.*\\)>" 1 nil))
    (dirtrack-mode 1)))
(add-hook 'shell-mode-hook 'my-dirtrack-mode)

; interpret and use ansi color codes in shell output windows
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(defun set-scroll-conservatively ()
  "Add to shell-mode-hook to prevent jump-scrolling on newlines in shell buffers."
  (set (make-local-variable 'scroll-conservatively) 10))
(add-hook 'shell-mode-hook 'set-scroll-conservatively)

(defun enter-again-if-enter ()
  "Make the return key select the current item in minibuf and shell history isearch.
An alternate approach would be after-advice on isearch-other-meta-char."
  (when (and (not isearch-mode-end-hook-quit)
             (equal (this-command-keys-vector) [13])) ; == return
    (cond ((active-minibuffer-window) (minibuffer-complete-and-exit))
          ((member (buffer-name) my-shells) (comint-send-input)))))
(add-hook 'isearch-mode-end-hook 'enter-again-if-enter)

(defadvice comint-previous-matching-input
    (around suppress-history-item-messages activate)
  "Suppress the annoying 'History item : NNN' messages from shell history isearch.
If this isn't enough, try the same thing with
comint-replace-by-expanded-history-before-point."
  (let ((old-message (symbol-function 'message)))
    (unwind-protect
      (progn (fset 'message 'ignore) ad-do-it)
    (fset 'message old-message))))

(defadvice comint-send-input (around go-to-end-of-multiline activate)
  "When I press enter, jump to the end of the *buffer*, instead of the end of
the line, to capture multiline input. (This only has effect if
`comint-eol-on-send' is non-nil."
  (flet ((end-of-line () (end-of-buffer)))
    ad-do-it))

;if a file is already open in read only mode, use this to re-open the
;file with sudo access
(defun find-alternative-file-with-sudo ()
  (interactive)
  (let ((fname (or buffer-file-name
		   dired-directory)))
    (when fname
      (if (string-match "^/sudo:root@localhost:" fname)
	  (setq fname (replace-regexp-in-string
		       "^/sudo:root@localhost:" ""
		       fname))
	(setq fname (concat "/sudo:root@localhost:" fname)))
      (find-alternate-file fname))))

;;; THIS STUFF BELOW DOESN'T WORK - TODO: SEND A MESSAGE TO EMACS LIST
;; TO FIND OUT WHY THE LONGER VERSION DOESN'T DISPLAY ANYTHING
;; (defun vc-git-annotate-command (file buffer &optional revision)
;;   "Prepare BUFFER for `vc-annotate' on FILE.
;; Each line is tagged with the revision number, which has a `help-echo'
;; property containing author and date information."
;;   (apply #'vc-git-command buffer 'async nil "blame" "--date=iso" "-C" "-C" revision "--" (file-relative-name file)
;;          (if revision (list "-r" revision)))
;;   (lexical-let ((table (make-hash-table :test 'equal)))
;;     (set-process-filter
;;      (get-buffer-process buffer)
;;      (lambda (proc string)
;;        (when (process-buffer proc)
;;          (with-current-buffer (process-buffer proc)
;;            (setq string (concat (process-get proc :vc-left-over) string))
;;            (while (string-match "^\\([0-9a-z]+\\) \\(.+?\\) (\\(.+?\\) + \\(.\\{25\\}\\) +\\([0-9]+\\)) +\\(.*\\)$" string)
;;              (let* ((rev (match-string 1 string))
;;                     (path (match-string 2 string))
;;                     (author (match-string 3 string))
;;                     (date (match-string 4 string))
;;                     (key (substring string (match-beginning 0)
;;                                     (match-beginning 4)))
;;                     (line (match-string 5 string))
;;                     (tag (gethash key table))
;;                     (inhibit-read-only t))
;;                (setq string (substring string (match-end 0)))
;; 	       (unless tag
;; 		 (setq tag
;; 		       (propertize
;; 			(format "%s %-7.7s" rev author)
;; 			'help-echo (format "Revision: %d, author: %s, date: %s"
;; 					   (string-to-number rev)
;; 					   author date)
;; 			'mouse-face 'highlight))
;;                  (puthash key tag table))
;;                (goto-char (process-mark proc))
;;                (insert tag line)
;;                (move-marker (process-mark proc) (point))))
;;            (process-put proc :vc-left-over string)))))))

;; (defun vc-git-annotate-command (file buf &optional rev)
;;   (let ((name (file-relative-name file)))
;;     (vc-git-command buf 'async nil "blame" "--date=iso" "-C" "-C" rev "--" name)))
