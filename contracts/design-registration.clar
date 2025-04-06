;; Infringement Reporting Contract
;; Tracks unauthorized copying of designs

(define-data-var last-report-id uint u0)

(define-map infringement-reports
  { report-id: uint }
  {
    reporter: principal,
    design-id: uint,
    infringing-party: (string-ascii 100),
    evidence: (string-ascii 256),
    status: (string-ascii 20),
    created-at: uint,
    resolution: (string-ascii 500)
  }
)

(define-map design-reports
  { design-id: uint }
  { report-ids: (list 100 uint) }
)

(define-read-only (get-report (report-id uint))
  (map-get? infringement-reports { report-id: report-id })
)

(define-read-only (get-reports-for-design (design-id uint))
  (map-get? design-reports { design-id: design-id })
)

(define-public (file-infringement-report
    (design-id uint)
    (infringing-party (string-ascii 100))
    (evidence (string-ascii 256)))
  (let
    (
      (new-report-id (+ (var-get last-report-id) u1))
      (existing-reports (default-to { report-ids: (list) } (map-get? design-reports { design-id: design-id })))
    )
    (map-set infringement-reports
      { report-id: new-report-id }
      {
        reporter: tx-sender,
        design-id: design-id,
        infringing-party: infringing-party,
        evidence: evidence,
        status: "pending",
        created-at: block-height,
        resolution: ""
      }
    )

    (map-set design-reports
      { design-id: design-id }
      { report-ids: (append (get report-ids existing-reports) new-report-id) }
    )

    (var-set last-report-id new-report-id)
    (ok new-report-id)
  )
)

(define-public (update-report-status
    (report-id uint)
    (new-status (string-ascii 20))
    (resolution (string-ascii 500)))
  (let
    (
      (report (map-get? infringement-reports { report-id: report-id }))
    )
    (asserts! (is-some report) (err u1))

    (map-set infringement-reports
      { report-id: report-id }
      (merge (unwrap! report (err u2)) {
        status: new-status,
        resolution: resolution
      })
    )
    (ok true)
  )
)
