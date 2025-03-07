;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-as %s -all -g -o %t.wasm
;; RUN: wasm-dis %t.wasm -all -o %t.wast
;; RUN: wasm-as %s -all -o %t.nodebug.wasm
;; RUN: wasm-dis %t.nodebug.wasm -all -o %t.nodebug.wast
;; RUN: wasm-opt %t.wast -all -o %t.text.wast -g -S
;; RUN: cat %t.wast | filecheck %s --check-prefix=CHECK-BINARY
;; RUN: cat %t.nodebug.wast | filecheck %s --check-prefix=CHECK-NODEBUG
;; RUN: cat %t.text.wast | filecheck %s --check-prefix=CHECK-TEXT

(module
  ;; CHECK-BINARY:      (type $0 (func))

  ;; CHECK-BINARY:      (type $1 (func (result i32)))

  ;; CHECK-BINARY:      (type $2 (func (param i32) (result i32)))

  ;; CHECK-BINARY:      (type $3 (func (param i32 funcref i32)))

  ;; CHECK-BINARY:      (type $4 (func (param i32 i32 i32)))

  ;; CHECK-BINARY:      (table $table-1 1 1 funcref)
  ;; CHECK-TEXT:      (type $0 (func))

  ;; CHECK-TEXT:      (type $1 (func (result i32)))

  ;; CHECK-TEXT:      (type $2 (func (param i32) (result i32)))

  ;; CHECK-TEXT:      (type $3 (func (param i32 funcref i32)))

  ;; CHECK-TEXT:      (type $4 (func (param i32 i32 i32)))

  ;; CHECK-TEXT:      (table $table-1 1 1 funcref)
  (table $table-1 funcref
    (elem $foo)
  )

  ;; CHECK-BINARY:      (table $table-2 3 3 funcref)
  ;; CHECK-TEXT:      (table $table-2 3 3 funcref)
  (table $table-2 funcref
    (elem $bar $bar $bar)
  )

  ;; CHECK-BINARY:      (elem $0 (table $table-1) (i32.const 0) func $foo)

  ;; CHECK-BINARY:      (elem $1 (table $table-2) (i32.const 0) func $bar $bar $bar)

  ;; CHECK-BINARY:      (func $foo (type $0)
  ;; CHECK-BINARY-NEXT:  (nop)
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (elem $0 (table $table-1) (i32.const 0) func $foo)

  ;; CHECK-TEXT:      (elem $1 (table $table-2) (i32.const 0) func $bar $bar $bar)

  ;; CHECK-TEXT:      (func $foo (type $0)
  ;; CHECK-TEXT-NEXT:  (nop)
  ;; CHECK-TEXT-NEXT: )
  (func $foo
    (nop)
  )
  ;; CHECK-BINARY:      (func $bar (type $0)
  ;; CHECK-BINARY-NEXT:  (drop
  ;; CHECK-BINARY-NEXT:   (table.get $table-1
  ;; CHECK-BINARY-NEXT:    (i32.const 0)
  ;; CHECK-BINARY-NEXT:   )
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT:  (drop
  ;; CHECK-BINARY-NEXT:   (table.get $table-2
  ;; CHECK-BINARY-NEXT:    (i32.const 100)
  ;; CHECK-BINARY-NEXT:   )
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (func $bar (type $0)
  ;; CHECK-TEXT-NEXT:  (drop
  ;; CHECK-TEXT-NEXT:   (table.get $table-1
  ;; CHECK-TEXT-NEXT:    (i32.const 0)
  ;; CHECK-TEXT-NEXT:   )
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT:  (drop
  ;; CHECK-TEXT-NEXT:   (table.get $table-2
  ;; CHECK-TEXT-NEXT:    (i32.const 100)
  ;; CHECK-TEXT-NEXT:   )
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT: )
  (func $bar
    (drop
      (table.get $table-1
        (i32.const 0)
      )
    )
    (drop
      (table.get $table-2
        (i32.const 100)
      )
    )
  )

  ;; CHECK-BINARY:      (func $set-get (type $0)
  ;; CHECK-BINARY-NEXT:  (table.set $table-1
  ;; CHECK-BINARY-NEXT:   (i32.const 0)
  ;; CHECK-BINARY-NEXT:   (ref.func $foo)
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT:  (drop
  ;; CHECK-BINARY-NEXT:   (table.get $table-1
  ;; CHECK-BINARY-NEXT:    (i32.const 0)
  ;; CHECK-BINARY-NEXT:   )
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (func $set-get (type $0)
  ;; CHECK-TEXT-NEXT:  (table.set $table-1
  ;; CHECK-TEXT-NEXT:   (i32.const 0)
  ;; CHECK-TEXT-NEXT:   (ref.func $foo)
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT:  (drop
  ;; CHECK-TEXT-NEXT:   (table.get $table-1
  ;; CHECK-TEXT-NEXT:    (i32.const 0)
  ;; CHECK-TEXT-NEXT:   )
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT: )
  (func $set-get
    (table.set $table-1
      (i32.const 0)
      (ref.func $foo)
    )
    (drop
      (table.get $table-1
        (i32.const 0)
      )
    )
  )

  ;; CHECK-BINARY:      (func $get-table-size (type $1) (result i32)
  ;; CHECK-BINARY-NEXT:  (table.size $table-1)
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (func $get-table-size (type $1) (result i32)
  ;; CHECK-TEXT-NEXT:  (table.size $table-1)
  ;; CHECK-TEXT-NEXT: )
  (func $get-table-size (result i32)
    (table.size $table-1)
  )

  ;; CHECK-BINARY:      (func $table-grow (type $2) (param $sz i32) (result i32)
  ;; CHECK-BINARY-NEXT:  (table.grow $table-1
  ;; CHECK-BINARY-NEXT:   (ref.null nofunc)
  ;; CHECK-BINARY-NEXT:   (local.get $sz)
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (func $table-grow (type $2) (param $sz i32) (result i32)
  ;; CHECK-TEXT-NEXT:  (table.grow $table-1
  ;; CHECK-TEXT-NEXT:   (ref.null nofunc)
  ;; CHECK-TEXT-NEXT:   (local.get $sz)
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT: )
  (func $table-grow (param $sz i32) (result i32)
    (table.grow $table-1 (ref.null func) (local.get $sz))
  )

  ;; CHECK-BINARY:      (func $table-fill (type $3) (param $dest i32) (param $value funcref) (param $size i32)
  ;; CHECK-BINARY-NEXT:  (table.fill $table-1
  ;; CHECK-BINARY-NEXT:   (local.get $dest)
  ;; CHECK-BINARY-NEXT:   (local.get $value)
  ;; CHECK-BINARY-NEXT:   (local.get $size)
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (func $table-fill (type $3) (param $dest i32) (param $value funcref) (param $size i32)
  ;; CHECK-TEXT-NEXT:  (table.fill $table-1
  ;; CHECK-TEXT-NEXT:   (local.get $dest)
  ;; CHECK-TEXT-NEXT:   (local.get $value)
  ;; CHECK-TEXT-NEXT:   (local.get $size)
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT: )
  (func $table-fill (param $dest i32) (param $value funcref) (param $size i32)
    (table.fill $table-1
      (local.get $dest)
      (local.get $value)
      (local.get $size)
    )
  )

  ;; CHECK-BINARY:      (func $table-copy (type $4) (param $dest i32) (param $source i32) (param $size i32)
  ;; CHECK-BINARY-NEXT:  (table.copy $table-1 $table-2
  ;; CHECK-BINARY-NEXT:   (local.get $dest)
  ;; CHECK-BINARY-NEXT:   (local.get $source)
  ;; CHECK-BINARY-NEXT:   (local.get $size)
  ;; CHECK-BINARY-NEXT:  )
  ;; CHECK-BINARY-NEXT: )
  ;; CHECK-TEXT:      (func $table-copy (type $4) (param $dest i32) (param $source i32) (param $size i32)
  ;; CHECK-TEXT-NEXT:  (table.copy $table-1 $table-2
  ;; CHECK-TEXT-NEXT:   (local.get $dest)
  ;; CHECK-TEXT-NEXT:   (local.get $source)
  ;; CHECK-TEXT-NEXT:   (local.get $size)
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT: )
  (func $table-copy (param $dest i32) (param $source i32) (param $size i32)
    (table.copy $table-1 $table-2
      (local.get $dest)
      (local.get $source)
      (local.get $size)
    )
  )
)
;; CHECK-NODEBUG:      (type $0 (func))

;; CHECK-NODEBUG:      (type $1 (func (result i32)))

;; CHECK-NODEBUG:      (type $2 (func (param i32) (result i32)))

;; CHECK-NODEBUG:      (type $3 (func (param i32 funcref i32)))

;; CHECK-NODEBUG:      (type $4 (func (param i32 i32 i32)))

;; CHECK-NODEBUG:      (table $0 1 1 funcref)

;; CHECK-NODEBUG:      (table $1 3 3 funcref)

;; CHECK-NODEBUG:      (elem $0 (table $0) (i32.const 0) func $0)

;; CHECK-NODEBUG:      (elem $1 (table $1) (i32.const 0) func $1 $1 $1)

;; CHECK-NODEBUG:      (func $0 (type $0)
;; CHECK-NODEBUG-NEXT:  (nop)
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:      (func $1 (type $0)
;; CHECK-NODEBUG-NEXT:  (drop
;; CHECK-NODEBUG-NEXT:   (table.get $0
;; CHECK-NODEBUG-NEXT:    (i32.const 0)
;; CHECK-NODEBUG-NEXT:   )
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT:  (drop
;; CHECK-NODEBUG-NEXT:   (table.get $1
;; CHECK-NODEBUG-NEXT:    (i32.const 100)
;; CHECK-NODEBUG-NEXT:   )
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:      (func $2 (type $0)
;; CHECK-NODEBUG-NEXT:  (table.set $0
;; CHECK-NODEBUG-NEXT:   (i32.const 0)
;; CHECK-NODEBUG-NEXT:   (ref.func $0)
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT:  (drop
;; CHECK-NODEBUG-NEXT:   (table.get $0
;; CHECK-NODEBUG-NEXT:    (i32.const 0)
;; CHECK-NODEBUG-NEXT:   )
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:      (func $3 (type $1) (result i32)
;; CHECK-NODEBUG-NEXT:  (table.size $0)
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:      (func $4 (type $2) (param $0 i32) (result i32)
;; CHECK-NODEBUG-NEXT:  (table.grow $0
;; CHECK-NODEBUG-NEXT:   (ref.null nofunc)
;; CHECK-NODEBUG-NEXT:   (local.get $0)
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:      (func $5 (type $3) (param $0 i32) (param $1 funcref) (param $2 i32)
;; CHECK-NODEBUG-NEXT:  (table.fill $0
;; CHECK-NODEBUG-NEXT:   (local.get $0)
;; CHECK-NODEBUG-NEXT:   (local.get $1)
;; CHECK-NODEBUG-NEXT:   (local.get $2)
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:      (func $6 (type $4) (param $0 i32) (param $1 i32) (param $2 i32)
;; CHECK-NODEBUG-NEXT:  (table.copy $0 $1
;; CHECK-NODEBUG-NEXT:   (local.get $0)
;; CHECK-NODEBUG-NEXT:   (local.get $1)
;; CHECK-NODEBUG-NEXT:   (local.get $2)
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT: )
