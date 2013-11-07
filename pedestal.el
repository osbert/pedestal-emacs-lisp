;; Define some helper functions to interact with Pedestal applications
;; through the ClojureScript REPL.  To use these functions:
;;
;;   $ git clone http://github.com/osbert/pedestal-emacs-lisp
;;
;; Edit your ~/.emacs.d/init.el to add pedestal-emacs-lisp to your
;; load path and then load the file.  For example:
;;
;;   (add-to-list 'load-path "~/pedestal-emacs-lisp")
;;   (load "pedestal.el")
;;
;; NOTE: You must also use nREPL/cider and have a ClojureScript
;; browser REPL connected for this to work.
;;
;; You can then setup custom keybinds, here are some suggested defaults:
;;
;;   (global-set-key (kbd "C-c M-p ]") 'pedestal-step-forward)
;;   (global-set-key (kbd "C-c M-p [") 'pedestal-step-back)
;;   (global-set-key (kbd "C-c M-p r") 'pedestal-reload)

(require 'nrepl)

(defun pedestal-step-forward (n)
  "When in the render tooling, step the current recording forward n steps."
  (interactive "p")
  (when (> n 0)
    (nrepl-interactive-eval "(swap! io.pedestal.app-tools.rendering-view.client/emitter io.pedestal.app-tools.rendering-view.client/step-forward)")
    (pedestal-step-forward (- n 1))))

(defun pedestal-step-back (n)
  "When in the render tooling, step the current recording backward n steps."
  (interactive "p")
  (when (> n 0)
    (nrepl-interactive-eval "(swap! io.pedestal.app-tools.rendering-view.client/emitter io.pedestal.app-tools.rendering-view.client/step-back)")
    (pedestal-step-back (- n 1))))

(defcustom pedestal-render-config nil
  "Render configuration to utilize with pedestal-reload."
  :type 'string
  :group 'pedestal)

(defun pedestal-reload ()
  "When in the render tooling, reload the app, allowing
render-configuration changes to get picked up since ClojureScript
does not support vars.

The render configuration needs to have been previously set using:

  M-x set-variable \"your.app.rendering.render-config\"
"
  (interactive)
  (nrepl-interactive-eval (format "(io.pedestal.app-tools.rendering-view.client.main %s true)" pedestal-render-config)))
