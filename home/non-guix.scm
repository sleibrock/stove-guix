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

; shortcut function
(define s->p specification->package)

; our home environment definition
(home-environment
 (packages
  (specifications->packages
   `("grim" "slurp" "wl-clipboard"
     "arc-theme" "arc-icon-theme"
     "hicolor-icon-theme"
     "plasma-workspace-wallpapers"
     )))

 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (aliases '(("grep" . "grep --color=auto")
                        ("ls" . "ls -p --color=auto")
                        ))
             (bashrc
              (list (local-file "/home/steve/.bashrc" "bashrc")))
             (bash-profile
              (list (local-file "/home/steve/.bash_profile"
                                "bash_profile")))))
   
   (let ([arc-theme (s->p "arc-theme")]
         [plasma-wp (s->p "plasma-workspace-wallpapers")])
     (simple-service
      'env-vars home-environment-variables-service-type
      `(("MOZ_ENABLE_WAYLAND" . "1")
        ("GTK_THEME" . "Arc-Dark")
        ("SDL_VIDEODRIVER" . "wayland,x11")
        ("SWAY_ROOT" . "")
        ("XDG_DESKTOP_SESSION" . "sway")
        ("XDG_CURRENT_DESKTOP" . "sway")
        ("PLASMA_WP" . ,#~(string-append #$plasma-wp ""))
        ("_JAVA_AWT_WM_NONREPARENTING" . "1")
        ("GTK2_RC_FILES" .
         ,#~(string-append #$arc-theme
                           "/share/themes/Arc-Dark/gtk-2.0/gtkrc")))))
   
   (simple-service
    'all-the-dotfiles home-files-service-type
    `((".emacs" ,(local-file "dotfiles/emacsconfig"))
      (".gitconfig" ,(local-file "dotfiles/gitconfig"))))
   )
  ))
 
                                        ; done
