// RUN: %target-swift-frontend -assume-parsing-unqualified-ownership-sil %s -emit-ir -whole-module-optimization | %FileCheck %s

// REQUIRES: CPU=i386 || CPU=x86_64


// Non-Swift _silgen_name definitions

@_silgen_name("atan2") func atan2test(_ a: Double, _ b: Double) -> Double
_ = atan2test(0.0, 0.0)
// CHECK: call swiftcc double @atan2(double {{.*}}, double {{.*}})


// Ordinary Swift definitions
// WMO is expected to eliminate the unused internal and private functions.

public   func PlainPublic()   { }
internal func PlainInternal() { }
private  func PlainPrivate()  { }
// CHECK: define{{( protected)?}} swiftcc void @_T07asmname11PlainPublic
// CHECK-NOT: PlainInternal
// CHECK-NOT: PlainPrivate


// Swift _silgen_name definitions
// WMO is expected to eliminate the private function
// but the internal function must survive for C use.
// Only the C-named definition is emitted.

@_silgen_name("silgen_name_public")   public   func SilgenNamePublic()   { }
@_silgen_name("silgen_name_internal") internal func SilgenNameInternal() { }
@_silgen_name("silgen_name_private")  private  func SilgenNamePrivate()  { }
// CHECK: define{{( protected)?}} swiftcc void @silgen_name_public
// CHECK: define hidden swiftcc void @silgen_name_internal
// CHECK-NOT: silgen_name_private
// CHECK-NOT: SilgenName


// Swift cdecl definitions
// WMO is expected to eliminate the private functions
// but the internal functions must survive for C use.
// Both a C-named definition and a Swift-named definition are emitted.

@_cdecl("cdecl_public")   public   func CDeclPublic()   { }
@_cdecl("cdecl_internal") internal func CDeclInternal() { }
@_cdecl("cdecl_private")  private  func CDeclPrivate()  { }
// CHECK: define{{( protected)?}} void @cdecl_public
// CHECK: define{{( protected)?}} swiftcc void @_T07asmname11CDeclPublic
// CHECK: define hidden void @cdecl_internal
// CHECK: define hidden swiftcc void @_T07asmname13CDeclInternal
// CHECK-NOT: cdecl_private
