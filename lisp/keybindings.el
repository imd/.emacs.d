;;;; Global

;;; Cursor movement
(global-set-key (kbd "M-p")             'chop-move-up)
(global-set-key (kbd "M-n")             'chop-move-down)
(global-set-key (kbd "M-P")             'move-line-up)
(global-set-key (kbd "M-N")             'move-line-down)
(global-set-key (kbd "%")               'match-paren)

;;; Text editing
(global-set-key (kbd "M-C-q")           'unfill-paragraph)
(global-set-key (kbd "C-'")             'hippie-expand)

;;; Code only
(global-set-key (kbd "<C-tab>")         'comment-indent)
(global-set-key (kbd "<C-M-backspace>") 'backward-kill-sexp)
(global-set-key (kbd "<C-M-delete>")    'backward-kill-sexp)

;;; Buffer editing and operations
(global-set-key (kbd "C-c d")           'diff-buffer-with-associated-file)
(global-set-key (kbd "C-x C-M-b")       'bury-buffer)
(global-set-key (kbd "C-x C-r")         'find-alternative-file-with-sudo)

;;; Applications and F-keys
(global-set-key (kbd "C-c s")           'slime-selector)
(global-set-key (kbd "<f2>")            'calc)
(global-set-key (kbd "<f4>")            'calendar)
(global-set-key (kbd "<f8>")            'call-last-kbd-macro)
(global-set-key (kbd "<C-f8>")          'start-or-end-macro)
(global-set-key (kbd "<f9>")            'disk) ;DiskKey, synchronize buffer with disk
(global-set-key (kbd "<f11>")           'flymake-goto-prev-error)
(global-set-key (kbd "<f12>")           'flymake-goto-next-error)

;;; Org
(global-set-key (kbd "C-c a")           'org-agenda)
(global-set-key (kbd "C-c c")           'org-capture)
(global-set-key (kbd "C-c j")           'journal)
(global-set-key (kbd "C-c g")           'gtd)
(global-set-key (kbd "<f7>")            'count-words-org-buffer)

;;;; Dired

(add-hook 'dired-mode-hook
          (lambda () (local-set-key "E" 'dired-xdg-open-file)))

;;;; Java

(add-hook 'java-mode-hook
          (lambda ()
            (local-set-key (kbd "C-<f11>") 'compile)
            (local-set-key (kbd "C-h S") 'javadoc-lookup)
            (local-set-key (kbd "C-h M-s") 'javadoc-help)))

;;;; HTML

(add-hook 'html-helper-mode-hook
          (lambda () (local-set-key (kbd "C-x t") 'tidy-buffer)))

;;;; rcirc

(define-key rcirc-mode-map (kbd "C-x C-e") 'slime-rcirc-eval-last-expression)

;;;; SLIME

;; (eval-after-load "slime"
;;   '(define-key slime-repl-mode-map (kbd "C-c ;")
;;      'slime-insert-balanced-comments))

(provide 'keybindings)
