;; Alienware Alpha Guix configuration
;; Steven's personal Guix definition for his Alienware Alpha box
;; Comments are documentation about the setup
;; To use successfully, you must add `nongnu` as a channel in Guix
;; then run `guix pull` to get commits from the `nongnu` channel
;;
;; Author: Steven Leibrock <steven.leibrock@gmail.com>


;; Imports required for build
;; Uses the nongnu channel for Linux packages
;; Services not included by default in Guix must
;; be imported up here (like Docker)
(use-modules (gnu)
             (gnu services docker)
             (nongnu packages linux)
             (nongnu system linux-initrd))
(use-service-modules base cups desktop networking ssh)


;; Operating system function to generate a functional OS
;; from a single definition.
(operating-system
 ;; System setup
 ;; kernel   - by default this uses a libre Linux kernel with free only code
 ;;          - we change this to use the kernel from nongnu channel
 ;; initrd   - microcode patches for CPUs that are nonfree
 ;; firmware - same story...
 ;; locale   - change to your language
 ;; tz       - change to your region
 ;; keyboard - yup
 ;; hostname - change as you please
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "alienguix")

 ;; Users
 ;; This list of users is passed to the system build
 ;; to generate users dynamically. Passwords are not
 ;; set here (obviously) and must be set by root admin.
 ;; Groups, home directory, other details, etc
 (users
  (cons*
   (user-account
    (name "steve")
    (comment "It'sa me")
    (group "users")
    (home-directory "/home/steve")
    (supplementary-groups '("wheel" "netdev" "audio" "video" "docker")))
   %base-user-accounts))

 ;; Packages
 ;; These packages are installed system-wide for all users
 ;; nss-certs - signing purposes
 ;; gvfs      - volume management
 ;; neovim    - modern vim replacement
 ;; git       - git
 ;; ruby      - no comment
 ;; racket    - modern lisp/scheme
 ;; python    - no comment
 ;; htop      - proc management / viewer
 ;; docker    - container hosting
 ;; gcc-toolchain - gcc, g++, etc
 ;; tmux      - alternative to gnu/screen
 ;; %base-packages - base list of packages to append to
 ;;
 ;; Post-install, you can install packages through Guix
 ;; ie. `guix install vim`
 (packages
  (append
   (map specification->package
        '("udisks" "gvfs" "neovim" "git" "ruby" "racket"
          "curl" "openssl" "ntfs-3g" "make" "zip" "unzip"
          "python" "htop" "docker" "containerd" "gcc-toolchain"
          "tmux"
          ))
   %base-packages))

 ;; Services list
 ;; List of services and explanations why:
 ;; network-manager - for internet / nm-applet
 ;; wpa-supplicant  - wifi capabilities (low priority)
 ;; openssh-service - autostart sshd service
 ;; cups-service    - printing, who cares
 ;; elogind         - login init system
 ;; containerd      - needed for Docker
 ;; docker          - docker-related stuff (process autostart)
 ;; %base-services  - default, minimal linux services to append to
 (services
  (modify-services
   (cons*
    (service network-manager-service-type)
    (service wpa-supplicant-service-type)
    (service openssh-service-type)
    (service cups-service-type)
    (service elogind-service-type (elogind-configuration))
    (service containerd-service-type)
    (service docker-service-type)
    %base-services)

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
       (plain-file "non-guix.pub"
                   "(public-key
 (ecc
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
  )
 )")
       %default-authorized-guix-keys))))
   ))

 ;; Bootloader section
 ;; Configure to match your partitioning / BIOS setup
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))

 ;; Swap devices
 ;; Configure a SWAP and set your UUID here
 (swap-devices
  (list
   (swap-space
    (target
     (uuid "cc10f5d0-ef06-4dfb-b9f1-a9991badeb16")))))

 ;; File systems
 ;; These systems will get "mounted" by default
 ;; Change to match your partitioned drives UUIDs / vol types
 (file-systems
  (cons* (file-system
          (mount-point "/boot/efi")
          (device (uuid "6B40-C07A" 'fat32))
          (type "vfat"))
         (file-system
          (mount-point "/")
          (device (uuid
                   "d979309e-9dbc-4894-82b2-2da645d39cec"
                   'ext4))
          (type "ext4"))
         %base-file-systems)))

;; end
