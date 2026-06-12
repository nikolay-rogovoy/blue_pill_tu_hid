#include "led_task.h"
#include "usb_report_task.h"
#include "usb_hid.h"

void vLEDTask(void *pvParameters)
{
    (void)pvParameters;
    uint32_t button_mask = 0x00000001u;

    for (;;)
    {
        HAL_GPIO_TogglePin(LED_PORT, LED_PIN);

        if (xUSBReportSemaphore != NULL)
        {
            usb_hid_set_buttons(button_mask);
            xSemaphoreGive(xUSBReportSemaphore);

            button_mask <<= 1;
            if (button_mask == 0u)
            {
                button_mask = 0x00000001u;
            }
        }

        vTaskDelay(pdMS_TO_TICKS(LED_TOGGLE_INTERVAL_MS));
    }
}
