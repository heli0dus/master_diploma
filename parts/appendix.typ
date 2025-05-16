#import "../lib.typ": *
#show: appendix


= Листинг реализации эффектов высшего порядка на Racket <app:A>

#show figure: set block(breakable: true)
#figure([
  ```rkt
  #lang algebraic/racket/base

  (require racket/control)
  (require racket/promise)
  (require algebraic/racket/base/forms)

  (define-syntax-rule ($ tag in after)
    (reset0-at tag
              (let ([y in])
                (shift0-at tag k (after y)))
              )
    )

  (data Throw (Throw)
        Catch (Catch))

  (data Maybe (Just Nothing))

  (define-syntax-rule (send tag op)
    (shift0-at tag k (λ (h) ((h op) (λ (x) ((k x) h))))))

  (define-syntax-rule (handle-ret tag comp ret-clause op-clause)
    (($ tag comp (λ (x) (λ (h) (ret-clause x))) )
    (λ (x) (λ (k) (op-clause x k))))
    )

  (define-syntax-rule (withHandler tag ret-clause op-clause comp) (handle-ret tag comp ret-clause op-clause))

  (define-syntax-rule (withIdHandler tag op-clause comp) (handle-ret tag comp (λ (x) x) op-clause))

  (define-syntax-rule (embed k comp)
    (k (λ () comp))
    )

  (define-syntax-rule (resume k comp)
    (let
        ([x comp])
      (k (λ () x)))
    )

  (define-syntax-rule (edo tag op)
    ((shift0-at tag k (λ (h) ((h op) (λ (x) ((k x) h))))))
    )
  ```
  ],
  caption: [Реализация эффектов высших порядков при помощи ограниченных продолжений]
)
#show figure: set block(breakable: false)