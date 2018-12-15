(define-module (coq)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
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

(define-public coq-autosubst
  (let ((branch "coq86-devel")
        (commit "d0d73557979796b3d4be7aac72135581c33f26f7"))
    (package
      (name "coq-autosubst")
      (synopsis "A Coq library for parallel de Bruijn substitutions")
      (version (git-version "1" branch commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "git://github.com/uds-psl/autosubst.git")
                      ;; (branch branch)
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32 "1852xb5cwkjw3dlc0lp2sakwa40bjzw37qmwz4bn3vqazg1hnh6r"))))
      (build-system gnu-build-system)
      (native-inputs
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
      (description "Formalizing syntactic theories with variable binders is not easy. We present Autosubst, a library for the Coq proof assistant to automate this process. Given an inductive definition of syntactic objects in de Bruijn representation augmented with binding annotations, Autosubst synthesizes the parallel substitution operation and automatically proves the basic lemmas about substitutions. Our core contribution is an automation tactic that solves equations involving terms and substitutions. This makes the usage of substitution lemmas unnecessary. The tactic is based on our current work on a decision procedure for the equational theory of an extension of the sigma-calculus by Abadi et. al. The library is completely written in Coq and uses Ltac to synthesize the substitution operation.")
      (home-page "https://www.ps.uni-saarland.de/autosubst/")
      (license bsd-3))))

