(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))

(define-map process-workflows
  { workflow-id: uint }
  {
    process-name: (string-ascii 100),
    steps-count: uint,
    cycle-time: uint,
    efficiency-score: uint,
    discovery-date: uint
  }
)

(define-map efficiency-metrics
  { metric-id: uint }
  {
    workflow-id: uint,
    metric-type: (string-ascii 50),
    current-value: uint,
    baseline-value: uint,
    improvement-percent: uint
  }
)

(define-map bottleneck-analysis
  { bottleneck-id: uint }
  {
    workflow-id: uint,
    bottleneck-location: (string-ascii 100),
    delay-hours: uint,
    root-cause: (string-ascii 200),
    recommended-fix: (string-ascii 200)
  }
)

(define-map optimization-opportunities
  { opportunity-id: uint }
  {
    workflow-id: uint,
    optimization-type: (string-ascii 50),
    potential-savings: uint,
    implementation-effort: (string-ascii 30),
    priority: (string-ascii 20)
  }
)

(define-data-var next-workflow-id uint u1)
(define-data-var next-metric-id uint u1)
(define-data-var next-bottleneck-id uint u1)
(define-data-var next-opportunity-id uint u1)

(define-public (discover-process (name (string-ascii 100)) (steps uint) (cycle-time uint) (score uint))
  (let ((workflow-id (var-get next-workflow-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set process-workflows
        { workflow-id: workflow-id }
        {
          process-name: name,
          steps-count: steps,
          cycle-time: cycle-time,
          efficiency-score: score,
          discovery-date: u0
        }
      )
      (var-set next-workflow-id (+ workflow-id u1))
      (ok workflow-id)
    )
  )
)

(define-public (record-efficiency-metric (workflow-id uint) (metric-type (string-ascii 50)) (current uint) (baseline uint) (improvement uint))
  (let ((metric-id (var-get next-metric-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set efficiency-metrics
        { metric-id: metric-id }
        {
          workflow-id: workflow-id,
          metric-type: metric-type,
          current-value: current,
          baseline-value: baseline,
          improvement-percent: improvement
        }
      )
      (var-set next-metric-id (+ metric-id u1))
      (ok metric-id)
    )
  )
)

(define-public (identify-bottleneck (workflow-id uint) (location (string-ascii 100)) (delay uint) (cause (string-ascii 200)) (fix (string-ascii 200)))
  (let ((bottleneck-id (var-get next-bottleneck-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set bottleneck-analysis
        { bottleneck-id: bottleneck-id }
        {
          workflow-id: workflow-id,
          bottleneck-location: location,
          delay-hours: delay,
          root-cause: cause,
          recommended-fix: fix
        }
      )
      (var-set next-bottleneck-id (+ bottleneck-id u1))
      (ok bottleneck-id)
    )
  )
)

(define-public (suggest-optimization (workflow-id uint) (opt-type (string-ascii 50)) (savings uint) (effort (string-ascii 30)) (priority (string-ascii 20)))
  (let ((opportunity-id (var-get next-opportunity-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set optimization-opportunities
        { opportunity-id: opportunity-id }
        {
          workflow-id: workflow-id,
          optimization-type: opt-type,
          potential-savings: savings,
          implementation-effort: effort,
          priority: priority
        }
      )
      (var-set next-opportunity-id (+ opportunity-id u1))
      (ok opportunity-id)
    )
  )
)

(define-read-only (get-workflow (workflow-id uint))
  (map-get? process-workflows { workflow-id: workflow-id })
)

(define-read-only (get-bottleneck (bottleneck-id uint))
  (map-get? bottleneck-analysis { bottleneck-id: bottleneck-id })
)
