#include "../../../../include/symt.h"
#include "../../../../include/symt_type.h"
#include "../../../../include/symt_call.h"
#include "../../../../include/symt_cons.h"
#include "../../../../include/symt_rout.h"
#include "../../../../include/symt_var.h"
#include "../../../../include/symt_node.h"
#include "../../../../include/cunit.h"
#include "../../../../include/memlib.h"
#include "../../../../include/arrcopy.h"
#include <string.h>

void test_new_delete()
{
    symt_tab *test_tab1, *test_tab2;
    int *val1, *val2, *val3;

    val1 = (int*)(ml_malloc(sizeof(int)));
    val2 = (int*)(ml_malloc(sizeof(int)));
    val3 = (int*)(ml_malloc(sizeof(int)));
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_new_delete");

    test_tab1 = symt_new();
    test_assert("test_new_tab1");
    assertf(test_tab1 != NULL, "%s must be defined", "test_tab1");
    show_ok();

    test_tab2 = symt_new();
    test_assert("test_new_tab2");
    assertf(test_tab2 != NULL, "%s must be defined", "test_tab2");
    show_ok();

    test_tab1 = symt_insert_tab_var(test_tab1, GLOBAL_VAR, (char*)"gvar1", I32, false, 0, val1, false);
    test_tab1 = symt_insert_tab_var(test_tab1, GLOBAL_VAR, (char*)"gvar2", I32, false, 0, val2, false);
    test_tab1 = symt_insert_tab_var(test_tab1, GLOBAL_VAR, (char*)"gvar3", I32, false, 0, val3, false);
    test_tab1 = symt_insert_tab_rout(test_tab1, PROCEDURE, (char*)"main", VOID, NULL, false, NULL);

    test_assert("test_delete_tab1");
    symt_delete(test_tab1); test_tab1 = NULL;
    assertf(test_tab1 == NULL, "%s must be cleaned", "test_tab1");
    show_ok();

    test_assert("test_delete_tab2");
    symt_delete(test_tab2); test_tab2 = NULL;
    assertf(test_tab2 == NULL, "%s must be cleaned", "test_tab2");
    show_ok();
}

