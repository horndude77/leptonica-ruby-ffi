#include <stdio.h>
#include <stdlib.h>

#include "allheaders.h"

void estimate_staff_parameters(PIX *pixs, l_uint32 *staff_height, l_uint32 *staff_space)
{
    l_int32 rows = pixGetHeight(pixs);
    l_int32 cols = pixGetWidth(pixs);
    l_int32 row, col, i, currLength, val, color;

    l_uint32 staff_height_histogram[rows];
    l_uint32 staff_space_histogram[rows];

    for(i=0; i<rows; ++i)
    {
        staff_height_histogram[i] = 0;
        staff_space_histogram[i] = 0;
    }

    for(col=0; col<cols; ++col)
    {
        currLength = 0;
        color = 0;
        for(row=0; row<rows; ++row)
        {
            pixGetPixel(pixs, col, row, &val);
            if(val == color)
            {
                ++currLength;
            }
            else if(currLength > 0)
            {
                if(color == 1)
                {
                    ++staff_height_histogram[currLength];
                }
                else
                {
                    ++staff_space_histogram[currLength];
                }
                color = val;
                currLength = 0;
            }
        }
    }

    /* find maxes */
    l_uint32 max_height = 0, max_height_index = 0;
    l_uint32 max_space = 0, max_space_index = 0;
    for(i=0; i<rows; ++i)
    {
        if(staff_height_histogram[i] > max_height)
        {
            max_height = staff_height_histogram[i];
            max_height_index = i;
        }
        if(staff_space_histogram[i] > max_space)
        {
            max_space = staff_space_histogram[i];
            max_space_index = i;
        }
    }

    *staff_height = max_height_index;
    *staff_space = max_space_index;
}

/*
int main(int argc, char** argv)
{
    if(argc != 2)
    {
        printf("Usage: kmeans_threshold <input>\n");
        exit(-1);
    }

    char *input_filename;
    PIX *input;

    input_filename = argv[1];

    if((input = pixRead(input_filename)) == NULL)
    {
        printf("Unable to read file.\n");
        exit(-1);
    }

    l_uint32 staff_height, staff_space;
    estimate_staff_parameters(input, &staff_height, &staff_space);

    printf("Staff height: %d\nStaff space: %d\n", staff_height, staff_space);

    pixDestroy(&input);
}
*/
