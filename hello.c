#include <stdio.h>
#include <stdlib.h>

#include <mruby.h>
#include <mruby/irep.h>
#include "sbi/sbi.h"
#include "test_program.c"

int main(void)
{
	sbi_console_init();
	sbi_puts("hello implemented by opensbi\n");

	mrb_state *mrb = mrb_open();
	if (!mrb) {
		fprintf(stderr, "error: failed to initialize mruby!\n");
		exit(1);
	}
	mrb_load_irep(mrb, test_symbol);
	mrb_close(mrb);

	exit(0);
}
