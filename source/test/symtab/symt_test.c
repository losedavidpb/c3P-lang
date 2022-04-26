#include "../../compiler/symtab/symt.h"
#include "../../compiler/symtab/lib/assertb.h"
#include "../../compiler/symtab/lib/memlib.h"

#include <stdio.h>

// Show main title for the list of unit tests
// that are going to be executed
#define test_welcome() \
    printf("\e[0;33mTEST \e[0m\e[0;34m::\e[0m \e[0;36msymtab\e[0m\n\e[0;35m==============================\e[0m\n")

// Show test's name at current terminal
#define test_name(message) \
    printf(" \e[0;33m*\e[0m \e[0;34mTest\e[0m \e[0;36m%s\e[0m ...................... ", message)

// Show a message that informs that current test
// has not errors at current assert
#define show_ok() \
    printf(" \e[0;32mOK\e[0m\n")

void test_new_delete()
{
    test_name("test_new_delete");

    symt_tab *tab1 = symt_new();
    assertf(tab1 != NULL, "table 1 should have been created");

    symt_tab *tab2 = symt_new();
    assertf(tab2 != NULL, "table 2 should have been created");

    symt_delete(tab1); tab1 = NULL;
    assertf(tab1 == NULL, "table 1 should have been deleted");

    symt_delete(tab2); tab2 = NULL;
    assertf(tab2 == NULL, "table 2 should have been deleted");

    show_ok();
}

void test_push()
{
    test_name("test_push");

    symt_tab *tab = symt_new();

    symt_var *var = (symt_var *)(ml_malloc(sizeof(symt_var)));
    var->name = "test_var";
    var->type = I8;
    var->modifiers = NULL;
    var->value = NULL;
    var->is_array = false;
    var->array_length = 0;

    symt_node *value = (symt_node *)(ml_malloc(sizeof(symt_node *)));
    value->id = LOCAL_VAR;
    value->var = var;

    tab = symt_push(tab, value);
    assertf(tab->var != NULL, "variable must be pushed");
    assertf(tab->next_node == NULL, "table must only have one element");

    show_ok();
}

int main(int nargc, char *argv[])
{
    test_welcome();
    test_new_delete();
    test_push();

    return 0;
}