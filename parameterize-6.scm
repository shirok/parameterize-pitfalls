;; -*- coding:utf-8 -*-

;;; 実装例6

(define *env* '())

(define (%lookup param) ; returns (<parameter> . <current-value>) or #f
  (let loop ([frames *env*])
    (cond [(null? frames) #f]
          [(find (^[pv] (eq? (car pv) param)) (car frames))]
          [else (loop (cdr frames))])))

(define (make-parameter init . opts)
  (let* ([converter (if (null? opts) values (car opts))]
         [global-value (converter init)])
    (rec (self . arg)
      (if (null? arg)
        (if-let1 pv (%lookup self) (cdr pv) global-value)
        (let1 newval (converter (car arg))
          (if-let1 pv (%lookup self)
            (begin0 (cdr pv) (set! (cdr pv) newval))
            (begin0 global-value (set! global-value newval))))))))

(define-syntax parameterize
  (syntax-rules ()
    [(_ ((param val) ...) body ...)
     (let* ([params (list param ...)]
            [vals   (list val ...)]
            [frame  (map list params)]
            [restart #f])
       (dynamic-wind
         (^[]
           (push! *env* frame)
           (unless restart
             (for-each (^[p v] (p v)) params vals)))
         (^[] body ...)
         (^[]
           (set! restart #t)
           (pop! *env*))))]))
#|
;;; 実行例

(define special
  (make-parameter 1 -))

(special)
;;=> -1

(parameterize ((special -5))
  (special))
;;=> 5


(define cc #f)

(parameterize ((special -5))
  (call/cc (lambda (c) (set! cc c)))
  (special))
;;=> 5

(cc #f)
;;=> 5

|#


