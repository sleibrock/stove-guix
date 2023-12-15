;; Stove's generic Guix home config
;; Can work independent of Guix OS (I hope)

(use-modules
 (gnu home)
 (gnu home services)
 (gnu packages)
 (gnu services)
 (guix gexp)
 (gnu home services shells))

(define s->p specification->package)

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages
  (specifications->packages
   '(;; desktop utilities
     "sway" "htop" "git" "emacs" "vim" "kitty" "brightnessctl"
     "pcmanfm" "grim" "rofi" "pavucontrol" "curl"
     "arc-theme" "arc-icon-theme" "hicolor-icon-theme"
     "plasma-workspace-wallpapers"
     ;; programming environs
     "python" "ruby" "racket" "ghc" "janet" "gcc-toolchain" "openjdk"
     ;; multimedia
     "gimp" "graphviz" "libreoffice" "mpd" "ncmpcpp"
     ;;"steam"
     ;;"colobot"
     ;;"gzdoom"
     ;; the "i'm gaming" section
     "chocolate-doom" "freedoom" "gzdoom"
     "mgba" "bsnes"
     ;;"colobot" ; slow
     ;;"steam" ; slow
     ;; the forbidden firefox section
     ;;"firefox"
     )))

  (services
   (list
    ;; Customizing our bash shell environ
    (service home-bash-service-type
             (home-bash-configuration
              (aliases '(("grep" . "grep --color=auto")
                         ("ls" . "ls -p --color=auto")
                         ))
              (bashrc (list (local-file "/home/steve/.bashrc" "bashrc")))
              (bash-profile (list (local-file "/home/steve/.bash_profile"
                                              "bash_profile")))))
    ;; Adding my custom environment variables into the home
    (let ([arc-theme (s->p "arc-theme")]
          [sway      (s->p "sway")]
          [plasma-wp (s->p "plasma-workspace-wallpapers")])
       (simple-service
        'env-vars home-environment-variables-service-type
        `(("MOZ_ENABLE_WAYLAND" . "1")
          ("GTK_THEME" . "Arc-Dark")
          ("SWAY_ROOT" . ,#~(string-append #$sway ""))
          ("PLASMA_WP" . ,#~(string-append #$plasma-wp ""))
          ("GTK2_RC_FILES" .
           ,#~(string-append #$arc-theme
                             "/share/themes/Arc-Dark/gtk-2.0/gtkrc"))
          )))
    (simple-service
     'all-the-dotfiles home-files-service-type
     `((".sway/config" ,(local-file "dotfiles/swayconfig"))
       (".emacs" ,(local-file "dotfiles/emacsconfig"))
       (".gitconfig" ,(local-file "dotfiles/gitconfig"))
       ))
    )))

; end
