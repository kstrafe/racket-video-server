#! /usr/bin/env racket
#lang racket

(require reloadable
         web-server/servlet
         web-server/servlet-env)

(define handler (reloadable-entry-point->procedure (make-reloadable-entry-point 'handler "handler.rkt")))

(define (start req)
  (reload!)
  (handler req))

(serve/servlet start
  ; #:ssl?
  #:stateless? #t
  #:listen-ip #f
  #:port 8000
  #:server-root-path "."
  #:extra-files-paths (list (build-path "images"))
  #:servlet-regexp #rx""
  #:command-line? #t)
