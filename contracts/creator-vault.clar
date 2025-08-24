;; CreatorVault Core Infrastructure - Clarity v3
;; Enhanced Decentralized Creator Economy Platform

;; ==============================================
;; CREATOR VAULT CONTRACT 
;; ==============================================

;; ==============================================
;; ERROR CONSTANTS
;; ==============================================

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-CREATOR-NOT-FOUND (err u1001))
(define-constant ERR-CREATOR-ALREADY-EXISTS (err u1002))
(define-constant ERR-INVALID-AMOUNT (err u1003))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1004))
(define-constant ERR-INVALID-INPUT (err u1005))
(define-constant ERR-TRANSFER-FAILED (err u1006))
(define-constant ERR-PLATFORM-FEE-FAILED (err u1007))

;; ==============================================
;; DATA STRUCTURES
;; ==============================================

;; Creator profile information
(define-map creators
  principal
  {
    name: (string-ascii 100),
    bio: (string-ascii 500),
    links: (list 5 (string-ascii 100)),
    total-tips: uint,
    tip-count: uint,
    created-at: uint,
    verified: bool,
    balance: uint
  }
)

;; Individual tip records
(define-map tips
  uint ;; tip-id
  {
    tipper: principal,
    recipient: principal,
    amount: uint,
    message: (optional (string-ascii 280)),
    timestamp: uint,
    block-height: uint
  }
)

;; Platform configuration
(define-data-var platform-fee-rate uint u150) ;; 1.5% in basis points
(define-data-var platform-treasury principal tx-sender)
(define-data-var contract-owner principal tx-sender)
(define-data-var tip-counter uint u0)
(define-data-var total-platform-volume uint u0)
(define-data-var total-platform-tips uint u0)

;; Emergency pause mechanism
(define-data-var contract-paused bool false)

;; ==============================================
;; PRIVATE FUNCTIONS
;; ==============================================

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u10000)
)

(define-private (calculate-creator-amount (amount uint))
  (- amount (calculate-platform-fee amount))
)

(define-private (is-valid-string (input (string-ascii 500)))
  (> (len input) u0)
)

(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

(define-private (is-platform-treasury)
  (is-eq tx-sender (var-get platform-treasury))
)

;; ==============================================
;; ADMIN FUNCTIONS
;; ==============================================

(define-public (set-platform-fee (new-rate uint))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-rate u500) ERR-INVALID-INPUT) ;; Max 5%
    (ok (var-set platform-fee-rate new-rate))
  )
)

(define-public (set-platform-treasury (new-treasury principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (var-set platform-treasury new-treasury))
  )
)

(define-public (pause-contract)
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-paused true))
  )
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-paused false))
  )
)

;; ==============================================
;; CORE CREATOR FUNCTIONS
;; ==============================================

(define-public (register-creator 
  (name (string-ascii 100)) 
  (bio (string-ascii 500)) 
  (links (list 5 (string-ascii 100))))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? creators tx-sender)) ERR-CREATOR-ALREADY-EXISTS)
    (asserts! (is-valid-string name) ERR-INVALID-INPUT)
    (asserts! (is-valid-string bio) ERR-INVALID-INPUT)
    
    (map-set creators tx-sender {
      name: name,
      bio: bio,
      links: links,
      total-tips: u0,
      tip-count: u0,
      created-at: stacks-block-height,
      verified: false,
      balance: u0
    })
    
    (ok true)
  )
)

(define-public (update-creator-profile 
  (name (string-ascii 100)) 
  (bio (string-ascii 500)) 
  (links (list 5 (string-ascii 100))))
  (let ((creator-info (unwrap! (map-get? creators tx-sender) ERR-CREATOR-NOT-FOUND)))
    (begin
      (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)
      (asserts! (is-valid-string name) ERR-INVALID-INPUT)
      (asserts! (is-valid-string bio) ERR-INVALID-INPUT)
      
      (map-set creators tx-sender (merge creator-info {
        name: name,
        bio: bio,
        links: links
      }))
      
      (ok true)
    )
  )
)

(define-public (tip-creator 
  (recipient principal) 
  (amount uint) 
  (message (optional (string-ascii 280))))
  (let (
    (creator-info (unwrap! (map-get? creators recipient) ERR-CREATOR-NOT-FOUND))
    (platform-fee (calculate-platform-fee amount))
    (creator-amount (calculate-creator-amount amount))
    (new-tip-id (+ (var-get tip-counter) u1))
  )
    (begin
      (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! (not (is-eq tx-sender recipient)) ERR-INVALID-INPUT)
      
      ;; Transfer platform fee to treasury
      (if (> platform-fee u0)
        (unwrap! (stx-transfer? platform-fee tx-sender (var-get platform-treasury)) ERR-TRANSFER-FAILED)
        true
      )
      
      ;; Add creator amount to their balance (don't transfer yet, let them withdraw)
      (map-set creators recipient (merge creator-info {
        total-tips: (+ (get total-tips creator-info) creator-amount),
        tip-count: (+ (get tip-count creator-info) u1),
        balance: (+ (get balance creator-info) creator-amount)
      }))
      
      ;; Record the tip
      (map-set tips new-tip-id {
        tipper: tx-sender,
        recipient: recipient,
        amount: creator-amount,
        message: message,
        timestamp: stacks-block-height,
        block-height: stacks-block-height
      })
      
      ;; Update global stats
      (var-set tip-counter new-tip-id)
      (var-set total-platform-volume (+ (var-get total-platform-volume) amount))
      (var-set total-platform-tips (+ (var-get total-platform-tips) u1))
      
      (ok new-tip-id)
    )
  )
)

(define-public (withdraw-funds (amount uint))
  (let (
    (creator-info (unwrap! (map-get? creators tx-sender) ERR-CREATOR-NOT-FOUND))
    (creator tx-sender)
  )
    (begin
      (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! (>= (get balance creator-info) amount) ERR-INSUFFICIENT-BALANCE)
      
      ;; Update creator balance
      (map-set creators creator (merge creator-info {
        balance: (- (get balance creator-info) amount)
      }))
      
      ;; Transfer STX to creator from contract
      (unwrap! (as-contract (stx-transfer? amount tx-sender creator)) ERR-TRANSFER-FAILED)
      
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

(define-read-only (get-tip-info (tip-id uint))
  (ok (unwrap! (map-get? tips tip-id) ERR-INVALID-INPUT))
)

(define-read-only (get-tip-stats)
  (ok {
    total-volume: (var-get total-platform-volume),
    total-tips: (var-get total-platform-tips),
    active-creators: u0 ;; TODO: implement counter for registered creators
  })
)

(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)

(define-read-only (get-platform-treasury)
  (var-get platform-treasury)
)

(define-read-only (is-creator-registered (creator principal))
  (is-some (map-get? creators creator))
)

(define-read-only (get-contract-info)
  {
    owner: (var-get contract-owner),
    treasury: (var-get platform-treasury),
    fee-rate: (var-get platform-fee-rate),
    paused: (var-get contract-paused),
    total-tips: (var-get total-platform-tips),
    total-volume: (var-get total-platform-volume)
  }
)