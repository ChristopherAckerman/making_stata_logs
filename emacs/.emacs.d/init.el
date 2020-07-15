(setq use-package-always-ensure t)
(setq inhibit-startup-message t)
(setq inhibit-scratch-message nil)

;;PacMan stuff
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives
	     '("gnu" . "http://elpa.gnu.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq package-check-signature nil)

;;org-mode
(require 'org)
(require 'pdf-tools)
;; (setq Tex-auto-save t)
;; (setq Tex-parse-self t)
;; (setq-default Tex-master nil)
;; (setq TeX-PDF-mode t)
;; (pdf-tools-install)

;; stats stuff
(require 'ess)
;; (require 'ess-site)
;; personal elisp (and ob-stata.el/ess-stata-mode.el)
(add-to-list 'load-path "~/dotfiles/emacs/.emacs.d/lisp")
(require 'ess-stata-mode)
;; (setq-default inferior-STA-program-name "stata-se")
(setq-default inferior-STA-program "stata-se")
(setq-default inferior-STA-start-args "")

;;literate programming
(require 'babel)
(setq org-confirm-babel-evaluate nil)
;; Tell emacs location of the directory containing 
(require 'ob-stata)
(require 's)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((stata . t)
   (latex . t)))
;; Include the latex-exporter
(require 'ox-latex)
(add-to-list 'org-latex-packages-alist '("" "minted"))
(setq org-latex-listings 'minted) 

(setq org-latex-to-pdf-process (list "latexmk -shell-escape -f -interaction=nonstopmode -pdf %f"))

