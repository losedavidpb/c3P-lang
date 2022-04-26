#include "../../compiler/symtab/symt.h"
#include "../../compiler/symtab/lib/assertb.h"
#include "../../compiler/symtab/lib/memlib.h"

#include <stdio.h>

// Show main title for the list of unit tests
// that are going to be executed
#define test_welcome() \
    printf("\e[0;32mTEST \e[0m\e[0;34m::\e[0m \e[0;36msymtab\e[0m\n\e[0;35m==============================\e[0m\n")

// Show test's name at current terminal
#define test_name(message) \
    printf(" \e[0;33m*\e[0m \e[0;34mTest\e[0m \e[0;36m%s\e[0m ...................... ", message)

// Show a message that informs that current test
// has not errors at current assert
#define show_ok() \
    printf(" \e[0;32mOK\e[0m\n")

void test_new_delete()
{
    symt_tab *test_tab1, *test_tab2;
    int *val1, *val2, *val3;
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_new_delete");

    test_tab1 = symt_new();
    assertf(test_tab1 != NULL, "%s must be defined", "test_tab1");

    test_tab2 = symt_new();
    assertf(test_tab2 != NULL, "%s must be defined", "test_tab2");

    symt_insert_var(test_tab1, GLOBAL_VAR, "gvar1", I32, false, 0, val1, NULL);
    symt_insert_var(test_tab1, GLOBAL_VAR, "gvar2", I32, false, 0, val2, NULL);
    symt_insert_var(test_tab1, GLOBAL_VAR, "gvar3", I32, false, 0, val3, NULL);
    symt_insert_rout(test_tab1, PROCEDURE, "main", VOID, NULL, NULL, NULL);

    symt_delete(test_tab1); test_tab1 = NULL;
    assertf(test_tab1 == NULL, "%s must be cleaned", "test_tab1");

    symt_delete(test_tab2); test_tab2 = NULL;
    assertf(test_tab2 == NULL, "%s must be cleaned", "test_tab2");

    show_ok();
}

void test_push()
{
    symt_tab *tab;
    symt_var *var1, *var2;
    symt_routine *rout1, *rout2;
    symt_node *node1, *node2, *node3, *node4;

    test_name("test_push");

    tab = symt_new();
    assertf(tab != NULL, "table must be created");

    symt_push(tab, node1);
    assertf(tab->var == NULL, "null values must not be allowed");

    var1 = (symt_var*)(ml_malloc(sizeof(symt_var)));
    var2 = (symt_var*)(ml_malloc(sizeof(symt_var)));
    rout1 = (symt_routine*)(ml_malloc(sizeof(symt_routine)));
    rout2 = (symt_routine*)(ml_malloc(sizeof(symt_routine)));

    var1->name = "gvar1"; var2->name = "gvar2";
    rout1->name = "rout1"; rout2->name = "rout2";

    node1 = (symt_node*)(ml_malloc(sizeof(symt_node)));
    node2 = (symt_node*)(ml_malloc(sizeof(symt_node)));
    node3 = (symt_node*)(ml_malloc(sizeof(symt_node)));
    node4 = (symt_node*)(ml_malloc(sizeof(symt_node)));

    node1->id = GLOBAL_VAR; node1->var = var1;
    node2->id = GLOBAL_VAR; node1->var = var2;
    node3->id = PROCEDURE; node1->rout = rout1;
    node4->id = FUNCTION; node1->rout = rout2;

    symt_push(tab, node1);
    assertf(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == true, "var1 name should be the same");

    symt_push(tab, node2);
    assertf(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == true, "var1 name should be the same");
    assertf(tab->next_node->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->next_node->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->next_node->var->name, "gvar2") == true, "var2 name should be the same");

    symt_push(tab, node3);
    assertf(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == true, "var1 name should be the same");
    assertf(tab->next_node->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->next_node->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->next_node->var->name, "gvar2") == true, "var2 name should be the same");
    assertf(tab->next_node->next_node->id == PROCEDURE, "procedure id should be defined");
    assertf(tab->next_node->next_node->rout != NULL, "procedure should be defined");
    assertf(strcmp(tab->next_node->next_node->rout->name, "rout1") == true, "rout1 name should be the same");

    symt_push(tab, node4);
    assertf(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == true, "var1 name should be the same");
    assertf(tab->next_node->id == GLOBAL_VAR, "id must be a global variable");
    assertf(tab->next_node->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->next_node->var->name, "gvar2") == true, "var2 name should be the same");
    assertf(tab->next_node->next_node->id == PROCEDURE, "procedure id should be defined");
    assertf(tab->next_node->next_node->rout != NULL, "procedure should be defined");
    assertf(strcmp(tab->next_node->next_node->rout->name, "rout1") == true, "rout1 name should be the same");
    assertf(tab->next_node->next_node->next_node->id == FUNCTION, "id must be a function");
    assertf(tab->next_node->next_node->next_node->rout != NULL, "function should be defined");
    assertf(strcmp(tab->next_node->next_node->next_node->rout->name, "rout2") == true, "rout2 name should be the same");

    symt_delete(tab);
    show_ok();
}

