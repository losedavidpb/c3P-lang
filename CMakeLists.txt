cmake_minimum_required(VERSION 3.0.0)
project(c3p-lang VERSION 0.1.0)

include(CTest)
enable_testing()

include_directories(source/compiler/symt)

set(SOURCES ${PROJECT_SOURCE_DIR}/source/compiler/symtab/symt.c
            ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/memlib.c
            ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/copy.c
            ${PROJECT_SOURCE_DIR}/source/compiler/symtab/symt.h
            ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/memlib.h
            ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/assertb.h
            ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/copy.h
            ${PROJECT_SOURCE_DIR}/source/test/symtab/symt_test.c
)

set(HEADER_FILES ${PROJECT_SOURCE_DIR}/source/compiler/symtab/symt.h
                 ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/memlib.h
                 ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/assertb.h
                 ${PROJECT_SOURCE_DIR}/source/compiler/symtab/lib/copy.h
)

add_executable(c3p-lang ${SOURCES})

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)
