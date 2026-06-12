#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif


#include "stm32f1xx_hal.h"

/* Определения пинов */
#define LED_PIN                     GPIO_PIN_13
#define LED_PORT                    GPIOC

/* Другие определения */
#define LED_TOGGLE_INTERVAL_MS      1000

/* Прототипы функций */
void Error_Handler(void);
void SystemClock_Config(void);
void vLEDTask(void *pvParameters);
void USBTask(void *pvParameters);
void USBReportTask(void *pvParameters);

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */