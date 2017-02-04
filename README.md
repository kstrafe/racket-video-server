## Racket-Blog ##

Run `main.rkt`. Settings are located in main.
Put SSL keys as `private-key.pem` and `server-cert.pem` in the same folder as `main.rkt`.
If you have no SSL certificates, set (#:ssl? #f).

Put posts in `htdocs/pages`. This will be `eval`d by Racket.
