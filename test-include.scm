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

(define (test-1b-restart ok)
  (define special (make-parameter 1))
  (define (get-special) (special))
  (define cc #f)
  (test* #"test-1b-restart (~ok)" (if (eq? ok 'ok) 3 1)
         (let1 a (parameterize ((special 3))
                   (call/cc (lambda (c) (set! cc c)))
                   (get-special))
           (if cc
             (let1 c cc (set! cc #f) (c #f))
             a))))

(define (test-2a-set+restart ok)
  (define special (make-parameter 1))
  (define (get-special) (special))
  (define cc #f)
  (test* #"test-2a-set+restart (~ok)" (if (eq? ok 'ok) 5 3)
         (let1 a (parameterize ((special 3))
                   (special 5)
                   (call/cc (lambda (c) (set! cc c)))
                   (get-special))
           (if cc
             (let1 c cc (set! cc #f) (c #f))
             a))))

(define (test-4a-converter)
  (define prompt
    (make-parameter
     '>
     (lambda (x)
       (if (string? x)
         x
         (with-output-to-string (lambda () (write x)))))))
  (test* "test-4a-converter" ">" (prompt))
  (test* "test-4a-converter" "$" (parameterize ((prompt '$))
                                   (prompt))))

(define (test-4b-converter ok)
  (define special
    (make-parameter 1 -))
  (define cc #f)
  (test* #"test-4b-converter (~ok)" (if (eq? ok 'ok) '(5 5) '(5 -5))
         (let1 r '()
           (push! r (parameterize ((special -5))
                      (call/cc (lambda (c) (set! cc c)))
                      (special)))
           (if cc
             (let1 c cc (set! cc #f) (c #f))
             (reverse r)))))

(define (test-5a-rollback ok)
  (define a (make-parameter 1 (^x (unless (number? x) (error "!!")) x)))
  (define b (make-parameter 2 (^x (unless (number? x) (error "!!")) x)))

  (guard (e [else #f]) ; ignore error
    (parameterize ((a 10) (b 'abc)) (list a b)))

  (test* #"test-5a-rollback (~ok)" (if (eq? ok 'ok) 1 10) (a)))
