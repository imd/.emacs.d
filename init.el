(require 'cl)

(add-to-list 'exec-path "~/Applications/bin")
(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/site-lisp")
(add-to-list 'load-path "~/.emacs.d/site-lisp/g-client")
;; (add-to-list 'load-path "~/.emacs.d/site-lisp/slime")
(load (expand-file-name "~/.quicklisp/slime-helper.el"))

(setq custom-file "~/.emacs.d/lisp/custom.el")
(load custom-file)
(load-library "keybindings")    ;key bindings and aliases
(load-library "functions")      ;functions I've collected or written
(load-library "misc")           ;misc settings
(load-library "modes")          ;configuration for modes

;;; Miscellaneous

;; Always end searches at the beginning of the matching expression.
(add-hook 'isearch-mode-end-hook 'custom-goto-match-beginning)
(when (file-readable-p "f:/cygwin/bin/bash.exe")
  (let ((cygwin-bin "f:/cygwin/bin"))
    (add-to-list 'exec-path cygwin-bin)
    (setenv "PATH" (concat cygwin-bin ";" (getenv "PATH"))))
  (setq shell-file-name "bash"
        explicit-shell-file-name "bash"))

;; (when (member system-name '("Asmodeus" "Kimiko"))
;;   (split-window-horizontally))
(add-to-list 'default-frame-alist '(alpha 75 50))

;; EmacsClient
(server-start)
