;;; g-cus-load.el --- automatically extracted custom dependencies
;;
;;; Code:

(put 'gskeleton 'custom-loads '(gskeleton))
(put 'ghealth 'custom-loads '(ghealth))
(put 'g-auth 'custom-loads '(g-auth))
(put 'gphoto 'custom-loads '(gphoto))
(put 'gtube 'custom-loads '(gtube))
(put 'gwis 'custom-loads '(gwis))
(put 'gweb 'custom-loads '(gweb))
(put 'gnotebook 'custom-loads '(gnotebook))
(put 'gcontacts 'custom-loads '(gcontacts))
(put 'gdocs 'custom-loads '(gdocs))
(put 'gfinance 'custom-loads '(gfinance))
(put 'applications 'custom-loads '(g))
(put 'gfeeds 'custom-loads '(gfeeds))
(put 'gcal 'custom-loads '(gcal))
(put 'gsheet 'custom-loads '(gsheet))
(put 'g 'custom-loads '(g-utils g-auth gblogger gcal gcontacts gdocs gfeeds gfinance ghealth gnotebook gphoto greader gsheet gskeleton gtube gweb))
(put 'gblogger 'custom-loads '(gblogger))
(put 'greader 'custom-loads '(greader))
;; These are for handling :version.  We need to have a minimum of
;; information so `customize-changed-options' could do its job.

;; For groups we set `custom-version', `group-documentation' and
;; `custom-tag' (which are shown in the customize buffer), so we
;; don't have to load the file containing the group.

;; `custom-versions-load-alist' is an alist that has as car a version
;; number and as elts the files that have variables or faces that
;; contain that version. These files should be loaded before showing
;; the customization buffer that `customize-changed-options'
;; generates.

;; This macro is used so we don't modify the information about
;; variables and groups if it's already set. (We don't know when
;; g-cus-load.el is going to be loaded and at that time some of the
;; files might be loaded and some others might not).
(defmacro custom-put-if-not (symbol propname value)
  `(unless (get ,symbol ,propname)
     (put ,symbol ,propname ,value)))


(defvar custom-versions-load-alist nil
 "For internal use by custom.")

(provide 'g-cus-load)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; g-cus-load.el ends here
