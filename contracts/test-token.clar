
;; Bitbasel
;; <add a description here>

;; SIP900 local trait
(impl-trait .traits.sip009-nft-trait)
;; SIP009 NFT trait on mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8zFVY99RRM50D2JG9.nft-trait.nft-trait)

;; constants
;;
(define-non-fungible-token Bitbasel uint)
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
;; data maps and vars
;;
(define-data-var last-token-id uint u0)
(define-data-var mint-limit uint u5000)
(define-map nft-meta-data uint (string-ascii 80))


(define-private (mint-private (new-owner principal) (data (string-ascii 80)))  
(let ((next-id (+ u1 (var-get last-token-id)))
		(count (var-get last-token-id)))  
	(asserts! (< count (var-get mint-limit)) (err err-no-more-nfts))
	(begin
	(mint-helper new-owner next-id data))))


(define-private (mint-helper (new-owner principal) (next-id uint) (data (string-ascii 80)))  
	(match (nft-mint? Bitbasel next-id new-owner) success
			(begin
				(var-set last-token-id next-id)
				(map-set nft-meta-data next-id data)
				(ok next-id))
			error (err error)))


;; public functions
(define-public (mint (data (string-ascii 80)))  
(match (mint-private tx-sender data) success
	(begin 
	
	(ok success))
	error (err error)))


(define-public (transfer (token-id uint) (sender principal) (recipient principal))  
(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(nft-transfer? Bitbasel token-id sender recipient)
	))


;; read-only functions
;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))  
(ok (nft-get-owner? Bitbasel token-id)))


;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)  
(ok (var-get last-token-id)))


(define-read-only (get-token-uri (token-id uint))  
(begin (match (map-get? nft-meta-data token-id) entry 
		(ok (some entry))
		(ok none))))