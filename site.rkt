#lang racket

[provide generate-list]

[define generate-list `(ul ,@[map (lambda (x) `(li ,x)) [list "hello" "you" "are" "here"]])]
