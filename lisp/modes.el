;;;; C#

(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)

(add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-mode))
(defun my-csharp-mode-fn ()
  "function that runs when csharp-mode is initialized for a buffer."
  (c-set-style "bsd")
  (setq c-basic-offset 4))
(add-hook 'csharp-mode-hook 'my-csharp-mode-fn t)

;;;; Diction

(autoload 'diction-region "diction"
  "Run detex'd region through diction and display output in buffer
\"*Diction-Output*\"." t)
(autoload 'diction-buffer "diction"
  "Run detex'd buffer through diction and display output in buffer
\"*Diction-Output*\"." t)

;;;; Email

; (require 'bbdb)
; (bbdb-initialize 'gnus 'message)

(add-to-list 'auto-mode-alist '("\\.mbox\\'" . mail-mode))

;;;; File Management

(require 'uniquify)

(autoload 'disk "disk" "Save, revert, or find file." t)

(add-hook 'after-save-hook 'local-add-file-to-recent)
(add-hook 'dired-load-hook (function (lambda ()
                                       (load "dired-x")
                                       (dired-omit-mode 1)
                                       (toggle-truncate-lines 1))))
(eval-after-load "saveplace"
  '(defalias 'save-place-alist-to-file 'imd-save-place-alist-to-file))

;;;; Google services

(require 'g)

;;;; Graphviz dot mode

(load-library "graphviz-dot-mode")

;;;; Java

(autoload 'javadoc-lookup "javadoc-help" "Look up Java class in Javadoc."   t)
(autoload 'javadoc-help "javadoc-help" "Open up the Javadoc-help menu."   t)
(autoload 'javadoc-set-predefined-urls "javadoc-help" "Set pre-defined urls."
  t)

;;;; JavaScript

;; (autoload 'js2-mode "js2" nil t)
;; (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;; (require 'flymake-jslint)
;; (when (executable-find "rhino")
;;   (add-hook 'js2-mode-hook (lambda () (flymake-mode t))))

;;;; KeyWiz

(autoload 'keywiz "keywiz" "Start the key sequence quiz." t)

;;;; Lisp

(add-hook 'lisp-mode-hook
          (lambda ()
            (set (make-local-variable 'lisp-indent-function)
                 'common-lisp-indent-function)))

(when (file-exists-p "~/.quicklisp/slime-helper.el")
  (load (expand-file-name "~/.quicklisp/slime-helper.el")))

;; (require 'slime-autoloads)

(eval-after-load "slime"
  '(progn
     (slime-setup '(slime-fancy slime-asdf slime-banner))
     (setq slime-complete-symbol*-fancy t)
     (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)))

(add-hook 'slime-mode-hook
          (lambda ()
            (unless (slime-connected-p)
              (save-excursion (slime)))))

;; (setq slime-lisp-implementations
;;       `((sbcl ("sbcl" "--core"
;;                ,(expand-file-name "~/.sbcl/sbcl.core-with-swank"))
;;               :init (lambda (port-file _)
;;                       (format "(swank:start-server %S)\n" port-file)))))

(require 'info-look)

(info-lookup-add-help
 :mode 'lisp-mode
 :regexp "[^][()'\" \t\n]+"
 :ignore-case t
 :doc-spec '(("(ansicl)Symbol Index" nil nil nil)))

(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code."
  t)

(eval-after-load "paredit"
  '(progn
     (define-key paredit-mode-map (kbd "RET") 'paredit-newline)
     (define-key paredit-mode-map (kbd "C-j") nil)))

(mapc (lambda (hook)
        (add-hook hook (lambda ()
                         (paredit-mode +1))))
      '(lisp-mode-hook
        emacs-lisp-mode-hook
        slime-repl-mode-hook
        scheme-mode-hook
        t-mode-hook))

;;; From Jorgen Schaefer (forcer)
;;; Make round brackets less visible
(mapc (lambda (mode)
        (font-lock-add-keywords mode '(("[()]" . 'paren-face))))
      '(lisp-mode
        emacs-lisp-mode
        slime-repl-mode
        scheme-mode
        t-mode))

(defface paren-face
  '((t (:foreground "gray60")))
  "The face used for parenthesises.")

;;;; Markdown

(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;;; Org

(setq org-ditaa-jar-path "~/Applications/org-mode/contrib/scripts/ditaa.jar")

(eval-after-load 'org-latex
  '(add-to-list 'org-export-latex-classes
                '("mla" "\\documentclass{mla-it}
\\usepackage{times}
\\surname{Dalton}"
                  ("\\section{%s}" . "\\section*{%s}")
                  ("\\subsection{%s}" . "\\subsection*{%s}")
                  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                  ("\\paragraph{%s}" . "\\paragraph*{%s}")
                  ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;;;; Python

(add-hook 'python-mode-hook '(lambda () (eldoc-mode 1)) t)
(add-hook 'python-mode-hook 'whitespace-mode)

(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;;;; Rcirc

(eval-after-load 'rcirc
  '(progn
     ;; (load "rcirc-dbus")
     ;; (require 'rcirc-ensure)
     ))

(add-hook 'rcirc-mode-hook
          '(lambda ()
             (rcirc-omit-mode)
             (setq word-wrap t)
             (push '(continuation) fringe-indicator-alist)
             (variable-pitch-mode t)
             (set (make-local-variable 'scroll-conservatively)
                  8192)))

(setq rcirc-unambiguous-complete t)

;;;; Session Management

(add-to-list 'desktop-globals-to-save 'whitespace-line-column)
(add-to-list 'desktop-globals-to-save 'whitespace-style)

;;;; Shell

(add-hook 'shell-mode-hook
          '(lambda () (ansi-color-for-comint-mode-on)) t)

;;; Enable autocompletion after sudo
(defalias 'pcomplete/sudo 'pcomplete/xargs)

;;;; Text

(dolist (hook '(text-mode-hook markdown-mode-hook))
  (add-hook hook
            (lambda ()
              (visual-line-mode t))))

(require 'chop)

;;;; Top

(autoload 'top "top-mode" "Runs 'top' in an emacs buffer." t)

;;;; Window Management

(defalias 'list-buffers 'ibuffer-other-window)

;;;; Misc

(defalias 'yes-or-no-p 'y-or-n-p)

(autoload 'describe-unbound-keys "unbound"
  "Display a list of unbound keystrokes of complexity no greater than MAX.")

(require 'autopair)
;; (autopair-global-mode)

(provide 'modes)
