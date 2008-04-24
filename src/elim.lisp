;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;

(in-package :maxima)

(defmfun $eliminate (eqns vars)
  (let ((sv nil)
	(l ($length eqns))
	(flag nil)
	($dispflag nil))
    (declare (special $dispflag))
    (unless (and ($listp eqns) ($listp vars))
      (maxima-error "eliminate: The arguments must both be lists"))
    (when (> ($length vars) l)
      (maxima-error "eliminate: More variables than equations"))
    (when (= l 1)
      (maxima-error "elimiinate: Can't eliminate from only one equation"))
    (when (= ($length vars) l)
      (setq vars ($reverse vars))
      (setq sv (maref vars 1))
      (setq vars ($reverse (simplify ($rest vars))))
      (setq flag t))
    (setq eqns (simplify (map1 (getopr 'meqhk) eqns)))
    (dolist (v (cdr vars))
      (let ((teqns '((mlist))))
	(do ((j 1 (1+ j)))
	    ((or (> j l) (not ($freeof v (simplify ($first eqns))))))
	  (setq teqns ($cons (simplify ($first eqns)) teqns))
	  (setq eqns (simplify ($rest eqns))))
	(cond ((like eqns '((mlist)))
	       (setq eqns teqns))
	      (t
	       (setq teqns ($append teqns (simplify ($rest eqns))))
	       (setq eqns (simplify ($first eqns)))
	       (decf l)
	       (let ((se '((mlist))))
		 (dotimes (j l)		;maxima starts indices with 1, therefore the 1+
		   (setq se ($cons (simplify ($resultant eqns (maref teqns (1+ j)) v)) se)))
		 (setq eqns se))))))
    (if flag
	(list '(mlist) ($rhs (simplify (mfuncall '$ev (simplify ($last (simplify ($solve (maref eqns 1) sv)))) '$eval))))
	eqns)))

(add2lnc '$eliminate $props)
