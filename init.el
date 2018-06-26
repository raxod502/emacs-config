;; -*- lexical-binding: t -*-
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;;(package-initialize)
(setq load-prefer-newer t)

(if (member "-M" command-line-args)
    (progn
      ;; Abort and load minimal init instead
      ;; This is useful if we are running in a resource constrained
      ;; environment or have broken the main config
      (delete "-M" command-line-args)
      (load (locate-user-emacs-file "init-minimal")))

  (require 'cl-lib)

  (defmacro load-module! (sym &optional path noerror)
    (cl-assert (symbolp (cadr sym)) t)
    (let ((path (expand-file-name (concat (symbol-name (cadr sym)) ".el")
                                  (locate-user-emacs-file "modules"))))
      (if (file-exists-p path)
          `(unless (featurep ,sym)
             (load ,(file-name-sans-extension path)
                   ,noerror
                   (not (eq debug-on-error 'startup))))
        (unless noerror
          (error "Could not load file '%s' from '%s'" file path)))))

  (cl-letf* (;; In fact, never GC during initialization to save time.
             (gc-cons-threshold 402653184)
             (gc-cons-percentage 0.6)
             (file-name-handler-alist nil)
             (load-source-file-function nil)

             ;; Also override load to hide  superfluous loading messages
             (old-load (symbol-function #'load))
             ((symbol-function #'load)
              (lambda (file &optional noerror _nomessage &rest args)
                (apply old-load
                       file
                       noerror
                       (not (eq debug-on-error 'startup))
                       args))))

    (message "[                ]")

    (defvar my/slow-device nil)

    (menu-bar-mode -1)
    (when (fboundp 'scroll-bar-mode)
      (scroll-bar-mode -1))
    (when (fboundp 'tool-bar-mode)
      (tool-bar-mode -1))

    (when (member "-F" command-line-args)
      (delete "-F" command-line-args)
      (setq my/slow-device t))

    (eval-and-compile
      (add-to-list 'load-path (locate-user-emacs-file "modules/")))

    ;; suppress the GNU spam
    (fset 'display-startup-echo-area-message #'ignore)
    (add-hook 'emacs-startup-hook (lambda () (message "")))

    (setq custom-file (locate-user-emacs-file "custom.el"))
    (condition-case nil
        (load custom-file)
      (error (with-temp-file custom-file)))

    (load-module! 'config-setq)
    (message "[=              ] package")
    (load-module! 'config-package)
    (message "[==             ] desktop")
    (load-module! 'config-desktop)
    (message "[===            ] safety")
    (load-module! 'config-safety)
    (message "[====           ] evil")
    (load-module! 'config-evil)
    (message "[=====          ] ui")
    (load-module! 'config-ui)
    (message "[======         ] whitespace")
    (load-module! 'config-whitespace)
    (message "[=======        ] paste")
    (load-module! 'config-paste)
    (message "[========       ] company")
    (load-module! 'config-company)
    (message "[=========      ] vcs")
    (load-module! 'config-vcs)
    (message "[==========     ] ivy")
    (load-module! 'config-ivy)
    (message "[===========    ] helm")
    (load-module! 'config-helm)
    (message "[=============  ] intel")
    (load-module! 'config-intel)
    (message "[============== ] modes")
    (load-module! 'config-modes)
    (message "[===============] solarized")
    (load-module! 'config-solarized)
    (message "[===============] done")))
