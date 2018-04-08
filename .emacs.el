(setq inhibit-startup-screen t)
(blink-cursor-mode 0)

(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(if window-system
    (set-frame-font "DjvsmHW+VL-12:spacing=0")
)
  (setq default-frame-alist
      (append (list
               '(foreground-color . "white")
               '(background-color . "black")
               '(cursor-type . box))
               default-frame-alist))
  (setq-default line-spacing -1)

(setq hilit-mode-enable-list '(lilfes-mode)
      hilit-background-mode 'dark
      hilit-inhibit-hooks nil
      hilit-inhibit-rebinding nil)

(add-to-list 'load-path "~/.emacs.d/site-lisp/yatex")
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq tex-command "luajitlatex -synctex=1")
(setq bibtex-command "pbibtex")
(setq makeindex-command "mendex")
(setq dvi2-command "zathura")
;(setq dvi2-command "sumatra")
(setq YaTeX-use-LaTeX2e t)
(setq YaTeX-use-AMS-LaTeX t)
(setq YaTeX-use-font-lock t)
(setq YaTeX-kanji-code nil)
(setq YaTeX-inhibit-prefix-letter t)
(setq YaTeX-default-pop-window-height 6)
(setq YaTeX-dvipdf-command "dvipdfmx")

(add-hook 'yatex-mode-hook '(lambda () (auto-fill-mode nil) (setq fill-column 90)))
(setq YaTeX-dvi2-command-ext-alist
      '(("TeXworks\\|texworks\\|texstudio\\|mupdf\\|SumatraPDF\\|Preview\\|Skim\\|TeXShop\\|evince\\|okular\\|zathura\\|qpdfview\\|Firefox\\|firefox\\|chrome\\|chromium\\|Adobe\\|Acrobat\\|AcroRd32\\|acroread\\|pdfopen\\|xdg-open\\|open\\|start\\|sumatra" . ".pdf")))

(setq YaTeX-latex-message-code 'utf-8
      YaTeX-no-begend-shortcut t 
      )

(require 'font-lock)
(setq font-lock-maximum-decoration t)
(setq font-lock-verbose nil)
(global-font-lock-mode t)
(setq YaTeX-use-font-lock t) 


(line-number-mode 1)
(column-number-mode 1)
(delete-selection-mode 1)

(setq auto-mode-alist 
      (append '(
                ("\\.f95$"  . fortran-mode)
                ("\\.C$"    . c++-mode)
                ("\\.cc$"   . c++-mode)
                ("\\.cpp$"  . c++-mode)
                ("\\.hh$"   . c++-mode)
                ("\\.c$"    . c-mode)
                ("\\.h$"    . c-mode)
                ("\\.m$"    . objc-mode)
                ("\\.java$" . java-mode)
                ("\\.pl$"   . cperl-mode)
                ("\\.perl$" . cperl-mode)
                ("\\.tex$"  . yatex-mode)
                ("\\.sty$"  . yatex-mode)
                ("\\.cls$"  . yatex-mode)
                ("\\.clo$"  . yatex-mode)
                ("\\.dtx$"  . yatex-mode)
                ("\\.fdd$"  . yatex-mode)
                ("\\.ins$"  . yatex-mode)
                ("\\.s?html?$" . html-helper-mode)
                ("\\.php$" . html-helper-mode)
                ("\\.jsp$" . html-helper-mode)
                ("\\.css$" . css-mode)
                ("\\.js$"  . java-mode)
                ("\\.el$"  . emacs-lisp-mode)
                ("\\.lua$" . lua-mode)
                ) auto-mode-alist))

(defface YaTeX-font-lock-bold-face
  '((((class color) (background dark)) (:foreground "lightgoldenrod"))
    (((class color) (background light)) (:foreground "DarkGoldenrod"))
    (t (:bold t)))
  "Font Lock mode face used to express bold itself."
  :group 'font-lock-faces)
(defvar YaTeX-font-lock-bold-face 'YaTeX-font-lock-bold-face)
(defface YaTeX-font-lock-italic-face
  '((((class color) (background dark)) (:foreground "Plum1"))
    (((class color) (background light)) (:foreground "purple"))
    (t (:italic t)))
  "Font Lock mode face used to express italic itself."
  :group 'font-lock-faces)
(defvar YaTeX-font-lock-italic-face 'YaTeX-font-lock-italic-face)

(defface font-latex-math-face'((t (:foreground "brightyellow")))
    "Font Lock mode face used to highlight math in LaTeX."
    :group 'font-latex-highlighting-faces)
(setq YaTeX-font-lock-formula-face 'font-latex-math-face)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(electric-indent-mode nil)
 '(safe-local-variable-values (quote ((buffer-file-coding-system . sjis-dos))))
 '(selection-coding-system (quote utf-8-unix))
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(tooltip-mode nil))



(defface my-face-b-1 '((t (:background "color-52"))) nil)
(defface my-face-b-3 '((t (:foreground "color-215"))) nil)
(defface my-face-b-2 '((t (:background "gray15"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-b-3 'my-face-b-3)
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-b-2 append)
     ("　" 0 my-face-b-1 append)
     ("（\\|）" 0 my-face-b-3 append)
     ("[ ]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)



(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq uniquify-ignore-buffers-re "*[^*]+*")


(set-language-environment "Japanese")
(if window-system (progn
  (load-file "/usr/share/emacs/site-lisp/mozc/mozc.el")
  (require 'mozc)
  (setq default-input-method "japanese-mozc")
  (setq mozc-candidate-style 'echo-area)
  (add-hook 'input-method-activate-hook '(lambda () (set-cursor-color "green")))
  (add-hook 'input-method-inactivate-hook '(lambda () (set-cursor-color "red")))
  (global-set-key [?\S- ] 'toggle-input-method)
  (substitute-key-definition
   'toggle-input-method 'isearch-toggle-input-method isearch-mode-map global-map)
  (global-set-key [(super q)] (lambda() (interactive) (set-input-method "japanese-mozc")))
  (global-set-key [(super a)] (lambda() (interactive) (set-input-method nil)))
  (add-hook 'mozc-mode-hook
    (lambda()
      (define-key mozc-mode-map [?\S- ] 'toggle-input-method))
    )
))

(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(set-buffer-file-coding-system 'utf-8-unix)
(global-set-key [delete] 'delete-char)
(global-set-key [backspace] 'delete-backward-char)
(desktop-save-mode 0)

(server-start)


;; xterm-mouse-mode
(unless (fboundp 'track-mouse)
  (defun track-mouse (e)))
(xterm-mouse-mode t)
(require 'mouse)
(require 'mwheel)
(mouse-wheel-mode t)

(define-key global-map "\M-[7~" 'beginning-of-line)
(define-key global-map "\M-[8~" 'end-of-line)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(YaTeX-font-lock-bold-face ((t (:weight bold))))
 '(YaTeX-font-lock-delimiter-face ((t (:weight bold))))
 '(YaTeX-font-lock-formula-face ((t (:foreground "brightyellow"))))
 '(YaTeX-font-lock-italic-face ((t (:slant italic))))
 '(YaTeX-font-lock-math-sub-face ((t (:inherit YaTeX-font-lock-formula-face))))
 '(YaTeX-font-lock-math-sup-face ((t (:inherit YaTeX-font-lock-formula-face))))
 '(font-lock-comment-face ((t (:foreground "color-40")))))
