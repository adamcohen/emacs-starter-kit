(add-to-list 'load-path 
   (concat dotfiles-dir "acohen/yasnippets-rails"))

(require 'ruby-electric)

(add-hook 'ruby-mode-hook ; or rails-minor-mode-hook ?
          '(lambda ()
             (require 'ruby-electric)
             (ruby-electric-mode)
             (make-variable-buffer-local 'yas/trigger-key)
             (setq yas/trigger-key [tab])))

(require 'yasnippet)
;(add-to-list 'yas/extra-mode-hooks
;             'ruby-mode-hook)

(yas/initialize)
(setq yas/window-system-popup-function 'yas/x-popup-menu-for-template)
;(yas/load-directory (concat dotfiles-dir "acohen/yasnippet/snippets"))

(yas/load-directory 
   (concat 
      dotfiles-dir "acohen/yasnippets-rails/rails-snippets/"))

(yas/load-directory 
   (concat 
      dotfiles-dir "acohen/yasnippets-rails/cucumber-snippets/"))

(make-variable-buffer-local 'yas/trigger-key)

(setq yas/wrap-around-region 'cua)

(color-theme-clarity)

(add-hook 'html-mode-hook
          (lambda nil
            (auto-fill-mode -1)))

;(add-to-list 'load-path "~/.emacs.d/cucumber.el/")

;; and load it
;; (require 'feature-mode)
;; (add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))

;; Feature mode Key Bindings
;; ------------

;; \C-c ,v - Verify all scenarios in the current buffer file.

;; \C-c ,s - Verify the scenario under the point in the current buffer.

;; \C-c ,f - Verify all features in project. (Available in feature and ruby files)

;; \C-c ,r - Repeat the last verification process.
(define-key ruby-mode-map (kbd "TAB") nil)

;;; CEDET stuff
(load-file "~/.emacs.d/acohen/cedet-1.0pre7/common/cedet.el")
(global-ede-mode 1)                      ; Enable the Project management system
(semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion 
(global-srecode-minor-mode 1)            ; Enable template insertion menu

(add-to-list 'load-path "~/.emacs.d/acohen/ecb-2.40/")
(require 'ecb)
(setq ecb-tip-of-the-day nil)

;; (add-to-list 'load-path "~/.emacs.d/acohen/autopair.el") ;; comment if autopair.el is in standard load path 
;; (require 'autopair)
;; (autopair-global-mode) ;; enable autopair in all buffers 

;;; disable this - don't like the kill ring window that pops up, it's annoying
;; (when (require 'browse-kill-ring nil 'noerror)
;;   (browse-kill-ring-default-keybindings))
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'scheme-mode-hook     'enable-paredit-mode)
(add-hook 'clojure-mode-hook    'enable-paredit-mode)
(add-hook 'ruby-mode-hook       'esk-paredit-nonlisp)
(add-hook 'espresso-mode-hook   'esk-paredit-nonlisp)

;; C-M-n runs the command ruby-end-of-block, which is an interactive
;; C-M-f runs the command ruby-forward-sexp, which is an interactive
;; C-M-b runs the command ruby-backward-sexp, which is an interactive
;; C-M-p runs the command ruby-beginning-of-block, which is an

;; DEL (translated from <backspace>) runs the command
;; delete-backward-char, which is an interactive built-in function in `C
;; source code'.


(add-hook 'ruby-mode-hook
          '(lambda ()
;;; I don't like the way paredit handles ruby sexp
(define-key paredit-mode-map (kbd "M-C-a") 'ruby-beginning-of-defun)
(define-key paredit-mode-map (kbd "M-C-e") 'ruby-end-of-defun)
(define-key paredit-mode-map (kbd "M-C-b") 'ruby-backward-sexp)
(define-key paredit-mode-map (kbd "M-C-f") 'ruby-forward-sexp)
(define-key paredit-mode-map (kbd "M-C-p") 'ruby-beginning-of-block)
(define-key paredit-mode-map (kbd "M-C-n") 'ruby-end-of-block)
(define-key paredit-mode-map (kbd "<backspace>") 'delete-backward-char)
))


