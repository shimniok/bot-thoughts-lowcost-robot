#include "stdlib.h"
#include "IRremote.h"
#include "pitches.h"
#include "Minibloq.h"


void setup()
{
	initBoard();

	while(true)
	{
		DigitalWrite(D13_LED, false);
		delay(1000);
		DigitalWrite(D13_LED, true);
		delay(1000);
	}
}

void loop()
{
}
