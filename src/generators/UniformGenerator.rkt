#lang racket

(define (generate-samples num-samples output-file)
  "Generate random integers in [1,20] and save to file"
  (with-output-to-file output-file
    #:exists 'replace
    (lambda ()
      (for ([i (in-range num-samples)])
        (displayln (+ 1 (random 20))))))  ; [1,20]
  (printf "Generated ~a samples in ~a\n" num-samples output-file))

(define (main)
  (define args (current-command-line-arguments))
  (if (< (vector-length args) 2)
      (begin
        (displayln "Usage: racket racket_generator.rkt <num_samples> <output_file>")
        (exit 1))
      (let ([num-samples (string->number (vector-ref args 0))]
            [output-file (vector-ref args 1)])
        (generate-samples num-samples output-file))))

(main)