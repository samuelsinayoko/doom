;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybindings
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Define the functions
(defun sam/copy-buffer-file-name ()
  "Copy buffer file name to clipboard"
  (interactive)
  (kill-new buffer-file-name)
  (message "copied %s" buffer-file-name))
(defun sam/reload-configuration ()
  "Reload .emacs file"
  (interactive)
  (load-file emacs-init-file))
;; Open previous / next line
(defun sam/open-next-line (arg)
  "Move to the next line and then opens a line.
      See also `newline-and-indent'."
  (interactive "p")
  (end-of-line)
  (open-line arg)
  (next-line 1)
  (indent-according-to-mode))
(defun sam/open-previous-line (arg)
  "Open a new line before the current one.
       See also `newline-and-indent'."
  (interactive "p")
  (beginning-of-line)
  (open-line arg)
  (indent-according-to-mode))
(defun sam/backward-kill-word-or-kill-region (&optional arg)
  (interactive "p")
  (if (region-active-p)
      (copy-region-as-kill (region-beginning) (region-end))
    (backward-kill-word arg)))
(defun sam/transpose-comma (&optional N)
  "Transpose words around comma. Point needs to be in word before
  comma.
  Useful to transpose the arguments of a function
  definition when coding.
  TODO: allow for negative arguments
  "
  (interactive "p")
          (let (eol)
    (save-excursion
      (end-of-line)
      (setq eol (point)))
    (beginning-of-sexp)
    (if (re-search-forward "\\(\\w+\\), \\(\\w+\\)"  eol t 1)
	(replace-match "\\2, \\1")))
  (if (and N (> N 1))
      (transpose-comma (1- N))))

