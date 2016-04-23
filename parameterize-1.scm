;; -*- coding:utf-8 -*-

;;; 実装例1
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
            (vals   (list val ...))     ;valのリスト
            (saves  (map (lambda (p v) (p v)) params vals))) ;入る前の値を保存
       (dynamic-wind
         (lambda () #f)
         (lambda () body ...)
         (lambda () (for-each (lambda (p v) (p v)) params saves)))))))

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


