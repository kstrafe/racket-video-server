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
        (meta ([charset "UTF-8"]))
        (meta ([name "viewport"] [content "width=device-width,maximum-scale=1,minimum-scale=1"]))
        (script ([type "text/x-mathjax-config"])
          "MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});"
        )
        (script ([type "text/javascript"] [async ""] [src "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML"])
        )
        (link ((rel "stylesheet") (type "text/css") (href "/css/main.css")))
        (title ,post))
      (body ([class "blog"])
        (div ((class "table"))
          (div ([class "small table-column"]))
          (div ([class "auto table-column"]))
          (div ([class "tiny table-column"]))
          (div ([class "small table-column"]))
          (div ((class "cell"))
            (ul
              ,@(compute-sidebar)
            )
          )
          (div ((class "cell"))
            (h1 ,post)
            ,@(load-page post))
          (div ((class "cell")))
          (div ((class "cell"))
            (div ([id "disqus_thread"]))
            (script
              "/**
              *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
              *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables*/
              /*
              var disqus_config = function () {
                this.page.url = \"krs\";  // Replace PAGE_URL with your page's canonical URL variable
                this.page.identifier = \"" ,post \""; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
              };
              */
              (function() { // DON'T EDIT BELOW THIS LINE
                var d = document, s = d.createElement('script');
                s.src = '//evo-1.disqus.com/embed.js';
                s.setAttribute('data-timestamp', +new Date());
                (d.head || d.body).appendChild(s);
              })();"
            )
            (noscript "Please enable JavaScript to view the " (a ([href "https://disqus.com/?ref_noscript"]) "comments powered by Disqus."))
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
