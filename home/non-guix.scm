;; Stove's Config for Non-Guix systems
;; Use this to work specific to Non-Guix OS devices
;; namely, should work while running Arch/Debian/etc

; imports
(use-modules
 (gnu home)
 (gnu home services)
 (gnu packages)
 (gnu services)
 (guix gexp)
 (gnu home services shells))

;; shortcut function
(define s->p specification->package)

;; Our home environment definition
;; made up of two things:
;; * packages - software we run/require/need/etc
;; * services - things to be run autonomously, link files, etc
(home-environment
 (packages
  (specifications->packages
   `("arc-theme" "arc-icon-theme"
     "hicolor-icon-theme"
     "plasma-workspace-wallpapers"
     )))

 (services
  (list
   ;; This is the base-level Bash customization
   ;; Replace this with your preferred shell
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (aliases '(("grep" . "grep --color=auto")
                        ("ls" . "ls -p --color=auto")
                        ))
             ))
   
   ;; This section is related to env variables for random stuff
   ;; GTK_THEME is required for many GTK-based applications
   ;; in worst cases, GTK2_RC_FILES is needed for older GTK apps
   ;; SDL_VIDEODRIVER must be supplied to prefer wayland support
   ;; over x11, though this might not be enough for most applications
   ;; that don't have up-to-date SDL libraries
   ;; PLASMA_WP is where I put `plasma-workspace-wallpapers` for easier
   ;; customization at the desktop level
   ;; MOZ_ENABLE_WAYLAND, because Firefox is weird about Wayland by default
   ;; add other environment variables here
   (let ([arc-theme (s->p "arc-theme")]
         [plasma-wp (s->p "plasma-workspace-wallpapers")])
     (simple-service
      'env-vars home-environment-variables-service-type
      `(("GUIX_LOCPATH" . "")
        ("MOZ_ENABLE_WAYLAND" . "1")
        ("GTK_THEME" . "Arc-Dark")
        ("SDL_VIDEODRIVER" . "wayland,x11")
        ("SWAY_ROOT" . "")
        ("XDG_DESKTOP_SESSION" . "sway")
        ("XDG_CURRENT_DESKTOP" . "sway")
        ("PLASMA_WP" . ,#~(string-append #$plasma-wp ""))
        ("_JAVA_AWT_WM_NONREPARENTING" . "1")
        ("GTK2_RC_FILES" .
         ,#~(string-append #$arc-theme
                           "/share/themes/Arc-Dark/gtk-2.0/gtkrc"))
        )))
   
   ;; This is a service to create the symlink between our
   ;; files stored in the Git repo to our home system itself.
   ;; The local-file function refers to git-tracked files,
   ;; then stores them into the Guix store, and creates the
   ;; up-to-date symlinks to the files per generation
   (simple-service
    'all-the-dotfiles home-files-service-type
    `((".emacs" ,(local-file "dotfiles/emacsconfig"))
      (".gitconfig" ,(local-file "dotfiles/gitconfig"))))
   )
  ))
 
;; done
