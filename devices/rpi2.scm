;; Raspberry Pi 2 Guix configuration
;; requires being CC'd to aarch64 / armv7
;; ex: guix system --target=aarch64 rpi2.scm

(use-modules (gnu) (nongnu packages linux))
(use-service-modules cups networking ssh)

(operating-system
 (kernel linux)
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "stoverpi2")

 (users
  (cons*
   (user-account (name "steve")
                 (comment "It'sa Steben")
                 (group "users")
                 (home-directory "/home/steve")
                 (supplementary-groups '("wheel" "netdev" "audio" "video")))
   %base-user-accounts))

 (packages
  (cons*
   (map specification->packages
        '("vim" "python" "ruby" "janet" "racket" "ghc"
          "nss-certs" "gvfs"))
   %base-packages))

 (services
  (modify-services
   (cons*
    (service openssh-service-type)
    (service cups-service-type)
    %desktop-services)

   ;; stub Nonguix info into our channels
   (guix-service-type
    config =>
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
 
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (targets (list "/dev/sda"))
   (keyboard-layout keyboard-layout)))

 ;; swap and data
 (swap-devices
  (list (swap-space
         (target
          (uuid "<insert uuid of swap space on SD card")))))
 (file-systems
  (cons*
   (file-system
    (mount-point "/")
    (device (uuid "" 'ext4))
    (type "ext4"))
   %base-file-systems)))

;; end
