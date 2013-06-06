;;;; General editing

(defun custom-goto-match-beginning ()
  "Use with isearch hook to end search at first char of match."
  (when isearch-forward (goto-char isearch-other-end)))

(defun find-alternative-file-with-sudo ()
  "Open current buffer as root!"
  (interactive)
  (when buffer-file-name
    (find-alternate-file
     (concat "/sudo:root@localhost:"
             buffer-file-name))))

(defun kill-syntax-forward ()
  "Kill characters with syntax at point."
  (interactive)
  (kill-region (point)
               (progn (skip-syntax-forward (string (char-syntax (char-after))))
                      (point))))

(defun kill-syntax-backward ()
  "Kill characters with syntax at point."
  (interactive)
  (kill-region (point)
               (progn (skip-syntax-backward (string (char-syntax
                                                     (char-before))))
                      (point))))

(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
         (newname (concat dir "/" name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (progn
        (copy-file filename newname 1)
        (delete-file filename)
        (set-visited-file-name newname)
        (set-buffer-modified-p nil)
        t))))

(defun move-line (&optional n)
  "Move current line N (1) lines up/down leaving point in place."
  (interactive "p")
  (when (null n)
    (setq n 1))
  (let ((col (current-column)))
    (beginning-of-line)
    (next-line 1)
    (transpose-lines n)
    (previous-line 1)
    (forward-char col)))

