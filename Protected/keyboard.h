#ifndef KEYBOARD_H
#define KEYBOARD_H

#define LED_SCROLL_LOCK		1
#define LED_NUM_LOCK		2
#define LED_CAPS_LOCK		4

#define CK_SHIFT	1
#define	CK_ALT		2
#define CK_CTRL		4

void InitKeyboard();
void keyb_handler();
void setleds();
unsigned char getch();
unsigned char kbhit();

#endif
