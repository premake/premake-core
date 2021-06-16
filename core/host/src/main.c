#include "premake.h"

static void errorHandler(const char* message, const char* traceback);


int main(int argc, const char** argv)
{
	pmk_State* P = pmk_init(errorHandler);
	if (P == NULL) {
		return (-1);
	}

	if (pmk_execute(P, argc, argv) != OKAY) {
		return (-1);
	}

	pmk_close(P);
	return (0);
}


static void errorHandler(const char* message, const char* traceback)
{
#if !defined(NDEBUG)
	if (traceback != NULL) {
		message = traceback;
	}
#else
	(void) traceback;
#endif

	pmk_setTextColor(PMK_COLOR_ERROR);
	printf("Error: %s\n", message);
}
