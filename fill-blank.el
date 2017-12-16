(defun init-fill-blank ()
  (setq fill-blank-postions '())
  (setq fill-blank-current-pos-idx 0)
  (make-variable-buffer-local 'fill-blank-postions)
  (make-variable-buffer-local 'fill-blank-current-pos-idx)
  (setq-local fill-blank-postions '())
  (setq-local fill-blank-current-pos-idx 0))

(defun goto-idx-blank (idx)
  (goto-char (nth idx
		  (reverse fill-blank-postions))))
  
(defun fill-blanks-info ()
  (interactive)
  (print
   (with-output-to-string
     (princ "current postion idx:")
     (princ fill-blank-current-pos-idx)
     (princ "\n")
     (princ "postions:")
     (princ fill-blank-postions))))

(defun erase-following-blanks ()
  (while (char-equal ?_ (char-after))
    (delete-forward-char 1)))

(defun skip-next-some ()
  (interactive)
  (while (or (char-equal (char-after) ?\))
	     (char-equal (char-after) ?\")
	     (char-equal (char-after) ?\ ))
    (goto-char (1+ (point)))))

(defun find-next-blanks ()
  (let ((blank "__")
	(dump))
    (if (search-forward blank dump t)
	(progn
	  (backward-char (length blank))
	  (push (point) fill-blank-postions)
	  (setf fill-blank-current-pos-idx (1- (length fill-blank-postions))))
      (princ "no more blanks after this!"))))

(defun at-last-found-blank-postion ()
  (>= fill-blank-current-pos-idx
	 (1- (length fill-blank-postions))))

(defmacro incf-1 (num)
  `(setf ,num (1+ ,num)))

(defmacro decf-1 (num)
  `(setf ,num (1- ,num)))

(defun move-to-next-blanks ()
  (if (< fill-blank-current-pos-idx (1- (length fill-blank-postions)))
      (goto-idx-blank (incf-1 fill-blank-current-pos-idx))
    (princ "no more blanks after this one!")))

(defun move-to-prev-blanks ()
  (if (> fill-blank-current-pos-idx 0)
      (goto-idx-blank (decf-1 fill-blank-current-pos-idx))
    (princ "no more blanks before this one!")))

(defun active-find-blank-key ()
  (init-fill-blank)
  (local-set-key
   (kbd "C-c n")
   #'(lambda () (interactive)
       (skip-next-some)
       (erase-following-blanks)
       (if (at-last-found-blank-postion)
	   (find-next-blanks)
	 (move-to-next-blanks))))
  (local-set-key
   (kbd "C-c p")
   #'(lambda () (interactive)
       (move-to-prev-blanks))))

(defun fill-blank-active ()
  (if (string-match-p ".*lisp-koans/koans/.*"
		      (buffer-file-name (current-buffer)))
      (active-find-blank-key)))
  
(add-hook 'find-file-hook 'fill-blank-active)