void test_push()
{
    symt_tab *tab;
    symt_var *var1, *var2;
    symt_rout *rout1, *rout2;
    symt_node *node1, *node2, *node3, *node4;

    test_name("test_push");

    test_assert("test_new_tab");
    tab = symt_new();
    assertp(tab != NULL, "table must be created");
    show_ok();

    var1 = (symt_var*)(ml_malloc(sizeof(symt_var)));
    var2 = (symt_var*)(ml_malloc(sizeof(symt_var)));
    rout1 = (symt_rout*)(ml_malloc(sizeof(symt_rout)));
    rout2 = (symt_rout*)(ml_malloc(sizeof(symt_rout)));

    var1->name = strcopy((char*)"gvar1"); var1->value = NULL;
    var2->name = strcopy((char*)"gvar2"); var2->value = NULL;
    rout1->name = strcopy((char*)"rout1"); rout1->params = NULL;
    rout2->name = strcopy((char*)"rout2"); rout2->params = NULL;

    node1 = (symt_node*)(ml_malloc(sizeof(symt_node)));
    node2 = (symt_node*)(ml_malloc(sizeof(symt_node)));
    node3 = (symt_node*)(ml_malloc(sizeof(symt_node)));
    node4 = (symt_node*)(ml_malloc(sizeof(symt_node)));

    node1->id = GLOBAL_VAR; node1->var = var1; node1->next_node = NULL;
    node2->id = GLOBAL_VAR; node2->var = var2; node2->next_node = NULL;
    node3->id = PROCEDURE; node3->rout = rout1; node3->next_node = NULL;
    node4->id = FUNCTION; node4->rout = rout2; node4->next_node = NULL;

    test_assert("test_push_gvar1");
    tab = symt_push(tab, node1);
    assertp(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == 0, "%s is not equal to %s", tab->var->name, "gvar1");
    show_ok();

    test_assert("test_push_gvar2");
    tab = symt_push(tab, node2);
    assertp(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == 0, "%s is not equal to %s", tab->var->name, "gvar1");
    assertp(tab->next_node->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->next_node->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->next_node->var->name, "gvar2") == 0, "%s is not equal to %s", tab->next_node->var->name, "gvar2");
    show_ok();

    test_assert("test_push_rout1");
    tab = symt_push(tab, node3);
    assertp(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == 0, "%s is not equal to %s", tab->var->name, "gvar1");
    assertp(tab->next_node->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->next_node->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->next_node->var->name, "gvar2") == 0, "%s is not equal to %s", tab->next_node->var->name, "gvar2");
    assertp(tab->next_node->next_node->id == PROCEDURE, "procedure id should be defined");
    assertp(tab->next_node->next_node->rout != NULL, "procedure should be defined");
    assertf(strcmp(tab->next_node->next_node->rout->name, "rout1") == 0, "%s is not equal to %s", tab->next_node->next_node->rout->name, "rout1");
    show_ok();

    test_assert("test_push_rout2");
    tab = symt_push(tab, node4);
    assertp(tab->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->var->name, "gvar1") == 0, "%s is not equal to %s", tab->var->name, "gvar1");
    assertp(tab->next_node->id == GLOBAL_VAR, "id must be a global variable");
    assertp(tab->next_node->var != NULL, "global variable should be defined");
    assertf(strcmp(tab->next_node->var->name, "gvar2") == 0, "%s is not equal to %s", tab->next_node->var->name, "gvar2");
    assertp(tab->next_node->next_node->id == PROCEDURE, "procedure id should be defined");
    assertp(tab->next_node->next_node->rout != NULL, "procedure should be defined");
    assertf(strcmp(tab->next_node->next_node->rout->name, "rout1") == 0, "%s is not equal to %s", tab->next_node->next_node->rout->name, "rout1");
    assertp(tab->next_node->next_node->next_node->id == FUNCTION, "id must be a function");
    assertp(tab->next_node->next_node->next_node->rout != NULL, "function should be defined");
    assertf(strcmp(tab->next_node->next_node->next_node->rout->name, "rout2") == 0, "%s is not equal to %s", tab->next_node->next_node->rout->name, "rout2");
    show_ok();

    test_assert("test_delete_after_push");
    symt_delete(tab);
    show_ok();
}

void test_search()
{
    symt_tab* tab;
    symt_node *result, *cond;
    symt_node *if_statements, *else_statements;
    int *val1, *val2, *val3;

    val1 = (int*)(ml_malloc(sizeof(int)));
    val2 = (int*)(ml_malloc(sizeof(int)));
    val3 = (int*)(ml_malloc(sizeof(int)));
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_search");

    tab = symt_new();
    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar1", I32, false, 0, val1, false);

    test_assert("test_search_one_var");
    result = symt_search(tab, GLOBAL_VAR);
    assertp(result != NULL, "global variable should exist");
    show_ok();

    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar2", I32, false, 0, val2, false);
    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar3", I32, false, 0, val3, false);
    tab = symt_insert_tab_rout(tab, PROCEDURE, (char*)"main", VOID, NULL, false, NULL);

    test_assert("test_search_procedure");
    result = symt_search(tab, PROCEDURE);
    assertp(result != NULL, "procedure should exist");
    show_ok();

    symt_delete(tab);

    cond = symt_new();
    if_statements = symt_new();
    else_statements = symt_new();

    if_statements = symt_insert_tab_var(if_statements, LOCAL_VAR, (char*)"local_var1", I32, false, 0, val1, false);
    else_statements = symt_insert_tab_var(else_statements, GLOBAL_VAR, (char*)"local_var2", I32, false, 0, val2, false);

    tab = symt_new();
    tab = symt_insert_tab_if(tab, cond, if_statements, NULL);
    tab = symt_insert_tab_if(tab, cond, NULL, else_statements);
    tab = symt_insert_tab_if(tab, cond, NULL, NULL);

    test_assert("test_search_local_var_at_if");
    result = symt_search(tab, LOCAL_VAR);
    assertp(result != NULL, "if statement must define local var");
    show_ok();

    test_assert("test_search_global_var_at_else");
    result = symt_search(tab, GLOBAL_VAR);
    assertp(result != NULL, "else statement must define global val");
    show_ok();

    symt_delete(tab);
}

