;;
;; This file is included by test.scm multiple times, for
;; we use different definitions of parameterize macro for each step.
;;

(define (test-1a-basic) ; this one always succeeds
  (define special (make-parameter 1))
  (define (get-special) (special))
  (test* "test-1a-basic" '(2 1)
         (let1 x (parameterize ((special 2))
                   (get-special))
           (list x (get-special)))))

(define (test-1b-restart expect)
  (define special (make-parameter 1))
  (define (get-special) (special))
  (define cc #f)
  (test* "test-1b-restart" expect
         (let1 a (parameterize ((special 3))
                   (call/cc (lambda (c) (set! cc c)))
                   (get-special))
           (if cc
             (let1 c cc (set! cc #f) (c #f))
             a))))

(define (test-2a-set+restart expect)
  (define special (make-parameter 1))
  (define (get-special) (special))
  (define cc #f)
  (test* "test-2a-set+restart" expect
         (let1 a (parameterize ((special 3))
                   (special 5)
                   (call/cc (lambda (c) (set! cc c)))
                   (get-special))
           (if cc
             (let1 c cc (set! cc #f) (c #f))
             a))))
