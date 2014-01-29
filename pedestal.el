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

(defcustom pedestal-cljs-nrepl-buffer "*nrepl*"
  "CLJS browser REPL buffer."
  :type 'string
  :group 'pedestal)

(defcustom pedestal-clj-nrepl-buffer "*nrepl*<2>"
  "CLJ server REPL buffer."
  :type 'string
  :group 'pedestal)

(defun pedestal-reload ()
  "When in the render tooling, reload the app, allowing
render-configuration changes to get picked up since ClojureScript
does not support vars.

The render configuration needs to have been previously set using:

  M-x set-variable pedestal-render-config <ENTER> \"(your.app.rendering.render-config)\"
"
  (interactive)
  (with-current-buffer pedestal-cljs-nrepl-buffer
    (nrepl-interactive-eval (format "(io.pedestal.app-tools.rendering-view.client.main %s true)" pedestal-render-config))))

(defcustom pedestal-templates-var nil
  "Var representing macro that generates templates.  This should be an s-exp like:  (client.html-templates/client-templates)"
  :type 'sexp
  :group 'pedestal)

(defcustom pedestal-main nil
  "s-exp for creating and starting your pedestal app.  For example:  (client.start/main)"
  :type 'sexp
  :group 'pedestal)

(defun pedestal-reload-templates ()
  "Allow for interactive template modification.

Pedestal utilizes Enlive on the server side and uses a macro to
generate the CLJS side templates. However, it difficult to get
the macro definition reloaded from a bREPL. To work around this,
we evaluate the macro again in the server side REPL, then
redefine the template var in the bREPL with the new expansion.

NOTE: Your current bREPL namespace must be the rendering
namespace where templates are reference, by default this is
something like:

  client.rendering
"
  (interactive)
  (with-current-buffer pedestal-clj-nrepl-buffer
    (nrepl-macroexpand-expr 'macroexpand pedestal-templates-var))
  (let ((expansion (with-current-buffer nrepl-macroexpansion-buffer
                     (buffer-substring-no-properties (point-min) (point-max)))))
    (with-current-buffer pedestal-cljs-nrepl-buffer
      (nrepl-interactive-eval (format "(def templates %s) %s" expansion pedestal-main))))
  (nrepl--close-connection-buffer nrepl-macroexpansion-buffer))
