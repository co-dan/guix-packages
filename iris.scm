(define-module (coq)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix build utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system ocaml)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (gnu packages base)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages python)
  #:use-module (gnu packages gawk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages coq))

;; I want to install some of the libraries directly from the source code
;; For that I use the .git versions of the packages
(define coq-stdpp-dev-dir "/home/dan/iris/coq-stdpp")
(define coq-iris-dev-dir "/home/dan/iris/iris-coq")
(define coq-iris-examples-dev-dir "/home/dan/iris/iris-examples")
(define coq-iris-c-monad-dev-dir "/home/dan/iris/c-monad")

(define-public coq-stdpp
  (package
    (name "coq-stdpp")
    (synopsis "An alternative Coq standard library coq-std++")
    (version "1.1.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://gitlab.mpi-sws.org/iris/stdpp/repository/stdpp-"
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
     `(("coq" ,coq)
       ("camlp5" ,camlp5)))
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

(define-public coq-iris
  (package
    (name "coq-iris")
    (synopsis "Higher-Order Concurrent Separation Logic Framework implemented and verified in the proof assistant Coq")
    (version "3.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://gitlab.mpi-sws.org/FP/coq-iris/repository/coq-iris-"
                    version "/archive.tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32 ""))))
    (build-system gnu-build-system)
    (native-inputs
     `(;; need for egrep for tests
       ("grep" ,grep)
       ("gawk" ,gawk)
       ;; need diff for tests
       ("diffutils" ,diffutils)
       ("coq" ,coq)
       ("coq-stdpp" ,coq-stdpp)
       ("camlp5" ,camlp5)))
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
    (description "Iris Coq formalization")
    (home-page "https://gitlab.mpi-sws.org/FP/iris-coq")
    (license bsd-3)))


(define-public coq-stdpp.git
  (package
    (inherit coq-stdpp)
    (name "coq-stdpp.git")
    (synopsis "An alternative Coq standard library coq-std++ (local files)")
    (version "dev")
    (source (local-file coq-stdpp-dev-dir
                        #:recursive? #t
                        #:select? ;; (git-file? coq-stdpp-dev-dir)
                        (git-predicate coq-stdpp-dev-dir)
                        ))))

