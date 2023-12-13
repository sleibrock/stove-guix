;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
	     (gnu home services)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (gnu home services shells))

(define s->p specification->package)

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "graphviz"
                                            "htop"
                                            "brightnessctl"
                                            "sway"
                                            "ncmpcpp"
                                            "libreoffice"
                                            "arc-icon-theme"
                                            "arc-theme"
                                            "ruby"
                                            "pcmanfm"
                                            "gimp"
                                            "mpd"
                                            "racket"
                                            "ghc"
                                            "python"
					    "grim"
                                            "rofi"
                                            ;"steam"
                                            ;"colobot"
                                            ;"gzdoom"
                                            "chocolate-doom"
					    "plasma-workspace-wallpapers"
                                            "freedoom"
                                            "mgba"
                                            "bsnes"
                                            "hicolor-icon-theme"
                                            "openjdk"
                                            "pavucontrol"
                                            "git"
                                            "gcc-toolchain"
                                            "janet"
                                            ;"firefox"
                                            "vim"
                                            "curl"
                                            "kitty"
                                            "emacs")))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (list (service home-bash-service-type
                  (home-bash-configuration
                   (aliases '(
			      ("grep" . "grep --color=auto")
			      ("ls" . "ls -p --color=auto")
			      ))
                   (bashrc (list (local-file "/home/steve/.bashrc" "bashrc")))
                   (bash-profile (list (local-file "/home/steve/.bash_profile"
                                        "bash_profile")))))
	 (let ([arc-theme (s->p "arc-theme")]
	       [sway      (s->p "sway")]
	       [plasma-wp (s->p "plasma-workspace-wallpapers")])
	   (simple-service 
	     'env-vars home-environment-variables-service-type
	     `(("MOZ_ENABLE_WAYLAND" . "1")
               ("GTK_THEME" . "Arc-Dark")
	       ("SWAY_ROOT" . ,#~(string-append #$sway ""))
	       ("PLASMA_WP" . ,#~(string-append #$plasma-wp ""))
	       ("GTK2_RC_FILES" . ,#~(string-append #$arc-theme
                                      "/share/themes/Arc-Dark/gtk-2.0/gtkrc"))
               )))
	 (simple-service
	   'all-the-dotfiles home-files-service-type
	   `((".sway/config" ,(local-file "dotfiles/swayconfig"))
	     (".emacs" ,(local-file "dotfiles/emacsconfig"))
	     (".gitconfig" ,(local-file "dotfiles/gitconfig"))
	      ))
	  )))
