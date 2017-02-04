#lang racket

[provide handler]

[require "site.rkt"
         web-server/dispatch
         web-server/servlet
         web-server/servlet-env]

(define (file->bytes path)
  [with-input-from-file path
    [lambda ()
      [read-bytes 2000]]])

(define (serve-image req image)
  [writeln "COOLio"]
  (response/full
    200 #"Ok"
    (current-seconds) #"image/svg+xml"
    empty
    (list (file->bytes [string-append "images/" image]))))

(define (serve-css req filename)
  [writeln "Oowlio"]
  (response/full
    200 #"Ok"
    (current-seconds) #"text/css"
    empty
    (list (file->bytes [string-append "css/" filename]))))

(define (serve-index req)
  (response/xexpr
    #:preamble #"<!DOCTYPE html>"
    `(html
      (head
        (meta ([charset "UTF-8"]))
        (link ([rel "stylesheet"] [type "text/css"] [href "css/main.css"]))
        (title "Evo's Musings"))
      (body
        (div ([class "table"])
          (div ([class "table-row"])
            (div ([class "table-head navigation"])
              (ul
                (li "Makethatmoney")
                (li "Controlthemoney")
                (li "EnsureTheSurvival")
                (li "Transitiveloading in Racket")
                (li "FunctionalUDP")))
            (div ([class "table-head spacing"]))
            (div ([class "table-head content"]) ,@golden)
            (div ([class "table-head spacing"]))
            (div ([class "table-head spacing"]))
            (div ([class "table-head spacing"]))
          )
        )
        ))))

(define-values (blog-dispatch blog-url)
  (dispatch-rules
    [("images" (string-arg)) serve-image]
    [("css" (string-arg)) serve-css]
    [else serve-index]))

(define (handler req)
  (blog-dispatch req))

[define golden [list "hey"]]
