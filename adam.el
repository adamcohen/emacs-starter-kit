;start the emacsclient server
(server-start)

;remove annoying "Buffer `buffername' still has clients; kill it?" message
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(setq 
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

;; when using ido, the confirmation is rather annoying...
 (setq confirm-nonexistent-file-or-buffer nil)

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

(defun xadam-save-current-directory ()
  "Save the current directory to the file ~/.emacs.d/adam/current-directory"
  (interactive)
  (let ((dir default-directory))
    (with-current-buffer (find-file-noselect "~/.emacs.d/adam/current-directory")
      (delete-region (point-min) (point-max))
      (insert (concat dir "\n"))
      (save-buffer)
      (kill-buffer (current-buffer)))))
(global-set-key [(super f10)] 'xadam-save-current-directory)

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

(defun lw ()
  (interactive)
  "insert log message containing clipboard contents"
  (set 'logmsg (concat "(%|" ( upcase (car kill-ring)) ": #{" (car kill-ring) ".inspect}|)\n"))
  (insert (concat "logger.debug" logmsg))
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
