;; -*- coding:utf-8 -*-

;;; 実装例5

;; parameter手続きのインタフェースを変更
;;  (proc)                  => 現在の値を返す
;;  (proc newval)           => newvalを新しい値とし、以前の値を返す
;;  (proc newval something) => newvalをconverter手続きを通さずに直接セット
;; 3番目は内部的に使う
(define (make-parameter init . opts)
  (let* ((converter (if (null? opts) values (car opts)))
         (val (converter init)))
    (lambda arg
      (cond [(null? arg) val]
            [(null? (cdr arg)) 
             (let ((oldval val))
               (set! val (converter (car arg)))
               oldval)]
            [else
             (let ((oldval val))
               (set! val (car arg))
               oldval)]))))

(define-syntax parameterize
  (syntax-rules ()
    ((_ ((param val) ...) body ...)
     (let* ((params (list param ...))   ;paramのリスト
            (vals   (list val ...))     ;valのリスト
            (saves  #f))
       (dynamic-wind
         (lambda () (if saves
                      (set! saves (map (lambda (p v) (p v #t)) params saves))
                      (set! saves (map (lambda (p v) (p v)) params vals))))
         (lambda () body ...)
         (lambda () (set! saves (map (lambda (p v) (p v #t)) params saves))))))))
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


|#

