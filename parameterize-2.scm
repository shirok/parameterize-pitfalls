;; -*- coding:utf-8 -*-

;;; 実装例2

;; これは例1と同じ
(define (make-parameter init)
  (case-lambda
    [() init]                 ; 引数なしの時は現在値を返す
    [(newval)
     (begin0 init             ; 引数ありの時はそれを新たな現在値にして元の値を返す
       (set! init newval))]))

(define-syntax parameterize
  (syntax-rules ()
    [(_ ((param val) ...) body ...)
     (let ([params (list param ...)]   ;paramのリスト
           [vals   (list val ...)]     ;valのリスト
           [saves  #f])
       (dynamic-wind
         (^[] (set! saves (map (^[p v] (p v)) params vals)))
         (^[] body ...)
         (^[] (for-each (^[p v] (p v)) params saves))))]))
#|
;;; 実行例

(define special (make-parameter 1))

(define (get-special) (special))

;; 今度はこれもうまくいく

(define cc #f)

(parameterize ((special 3))
  (call/cc (lambda (c) (set! cc c)))
  (get-special))
;; => 3

(cc #f)
;; => 3

;; しかし…

(parameterize ((special 3))
  (special 5)          ; special の値を変更
  (call/cc (lambda (c) (set! cc c)))
  (get-special))
;; => 5

(cc #f)
;; => 3  ; 5であるべき

|#