void test_search_by_name()
{
    symt_tab* tab;
    symt_node *result;
    int *val1, *val2, *val3;

    val1 = (int*)(ml_malloc(sizeof(int)));
    val2 = (int*)(ml_malloc(sizeof(int)));
    val3 = (int*)(ml_malloc(sizeof(int)));
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_search_by_name");

    tab = symt_new();
    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar1", I32, false, 0, val1, false);

    test_assert("test_search_gvar1");
    result = symt_search_by_name(tab, (char*)"gvar1", GLOBAL_VAR);
    assertp(result != NULL, "global var should exist");
    show_ok();

    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar2", I32, false, 0, val2, false);
    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar3", I32, false, 0, val3, false);
    tab = symt_insert_tab_rout(tab, PROCEDURE, (char*)"main", VOID, NULL, false, NULL);

    test_assert("test_search_main");
    result = symt_search_by_name(tab, (char*)"main", PROCEDURE);
    assertp(result != NULL, "procedure should exist");
    show_ok();

    test_assert("test_search_gvar1_again");
    result = symt_search_by_name(tab, (char*)"gvar1", GLOBAL_VAR);
    assertp(result != NULL, "global var 1 should exist");
    show_ok();

    test_assert("test_search_gvar2");
    result = symt_search_by_name(tab, (char*)"gvar2", GLOBAL_VAR);
    assertp(result != NULL, "global var 2 should exist");
    show_ok();

    test_assert("test_search_gvar3");
    result = symt_search_by_name(tab, (char*)"gvar3", GLOBAL_VAR);
    assertp(result != NULL, "global var 3 should exist");
    show_ok();

    symt_delete(tab);
}

