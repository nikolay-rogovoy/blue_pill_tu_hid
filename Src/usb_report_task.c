#include "usb_report_task.h"
#include "usb_hid.h"
#include "tusb.h"

void USBReportTask(void *pvParameters)
{
    (void)pvParameters;

    for (;;)
    {
        if (xUSBReportSemaphore != NULL && xSemaphoreTake(xUSBReportSemaphore, portMAX_DELAY) == pdTRUE)
        {
            blue_hid_report_t report = {
                .buttons = usb_hid_get_buttons(),
                .padding = 0,
            };

            if (tud_hid_ready())
            {
                tud_hid_report(0, &report, sizeof(report));
            }
        }
    }
}
