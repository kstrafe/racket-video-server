#lang racket

(provide file-not-found handler)

(require web-server/dispatch
         web-server/servlet
         web-server/servlet-env)

(define (serve-index req)
  (serve-post req "IndexPage"))

(define p-name "pages")

(define (get-pages)
  (if (directory-exists? p-name)
    (build-path p-name)
    (build-path "htdocs" p-name)))

(define (compute-sidebar)
  (with-handlers
    ((exn?
      (lambda (err)
        '((li "Unable to compute this sidebar due to an inconvenient error")))))
    (map
      (lambda (elems)
        `(li (a
          ((href ,(string-append "/p/" (path->string (file-name-from-path (first elems))))))
          ,(path->string (file-name-from-path (first elems))))))
      (sort
        (map
          (lambda (path) (list path (file-or-directory-modify-seconds path)))
          (sequence->list (in-directory (get-pages))))
        (lambda (e1 e2) (> (second e1) (second e2)))))))

(define (load-page name)
  (with-handlers
    ((exn?
      (lambda (err)
        '((p "This file can not be viewed, either because it does not exist or because it's locked.")))))
    (with-input-from-file
      (build-path (get-pages) name)
      (lambda () (read)))))

(define (serve-post req post)
  (response/xexpr
    #:preamble #"<!DOCTYPE html>"
    `(html
      (head
        (meta ((charset "UTF-8")))
        (link ((rel "stylesheet") (type "text/css") (href "/css/main.css")))
        (title ,post))
      (body
        (div ((class "table"))
          (div ((class "table-row"))
            (div ((class "table-head navigation"))
              (ul
                ,@(compute-sidebar)
              )
            )
            (div ((class "table-head spacing")))
            (div ((class "table-head content"))
              (h1 ,post)
              ,@(load-page post))
            (div ((class "table-head right-spacing")))
          )
        )
        ))))

(define-values (blog-dispatch blog-url)
  (dispatch-rules
    (("p" (string-arg)) serve-post)
    (else serve-index)))

(define (file-not-found req)
  (serve-post req "ErrorNotFound"))

(define (handler req)
  (blog-dispatch req))
