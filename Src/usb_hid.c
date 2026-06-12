#include <string.h>
#include "stm32f1xx_hal.h"
#include "tusb.h"
#include "usb_hid.h"

static volatile blue_hid_report_t current_hid_report = {
    .buttons = 0,
    .padding = 0,
};

void usb_device_init(void)
{
    /* Инициализация USB контроллера STM32 */
    __HAL_RCC_USB_CLK_ENABLE();
    HAL_NVIC_SetPriority(USB_LP_CAN1_RX0_IRQn, 6, 0);
    HAL_NVIC_EnableIRQ(USB_LP_CAN1_RX0_IRQn);

    /* Инициализация TinyUSB stack */
    tusb_rhport_init_t dev_init = {
        .role = TUSB_ROLE_DEVICE,
        .speed = TUSB_SPEED_FULL
    };
    tusb_init(0, &dev_init);
}

void usb_hid_set_buttons(uint32_t buttons)
{
    current_hid_report.buttons = buttons;
    current_hid_report.padding = 0;
}

uint32_t usb_hid_get_buttons(void)
{
    return current_hid_report.buttons;
}

uint16_t tud_hid_get_report_cb(uint8_t instance,
                               uint8_t report_id,
                               hid_report_type_t report_type,
                               uint8_t *buffer,
                               uint16_t reqlen)
{
    (void)instance;
    (void)report_id;

    if (report_type != HID_REPORT_TYPE_INPUT || buffer == NULL)
    {
        return 0;
    }

    uint16_t const len = reqlen < sizeof(current_hid_report) ? reqlen : sizeof(current_hid_report);
    memcpy(buffer, (const void *)&current_hid_report, len);
    return len;
}

void tud_hid_set_report_cb(uint8_t instance,
                           uint8_t report_id,
                           hid_report_type_t report_type,
                           uint8_t const *buffer,
                           uint16_t bufsize)
{
    (void)instance;
    (void)report_id;

    if (report_type != HID_REPORT_TYPE_OUTPUT || buffer == NULL || bufsize == 0)
    {
        return;
    }

    // В данной реализации контроллера выходные отчёты не используются.
    // Если понадобится поддержка светодиодов или других эффектов,
    // обработку можно добавить здесь.
}