void test_search()
{
    symt_tab* tab;
    symt_node *result, *cond;
    symt_node *if_statements, *else_statements;
    int *val1, *val2, *val3;
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_search");

    tab = symt_new();
    symt_insert_var(tab, GLOBAL_VAR, "gvar1", I32, false, 0, val1, NULL);

    result = symt_search(tab, GLOBAL_VAR);
    assertf(result != NULL, "procedure should exist");

    symt_insert_var(tab, GLOBAL_VAR, "gvar2", I32, false, 0, val2, NULL);
    symt_insert_var(tab, GLOBAL_VAR, "gvar3", I32, false, 0, val3, NULL);
    symt_insert_rout(tab, PROCEDURE, "main", VOID, NULL, NULL, NULL);

    result = symt_search(tab, PROCEDURE);
    assertf(result != NULL, "procedure should exist");

    symt_delete(tab);

    cond = symt_new();
    if_statements = symt_new();
    else_statements = symt_new();

    symt_insert_var(if_statements, LOCAL_VAR, "local_var1", I32, false, 0, val1, NULL);
    symt_insert_var(else_statements, GLOBAL_VAR, "local_var1", I32, false, 0, val1, NULL);
    symt_insert_var(else_statements, LOCAL_VAR, "local_var2", I32, false, 0, val1, NULL);

    tab = symt_new();
    symt_insert_if(tab, cond, if_statements, NULL);
    symt_insert_if(tab, cond, NULL, else_statements);
    symt_insert_if(tab, cond, NULL, NULL);

    result = symt_search(tab, LOCAL_VAR);
    assertf(result != NULL, "if statement must define local var");

    result = symt_search(tab, GLOBAL_VAR);
    assertf(result != NULL, "else statement must define global val");

    result = symt_search(else_statements, LOCAL_VAR);
    assertf(result != NULL, "else statement must define local var");

    symt_delete(tab);
    show_ok();
}

void test_search_by_name()
{
    symt_tab* tab;
    symt_node *result;
    int *val1, *val2, *val3;
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_search");

    tab = symt_new();
    symt_insert_var(tab, GLOBAL_VAR, "gvar1", I32, false, 0, val1, NULL);

    result = symt_search_by_name(tab, "gvar1", GLOBAL_VAR);
    assertf(result != NULL, "global var should exist");

    symt_insert_var(tab, GLOBAL_VAR, "gvar2", I32, false, 0, val2, NULL);
    symt_insert_var(tab, GLOBAL_VAR, "gvar3", I32, false, 0, val3, NULL);
    symt_insert_rout(tab, PROCEDURE, "main", VOID, NULL, NULL, NULL);

    result = symt_search_by_name(tab, "main", PROCEDURE);
    assertf(result != NULL, "procedure should exist");

    result = symt_search_by_name(tab, "gvar1", GLOBAL_VAR);
    assertf(result != NULL, "global var 1 should exist");

    result = symt_search_by_name(tab, "gvar2", GLOBAL_VAR);
    assertf(result != NULL, "global var 2 should exist");

    result = symt_search_by_name(tab, "gvar3", GLOBAL_VAR);
    assertf(result != NULL, "global var 3 should exist");

    symt_delete(tab);
    show_ok();
}

void test_end_block()
{
    symt_tab * tab;
    symt_node *cond;
    symt_node *statements;

    test_name("test_end_block");

    tab = symt_new();
    cond = symt_new();
    statements = symt_new();

    symt_insert_var(statements, LOCAL_VAR, "gvar1", I64, false, 0, NULL, NULL);
    symt_insert_var(statements, LOCAL_VAR, "gvar2", I64, false, 0, NULL, NULL);
    symt_insert_while(tab, cond, statements);

    symt_end_block(tab, WHILE);
    assertf(tab->while_val == NULL, "block statement wasn't clean");

    symt_delete(tab);
    show_ok();
}

void test_merge()
{
    symt_tab* tab1, *tab2;
    symt_var_mod_t** hide_mod;
    symt_node *result;

    hide_mod = (symt_var_mod_t**)(ml_malloc(2 * sizeof(symt_var_mod_t*)));
    *hide_mod = HIDE;

    test_name("test_merge");

    tab1 = symt_new();
    tab2 = symt_new();

    symt_insert_var(tab1, GLOBAL_VAR, "gvar", F32, true, 10, NULL, NULL);
    symt_insert_rout(tab2, PROCEDURE, "main", VOID, NULL, hide_mod, NULL);

    symt_merge(tab1, tab2);

    result = symt_search(tab2, GLOBAL_VAR);
    assertf(result != NULL, "global variable must exist after merging");

    result = symt_search(tab2, PROCEDURE);
    assertf(result == NULL, "procedure must not exist after merging");

    symt_delete(tab1);
    symt_delete(tab2);

    show_ok();
}

int main(int nargc, char *argv[])
{
    test_welcome();
    test_new_delete();
    test_push();
    test_search();
    test_search_by_name();
    test_end_block();
    test_merge();

    return 0;
}