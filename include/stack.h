#ifndef STACK_H
#define STACK_H

typedef struct stack_t
{
	void *value;
	struct stack_t* next;
} stack_t;

typedef int type_t;

stack_t* stack_new();

void stack_push(stack_t *stack, type_t *value);

stack_t *stack_pop(stack_t *stack);

int stack_len(stack_t *stack);

void stack_delete(stack_t *stack);

#endif 	// STACK_H
