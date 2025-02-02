"""OSS versions of Bazel macros that can't be migrated to TSL."""

load(
    "//tensorflow/core/platform:build_config_root.bzl",
    "if_static",
)
load(
    "@local_xla//xla:xla.bzl",
    _xla_clean_dep = "clean_dep",
)
load(
    "@local_tsl//tsl:tsl.bzl",
    "if_libtpu",
    _tsl_clean_dep = "clean_dep",
)
load(
    "//tensorflow:tensorflow.bzl",
    "clean_dep",
)
load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda")
load("@local_config_rocm//rocm:build_defs.bzl", "if_rocm")
load(
    "//third_party/mkl:build_defs.bzl",
    "if_mkl_ml",
)

def tf_tpu_dependencies():
    return if_libtpu(["//tensorflow/core/tpu/kernels"])

def tf_dtensor_tpu_dependencies():
    return if_libtpu(["//tensorflow/dtensor/cc:dtensor_tpu_kernels"])

def tf_additional_binary_deps():
    return [
        clean_dep("@nsync//:nsync_cpp"),
        # TODO(allenl): Split these out into their own shared objects. They are
        # here because they are shared between contrib/ op shared objects and
        # core.
        clean_dep("//tensorflow/core/kernels:lookup_util"),
        clean_dep("//tensorflow/core/util/tensor_bundle"),
    ] + if_cuda(
        [
            clean_dep("@local_xla//xla/stream_executor:cuda_platform"),
        ],
    ) + if_rocm(
        [
            clean_dep("@local_xla//xla/stream_executor:rocm_platform"),
            clean_dep("@local_xla//xla/stream_executor/rocm:rocm_rpath"),
        ],
    ) + if_mkl_ml(
        [
            clean_dep("//third_party/mkl:intel_binary_blob"),
        ],
    )

def tf_protos_all():
    return if_static(
        extra_deps = [
            clean_dep("//tensorflow/core/protobuf:conv_autotuning_proto_cc_impl"),
            clean_dep("//tensorflow/core:protos_all_cc_impl"),
            _xla_clean_dep("@local_xla//xla:autotuning_proto_cc_impl"),
            _tsl_clean_dep("@local_tsl//tsl/protobuf:protos_all_cc_impl"),
        ],
        otherwise = [clean_dep("//tensorflow/core:protos_all_cc")],
    )
