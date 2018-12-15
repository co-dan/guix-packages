(define-module (coq)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages ocaml))

(define-public coq-stdpp
  (package
    (name "coq-stdpp")
    (synopsis "An alternative Coq standard library coq-std++")
    (version "1.1.0")
    (source (origin
             (method url-fetch)
             (uri (string-append
                   "https://gitlab.mpi-sws.org/robbertkrebbers/coq-stdpp/repository/coq-stdpp-"
                   version "/archive.tar.gz"))
             (file-name (string-append name "-" version ".tar.gz"))
             (sha256
              (base32 "1lhyalr20amz8inr4ca6p70lhfal0gmxwsvnh1xd04mcvsgxhj8s"))))
    (build-system gnu-build-system)
    (native-inputs
     `(;; need for egrep for tests
       ("grep" ,grep)
       ("gawk" ,gawk)
       ;; need diff for tests
       ("diffutils" ,diffutils)))
    (inputs
     `(("coq" ,coq)))
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (setenv "COQLIB" (string-append (assoc-ref outputs "out") "/lib/coq/"))
             (zero? (system* "make"
                             (string-append "COQLIB=" (assoc-ref outputs "out")
                                            "/lib/coq/")
                             "install")))))))
   (description "This project contains an extended \"Standard Library\" for Coq called coq-std++.")
   (home-page "https://gitlab.mpi-sws.org/iris/stdpp")
   (license bsd-3)))
