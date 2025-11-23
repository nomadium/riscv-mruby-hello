#include <stdio.h>
#include <stdlib.h>

#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/compile.h>
#include "test_program.c"

int main(void)
{
	mrb_state *mrb = mrb_open();
	if (!mrb) {
		printf("error: failed to initialize mruby!\n");
		exit(1);
	}
	mrb_load_irep(mrb, test_symbol);
	//mrb_load_string(mrb, "print '1'");
	mrb_close(mrb);

	exit(0);
}
