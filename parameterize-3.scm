;; -*- coding:utf-8 -*-

;;; 実装例3

;; これは例1,2と同じ
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
            [vals   (list val ...)])    ;valのリスト 兼 現在の値のセーブ
       (dynamic-wind
         (^[] (set! vals (map (^[p v] (p v)) params vals)))
         (^[] body ...)
         (^[] (set! vals (map (^[p v] (p v)) params vals)))))]))

#|
;;; 実行例

(define special (make-parameter 1))

(define (get-special) (special))

;; okになった

(parameterize ((special 3))
  (special 5)          ; special の値を変更
  (call/cc (lambda (c) (set! cc c)))
  (get-special))
;; => 5

(cc #f)
;; => 5

(get-special)
;; => 1

|#


