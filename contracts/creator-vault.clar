;; Basic CreatorVault Contract
;; Simplified tip jar for creators

;; ==============================================
;; ERROR CONSTANTS
;; ==============================================

(define-constant ERR-CREATOR-NOT-FOUND (err u1001))
(define-constant ERR-CREATOR-ALREADY-EXISTS (err u1002))
(define-constant ERR-INVALID-AMOUNT (err u1003))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1004))
(define-constant ERR-TRANSFER-FAILED (err u1006))

;; ==============================================
;; DATA STRUCTURES
;; ==============================================

;; Creator profiles
(define-map creators
  principal
  {
    name: (string-ascii 100),
    bio: (string-ascii 500),
    total-tips: uint,
    tip-count: uint,
    balance: uint
  }
)

;; Global counters
(define-data-var total-tips uint u0)
(define-data-var total-volume uint u0)

;; ==============================================
;; CORE FUNCTIONS
;; ==============================================

(define-public (register-creator 
  (name (string-ascii 100)) 
  (bio (string-ascii 500)))
  (begin
    (asserts! (is-none (map-get? creators tx-sender)) ERR-CREATOR-ALREADY-EXISTS)
    (asserts! (> (len name) u0) ERR-INVALID-AMOUNT)

    (map-set creators tx-sender {
      name: name,
      bio: bio,
      total-tips: u0,
      tip-count: u0,
      balance: u0
    })

    (ok true)
  )
)

(define-public (tip-creator (recipient principal) (amount uint))
  (let (
    (creator-info (unwrap! (map-get? creators recipient) ERR-CREATOR-NOT-FOUND))
  )
    (begin
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! (not (is-eq tx-sender recipient)) ERR-INVALID-AMOUNT)

      ;; Transfer STX to contract for creator
      (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) ERR-TRANSFER-FAILED)

      ;; Update creator stats
      (map-set creators recipient (merge creator-info {
        total-tips: (+ (get total-tips creator-info) amount),
        tip-count: (+ (get tip-count creator-info) u1),
        balance: (+ (get balance creator-info) amount)
      }))

      ;; Update global stats
      (var-set total-tips (+ (var-get total-tips) u1))
      (var-set total-volume (+ (var-get total-volume) amount))

      (ok true)
    )
  )
)

(define-public (withdraw-funds (amount uint))
  (let (
    (creator-info (unwrap! (map-get? creators tx-sender) ERR-CREATOR-NOT-FOUND))
  )
    (begin
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! (>= (get balance creator-info) amount) ERR-INSUFFICIENT-BALANCE)

      ;; Update balance
      (map-set creators tx-sender (merge creator-info {
        balance: (- (get balance creator-info) amount)
      }))

      ;; Transfer from contract to creator
      (unwrap! (as-contract (stx-transfer? amount tx-sender tx-sender)) ERR-TRANSFER-FAILED)

      (ok true)
    )
  )
)

;; ==============================================
;; READ-ONLY FUNCTIONS
;; ==============================================

(define-read-only (get-creator-info (creator principal))
  (ok (unwrap! (map-get? creators creator) ERR-CREATOR-NOT-FOUND))
)

(define-read-only (get-creator-balance (creator principal))
  (let ((creator-info (unwrap! (map-get? creators creator) ERR-CREATOR-NOT-FOUND)))
    (ok (get balance creator-info))
  )
)

(define-read-only (get-tip-stats)
  (ok {
    total-volume: (var-get total-volume),
    total-tips: (var-get total-tips)
  })
)