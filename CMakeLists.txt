cmake_minimum_required(VERSION 3.1)
project(c3p-lang VERSION 1.0)

# Set the global package-wide C++ standard. This will be inherited by all
# targets specified in the project. One can also specify the C++ standard in a
# target-specific manner, using:
#   set_target_properties(foo PROPERTIES CXX_STANDARD 11)
# for a target foo
set(CMAKE_CXX_STANDARD 11)

enable_testing()
include(CTest)

# Packages required to compile most source files of
# c3P compiler. Discard REQUIRED if compilation would only
# use C source and header files
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

set(SOURCE_DIR ${PROJECT_SOURCE_DIR}/src)
set(SYMT_PATH ${SOURCE_DIR}/symtab)
set(HEADER_DIR ${PROJECT_SOURCE_DIR}/include)

set(SOURCES ${SYMT_PATH}/symt.c ${SYMT_PATH}/copy.c ${SYMT_PATH}/memlib.c)
set(HEADERS ${HEADER_DIR}/symt.h ${HEADER_DIR}/arrcopy.h ${HEADER_DIR}/memlib.h ${HEADER_DIR}/assertb.h)

set(LEXER_OUT ${SYMT_PATH}/lex.yy.c)
set(PARSER_OUT ${SYMT_PATH}/c3pbison.tab.c)

BISON_TARGET(PARSER "${SYMT_PATH}/c3pbison.y" "${PARSER_OUT}" DEFINES_FILE "${SYMT_PATH}/c3pbison.tab.h" )
FLEX_TARGET(LEXER "${SYMT_PATH}/c3pflex.l" "${LEXER_OUT}")
ADD_FLEX_BISON_DEPENDENCY(LEXER PARSER)

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-lfl -lm)
else()
    error("Only GCC is supported")
endif()

add_executable(c3p-lang "${SOURCES}" "${HEADERS}" "${LEXER_OUT}" "${PARSER_OUT}")
target_link_libraries(c3p-lang m)
