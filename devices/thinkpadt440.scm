;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


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
  (users (cons* (user-account
                  (name "steve")
                  (comment "Steven")
                  (group "users")
                  (home-directory "/home/steve")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (specification->package "sway")
                          (specification->package "i3status")
                          (specification->package "dmenu")
                          (specification->package "rofi")
			              (specification->package "gvfs")
                          (specification->package "nss-certs"))
                    %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (modify-services  
     (cons*
                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service cups-service-type)
		         (service gdm-service-type
	                      (gdm-configuration
		                   (wayland? #t)))

           ;; This is the default list of services we
           ;; are appending to.
           (modify-services %desktop-services
            (delete gdm-service-type)))

     ; stub Nonguix info into our channels
     (guix-service-type config => 
       (guix-configuration
	 (inherit config)
          (substitute-urls
	    (cons* "https://substitutes.nonguix.org" %default-substitute-urls))
	  (authorized-keys
	    (cons*
	      ; needs Nonguix's signing key stored somewhere, in this case, /etc
	      (local-file "/etc/signing-key.pub")
	      %default-authorized-guix-keys))))
     ))

  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/sda"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "02a235c5-0cb2-49ad-8634-deac5bb615b6")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "5f993c0b-1c14-4dee-87c5-f15964913e04"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))