(defun move-line-down (n)
  "Moves current line N (1) lines down leaving point in place."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(defun move-line-up (n)
  "Moves current line N (1) lines up leaving point in place."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

;;; From http://stackoverflow.com/questions/2588277/how-can-i-swap-or-replace-multiple-strings-in-code-at-the-same-time
;; (loop for i from 0
;;       for str = (read-from-minibuffer "Replace: ")
;;       then (read-from-minibuffer (if (evenp i) "Replace: " "With: "))
;;       until (equal str "")
;;       collect str)
(defun parallel-replace (plist &optional start end)
  "Replace strings in parallel.  Called interactively, tokenizes
input string on whitespace into a plist."
  (interactive
   `(,(loop with input = (read-from-minibuffer "Replace: ")
            with limit = (length input)
            for (item . index) = (read-from-string input 0)
            then (read-from-string input index)
            collect (prin1-to-string item t) until (<= limit index))
     ,@(if (use-region-p) `(,(region-beginning) ,(region-end)))))
  (let* ((alist (loop for (key val . tail) on plist by #'cddr
                      collect (cons key val)))
         (matcher (regexp-opt (mapcar #'car alist) 'words)))
    (save-excursion
      (goto-char (or start (point)))
      (while (re-search-forward matcher (or end (point-max)) t)
        (replace-match (cdr (assoc-string (match-string 0) alist)))))))

(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun unfill-paragraph ()
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(dolist (command '(yank yank-pop))
  (eval `(defadvice ,command (after indent-region activate)
           (and (not current-prefix-arg)
                (member major-mode '(emacs-lisp-mode lisp-mode
                                                     clojure-mode    scheme-mode
                                                     haskell-mode    ruby-mode
                                                     rspec-mode      python-mode
                                                     c-mode          c++-mode
                                                     objc-mode       latex-mode
                                                     plain-tex-mode))
                (let ((mark-even-if-inactive transient-mark-mode))
                  (indent-region (region-beginning) (region-end) nil))))))


;;;; Information-gathering

(defun totd ()
  (interactive)
  (random t) ;; seed with time-of-day
  (with-output-to-temp-buffer "*Tip of the day*"
    (let* ((commands (loop for s being the symbols
                           when (commandp s) collect s))
           (command (nth (random (length commands)) commands)))
      (princ
       (describe-function command)))))

(defun word-count-buffer ()
  "Count the words in a buffer.
Gives a quick word count for the buffer in the message line.
This removes the need to use the shell command."
  (interactive)
  (word-count-region (point-min) (point-max) (buffer-name)))

(defun word-count-region (start end &optional description)
  "Count the words in a region.
This counts the number of words within a region including numbers, but
not punctuation. It has no special knowledge of TeX or LaTeX commands
so counts these as well. Uses forward-word as a guide to the next word."
  (interactive "r")             ; gets the region if not already given
  (let ((words 0))                ; local variable counts words-so-far
    (save-excursion               ; don't muck up the pointer and mark
      (goto-char start)     ; go to the beginning of the buffer/region
      (while (< (point) end) (setq words (1+ words)) (forward-word 1))
      (backward-word 1)        ; wally's fix for that one-word-out bug
      (if (> (point) end) (setq words (1- words))))
    (if (eq words 1)                   ; let's try to be user-friendly
        (message "There is only 1 word in %s" (or description "the region"))
      (message "There are %d words in %s" words
               (or description "the region")))))

(defun count-words-org-buffer ()
  (interactive)
  (org-export-as-html 3)
  (shell-command "links2 -dump paper3.html | wc -w"))

;;;; Macros

(defun start-or-end-macro (arg)
  "Toggle macro recording."
  (interactive "P")
  (if defining-kbd-macro
      (if arg
          (end-kbd-macro arg)
        (end-kbd-macro))
    (start-kbd-macro arg)))

;;;; Window management

(defadvice raise-frame (after make-it-work (&optional frame) activate)
  "Move Emacs to the current desktop, raise the window, and give it
focus.  Needs wmctrl on X; doesn't work on other platforms."
  (when (executable-find "wmctrl")
    (call-process
     "wmctrl" nil nil nil "-i" "-a"
     (frame-parameter (or frame (selected-frame)) 'outer-window-id))))

(defun rotate-windows ()
  "Rotate your windows"
  (interactive)
  (if (not (> (count-windows) 1))
      (message "You can't rotate a single window!")
    (setq i 1)
    (setq numWindows (count-windows))
    (while  (< i numWindows)
      (let* (
             (w1 (elt (window-list) i))
             (w2 (elt (window-list) (+ (% i numWindows) 1)))

             (b1 (window-buffer w1))
             (b2 (window-buffer w2))

             (s1 (window-start w1))
             (s2 (window-start w2))
             )
        (set-window-buffer w1  b2)
        (set-window-buffer w2 b1)
        (set-window-start w1 s2)
        (set-window-start w2 s1)
        (setq i (1+ i))))))

;;;; File management

(defun add-file-to-recent (filename)
  (when (executable-find "addtorecent.py")
    (interactive "File to add: ")
    (start-process "addtorecent.py" nil "addtorecent.py" filename
                   (concat "file://" buffer-file-name) "text/plain")))

(defun dired-xdg-open-file ()
  "Opens the current file in a Dired buffer."
  (interactive)
  (xdg-open-file (dired-get-file-for-visit))
  (add-file-to-recent (dired-get-file-for-visit)))

(defun imd-save-place-alist-to-file ()
  (let ((file (expand-file-name save-place-file)))
    (save-excursion
      (message "Saving places to %s..." file)
      (set-buffer (get-buffer-create " *Saved Places*"))
      (delete-region (point-min) (point-max))
      (when save-place-forget-unreadable-files
        (save-place-forget-unreadable-files))
      (let ((print-length nil)
            (print-level nil))
        (pp save-place-alist (current-buffer)))
      (let ((version-control
             (cond
              ((null save-place-version-control) nil)
              ((eq 'never save-place-version-control) 'never)
              ((eq 'nospecial save-place-version-control) version-control)
              (t
               t))))
        (condition-case nil
            ;; Don't use write-file; we don't want this buffer to visit it.
            (write-region (point-min) (point-max) file)
          (file-error (message "Can't write %s" file)))
        (kill-buffer (current-buffer))
        (message "Saving places to %s...done" file)))))

(defun local-add-file-to-recent ()
  (when (and buffer-file-name (executable-find "addtorecent.py"))
    (start-process "addtorecent.py" nil "addtorecent.py"
                   (concat "file://" buffer-file-name) "text/plain")))

(defun xdg-open-file (filename)
  "xdg-opens the specified file."
  (interactive "fFile to open: ")
  (let ((process-connection-type nil))
    (start-process "xdg-open" nil "xdg-open" filename)))

(defun .custom ()
  (interactive)
  (find-file "~/.emacs.d/lisp/custom.el"))

(defun funs ()
  (interactive)
  (find-file "~/.emacs.d/lisp/functions.el"))

(defun init ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun keys ()
  (interactive)
  (find-file "~/.emacs.d/lisp/keybindings.el"))

(defun misc ()
  (interactive)
  (find-file "~/.emacs.d/lisp/misc.el"))

(defun modes ()
  (interactive)
  (find-file "~/.emacs.d/lisp/modes.el"))

(defun journal ()
  (interactive)
  (find-file "~/Documents/journal.org"))

(defun gtd ()
  (interactive)
  (find-file "~/Documents/gtd.org"))

;;;; Gnus

(defun switch-to-gnus (&optional arg)
  "Switch to a Gnus related buffer.
    Candidates are buffers starting with
     *mail or *reply or *wide reply
     *Summary or
     *Group*

    Use a prefix argument to start Gnus if no candidate exists."
  (interactive "P")
  (let (candidate
        (alist '(("^\\*\\(mail\\|\\(wide \\)?reply\\)" t)
                 ("^\\*Group")
                 ("^\\*Summary")
                 ("^\\*Article"
                  nil
                  (lambda ()
                    (buffer-live-p gnus-article-current-summary))))))
    (catch 'none-found
      (dolist (item alist)
        (let (last
              (regexp (nth 0 item))
              (optional (nth 1 item))
              (test (nth 2 item)))
          (dolist (buf (buffer-list))
            (when (and (string-match regexp (buffer-name buf))
                       (> (buffer-size buf) 0))
              (setq last buf)))
          (cond ((and last (or (not test) (funcall test)))
                 (setq candidate last))
                (optional nil)
                (t (throw 'none-found t))))))
    (cond (candidate (switch-to-buffer candidate))
          (arg (gnus))
          (t (gnus)))))

;;;; HTML

(defun tidy-buffer ()
  "Run Tidy HTML parser on current buffer."
  (interactive)
  (if (get-buffer "tidy-errs") (kill-buffer "tidy-errs"))
  (shell-command-on-region (point-min) (point-max)
                           "tidy -f /tmp/tidy-errs -q -i -wrap 0 -c -utf8" t)
  (find-file-other-window "/tmp/tidy-errs")
  (other-window 1)
  (delete-file "/tmp/tidy-errs")
  (message "buffer tidy'ed"))

;;;; IRC

(defun rcirc-complete-nick ()
  "Complete nick from list of nicks in channel."
  (interactive)
  (if (eq last-command this-command)
      (setq rcirc-nick-completions
            (append (cdr rcirc-nick-completions)
                    (list (car rcirc-nick-completions))))
    (setq rcirc-nick-completion-start-offset
          (- (save-excursion
               (if (re-search-backward " " rcirc-prompt-end-marker t)
                   (1+ (point))
                 rcirc-prompt-end-marker))
             rcirc-prompt-end-marker))
    (setq rcirc-nick-completions
          (let ((completion-ignore-case t))
            (all-completions
             (buffer-substring
              (+ rcirc-prompt-end-marker
                 rcirc-nick-completion-start-offset)
              (point))
             (mapcar (lambda (x) (cons x nil))
                     (rcirc-channel-nicks (rcirc-buffer-process)
                                          rcirc-target))))))
  (if rcirc-unambiguous-complete
      (rcirc-unambiguous-complete-nick rcirc-nick-completions)
    (rcirc-cycle-complete-nick rcirc-nick-completions)))

(defun rcirc-cycle-complete-nick (completions)
  "Complete nick by cycling through possibilities."
  (let ((completion (car completions)))
    (when completion
      (rcirc-put-nick-channel (rcirc-buffer-process) completion rcirc-target)
      (rcirc-insert-completed-nick completion))))

(defun rcirc-unambiguous-complete-nick (completions)
  "Complete unambiguous portion of nick and prompt for more."
  (let ((unambiguous (car completions)))
    (mapc (lambda (nick)
            (setq unambiguous (rcirc-get-unambiguous nick unambiguous)))
          (cdr completions))
    (if (string= unambiguous (buffer-substring
                              (+ rcirc-prompt-end-marker
                                 rcirc-nick-completion-start-offset)
                              (point)))
        (message (mapconcat 'identity completions " "))
      (if unambiguous
          (rcirc-insert-completed-nick unambiguous
                                       (not (equal (length completions)
                                                   1)))))))

(defun rcirc-get-unambiguous (nick target)
  (if (> (length nick) (length target))
      (setq nick (substring nick 0 (length target))))
  (if (equalp nick (substring target 0 (length nick)))
      nick
    (rcirc-get-unambiguous (substring nick 0 (- (length nick) 1)) target)))

(defun rcirc-insert-completed-nick (nick &optional incomplete)
  (delete-region (+ rcirc-prompt-end-marker
                    rcirc-nick-completion-start-offset)
                 (point))
  (insert nick)
  (if (and (= (+ rcirc-prompt-end-marker
                 rcirc-nick-completion-start-offset)
              rcirc-prompt-end-marker)
           (not incomplete))
      (insert ": ")))

;;; Don't use *, and convert to lower case.
(defun rcirc-generate-log-path (process target)
  "Return a buffer name based on PROCESS and TARGET.
This is used for the initial name given to IRC buffers."
  (downcase
   (substring-no-properties
    (concat
     (when target (concat target "@"))
     (process-name process)
     "/"
     (format-time-string "%Y-%m-%d")))))


;;;; Lisp

;;; From Julian Fondren (ayrnieu)
;;; Print a sexp's values in rcirc
(defun slime-eval-print-sync (string)
  (insert (second (slime-eval `(swank:eval-and-grab-output ,string)))))

(defun slime-rcirc-eval-last-expression ()
  (interactive)
  (when (save-excursion (search-forward-regexp "." (line-end-position) t))
    (kill-line))
  (let ((expr (slime-last-expression)))
    (save-excursion
      (insert " → ")
      (slime-eval-print-sync expr))))

(provide 'functions)
