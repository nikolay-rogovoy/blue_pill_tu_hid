#ifndef USB_REPORT_TASK_H_
#define USB_REPORT_TASK_H_

#include "FreeRTOS.h"
#include "semphr.h"
#include "task.h"

extern SemaphoreHandle_t xUSBReportSemaphore;

void USBReportTask(void *pvParameters);

#endif /* USB_REPORT_TASK_H_ */
