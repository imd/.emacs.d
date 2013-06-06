(require 'rcirc)


(defun rcirc-ensure-channel-name (channel)
  "Return CHANNEL if it is a valid channel name.
Eventually add a # in front of it, if that turns it into a valid channel name."
  (if (rcirc-channel-p channel)
      channel
    (concat "#" channel)))

(defun-rcirc-command join (channel)
  "Join CHANNEL."
  (interactive "sJoin channel: ")
  (let ((buffer (rcirc-get-buffer-create process
                                         (car (split-string channel)))))
    (rcirc-send-string process (concat "JOIN "
                                       (rcirc-ensure-channel-name channel)))
    (when (not (eq (selected-window) (minibuffer-window)))
      (switch-to-buffer buffer))))

(provide 'rcirc-ensure)
