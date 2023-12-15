; This is Stove's Guix configuration for his Lenovo Thinkpad T440

;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (nongnu packages linux))
(use-service-modules cups desktop networking ssh xorg)

(operating-system
  (kernel linux)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "America/New_York")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "thiccpad")

  ;; The list of user accounts ('root' is implicit).
  (users
   (cons*
    (user-account
     (name "steve")
     (comment "Steven")
     (group "users")
     (home-directory "/home/steve")
     (supplementary-groups '("wheel" "netdev" "audio" "video")))
    %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages
   (cons*
    (map specification->packages
         '("sway" "i3status" "dmenu" "rofi" "gvfs" "nss-certs"))
    %base-packages))

  ;; Service section
  ;; Here we want to delete the old gdm service
  ;; and replace it with a Wayland configured one
  (services
   (modify-services
     (cons*
      (service openssh-service-type)
      (service cups-service-type)
      (service gdm-service-type
               (gdm-configuration
                (wayland? #t)))
      (modify-services %desktop-services
                       (delete gdm-service-type)))

     ; stub Nonguix info into our channels
     (guix-service-type config =>
       (guix-configuration
        (inherit config)
        (substitute-urls
         (cons* "https://substitutes.nonguix.org"
                %default-substitute-urls))
        (authorized-keys
         (cons*
          ;; needs Nonguix's signing key stored somewhere
          ;; modify to where you store it
          (local-file "/etc/signing-key.pub")
          %default-authorized-guix-keys))))
     ))

  ;; Bootloader
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)
    (targets (list "/dev/sda"))
    (keyboard-layout keyboard-layout)))

  ;; My swap disk
  (swap-devices
   (list (swap-space
          (target
           (uuid "02a235c5-0cb2-49ad-8634-deac5bb615b6")))))

  ;; My data disk
  (file-systems
   (cons*
    (file-system
     (mount-point "/")
     (device (uuid "5f993c0b-1c14-4dee-87c5-f15964913e04" 'ext4))
     (type "ext4"))
    %base-file-systems)))

; end
