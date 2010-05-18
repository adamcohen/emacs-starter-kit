(add-to-list 'load-path 
   (concat dotfiles-dir "adam/yasnippets-rails"))

(add-hook 'ruby-mode-hook ; or rails-minor-mode-hook ?
          '(lambda ()
             (make-variable-buffer-local 'yas/trigger-key)
             (setq yas/trigger-key [tab])))

(require 'yasnippet)
;(add-to-list 'yas/extra-mode-hooks
;             'ruby-mode-hook)

(yas/initialize)
(setq yas/window-system-popup-function 'yas/x-popup-menu-for-template)
;(yas/load-directory (concat dotfiles-dir "adam/yasnippet/snippets"))

(yas/load-directory 
   (concat 
      dotfiles-dir "adam/yasnippets-rails/rails-snippets/"))

(yas/load-directory 
   (concat 
      dotfiles-dir "adam/yasnippets-rails/cucumber-snippets/"))

(make-variable-buffer-local 'yas/trigger-key)

(require 'ruby-electric)
(add-hook 'ruby-mode-hook
          (lambda nil
            (require 'ruby-electric)
            (ruby-electric-mode)))

(color-theme-clarity)

;(add-to-list 'load-path "~/.emacs.d/cucumber.el/")

;; and load it
;(require 'feature-mode)
;(add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))

;; Feature mode Key Bindings
;; ------------

;; \C-c ,v - Verify all scenarios in the current buffer file.

;; \C-c ,s - Verify the scenario under the point in the current buffer.

;; \C-c ,f - Verify all features in project. (Available in feature and ruby files)

;; \C-c ,r - Repeat the last verification process.
(define-key ruby-mode-map (kbd "TAB") nil)
