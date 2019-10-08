// RUN: mlir-opt -convert-gpu-to-spirv %s -o - | FileCheck %s

module attributes {gpu.container_module} {

  // CHECK:       spv.module "Logical" "GLSL450" {
  // CHECK-NEXT:    spv.globalVariable [[VAR1:@.*]] bind(0, 0) : !spv.ptr<f32, StorageBuffer>
  // CHECK-NEXT:    spv.globalVariable [[VAR2:@.*]] bind(0, 1) : !spv.ptr<!spv.array<12 x f32>, StorageBuffer>
  // CHECK-NEXT:    func @kernel_1
  // CHECK-NEXT:      spv.Return
  // CHECK:       spv.EntryPoint "GLCompute" @kernel_1, [[VAR1]], [[VAR2]]
  module @kernels attributes {gpu.kernel_module} {
    func @kernel_1(%arg0 : f32, %arg1 : memref<12xf32, 1>)
        attributes { gpu.kernel } {
      return
    }
  }

  func @foo() {
    %0 = "op"() : () -> (f32)
    %1 = "op"() : () -> (memref<12xf32, 1>)
    %cst = constant 1 : index
    "gpu.launch_func"(%cst, %cst, %cst, %cst, %cst, %cst, %0, %1) { kernel = "kernel_1", kernel_module = @kernels }
        : (index, index, index, index, index, index, f32, memref<12xf32, 1>) -> ()
    return
  }

}
