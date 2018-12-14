(define-module (fish-shell)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages base)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages groff)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages python))

;; TODO: fish 3.0 is build using the CMake system as a preferred method
(define-public fish-3.0
  (package
    (name "fish")
    (version "3.0b1")
    (source (origin
              (method url-fetch)
              (uri
               (list
                (string-append "https://fishshell.com/files/"
                               version "/fish-" version ".tar.gz")
                (string-append "https://github.com/fish-shell/fish-shell/"
                               "releases/download/" version "/"
                               name "-" version ".tar.gz")))
              (sha256
               (base32
                "19p8qndikrf4gg5mnaqj2c6rsr17fwgykf1zkq58p0rbkyn69i0i"))
              (modules '((guix build utils)))
              (snippet '(begin
                          ;; Don't try to install /etc/fish/config.fish
                          (substitute* "Makefile.in"
                            ((".*INSTALL.*sysconfdir.*fish.*") ""))
                          #t))))
    (build-system gnu-build-system)
    (native-inputs
     `(("doxygen" ,doxygen)
       ("coreutils" ,coreutils))) ; for env
    (inputs
     `(("bc" ,bc)
       ("perl" ,perl)
       ("ncurses" ,ncurses)
       ("groff" ,groff)               ;for 'fish --help'
       ("pcre2" ,pcre2)               ;don't use the bundled PCRE2
       ("python" ,python-wrapper)))   ;for fish_config and manpage completions
    (arguments
     '(#:tests? #f ; no check target
       #:configure-flags '("--sysconfdir=/etc")
       #:phases
       (modify-phases %standard-phases
         ;; Embed absolute paths to store items.
         (add-after 'unpack 'embed-store-paths
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (substitute* '("share/functions/seq.fish")
               (("\\| bc")
                (string-append "| " (assoc-ref %build-inputs "bc")
                               "/bin/bc")))
             (substitute* "share/functions/fish_update_completions.fish"
               (("python") (which "python")))
             (substitute* "share/functions/__fish_print_help.fish"
               (("nroff") (which "nroff")))
             ;; Get rid of /usr/bin/env in the build scripts
             (substitute* "build_tools/build_commands_hdr.sh"
               (("/usr/bin/env awk") (which "awk")))
             #t)))))
    (synopsis "The friendly interactive shell")
    (description
     "Fish (friendly interactive shell) is a shell focused on interactive use,
discoverability, and friendliness.  Fish has very user-friendly and powerful
tab-completion, including descriptions of every completion, completion of
strings with wildcards, and many completions for specific commands.  It also
has extensive and discoverable help.  A special @command{help} command gives
access to all the fish documentation in your web browser.  Other features
include smart terminal handling based on terminfo, an easy to search history,
and syntax highlighting.")
    (home-page "https://fishshell.com/")
    (license gpl2)))
