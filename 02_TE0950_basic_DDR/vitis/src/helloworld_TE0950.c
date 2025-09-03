/******************************************************************************
* Copyright (C) 2025 Florent Werbrouck. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld_TE0950.c: simple test application
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"


int main()
{
    init_platform();

    int i = 0;

    while(1)
    {
        xil_printf("Hello World from TE0950 board # %d\n\r",i++);
        sleep(5);
    }
    
    cleanup_platform();
    return 0;
}