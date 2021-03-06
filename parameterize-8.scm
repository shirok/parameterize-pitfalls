;; -*- coding:utf-8 -*-

;;; 実装例8

;; これは例7と同じ
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
            [saves  #f]
            [restarted #f])
       (dynamic-wind
         (^[] (if restarted
                (set! saves (map (^[p v] (p v #t)) params saves))
                (set! saves (map (^[p] (p)) params)))) ; 初回の値を保存
         (^[]
           (unless restarted  ; 初回のみここで値をセット。エラーが起きたら巻き戻される
             (set! saves (map (^[p v] (p v)) params vals)))
           body ...)
         (^[]
           (set! restarted #t)
           (set! saves (map (^[p v] (p v #t)) params saves)))))]))
#|
;;; 実行例

(define a (make-parameter 1 (^x (unless (number? x) (error "!!")) x)))
(define b (make-parameter 2 (^x (unless (number? x) (error "!!")) x)))

(parameterize ((a 10) (b 'abc)) (list a b))
;;=> error

(a)
;;=> 1  ; ちゃんと戻る
|#


