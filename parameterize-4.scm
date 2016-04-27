;; -*- coding:utf-8 -*-

;;; 実装例4

;; これは例3までと同じ
(define (make-parameter init)
  (case-lambda
    [() init]                 ; 引数なしの時は現在値を返す
    [(newval)
     (begin0 init             ; 引数ありの時はそれを新たな現在値にして元の値を返す
       (set! init newval))]))

;; 値のセーブをリストにするのではなく、各パラメータごとに一時変数を作る方式

(define-syntax parameterize
  (syntax-rules ()
    [(_ (binding ...) body ...)
     (%parameterize (binding ...) () () () (body ...))]))

(define-syntax %parameterize
  (syntax-rules ()
    [(_ () (param ...) (val ...) (tmp ...) (body ...))
     (let ((tmp val) ...)
       (dynamic-wind
         (^[] (set! tmp (param tmp)) ...)
         (^[] body ...)
         (^[] (set! tmp (param tmp)) ...)))]
    [(_ ((param val) . rest) (p ...) (v ...) (t ...) bodies)
     (%parameterize rest (p ... param) (v ... val) (t ... tmp) bodies)]))

#|
;;; 展開例

gosh> (macroexpand-all '(parameterize ((a 3)(b 5)) (list a b)))
(letrec ((tmp.0 '3)
         (tmp.1 '5))
  (dynamic-wind
    (lambda ()
      (begin (set! tmp.0 (a tmp.0)) (set! tmp.1 (b tmp.1))))
    (lambda ()
      (list a b))
    (lambda ()
      (begin (set! tmp.0 (a tmp.0)) (set! tmp.1 (b tmp.1))))))
|#


#|
;;; 実行例

(define special (make-parameter 1))

(define (get-special) (special))

(parameterize ((special 3))
  (special 5)          ; special の値を変更
  (call/cc (lambda (c) (set! cc c)))
  (get-special))
;; => 5

(cc #f)
;; => 5

(get-special)
;; => 1

;; ただし、これはうまくいかない
;; 本来、special自身がset!されるような用途は想定していないが、
;; set!されたとしてもエラーになるのはまずい。
;; 正しくやるには、paramも一時変数に束縛する必要がある。
(parameterize ((special 3))
  (set! special string->number))
;; => error

|#



