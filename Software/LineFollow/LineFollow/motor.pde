/*
  Motor driver software
  Bot Thoughts

  AFRON "10 Dollar Robotic Challenge" 

  This is the code used in the demonstration video  
 */
 

/* DO NOT EDIT - VERY IMPORTANT
 *
 * If you goof these definitions up you will fry your motor drivers 
 *
 * If you enable NMOS and PMOS on the same IC, you get "shoot through"
 * which is maximum available current from the battery through the
 * MOSFETs which will fry them fast
 */
//#define NMOS2 9  // NMOS on IC2, PB1
#define NMOS2_DIR  DDRB
#define NMOS2_PORT PORTB
#define NMOS2_PIN 1
#define NMOS2_ON()  NMOS2_PORT |=  _BV(NMOS2_PIN)
#define NMOS2_OFF() NMOS2_PORT &= ~_BV(NMOS2_PIN)

//#define PMOS2 10 // PMOS on IC2, PB2
#define PMOS2_DIR  DDRB
#define PMOS2_PORT PORTB
#define PMOS2_PIN 2
#define PMOS2_ON()  PMOS2_PORT &= ~_BV(PMOS2_PIN)
#define PMOS2_OFF() PMOS2_PORT |=  _BV(PMOS2_PIN)

//#define NMOS3 7  // NMOS on IC3, PD7
#define NMOS3_DIR  DDRD
#define NMOS3_PORT PORTD
#define NMOS3_PIN 7
#define NMOS3_ON()  NMOS3_PORT |=  _BV(NMOS3_PIN)
#define NMOS3_OFF() NMOS3_PORT &= ~_BV(NMOS3_PIN)

//#define PMOS3 8  // PMOS on IC3, PB0
#define PMOS3_DIR  DDRB
#define PMOS3_PORT PORTB
#define PMOS3_PIN 0
#define PMOS3_ON()  PMOS3_PORT &= ~_BV(PMOS3_PIN)
#define PMOS3_OFF() PMOS3_PORT |=  _BV(PMOS3_PIN)

enum { FORWARD, REVERSE, STOP, COAST };

static int motorCount=0;
static int motorDuty=0;
static int motorMode=FORWARD;

/* END DO NOT EDIT */

/* Shoot through
 *
 * If we switch motor direction, we have to be careful about shoot through
 * where both MOSFETs on the same IC are on.
 *
 * MOSFETs have a turn on and turn off delay. The datasheets tend not to show
 * that delay for very low voltages like our intended robot is running.
 *
 * Delays are on the order of 10s of nanoseconds at higher voltages. At 8MHz
 * we run an instruction every 125ns.  If we wait for a few microseconds we
 * should be ok.
 */
void motorInit()
{
  /* make sure everything's off, first */
  NMOS2_OFF();
  PMOS2_OFF();
  NMOS3_OFF();
  PMOS3_OFF();
  motorDelay();
  /* enable pins for control */
  NMOS2_DIR |= _BV(NMOS2_PIN);
  PMOS2_DIR |= _BV(PMOS2_PIN);
  NMOS3_DIR |= _BV(NMOS3_PIN);
  PMOS3_DIR |= _BV(PMOS3_PIN);

  /* Setup PWM interrupt and handler */  
  cli();
  TCCR2A = 0;
  TCCR2B = 0;
  TCCR2B |= (1 << WGM22); // turn on CTC mode:
  TIMSK2 = (1 << OCIE2A); // Timer compare
  TCCR2B |= _BV(CS20);    // clk/1 = 8MHz
  OCR2A = 20;             // 200kHz, duty count = /64 = 3125
  sei();
}

void motorSpeed(int duty)
{
  /* duty must fall in the range 0-63 */
  motorDuty = duty & 0x3F;
}

void motorForward()
{
  motorMode = FORWARD;
}

void motorReverse()
{
  motorMode = REVERSE;
}

void motorStop()
{
  motorMode = STOP;
}

void motorCoast()
{
  motorMode = COAST;
}


void motorDelay()
{
  delayMicroseconds(100);
}


ISR(TIMER2_COMPA_vect)
{
  // Motor control, ensure no shoot through
  // Motor on duty

  /* motorCount must fall between 0 and 63 */
  motorCount = (motorCount + 1) & 0x3F;
  
  switch (motorMode) {
    
    case FORWARD:
      if (motorCount < motorDuty) {    /* on part of duty cycle */  
        NMOS3_OFF(); PMOS3_OFF();
        NMOS2_ON();  PMOS3_ON();
      } else {                         /* off part of duty cycle */
        NMOS3_OFF(); PMOS3_OFF();
        NMOS2_OFF(); PMOS3_OFF();
      } 
      break;
    case REVERSE:
      break;
    case STOP:
    case COAST:
      NMOS3_OFF(); PMOS3_OFF();
      NMOS2_OFF(); PMOS3_OFF();
      break;  
    default :
      break;
  }
}

