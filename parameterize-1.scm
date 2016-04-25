;; -*- coding:utf-8 -*-

;;; 実装例1
(define (make-parameter init)
  (case-lambda
    [() init]                 ; 引数なしの時は現在値を返す
    [(newval)
     (begin0 init             ; 引数ありの時はそれを新たな現在値にして元の値を返す
       (set! init newval))]))

(define-syntax parameterize
  (syntax-rules ()
    [(_ ((param val) ...) body ...)
     (let* ([params (list param ...)]   ;paramのリスト
            [vals   (list val ...)]     ;valのリスト
            [saves  (map (^[p v] (p v)) params vals)]) ;入る前の値を保存
       (dynamic-wind
         (^[] #f)
         (^[] body ...)
         (^[] (for-each (^[p v] (p v)) params saves))))]))

#|
;;; 実行例

(define special (make-parameter 1))

(define (get-special) (special))

(parameterize ((special 2))
  (get-special))
;; => 2

(get-special)
;; => 1

;; うまくいかない例

(define cc #f)

(parameterize ((special 3))
  (call/cc (lambda (c) (set! cc c)))
  (get-special))
;; => 3

(cc #f)
;; => 1  ; 3になるべき
|#


