#! /usr/bin/env racket
#lang racket

(require reloadable
         web-server/servlet
         web-server/servlet-env)

(define handler (reloadable-entry-point->procedure (make-reloadable-entry-point 'handler "handler.rkt")))
(define file-not-found (reloadable-entry-point->procedure (make-reloadable-entry-point 'file-not-found "handler.rkt")))

(define (start req)
  (reload!)
  (handler req))

(serve/servlet start
  ; #:ssl?
  #:stateless? #t
  #:listen-ip #f
  #:port 8000
  #:server-root-path (current-directory)
  #:servlet-regexp #px"^/$|^/p/"
  #:command-line? #t
  #:file-not-found-responder file-not-found
  )