(define-public coq-iris.git
  (package
    (inherit coq-iris)
    (name "coq-iris.git")
    (synopsis "Iris Coq formalzation (local files)")
    (version "dev")
    (native-inputs
     `(;; need for egrep for tests
       ("grep" ,grep)
       ("gawk" ,gawk)
       ;; need diff for tests
       ("diffutils" ,diffutils)
       ("coq" ,coq)
       ("coq-stdpp.git" ,coq-stdpp.git)
       ("camlp5" ,camlp5)))
    (source (local-file coq-iris-dev-dir
                        #:recursive? #t
                        #:select? (git-predicate coq-iris-dev-dir)))))

(define-public coq-iris-examples.git
  (package
    (inherit coq-iris)
    (name "coq-iris-examples.git")
    (synopsis "Iris Coq Examples (local files)")
    (version "dev")
    (native-inputs
     `(;; need for egrep for tests
       ("grep" ,grep)
       ("gawk" ,gawk)
       ;; need diff for tests
       ("diffutils" ,diffutils)
       ("coq" ,coq)
       ("coq-stdpp.git" ,coq-stdpp.git)
       ("coq-autosubst",coq-autosubst)
       ("coq-iris.git" ,coq-iris.git)
       ("camlp5" ,camlp5)))
    (source (local-file coq-iris-examples-dev-dir
                        #:recursive? #t
                        #:select? (git-predicate coq-iris-examples-dev-dir)))))

(define-public coq-iris-c-monad.git
  (package
    (inherit coq-iris)
    (name "coq-iris-c-monad.git")
    (synopsis "Mini C in Iris (local files)")
    (version "dev")
    (native-inputs
     `(;; need for egrep for tests
       ("grep" ,grep)
       ("gawk" ,gawk)
       ;; need diff for tests
       ("diffutils" ,diffutils)
       ("coq" ,coq)
       ("coq-stdpp.git" ,coq-stdpp.git)
       ("coq-iris.git" ,coq-iris.git)
       ("camlp5" ,camlp5)))
    (source (local-file coq-iris-c-monad-dev-dir
                        #:recursive? #t
                        #:select? (git-predicate coq-iris-c-monad-dev-dir)))))

;; (define-public coq
;;   (package
;;     (name "coq")
;;     (version "8.9.0")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/coq/coq.git")
;;              (commit (string-append "V" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "01ad7az6f95w16xya7979lk32agy22lf4bqgqf5qpnarpkpxhbw8"))))
;;     (native-search-paths
;;      (list (search-path-specification
;;             (variable "COQPATH")
;;             (files (list "lib/coq/user-contrib")))))
;;     (build-system ocaml-build-system)
;;     (inputs
;;      `(("lablgtk" ,lablgtk)  ;; for coqide
;;        ("python" ,python-2)
;;        ("rsync" ,rsync) ;; for building the test log summary
;;        ("camlp5" ,camlp5)
;;        ("ocaml-num" ,ocaml-num)
;;        ("ocaml-ounit" ,ocaml-ounit)))
;;     (arguments
;;      `(#:phases
;;        (modify-phases %standard-phases
;;          (add-after 'unpack 'make-git-checkout-writable
;;            (lambda _
;;              (for-each make-file-writable (find-files "."))
;;              #t))
;;          (replace 'configure
;;            (lambda* (#:key outputs #:allow-other-keys)
;;              (let* ((out (assoc-ref outputs "out"))
;;                     (mandir (string-append out "/share/man"))
;;                     (browser "icecat -remote \"OpenURL(%s,new-tab)\""))
;;                (invoke "./configure"
;;                        "-prefix" out
;;                        "-mandir" mandir
;;                        "-browser" browser
;;                        "-coqide" "opt"))))
;;          (replace 'build
;;            (lambda _
;;              (invoke "make"
;;                      "-j" (number->string (parallel-job-count))
;;                      "world")))
;;          (delete 'check)
;;          (add-after 'install 'check
;;            (lambda _
;;              (with-directory-excursion "test-suite"
;;                ;; These two tests fail.
;;                ;; This one fails because the output is not formatted as expected.
;;                (delete-file-recursively "coq-makefile/timing")
;;                ;; This one fails because we didn't build coqtop.byte.
;;                (delete-file-recursively "coq-makefile/findlib-package")
;;                (invoke "make")))))))
;;     (home-page "https://coq.inria.fr")
;;     (synopsis "Proof assistant for higher-order logic")
;;     (description
;;      "Coq is a proof assistant for higher-order logic, which allows the
;; development of computer programs consistent with their formal specification.
;; It is developed using Objective Caml and Camlp5.")
;;     ;; The code is distributed under lgpl2.1.
;;     ;; Some of the documentation is distributed under opl1.0+.
;;     (license (list license:lgpl2.1 license:opl1.0+))))

;; Coq without the coqide
(define-public coq-beta
  (package
    (name "coq-beta")
    (version "8.9+beta1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/coq/coq/archive/V"
                                  version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0yf8zpdynl3z07gl6zgrjq0vk9fivr0d3gr0svmvjrnw0ml03v5z"))))
    (native-search-paths
     (list (search-path-specification
            (variable "COQPATH")
            (files (list "lib/coq/user-contrib")))))
    (build-system ocaml-build-system)
    (inputs
     `(("rsync" ,rsync) ;; for building the test log
       ("python2" ,python-2)
       ("camlp5" ,camlp5)
       ("ocaml-num" ,ocaml-num)
       ("ocaml-ounit" ,ocaml-ounit)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (mandir (string-append out "/share/man"))
                    (browser "icecat -remote \"OpenURL(%s,new-tab)\""))
               (invoke "./configure"
                       "-prefix" out
                       "-mandir" mandir
                       "-browser" browser
                       "-coqide" "no"))))
         (replace 'build
           (lambda _
             (invoke "make"
                     "-j" (number->string (parallel-job-count))
                     "world")))
         (delete 'check)
         (add-after 'install 'check
           (lambda _
             (with-directory-excursion "test-suite"
               ;; These two tests fail.
               ;; This one fails because the output is not formatted as expected.
               (delete-file-recursively "coq-makefile/timing")
               ;; This one fails because we didn't build coqtop.byte.
               (delete-file-recursively "coq-makefile/findlib-package")
               (invoke "make" "PRINT_LOGS=1")))))))
    (home-page "https://coq.inria.fr")
    (synopsis "Proof assistant for higher-order logic")
    (description
     "Coq is a proof assistant for higher-order logic, which allows the
development of computer programs consistent with their formal specification.
It is developed using Objective Caml and Camlp5.")
    ;; The code is distributed under lgpl2.1.
    ;; Some of the documentation is distributed under opl1.0+.
    (license (list lgpl2.1 opl1.0+))))

;; for coq shell
;; python-sphinx python-sphinx-rtd-theme
