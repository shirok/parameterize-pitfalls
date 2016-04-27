;; -*- coding:utf-8 -*-

;;; 実装例5

;; これは例3までと同じ
(define (make-parameter init)
  (case-lambda
    [() init]                 ; 引数なしの時は現在値を返す
    [(newval)
     (begin0 init             ; 引数ありの時はそれを新たな現在値にして元の値を返す
       (set! init newval))]))

;; 例4の問題をfix

(define-syntax parameterize
  (syntax-rules ()
    [(_ (binding ...) body ...)
     (%parameterize (binding ...) () () () () (body ...))]))

(define-syntax %parameterize
  (syntax-rules ()
    [(_ () (param ...) (val ...) (ptmp ...) (vtmp ...) (body ...))
     (let ((ptmp param) ...
           (vtmp val) ...)
       (dynamic-wind
         (^[] (set! vtmp (ptmp vtmp)) ...)
         (^[] body ...)
         (^[] (set! vtmp (ptmp vtmp)) ...)))]
    [(_ ((param val) . rest) (p ...) (v ...) (pt ...) (vt ...) bodies)
     (%parameterize rest (p ... param) (v ... val)
                    (pt ... ptmp) (vt ... vtmp) bodies)]))

#|
;;; 展開例

gosh> (macroexpand-all '(parameterize ((a 3)(b 5)) (list a b)))
(letrec ((ptmp.0 a)
         (ptmp.1 b)
         (vtmp.2 '3)
         (vtmp.3 '5))
  (dynamic-wind
    (lambda ()
      (begin (set! vtmp.2 (ptmp.0 vtmp.2)) (set! vtmp.3 (ptmp.1 vtmp.3))))
    (lambda ()
      (list a b))
    (lambda ()
      (begin (set! vtmp.2 (ptmp.0 vtmp.2)) (set! vtmp.3 (ptmp.1 vtmp.3))))))

|#


#|
;;; 実行例

(define special (make-parameter 1))

(define (get-special) (special))

(parameterize ((special 3))
  (set! special string->number))
;; => errorにならない


|#



