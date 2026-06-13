/*
 * source.c
 *
 *  Created on: May 20, 2026
 *      Author: NhatHuyCE
 */
#include "system.h"
#include "io.h"
#include "stdio.h"
#include "sys/alt_irq.h"
#include "alt_types.h"

#define DMA_REG_SRC      0
#define DMA_REG_DST      1
#define DMA_REG_LENGTH   2
#define DMA_REG_CONTROL  3
#define DMA_REG_STATUS   7

#define DMA_CONTROL_GO   0x8
#define DMA_STATUS_DONE  0x1
#define DMA_STATUS_BUSY  0x2

volatile int dma_done = 0;

int length = 32;
int control = DMA_CONTROL_GO;

char pdata0[32] = {
    0, 1, 2, 3, 4, 5, 6, 7,
    8, 9, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20, 21, 22, 23,
    24, 25, 26, 27, 28, 29, 30, 31
};

char *pdata1 = (char *)(ONCHIP_MEMORY2_1_BASE);

void print_result(void)
{
    int i;

    printf("Ket qua sau khi DMA copy:\n");

    for (i = 0; i < 32; i++)
    {
        printf("Byte %d = %d\n", i, pdata1[i]);
    }
}

void do_other_work(void)
{
   
}

/* ISR cua DMA */
static void dma_isr(void *context)
{
    volatile int status;
    status = IORD_32DIRECT(DMA_0_BASE, DMA_REG_STATUS * 4);
    (void)status;
    dma_done = 1;
}

static void dma_init_interrupt(void)
{
    #if defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
        alt_ic_isr_register(
            DMA_0_IRQ_INTERRUPT_CONTROLLER_ID,
            DMA_0_IRQ,
            dma_isr,
            NULL,
            NULL
        );
    #else
        alt_irq_register(
            DMA_0_IRQ,
            NULL,
            dma_isr
        );
    #endif
}

int main(void)
{
    int cpu_counter = 0;
    dma_done = 0;
    printf("Bat dau chuong trinh...\n");
    dma_init_interrupt();
    printf("Da dang ky ISR\n");

    IOWR_32DIRECT(DMA_0_BASE, DMA_REG_SRC     * 4, (int)pdata0);
    IOWR_32DIRECT(DMA_0_BASE, DMA_REG_DST     * 4, (int)pdata1);
    IOWR_32DIRECT(DMA_0_BASE, DMA_REG_LENGTH  * 4, length);
    IOWR_32DIRECT(DMA_0_BASE, DMA_REG_CONTROL * 4, control);

    // printf("Da start DMA, CPU dang lam viec khac...\n");
    while (!dma_done)
    {
        cpu_counter++;
        do_other_work();
    }

    printf("DMA hoan thanh!\n");
    printf("CPU da dem duoc %d vong trong luc DMA chay.\n", cpu_counter);
    print_result();
    return 0;
}
