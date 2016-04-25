;; -*- coding:utf-8 -*-

;;; 実装例5

;; parameter手続きのインタフェースを変更
;;  (proc)                  => 現在の値を返す
;;  (proc newval)           => newvalを新しい値とし、以前の値を返す
;;  (proc newval something) => newvalをconverter手続きを通さずに直接セット
;; 3番目は内部的に使う
(define (make-parameter init :optional (converter identity))
  (let1 val (converter init)
    (case-lambda
      [() val]
      [(newval)   (begin0 val (set! val (converter newval)))]
      [(newval _) (begin0 val (set! val newval))])))

(define-syntax parameterize
  (syntax-rules ()
    [(_ ((param val) ...) body ...)
     (let* ([params (list param ...)]   ;paramのリスト
            [vals   (list val ...)]     ;valのリスト
            [saves  #f])
       (dynamic-wind
         (^[] (if saves
                (set! saves (map (^[p v] (p v #t)) params saves))
                (set! saves (map (^[p v] (p v)) params vals))))
         (^[] body ...)
         (^[] (set! saves (map (^[p v] (p v #t)) params saves)))))]))
#|
;;; 実行例

;; 今度はok
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

;; まずい例
(define a (make-parameter 1 (^x (unless (number? x) (error "!!")) x)))
(define b (make-parameter 2 (^x (unless (number? x) (error "!!")) x)))

(parameterize ((a 10) (b 'abc)) (list a b))
;;=> error

(a)
;;=> 10 ; 1に戻ってない

|#