void test_end_block()
{
    symt_tab *tab, *result;
    symt_node *cond, *statements;
    symt_node *iter_op, * iter_var;
	symt_node *if_statements, *else_statements;

	int* val1 = (int*)(ml_malloc(sizeof(int)));
    int* val2 = (int*)(ml_malloc(sizeof(int)));
    int* val3 = (int*)(ml_malloc(sizeof(int)));
    *val1 = 10; *val2 = 20; *val3 = 30;

    test_name("test_end_block");

    tab = symt_new();
    cond = symt_new();
    statements = symt_new();

    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar1", I32, false, 0, NULL, false);
    tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"gvar2", I32, false, 0, NULL, false);

    statements = symt_insert_tab_var(statements, LOCAL_VAR, (char*)"lvar1", I64, false, 0, NULL, false);
    statements = symt_insert_tab_var(statements, LOCAL_VAR, (char*)"lvar2", I64, false, 0, NULL, false);
    tab = symt_insert_tab_while(tab, cond, statements);

    test_assert("test_end_block_while");
    symt_end_block(tab, WHILE);
    assertp(tab->next_node->next_node == NULL, "block statement wasn't clean");
    assertf(tab->var != NULL, "global variable %s must exist", "gvar1");
    assertf(tab->next_node->var != NULL, "global variable %s must exist", "gvar2");

    result = symt_search_by_name(tab, (char*)"lvar1", LOCAL_VAR);
    assertf(result == NULL, "local var %s should not exist", "lvar1");

    result = symt_search_by_name(tab, (char*)"lvar2", LOCAL_VAR);
    assertf(result == NULL, "local var %s should not exist", "lvar2");
    show_ok();

    iter_var = symt_new();
    iter_var = symt_insert_tab_var(iter_var, LOCAL_VAR, (char*)"i", I32, false, 0, NULL, false);

    cond = NULL; statements = NULL; iter_op = NULL;
    tab = symt_insert_tab_for(tab, cond, statements, iter_var, iter_op);

    test_assert("test_end_block_for");
    symt_end_block(tab, FOR);

    assertp(tab->next_node->next_node == NULL, "block statement wasn't clean");
    assertf(tab->var != NULL, "global variable %s must exist", "gvar1");
    assertf(tab->next_node->var != NULL, "global variable %s must exist", "gvar2");

    result = symt_search_by_name(tab, (char*)"i", LOCAL_VAR);
    assertf(result == NULL, "local var %s should not exist", "i");
    show_ok();

	cond = symt_new();
    if_statements = symt_new();
    else_statements = NULL;

    if_statements = symt_insert_tab_var(if_statements, LOCAL_VAR, (char*)"local_var1", I32, false, 0, val1, false);

    tab = symt_new();
	tab = symt_insert_tab_var(tab, GLOBAL_VAR, (char*)"local_var2", I32, false, 0, val2, false);
    tab = symt_insert_tab_if(tab, cond, if_statements, else_statements);

	test_assert("test_end_block_if");
    symt_end_block(tab, IF);

	result = symt_search(tab, LOCAL_VAR);
	assertp(result == NULL, "local var must not be defined");

	result = symt_search(tab, GLOBAL_VAR);
	assertp(result != NULL, "global var must be defined");

	assertp(tab->if_val == NULL, "if statements must not be defined");
    show_ok();
}

void test_merge()
{
    symt_tab* tab1, *tab2;
    symt_node *result;

    test_name("test_merge");

    tab1 = symt_new();
    tab2 = symt_new();

    tab1 = symt_insert_tab_var(tab1, GLOBAL_VAR, (char*)"gvar", F32, false, 10, NULL, false);

    tab2 = symt_insert_tab_var(tab2, LOCAL_VAR, (char*)"lvar1", C, true, 10, NULL, false);
    tab2 = symt_insert_tab_var(tab2, LOCAL_VAR, (char*)"lvar2", C, true, 10, NULL, true);
    tab2 = symt_insert_tab_rout(tab2, PROCEDURE, (char*)"main", VOID, NULL, true, NULL);
    tab2 = symt_insert_tab_rout(tab2, FUNCTION, (char*)"func", I32, NULL, false, NULL);

    tab1 = symt_merge(tab2, tab1);

    test_assert("test_search_global_var");
    result = symt_search(tab1, GLOBAL_VAR);
    assertp(result != NULL, "global variable must exist after merging");
    show_ok();

    test_assert("test_search_procedure");
    result = symt_search(tab1, PROCEDURE);
    assertp(result == NULL, "procedure must not exist after merging");
    show_ok();

    test_assert("test_search_function");
    result = symt_search(tab1, FUNCTION);
    assertp(result != NULL, "function must exist after merging");
    show_ok();

    test_assert("test_search_local_var_public");
    result = symt_search_by_name(tab1, (char*)"lvar1", LOCAL_VAR);
    assertf(result != NULL, "%s must exist after merging", "lvar1");
    show_ok();

    test_assert("test_search_local_var_hide");
    result = symt_search_by_name(tab1, (char*)"lvar2", LOCAL_VAR);
    assertf(result == NULL, "%s must not exist after merging", "lvar2");
    show_ok();

    symt_delete(tab1);
    symt_delete(tab2);
}

int main(int nargc, char *argv[])
{
    test_welcome();
    test_new_delete();
    test_push();
    test_search();
    test_search_by_name();
    test_merge();
    test_end_block();

    return 0;
}
