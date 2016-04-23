;; -*- coding:utf-8 -*-

;;; 実装例3

;; これは例1,2と同じ
(define (make-parameter init)
  (lambda arg
    (if (null? arg)
      init                     ; 引数なしの時は現在値を返す
      (let ((oldval init))
        (set! init (car arg))  ; 引数ありの時はそれを新たな現在値にして
        oldval))))             ; 以前の値を返す

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