(defun sam/kill-help-buffer()
    "Kill buffer in other window"
    (interactive)
    ;;  (fset 'kill-help-buffer "\C-xoq")
    (save-excursion
      ;; Cycle window until we reach *Help* buffer
      (while (not (equal (buffer-name) "*Help*"))
        (select-window (next-window)))
      (View-quit)))
(defun copy-to-char (char)
  "Copy region between point and char"
  (interactive "cCopy to character:")
  (if (char-table-p translation-table-for-input)
      (setq char (or (aref translation-table-for-input char) char)))
  (save-excursion
    (kill-ring-save (point)
                    (progn
                      (search-forward (char-to-string char))
                      (point)))))
(defalias 'cc 'copy-to-char)

                                        ;(global-set-key (kbd "\C-;") 'ipython-filter-private-attributes)
;; From mastering emacs blog
(defun sam/push-mark-no-activate () ;; use C-SPC C-SPC instead
  "Pushes `point' to `mark-ring' and does not activate the region
Equivalent to \\[set-mark-command] when \\[transient-mark-mode] is disabled"
  (interactive)
  (push-mark (point) t nil)
  (message "Pushed mark to ring"))

(defun sam/jump-to-mark ()
  "Jumps to the local mark, respecting the `mark-ring' order.
This is the same as using \\[set-mark-command] with the prefix argument."
  (interactive)
  (set-mark-command 1))

(define-minor-mode sam-keys-mode
  "Sam's keybindings, hopefully more convenient than emacs defaults. It is a global mode so it overwrides all other minor modes' bindings. "
  :lighter " Sam"
  :global t
  :keymap (let ((map (make-sparse-keymap)))
    ;; Make cursor movement keys under right hand's home-row.
    (define-key map "\M-j" 'backward-char)
    (define-key map "\M-l" 'forward-char)
    (define-key map "\M-i" 'previous-line)
    (define-key map "\M-k" 'next-line)
    (define-key map "\M-h" 'move-beginning-of-line)
    (define-key map (kbd "M-;") 'move-end-of-line)
    ;; Movements in terms of words and sentences
    (define-key map "\M-L" 'forward-word)
    (define-key map "\M-J" 'backward-word)
    (define-key map "\M-H" 'backward-sentence)
    (define-key map "\M-:" 'forward-sentence)
    (define-key map "\M-I" 'scroll-down)
    (define-key map "\M-K" 'scroll-up)
    (define-key map "\M-a" 'set-mark-command)
    (define-key map (kbd "C-M-i") 'back-to-indentation)
    ;; Buffer
    (define-key map "\M-f" 'ido-switch-buffer)
    (define-key map (kbd "M-c") 'ido-kill-buffer)
    (define-key map (kbd "C-M-c") 'sam/kill-help-buffer)
    (define-key map (kbd "C-x C-b") 'ibuffer)

    ;; Delete
    (define-key map (kbd "M-'") 'zap-up-to-char) ;; stop just before char
    (define-key map (kbd "M-w") 'sam/backward-kill-word-or-kill-region) ;; so we can
    ;; Windows
    (define-key map "\M-0" 'delete-window)
    (define-key map "\M-1" 'delete-other-windows)
    (define-key map "\M-2" 'split-window-vertically)
    (define-key map "\M-3" 'split-window-horizontally)
    (define-key map "\M-o" 'other-window)
    (define-key map "\C-\M-u" 'winner-undo) ;; requires winner-mode
    (define-key map "\M-}"  'enlarge-window)
    (define-key map (kbd "C-M-{")  'shrink-window)
    (define-key map (kbd "C-M-]") 'enlarge-window-horizontally)
    (define-key map (kbd "C-M-[") 'shrink-window-horizontally)
    (define-key map "\M-=" 'balance-windows)
    ;; Registers
    (define-key map (kbd "M-SPC") 'sam/push-mark-no-activate)
    (define-key map (kbd "C-SPC") 'just-one-space)
    (define-key map (kbd "M-<return>") 'sam/jump-to-mark)
    ;; ;; Comments
    ;; (define-key map "\C-cc"  'comment-region)
    ;; (define-key map "\C-cu"  'uncomment-region)
    ;; Use `C-x C-; and comment or uncomment region

    ;; ;; Misc
    ;;(define-key map "\M-g" 'goto-line)
    (define-key map (kbd "C-<tab>") 'indent-relative) ; see also tab-to-tab-stops
    (define-key map (kbd "M-r") 'undo) ;; undo easily
    (define-key map "\M-m" 'dabbrev-expand) ;; dynamic expansions
    (define-key map (kbd "C-c C-;") 'iedit-mode)
    ;;   replace regexps interactively
    ;;(define-key map "\C-c\C-r" 'query-replace-regexp)
    ;; My functions
    (define-key map (kbd "<f5>") 'sam/reload-configuration)
    (define-key map (kbd "C-,") 'sam/transpose-comma)
    (define-key map (kbd "C-c ;") 'sam/copy-buffer-file-name)
    ;(define-key map (kbd "C-o") 'sam/open-previous-line)
    ;(define-key map (kbd "C-M-o") 'sam/open-next-line)
    ;; Magit (Version Control for Git)
    (define-key map (kbd "C-c m") 'magit-status)
    map))

(sam-keys-mode t)

;; Mac settings
(when IS-MAC
  (setq mac-command-key-is-meta t)
  (setq mac-command-modifier 'meta)
  (setq browse-url-browser-function (quote browse-url-default-macosx-browser)))
  ;; (setq exec-path (cons "/usr/local/bin" exec-path))
  ;; (setq exec-path (cons "/usr/texbin" exec-path))
  ;; (setq exec-path (cons "/usr/local/texlive/2014/bin/x86_64-darwin//pdflatex" exec-path))
  ;; (setq exec-path (cons (expand-file-name "~/bin") exec-path)))

;; ido
;; ;; ido: help with buffers / opening files
;; (require 'ido)
;; (setq ido-everywhere t)
;; (ido-mode t)

;; (setq enable-recursive-minibuffers nil)
;; (setq ido-enable-flex-matching nil)
;; (setq ido-create-new-buffer 'always)
;; (setq ido-use-virtual-buffers t)
;; (setq ido-use-filename-at-point (quote guess))
;; (setq ido-use-url-at-point t)
;; (put 'ido-exit-minibuffer 'disabled nil)

;; ;; Overwride sam-key-mode's C-SPC
;; (add-hook 'minibuffer-inactive-mode-hook
;;     (lambda ()
;;       (let ((oldmap (cdr (assoc 'sam-keys-mode minor-mode-map-alist)))
;;             (newmap (make-sparse-keymap)))
;;         (set-keymap-parent newmap oldmap)
;;         (define-key newmap (kbd "C-SPC") 'ido-restrict-to-matches)
;;         (make-local-variable 'minor-mode-overriding-map-alist)
;;         (push `(sam-keys-mode . ,newmap) minor-mode-overriding-map-alist))))

;; ;; recent files (from Mickey at
;;   ;; http://www.masteringemacs.org/articles/2011/01/27/find-files-faster-recent-files-package/
;; (use-package recentf
;;   :config
;;   ;;(require 'recentf)
;;   ;;; get rid of `find-file-read-only' and replace it with something
;;   ;;; more useful.
;;   (global-set-key (kbd "C-x C-r") 'ido-recentf-open)
;;   ;;; enable recent files mode.
;;   (recentf-mode t)
;;   ;;; 50 files ought to be enough.
;;   (setq recentf-max-saved-items 200)
;;   (defun ido-recentf-open ()
;;     "Use `ido-completing-read' to \\[find-file] a recent file"
;;     (interactive)
;;     (if (find-file (ido-completing-read "Find recent file: " recentf-list))
;;         (message "Opening file...")
;;       (message "Aborting"))))

;; ido everything
;; (defvar ido-enable-replace-completing-read t
;;   "If t, use ido-completing-read instead of completing-read if possible.

;; Set it to nil using let in around-advice for functions where the
;; original completing-read is required.  For example, if a function
;; foo absolutely must use the original completing-read, define some
;; advice like this:

;;(defadvice foo (around original-completing-read-only activate)
;;  (let (ido-enable-replace-completing-read) ad-do-it))")

;; ;; Replace completing-read wherever possible, unless directed otherwise
;; (defadvice completing-read
;;   (around use-ido-when-possible activate)
;;   (if (or (not ido-enable-replace-completing-read) ; Manual override disable ido
;;           (boundp 'ido-cur-list)) ; Avoid infinite loop from ido calling this
;;       ad-do-it
;;     (let ((allcomp (all-completions "" collection predicate)))
;;       (if allcomp
;;           (setq ad-return-value
;;                 (ido-completing-read prompt
;;                                   allcomp
;;                                   nil require-match initial-input hist def))
;;         ad-do-it))))

;; smex
;;(load-file "~/.emacs.d/site-lisp/smex.el") ;; use elpa instead
;;(smex-initialize)
;; (setq smex-save-file "~/.emacs.d/.smex-items")
;; (global-set-key (kbd "M-x") 'smex)
;; (global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
;; idomenu
;;(load-file "~/.emacs.d/site-lisp/idomenu.el")
;;(autoload 'idomenu "idomenu" nil t)
;;(global-set-key (kbd "M-/") 'idomenu)

;; ;; Iedit: to replace things easily locally
;; (load-file "~/.emacs.d/site-lisp/iedit.el")
;; (require 'iedit)
;; (define-key global-map (kbd "C-;") 'iedit-mode)
;; (define-key isearch-mode-map (kbd "C-;") 'iedit-mode)

(defun python-add-breakpoint ()
  "Add a break point"
  (interactive)
  (let ((debug-cmd "import ipdb; ipdb.set_trace()"))
  ;;(let ((debug-cmd "from IPython.core.debugger import Tracer; Tracer()()"))
    (save-excursion
      ;; Insert line above and indent
      ;; deal with special case of being at top of module
      (if (= (forward-line -1) 0)
          (progn
            (end-of-line)
            (newline-and-indent))
        (beginning-of-line)
        (newline-and-indent)
        (forward-line -1))
      (message (format "%s:%s" buffer-file-name (line-number-at-pos)))
      (insert debug-cmd))
    (highlight-lines-matching-regexp (concat "^[ ]*" debug-cmd) "hi-aquamarine")))


; python virtual envs
 (use-package pet
   :config
   (add-hook 'python-base-mode-hook 'pet-mode -10))
(use-package python
  :config
  (define-key python-mode-map (kbd "C-c C-b") 'python-add-breakpoint)
)


(setq +python-ipython-repl-args '("-i" "--simple-prompt" "--no-color-info"))
(setq +python-jupyter-repl-args '("--simple-prompt"))
(context-menu-mode)

(defun activate-compilation-mode ()
  (s)
  (compilation-mode 1)
)
;; always run compile interactively
;; see https://www.masteringemacs.org/article/compiling-running-scripts-emacs
(defadvice compilation-start (before ad-compile-smart activate)
  "Advises `compile' so it sets the argument COMINT to t."
  (ad-set-arg 1 t))

(defun revert-compile-buffer-to-compilation-mode (buffer string)
  "Revert compilation buffer to compilation mode: when running interactively it normally stays in comint mode which is annoying"
  (when (and
         (string-match "compilation" (buffer-name buffer))
         (string-match "finished" string))
      (compilation-mode 1))
)

(add-hook 'compilation-finish-functions 'revert-compile-buffer-to-compilation-mode)

(defadvice compile (after ad-compile-smart-reset-mode activate)
  "reset mode to compilation mode"
  (save-excursion
    (switch-to-buffer "*compil")
    )(activate-compilation-mode)
)


;; sweet, in M-x shell or M-x eshell we'll have links to errors
;; like in *compile* buffer, *very* neat :)
;; just do M-g p / n to go to previous / next errors for example
;; with flake8
;; commenting out for now as it breaks workflow with ipdb, moves cursor to first error instead
;; of (pdb) prompt
;;(add-hook 'shell-mode-hook 'compilation-shell-minor-mode)
;; consider I have bound "compile" to M-g c, and "recompile" to M-g r. It totally simplifies everything!



;; ;; debugging with dape
;; (use-package dape
;;   ;; By default dape shares the same keybinding prefix as `gud'
;;   ;; If you do not want to use any prefix, set it to nil.
;;   ;; :preface
;;   ;; (setq dape-key-prefix "\C-x\C-a")
;;   ;;
;;   ;; May also need to set/change gud (gdb-mi) key prefix
;;   ;; (setq gud-key-prefix "\C-x\C-a")

;;   :hook
;;   ;; Save breakpoints on quit
;;   ;; ((kill-emacs . dape-breakpoint-save)
;;   ;; Load breakpoints on startup
;;   ;;  (after-init . dape-breakpoint-load))

;;   :init
;;   ;; To use window configuration like gud (gdb-mi)
;;   ;; (setq dape-buffer-window-arrangement 'gud)

;;   :config
;;   ;; Info buffers to the right
;;   ;; (setq dape-buffer-window-arrangement 'right)

;;   ;; To not display info and/or buffers on startup
;;   ;; (remove-hook 'dape-on-start-hooks 'dape-info)
;;   ;; (remove-hook 'dape-on-start-hooks 'dape-repl)

;;   ;; To display info and/or repl buffers on stopped
;;   ;; (add-hook 'dape-on-stopped-hooks 'dape-info)
;;   ;; (add-hook 'dape-on-stopped-hooks 'dape-repl)

;;   ;; Kill compile buffer on build success
;;   ;; (add-hook 'dape-compile-compile-hooks 'kill-buffer)

;;   ;; Save buffers on startup, useful for interpreted languages
;;   ;; (add-hook 'dape-on-start-hooks (lambda () (save-some-buffers t t)))

;;   ;; Projectile users
;;   ;; (setq dape-cwd-fn 'projectile-project-root)
;;   )

(require 'dape)
(add-to-list 'dape-configs
    `(debugpy
      modes (python-ts-mode python-mode)
      command "python3"
      command-args ("-m" "debugpy.adapter")
      :type "executable"
      :request "launch"
      :cwd dape-cwd-fn
      :program dape-find-file-buffer-default))

;; (add-to-list 'dape-configs
;; `(debugpy-attach
;;   modes ()
;;   host "localhost"
;;   port ,(lambda () (read-number "Port: "))
;;   :type "debugpy"
;;   :request "attach"))
(defun foo ()
  (message "starting foo")
)

;;(remove-hook 'comint-exec-hook 'foo)

(defun sam/restart-shell-and-send-buffer ()
  (interactive)
  (save-excursion
    ;; make sure sure ipython shell is running
    
    (+python/open-ipython-repl)
    (python-shell-switch-to-shell)
    ;; clear the buffer
    (python-shell-with-shell-buffer
      (comint-clear-buffer)
      ;; restart buffer (similar to compilation mode)
      ;; but reason for doing "compilation" via run-python
      ;; is we've got auto completion and other nicities
      (python-shell-restart nil)
      ;; compilation shell minor mode seems to leave
      ;; mark away from the (i)pdb prompt for
      ;; some weird reason so disabling it
      ;;
      ;;compilation-shell-minor-mode nil
      (message "current buffer = %s" (buffer-name (current-buffer)) )
      (compilation-shell-minor-mode -1)
      (message "compilation-shell-minor-mode = %s" compilation-shell-minor-mode)))

  ;; make sure the shell is ready, without the sleep the macros needed
  ;; aren't fully loaded in the shell
  (sleep-for 1)
  (python-shell-send-buffer t)
  ;; ;; doesn't work
  ;; (python-shell-with-shell-buffer
  ;;   ;; re-enable compilation-shell-minor mode once we've returned from executing
  ;;   ;; the code and exited debug session
  ;;   (compilation-shell-minor-mode 1)
  ;;   (end-of-buffer)
  ;;  )
)

(setq python-shell-completion-native-enable nil)



;; virtualenvs in eshell
(eval-and-compile
  (defun venv--gen-fun (command)
    `(defun ,(intern (format "pcomplete/eshell-mode/%s" command)) ()
       (pcomplete-here* (venv-get-candidates)))))

(defmacro venv--make-pcompletions (commands)
  `(progn ,@(-map #'venv--gen-fun commands)))

(defun venv-initialize-eshell ()
  "Configure eshell for use with virtualenvwrapper.el."
  ;; make emacs and eshell share an environment
  (setq eshell-modify-global-environment t)
  ;; set eshell path
  (setq eshell-path-env (getenv "PATH"))
  ;; alias functions
  (defun eshell/workon (arg) (pyvenv-workon arg))
  (defun eshell/activate (arg) (pyvenv-activate arg))
  (defun eshell/deactivate () (pyvenv-deactivate))
  ;;(defun eshell/rmvirtualenv (&rest args) (apply #'venv-rmvirtualenv args))
  ;;(defun eshell/mkvirtualenv (&rest args) (apply #'venv-mkvirtualenv args))
  ;;(defun eshell/cpvirtualenv (&rest args) (apply #'venv-cpvirtualenv args))
  ;;(defun eshell/cdvirtualenv (&optional arg) (venv-cdvirtualenv arg))
  ;;(defun eshell/lsvirtualenv () (venv-list-virtualenvs))
  (defun eshell/allvirtualenv (&rest command)
    (venv-allvirtualenv-shell-command
     (s-join " " (eshell-stringify-list command))))
  ;; make completions work
  (venv--make-pcompletions ("workon" "rmvirtualenv"
                            "cdvirtualenv" "cpvirtualenv"))
  (message "Eshell virtualenv support initialized."))


;; based on +eshell-default-prompt-fn
(defun sam/eshell-default-prompt-fn ()
  "Generate the prompt string for eshell. Use for `eshell-prompt-function'."
  (require 'shrink-path)
  (concat (if (bobp) "" "\n")
          (if pyvenv-virtual-env-name (concat "(" pyvenv-virtual-env-name ") ") "")
          (let ((pwd (eshell/pwd)))
            (propertize (if (equal pwd "~")
                            pwd
                          (abbreviate-file-name (shrink-path-file pwd)))
                        'face '+eshell-prompt-pwd))
          (propertize (+eshell--current-git-branch)
                      'face '+eshell-prompt-git-branch)
          (propertize " λ" 'face (if (zerop eshell-last-command-status) 'success 'error))
          " "))


(setq eshell-prompt-function 'sam/eshell-default-prompt-fn)
    ;; (lambda ()
    ;;   (concat (if pyvenv-virtual-env-name (concat "(" pyvenv-virtual-env-name ") ") "")
    ;;           (+eshell-default-prompt-fn)
    ;;           (abbreviate-file-name (eshell/pwd))
    ;;           (if (= (user-uid) 0) " # " " $ "))))
(add-hook 'eshell-mode-hook 'venv-initialize-eshell)


;; (add-to-list 'display-buffer-alist
;;      '("\\*Python\\*" display-buffer-reuse-window
;;        ;; change to `t' to not reuse same window
;;        (inhibit-same-window . nil)
;;        (or
;;         (mode python-mode)
;;         (mode inferior-python-mode))))

(add-to-list 'display-buffer-alist
'((or (derived-mode . python-mode) (derived-mode . inferior-python-mode))
  (display-buffer-reuse-window display-buffer-reuse-mode-window)
  (inhibit-same-window . nil)))


(add-to-list 'display-buffer-alist
'(("//*temp//*"
  (display-buffer-reuse-window display-buffer-reuse-mode-window)
  (inhibit-same-window . nil))))

(defun sam/fix-python-window-management ()
  (defun view-buffer-other-window (buffer &optional _not-return exit-action)
    (sam/view-buffer-other-window buffer _not-return exit-action))
  )


(defun sam/view-buffer-other-window (buffer &optional _not-return exit-action)
  "View BUFFER in View mode in another window.
Emacs commands editing the buffer contents are not available;
instead, a special set of commands (mostly letters and
punctuation) are defined for moving around in the buffer.
Space scrolls forward, Delete scrolls backward.
For a list of all View commands, type H or h while viewing.

This command runs the normal hook `view-mode-hook'.

Optional argument NOT-RETURN is ignored.

Optional argument EXIT-ACTION is either nil or a function with buffer as
argument.  This function is called when finished viewing buffer.  Use
this argument instead of explicitly setting `view-exit-action'.

This function does not enable View mode if the buffer's major mode
has a `special' mode-class, because such modes usually have their
own View-like bindings."
  (interactive "bIn other window view buffer:\nP")
  ;; changing default implementation
  (let ((pop-up-windows nil))
    (pop-to-buffer buffer nil))
  (if (eq (get major-mode 'mode-class) 'special)
      (message "Not using View mode because the major mode is special")
    (view-mode-enter nil exit-action)))

(add-hook 'python-mode-hook 'sam/fix-python-window-management)


;;;; Aliases
(defalias 'eb 'eval-buffer)
(defalias 'er 'eval-region)
(defalias 'ee 'eval-expression)
(defalias 'lf 'load-file)
(defalias 'sh 'eshell)
;;(defalias '.e 'visit-dot-emacs)
;;(defalias '.g 'visit-dot-gnus)
(defalias 'rb 'revert-buffer)
(defalias 'tf 'transpose-frame)
(defalias 'ffv 'flip-frame)  ;; flip frame vertically
(defalias 'ffh 'flop-frame)  ;; flip frame horizontally
;; run "restart-shell-and-send-buffer" commadn in emacs
(defalias 'rssb 'sam/restart-shell-and-send-buffer)

(add-hook 'window-setup-hook #'toggle-frame-maximized)

;; set limit for asking to open file to 5GB
(setq large-file-warning-threshold 5000000000)

;; popups
(use-package popper
  :ensure t ; or :straight t
  :bind (("M-`"   . popper-toggle)
         ("M-¬"   . popper-cycle)
         ("C-M-'" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "Python\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  ;; Match eshell, shell, term and/or vterm buffers
  (setq popper-reference-buffers
        (append popper-reference-buffers
                '("^\\*eshell.*\\*$" eshell-mode ;eshell as a popup
                  "^\\*shell.*\\*$"  shell-mode  ;shell as a popup
                  "^\\*term.*\\*$"   term-mode   ;term as a popup
                  "^\\*vterm.*\\*$"  vterm-mode  ;vterm as a popup
                  )))
  (popper-mode +1)
  (popper-echo-mode +1))

;; dired
(use-package dired
  :hook (dired-mode . dired-hide-details-mode)
  )
;; git info
(use-package dired-git-info
  :ensure t
  :bind (:map dired-mode-map
              (")" . dired-git-info-mode)))

;; make sure we can select options from mouse in vertico

(use-package vertico
  :hook (vertico-mode . vertico-mouse-mode)
  :init (bind-key "M-<mouse-3>" #'(lambda () (interactive) (vertico-mouse--click "TAB"))))

;; enable eyebrowse workspaces
(use-package eyebrowse
  :ensure t
  :init (eyebrowse-mode t))
