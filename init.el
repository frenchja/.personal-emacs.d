;;; init.el --- Emacs init file
;;  Author: Ian Y.E. Pan
;;; Commentary:
;;; A use-package lightweight Emacs config containing only the essentials.
;;; Code:

(let ((file-name-handler-alist nil))

  (setq gc-cons-threshold 402653184
        gc-cons-percentage 0.6)

  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
  (setq package-enable-at-startup nil)
  (package-initialize)

  (setq custom-file "~/.emacs.d/to-be-dumped.el") ; custom generated, don't load

  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package-ensure)
  (setq use-package-always-ensure t)

  (setq ring-bell-function 'ignore
        confirm-kill-processes nil
        make-backup-files nil
        default-directory "~/"
        eldoc-idle-delay 0.4)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode +1)
  (blink-cursor-mode -1)
  (setq mouse-highlight nil)
  (column-number-mode)
  (setq scroll-margin 0
        scroll-conservatively 10000
        scroll-preserve-screen-position t
        auto-window-vscroll nil
        mouse-wheel-scroll-amount '(1 ((shift) . 1))
        mouse-wheel-progressive-speed nil)
  (setq show-paren-delay 0)
  (show-paren-mode)
  (setq frame-title-format '("Emacs")
        initial-frame-alist (quote ((fullscreen . maximized))))
  (set-frame-font "Source Code Pro-13" nil t)
  (setq-default line-spacing 3)
  (add-hook 'prog-mode-hook 'electric-pair-mode)
  (add-hook 'before-save-hook 'whitespace-cleanup)
  (define-key prog-mode-map (kbd "s-b") 'xref-find-definitions)
  (define-key prog-mode-map (kbd "s-[") 'xref-pop-marker-stack)
  (setq auto-revert-interval 2
        auto-revert-check-vc-info t
        auto-revert-verbose nil)
  (add-hook 'after-init-hook 'global-auto-revert-mode)
  (setq-default indent-tabs-mode nil
                tab-width 4
                c-basic-offset 4)
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "k&r")))

  (defun ian/load-init()
    "Reload `.emacs.d/init.el'."
    (interactive)
    (load-file "~/.emacs.d/init.el"))

  (defun ian/hide-dos-eol ()
    "Do not show ^M in files containing mixed UNIX and DOS line endings."
    (interactive)
    (setq buffer-display-table (make-display-table))
    (aset buffer-display-table ?\^M []))

  (defun ian/split-and-follow-horizontally ()
    "Split window below."
    (interactive)
    (split-window-below)
    (other-window 1))

  (defun ian/split-and-follow-vertically ()
    "Split window right."
    (interactive)
    (split-window-right)
    (other-window 1))

  (global-set-key (kbd "C-x 2") 'ian/split-and-follow-horizontally)
  (global-set-key (kbd "C-x 3") 'ian/split-and-follow-vertically)

  (defun ian/disable-bold-and-fringe-bg-face-globally ()
    "disable bold face and fringe backgroung in Emacs"
    (interactive)
    (set-face-attribute 'fringe nil :background nil)
    (mapc (lambda (face)
            (when (eq (face-attribute face :weight) 'bold)
              (set-face-attribute face nil :weight 'normal))) (face-list)))

  ;; (use-package doom-themes :config (load-theme 'doom-tomorrow-night t))

  (use-package zenburn-theme :config (load-theme 'zenburn t))

  ;; (set-background-color "#151515")
  ;; (set-foreground-color "#eeeeee")
  ;; (custom-set-faces
  ;;  '(region ((t (:background "#333D48"))))
  ;;  '(solaire-default-face ((t (:inherit default :background "black"))))
  ;;  '(solaire-minibuffer-face ((t (:inherit default :background "black"))))
  ;;  '(solaire-hl-line-face ((t (:inherit hl-line))))
  ;;  '(mode-line ((t (:background "#2b2b2b" :foreground "white"))))
  ;;  '(ido-only-match ((t (:foreground "#98FB98"))))
  ;;  '(company-preview ((t (:underline t :weight bold))))
  ;;  '(company-preview-common ((t (:inherit company-preview))))
  ;;  '(company-scrollbar-bg ((t (:background "lightgray"))))
  ;;  '(company-scrollbar-fg ((t (:background "darkgray"))))
  ;;  '(company-tooltip ((t (:background "lightgray" :foreground "black"))))
  ;;  '(company-tooltip-common ((t (:inherit company-preview-common))))
  ;;  '(company-tooltip-selection ((t (:background "steelblue" :foreground "white")))))

  (use-package solaire-mode
    :hook (((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
           (minibuffer-setup . solaire-mode-in-minibuffer))
    :config
    (solaire-global-mode)
    (solaire-mode-swap-bg))

  (use-package diminish)

  (use-package evil
    :diminish undo-tree-mode
    :init (setq evil-want-C-u-scroll t)
    :hook (after-init . evil-mode)
    :config
    (with-eval-after-load 'evil-maps ; avoid conflict with company tooltip selection
      (define-key evil-insert-state-map (kbd "C-n") nil)
      (define-key evil-insert-state-map (kbd "C-p") nil))
    (evil-set-initial-state 'term-mode 'emacs)
    (defun ian/save-and-kill-this-buffer ()
      (interactive)
      (save-buffer)
      (kill-this-buffer))
    (evil-ex-define-cmd "q" 'kill-this-buffer)
    (evil-ex-define-cmd "wq" 'ian/save-and-kill-this-buffer)
    (use-package evil-commentary
      :after evil
      :diminish evil-commentary-mode
      :config (evil-commentary-mode)))

  (use-package company
    :diminish company-mode eldoc-mode
    :hook (prog-mode . company-mode)
    :config
    (setq company-minimum-prefix-length 1
          company-idle-delay 0
          company-selection-wrap-around t
          company-tooltip-align-annotations t
          company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even if single candidate
                              company-echo-metadata-frontend))
    (with-eval-after-load 'company
      (define-key company-active-map (kbd "C-n") 'company-select-next)
      (define-key company-active-map (kbd "C-p") 'company-select-previous)))

  (use-package flycheck
    :hook (after-init . global-flycheck-mode)
    :config
    (setq ispell-program-name "/usr/local/bin/aspell")
    (setq flycheck-python-flake8-executable "python3"))

  (use-package ido-vertical-mode
    :hook ((after-init . ido-mode)
           (after-init . ido-vertical-mode))
    :config
    (setq ido-everywhere t
          ido-enable-flex-matching t
          ido-vertical-define-keys 'C-n-C-p-up-and-down))

  (use-package flx-ido :config (flx-ido-mode))

  (use-package magit :bind ("C-x g" . magit-status))

  (use-package org-bullets
    :hook ((org-mode . org-bullets-mode)
           (org-mode . visual-line-mode)
           (org-mode . org-indent-mode)))

  (use-package ranger
    :defer t
    :config (setq ranger-width-preview 0.5))

  (use-package highlight-numbers :hook (prog-mode . highlight-numbers-mode))

  (use-package highlight-operators :hook (prog-mode . highlight-operators-mode))

  (use-package highlight-escape-sequences :hook (prog-mode . hes-mode))

  (use-package which-key
    :diminish which-key-mode
    :defer 1
    :config
    (which-key-mode)
    (setq which-key-idle-delay 0.4
          which-key-idle-secondary-delay 0.4))

  (use-package dashboard
    :config
    (dashboard-setup-startup-hook)
    (setq dashboard-startup-banner 'logo
          dashboard-banner-logo-title "Dangerously powerful"
          dashboard-items nil
          dashboard-set-footer nil))

  (use-package yasnippet-snippets
    :config
    (yas-global-mode)
    (advice-add 'company-complete-common :before (lambda () (setq my-company-point (point))))
    (advice-add 'company-complete-common :after (lambda () (when (equal my-company-point (point)) (yas-expand)))))

  (use-package markdown-mode :hook (markdown-mode . visual-line-mode))

  (use-package kotlin-mode)

  (use-package json-mode)

  (use-package format-all
    :config
    (defun ian/format-code ()
      "Auto-format whole buffer"
      (interactive)
      (format-all-buffer)))

  (use-package exec-path-from-shell
    :config (when (memq window-system '(mac ns x))
              (exec-path-from-shell-initialize)))

  (use-package highlight-symbol
    :diminish highlight-symbol-mode
    :hook (prog-mode . highlight-symbol-mode)
    :config (setq highlight-symbol-idle-delay 0.3))

  (use-package lsp-mode
    :hook ((c-mode
            c-or-c++-mode
            java-mode
            python-mode
            js-mode
            web-mode
            typescript-mode) . lsp)
    :commands lsp
    :config (setq lsp-enable-symbol-highlighting nil))

  (use-package company-lsp
    :commands company-lsp
    :config (setq company-lsp-cache-candidates 'auto))

  (use-package lsp-java :after lsp)

  (use-package typescript-mode
    :mode ("\\.ts\\'" . typescript-mode)
    :config (setq typescript-indent-level 2))

  (use-package js2-mode
    :mode ("\\.jsx?\\'" . js-mode)
    :diminish js2-minor-mode
    :hook ((js-mode . js2-minor-mode))
    :config
    (setq js-indent-level 2
          js2-strict-missing-semi-warning nil))

  (use-package web-mode
    :mode (("\\.html?\\'". web-mode)
           ("\\.css\\'". web-mode)
           ("\\.tsx\\'". web-mode))
    ;; :hook (web-mode . (lambda ()
    ;;                     (when (string-match "\\.tsx\\'" buffer-file-name)
    ;;                       (add-hook 'web-mode-hook 'lsp))))
    :config
    (setq web-mode-markup-indent-offset 2 ; html
          web-mode-code-indent-offset 2   ; tsx
          web-mode-css-indent-offset 2))  ; css

  (use-package treemacs
    :after evil
    :config
    (global-set-key (kbd "s-1") 'treemacs)
    (setq treemacs-fringe-indicator-mode nil
          treemacs-no-png-images t
          treemacs-width 40
          treemacs-silent-refresh t
          treemacs-silent-filewatch t
          treemacs-file-event-delay 1000
          treemacs-file-follow-delay 0.1)
    (use-package treemacs-evil
      :after treemacs
      :config
      (evil-define-key 'treemacs treemacs-mode-map (kbd "l") 'treemacs-RET-action)
      (evil-define-key 'treemacs treemacs-mode-map (kbd "h") 'treemacs-TAB-action)))

  (use-package treemacs-projectile)

  (use-package all-the-icons :config (setq all-the-icons-scale-factor 1.0))

  (use-package centaur-tabs
    :demand
    :init (setq centaur-tabs-set-bar 'over)
    :config
    (centaur-tabs-mode)
    (centaur-tabs-headline-match)
    (setq centaur-tabs-set-modified-marker t
          centaur-tabs-modified-marker "●"
          centaur-tabs-cycle-scope 'tabs
          centaur-tabs-height 30
          centaur-tabs-set-icons t)
    :bind
    ("C-S-<tab>" . centaur-tabs-backward)
    ("C-<tab>" . centaur-tabs-forward))

  (use-package emmet-mode
    :hook ((js-mode . emmet-mode) ; js, jsx
           (web-mode . emmet-mode)) ; tsx, html, & css
    :config (setq emmet-expand-jsx-className? t))

  (use-package projectile
    :diminish projectile-mode
    :config
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    (define-key projectile-mode-map (kbd "s-p") 'projectile-find-file)
    (setq projectile-sort-order 'recentf
          projectile-indexing-method 'hybrid)
    (projectile-mode +1))

  (use-package smart-mode-line :config (setq sml/no-confirm-load-theme t) (sml/setup))

  ) ;; file-name-handler-alist ends here

(ian/disable-bold-and-fringe-bg-face-globally)

(setq gc-cons-threshold 20000000
      gc-cons-percentage 0.1)

(provide 'init)
;;; init.el ends here
