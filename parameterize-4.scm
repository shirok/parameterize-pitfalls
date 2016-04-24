;; -*- coding:utf-8 -*-

;;; 実装例4

;; converter手続きを追加
(define (make-parameter init . opts)
  (let* ((converter (if (null? opts) values (car opts)))
         (val (converter init)))
    (lambda arg
      (if (null? arg)
        val
        (let ((oldval val))
          (set! val (converter (car arg)))
          oldval)))))

;; これは例3と同じ
(define-syntax parameterize
  (syntax-rules ()
    ((_ ((param val) ...) body ...)
     (let* ((params (list param ...))   ;paramのリスト
            (vals   (list val ...)))    ;valのリスト
       (dynamic-wind
         (lambda () (set! vals (map (lambda (p v) (p v)) params vals)))
         (lambda () body ...)
         (lambda () (set! vals (map (lambda (p v) (p v)) params vals))))))))
#|
;;; 実行例

;; srfi-39 の例
(define prompt
  (make-parameter
   ">"
   (lambda (x)
     (if (string? x)
       x
       (with-output-to-string (lambda () (write x)))))))

(prompt)
;;=> ">"

(parameterize ((prompt '$))
  (prompt))
;;=> "$"


;; 妙な例
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
;;=> -5  ; 5になるべき


|#


