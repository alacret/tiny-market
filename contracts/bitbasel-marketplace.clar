(use-trait nft-trait .traits.sip009-nft-trait)
(use-trait ft-trait .traits.sip010-ft-trait)

;; main errors
(define-constant err-owner-only (err u1000))

;; listing errors
(define-constant err-expiry-in-past (err u2000))
(define-constant err-price-zero (err u2001))

;; cancelling and fulfilling errors
(define-constant err-unknown-listing (err u3000))
(define-constant err-unauthorised (err u3001))
(define-constant err-listing-expired (err u3002))
(define-constant err-nft-asset-mismatch (err u3003))
(define-constant err-payment-asset-mismatch (err u3004))
(define-constant err-maker-taker-equal (err u3005))
(define-constant err-unintended-taker (err u3006))
(define-constant err-asset-contract-not-whitelisted (err u3007))
(define-constant err-payment-contract-not-whitelisted (err u3008))

;; variables
(define-map listings
	uint
	{
		maker: principal,
		taker: (optional principal),
		token-id: uint,
		nft-asset-contract: principal,
		expiry: uint,
		price: uint,
		payment-asset-contract: (optional principal)
	}
)
(define-data-var listing-nonce uint u0)
(define-data-var contract-paused bool true)
(define-map whitelisted-asset-contracts principal bool)
(define-data-var contract-owner principal tx-sender)

;; owner feature
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)
(define-read-only (is-contract-owner)
	(ok (is-eq (var-get contract-owner) tx-sender))
)
(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(asserts! (is-eq (var-get contract-owner) tx-sender) err-owner-only)
		(ok (var-set contract-owner new-contract-owner))
	)
)

;; paused feature
(define-read-only (get-contract-paused)
	(ok (var-get contract-paused))
)
(define-read-only (is-contract-paused)
	(ok (is-eq (var-get contract-paused) true))
)
(define-public (set-paused (new-contract-paused bool))
	(begin
		(asserts! (is-eq (var-get contract-owner) tx-sender) err-owner-only)
		(ok (var-set contract-paused new-contract-paused))
	)
)

;; whitelisted feature
(define-read-only (is-whitelisted (asset-contract principal))
	(default-to false (map-get? whitelisted-asset-contracts asset-contract))
)

(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
	(begin
		(asserts! (is-eq (var-get contract-owner) tx-sender) err-owner-only)
		(ok (map-set whitelisted-asset-contracts asset-contract whitelisted))
	)
)

(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
	(contract-call? token-contract transfer token-id sender recipient)
)

(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
	(contract-call? token-contract transfer amount sender recipient none)
)