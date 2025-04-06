;; Timestamp Verification Contract
;; Establishes priority of design creation

(define-map design-timestamps
  { design-id: uint }
  {
    timestamp: uint,
    block-height: uint
  }
)

(define-read-only (get-timestamp (design-id uint))
  (map-get? design-timestamps { design-id: design-id })
)

(define-public (record-timestamp (design-id uint))
  (let
    (
      (current-block (- block-height u1))
      (timestamp (get-block-info? time current-block))
    )
    (asserts! (is-some timestamp) (err u1))

    (map-set design-timestamps
      { design-id: design-id }
      {
        timestamp: (unwrap! timestamp (err u2)),
        block-height: current-block
      }
    )
    (ok true)
  )
)

(define-read-only (verify-timestamp (design-id uint) (claimed-timestamp uint))
  (let
    (
      (timestamp-data (map-get? design-timestamps { design-id: design-id }))
    )
    (asserts! (is-some timestamp-data) (err u1))
    (ok (is-eq (get timestamp (unwrap! timestamp-data (err u2))) claimed-timestamp))
  )
)
