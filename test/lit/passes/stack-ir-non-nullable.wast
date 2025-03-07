;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --generate-stack-ir --optimize-stack-ir --shrink-level=1 \
;; RUN:   -all --print-stack-ir | filecheck %s

;; Shrink level is set to 1 to enable local2stack in StackIR opts.

(module
 ;; CHECK:      (func $if (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT: )
 (func $if (param $param (ref eq)) (result (ref eq))
  (local $temp (ref eq))
  ;; Copy the param into $temp. $temp is then set in both arms of the if, so
  ;; it is set before the get at the end of the function, but we still need to
  ;; keep this set for validation purposes. Specifically, there is a set of
  ;; $temp followed by a get of it in the if condition, which local2stack could
  ;; remove in principle, if not for that final get at the function end.
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.get $temp)
 )

 ;; CHECK:      (func $if-no-last-get (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT: )
 (func $if-no-last-get (param $param (ref eq)) (result (ref eq))
  ;; As the original, but now there is no final get, so we can remove the set-
  ;; get pair of $temp before the if.
  (local $temp (ref eq))
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.get $param) ;; this changed from $temp to $param
 )

 ;; CHECK:      (func $if-extra-set (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT: )
 (func $if-extra-set (param $param (ref eq)) (result (ref eq))
  ;; As the original, but now there is an extra set before the final get, so
  ;; we can optimize - the extra set ensures validation.
  (local $temp (ref eq))
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.set $temp    ;; This set is new.
   (local.get $param)
  )
  (local.get $temp)
 )

 ;; CHECK:      (func $if-wrong-extra-set (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $param
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT: )
 (func $if-wrong-extra-set (param $param (ref eq)) (result (ref eq))
  ;; As the last testcase, but the extra set's index is wrong, so we cannot
  ;; optimize.
  (local $temp (ref eq))
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.set $param    ;; This set now writes to $param.
   (local.get $param)
  )
  (local.get $temp)
 )

 ;; CHECK:      (func $if-wrong-extra-get (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT: )
 (func $if-wrong-extra-get (param $param (ref eq)) (result (ref eq))
  ;; As the last testcase, but now it is the get that has the wrong index to
  ;; stop us, so we can optimize.
  (local $temp (ref eq))
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.set $temp
   (local.get $param)
  )
  (local.get $param) ;; This get does not affect optimizing the pair before the
                     ;; if, because it is of another local.
 )

 ;; CHECK:      (func $if-param (type $2) (param $param (ref eq)) (param $temp (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT: )
 (func $if-param (param $param (ref eq)) (param $temp (ref eq)) (result (ref eq))
  ;; As the original testcase, but now $temp is a param. Validation is no
  ;; longer an issue, so we can optimize away the pair.
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.get $temp)
 )

 ;; CHECK:      (func $if-nullable (type $3) (param $param (ref eq)) (result eqref)
 ;; CHECK-NEXT:  (local $temp eqref)
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT: )
 (func $if-nullable (param $param (ref eq)) (result (ref null eq))
  (local $temp (ref null eq)) ;; this changed
  ;; As the original testcase, but now $temp is a nullable. Validation is no
  ;; longer an issue, so we can optimize away the pair.
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (i31.new
     (i32.const 2)
    )
   )
  )
  (local.get $temp)
 )

 ;; CHECK:      (func $if-nondefaultable (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (i32 (ref eq)))
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  tuple.make
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  tuple.extract 1
 ;; CHECK-NEXT:  i32.const 1
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   i32.const 3
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   tuple.make
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 4
 ;; CHECK-NEXT:   i32.const 5
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   tuple.make
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  tuple.extract 1
 ;; CHECK-NEXT: )
 (func $if-nondefaultable (param $param (ref eq)) (result (ref eq))
  (local $temp (i32 (ref eq)))
  ;; As the original testcase, but now $temp is a nondefaultable tuple rather
  ;; than a non-nullable reference by itself. We cannot remove the first set
  ;; here.
  (local.set $temp
   (tuple.make
    (i32.const 0)
    (local.get $param)
   )
  )
  (if
   (ref.eq
    (tuple.extract 1
     (local.get $temp)
    )
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (tuple.make
     (i32.const 2)
     (i31.new
      (i32.const 3)
     )
    )
   )
   (local.set $temp
    (tuple.make
     (i32.const 4)
     (i31.new
      (i32.const 5)
     )
    )
   )
  )
  (tuple.extract 1
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $if-defaultable (type $4) (param $param eqref) (result eqref)
 ;; CHECK-NEXT:  (local $temp (i32 eqref))
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  tuple.make
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  tuple.extract 1
 ;; CHECK-NEXT:  i32.const 1
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   i32.const 3
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   tuple.make
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 4
 ;; CHECK-NEXT:   i32.const 5
 ;; CHECK-NEXT:   ref.i31
 ;; CHECK-NEXT:   tuple.make
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  tuple.extract 1
 ;; CHECK-NEXT: )
 (func $if-defaultable (param $param (ref null eq)) (result (ref null eq))
  (local $temp (i32 (ref null eq)))
  ;; As the last testcase, but now $temp is a defaultable tuple. We still do not
  ;; optimize away the set here, as we ignore tuples in local2stack.
  (local.set $temp
   (tuple.make
    (i32.const 0)
    (local.get $param)
   )
  )
  (if
   (ref.eq
    (tuple.extract 1
     (local.get $temp)
    )
    (i31.new
     (i32.const 1)
    )
   )
   (local.set $temp
    (tuple.make
     (i32.const 2)
     (i31.new
      (i32.const 3)
     )
    )
   )
   (local.set $temp
    (tuple.make
     (i32.const 4)
     (i31.new
      (i32.const 5)
     )
    )
   )
  )
  (tuple.extract 1
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $if-non-ref (type $5) (param $param i32) (result i32)
 ;; CHECK-NEXT:  (local $temp i32)
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  i32.eqz
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   i32.const 1
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   i32.const 2
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT: )
 (func $if-non-ref (param $param i32) (result i32)
  (local $temp i32)
  ;; As the original testcase, but now $temp is not a ref. Validation is no
  ;; longer an issue, so we can optimize away the pair.
  (local.set $temp
   (local.get $param)
  )
  (if
   (i32.eqz
    (local.get $temp)
    (i32.const 0)
   )
   (local.set $temp
    (i32.const 1)
   )
   (local.set $temp
    (i32.const 2)
   )
  )
  (local.get $temp)
 )

 ;; CHECK:      (func $nesting (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting (param $param (ref eq))
  (local $temp (ref eq))
  ;; The if arms contain optimization opportunities, even though there are 2
  ;; gets in each one, because this top set helps them all validate. Atm we do
  ;; not look backwards, however, so we fail to optimize here.
  (local.set $temp
   (local.get $param)
  )
  (if
   (i32.const 0)
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    (drop
     (local.get $temp)
    )
   )
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    (drop
     (local.get $temp)
    )
   )
  )
  (drop
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $nesting-left (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT: )
 (func $nesting-left (param $param (ref eq))
  (local $temp (ref eq))
  ;; As $nesting, but now the left arm has one get, and can be optimized.
  (local.set $temp
   (local.get $param)
  )
  (if
   (i32.const 0)
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    ;; A get was removed here.
   )
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    (drop
     (local.get $temp)
    )
   )
  )
 )

 ;; CHECK:      (func $nesting-right (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:   local.get $temp
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT: )
 (func $nesting-right (param $param (ref eq))
  (local $temp (ref eq))
  ;; As above, but now we can optimize the right arm.
  (local.set $temp
   (local.get $param)
  )
  (if
   (i32.const 0)
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    (drop
     (local.get $temp)
    )
   )
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    ;; A get was removed here.
   )
  )
 )

 ;; CHECK:      (func $nesting-both (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT: )
 (func $nesting-both (param $param (ref eq))
  (local $temp (ref eq))
  ;; As above, but now we can optimize both arms.
  (local.set $temp
   (local.get $param)
  )
  (if
   (i32.const 0)
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    ;; A get was removed here.
   )
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
    ;; A get was removed here.
   )
  )
 )

 ;; CHECK:      (func $nesting-both-less (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT: )
 (func $nesting-both-less (param $param (ref eq))
  (local $temp (ref eq))
  ;; As above, but without the initial set-get at the top. We can still
  ;; optimize both arms.
  (if
   (i32.const 0)
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
   )
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
   )
  )
 )

 ;; CHECK:      (func $nesting-both-after (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   drop
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting-both-after (param $param (ref eq))
  (local $temp (ref eq))
  ;; As above, but now there is a set-get at the end of the function. The get
  ;; there should not confuse us; we can still optimize both arms, and after
  ;; them as well.
  (if
   (i32.const 0)
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
   )
   (block
    (local.set $temp
     (local.get $param)
    )
    (drop
     (local.get $temp)
    )
   )
  )
  (local.set $temp
   (local.get $param)
  )
  (drop
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $nesting-irrelevant (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting-irrelevant (param $param (ref eq))
  (local $temp (ref eq))
  ;; The block in the middle here adds a scope, but it does not prevent us from
  ;; optimizing.
  (local.set $temp
   (local.get $param)
  )
  (block $block
  )
  (drop
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $nesting-relevant (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting-relevant (param $param (ref eq))
  (local $temp (ref eq))
  ;; As above, but now there is a get in that scope, which is a problem.
  (local.set $temp
   (local.get $param)
  )
  (block $block
   (drop
    (local.get $temp)
   )
  )
  (drop
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $nesting-after (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting-after (param $param (ref eq))
  (local $temp (ref eq))
  ;; A set-get pair with another after it in a block. We can optimize both.
  (local.set $temp
   (local.get $param)
  )
  (drop
   (local.get $temp)
  )
  (block $block
   (local.set $temp
    (local.get $param)
   )
   (drop
    (local.get $temp)
   )
  )
 )

 ;; CHECK:      (func $nesting-reverse (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting-reverse (param $param (ref eq))
  (local $temp (ref eq))
  ;; The reverse of the last case, now the block is first. We can optimize
  ;; both pairs.
  (block $block
   (local.set $temp
    (local.get $param)
   )
   (drop
    (local.get $temp)
   )
  )
  (local.set $temp
   (local.get $param)
  )
  (drop
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $nesting-covered-but-ended (type $0) (param $param (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  drop
 ;; CHECK-NEXT: )
 (func $nesting-covered-but-ended (param $param (ref eq))
  (local $temp (ref eq))
  ;; We cannot optimize this first pair, because while we see another set after
  ;; us, its scope ends, so our set must help the very final get validate.
  (local.set $temp
   (local.get $param)
  )
  (drop
   (local.get $temp)
  )
  (block $block
   ;; This pair we can almost optimize, but the get after the block reads from
   ;; it, so we don't.
   (local.set $temp
    (local.get $param)
   )
   (drop
    (local.get $temp)
   )
  )
  (drop
   (local.get $temp)
  )
 )

 ;; CHECK:      (func $two-covers (type $1) (param $param (ref eq)) (result (ref eq))
 ;; CHECK-NEXT:  (local $temp (ref eq))
 ;; CHECK-NEXT:  local.get $param
 ;; CHECK-NEXT:  local.set $temp
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT:  i32.const 0
 ;; CHECK-NEXT:  ref.i31
 ;; CHECK-NEXT:  ref.eq
 ;; CHECK-NEXT:  if
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   local.tee $temp
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  else
 ;; CHECK-NEXT:   local.get $param
 ;; CHECK-NEXT:   local.set $temp
 ;; CHECK-NEXT:  end
 ;; CHECK-NEXT:  local.get $temp
 ;; CHECK-NEXT: )
 (func $two-covers (param $param (ref eq)) (result (ref eq))
  (local $temp (ref eq))
  (local.set $temp
   (local.get $param)
  )
  (if
   (ref.eq
    (local.get $temp)
    (i31.new
     (i32.const 0)
    )
   )
   ;; In this if arm we write to $temp twice. That shouldn't confuse us; there's
   ;; still a use after the if, and we should not remove the set-get pair before
   ;; the if.
   (local.set $temp
    (local.tee $temp
     (local.get $param)
    )
   )
   (local.set $temp
    (local.get $param)
   )
  )
  (local.get $temp)
 )
)
