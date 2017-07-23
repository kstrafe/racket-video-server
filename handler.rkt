#lang racket

(provide blog-dispatch file-not-found)

(require (for-syntax racket/list)
         (for-syntax racket/pretty)
         web-server/dispatch
         web-server/servlet
         web-server/servlet-env
         )

(require "settings.rkt")

(define (serve-index req)
  (serve-post req default-video))

(define (get-random-webm)
  (with-output-to-string (lambda ()
                           (system/exit-code "/usr/bin/env bash -c 'find music -maxdepth 1 -name \"*.webm\" -type f | shuf | head -n 1 | sed s/^music//'"))))

(define (get-random-page)
  (get-random-webm))

(define (serve-post req post)
  (if (not (file-exists? (string-append "music/" post)))
    (redirect-to (get-random-page))
    (response/xexpr
      #:preamble #"<!DOCTYPE html>"
      `(html
        (head
          (meta ([charset "UTF-8"]))
          (meta ([name "viewport"] [content "width=device-width,maximum-scale=1,minimum-scale=1"]))
          (link ([rel "icon"] [type "image/png"] [href "/images/musings_symbol_16.png"]))
          (link ([rel "icon"] [type "image/png"] [href "/images/musings_symbol_32.png"]))
          (link ([rel "icon"] [type "image/png"] [href "/images/musings_symbol_64.png"]))
          (link ([rel "stylesheet"] [type "text/css"] [href "/css/reset.css"]))
          (style
            "button { background: rgba(32, 40, 45, 0.3); border: 1px solid #1C252B; color: lightgrey; font-size: 1em; height: 100%; left: 50%; position: relative; transform: translate(-50%, 0); width: 100%; }
            button:hover { cursor: pointer; }
            .blog { background-image: url(\"/images/sharding.jpg\"); background-size: 100%; background-repeat: y; height: 100vh; position: relative; }
            .video { height: 88vh; }
            .bottom { color: white; font-family: arial; height: 10vh; margin-bottom: 1vh; margin-top: 1vh; margin-left: 1vw; margin-right: 1vw; }")
          (title "Music")
          (body ([class "blog"])
                (div ([class "video"])
                     (video ([id "video"] [width "100%"] [height "100%"] [onclick "toggle_pause();"] [autoplay ""] [controls ""])
                            (source ((src ,(string-append "/music/" post)) (type "video/webm")))))
                (script ([type "text/javascript"])
                        "document.getElementById('video').addEventListener('ended', ended, false);
                        function ended(handle) {
                            history.pushState({
                              prevUrl: window.location.href
                            }, 'Next page', \"/random\");
                            history.go();
                        }
                        function toggle_pause() {
                            if (document.getElementById('video').paused) {
                               document.getElementById('video').play();
                            } else {
                               document.getElementById('video').pause();
                            }
                        }")
                (div ([class "bottom"])
                     (button ([type "button"] [onclick "ended();"]) "Next (random)"))))))))

(define-values (blog-dispatch blog-url)
  (dispatch-rules
    (("random") (lambda _ (redirect-to (get-random-page))))
    (((string-arg)) serve-post)
    (else (lambda _ (redirect-to default-video)))))

(define (file-not-found req)
  (redirect-to default-video))
