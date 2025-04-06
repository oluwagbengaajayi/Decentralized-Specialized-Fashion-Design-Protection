;; Design Registration Contract
;; Records details of original fashion creations

(define-data-var last-design-id uint u0)

(define-map designs
  { design-id: uint }
  {
    owner: principal,
    name: (string-ascii 100),
    description: (string-ascii 500),
    image-uri: (string-ascii 256),
    created-at: uint,
    status: (string-ascii 20)
  }
)

(define-read-only (get-last-design-id)
  (var-get last-design-id)
)

(define-read-only (get-design (design-id uint))
  (map-get? designs { design-id: design-id })
)

(define-public (register-design
    (name (string-ascii 100))
    (description (string-ascii 500))
    (image-uri (string-ascii 256)))
  (let
    (
      (new-design-id (+ (var-get last-design-id) u1))
    )
    (map-set designs
      { design-id: new-design-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        image-uri: image-uri,
        created-at: block-height,
        status: "active"
      }
    )
    (var-set last-design-id new-design-id)
    (ok new-design-id)
  )
)

(define-public (update-design-status
    (design-id uint)
    (new-status (string-ascii 20)))
  (let
    (
      (design (map-get? designs { design-id: design-id }))
    )
    (asserts! (is-some design) (err u1))
    (asserts! (is-eq (get owner (unwrap! design (err u2))) tx-sender) (err u3))
    (map-set designs
      { design-id: design-id }
      (merge (unwrap! design (err u4)) { status: new-status })
    )
    (ok true)
  )
)
