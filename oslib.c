#include <stdio.h>
#include "sbi/sbi.h"

[[noreturn]] void
_exit(int status)
{
	sbi_system_shutdown();
}

int
isatty(int fd) {
	return 0;
}

static int
_putc(char ch, FILE *file)
{
	(void) file;
	sbi_putc(ch);
	return ch;
}

static int
_getc(FILE *file)
{
	unsigned char ch;
	(void) file;
	ch = sbi_getc();
	return ch;
}

static FILE __stdio = FDEV_SETUP_STREAM(_putc, _getc, NULL, _FDEV_SETUP_RW);
FILE *const stdin = &__stdio;
__strong_reference(stdin, stdout);
__strong_reference(stdin, stderr);
