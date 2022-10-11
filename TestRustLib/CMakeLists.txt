cmake_minimum_required(VERSION 3.22)
project(cpp_with_rust)

set(CMAKE_CXX_STANDARD 17)

set(CPP_BIN_ROOT ${CMAKE_SOURCE_DIR}/cpp_bin)

set(CARGO_ROOT ${CMAKE_SOURCE_DIR}/im_core)
set(CARGO_MANIFEST ${CARGO_ROOT}/Cargo.toml)
set(CARGO_TARGET_DIR ${CARGO_ROOT}/target)

set(IM_CORE_BRIDGE_FILE bridge.rs)

set(IM_CORE_DEPEND_SOURCE_FILE
    ${CARGO_ROOT}/src/${IM_CORE_BRIDGE_FILE} ${CARGO_ROOT}/src/lib.rs
    ${CARGO_ROOT}/src/logger.rs)

set(IM_CORE_BRIDGE_HEADER
    ${CARGO_TARGET_DIR}/cxxbridge/im_core/src/${IM_CORE_BRIDGE_FILE}.h)

set(IM_CORE_BRIDGE_CPP
    ${CARGO_TARGET_DIR}/cxxbridge/im_core/src/${IM_CORE_BRIDGE_FILE}.cc)

set(IM_CORE_LIB
    ${CARGO_TARGET_DIR}/debug/${CMAKE_STATIC_LIBRARY_PREFIX}im_core${CMAKE_STATIC_LIBRARY_SUFFIX}
)

message(STATUS ${IM_CORE_DEPEND_SOURCE_FILE})
message(STATUS ${IM_CORE_LIB})

# Add a custom command that builds the rust crate and generates C++ bridge code
add_custom_command(
  OUTPUT ${IM_CORE_BRIDGE_CPP} ${IM_CORE_LIB}
  COMMAND cargo build --manifest-path ${CARGO_MANIFEST}
  DEPENDS ${IM_CORE_DEPEND_SOURCE_FILE}
  USES_TERMINAL)

add_library(im_core_bridge STATIC ${IM_CORE_BRIDGE_CPP})
target_include_directories(im_core_bridge PRIVATE ${CARGO_TARGET_DIR}/cxxbridge)
target_link_libraries(im_core_bridge ${IM_CORE_LIB})

add_executable(cpp_with_rust ${CPP_BIN_ROOT}/main.mm)

target_include_directories(cpp_with_rust PRIVATE ${CARGO_TARGET_DIR}/cxxbridge)
target_link_libraries(cpp_with_rust im_core_bridge)

message(STATUS ${CMAKE_BINARY_DIR})
set(IM_CORE_SDK_DIR ${CMAKE_BINARY_DIR}/im_core_sdk)
set(IM_CORE_SDK_LIB ${IM_CORE_SDK_DIR}/libim_core_sdk.a)
set(IM_CORE_SDK_INCLUDE ${IM_CORE_SDK_DIR}/include/im_core_sdk)
set(IM_CORE_BRIDGE_LIB
    ${CMAKE_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}im_core_bridge${CMAKE_STATIC_LIBRARY_SUFFIX}
)

add_custom_command(
  OUTPUT ${IM_CORE_SDK_LIB}
  COMMAND mkdir -p ${IM_CORE_SDK_INCLUDE}
  COMMAND libtool -static -o ${IM_CORE_SDK_LIB} ${IM_CORE_LIB}
          ${IM_CORE_BRIDGE_LIB}
  COMMAND cp -rf ${IM_CORE_BRIDGE_HEADER}
          ${IM_CORE_SDK_INCLUDE}
  COMMENT "merge lib"
  DEPENDS ${IM_CORE_LIB} ${IM_CORE_BRIDGE_LIB}
  USES_TERMINAL)

  add_custom_target(merge
  DEPENDS ${IM_CORE_SDK_LIB}
  )
